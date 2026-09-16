#!/usr/bin/env bash
# 集群答辩入口：Hive LOAD ODS(TextFile) -> Spark SQL ORC 数仓 -> TXT -> MySQL。
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

[[ -f "$ROOT_DIR/deploy/hadoop_env.sh" ]] && source "$ROOT_DIR/deploy/hadoop_env.sh"
VENV_DIR="${VENV_DIR:-$ROOT_DIR/.venv}"
LOAD_DT="${LOAD_DT:-$(date +%F)}"
LOCAL_RAW="${LOCAL_RAW:-$ROOT_DIR/data/raw_expanded}"
WAREHOUSE_ROOT="${WAREHOUSE_ROOT:-/warehouse/charging_pile_orc}"
HIVE_CMD="${HIVE_CMD:-$VENV_DIR/bin/spark-sql --master yarn}"
SPARK_SQL_CMD="${SPARK_SQL_CMD:-$VENV_DIR/bin/spark-sql --master yarn}"

[[ -d "$LOCAL_RAW" ]] || { echo "[ERROR] 原始数据目录不存在：$LOCAL_RAW"; exit 1; }
command -v hdfs >/dev/null || { echo '[ERROR] 未找到 hdfs 命令'; exit 1; }

LOAD_DT="$LOAD_DT" MODE=hdfs LOCAL_RAW="$LOCAL_RAW" WAREHOUSE_ROOT="$WAREHOUSE_ROOT" \
  HIVE_CMD="$HIVE_CMD" SPARK_SQL_CMD="$SPARK_SQL_CMD" SPARK_MASTER=yarn \
  bash "$ROOT_DIR/hive/scripts/build_warehouse.sh"
echo "[OK] Spark on YARN 正式链路完成：load_dt=$LOAD_DT"
