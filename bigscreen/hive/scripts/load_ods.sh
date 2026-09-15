#!/usr/bin/env bash
# Hive LOAD 封装：MODE=local（默认）或 MODE=hdfs。
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"
HQL_DIR="$ROOT_DIR/hive/hql"
LOAD_DT="${LOAD_DT:-$(date +%F)}"
MODE="${MODE:-local}"
LOCAL_RAW="${LOCAL_RAW:-$ROOT_DIR/data/raw_expanded}"
WAREHOUSE_ROOT="${WAREHOUSE_ROOT:-/warehouse/charging_pile}"
STAGING_ROOT="${STAGING_ROOT:-/tmp/charging_pile_staging}"
HIVE_CMD="${HIVE_CMD:-hive}"
read -r -a HIVE_CLI <<< "$HIVE_CMD"
if [[ -z "${PYSPARK_PYTHON:-}" && -x "$ROOT_DIR/.venv/bin/python" ]]; then
  export PYSPARK_PYTHON="$ROOT_DIR/.venv/bin/python"
  export PYSPARK_DRIVER_PYTHON="$ROOT_DIR/.venv/bin/python"
fi

[[ "$LOAD_DT" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || { echo "[ERROR] LOAD_DT 必须为 yyyy-MM-dd"; exit 2; }
for name in nvv2t.csv dsv13r2.csv nvv2t_md_end.csv; do
  [[ -f "$LOCAL_RAW/$name" ]] || { echo "[ERROR] 缺少 $LOCAL_RAW/$name"; exit 2; }
done

# Hive 与 Spark SQL 对 skip.header.line.count 的兼容性不同。统一在临时副本移除表头，
# 原始 CSV 不变，且不会把标题行误计为 ODS 数据。
LOAD_STAGE="$(mktemp -d /tmp/charging-ods-load.XXXXXX)"
trap 'rm -rf -- "$LOAD_STAGE"' EXIT
for name in nvv2t.csv dsv13r2.csv nvv2t_md_end.csv; do
  tail -n +2 "$LOCAL_RAW/$name" > "$LOAD_STAGE/$name"
done

run_hive() {
  "${HIVE_CLI[@]}" --hiveconf warehouse_root="$WAREHOUSE_ROOT" \
    --hiveconf load_dt="$LOAD_DT" --hiveconf local_raw="$LOAD_STAGE" \
    --hiveconf staging_root="$STAGING_ROOT" -f "$1"
}

echo "[1/3] 创建四层数据库与 ODS 外部表"
run_hive "$HQL_DIR/00_create_databases.hql"
run_hive "$HQL_DIR/01_create_ods_tables.hql"

if [[ "$MODE" == "local" ]]; then
  echo "[2/3] LOAD DATA LOCAL -> ODS dt=$LOAD_DT"
  run_hive "$HQL_DIR/02_load_ods_local.hql"
elif [[ "$MODE" == "hdfs" ]]; then
  echo "[2/3] 上传 staging 后 LOAD DATA INPATH -> ODS dt=$LOAD_DT"
  hdfs dfs -mkdir -p "$STAGING_ROOT/$LOAD_DT"
  hdfs dfs -put -f "$LOAD_STAGE/nvv2t.csv" "$LOAD_STAGE/dsv13r2.csv" \
    "$LOAD_STAGE/nvv2t_md_end.csv" "$STAGING_ROOT/$LOAD_DT/"
  run_hive "$HQL_DIR/02_load_ods_hdfs.hql"
else
  echo "[ERROR] MODE 只允许 local 或 hdfs"; exit 2
fi

echo "[3/3] 验证 ODS 分区"
"${HIVE_CLI[@]}" --hiveconf load_dt="$LOAD_DT" -e \
  "SELECT 'order',count(*) FROM charging_ods.ods_charging_session WHERE dt='${LOAD_DT}' UNION ALL SELECT 'battery',count(*) FROM charging_ods.ods_battery_telemetry WHERE dt='${LOAD_DT}' UNION ALL SELECT 'station',count(*) FROM charging_ods.ods_station WHERE dt='${LOAD_DT}';"
echo "[OK] ODS 装载完成：dt=$LOAD_DT"
