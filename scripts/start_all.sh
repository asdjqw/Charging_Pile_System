#!/usr/bin/env bash
# ============================================================================
# 充电桩项目一键启动 / 停止 / 状态
#
# 第一次把环境装齐（15～40 分钟，可重复执行）：
#   bash /mnt/hgfs/Small_s3/Charge_pile/scripts/setup_all_ubuntu.sh
#
# 家目录的 ~/start_charge_pile.sh 不会凭空出现。第一次请先：
#   bash /mnt/hgfs/Small_s3/Charge_pile/scripts/install_start_shortcut.sh
# 或直接启动（同时会写入家目录快捷方式）：
#   bash /mnt/hgfs/Small_s3/Charge_pile/scripts/start_all.sh
#
# 以后每次登录只需：
#   bash ~/start_charge_pile.sh
#
# 子命令： start（默认） | stop | status | restart
# 选项：   --no-gui              不打开用户端/管理端窗口
#          --hadoop              同时拉起 HDFS/YARN（日常看大屏不必开）
#          --install-autostart   登录图形界面后自动拉起后台服务（不开窗口）
# ============================================================================
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LOG_DIR="${CHARGE_ALL_LOGDIR:-$HOME/charge-pile-logs}"
SCREEN="${CHARGING_SCREEN_HOME:-$HOME/charging-bigscreen}"
SCREEN_VENV="${CHARGING_SCREEN_VENV:-}"
ML_VENV="${CHARGING_ML_VENV:-$HOME/charging-ml-venv}"
STAGE="$HOME/Charge_pile_bin"
WRAPPER="$HOME/start_charge_pile.sh"
PIP_INDEX="${PIP_INDEX:-https://pypi.tuna.tsinghua.edu.cn/simple}"

mkdir -p "$LOG_DIR"

if [[ -f "$HOME/charge_phase2_env.sh" ]]; then
  # shellcheck disable=SC1091
  source "$HOME/charge_phase2_env.sh"
  SCREEN="${CHARGING_SCREEN_HOME:-$SCREEN}"
fi

START_GUI=1
START_HADOOP=0
INSTALL_AUTOSTART=0
CMD="start"
for arg in "$@"; do
  case "$arg" in
    start|stop|status|restart) CMD="$arg" ;;
    --no-gui) START_GUI=0 ;;
    --hadoop) START_HADOOP=1 ;;
    --install-autostart) INSTALL_AUTOSTART=1 ;;
    --help|-h)
      sed -n '2,18p' "$0"
      exit 0
      ;;
    *)
      echo "未知参数: $arg"
      echo "用法: $0 start|stop|status|restart [--no-gui] [--hadoop] [--install-autostart]"
      exit 1
      ;;
  esac
done

if [[ -z "${DISPLAY:-}" ]]; then
  START_GUI=0
fi

log() { printf '\033[36m[%s]\033[0m %s\n' "$(date '+%H:%M:%S')" "$*"; }
warn() { printf '\033[33m[WARN]\033[0m %s\n' "$*"; }

alive() {
  local pidf="$1"
  [[ -f "$pidf" ]] || return 1
  local pid
  pid="$(tr -d ' \n' < "$pidf" 2>/dev/null || true)"
  [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null
}

write_wrapper() {
  if [[ -f "$ROOT/scripts/install_start_shortcut.sh" ]]; then
    bash "$ROOT/scripts/install_start_shortcut.sh" >/dev/null || warn "未能写入 $WRAPPER"
  fi
}

install_autostart() {
  mkdir -p "$HOME/.config/autostart"
  cat > "$HOME/.config/autostart/charge-pile.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Charge Pile Services
Comment=Start charging-pile MySQL, bigscreen, ML API and admin_server
Exec=bash -lc '$WRAPPER --no-gui'
X-GNOME-Autostart-enabled=true
Terminal=false
EOF
  log "已写入登录自启 $HOME/.config/autostart/charge-pile.desktop"
}

find_screen_venv() {
  if [[ -n "$SCREEN_VENV" && -x "$SCREEN_VENV/bin/python" ]]; then
    return
  fi
  SCREEN_VENV=""
  if [[ -x "$SCREEN/.venv/bin/python" ]]; then
    SCREEN_VENV="$SCREEN/.venv"
  elif [[ -x "$HOME/charging-bigscreen-venv/bin/python" ]]; then
    SCREEN_VENV="$HOME/charging-bigscreen-venv"
  fi
}

ensure_ml_venv() {
  if ! command -v python3 >/dev/null 2>&1; then
    warn "没有 python3，跳过机器学习服务"
    return 1
  fi
  if [[ ! -x "$ML_VENV/bin/python" ]]; then
    log "创建机器学习虚拟环境 $ML_VENV"
    if ! python3 -m venv "$ML_VENV"; then
      warn "python3 -m venv 失败，请先执行 bash $ROOT/scripts/setup_all_ubuntu.sh"
      return 1
    fi
  fi
  if ! "$ML_VENV/bin/python" -c "import flask" 2>/dev/null; then
    log "为机器学习环境安装 Flask"
    "$ML_VENV/bin/python" -m pip install -U pip -i "$PIP_INDEX" >/dev/null
    "$ML_VENV/bin/pip" install "Flask>=3.0" -i "$PIP_INDEX"
  fi
}

ensure_screen() {
  if [[ ! -f "$SCREEN/backend/app.py" && -f "$ROOT/bigscreen/backend/app.py" ]]; then
    log "同步大屏代码到 $SCREEN"
    mkdir -p "$SCREEN"
    if command -v rsync >/dev/null 2>&1; then
      rsync -a --exclude '.venv' --exclude 'frontend/node_modules' --exclude '__pycache__' \
        "$ROOT/bigscreen/" "$SCREEN/"
    else
      cp -a "$ROOT/bigscreen/." "$SCREEN/"
    fi
    mkdir -p "$SCREEN/frontend/dist"
    if [[ -f "$ROOT/web/index.html" ]]; then
      cp -a "$ROOT/web/." "$SCREEN/frontend/dist/"
    fi
  fi
  find_screen_venv
  if [[ -z "$SCREEN_VENV" && -f "$SCREEN/backend/app.py" ]]; then
    log "创建大屏虚拟环境 $SCREEN/.venv"
    python3 -m venv "$SCREEN/.venv" || return 0
    SCREEN_VENV="$SCREEN/.venv"
    "$SCREEN_VENV/bin/python" -m pip install -U pip -i "$PIP_INDEX" >/dev/null
    "$SCREEN_VENV/bin/pip" install -r "$SCREEN/backend/requirements.txt" -i "$PIP_INDEX"
  fi
}

find_server_bin() {
  SERVER_BIN=""
  for candidate in \
      "$STAGE/admin_server" \
      "$ROOT/build/admin_server/admin_server"
  do
    if [[ -f "$candidate" ]]; then
      SERVER_BIN="$candidate"
      break
    fi
  done
}

stage_qt_if_needed() {
  find_server_bin
  [[ -n "$SERVER_BIN" ]] || return 0
  local need=0
  local mount_opts
  mount_opts="$(findmnt -n -o OPTIONS -T "$SERVER_BIN" 2>/dev/null || true)"
  if [[ "$SERVER_BIN" == /mnt/hgfs/* || "$SERVER_BIN" == /mnt/host/* || "$mount_opts" == *noexec* ]]; then
    need=1
  fi
  [[ "$need" -eq 1 ]] || return 0
  log "共享盘 noexec，复制 Qt 程序到 $STAGE"
  mkdir -p "$STAGE/web" "$STAGE/database" "$STAGE/data"
  local src_dir="$ROOT/build"
  if [[ -f "$src_dir/admin_server/admin_server" ]]; then
    cp -f "$src_dir/admin_server/admin_server" "$STAGE/admin_server"
    [[ -f "$src_dir/admin_client/admin_client" ]] && cp -f "$src_dir/admin_client/admin_client" "$STAGE/admin_client"
    [[ -f "$src_dir/user_client/user_client" ]] && cp -f "$src_dir/user_client/user_client" "$STAGE/user_client"
  else
    cp -f "$SERVER_BIN" "$STAGE/admin_server"
  fi
  chmod +x "$STAGE"/admin_server "$STAGE"/admin_client "$STAGE"/user_client 2>/dev/null || true
  [[ -d "$ROOT/web" ]] && cp -a "$ROOT/web/." "$STAGE/web/"
  [[ -d "$ROOT/database" ]] && cp -a "$ROOT/database/." "$STAGE/database/"
  if [[ -f "$ROOT/data/北京市充电桩数据.csv" ]]; then
    cp -f "$ROOT/data/北京市充电桩数据.csv" "$STAGE/data/"
  fi
  SERVER_BIN="$STAGE/admin_server"
  export CHARGE_PILE_WEB_ROOT="$STAGE/web"
}

start_mysql() {
  if command -v systemctl >/dev/null 2>&1; then
    sudo -n systemctl start mysql 2>/dev/null \
      || sudo systemctl start mysql 2>/dev/null \
      || sudo -n systemctl start mysqld 2>/dev/null \
      || true
  fi
}

start_hadoop() {
  [[ "$START_HADOOP" == "1" ]] || return 0
  if [[ -f "$SCREEN/deploy/hadoop_env.sh" ]]; then
    # shellcheck disable=SC1091
    source "$SCREEN/deploy/hadoop_env.sh"
  fi
  command -v hdfs >/dev/null 2>&1 || { warn "未找到 hdfs，跳过 Hadoop。需要时先 bash $ROOT/scripts/setup_phase2_ubuntu.sh"; return 0; }
  log "启动 Hadoop（HDFS + YARN）"
  hdfs --daemon start namenode 2>/dev/null || true
  hdfs --daemon start datanode 2>/dev/null || true
  yarn --daemon start resourcemanager 2>/dev/null || true
  yarn --daemon start nodemanager 2>/dev/null || true
}

stop_hadoop() {
  command -v hdfs >/dev/null 2>&1 || return 0
  yarn --daemon stop nodemanager 2>/dev/null || true
  yarn --daemon stop resourcemanager 2>/dev/null || true
  hdfs --daemon stop datanode 2>/dev/null || true
  hdfs --daemon stop namenode 2>/dev/null || true
}

start_bigscreen() {
  find_screen_venv
  if [[ ! -f "$SCREEN/backend/app.py" || ! -x "${SCREEN_VENV:-}/bin/python" ]]; then
    warn "大屏未安装，跳过 :5000。请先执行 bash $ROOT/scripts/setup_all_ubuntu.sh"
    return 0
  fi
  local pidf="$HOME/charging-bigscreen-logs/flask.pid"
  mkdir -p "$HOME/charging-bigscreen-logs"
  if alive "$pidf"; then
    log "大屏已在运行 http://127.0.0.1:5000/"
    return 0
  fi
  if [[ -f "$SCREEN/config/database.env" ]]; then
    set -a
    # shellcheck disable=SC1091
    source "$SCREEN/config/database.env"
    set +a
  fi
  export DATA_SOURCE="${DATA_SOURCE:-mysql}"
  export PORT="${SERVER_PORT:-5000}"
  export PYTHONUNBUFFERED=1
  log "启动分析大屏 :${PORT}"
  nohup "$SCREEN_VENV/bin/python" "$SCREEN/backend/app.py" >>"$HOME/charging-bigscreen-logs/flask.log" 2>&1 &
  echo $! > "$pidf"
  local i
  for i in 1 2 3 4 5 6 7 8 9 10; do
    if curl -sf "http://127.0.0.1:${PORT}/api/health" >/dev/null 2>&1; then
      log "大屏 http://127.0.0.1:${PORT}/"
      return 0
    fi
    sleep 1
  done
  warn "大屏接口尚未就绪，见 $HOME/charging-bigscreen-logs/flask.log"
}

stop_bigscreen() {
  local pidf="$HOME/charging-bigscreen-logs/flask.pid"
  if [[ -f "$pidf" ]]; then
    kill "$(cat "$pidf")" 2>/dev/null || true
    rm -f "$pidf"
  fi
  pkill -f "$SCREEN/backend/app.py" 2>/dev/null || true
}

start_ml() {
  ensure_ml_venv || return 0
  local pidf="$LOG_DIR/ml.pid"
  if alive "$pidf"; then
    log "机器学习查询服务已在运行 :5010"
    return 0
  fi
  local results="$ROOT/ml/fixtures"
  local ads="$ROOT/ml/data/warehouse/ads"
  if [[ -d "$ads" ]] && ls "$ads"/*.json >/dev/null 2>&1; then
    results="$ads"
  fi
  log "启动机器学习查询服务 :5010  （数据 $results）"
  (
    cd "$ROOT"
    export PYTHONUNBUFFERED=1
    nohup "$ML_VENV/bin/python" -m ml.cli.warehouse_api \
      --store file --results-dir "$results" --source-kind SIMULATED --port 5010 \
      >>"$LOG_DIR/ml.log" 2>&1 &
    echo $! > "$pidf"
  )
  local i
  for i in 1 2 3 4 5 6 7 8 9 10; do
    if curl -sf "http://127.0.0.1:5010/api/forecast/latest" >/dev/null 2>&1; then
      log "ML http://127.0.0.1:5010/api/forecast/latest"
      return 0
    fi
    sleep 1
  done
  warn "ML 接口尚未就绪，见 $LOG_DIR/ml.log"
}

stop_ml() {
  local pidf="$LOG_DIR/ml.pid"
  if [[ -f "$pidf" ]]; then
    kill "$(cat "$pidf")" 2>/dev/null || true
    rm -f "$pidf"
  fi
  pkill -f "ml.cli.warehouse_api" 2>/dev/null || true
}

start_admin_server() {
  stage_qt_if_needed
  find_server_bin
  if [[ -z "$SERVER_BIN" ]]; then
    warn "未找到 admin_server。请用 Qt Creator 编译一期工程，或 bash $ROOT/scripts/build.sh"
    return 0
  fi
  if pgrep -x admin_server >/dev/null 2>&1; then
    log "admin_server 已在运行"
    return 0
  fi
  export CHARGE_PILE_ML_URL="${CHARGE_PILE_ML_URL:-http://127.0.0.1:5010}"
  export CHARGE_PILE_PORT="${CHARGE_PILE_PORT:-9000}"
  export CHARGE_PILE_HTTP_PORT="${CHARGE_PILE_HTTP_PORT:-8080}"
  log "启动一期后端 $SERVER_BIN"
  : > "$LOG_DIR/admin_server.log"
  nohup "$SERVER_BIN" >>"$LOG_DIR/admin_server.log" 2>&1 &
  echo $! > "$LOG_DIR/admin_server.pid"
  local i
  for i in {1..40}; do
    if grep -q "后端服务已启动" "$LOG_DIR/admin_server.log" 2>/dev/null; then
      grep "后端服务已启动" "$LOG_DIR/admin_server.log" | tail -n 1
      return 0
    fi
    if ! kill -0 "$(cat "$LOG_DIR/admin_server.pid")" 2>/dev/null; then
      warn "admin_server 已退出，见 $LOG_DIR/admin_server.log"
      tail -n 20 "$LOG_DIR/admin_server.log" || true
      return 0
    fi
    sleep 0.5
  done
  warn "后端尚未打印就绪日志，见 $LOG_DIR/admin_server.log"
}

stop_admin_server() {
  if [[ -f "$LOG_DIR/admin_server.pid" ]]; then
    kill "$(cat "$LOG_DIR/admin_server.pid")" 2>/dev/null || true
    rm -f "$LOG_DIR/admin_server.pid"
  fi
  pkill -x admin_server 2>/dev/null || true
}

start_gui() {
  [[ "$START_GUI" == "1" ]] || return 0
  local admin_bin="" user_bin=""
  for candidate in "$STAGE/admin_client" "$ROOT/build/admin_client/admin_client"; do
    [[ -f "$candidate" ]] && admin_bin="$candidate" && break
  done
  for candidate in "$STAGE/user_client" "$ROOT/build/user_client/user_client"; do
    [[ -f "$candidate" ]] && user_bin="$candidate" && break
  done
  if [[ -n "$admin_bin" ]] && ! pgrep -x admin_client >/dev/null 2>&1; then
    log "启动管理端"
    nohup "$admin_bin" >>"$LOG_DIR/admin_client.log" 2>&1 &
  fi
  if [[ -n "$user_bin" ]] && ! pgrep -x user_client >/dev/null 2>&1; then
    log "启动用户端"
    nohup "$user_bin" >>"$LOG_DIR/user_client.log" 2>&1 &
  fi
  if [[ -z "$admin_bin" && -z "$user_bin" ]]; then
    warn "未找到编译好的客户端，请用 Qt Creator 打开 user_client / admin_client"
  fi
}

stop_gui() {
  pkill -x admin_client 2>/dev/null || true
  pkill -x user_client 2>/dev/null || true
}

status() {
  echo "======== 充电桩运行状态 ========"
  echo -n "MySQL: "
  systemctl is-active mysql 2>/dev/null || systemctl is-active mysqld 2>/dev/null || echo "未运行"
  echo -n "大屏 :5000: "
  if curl -sf http://127.0.0.1:5000/api/health >/dev/null 2>&1; then echo "ok"; else echo "未通"; fi
  echo -n "ML   :5010: "
  if curl -sf http://127.0.0.1:5010/api/forecast/latest >/dev/null 2>&1; then echo "ok"; else echo "未通"; fi
  echo -n "后端 TCP: "
  if pgrep -x admin_server >/dev/null 2>&1; then echo "admin_server 运行中"; else echo "未运行"; fi
  echo -n "管理端: "
  if pgrep -x admin_client >/dev/null 2>&1; then echo "运行中"; else echo "未运行"; fi
  echo -n "用户端: "
  if pgrep -x user_client >/dev/null 2>&1; then echo "运行中"; else echo "未运行"; fi
  echo
  echo "分析大屏  http://127.0.0.1:5000/"
  echo "一期 Web  http://127.0.0.1:8080/"
  echo "ML 接口   http://127.0.0.1:5010/api/forecast/latest"
  echo "日志目录  $LOG_DIR"
  echo "停止      bash $WRAPPER stop"
}

do_start() {
  write_wrapper
  log "工程目录 $ROOT"
  ensure_screen
  start_mysql
  start_hadoop
  start_bigscreen
  start_ml
  start_admin_server
  start_gui
  if [[ "$INSTALL_AUTOSTART" == "1" ]]; then
    install_autostart
  fi
  echo
  status
}

do_stop() {
  stop_gui
  stop_admin_server
  stop_ml
  stop_bigscreen
  stop_hadoop
  log "已停止（MySQL 保持运行）"
}

case "$CMD" in
  start) do_start ;;
  stop) do_stop ;;
  restart) do_stop; sleep 1; do_start ;;
  status) write_wrapper; status ;;
  *) echo "用法: $0 start|stop|status|restart [--no-gui] [--hadoop] [--install-autostart]"; exit 1 ;;
esac
