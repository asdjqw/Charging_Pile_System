-- 本文件必须由 spark-sql 执行。每个 INSERT 对应一张大屏图表的 ADS 表。
SET spark.sql.orc.compression.codec=snappy;
SET spark.sql.sources.partitionOverwriteMode=dynamic;

INSERT OVERWRITE TABLE charging_ads.ads_overview PARTITION(load_dt='${hiveconf:load_dt}')
SELECT COUNT(*), ROUND(SUM(kwh_total),2), ROUND(SUM(charging_fees),2),
  SUM(CASE WHEN charging_fees > 0 THEN 1 ELSE 0 END), COUNT(DISTINCT user_id),
  COUNT(DISTINCT station_id), COUNT(DISTINCT stat_date), ROUND(AVG(kwh_total),2),
  ROUND(AVG(charge_hours),2), ROUND(AVG(avg_power_kw),2),
  (SELECT SUM(device_count) FROM charging_dwd.dwd_station WHERE load_dt='${hiveconf:load_dt}'),
  ROUND(SUM(CASE WHEN charging_fees > 0 THEN 1 ELSE 0 END) / COUNT(*) * 100,2),
  MIN(stat_date), MAX(stat_date)
FROM charging_dwd.dwd_charging_session WHERE load_dt='${hiveconf:load_dt}';

INSERT OVERWRITE TABLE charging_ads.ads_daily_trend PARTITION(load_dt='${hiveconf:load_dt}')
SELECT stat_date,sessions,kwh,revenue,users,avg_kwh
FROM charging_dws.dws_daily_operation WHERE load_dt='${hiveconf:load_dt}';

INSERT OVERWRITE TABLE charging_ads.ads_monthly_trend PARTITION(load_dt='${hiveconf:load_dt}')
SELECT stat_month_str, COUNT(*), ROUND(SUM(kwh_total),2), ROUND(SUM(charging_fees),2),
  ROUND(AVG(kwh_total),2), COUNT(DISTINCT user_id)
FROM charging_dwd.dwd_charging_session WHERE load_dt='${hiveconf:load_dt}'
GROUP BY stat_month_str;

INSERT OVERWRITE TABLE charging_ads.ads_hour_load PARTITION(load_dt='${hiveconf:load_dt}')
SELECT start_hour,SUM(sessions),ROUND(SUM(kwh),2),ROUND(AVG(avg_power),2)
FROM charging_dws.dws_hour_operation WHERE load_dt='${hiveconf:load_dt}' GROUP BY start_hour;

INSERT OVERWRITE TABLE charging_ads.ads_weekday_hour_heat PARTITION(load_dt='${hiveconf:load_dt}')
SELECT weekday_num, MAX(weekday_cn), start_hour, COUNT(*), ROUND(SUM(kwh_total),2)
FROM charging_dwd.dwd_charging_session WHERE load_dt='${hiveconf:load_dt}'
GROUP BY weekday_num,start_hour;

INSERT OVERWRITE TABLE charging_ads.ads_station_top PARTITION(load_dt='${hiveconf:load_dt}')
SELECT station_id,station_name,district,facility_type_cn,device_count,sessions,kwh,revenue,users,
  avg_power,ROUND(sessions / NULLIF(device_count,0),2),CAST(rank_no AS INT)
FROM (
  SELECT a.*,ROW_NUMBER() OVER(ORDER BY kwh DESC) rank_no
  FROM charging_dws.dws_station_operation a WHERE load_dt='${hiveconf:load_dt}'
) t WHERE rank_no <= 10;

INSERT OVERWRITE TABLE charging_ads.ads_facility_compare PARTITION(load_dt='${hiveconf:load_dt}')
SELECT facility_type,facility_type_cn,sessions,kwh,revenue,users,avg_kwh,avg_hours,avg_power,
  ROUND(paid_sessions / NULLIF(sessions,0) * 100,2)
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
  ROUND(SUM(CASE WHEN charging_fees>0 THEN 1 ELSE 0 END) / COUNT(*) * 100,2)
FROM charging_dwd.dwd_charging_session WHERE load_dt='${hiveconf:load_dt}' GROUP BY platform;

INSERT OVERWRITE TABLE charging_ads.ads_district_compare PARTITION(load_dt='${hiveconf:load_dt}')
SELECT district,COUNT(*),ROUND(SUM(kwh_total),2),ROUND(SUM(charging_fees),2),
  COUNT(DISTINCT station_id),COUNT(DISTINCT user_id),ROUND(AVG(kwh_total),2)
FROM charging_dwd.dwd_charging_session WHERE load_dt='${hiveconf:load_dt}' GROUP BY district;

INSERT OVERWRITE TABLE charging_ads.ads_duration_dist PARTITION(load_dt='${hiveconf:load_dt}')
WITH binned AS (
  SELECT CASE WHEN charge_hours < 0.5 THEN '0-0.5' WHEN charge_hours < 1 THEN '0.5-1'
    WHEN charge_hours < 2 THEN '1-2' WHEN charge_hours < 4 THEN '2-4' ELSE '4+' END bin_label,
    CASE WHEN charge_hours < 0.5 THEN 0 WHEN charge_hours < 1 THEN 1 WHEN charge_hours < 2 THEN 2
      WHEN charge_hours < 4 THEN 3 ELSE 4 END bin_order, kwh_total
  FROM charging_dwd.dwd_charging_session WHERE load_dt='${hiveconf:load_dt}'
), total AS (SELECT COUNT(*) cnt FROM binned)
SELECT bin_label,bin_order,COUNT(*),ROUND(SUM(kwh_total),2),ROUND(COUNT(*) / total.cnt * 100,2)
FROM binned CROSS JOIN total GROUP BY bin_label,bin_order,total.cnt;

INSERT OVERWRITE TABLE charging_ads.ads_energy_dist PARTITION(load_dt='${hiveconf:load_dt}')
WITH binned AS (
  SELECT CASE WHEN kwh_total < 2 THEN '0-2' WHEN kwh_total < 5 THEN '2-5'
    WHEN kwh_total < 10 THEN '5-10' WHEN kwh_total < 15 THEN '10-15' ELSE '15+' END bin_label,
    CASE WHEN kwh_total < 2 THEN 0 WHEN kwh_total < 5 THEN 1 WHEN kwh_total < 10 THEN 2
      WHEN kwh_total < 15 THEN 3 ELSE 4 END bin_order, kwh_total
  FROM charging_dwd.dwd_charging_session WHERE load_dt='${hiveconf:load_dt}'
), total AS (SELECT COUNT(*) cnt FROM binned)
SELECT bin_label,bin_order,COUNT(*),ROUND(SUM(kwh_total),2),ROUND(COUNT(*) / total.cnt * 100,2)
FROM binned CROSS JOIN total GROUP BY bin_label,bin_order,total.cnt;

INSERT OVERWRITE TABLE charging_ads.ads_user_segment PARTITION(load_dt='${hiveconf:load_dt}')
WITH ranked AS (
  SELECT *, NTILE(3) OVER (ORDER BY kwh DESC) score_group
  FROM charging_dws.dws_user_operation WHERE load_dt='${hiveconf:load_dt}'
), labelled AS (
  SELECT CASE score_group WHEN 1 THEN '高价值用户' WHEN 2 THEN '潜力用户' ELSE '长尾用户' END segment,
    sessions,kwh FROM ranked
), totals AS (SELECT COUNT(*) total_users, SUM(kwh) total_kwh FROM labelled)
SELECT l.segment,COUNT(*),SUM(l.sessions),ROUND(SUM(l.kwh),2),ROUND(AVG(l.sessions),2),ROUND(AVG(l.kwh),2),
  ROUND(COUNT(*) / t.total_users * 100,2),ROUND(SUM(l.kwh) / t.total_kwh * 100,2)
FROM labelled l CROSS JOIN totals t GROUP BY l.segment,t.total_users,t.total_kwh;

INSERT OVERWRITE TABLE charging_ads.ads_battery_health PARTITION(load_dt='${hiveconf:load_dt}')
SELECT soc_bin,facility_type_cn,samples,avg_soc,avg_power,avg_voltage_diff,avg_temp_rise
FROM charging_dws.dws_battery_health WHERE load_dt='${hiveconf:load_dt}';

INSERT OVERWRITE TABLE charging_ads.ads_revenue_struct PARTITION(load_dt='${hiveconf:load_dt}')
SELECT facility_type_cn, sessions, kwh, revenue, paid_sessions,
  ROUND(paid_sessions / NULLIF(sessions,0) * 100,2), ROUND(revenue / NULLIF(kwh,0),3), '站点类型'
FROM charging_dws.dws_facility_operation WHERE load_dt='${hiveconf:load_dt}';

INSERT OVERWRITE TABLE charging_ads.ads_realtime_sessions PARTITION(load_dt='${hiveconf:load_dt}')
SELECT created_ts,station_name,district,facility_type_cn,platform,kwh_total,charging_fees,charge_hours,time_period
FROM charging_dwd.dwd_charging_session WHERE load_dt='${hiveconf:load_dt}'
ORDER BY created_ts DESC LIMIT 20;

INSERT OVERWRITE TABLE charging_ads.ads_data_quality PARTITION(load_dt='${hiveconf:load_dt}')
SELECT stage,data_type,cnt FROM charging_dwd.dwd_data_quality WHERE load_dt='${hiveconf:load_dt}';

INSERT OVERWRITE TABLE charging_ads.ads_pipeline_info PARTITION(load_dt='${hiveconf:load_dt}')
SELECT current_timestamp(), 'Spark SQL', 'HDFS ORC + Snappy', '${hiveconf:warehouse_root}/ods',
  '${hiveconf:warehouse_root}/dwd,dws', '${hiveconf:warehouse_root}/ads',
  (SELECT COUNT(*) FROM charging_dwd.dwd_charging_session WHERE load_dt='${hiveconf:load_dt}'),
  (SELECT COUNT(*) FROM charging_dwd.dwd_battery_detail WHERE load_dt='${hiveconf:load_dt}'),
  (SELECT COUNT(*) FROM charging_dwd.dwd_station WHERE load_dt='${hiveconf:load_dt}'),
  'Spark SQL DWD→DWS→ADS；ADS ORC 导出为管道符文本后幂等同步 MySQL';
