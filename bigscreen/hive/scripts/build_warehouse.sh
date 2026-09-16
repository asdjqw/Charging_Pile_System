#!/usr/bin/env bash
# 兼容旧入口：先采集 ODS，再转入正式 Spark SQL ETL。
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
LOAD_DT="${LOAD_DT:-$(date +%F)}"
WAREHOUSE_ROOT="${WAREHOUSE_ROOT:-/warehouse/charging_pile_orc}"
HIVE_CMD="${HIVE_CMD:-hive}"

echo "[ODS] Hive LOAD 原始 TextFile 分区：$LOAD_DT"
LOAD_DT="$LOAD_DT" WAREHOUSE_ROOT="$WAREHOUSE_ROOT" MODE="${MODE:-local}" \
  LOCAL_RAW="${LOCAL_RAW:-$ROOT_DIR/data/raw_expanded}" HIVE_CMD="$HIVE_CMD" \
  "$ROOT_DIR/hive/scripts/load_ods.sh"

LOAD_DT="$LOAD_DT" WAREHOUSE_ROOT="$WAREHOUSE_ROOT" \
  SPARK_MASTER="${SPARK_MASTER:-yarn}" SPARK_SQL_CMD="${SPARK_SQL_CMD:-}" \
  "$ROOT_DIR/hive/scripts/run_etl_all.sh" "$LOAD_DT"
