#!/usr/bin/env bash
# Ubuntu 虚拟机：启动后端。没有 .pro / 没有现成的 Qt 启动图标。
# 工程入口是顶层 CMakeLists.txt；编译后的程序在 build/ 目录。
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [[ ! -x build/admin_server/admin_server ]]; then
    echo "还没有编译产物。请先在项目根目录执行："
    echo "  chmod +x scripts/install_deps_ubuntu.sh scripts/build.sh"
    echo "  ./scripts/install_deps_ubuntu.sh"
    echo "  ./scripts/build.sh"
    echo
    echo "本项目是 CMake + Qt6，没有 qmake 的 .pro 文件。"
    echo "Qt Creator：文件 → 打开文件或项目 → 选择本目录的 CMakeLists.txt"
    exit 1
fi

echo "=============================================="
echo " 没有 .pro 启动文件，这是正常的。"
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

exec ./build/admin_server/admin_server
