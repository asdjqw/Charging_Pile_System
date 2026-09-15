SET parquet.compression=SNAPPY;

INSERT OVERWRITE TABLE charging_ads.ads_overview PARTITION(load_dt='${hiveconf:load_dt}')
SELECT COUNT(*), ROUND(SUM(kwh_total),2), ROUND(SUM(charging_fees),2),
  SUM(CASE WHEN charging_fees > 0 THEN 1 ELSE 0 END),
  COUNT(DISTINCT s.user_id), COUNT(DISTINCT s.station_id), COUNT(DISTINCT s.stat_date),
  ROUND(AVG(s.kwh_total),2), ROUND(AVG(s.charge_hours),2), ROUND(AVG(s.avg_power_kw),2)
FROM charging_dwd.dwd_charging_session s WHERE s.load_dt='${hiveconf:load_dt}';

INSERT OVERWRITE TABLE charging_ads.ads_daily_trend PARTITION(load_dt='${hiveconf:load_dt}')
SELECT stat_date,sessions,kwh,revenue,users,avg_kwh
FROM charging_dws.dws_daily_operation WHERE load_dt='${hiveconf:load_dt}';

INSERT OVERWRITE TABLE charging_ads.ads_station_top PARTITION(load_dt='${hiveconf:load_dt}')
SELECT station_id,station_name,district,facility_type_cn,device_count,sessions,kwh,revenue,users,
  avg_power,ROUND(sessions/CASE WHEN device_count=0 THEN NULL ELSE device_count END,2),CAST(rank_no AS INT)
FROM (
  SELECT a.*,ROW_NUMBER() OVER(ORDER BY kwh DESC) rank_no
  FROM charging_dws.dws_station_operation a WHERE load_dt='${hiveconf:load_dt}'
) t WHERE rank_no <= 15;

INSERT OVERWRITE TABLE charging_ads.ads_hour_load PARTITION(load_dt='${hiveconf:load_dt}')
SELECT start_hour,SUM(sessions),ROUND(SUM(kwh),2),ROUND(AVG(avg_power),2)
FROM charging_dws.dws_hour_operation WHERE load_dt='${hiveconf:load_dt}' GROUP BY start_hour;

INSERT OVERWRITE TABLE charging_ads.ads_facility_compare PARTITION(load_dt='${hiveconf:load_dt}')
SELECT facility_type,facility_type_cn,sessions,kwh,revenue,users,avg_kwh,avg_hours,avg_power,
  ROUND(paid_sessions/sessions*100,2)
FROM charging_dws.dws_facility_operation WHERE load_dt='${hiveconf:load_dt}';

INSERT OVERWRITE TABLE charging_ads.ads_weekend_compare PARTITION(load_dt='${hiveconf:load_dt}')
SELECT day_type,COUNT(DISTINCT stat_date),COUNT(*),ROUND(SUM(kwh_total),2),
  ROUND(SUM(charging_fees),2),COUNT(DISTINCT user_id),ROUND(AVG(kwh_total),2),
  ROUND(AVG(charge_hours),2),ROUND(AVG(avg_power_kw),2)
FROM charging_dwd.dwd_charging_session WHERE load_dt='${hiveconf:load_dt}' GROUP BY day_type;

INSERT OVERWRITE TABLE charging_ads.ads_time_period_compare PARTITION(load_dt='${hiveconf:load_dt}')
SELECT time_period,COUNT(*),ROUND(SUM(kwh_total),2),ROUND(SUM(charging_fees),2),
  ROUND(AVG(kwh_total),2),ROUND(AVG(charge_hours),2),ROUND(AVG(avg_power_kw),2)
FROM charging_dwd.dwd_charging_session WHERE load_dt='${hiveconf:load_dt}' GROUP BY time_period;

INSERT OVERWRITE TABLE charging_ads.ads_platform_compare PARTITION(load_dt='${hiveconf:load_dt}')
SELECT platform,COUNT(*),ROUND(SUM(kwh_total),2),ROUND(SUM(charging_fees),2),
  COUNT(DISTINCT user_id),ROUND(AVG(kwh_total),2),
  ROUND(SUM(CASE WHEN charging_fees>0 THEN 1 ELSE 0 END)/COUNT(*)*100,2)
FROM charging_dwd.dwd_charging_session WHERE load_dt='${hiveconf:load_dt}' GROUP BY platform;

INSERT OVERWRITE TABLE charging_ads.ads_district_compare PARTITION(load_dt='${hiveconf:load_dt}')
SELECT district,COUNT(*),ROUND(SUM(kwh_total),2),ROUND(SUM(charging_fees),2),
  COUNT(DISTINCT station_id),COUNT(DISTINCT user_id),ROUND(AVG(kwh_total),2)
FROM charging_dwd.dwd_charging_session WHERE load_dt='${hiveconf:load_dt}' GROUP BY district;

INSERT OVERWRITE TABLE charging_ads.ads_battery_health PARTITION(load_dt='${hiveconf:load_dt}')
SELECT soc_bin,facility_type_cn,samples,avg_soc,avg_power,avg_voltage_diff,avg_temp_rise
FROM charging_dws.dws_battery_health WHERE load_dt='${hiveconf:load_dt}';
