#!/usr/bin/env bash
# 在 Ubuntu 虚拟机上配置并启动二期 Vue 分析大屏（Flask :5000）。
# 共享文件夹常为 noexec：依赖与 venv 安装到 $HOME，不写进 hgfs。
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCREEN_SRC=""
for candidate in \
    "$ROOT/charging-bigscreen-export/charging-bigscreen-export" \
    "$ROOT/charging-bigscreen-export"
do
    if [[ -f "$candidate/backend/app.py" ]]; then
        SCREEN_SRC="$candidate"
        break
    fi
done
[[ -n "$SCREEN_SRC" ]] || { echo "找不到 charging-bigscreen-export/backend/app.py"; exit 1; }

RUNTIME="${CHARGING_SCREEN_HOME:-$HOME/charging-bigscreen}"
VENV="${CHARGING_SCREEN_VENV:-$HOME/charging-bigscreen-venv}"
PORT="${SERVER_PORT:-5000}"
FROM_SQLITE="${FROM_SQLITE:-0}"
SKIP_APT="${SKIP_APT:-0}"

log() { printf '\033[36m[%s]\033[0m %s\n' "$(date '+%H:%M:%S')" "$*"; }

need_copy=0
mount_opts="$(findmnt -n -o OPTIONS -T "$SCREEN_SRC" 2>/dev/null || true)"
if [[ "$SCREEN_SRC" == /mnt/hgfs/* || "$SCREEN_SRC" == /mnt/host/* || "$SCREEN_SRC" == /media/sf_* ]]; then
    need_copy=1
elif [[ "$mount_opts" == *noexec* ]]; then
    need_copy=1
fi

if [[ "$need_copy" -eq 1 ]]; then
    log "共享盘可能 noexec，同步代码到 $RUNTIME"
    mkdir -p "$RUNTIME"
    rsync -a --delete \
        --exclude '.venv' --exclude 'frontend/node_modules' --exclude '__pycache__' \
        "$SCREEN_SRC/" "$RUNTIME/"
    SCREEN="$RUNTIME"
else
    SCREEN="$SCREEN_SRC"
fi

if [[ "$SKIP_APT" != "1" ]]; then
    if command -v apt-get >/dev/null 2>&1; then
        log "安装 Python / Java（无 MySQL 也可 CSV 兜底）"
        export DEBIAN_FRONTEND=noninteractive
        sudo apt-get update -y
        sudo apt-get install -y python3 python3-venv python3-pip rsync curl \
            openjdk-11-jdk-headless || sudo apt-get install -y python3 python3-venv python3-pip rsync
    else
        log "非 apt 系统，跳过软件包安装"
    fi
fi

command -v python3 >/dev/null || { echo "需要 python3"; exit 1; }

if [[ ! -x "$VENV/bin/python" ]]; then
    log "创建虚拟环境 $VENV"
    python3 -m venv "$VENV"
fi
# shellcheck disable=SC1091
source "$VENV/bin/activate"
pip install -U pip -q
log "安装 Flask 依赖"
pip install -r "$SCREEN/backend/requirements.txt"

if [[ "$FROM_SQLITE" == "1" ]]; then
    log "从一期 SQLite 导出订单/电站 CSV"
    python3 "$ROOT/scripts/export_sqlite_to_bigscreen.py" \
        --out "$SCREEN/data/raw" --force || log "SQLite 导出失败，继续使用大屏自带 raw CSV"
fi

export DATA_SOURCE="${DATA_SOURCE:-csv}"
export ADS_DIR="$SCREEN/output/ads"
export PORT
cd "$SCREEN"
mkdir -p "$HOME/charging-bigscreen-logs"
LOG="$HOME/charging-bigscreen-logs/flask.log"
PIDF="$HOME/charging-bigscreen-logs/flask.pid"

if [[ -f "$PIDF" ]] && kill -0 "$(cat "$PIDF")" 2>/dev/null; then
    log "已有大屏进程 PID $(cat "$PIDF")，先停止"
    kill "$(cat "$PIDF")" 2>/dev/null || true
    sleep 1
fi

log "启动 Flask 大屏 0.0.0.0:$PORT （DATA_SOURCE=$DATA_SOURCE）"
nohup "$VENV/bin/python" "$SCREEN/backend/app.py" >>"$LOG" 2>&1 &
echo $! > "$PIDF"
sleep 1
if kill -0 "$(cat "$PIDF")" 2>/dev/null; then
    log "大屏已启动： http://127.0.0.1:$PORT/  以及 http://<虚机IP>:$PORT/"
    log "健康检查： curl -s http://127.0.0.1:$PORT/api/health"
    log "日志： $LOG"
    log "停止： kill \$(cat $PIDF)"
else
    echo "启动失败，日志："
    tail -n 40 "$LOG" || true
    exit 1
fi
