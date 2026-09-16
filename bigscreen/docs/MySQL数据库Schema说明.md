# 大屏 MySQL Schema 说明

正式 MySQL Schema 的唯一 SQL 来源是 [`mysql/schema/ads_schema.sql`](../mysql/schema/ads_schema.sql)。它不再从 CSV 自动推断字段；所有表由 Hive `charging_ads` 同名 ORC 表导出的 TXT 同步。

## 同步规则

1. Spark 从指定 `load_dt` 的 ADS ORC 分区导出管道符 TXT。
2. TXT 合并到 `output/mysql_stage/<load_dt>/`，该目录已被 Git 忽略。
3. 导入脚本先检查文件存在、非空且列数一致。
4. 每张目标表执行 `TRUNCATE TABLE`，随后执行 `LOAD DATA LOCAL INFILE`。
5. `etl_ads_sync_log` 记录批次、表名、导入行数和同步时间。

## 图表表

| 表 | 主要字段 | 使用位置 |
|---|---|---|
| `ads_overview` | 总订单、电量、收入、站点/设备/用户数、日期范围 | 顶部 KPI |
| `ads_daily_trend` | `stat_date`、订单、电量、收入、用户数 | 日趋势 |
| `ads_monthly_trend` | `stat_month_str`、订单、电量、收入 | 月趋势 |
| `ads_hour_load` | `start_hour`、订单、电量、平均功率 | 小时负荷 |
| `ads_weekday_hour_heat` | 星期、小时、订单、电量 | 热力图 |
| `ads_station_top` | 站点、行政区、订单、电量、排名 | 站点 TOP10 |
| `ads_facility_compare` | 站点类型、多项运营指标 | 类型对比 |
| `ads_weekend_compare` | 工作日/周末、多项运营指标 | 工作日对比 |
| `ads_time_period_compare` | 峰/平/谷、多项运营指标 | 时段对比 |
| `ads_platform_compare` | 平台、订单、电量、用户 | 平台对比 |
| `ads_district_compare` | 行政区、订单、电量、站点、用户 | 行政区分布 |
| `ads_duration_dist` | 时长区间、订单、电量、占比 | 时长分布 |
| `ads_energy_dist` | 电量区间、订单、电量、占比 | 电量分布 |
| `ads_user_segment` | 用户分层、用户数、订单、电量、占比 | 用户价值分层 |
| `ads_battery_health` | SOC 区间、电池健康指标 | 电池健康 |
| `ads_revenue_struct` | 站点类型、收入、付费率、均价 | 收入结构 |
| `ads_realtime_sessions` | 最近订单流水字段 | 实时订单面板 |
| `ads_data_quality` | 清洗阶段、数据类型、数量 | 顶部质量状态 |
| `ads_pipeline_info` | 引擎、存储、路径、行数、说明 | 顶部链路状态 |

旧 `ads_station_all`、`ads_district`、`ads_time_period` 以及 CSV 自动建表逻辑均不属于正式 MySQL Schema。
