#!/usr/bin/env bash
# Ubuntu 22.04 / 24.04 依赖安装脚本
set -euo pipefail

sudo apt update
sudo apt install -y \
  build-essential \
  cmake \
  ninja-build \
  qt6-base-dev \
  qt6-tools-dev \
  libqt6sql6-sqlite \
  libgl1-mesa-dev \
  pkg-config

echo
echo "依赖安装完成。接下来可执行："
echo "  cd \"$(dirname "$0")/..\""
echo "  cmake -S . -B build -G Ninja"
echo "  cmake --build build -j"
echo "  ./build/admin_server/admin_server"
echo "  ./build/user_client/user_client"
