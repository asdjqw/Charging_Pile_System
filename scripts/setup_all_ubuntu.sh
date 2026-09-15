#!/usr/bin/env bash
# 第一次把二期环境 + 机器学习查询环境装齐（可重复执行）。
# 装完以后每天只需： bash ~/start_charge_pile.sh
set -euo pipefail

if [[ "$(id -u)" -eq 0 ]]; then
  echo "请用普通用户执行，不要 sudo bash 整份脚本。"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PIP_INDEX="${PIP_INDEX:-https://pypi.tuna.tsinghua.edu.cn/simple}"

echo "======== 1/2 安装大屏 / MySQL / Java / Hadoop ========"
SKIP_FLASK=1 bash "$ROOT/scripts/setup_phase2_ubuntu.sh"

echo
echo "======== 2/2 安装机器学习查询环境并拉起全套服务 ========"
python3 -m venv "$HOME/charging-ml-venv"
"$HOME/charging-ml-venv/bin/python" -m pip install -U pip -i "$PIP_INDEX" >/dev/null
"$HOME/charging-ml-venv/bin/pip" install "Flask>=3.0" -i "$PIP_INDEX"

bash "$ROOT/scripts/start_all.sh" start --install-autostart "$@"

echo
echo "======== 全部就绪 ========"
echo "以后每次登录只需："
echo "  bash ~/start_charge_pile.sh"
echo "只起后台、不弹窗口："
echo "  bash ~/start_charge_pile.sh --no-gui"
echo "需要 HDFS/YARN 时："
echo "  bash ~/start_charge_pile.sh --hadoop"
echo "停止："
echo "  bash ~/start_charge_pile.sh stop"
echo
echo "已写入图形登录自启（只拉后台，不打开客户端窗口）。"
echo "Qt Creator 仍可单独打开客户端；若还没编译一期程序，编译一次后一键脚本会带上后端。"
