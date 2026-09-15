-- 每层均按同一 load_dt 验证，订单应满足 ODS数量 = DWD有效数量 + DWD异常剔除数量（去重另计）。
SELECT 'ODS_ORDER' layer_table, COUNT(*) cnt FROM charging_ods.ods_charging_session WHERE dt='${hiveconf:load_dt}'
UNION ALL SELECT 'ODS_BATTERY',COUNT(*) FROM charging_ods.ods_battery_telemetry WHERE dt='${hiveconf:load_dt}'
UNION ALL SELECT 'ODS_STATION',COUNT(*) FROM charging_ods.ods_station WHERE dt='${hiveconf:load_dt}'
UNION ALL SELECT 'DWD_ORDER_VALID',COUNT(*) FROM charging_dwd.dwd_charging_session WHERE load_dt='${hiveconf:load_dt}'
UNION ALL SELECT 'DWD_BATTERY',COUNT(*) FROM charging_dwd.dwd_battery_detail WHERE load_dt='${hiveconf:load_dt}'
UNION ALL SELECT 'DWD_STATION',COUNT(*) FROM charging_dwd.dwd_station WHERE load_dt='${hiveconf:load_dt}'
UNION ALL SELECT 'DWS_DAILY',COUNT(*) FROM charging_dws.dws_daily_operation WHERE load_dt='${hiveconf:load_dt}'
UNION ALL SELECT 'ADS_OVERVIEW',COUNT(*) FROM charging_ads.ads_overview WHERE load_dt='${hiveconf:load_dt}';

SELECT stage,data_type,cnt FROM charging_dwd.dwd_data_quality
WHERE load_dt='${hiveconf:load_dt}' ORDER BY data_type,stage;
