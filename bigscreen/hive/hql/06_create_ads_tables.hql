-- ADS 应用层：面向 Flask/MySQL/大屏的主题结果，覆盖 10 个分析维度和多组对比。
CREATE EXTERNAL TABLE IF NOT EXISTS charging_ads.ads_overview (
  total_sessions BIGINT, total_kwh DOUBLE, total_revenue DOUBLE, paid_sessions BIGINT,
  user_cnt BIGINT, station_cnt BIGINT, active_days BIGINT, avg_kwh DOUBLE,
  avg_hours DOUBLE, avg_power DOUBLE
) PARTITIONED BY (load_dt STRING) STORED AS PARQUET
LOCATION '${hiveconf:warehouse_root}/ads/overview';

CREATE EXTERNAL TABLE IF NOT EXISTS charging_ads.ads_daily_trend (
  stat_date DATE, sessions BIGINT, kwh DOUBLE, revenue DOUBLE, users BIGINT, avg_kwh DOUBLE
) PARTITIONED BY (load_dt STRING) STORED AS PARQUET
LOCATION '${hiveconf:warehouse_root}/ads/daily_trend';

CREATE EXTERNAL TABLE IF NOT EXISTS charging_ads.ads_station_top (
  station_id STRING, station_name STRING, district STRING, facility_type_cn STRING,
  device_count INT, sessions BIGINT, kwh DOUBLE, revenue DOUBLE, users BIGINT,
  avg_power DOUBLE, orders_per_device DOUBLE, rank_no INT
) PARTITIONED BY (load_dt STRING) STORED AS PARQUET
LOCATION '${hiveconf:warehouse_root}/ads/station_top';

CREATE EXTERNAL TABLE IF NOT EXISTS charging_ads.ads_hour_load (
  start_hour INT, sessions BIGINT, kwh DOUBLE, avg_power DOUBLE
) PARTITIONED BY (load_dt STRING) STORED AS PARQUET
LOCATION '${hiveconf:warehouse_root}/ads/hour_load';

CREATE EXTERNAL TABLE IF NOT EXISTS charging_ads.ads_facility_compare (
  facility_type INT, facility_type_cn STRING, sessions BIGINT, kwh DOUBLE,
  revenue DOUBLE, users BIGINT, avg_kwh DOUBLE, avg_hours DOUBLE,
  avg_power DOUBLE, paid_rate DOUBLE
) PARTITIONED BY (load_dt STRING) STORED AS PARQUET
LOCATION '${hiveconf:warehouse_root}/ads/facility_compare';

CREATE EXTERNAL TABLE IF NOT EXISTS charging_ads.ads_weekend_compare (
  day_type STRING, days BIGINT, sessions BIGINT, kwh DOUBLE, revenue DOUBLE,
  users BIGINT, avg_kwh DOUBLE, avg_hours DOUBLE, avg_power DOUBLE
) PARTITIONED BY (load_dt STRING) STORED AS PARQUET
LOCATION '${hiveconf:warehouse_root}/ads/weekend_compare';

CREATE EXTERNAL TABLE IF NOT EXISTS charging_ads.ads_time_period_compare (
  time_period STRING, sessions BIGINT, kwh DOUBLE, revenue DOUBLE,
  avg_kwh DOUBLE, avg_hours DOUBLE, avg_power DOUBLE
) PARTITIONED BY (load_dt STRING) STORED AS PARQUET
LOCATION '${hiveconf:warehouse_root}/ads/time_period_compare';

CREATE EXTERNAL TABLE IF NOT EXISTS charging_ads.ads_platform_compare (
  platform STRING, sessions BIGINT, kwh DOUBLE, revenue DOUBLE,
  users BIGINT, avg_kwh DOUBLE, paid_rate DOUBLE
) PARTITIONED BY (load_dt STRING) STORED AS PARQUET
LOCATION '${hiveconf:warehouse_root}/ads/platform_compare';

CREATE EXTERNAL TABLE IF NOT EXISTS charging_ads.ads_district_compare (
  district STRING, sessions BIGINT, kwh DOUBLE, revenue DOUBLE,
  station_cnt BIGINT, users BIGINT, avg_kwh DOUBLE
) PARTITIONED BY (load_dt STRING) STORED AS PARQUET
LOCATION '${hiveconf:warehouse_root}/ads/district_compare';

CREATE EXTERNAL TABLE IF NOT EXISTS charging_ads.ads_battery_health (
  soc_bin STRING, facility_type_cn STRING, samples BIGINT, avg_soc DOUBLE,
  avg_power DOUBLE, avg_voltage_diff DOUBLE, avg_temp_rise DOUBLE
) PARTITIONED BY (load_dt STRING) STORED AS PARQUET
LOCATION '${hiveconf:warehouse_root}/ads/battery_health';
