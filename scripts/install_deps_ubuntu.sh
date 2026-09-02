#!/usr/bin/env bash
# Ubuntu 22.04 / 24.04 依赖安装脚本
set -euo pipefail

sudo apt update
sudo apt install -y software-properties-common
sudo add-apt-repository -y universe || true
sudo apt update

# 22.04 (jammy) 包名是 libqt6charts6-dev；24.04 起才是 qt6-charts-dev
charts_pkg="libqt6charts6-dev"
if apt-cache show qt6-charts-dev >/dev/null 2>&1; then
    charts_pkg="qt6-charts-dev"
fi

sudo apt install -y \
  build-essential \
  cmake \
  ninja-build \
  qt6-base-dev \
  qt6-tools-dev \
  "$charts_pkg" \
  libqt6sql6-sqlite \
  libgl1-mesa-dev \
  pkg-config

echo
echo "依赖安装完成。接下来可执行："
echo "  cd \"$(cd "$(dirname "$0")/.." && pwd)\""
echo "  bash scripts/rebuild_run.sh         # 一键编译并启动三端"
echo "  bash scripts/build.sh"
echo "  bash scripts/run_ubuntu.sh          # 仅启动后端"
