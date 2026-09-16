#!/usr/bin/env bash
# ADS ORC -> HDFS 临时导出目录 -> 当前虚拟机项目目录下的管道符 TXT。
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
LOAD_DT="${1:-${LOAD_DT:-$(date +%F)}}"
HDFS_EXPORT_ROOT="${HDFS_EXPORT_ROOT:-/tmp/charging_pile_mysql_export}"
LOCAL_STAGE_DIR="${LOCAL_MYSQL_STAGE_DIR:-$ROOT_DIR/output/mysql_stage/$LOAD_DT}"
SPARK_SUBMIT="${SPARK_SUBMIT:-$ROOT_DIR/.venv/bin/spark-submit}"
SPARK_MASTER="${SPARK_MASTER:-yarn}"

[[ -x "$SPARK_SUBMIT" ]] || SPARK_SUBMIT="spark-submit"
command -v hdfs >/dev/null || { echo '[ERROR] 未找到 hdfs 命令'; exit 1; }
mkdir -p "$LOCAL_STAGE_DIR"

"$SPARK_SUBMIT" --master "$SPARK_MASTER" --deploy-mode client \
  "$ROOT_DIR/spark/jobs/export_ads_pipe_text.py" \
  --load-date "$LOAD_DT" --hdfs-export-root "$HDFS_EXPORT_ROOT"

tables=(
  ads_overview ads_daily_trend ads_monthly_trend ads_hour_load ads_weekday_hour_heat
  ads_station_top ads_facility_compare ads_weekend_compare ads_time_period_compare
  ads_platform_compare ads_district_compare ads_duration_dist ads_energy_dist
  ads_user_segment ads_battery_health ads_revenue_struct ads_realtime_sessions
  ads_data_quality ads_pipeline_info
)
for table in "${tables[@]}"; do
  src="$HDFS_EXPORT_ROOT/$LOAD_DT/$table"
  dst="$LOCAL_STAGE_DIR/$table.txt"
  hdfs dfs -test -d "$src" || { echo "[ERROR] HDFS 导出目录不存在：$src"; exit 1; }
  rm -f "$dst"
  hdfs dfs -getmerge "$src" "$dst"
  [[ -s "$dst" ]] || { echo "[ERROR] 导出文本为空：$dst"; exit 1; }
  echo "[OK] $table -> $dst"
done

printf '%s\n' "$LOAD_DT" > "$LOCAL_STAGE_DIR/.load_dt"
echo "[OK] ADS 本地 TXT 导出完成：$LOCAL_STAGE_DIR"
