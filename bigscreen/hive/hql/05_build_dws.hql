SET hive.exec.dynamic.partition=true;
SET hive.exec.dynamic.partition.mode=nonstrict;
SET parquet.compression=SNAPPY;

INSERT OVERWRITE TABLE charging_dws.dws_daily_operation PARTITION(load_dt='${hiveconf:load_dt}')
SELECT stat_date, COUNT(*), ROUND(SUM(kwh_total),2), ROUND(SUM(charging_fees),2),
  SUM(CASE WHEN charging_fees > 0 THEN 1 ELSE 0 END), COUNT(DISTINCT user_id),
  COUNT(DISTINCT station_id), ROUND(AVG(kwh_total),2), ROUND(AVG(charge_hours),2),
  ROUND(AVG(avg_power_kw),2)
FROM charging_dwd.dwd_charging_session WHERE load_dt='${hiveconf:load_dt}' GROUP BY stat_date;

INSERT OVERWRITE TABLE charging_dws.dws_station_operation PARTITION(load_dt='${hiveconf:load_dt}')
SELECT station_id, MAX(station_name), MAX(district), MAX(facility_type_cn), MAX(device_count),
  COUNT(*), ROUND(SUM(kwh_total),2), ROUND(SUM(charging_fees),2), COUNT(DISTINCT user_id),
  ROUND(AVG(kwh_total),2), ROUND(AVG(charge_hours),2), ROUND(AVG(avg_power_kw),2)
FROM charging_dwd.dwd_charging_session WHERE load_dt='${hiveconf:load_dt}' GROUP BY station_id;

INSERT OVERWRITE TABLE charging_dws.dws_hour_operation PARTITION(load_dt='${hiveconf:load_dt}')
SELECT day_type, time_period, start_hour, COUNT(*), ROUND(SUM(kwh_total),2),
  ROUND(SUM(charging_fees),2), ROUND(AVG(avg_power_kw),2)
FROM charging_dwd.dwd_charging_session WHERE load_dt='${hiveconf:load_dt}'
GROUP BY day_type,time_period,start_hour;

INSERT OVERWRITE TABLE charging_dws.dws_facility_operation PARTITION(load_dt='${hiveconf:load_dt}')
SELECT facility_type, facility_type_cn, COUNT(*), ROUND(SUM(kwh_total),2),
  ROUND(SUM(charging_fees),2), COUNT(DISTINCT user_id), ROUND(AVG(kwh_total),2),
  ROUND(AVG(charge_hours),2), ROUND(AVG(avg_power_kw),2),
  SUM(CASE WHEN charging_fees > 0 THEN 1 ELSE 0 END)
FROM charging_dwd.dwd_charging_session WHERE load_dt='${hiveconf:load_dt}'
GROUP BY facility_type,facility_type_cn;

INSERT OVERWRITE TABLE charging_dws.dws_user_operation PARTITION(load_dt='${hiveconf:load_dt}')
SELECT user_id, COUNT(*), ROUND(SUM(kwh_total),2), ROUND(SUM(charging_fees),2),
  COUNT(DISTINCT stat_date), MAX(created_ts)
FROM charging_dwd.dwd_charging_session WHERE load_dt='${hiveconf:load_dt}' GROUP BY user_id;

INSERT OVERWRITE TABLE charging_dws.dws_battery_health PARTITION(load_dt='${hiveconf:load_dt}')
SELECT soc_bin, facility_type_cn, COUNT(*), ROUND(AVG(soc),2), ROUND(AVG(charge_power_kw),2),
  ROUND(AVG(cell_voltage_diff),4), ROUND(AVG(temp_rise),2)
FROM charging_dwd.dwd_battery_detail WHERE load_dt='${hiveconf:load_dt}'
GROUP BY soc_bin,facility_type_cn;
