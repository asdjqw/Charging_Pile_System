-- LOCAL 模式会复制本机文件到 ODS 分区目录，源 CSV 保持不变。
LOAD DATA LOCAL INPATH '${hiveconf:local_raw}/nvv2t.csv'
OVERWRITE INTO TABLE charging_ods.ods_charging_session PARTITION (dt='${hiveconf:load_dt}');

LOAD DATA LOCAL INPATH '${hiveconf:local_raw}/dsv13r2.csv'
OVERWRITE INTO TABLE charging_ods.ods_battery_telemetry PARTITION (dt='${hiveconf:load_dt}');

LOAD DATA LOCAL INPATH '${hiveconf:local_raw}/nvv2t_md_end.csv'
OVERWRITE INTO TABLE charging_ods.ods_station PARTITION (dt='${hiveconf:load_dt}');
