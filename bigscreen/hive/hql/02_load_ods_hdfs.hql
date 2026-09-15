-- HDFS 模式会把 staging 文件移动进 ODS 分区，脚本每次会重新上传 staging。
LOAD DATA INPATH '${hiveconf:staging_root}/${hiveconf:load_dt}/nvv2t.csv'
OVERWRITE INTO TABLE charging_ods.ods_charging_session PARTITION (dt='${hiveconf:load_dt}');

LOAD DATA INPATH '${hiveconf:staging_root}/${hiveconf:load_dt}/dsv13r2.csv'
OVERWRITE INTO TABLE charging_ods.ods_battery_telemetry PARTITION (dt='${hiveconf:load_dt}');

LOAD DATA INPATH '${hiveconf:staging_root}/${hiveconf:load_dt}/nvv2t_md_end.csv'
OVERWRITE INTO TABLE charging_ods.ods_station PARTITION (dt='${hiveconf:load_dt}');
