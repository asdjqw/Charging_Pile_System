#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

QMAKE=""
if command -v qmake6 >/dev/null 2>&1; then
    QMAKE=qmake6
elif command -v qmake >/dev/null 2>&1; then
    QMAKE=qmake
else
    echo "未找到 qmake6。请先执行：bash scripts/install_deps_ubuntu.sh"
    exit 1
fi

QT_VER="$("$QMAKE" -query QT_VERSION)"
case "$QT_VER" in
    6.*) ;;
    *)
        echo "需要 Qt6（当前 $QMAKE 是 Qt $QT_VER），请使用 qmake6"
        exit 1
        ;;
esac

if [[ -f build/CMakeCache.txt ]]; then
    echo "检测到旧的 CMake 构建目录，正在清理 build/"
    rm -rf build
fi

mkdir -p build
cd build
"$QMAKE" "$ROOT/ChargePile.pro" CONFIG+=release
make -j"$(nproc 2>/dev/null || echo 4)"

echo
echo "构建完成："
echo "  后端服务:     $ROOT/build/admin_server/admin_server"
echo "  管理端:       $ROOT/build/admin_client/admin_client"
echo "  用户端:       $ROOT/build/user_client/user_client"
echo "  Web 大屏:     http://127.0.0.1:8080"
echo "  数据库: ~/.local/share/ChargePileLab/charge_pile.db"
echo "请先启动后端服务，再启动用户端和管理端。"
