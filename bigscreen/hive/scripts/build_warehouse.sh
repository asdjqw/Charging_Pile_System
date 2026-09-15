#!/usr/bin/env bash
# 完整链路：Hive LOAD ODS -> PySpark DWD -> HQL DWS -> HQL ADS -> 质量验证。
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"
HQL_DIR="$ROOT_DIR/hive/hql"
LOAD_DT="${LOAD_DT:-$(date +%F)}"
WAREHOUSE_ROOT="${WAREHOUSE_ROOT:-/warehouse/charging_pile}"
HIVE_CMD="${HIVE_CMD:-hive}"
ANALYTICS_SQL_CMD="${ANALYTICS_SQL_CMD:-$HIVE_CMD}"
SPARK_SUBMIT="${SPARK_SUBMIT:-spark-submit}"
SPARK_MASTER="${SPARK_MASTER:-yarn}"
read -r -a HIVE_CLI <<< "$HIVE_CMD"
read -r -a ANALYTICS_CLI <<< "$ANALYTICS_SQL_CMD"

# 本地默认锁定项目 Python；集群可在调用前显式设置为所有节点共有的 Python 3.11/3.12 路径。
if [[ -z "${PYSPARK_PYTHON:-}" && -x "$ROOT_DIR/.venv/bin/python" ]]; then
  export PYSPARK_PYTHON="$ROOT_DIR/.venv/bin/python"
  export PYSPARK_DRIVER_PYTHON="$ROOT_DIR/.venv/bin/python"
fi

run_hive() {
  "${HIVE_CLI[@]}" --hiveconf warehouse_root="$WAREHOUSE_ROOT" \
    --hiveconf load_dt="$LOAD_DT" -f "$1"
}

run_analytics() {
  "${ANALYTICS_CLI[@]}" --hiveconf warehouse_root="$WAREHOUSE_ROOT" \
    --hiveconf load_dt="$LOAD_DT" -f "$1"
}

echo "[1/5] Hive LOAD 采集到 ODS"
LOAD_DT="$LOAD_DT" WAREHOUSE_ROOT="$WAREHOUSE_ROOT" \
  MODE="${MODE:-local}" LOCAL_RAW="${LOCAL_RAW:-$ROOT_DIR/data/raw_expanded}" \
  HIVE_CMD="$HIVE_CMD" "$ROOT_DIR/hive/scripts/load_ods.sh"

echo "[2/5] 创建 DWD 表并执行原项目 PySpark 清洗规则"
run_hive "$HQL_DIR/03_create_dwd_tables.hql"
"$SPARK_SUBMIT" --master "$SPARK_MASTER" --deploy-mode client \
  "$ROOT_DIR/spark/jobs/hive_dwd.py" --load-date "$LOAD_DT"

echo "[3/5] 构建 DWS 公共汇总层"
run_hive "$HQL_DIR/04_create_dws_tables.hql"
run_analytics "$HQL_DIR/05_build_dws.hql"

echo "[4/5] 构建 ADS 大屏主题层"
run_hive "$HQL_DIR/06_create_ads_tables.hql"
run_analytics "$HQL_DIR/07_build_ads.hql"

echo "[5/5] 四层数量与质量验证"
run_analytics "$HQL_DIR/08_validate_warehouse.hql"
echo "[OK] Hive 四层数仓构建完成：load_dt=$LOAD_DT"
