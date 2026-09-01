#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build -j"$(nproc)"

mkdir -p build/database build/user_client/database build/admin_server/database \
         build/user_client/data build/admin_server/data
cp -f database/*.sql build/database/
cp -f database/*.sql build/user_client/database/
cp -f database/*.sql build/admin_server/database/
cp -f "data/北京市充电桩数据.csv" build/user_client/data/
cp -f "data/北京市充电桩数据.csv" build/admin_server/data/

echo
echo "构建完成："
echo "  用户端: $ROOT/build/user_client/user_client"
echo "  管理端: $ROOT/build/admin_server/admin_server"
echo "  数据库: ~/.local/share/ChargePileLab/charge_pile.db"
echo "  启动后会自动检测真实当前位置（GeoClue / IP）"
