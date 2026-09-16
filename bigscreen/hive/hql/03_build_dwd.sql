-- DWD 清洗只通过 Spark SQL 执行：时间修复、主键去重、空值/异常过滤、维度关联与指标派生。
SET spark.sql.orc.compression.codec=snappy;
SET spark.sql.sources.partitionOverwriteMode=dynamic;

INSERT OVERWRITE TABLE charging_dwd.dwd_station PARTITION(load_dt='${hiveconf:load_dt}')
WITH station_ranked AS (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY station_id ORDER BY update_time DESC) AS rn
  FROM charging_ods.ods_station WHERE dt='${hiveconf:load_dt}' AND station_id IS NOT NULL
)
SELECT station_id, location_id, station_name, address,
  regexp_extract(station_name, '^([^·]*(区|新区))', 1) AS district,
  regexp_extract(station_name, '^(?:[^·]*?(?:区|新区))([^·]*)·', 1) AS road,
  CAST(device_count AS INT), CAST(facility_type AS INT),
  CASE CAST(facility_type AS INT) WHEN 1 THEN '交流充电站' WHEN 2 THEN '直流充电站'
    WHEN 3 THEN '交直流充电站' WHEN 4 THEN '超充站' ELSE '未知' END,
  COALESCE(open_time, '00:00-24:00'), to_date(update_time, 'yyyy/M/d')
FROM station_ranked WHERE rn=1;

INSERT OVERWRITE TABLE charging_dwd.dwd_charging_session PARTITION(load_dt='${hiveconf:load_dt}',biz_date)
WITH source_dedup AS (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY session_id ORDER BY created DESC, ended DESC) AS rn
  FROM charging_ods.ods_charging_session WHERE dt='${hiveconf:load_dt}'
), typed AS (
  SELECT *,
    to_timestamp(concat(lpad(CAST(CAST(substr(created,1,4) AS INT)+2000 AS STRING),4,'0'),substr(created,5)), 'yyyy-MM-dd HH:mm:ss') created_ts,
    to_timestamp(concat(lpad(CAST(CAST(substr(ended,1,4) AS INT)+2000 AS STRING),4,'0'),substr(ended,5)), 'yyyy-MM-dd HH:mm:ss') ended_ts,
    CAST(kwh_total AS DOUBLE) kwh, CAST(charging_fees AS DOUBLE) fee, CAST(charge_time_hrs AS DOUBLE) hours,
    CAST(start_time AS INT) start_hour_int, CAST(end_time AS INT) end_hour_int
  FROM source_dedup WHERE rn=1 AND session_id IS NOT NULL AND user_id IS NOT NULL
    AND station_id IS NOT NULL AND created IS NOT NULL AND ended IS NOT NULL
), valid AS (
  SELECT * FROM typed WHERE created_ts IS NOT NULL AND ended_ts IS NOT NULL
    AND kwh > 0 AND kwh <= 40 AND hours > 0 AND hours <= 12 AND fee >= 0
)
SELECT v.session_id, v.user_id, v.station_id, v.location_id, v.kwh, v.fee, v.hours,
  ROUND(v.kwh / v.hours,3), ROUND(v.fee / v.kwh,3), CAST(v.manager_vehicle AS INT),
  CAST(v.facility_type AS INT), COALESCE(s.facility_type_cn, CASE CAST(v.facility_type AS INT)
    WHEN 1 THEN '交流充电站' WHEN 2 THEN '直流充电站' WHEN 3 THEN '交直流充电站' WHEN 4 THEN '超充站' ELSE '未知' END),
  v.platform, v.created_ts, v.ended_ts, to_date(v.created_ts), year(v.created_ts), month(v.created_ts),
  date_format(v.created_ts,'yyyy-MM'), v.start_hour_int, v.end_hour_int, dayofweek(v.created_ts),
  CASE dayofweek(v.created_ts) WHEN 1 THEN '周日' WHEN 2 THEN '周一' WHEN 3 THEN '周二' WHEN 4 THEN '周三'
    WHEN 5 THEN '周四' WHEN 6 THEN '周五' WHEN 7 THEN '周六' END,
  CASE WHEN dayofweek(v.created_ts) IN (1,7) THEN 1 ELSE 0 END,
  CASE WHEN dayofweek(v.created_ts) IN (1,7) THEN '周末' ELSE '工作日' END,
  CASE WHEN v.start_hour_int IN (0,1,2,3,4,5,6,23) THEN '谷' WHEN v.start_hour_int IN (8,9,10,11,18,19,20) THEN '峰' ELSE '平' END,
  s.station_name,s.address,COALESCE(s.district,'未知'),s.road,s.device_count,date_format(to_date(v.created_ts),'yyyy-MM-dd')
FROM valid v LEFT JOIN charging_dwd.dwd_station s
  ON v.station_id=s.station_id AND s.load_dt='${hiveconf:load_dt}';

INSERT OVERWRITE TABLE charging_dwd.dwd_battery_detail PARTITION(load_dt='${hiveconf:load_dt}',biz_date)
WITH telemetry_dedup AS (
  SELECT DISTINCT * FROM charging_ods.ods_battery_telemetry WHERE dt='${hiveconf:load_dt}'
), typed AS (
  SELECT esd AS session_id, CAST(soc AS DOUBLE) soc, CAST(pack_voltage_v AS DOUBLE) pack_voltage,
    ABS(CAST(charge_current_a AS DOUBLE)) charge_current, CAST(max_cell_voltage_v AS DOUBLE) max_cell_voltage,
    CAST(min_cell_voltage_v AS DOUBLE) min_cell_voltage, CAST(max_temperature_c AS DOUBLE) max_temperature,
    CAST(min_temperature_c AS DOUBLE) min_temperature, CAST(available_energy_kw AS DOUBLE) available_energy,
    CAST(available_capacity_ah AS DOUBLE) available_capacity
  FROM telemetry_dedup
)
SELECT t.session_id,t.soc,concat(CAST(floor(t.soc/10)*10 AS INT),'-',CAST(floor(t.soc/10)*10+10 AS INT)),
  t.pack_voltage,t.charge_current,ROUND(t.pack_voltage*t.charge_current/1000,3),t.max_cell_voltage,t.min_cell_voltage,
  ROUND(t.max_cell_voltage-t.min_cell_voltage,4),t.max_temperature,t.min_temperature,t.max_temperature-t.min_temperature,
  t.available_energy,t.available_capacity,COALESCE(s.station_id,'unknown'),COALESCE(s.district,'未知'),
  COALESCE(s.facility_type_cn,'未知'),s.day_type,s.time_period,s.stat_date,
  COALESCE(date_format(s.stat_date,'yyyy-MM-dd'),'unknown')
FROM typed t LEFT JOIN charging_dwd.dwd_charging_session s
  ON t.session_id=s.session_id AND s.load_dt='${hiveconf:load_dt}';

INSERT OVERWRITE TABLE charging_dwd.dwd_data_quality PARTITION(load_dt='${hiveconf:load_dt}')
SELECT '原始订单记录','订单',COUNT(*) FROM charging_ods.ods_charging_session WHERE dt='${hiveconf:load_dt}'
UNION ALL SELECT '业务主键去重后','订单',COUNT(DISTINCT session_id)
  FROM charging_ods.ods_charging_session WHERE dt='${hiveconf:load_dt}'
UNION ALL SELECT '有效订单记录','订单',COUNT(*) FROM charging_dwd.dwd_charging_session WHERE load_dt='${hiveconf:load_dt}'
UNION ALL SELECT '原始遥测记录','遥测',COUNT(*) FROM charging_ods.ods_battery_telemetry WHERE dt='${hiveconf:load_dt}'
UNION ALL SELECT '全字段去重后','遥测',COUNT(*) FROM (SELECT DISTINCT * FROM charging_ods.ods_battery_telemetry WHERE dt='${hiveconf:load_dt}') t
UNION ALL SELECT '可关联订单的遥测记录','遥测',COUNT(*) FROM charging_dwd.dwd_battery_detail
  WHERE load_dt='${hiveconf:load_dt}' AND district<>'未知';
