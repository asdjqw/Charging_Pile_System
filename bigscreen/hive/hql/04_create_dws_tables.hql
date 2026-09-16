-- DWS 公共汇总层：沉淀可被多个 ADS 主题复用的日/站点/小时/类型/用户/电池汇总。
CREATE EXTERNAL TABLE IF NOT EXISTS charging_dws.dws_daily_operation (
  stat_date DATE, sessions BIGINT, kwh DOUBLE, revenue DOUBLE, paid_sessions BIGINT,
  users BIGINT, stations BIGINT, avg_kwh DOUBLE, avg_hours DOUBLE, avg_power DOUBLE
) PARTITIONED BY (load_dt STRING) STORED AS ORC
LOCATION '${hiveconf:warehouse_root}/dws/daily_operation'
TBLPROPERTIES ('orc.compress'='SNAPPY');

CREATE EXTERNAL TABLE IF NOT EXISTS charging_dws.dws_station_operation (
  station_id STRING, station_name STRING, district STRING, facility_type_cn STRING,
  device_count INT, sessions BIGINT, kwh DOUBLE, revenue DOUBLE, users BIGINT,
  avg_kwh DOUBLE, avg_hours DOUBLE, avg_power DOUBLE
) PARTITIONED BY (load_dt STRING) STORED AS ORC
LOCATION '${hiveconf:warehouse_root}/dws/station_operation'
TBLPROPERTIES ('orc.compress'='SNAPPY');

CREATE EXTERNAL TABLE IF NOT EXISTS charging_dws.dws_hour_operation (
  day_type STRING, time_period STRING, start_hour INT, sessions BIGINT,
  kwh DOUBLE, revenue DOUBLE, avg_power DOUBLE
) PARTITIONED BY (load_dt STRING) STORED AS ORC
LOCATION '${hiveconf:warehouse_root}/dws/hour_operation'
TBLPROPERTIES ('orc.compress'='SNAPPY');

CREATE EXTERNAL TABLE IF NOT EXISTS charging_dws.dws_facility_operation (
  facility_type INT, facility_type_cn STRING, sessions BIGINT, kwh DOUBLE,
  revenue DOUBLE, users BIGINT, avg_kwh DOUBLE, avg_hours DOUBLE, avg_power DOUBLE,
  paid_sessions BIGINT
) PARTITIONED BY (load_dt STRING) STORED AS ORC
LOCATION '${hiveconf:warehouse_root}/dws/facility_operation'
TBLPROPERTIES ('orc.compress'='SNAPPY');

CREATE EXTERNAL TABLE IF NOT EXISTS charging_dws.dws_user_operation (
  user_id STRING, sessions BIGINT, kwh DOUBLE, revenue DOUBLE,
  active_days BIGINT, last_charge TIMESTAMP
) PARTITIONED BY (load_dt STRING) STORED AS ORC
LOCATION '${hiveconf:warehouse_root}/dws/user_operation'
TBLPROPERTIES ('orc.compress'='SNAPPY');

CREATE EXTERNAL TABLE IF NOT EXISTS charging_dws.dws_battery_health (
  soc_bin STRING, facility_type_cn STRING, samples BIGINT, avg_soc DOUBLE,
  avg_power DOUBLE, avg_voltage_diff DOUBLE, avg_temp_rise DOUBLE
) PARTITIONED BY (load_dt STRING) STORED AS ORC
LOCATION '${hiveconf:warehouse_root}/dws/battery_health'
TBLPROPERTIES ('orc.compress'='SNAPPY');
