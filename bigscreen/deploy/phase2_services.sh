#!/usr/bin/env bash
# 二期服务：HDFS/YARN + MySQL + Flask 大屏
# 用法： bash deploy/phase2_services.sh start|stop|status|restart
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"
LOG_DIR="${CHARGE_PHASE2_LOGDIR:-$HOME/charging-bigscreen-logs}"
PIDF="$LOG_DIR/flask.pid"
PORT="${SERVER_PORT:-5000}"
mkdir -p "$LOG_DIR"

if [[ -f "$ROOT_DIR/deploy/hadoop_env.sh" ]]; then
  # shellcheck disable=SC1091
  source "$ROOT_DIR/deploy/hadoop_env.sh"
fi

if [[ -z "${JAVA_HOME:-}" ]] && command -v java >/dev/null 2>&1; then
  JAVA_HOME="$(dirname "$(dirname "$(readlink -f "$(command -v java)")")")"
  export JAVA_HOME
fi

PY="${ROOT_DIR}/.venv/bin/python"
if [[ ! -x "$PY" && -x "${CHARGING_SCREEN_VENV:-}/bin/python" ]]; then
  PY="${CHARGING_SCREEN_VENV}/bin/python"
fi

log() { printf '\033[36m[%s]\033[0m %s\n' "$(date '+%H:%M:%S')" "$*"; }

start_mysql() {
  if command -v systemctl >/dev/null 2>&1; then
    sudo systemctl start mysql 2>/dev/null || sudo systemctl start mysqld 2>/dev/null || true
  fi
}

start_hadoop() {
  command -v hdfs >/dev/null 2>&1 || { log "未找到 hdfs，跳过 Hadoop"; return 0; }
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

start_flask() {
  [[ -x "$PY" ]] || { echo "找不到 Python 虚拟环境：$PY"; exit 1; }
  if [[ -f "$PIDF" ]] && kill -0 "$(cat "$PIDF")" 2>/dev/null; then
    log "Flask 已在运行 PID $(cat "$PIDF")"
    return 0
  fi
  export PORT
  export DATA_SOURCE="${DATA_SOURCE:-mysql}"
  export PYTHONUNBUFFERED=1
  nohup "$PY" "$ROOT_DIR/backend/app.py" >>"$LOG_DIR/flask.log" 2>&1 &
  echo $! > "$PIDF"
  sleep 2
  if kill -0 "$(cat "$PIDF")" 2>/dev/null; then
    log "Flask 已启动 http://127.0.0.1:${PORT}/  日志 $LOG_DIR/flask.log"
  else
    echo "Flask 启动失败，见 $LOG_DIR/flask.log"
    tail -n 40 "$LOG_DIR/flask.log" || true
    exit 1
  fi
}

stop_flask() {
  if [[ -f "$PIDF" ]]; then
    kill "$(cat "$PIDF")" 2>/dev/null || true
    rm -f "$PIDF"
  fi
  pkill -f "$ROOT_DIR/backend/app.py" 2>/dev/null || true
}

status() {
  echo "==== 二期状态 ===="
  echo -n "Java: "; java -version 2>&1 | head -1 || echo "无"
  echo -n "MySQL: "; systemctl is-active mysql 2>/dev/null || systemctl is-active mysqld 2>/dev/null || echo "未运行"
  echo -n "Hadoop 进程: "
  if command -v jps >/dev/null 2>&1; then jps 2>/dev/null | tr '\n' ' '; echo; else echo "无 jps"; fi
  echo -n "Flask: "
  if [[ -f "$PIDF" ]] && kill -0 "$(cat "$PIDF")" 2>/dev/null; then
    echo "PID $(cat "$PIDF") 端口 $PORT"
  else
    echo "未运行"
  fi
  curl -s "http://127.0.0.1:${PORT}/api/health" || echo "(接口未通)"
  echo
  if command -v hdfs >/dev/null 2>&1; then
    hdfs dfs -ls /data/charging 2>/dev/null || echo "HDFS /data/charging 暂不可用（先 start）"
  fi
}

usage() {
  echo "用法: $0 start|stop|restart|status"
}

START_HADOOP="${START_HADOOP:-1}"
SKIP_HADOOP="${SKIP_HADOOP:-0}"

cmd="${1:-status}"
case "$cmd" in
  start)
    start_mysql
    if [[ "$START_HADOOP" == "1" && "$SKIP_HADOOP" != "1" ]]; then
      start_hadoop
    fi
    start_flask
    status
    ;;
  stop) stop_flask; stop_hadoop; log "已停止 Flask 与 Hadoop（MySQL 保持运行）" ;;
  restart)
    stop_flask
    stop_hadoop
    start_mysql
    if [[ "$START_HADOOP" == "1" && "$SKIP_HADOOP" != "1" ]]; then
      start_hadoop
    fi
    start_flask
    status
    ;;
  status) status ;;
  *) usage; exit 1 ;;
esac
