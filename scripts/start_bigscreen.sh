#!/usr/bin/env bash
# 仅启动已配置好的分析大屏
# 推荐先跑： bash scripts/setup_phase2_ubuntu.sh
set -euo pipefail
export PORT="${SERVER_PORT:-5000}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCREEN="${CHARGING_SCREEN_HOME:-}"
VENV="${CHARGING_SCREEN_VENV:-}"

if [[ -z "$SCREEN" ]]; then
    if [[ -f "$HOME/charging-bigscreen/backend/app.py" ]]; then
        SCREEN="$HOME/charging-bigscreen"
    elif [[ -f "$HOME/cps/bigscreen/backend/app.py" ]]; then
        SCREEN="$HOME/cps/bigscreen"
    elif [[ -f "$ROOT/bigscreen/backend/app.py" ]]; then
        SCREEN="$ROOT/bigscreen"
    fi
fi
if [[ -z "$VENV" ]]; then
    if [[ -x "$SCREEN/.venv/bin/python" ]]; then
        VENV="$SCREEN/.venv"
    else
        VENV="$HOME/charging-bigscreen-venv"
    fi
fi
export DATA_SOURCE="${DATA_SOURCE:-mysql}"
[[ -x "$VENV/bin/python" ]] || { echo "请先执行 bash scripts/setup_phase2_ubuntu.sh"; exit 1; }
[[ -f "$SCREEN/backend/app.py" ]] || { echo "找不到 backend/app.py"; exit 1; }

if [[ -f "$SCREEN/deploy/phase2_services.sh" ]]; then
    SERVER_PORT="$PORT" bash "$SCREEN/deploy/phase2_services.sh" start
    exit 0
fi

mkdir -p "$HOME/charging-bigscreen-logs"
LOG="$HOME/charging-bigscreen-logs/flask.log"
PIDF="$HOME/charging-bigscreen-logs/flask.pid"
if [[ -f "$PIDF" ]] && kill -0 "$(cat "$PIDF")" 2>/dev/null; then
    echo "已在运行 PID $(cat "$PIDF")  http://127.0.0.1:$PORT/"
    exit 0
fi
cd "$SCREEN"
nohup "$VENV/bin/python" "$SCREEN/backend/app.py" >>"$LOG" 2>&1 &
echo $! > "$PIDF"
sleep 1
echo "大屏 http://127.0.0.1:$PORT/  日志 $LOG"
