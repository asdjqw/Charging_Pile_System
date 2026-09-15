#!/usr/bin/env bash
# 重新执行离线计算链路（清洗 -> 分析 -> 装载 MySQL），用于数据更新后刷新大屏
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

export JAVA_HOME="${JAVA_HOME:-$(dirname "$(dirname "$(readlink -f "$(command -v java)")")")}"
VENV_DIR="${VENV_DIR:-}"
if [[ -z "$VENV_DIR" && -f "$ROOT_DIR/deploy/venv_path.sh" ]]; then
  # shellcheck disable=SC1091
  source "$ROOT_DIR/deploy/venv_path.sh"
fi
VENV_DIR="${VENV_DIR:-$ROOT_DIR/.venv}"
export PYSPARK_PYTHON="$VENV_DIR/bin/python"
export PYSPARK_DRIVER_PYTHON="$PYSPARK_PYTHON"

"$VENV_DIR/bin/python" spark/jobs/run_all.py --raw "${RAW_PATH:-data/raw_expanded}" "$@"
"$VENV_DIR/bin/python" spark/jobs/load_mysql.py
echo "[OK] 离线计算完成，大屏数据已刷新"
