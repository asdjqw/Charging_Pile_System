-- DWD 明细层由 spark/jobs/hive_dwd.py 写入，清洗口径与原项目完全共用。
CREATE EXTERNAL TABLE IF NOT EXISTS charging_dwd.dwd_station (
  station_id STRING, location_id STRING, station_name STRING, address STRING,
  district STRING, road STRING, device_count INT, facility_type INT,
  facility_type_cn STRING, open_time STRING, update_time DATE
)
PARTITIONED BY (load_dt STRING)
STORED AS PARQUET LOCATION '${hiveconf:warehouse_root}/dwd/station'
TBLPROPERTIES ('parquet.compression'='SNAPPY');

CREATE EXTERNAL TABLE IF NOT EXISTS charging_dwd.dwd_charging_session (
  session_id STRING, user_id STRING, station_id STRING, location_id STRING,
  kwh_total DOUBLE, charging_fees DOUBLE, charge_hours DOUBLE,
  avg_power_kw DOUBLE, price_per_kwh DOUBLE, is_fleet_vehicle INT,
  facility_type INT, facility_type_cn STRING, platform STRING,
  created_ts TIMESTAMP, ended_ts TIMESTAMP, stat_date DATE,
  stat_year INT, stat_month INT, stat_month_str STRING,
  start_hour INT, end_hour INT, weekday_num INT, weekday_cn STRING,
  is_weekend INT, day_type STRING, time_period STRING, station_name STRING,
  address STRING, district STRING, road STRING, device_count INT
)
PARTITIONED BY (load_dt STRING, biz_date STRING)
STORED AS PARQUET LOCATION '${hiveconf:warehouse_root}/dwd/charging_session'
TBLPROPERTIES ('parquet.compression'='SNAPPY');

CREATE EXTERNAL TABLE IF NOT EXISTS charging_dwd.dwd_battery_detail (
  session_id STRING, soc DOUBLE, soc_bin STRING, pack_voltage DOUBLE,
  charge_current DOUBLE, charge_power_kw DOUBLE, max_cell_voltage DOUBLE,
  min_cell_voltage DOUBLE, cell_voltage_diff DOUBLE, max_temperature DOUBLE,
  min_temperature DOUBLE, temp_rise DOUBLE, available_energy DOUBLE,
  available_capacity DOUBLE, station_id STRING, district STRING,
  facility_type_cn STRING, day_type STRING, time_period STRING, stat_date DATE
)
PARTITIONED BY (load_dt STRING, biz_date STRING)
STORED AS PARQUET LOCATION '${hiveconf:warehouse_root}/dwd/battery_detail'
TBLPROPERTIES ('parquet.compression'='SNAPPY');

CREATE EXTERNAL TABLE IF NOT EXISTS charging_dwd.dwd_data_quality (
  stage STRING, data_type STRING, cnt BIGINT
)
PARTITIONED BY (load_dt STRING)
STORED AS PARQUET LOCATION '${hiveconf:warehouse_root}/dwd/data_quality'
TBLPROPERTIES ('parquet.compression'='SNAPPY');
