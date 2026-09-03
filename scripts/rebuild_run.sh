#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
export DISPLAY="${DISPLAY:-:0}"

SKIP_BUILD=0
for arg in "$@"; do
    case "$arg" in
        --skip-build|-n) SKIP_BUILD=1 ;;
        --help|-h)
            echo "用法: bash scripts/rebuild_run.sh [--skip-build]"
            echo "  重新编译并启动 admin_server、admin_client、user_client"
            echo "  Ctrl+C 会一并退出三个进程"
            exit 0
            ;;
        *)
            echo "未知参数: $arg"
            echo "用法: bash scripts/rebuild_run.sh [--skip-build]"
            exit 1
            ;;
    esac
done

if [[ "$SKIP_BUILD" -eq 0 ]]; then
    echo "======== 重新编译 ========"
    bash "$ROOT/scripts/build.sh"
    echo
else
    echo "跳过编译（--skip-build）"
fi

SERVER_SRC="$ROOT/build/admin_server/admin_server"
ADMIN_SRC="$ROOT/build/admin_client/admin_client"
USER_SRC="$ROOT/build/user_client/user_client"
for f in "$SERVER_SRC" "$ADMIN_SRC" "$USER_SRC"; do
    if [[ ! -f "$f" ]]; then
        echo "找不到 $f，请先完整编译。"
        exit 1
    fi
done

STAGE="$HOME/Charge_pile_bin"
need_stage=0
mount_opts="$(findmnt -n -o OPTIONS -T "$ROOT" 2>/dev/null || true)"
if [[ "$ROOT" == /mnt/hgfs/* || "$ROOT" == /mnt/host/* ]]; then
    need_stage=1
elif [[ "$mount_opts" == *noexec* ]]; then
    need_stage=1
fi

if [[ "$need_stage" -eq 1 ]]; then
    echo "当前目录无法直接执行二进制，拷贝到 $STAGE"
    mkdir -p "$STAGE/web" "$STAGE/database" "$STAGE/data"
    cp -f "$SERVER_SRC" "$STAGE/admin_server"
    cp -f "$ADMIN_SRC" "$STAGE/admin_client"
    cp -f "$USER_SRC" "$STAGE/user_client"
    chmod +x "$STAGE/admin_server" "$STAGE/admin_client" "$STAGE/user_client"
    cp -a "$ROOT/web/." "$STAGE/web/"
    cp -a "$ROOT/database/." "$STAGE/database/"
    if [[ -f "$ROOT/data/北京市充电桩数据.csv" ]]; then
        cp -f "$ROOT/data/北京市充电桩数据.csv" "$STAGE/data/"
    fi
    SERVER_BIN="$STAGE/admin_server"
    ADMIN_BIN="$STAGE/admin_client"
    USER_BIN="$STAGE/user_client"
    export CHARGE_PILE_WEB_ROOT="$STAGE/web"
else
    SERVER_BIN="$SERVER_SRC"
    ADMIN_BIN="$ADMIN_SRC"
    USER_BIN="$USER_SRC"
fi

echo "停止旧进程（若有）…"
pkill -x admin_server 2>/dev/null || true
pkill -x admin_client 2>/dev/null || true
pkill -x user_client 2>/dev/null || true
sleep 0.4

LOG="${TMPDIR:-/tmp}/charge_pile_server.log"
: > "$LOG"

echo "======== 启动 ========"
echo "  后端:   $SERVER_BIN"
echo "  管理端: $ADMIN_BIN"
echo "  用户端: $USER_BIN"
echo "  日志:   $LOG"
echo "  管理员  admin / 123456"
echo "  用户端  13800001111"
echo "  Web     http://127.0.0.1:8080"
echo "  Ctrl+C  结束全部"
echo

"$SERVER_BIN" >>"$LOG" 2>&1 &
SERVER_PID=$!

ready=0
for _ in $(seq 1 180); do
    if ! kill -0 "$SERVER_PID" 2>/dev/null; then
        echo "后端启动失败，日志如下："
        tail -n 40 "$LOG" || true
        exit 1
    fi
    if grep -q "后端服务已启动" "$LOG" 2>/dev/null; then
        ready=1
        break
    fi
    sleep 0.5
done
if [[ "$ready" -ne 1 ]]; then
    echo "等待后端超时。最近日志："
    tail -n 40 "$LOG" || true
    kill "$SERVER_PID" 2>/dev/null || true
    exit 1
fi
grep "后端服务已启动" "$LOG" | tail -n 1

"$ADMIN_BIN" &
ADMIN_PID=$!
"$USER_BIN" &
USER_PID=$!

cleanup() {
    echo
    echo "正在退出…"
    kill "$ADMIN_PID" "$USER_PID" "$SERVER_PID" 2>/dev/null || true
    wait "$ADMIN_PID" "$USER_PID" "$SERVER_PID" 2>/dev/null || true
}
trap cleanup INT TERM

wait "$ADMIN_PID" "$USER_PID" 2>/dev/null || true
cleanup
