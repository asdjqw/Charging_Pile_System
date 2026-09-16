#!/usr/bin/env bash
# 正式 ETL：仅执行 DWD -> DWS -> ADS -> ORC 导出 TXT -> MySQL。
# ODS 采集由 load_ods.sh 独立负责，避免采集与数仓计算的失败边界混淆。
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
HQL_DIR="$ROOT_DIR/hive/hql"
LOAD_DT="${1:-${LOAD_DT:-$(date +%F)}}"
WAREHOUSE_ROOT="${WAREHOUSE_ROOT:-/warehouse/charging_pile_orc}"
SPARK_MASTER="${SPARK_MASTER:-yarn}"
LOG_DIR="${ETL_LOG_DIR:-$ROOT_DIR/logs/etl/$LOAD_DT}"
mkdir -p "$LOG_DIR"

if [[ -z "${SPARK_SQL_CMD:-}" ]]; then
  if [[ -x "$ROOT_DIR/.venv/bin/spark-sql" ]]; then
    SPARK_SQL_CMD="$ROOT_DIR/.venv/bin/spark-sql --master $SPARK_MASTER"
  else
    SPARK_SQL_CMD="spark-sql --master $SPARK_MASTER"
  fi
fi
read -r -a SPARK_SQL_CLI <<< "$SPARK_SQL_CMD"

if [[ -z "${PYSPARK_PYTHON:-}" && -x "$ROOT_DIR/.venv/bin/python" ]]; then
  export PYSPARK_PYTHON="$ROOT_DIR/.venv/bin/python"
  export PYSPARK_DRIVER_PYTHON="$ROOT_DIR/.venv/bin/python"
fi

run_spark_sql() {
  "${SPARK_SQL_CLI[@]}" --hiveconf warehouse_root="$WAREHOUSE_ROOT" \
    --hiveconf load_dt="$LOAD_DT" -f "$1"
}

run_stage() {
  local stage="$1"
  shift
  local log_file="$LOG_DIR/${stage}.log"
  echo "[$(date '+%F %T')] [START] $stage" | tee -a "$LOG_DIR/run_etl_all.log"
  "$@" 2>&1 | tee "$log_file"
  echo "[$(date '+%F %T')] [OK] $stage" | tee -a "$LOG_DIR/run_etl_all.log"
}

failed_stage=""
trap 'status=$?; echo "[$(date "+%F %T")] [FAILED] ${failed_stage:-unknown}, exit=$status" | tee -a "$LOG_DIR/run_etl_all.log"; exit "$status"' ERR

failed_stage="dwd"
run_stage dwd_create run_spark_sql "$HQL_DIR/03_create_dwd_tables.hql"
run_stage dwd_build run_spark_sql "$HQL_DIR/03_build_dwd.sql"

failed_stage="dws"
run_stage dws_create run_spark_sql "$HQL_DIR/04_create_dws_tables.hql"
run_stage dws_build run_spark_sql "$HQL_DIR/05_build_dws.hql"

failed_stage="ads"
run_stage ads_create run_spark_sql "$HQL_DIR/06_create_ads_tables.hql"
run_stage ads_build run_spark_sql "$HQL_DIR/07_build_ads.hql"
run_stage validate run_spark_sql "$HQL_DIR/08_validate_warehouse.hql"

failed_stage="export_ads"
run_stage export_ads "$ROOT_DIR/hive/scripts/export_ads_to_local_text.sh" "$LOAD_DT"

failed_stage="import_mysql"
if [[ "${MYSQL_RESET_SCHEMA:-0}" == "1" ]]; then
  reset_python="${PYTHON_BIN:-$ROOT_DIR/.venv/bin/python}"
  [[ -x "$reset_python" ]] || reset_python="python3"
  run_stage mysql_schema env CONFIRM_RESET_ADS_SCHEMA=YES "$reset_python" "$ROOT_DIR/mysql/scripts/reset_ads_schema.py"
fi
run_stage import_mysql "$ROOT_DIR/mysql/scripts/import_ads_pipe_text.sh" "$LOAD_DT"

echo "[OK] ETL 全部完成：load_dt=$LOAD_DT；日志：$LOG_DIR"
