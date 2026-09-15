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

# ---------------------------------------------------------------------------
# 虚拟环境位置：项目放在 VMware 共享目录（/mnt/hgfs/...）时，hgfs 不支持符号链接、
# chmod 也不生效，venv 建在里面会失败或极慢，因此自动改用家目录下的本地路径。
# ---------------------------------------------------------------------------
resolve_venv_dir() {
  if [[ -n "${VENV_DIR:-}" ]]; then echo "$VENV_DIR"; return; fi
  if [[ -f "$ROOT_DIR/deploy/venv_path.sh" ]]; then
    # shellcheck disable=SC1091
    source "$ROOT_DIR/deploy/venv_path.sh"
    [[ -n "${VENV_DIR:-}" ]] && { echo "$VENV_DIR"; return; }
  fi
  case "$ROOT_DIR" in
    /mnt/hgfs/*|/media/sf_*|/mnt/*) echo "$HOME/.venvs/charge-pile-bigscreen" ;;
    *) echo "$ROOT_DIR/.venv" ;;
  esac
}

VENV_DIR="$(resolve_venv_dir)"
PY="$VENV_DIR/bin/python"
PIP="$VENV_DIR/bin/pip"

PYTHON_BIN="${PYTHON_BIN:-python3.12}"
SKIP_INSTALL="${SKIP_INSTALL:-0}"
SKIP_SPARK="${SKIP_SPARK:-0}"
SKIP_BACKEND="${SKIP_BACKEND:-0}"   # 1：只准备环境与数据，不启动/重启后端（用于准备阶段或调试）
LOAD_SQL="${LOAD_SQL:-auto}"     # auto：有 sql 备份且跳过 Spark 时直接导入，速度最快
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

SUDO_KEEPALIVE_PID=""

# 提前获取一次 sudo 授权（只提示一次密码），后续建库/装依赖都不再打断
ensure_sudo() {
  [[ -n "$SUDO" ]] || return 0
  if ! $SUDO -n true 2>/dev/null; then
    log "后面要安装依赖、初始化 MySQL，需要管理员权限；请输入 sudo 密码（本虚拟机通常是 123456）"
    $SUDO -v || die "sudo 授权失败：请改用  sudo bash deploy/deploy.sh  重新执行"
  fi
  # 后台刷新 sudo 时间戳，避免长时间安装过程中授权过期
  ( while true; do $SUDO -n true 2>/dev/null || exit; sleep 50; done ) &
  SUDO_KEEPALIVE_PID=$!
  trap '[[ -n "$SUDO_KEEPALIVE_PID" ]] && kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true' EXIT
}

# ---------------------------------------------------------------------------
# 0. 读取数据库配置
# ---------------------------------------------------------------------------
read_env_value() {
  local key="$1" default="$2"
  if [[ -f config/database.env ]]; then
    local value
    value="$(grep -E "^${key}=" config/database.env | head -n1 | cut -d= -f2- || true)"
    [[ -n "${value:-}" ]] && { echo "$value"; return; }
  fi
  echo "$default"
}

# config/database.env 是本机凭据（被 .gitignore 忽略）：不存在时先从模板生成，后续步骤才能改写它
ensure_env_file() {
  [[ -f config/database.env ]] && return 0
  if [[ -f config/database.env.example ]]; then
    cp config/database.env.example config/database.env
    log "已从 config/database.env.example 生成 config/database.env"
  else
    printf 'DB_HOST=127.0.0.1\nDB_PORT=3306\nDB_USER=root\nDB_PASSWORD=\nDB_NAME=charging_screen\nDATA_SOURCE=mysql\nCACHE_TTL=30\n' \
      > config/database.env
    log "已生成默认 config/database.env"
  fi
}

DB_HOST="$(read_env_value DB_HOST 127.0.0.1)"
DB_PORT="$(read_env_value DB_PORT 3306)"
DB_USER="$(read_env_value DB_USER root)"
DB_PASSWORD="$(read_env_value DB_PASSWORD '')"
DB_NAME="$(read_env_value DB_NAME charging_screen)"

# ---------------------------------------------------------------------------
# pip 安装：镜像可能是坏的/被墙的，按顺序自动换源重试
# ---------------------------------------------------------------------------
PIP_MIRRORS=(
  "${PIP_INDEX:-}"
  "https://mirrors.aliyun.com/pypi/simple"
  "https://pypi.tuna.tsinghua.edu.cn/simple"
  "https://mirrors.cloud.tencent.com/pypi/simple"
  "https://pypi.org/simple"
)

pip_install() {
  local index
  for index in "${PIP_MIRRORS[@]}"; do
    [[ -z "$index" ]] && continue
    if "$PIP" install -i "$index" "$@"; then
      log "依赖安装成功（镜像：$index）"
      return 0
    fi
    warn "镜像 $index 安装失败，自动换下一个源重试"
  done
  return 1
}

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
    warn "数据库初始化失败：当前账号没有 MySQL 的管理权限。"
    warn "  请在项目根目录用 sudo 重新执行：  sudo bash deploy/deploy.sh"
    warn "  或先手工建库建账号：  sudo mysql  （然后执行 deploy/deploy.sh 里 init_mysql 的 SQL）"
  fi

  # Ubuntu 下 root 默认走 auth_socket（TCP 连不上），应用需要一个带密码的账号；
  # 只要能用 root 执行 SQL，就确保 charging 账号存在（幂等）
  local app_user="charging" app_pass="charging123"
  if mysql_exec "
    CREATE USER IF NOT EXISTS '$app_user'@'%' IDENTIFIED BY '$app_pass';
    CREATE USER IF NOT EXISTS '$app_user'@'localhost' IDENTIFIED BY '$app_pass';
    GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$app_user'@'%';
    GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$app_user'@'localhost';
    FLUSH PRIVILEGES;"; then
    if [[ "$DB_USER" == "root" && -z "$DB_PASSWORD" ]]; then
      log "已创建应用账号 $app_user（密码 $app_pass），并写入 config/database.env"
      sed -i -e "s/^DB_USER=.*/DB_USER=$app_user/" -e "s/^DB_PASSWORD=.*/DB_PASSWORD=$app_pass/" config/database.env
      DB_USER="$app_user"; DB_PASSWORD="$app_pass"
    else
      log "应用账号 $app_user 已确认存在（配置用户：$DB_USER）"
    fi
  else
    warn "创建应用账号失败（需要 root/sudo 的 MySQL 访问权限）。"
    warn "  解决办法：用 sudo 重新执行本脚本  ->  sudo bash deploy/deploy.sh"
  fi
}

# ---------------------------------------------------------------------------
# 3. Python 虚拟环境
# ---------------------------------------------------------------------------
setup_venv() {
  log "创建 Python 虚拟环境：$VENV_DIR"
  local py=""
  for candidate in "$PYTHON_BIN" python3.12 python3.11 python3; do
    if have "$candidate"; then py="$candidate"; break; fi
  done
  [[ -n "$py" ]] || die "未找到 python3，请先安装 Python 3.11/3.12"
  "$py" -V
  [[ -d "$VENV_DIR" ]] || "$py" -m venv "$VENV_DIR"
  pip_install --upgrade pip >/dev/null 2>&1 || warn "pip 升级失败（继续使用现有 pip）"
  log "安装 PySpark 与 Flask 依赖（约 350MB，请耐心等待）"
  pip_install -r backend/requirements.txt || die "Flask 依赖安装失败：请检查网络或手动执行 $PIP install -r backend/requirements.txt"
  if [[ "$SKIP_SPARK" == "1" ]]; then
    log "SKIP_SPARK=1：不安装 PySpark，直接使用 sql/charging_screen.sql 中的结果数据"
  else
    pip_install "pyspark==3.5.3" || die "PySpark 安装失败（数据量较大，可加 SKIP_SPARK=1 跳过）"
  fi
  # 记录 venv 位置，供 run_pipeline.sh / install_service.sh 等脚本复用
  printf '# 由 deploy.sh 生成：虚拟环境位置（共享目录场景会放到家目录）\nexport VENV_DIR=%q\n' "$VENV_DIR" > deploy/venv_path.sh
}

# ---------------------------------------------------------------------------
# 4. Spark 离线计算 + 装载 MySQL
# ---------------------------------------------------------------------------
run_pipeline() {
  if [[ "$SKIP_SPARK" == "1" ]]; then
    log "SKIP_SPARK=1：跳过 Spark 计算"
    if [[ -f sql/charging_screen.sql ]]; then
      log "从 sql/charging_screen.sql 导入结果数据（约 1MB，秒级完成）"
      load_sql_dump
    else
      warn "未找到 sql/charging_screen.sql，跳过数据装载（大屏会没有数据）"
    fi
    return
  fi
  log "执行 Spark 数据清洗与多维分析"
  export JAVA_HOME="${JAVA_HOME:-$(dirname "$(dirname "$(readlink -f "$(command -v java)")")")}"
  export PYSPARK_PYTHON="$PY"
  local raw_path="${RAW_PATH:-}"
  if [[ -z "$raw_path" ]]; then
    if [[ -d data/raw_expanded ]]; then raw_path="data/raw_expanded"; else raw_path="data/raw"; fi
  fi
  log "输入数据目录：$raw_path"
  "$PY" spark/jobs/run_all.py --raw "$raw_path"
  log "装载分析结果到 MySQL"
  "$PY" spark/jobs/load_mysql.py
}

# 直接用仓库里的 MySQL 备份还原结果数据（新机器最快的起步方式）
load_sql_dump() {
  local sql_file="$ROOT_DIR/sql/charging_screen.sql"
  if [[ ! -f "$sql_file" ]]; then
    warn "未找到 $sql_file"
    return 1
  fi
  mysql_import "$sql_file"
}

mysql_import() {
  local sql_file="$1"
  # 备份里含 CREATE DATABASE，优先用 root 导入（权限最完整），失败再退回应用账号
  if $SUDO mysql -uroot < "$sql_file" 2>/dev/null; then
    log "已通过 root 导入 $(basename "$sql_file")"
    return 0
  fi
  if mysql -uroot < "$sql_file" 2>/dev/null; then
    log "已通过 root 导入 $(basename "$sql_file")"
    return 0
  fi
  if [[ -n "$DB_PASSWORD" ]] && \
     mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASSWORD" < "$sql_file" 2>/dev/null; then
    log "已导入 $(basename "$sql_file")"
    return 0
  fi
  if mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" < "$sql_file" 2>/dev/null; then
    log "已导入 $(basename "$sql_file")"
    return 0
  fi
  warn "导入 SQL 失败：请用 sudo 重新执行本脚本（sudo bash deploy/deploy.sh），或手工执行  sudo mysql < $sql_file"
  return 1
}

# ---------------------------------------------------------------------------
# 5. 前端构建
# ---------------------------------------------------------------------------
build_frontend() {
  if ! have node; then
    if [[ -d "$ROOT_DIR/../web" ]]; then
      log "未安装 Node.js，改用仓库 ../web 中已构建的大屏产物"
      rm -rf frontend/dist && mkdir -p frontend/dist && cp -rf "$ROOT_DIR/../web/." frontend/dist/
      return
    fi
    warn "跳过前端构建（未安装 Node.js 且没有 ../web 构建产物）"
    return
  fi
  log "构建前端（Vue3 + DataV + ECharts）"
  ( cd frontend && npm install --no-fund --no-audit && npm run build ) || {
    warn "npm 构建失败，改用仓库 ../web 中已构建的大屏产物"
    rm -rf frontend/dist && mkdir -p frontend/dist && cp -rf "$ROOT_DIR/../web/." frontend/dist/
  }
  log "前端构建完成：frontend/dist"
}

# ---------------------------------------------------------------------------
# 6. 启动后端服务
# ---------------------------------------------------------------------------
start_backend() {
  log "启动 Flask 服务（gunicorn，端口 $SERVER_PORT）"
  pkill -f 'gunicorn.*backend.wsgi' >/dev/null 2>&1 || true
  PORT="$SERVER_PORT" nohup "$VENV_DIR/bin/gunicorn" -c deploy/gunicorn.conf.py backend.wsgi:application \
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
  ensure_env_file
  log "项目目录：$ROOT_DIR"
  ensure_sudo
  if [[ "$SKIP_INSTALL" != "1" ]]; then install_dependencies; fi
  start_mysql
  init_mysql
  setup_venv
  if [[ "$SKIP_SPARK" != "1" ]]; then run_pipeline; fi
  build_frontend
  if [[ "$SKIP_BACKEND" == "1" ]]; then
    log "SKIP_BACKEND=1：跳过服务启动（需要时手动执行： bash deploy/install_service.sh 或 sudo systemctl restart charging-screen）"
  else
    start_backend
  fi
  log "部署完成。浏览器访问： http://<虚拟机IP>:${SERVER_PORT}/"
  log "如需 nginx 与开机自启，请执行： bash deploy/install_service.sh"
}

main "$@"
