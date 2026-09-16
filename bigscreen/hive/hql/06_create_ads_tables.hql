-- ADS 应用层：一张图表对应一张 ADS ORC 表；所有结果按 load_dt 批次分区。
-- 这些表同时是 MySQL 同名展示表的唯一上游来源。

CREATE EXTERNAL TABLE IF NOT EXISTS charging_ads.ads_overview (
  total_sessions BIGINT, total_kwh DOUBLE, total_revenue DOUBLE, paid_sessions BIGINT,
  user_cnt BIGINT, station_cnt BIGINT, active_days BIGINT, avg_kwh DOUBLE,
  avg_hours DOUBLE, avg_power DOUBLE, device_cnt BIGINT, paid_rate DOUBLE,
  start_date DATE, end_date DATE
) PARTITIONED BY (load_dt STRING) STORED AS ORC
LOCATION '${hiveconf:warehouse_root}/ads/overview' TBLPROPERTIES ('orc.compress'='SNAPPY');

CREATE EXTERNAL TABLE IF NOT EXISTS charging_ads.ads_daily_trend (
  stat_date DATE, sessions BIGINT, kwh DOUBLE, revenue DOUBLE, users BIGINT, avg_kwh DOUBLE
) PARTITIONED BY (load_dt STRING) STORED AS ORC
LOCATION '${hiveconf:warehouse_root}/ads/daily_trend' TBLPROPERTIES ('orc.compress'='SNAPPY');

CREATE EXTERNAL TABLE IF NOT EXISTS charging_ads.ads_monthly_trend (
  stat_month_str STRING, sessions BIGINT, kwh DOUBLE, revenue DOUBLE, avg_kwh DOUBLE, users BIGINT
) PARTITIONED BY (load_dt STRING) STORED AS ORC
LOCATION '${hiveconf:warehouse_root}/ads/monthly_trend' TBLPROPERTIES ('orc.compress'='SNAPPY');

CREATE EXTERNAL TABLE IF NOT EXISTS charging_ads.ads_hour_load (
  start_hour INT, sessions BIGINT, kwh DOUBLE, avg_power DOUBLE
) PARTITIONED BY (load_dt STRING) STORED AS ORC
LOCATION '${hiveconf:warehouse_root}/ads/hour_load' TBLPROPERTIES ('orc.compress'='SNAPPY');

CREATE EXTERNAL TABLE IF NOT EXISTS charging_ads.ads_weekday_hour_heat (
  weekday_num INT, weekday_cn STRING, start_hour INT, sessions BIGINT, kwh DOUBLE
) PARTITIONED BY (load_dt STRING) STORED AS ORC
LOCATION '${hiveconf:warehouse_root}/ads/weekday_hour_heat' TBLPROPERTIES ('orc.compress'='SNAPPY');

CREATE EXTERNAL TABLE IF NOT EXISTS charging_ads.ads_station_top (
  station_id STRING, station_name STRING, district STRING, facility_type_cn STRING,
  device_count INT, sessions BIGINT, kwh DOUBLE, revenue DOUBLE, users BIGINT,
  avg_power DOUBLE, orders_per_device DOUBLE, rank_no INT
) PARTITIONED BY (load_dt STRING) STORED AS ORC
LOCATION '${hiveconf:warehouse_root}/ads/station_top' TBLPROPERTIES ('orc.compress'='SNAPPY');

CREATE EXTERNAL TABLE IF NOT EXISTS charging_ads.ads_facility_compare (
  facility_type INT, facility_type_cn STRING, sessions BIGINT, kwh DOUBLE,
  revenue DOUBLE, users BIGINT, avg_kwh DOUBLE, avg_hours DOUBLE,
  avg_power DOUBLE, paid_rate DOUBLE
) PARTITIONED BY (load_dt STRING) STORED AS ORC
LOCATION '${hiveconf:warehouse_root}/ads/facility_compare' TBLPROPERTIES ('orc.compress'='SNAPPY');

CREATE EXTERNAL TABLE IF NOT EXISTS charging_ads.ads_weekend_compare (
  day_type STRING, days BIGINT, sessions BIGINT, kwh DOUBLE, revenue DOUBLE,
  users BIGINT, avg_kwh DOUBLE, avg_hours DOUBLE, avg_power DOUBLE
) PARTITIONED BY (load_dt STRING) STORED AS ORC
LOCATION '${hiveconf:warehouse_root}/ads/weekend_compare' TBLPROPERTIES ('orc.compress'='SNAPPY');

CREATE EXTERNAL TABLE IF NOT EXISTS charging_ads.ads_time_period_compare (
  time_period STRING, sessions BIGINT, kwh DOUBLE, revenue DOUBLE,
  avg_kwh DOUBLE, avg_hours DOUBLE, avg_power DOUBLE
) PARTITIONED BY (load_dt STRING) STORED AS ORC
LOCATION '${hiveconf:warehouse_root}/ads/time_period_compare' TBLPROPERTIES ('orc.compress'='SNAPPY');

CREATE EXTERNAL TABLE IF NOT EXISTS charging_ads.ads_platform_compare (
  platform STRING, sessions BIGINT, kwh DOUBLE, revenue DOUBLE,
  users BIGINT, avg_kwh DOUBLE, paid_rate DOUBLE
) PARTITIONED BY (load_dt STRING) STORED AS ORC
LOCATION '${hiveconf:warehouse_root}/ads/platform_compare' TBLPROPERTIES ('orc.compress'='SNAPPY');

CREATE EXTERNAL TABLE IF NOT EXISTS charging_ads.ads_district_compare (
  district STRING, sessions BIGINT, kwh DOUBLE, revenue DOUBLE,
  station_cnt BIGINT, users BIGINT, avg_kwh DOUBLE
) PARTITIONED BY (load_dt STRING) STORED AS ORC
LOCATION '${hiveconf:warehouse_root}/ads/district_compare' TBLPROPERTIES ('orc.compress'='SNAPPY');

CREATE EXTERNAL TABLE IF NOT EXISTS charging_ads.ads_duration_dist (
  bin_label STRING, bin_order INT, sessions BIGINT, kwh DOUBLE, pct DOUBLE
) PARTITIONED BY (load_dt STRING) STORED AS ORC
LOCATION '${hiveconf:warehouse_root}/ads/duration_dist' TBLPROPERTIES ('orc.compress'='SNAPPY');

CREATE EXTERNAL TABLE IF NOT EXISTS charging_ads.ads_energy_dist (
  bin_label STRING, bin_order INT, sessions BIGINT, kwh DOUBLE, pct DOUBLE
) PARTITIONED BY (load_dt STRING) STORED AS ORC
LOCATION '${hiveconf:warehouse_root}/ads/energy_dist' TBLPROPERTIES ('orc.compress'='SNAPPY');

CREATE EXTERNAL TABLE IF NOT EXISTS charging_ads.ads_user_segment (
  segment STRING, user_cnt BIGINT, sessions BIGINT, kwh DOUBLE, avg_sessions DOUBLE,
  avg_kwh DOUBLE, user_pct DOUBLE, kwh_pct DOUBLE
) PARTITIONED BY (load_dt STRING) STORED AS ORC
LOCATION '${hiveconf:warehouse_root}/ads/user_segment' TBLPROPERTIES ('orc.compress'='SNAPPY');

CREATE EXTERNAL TABLE IF NOT EXISTS charging_ads.ads_battery_health (
  soc_bin STRING, facility_type_cn STRING, samples BIGINT, avg_soc DOUBLE,
  avg_power DOUBLE, avg_voltage_diff DOUBLE, avg_temp_rise DOUBLE
) PARTITIONED BY (load_dt STRING) STORED AS ORC
LOCATION '${hiveconf:warehouse_root}/ads/battery_health' TBLPROPERTIES ('orc.compress'='SNAPPY');

CREATE EXTERNAL TABLE IF NOT EXISTS charging_ads.ads_revenue_struct (
  dim_name STRING, sessions BIGINT, kwh DOUBLE, revenue DOUBLE, paid_sessions BIGINT,
  paid_rate DOUBLE, avg_price DOUBLE, dim_type STRING
) PARTITIONED BY (load_dt STRING) STORED AS ORC
LOCATION '${hiveconf:warehouse_root}/ads/revenue_struct' TBLPROPERTIES ('orc.compress'='SNAPPY');

CREATE EXTERNAL TABLE IF NOT EXISTS charging_ads.ads_realtime_sessions (
  created_time TIMESTAMP, station_name STRING, district STRING, facility_type_cn STRING,
  platform STRING, kwh_total DOUBLE, charging_fees DOUBLE, charge_hours DOUBLE, time_period STRING
) PARTITIONED BY (load_dt STRING) STORED AS ORC
LOCATION '${hiveconf:warehouse_root}/ads/realtime_sessions' TBLPROPERTIES ('orc.compress'='SNAPPY');

-- 非图表辅助结果：顶部 KPI、质量与链路状态也从 ADS 同步到 MySQL。
CREATE EXTERNAL TABLE IF NOT EXISTS charging_ads.ads_data_quality (
  stage STRING, data_type STRING, cnt BIGINT
) PARTITIONED BY (load_dt STRING) STORED AS ORC
LOCATION '${hiveconf:warehouse_root}/ads/data_quality' TBLPROPERTIES ('orc.compress'='SNAPPY');

CREATE EXTERNAL TABLE IF NOT EXISTS charging_ads.ads_pipeline_info (
  run_time TIMESTAMP, engine STRING, storage STRING, raw_path STRING, warehouse_path STRING,
  ads_path STRING, valid_sessions BIGINT, battery_records BIGINT, station_cnt BIGINT, note STRING
) PARTITIONED BY (load_dt STRING) STORED AS ORC
LOCATION '${hiveconf:warehouse_root}/ads/pipeline_info' TBLPROPERTIES ('orc.compress'='SNAPPY');
