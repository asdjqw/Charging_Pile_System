# 正式 Spark SQL ORC ETL 与大屏接口

## 固定链路

```text
CSV → ODS(TextFile) → Spark SQL DWD(ORC+Snappy) → Spark SQL DWS(ORC+Snappy)
    → Spark SQL ADS(ORC+Snappy) → HDFS 管道符文本 → 项目内 output/mysql_stage/*.txt
    → MySQL(TRUNCATE + LOAD DATA LOCAL INFILE) → Flask → Vue/DataV
```

ODS 是原始贴源层，使用 Hive `LOAD DATA`；DWD、DWS、ADS 的计算均由 `spark-sql` 直接执行，不启用 Hive on Spark。

## 执行方式

先完成 ODS 采集：

```bash
cd bigscreen
LOAD_DT=2026-09-16 MODE=hdfs bash hive/scripts/load_ods.sh
```

首次从旧 CSV 链路迁移到正式 MySQL Schema 时，显式允许一次性重置同名 ADS 表：

```bash
MYSQL_RESET_SCHEMA=1 bash run_etl_all.sh 2026-09-16
```

后续批次不重建 MySQL 表，只清空并导入：

```bash
bash run_etl_all.sh 2026-09-16
```

日志写入 `logs/etl/<load_dt>/`。脚本采用 `set -euo pipefail`，任一阶段失败后立即停止。

## ORC 与本地 TXT

`export_ads_to_local_text.sh` 先由 Spark 读取 ADS ORC 分区，写入 HDFS 临时目录，再由 MySQL 所在虚拟机执行 `hdfs dfs -getmerge`，合并到：

```text
output/mysql_stage/<load_dt>/ads_<name>.txt
```

文本无表头、UTF-8、字段分隔符为 `|`、空值为 `\N`。`output/` 已被 Git 忽略，因此中间 TXT 不会提交。

导入前会检查 19 个 TXT 均存在且非空、字段数与 MySQL 表一致；检查不通过时不会执行 `TRUNCATE`。

## 图表接口契约

每个图表只请求一个接口，接口只读取一张同名 MySQL 表：

| 图表 | ADS / MySQL 表 | 接口 |
|---|---|---|
| 月度趋势 | `ads_monthly_trend` | `/api/charts/monthly-trend` |
| 日趋势 | `ads_daily_trend` | `/api/charts/daily-trend` |
| 小时负荷 | `ads_hour_load` | `/api/charts/hour-load` |
| 星期×小时热力图 | `ads_weekday_hour_heat` | `/api/charts/weekday-hour-heat` |
| 站点 TOP10 | `ads_station_top` | `/api/charts/station-top` |
| 场站类型对比 | `ads_facility_compare` | `/api/charts/facility-compare` |
| 工作日/周末对比 | `ads_weekend_compare` | `/api/charts/weekend-compare` |
| 峰平谷对比 | `ads_time_period_compare` | `/api/charts/time-period-compare` |
| 平台对比 | `ads_platform_compare` | `/api/charts/platform-compare` |
| 行政区对比 | `ads_district_compare` | `/api/charts/district-compare` |
| 充电时长分布 | `ads_duration_dist` | `/api/charts/duration-dist` |
| 单次电量分布 | `ads_energy_dist` | `/api/charts/energy-dist` |
| 用户价值分层 | `ads_user_segment` | `/api/charts/user-segment` |
| 电池健康 | `ads_battery_health` | `/api/charts/battery-health` |
| 收入结构 | `ads_revenue_struct` | `/api/charts/revenue-struct` |
| 实时订单流水 | `ads_realtime_sessions` | `/api/charts/realtime-sessions` |

顶部总览、数据质量和链路状态使用 `ads_overview`、`ads_data_quality`、`ads_pipeline_info` 三张辅助 ADS 表。旧的 `/api/screen/bundle` 和 CSV 自动兜底不再作为正式大屏链路。
