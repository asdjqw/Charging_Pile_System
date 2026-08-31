#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build -j"$(nproc)"

# 确保运行目录能找到 database 脚本
mkdir -p build/database
cp -f database/*.sql build/database/

echo
echo "构建完成："
echo "  用户端: $ROOT/build/user_client/user_client"
echo "  管理端: $ROOT/build/admin_server/admin_server"
echo "  数据库: ~/.local/share/ChargePileLab/charge_pile.db"
