#!/usr/bin/env bash
# Ubuntu 虚拟机：启动后端。
# 工程入口是顶层 ChargePile.pro；编译后的程序在 build/ 目录。
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

SERVER=""
for candidate in \
    build/admin_server/admin_server \
    "$HOME/Charge_pile_bin/admin_server"
do
    if [[ -f "$candidate" ]]; then
        SERVER="$candidate"
        break
    fi
done

if [[ -z "$SERVER" ]]; then
    echo "还没有编译产物。请先在项目根目录执行："
    echo "  bash scripts/install_deps_ubuntu.sh"
    echo "  bash scripts/build.sh"
    echo
    echo "本项目是 Qt6 + qmake，工程入口是 ChargePile.pro。"
    echo "Qt Creator：文件 → 打开文件或项目 → 选择本目录的 ChargePile.pro"
    exit 1
fi

echo "=============================================="
echo " 可执行程序在编译之后才出现："
echo "   $ROOT/build/admin_server/admin_server"
echo "   $ROOT/build/admin_client/admin_client"
echo "   $ROOT/build/user_client/user_client"
echo "=============================================="
echo
echo "现在启动后端。看到「后端服务已启动」后，再开两个终端运行："
echo "  $ROOT/build/admin_client/admin_client"
echo "  $ROOT/build/user_client/user_client"
echo
echo "管理员账号：admin / 123456"
echo "用户端手机号：13800001111"
echo "首次导入 CSV 可能要 1～2 分钟，请不要关闭本窗口。"
echo "=============================================="
echo

if [[ "$SERVER" == /* ]]; then
    exec "$SERVER"
else
    exec "./$SERVER"
fi
