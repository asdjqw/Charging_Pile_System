#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --parallel

echo
echo "构建完成："
echo "  后端服务:     $ROOT/build/admin_server/admin_server"
echo "  管理端:       $ROOT/build/admin_client/admin_client"
echo "  用户端:       $ROOT/build/user_client/user_client"
echo "  Web 大屏:     http://127.0.0.1:8080"
echo "  数据库: ~/.local/share/ChargePileLab/charge_pile.db"
echo "请先启动后端服务，再启动用户端和管理端。"
