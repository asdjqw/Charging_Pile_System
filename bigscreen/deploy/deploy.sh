#!/usr/bin/env bash
# ============================================================================
# 充电桩运营数据大屏 · 一键部署脚本（CentOS/RHEL 与 Ubuntu/Debian 通用）
#
#   在虚拟机（如 bit@192.168.44.129）上执行：
#       cd charging-bigscreen && bash deploy/deploy.sh
#
#   脚本流程：环境检查 -> 依赖安装 -> MySQL 初始化 -> Spark 离线计算
#             -> 结果装载 MySQL -> 前端构建 -> 启动 Flask(gunicorn) 服务
#   可重复执行（幂等）。
# ============================================================================
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

PYTHON_BIN="${PYTHON_BIN:-python3.12}"
SKIP_INSTALL="${SKIP_INSTALL:-0}"
SKIP_SPARK="${SKIP_SPARK:-0}"
SERVER_PORT="${SERVER_PORT:-5000}"

log()  { printf '\033[36m[%s]\033[0m %s\n' "$(date '+%H:%M:%S')" "$*"; }
warn() { printf '\033[33m[WARN]\033[0m %s\n' "$*"; }
die()  { printf '\033[31m[ERROR]\033[0m %s\n' "$*" >&2; exit 1; }

have() { command -v "$1" >/dev/null 2>&1; }

# 非 root 用户时自动使用 sudo（sudo 需可用；若已配置免密更佳）
SUDO=""
if [[ "$(id -u)" -ne 0 ]] && have sudo; then
  SUDO="sudo"
fi

# ---------------------------------------------------------------------------
# 0. 读取数据库配置
# ---------------------------------------------------------------------------
if [[ ! -f config/database.env ]]; then
  cp config/database.env.example config/database.env
  log "已从 database.env.example 创建本机数据库配置"
fi

read_env_value() {
  local key="$1" default="$2"
  if [[ -f config/database.env ]]; then
    local value
    value="$(grep -E "^${key}=" config/database.env | head -n1 | cut -d= -f2- || true)"
    [[ -n "${value:-}" ]] && { echo "$value"; return; }
  fi
  echo "$default"
}

DB_HOST="$(read_env_value DB_HOST 127.0.0.1)"
DB_PORT="$(read_env_value DB_PORT 3306)"
DB_USER="$(read_env_value DB_USER root)"
DB_PASSWORD="$(read_env_value DB_PASSWORD '')"
DB_NAME="$(read_env_value DB_NAME charging_screen)"

# ---------------------------------------------------------------------------
# 1. 环境检查 / 依赖安装
# ---------------------------------------------------------------------------
detect_pkg_mgr() {
  if have yum; then echo yum
  elif have dnf; then echo dnf
  elif have apt-get; then echo apt
  else echo none; fi
}

install_dependencies() {
  local mgr; mgr="$(detect_pkg_mgr)"
  log "包管理器：$mgr"
  case "$mgr" in
    yum|dnf)
      $SUDO $mgr install -y java-11-openjdk-headless mysql-server tar gzip curl || \
        $SUDO $mgr install -y java-1.8.0-openjdk-headless mysql-server tar gzip curl || true
      $SUDO $mgr install -y python3.11 python3.11-devel python3-pip || \
        $SUDO $mgr install -y python3 python3-devel python3-pip || true
      ;;
    apt)
      export DEBIAN_FRONTEND=noninteractive
      $SUDO apt-get update -y
      # Spark 3.5 支持 Java 8/11/17，优先安装 11（Ubuntu 22.04 官方源自带）
      $SUDO apt-get install -y openjdk-11-jdk-headless mysql-server tar gzip curl python3-venv python3-pip || \
        $SUDO apt-get install -y openjdk-17-jdk-headless mysql-server tar gzip curl python3-venv python3-pip || \
        $SUDO apt-get install -y openjdk-8-jdk-headless mysql-server tar gzip curl python3-venv python3-pip || true
      # 要求 Python 3.11/3.12：Ubuntu 22.04 默认 3.10，尝试通过 deadsnakes PPA 安装 3.12
      if ! command -v python3.12 >/dev/null 2>&1 && ! command -v python3.11 >/dev/null 2>&1; then
        $SUDO apt-get install -y software-properties-common || true
        $SUDO add-apt-repository -y ppa:deadsnakes/ppa || true
        $SUDO apt-get update -y || true
        $SUDO apt-get install -y python3.12 python3.12-venv python3.12-dev || \
          $SUDO apt-get install -y python3.11 python3.11-venv python3.11-dev || true
      fi
      ;;
    *)
      warn "未识别的包管理器，跳过系统依赖安装"
      ;;
  esac

  # Node.js 23+（前端构建）
  if ! have node || [[ "$(node -v | sed 's/v\([0-9]*\).*/\1/')" -lt 23 ]]; then
    log "安装 Node.js 23（前端要求 23 及以上）"
    if [[ "$mgr" == "apt" ]]; then
      curl -fsSL https://deb.nodesource.com/setup_23.x | $SUDO bash - && $SUDO apt-get install -y nodejs
    else
      curl -fsSL https://rpm.nodesource.com/setup_23.x | $SUDO bash - && $SUDO $mgr install -y nodejs
    fi
  fi

  have node && log "Node 版本：$(node -v)" || warn "Node 未安装，前端构建将跳过（可直接使用已构建的 frontend/dist）"
}

# ---------------------------------------------------------------------------
# 2. MySQL 初始化与启动
# ---------------------------------------------------------------------------
start_mysql() {
  log "检查 MySQL 服务"
  if have systemctl; then
    $SUDO systemctl enable mysqld >/dev/null 2>&1 || $SUDO systemctl enable mysql >/dev/null 2>&1 || true
    $SUDO systemctl start mysqld >/dev/null 2>&1 || $SUDO systemctl start mysql >/dev/null 2>&1 || true
  elif have service; then
    $SUDO service mysqld start >/dev/null 2>&1 || $SUDO service mysql start >/dev/null 2>&1 || true
  fi
  sleep 2
  have mysql || { warn "未找到 mysql 客户端"; return; }
  if mysql_ping; then
    log "MySQL 已就绪"
  else
    warn "MySQL 未就绪，请检查服务状态/账号密码"
  fi
}

# 依次尝试：配置账号 -> sudo 本机 root -> 本机 root，兼容 Ubuntu(auth_socket) 与 CentOS(空密码 root)
mysql_ping() {
  if [[ -n "$DB_PASSWORD" ]]; then
    mysqladmin ping -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASSWORD" >/dev/null 2>&1 && return 0
  fi
  mysqladmin ping -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" >/dev/null 2>&1 && return 0
  $SUDO mysql -uroot -e "select 1" >/dev/null 2>&1 && return 0
  mysql -uroot -e "select 1" >/dev/null 2>&1 && return 0
  return 1
}

# 在某个可用入口上执行 SQL（自动选择可用的 root 登录方式）
mysql_exec() {
  local sql="$1"
  if [[ -n "$DB_PASSWORD" ]] && \
     mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASSWORD" -e "$sql" >/dev/null 2>&1; then
    return 0
  fi
  if mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -e "$sql" >/dev/null 2>&1; then
    return 0
  fi
  if $SUDO mysql -uroot -e "$sql" >/dev/null 2>&1; then
    return 0
  fi
  if mysql -uroot -e "$sql" >/dev/null 2>&1; then
    return 0
  fi
  return 1
}

init_mysql() {
  log "初始化数据库 $DB_NAME 与应用账号"
  local sql="CREATE DATABASE IF NOT EXISTS \`$DB_NAME\` DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_general_ci;"
  if mysql_exec "$sql"; then
    log "数据库已就绪：$DB_NAME"
  else
    warn "数据库初始化失败，请确认 config/database.env 中的账号密码（或使用 sudo 执行本脚本）"
  fi

  # Ubuntu 下 root 默认走 auth_socket，应用需要一个可用的密码账号
  if [[ "$DB_USER" == "root" && -z "$DB_PASSWORD" ]]; then
    local app_user="charging" app_pass="charging123"
    if mysql_exec "
      CREATE USER IF NOT EXISTS '$app_user'@'%' IDENTIFIED BY '$app_pass';
      CREATE USER IF NOT EXISTS '$app_user'@'localhost' IDENTIFIED BY '$app_pass';
      GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$app_user'@'%';
      GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$app_user'@'localhost';
      FLUSH PRIVILEGES;"; then
      log "已创建应用账号 $app_user，并写入本机 config/database.env"
      sed -i -e "s/^DB_USER=.*/DB_USER=$app_user/" -e "s/^DB_PASSWORD=.*/DB_PASSWORD=$app_pass/" config/database.env
      DB_USER="$app_user"; DB_PASSWORD="$app_pass"
    else
      warn "创建应用账号失败，请手工准备 MySQL 账号后修改 config/database.env"
    fi
  fi
}

# ---------------------------------------------------------------------------
# 3. Python 虚拟环境
# ---------------------------------------------------------------------------
setup_venv() {
  log "创建 Python 虚拟环境 .venv"
  local py=""
  for candidate in "$PYTHON_BIN" python3.12 python3.11 python3; do
    if have "$candidate"; then py="$candidate"; break; fi
  done
  [[ -n "$py" ]] || die "未找到 python3，请先安装 Python 3.11/3.12"
  "$py" -V
  [[ -d .venv ]] || "$py" -m venv .venv
  ./.venv/bin/python -m pip install --upgrade pip -i "${PIP_INDEX:-https://pypi.tuna.tsinghua.edu.cn/simple}" || true
  log "安装 PySpark 与 Flask 依赖（约 350MB，请耐心等待）"
  ./.venv/bin/pip install -r backend/requirements.txt -i "${PIP_INDEX:-https://pypi.tuna.tsinghua.edu.cn/simple}"
  ./.venv/bin/pip install "pyspark==3.5.3" -i "${PIP_INDEX:-https://pypi.tuna.tsinghua.edu.cn/simple}"
}

# ---------------------------------------------------------------------------
# 4. Spark 离线计算 + 装载 MySQL
# ---------------------------------------------------------------------------
run_pipeline() {
  log "执行 Spark 数据清洗与多维分析"
  export JAVA_HOME="${JAVA_HOME:-$(dirname "$(dirname "$(readlink -f "$(command -v java)")")")}"
  export PYSPARK_PYTHON="$ROOT_DIR/.venv/bin/python"
  ./.venv/bin/python spark/jobs/run_all.py --raw data/raw_expanded
  log "装载分析结果到 MySQL"
  ./.venv/bin/python spark/jobs/load_mysql.py
}

# ---------------------------------------------------------------------------
# 5. 前端构建
# ---------------------------------------------------------------------------
build_frontend() {
  if ! have node; then
    warn "跳过前端构建（未安装 Node.js）"
    return
  fi
  log "构建前端（Vue3 + DataV + ECharts）"
  ( cd frontend && npm install --no-fund --no-audit && npm run build )
  log "前端构建完成：frontend/dist"
}

# ---------------------------------------------------------------------------
# 6. 启动后端服务
# ---------------------------------------------------------------------------
start_backend() {
  log "启动 Flask 服务（gunicorn，端口 $SERVER_PORT）"
  pkill -f 'gunicorn.*backend.wsgi' >/dev/null 2>&1 || true
  PORT="$SERVER_PORT" nohup ./.venv/bin/gunicorn -c deploy/gunicorn.conf.py backend.wsgi:application \
    > logs/gunicorn.log 2>&1 &
  sleep 3
  if curl -sf "http://127.0.0.1:${SERVER_PORT}/api/health" >/dev/null; then
    log "服务已启动： http://$(hostname -I 2>/dev/null | awk '{print $1}'):${SERVER_PORT}/"
  else
    warn "服务启动检查失败，请查看 logs/gunicorn.log"
  fi
}

main() {
  mkdir -p logs
  log "项目目录：$ROOT_DIR"
  if [[ "$SKIP_INSTALL" != "1" ]]; then install_dependencies; fi
  start_mysql
  init_mysql
  setup_venv
  if [[ "$SKIP_SPARK" != "1" ]]; then run_pipeline; fi
  build_frontend
  start_backend
  log "部署完成。浏览器访问： http://<虚拟机IP>:${SERVER_PORT}/"
  log "如需 nginx 与开机自启，请执行： bash deploy/install_service.sh"
}

main "$@"
