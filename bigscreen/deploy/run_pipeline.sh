#!/usr/bin/env bash
# 重新执行离线计算链路（清洗 -> 分析 -> 装载 MySQL），用于数据更新后刷新大屏
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

export JAVA_HOME="${JAVA_HOME:-$(dirname "$(dirname "$(readlink -f "$(command -v java)")")")}"
export PYSPARK_PYTHON="$ROOT_DIR/.venv/bin/python"

.venv/bin/python spark/jobs/run_all.py --raw "${RAW_PATH:-data/raw_expanded}" "$@"
.venv/bin/python spark/jobs/load_mysql.py
echo "[OK] 离线计算完成，大屏数据已刷新"
