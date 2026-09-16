#!/usr/bin/env bash
# 正式本地/单机流水线：ODS TextFile -> Spark SQL ORC 数仓 -> TXT -> MySQL。
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

LOAD_DT="${LOAD_DT:-$(date +%F)}"
echo "[INFO] 正式数仓链路，批次：$LOAD_DT"
LOAD_DT="$LOAD_DT" MODE="${MODE:-hdfs}" LOCAL_RAW="${RAW_PATH:-$ROOT_DIR/data/raw_expanded}" \
  bash "$ROOT_DIR/deploy/run_warehouse_local.sh"
