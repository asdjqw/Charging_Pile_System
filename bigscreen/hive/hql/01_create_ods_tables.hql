-- ODS 贴源层：字段全部保留为 STRING，不在采集阶段改变原始值。
-- 表为 EXTERNAL，删除 Hive 元数据不会删除 HDFS 原文件。
CREATE EXTERNAL TABLE IF NOT EXISTS charging_ods.ods_charging_session (
  session_id STRING, kwh_total STRING, charging_fees STRING,
  created STRING, ended STRING, start_time STRING, end_time STRING,
  charge_time_hrs STRING, weekday STRING, platform STRING, user_id STRING,
  station_id STRING, location_id STRING, manager_vehicle STRING,
  facility_type STRING, mon STRING, tues STRING, wed STRING, thurs STRING,
  fri STRING, sat STRING, sun STRING
)
PARTITIONED BY (dt STRING)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
  "separatorChar" = ",",
  "quoteChar" = "\"",
  "escapeChar" = "\\"
)
STORED AS TEXTFILE
LOCATION '${hiveconf:warehouse_root}/ods/charging_session';

CREATE EXTERNAL TABLE IF NOT EXISTS charging_ods.ods_battery_telemetry (
  esd STRING, record_time STRING, soc STRING, pack_voltage_v STRING,
  charge_current_a STRING, max_cell_voltage_v STRING, min_cell_voltage_v STRING,
  max_temperature_c STRING, min_temperature_c STRING,
  available_energy_kw STRING, available_capacity_ah STRING
)
PARTITIONED BY (dt STRING)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
  "separatorChar" = ",",
  "quoteChar" = "\"",
  "escapeChar" = "\\"
)
STORED AS TEXTFILE
LOCATION '${hiveconf:warehouse_root}/ods/battery_telemetry';

CREATE EXTERNAL TABLE IF NOT EXISTS charging_ods.ods_station (
  station_id STRING, location_id STRING, facility_type STRING,
  station_name STRING, address STRING, device_count STRING,
  open_time STRING, update_time STRING
)
PARTITIONED BY (dt STRING)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
  "separatorChar" = ",",
  "quoteChar" = "\"",
  "escapeChar" = "\\"
)
STORED AS TEXTFILE
LOCATION '${hiveconf:warehouse_root}/ods/station';
