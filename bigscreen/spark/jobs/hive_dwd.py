# -*- coding: utf-8 -*-
"""从 Hive ODS 分区读取数据，复用原项目 PySpark 规则写入 Hive DWD。"""

import argparse
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from pyspark.sql import functions as F

from etl_clean import build_spark, clean_battery, clean_sessions, clean_station


def _ods_sources(spark, load_dt):
    session = spark.table("charging_ods.ods_charging_session").where(F.col("dt") == load_dt).selectExpr(
        "session_id AS sessionId", "kwh_total AS kwhTotal", "charging_fees", "created", "ended",
        "start_time AS startTime", "end_time AS endTime", "charge_time_hrs AS chargeTimeHrs",
        "weekday", "platform", "user_id AS userId", "station_id AS stationId",
        "location_id AS locationId", "manager_vehicle AS managerVehicle",
        "facility_type AS facilityType", "mon AS Mon", "tues AS Tues", "wed AS Wed",
        "thurs AS Thurs", "fri AS Fri", "sat AS Sat", "sun AS Sun"
    )
    battery = spark.table("charging_ods.ods_battery_telemetry").where(F.col("dt") == load_dt).selectExpr(
        "esd", "record_time", "soc", "pack_voltage_v AS `pack_voltage (V)`",
        "charge_current_a AS `charge_current (A)`",
        "max_cell_voltage_v AS `max_cell_voltage (V)`",
        "min_cell_voltage_v AS `min_cell_voltage (V)`",
        "max_temperature_c AS `max_temperature (℃)`",
        "min_temperature_c AS `min_temperature (℃)`",
        "available_energy_kw AS `available_energy (kw)`",
        "available_capacity_ah AS `available_capacity (Ah)`"
    )
    station = spark.table("charging_ods.ods_station").where(F.col("dt") == load_dt).selectExpr(
        "station_id AS stationId", "location_id AS locationId", "facility_type AS facilityType",
        "station_name", "address", "device_count", "open_time", "update_time"
    )
    return session, battery, station


def _write_partition(df, table, columns, load_dt, with_biz_date=False):
    selected = df.select(*columns).withColumn("load_dt", F.lit(load_dt))
    if with_biz_date:
        selected = selected.withColumn(
            "biz_date", F.coalesce(F.date_format("stat_date", "yyyy-MM-dd"), F.lit("unknown"))
        )
    # dynamic partition overwrite 只替换本批次实际涉及的分区，不清空历史批次。
    # 单机/小规模批次限制输出 task 数，避免每个业务日产生大量 Parquet 小文件。
    write_partitions = max(1, int(os.environ.get("DWD_WRITE_PARTITIONS", "2")))
    selected.coalesce(write_partitions).write.mode("overwrite").insertInto(table)


def main(argv=None):
    parser = argparse.ArgumentParser(description="Hive ODS -> DWD PySpark 清洗")
    parser.add_argument("--load-date", required=True, help="ODS 装载分区，格式 yyyy-MM-dd")
    args = parser.parse_args(argv)

    spark = build_spark("ChargingPile-Hive-DWD", enable_hive=True)
    spark.sparkContext.setLogLevel("WARN")
    spark.conf.set("hive.exec.dynamic.partition", "true")
    spark.conf.set("hive.exec.dynamic.partition.mode", "nonstrict")

    session_raw, battery_raw, station_raw = _ods_sources(spark, args.load_date)
    if session_raw.limit(1).count() == 0:
        raise RuntimeError(f"ODS 订单分区为空：dt={args.load_date}")

    station = clean_station(spark, station_raw).cache()
    sessions, session_report = clean_sessions(spark, session_raw, station)
    battery, battery_report = clean_battery(spark, battery_raw, sessions, station)

    _write_partition(station, "charging_dwd.dwd_station", station.columns, args.load_date)
    _write_partition(sessions, "charging_dwd.dwd_charging_session", sessions.columns, args.load_date, True)
    _write_partition(battery, "charging_dwd.dwd_battery_detail", battery.columns, args.load_date, True)

    quality_rows = (
        [(stage, "订单", int(cnt)) for stage, cnt in session_report]
        + [(stage, "遥测", int(cnt)) for stage, cnt in battery_report]
    )
    quality = spark.createDataFrame(quality_rows, "stage string, data_type string, cnt long")
    _write_partition(quality, "charging_dwd.dwd_data_quality", quality.columns, args.load_date)

    print(f"[OK] Hive DWD 批次 {args.load_date}：有效订单={sessions.count()}，遥测={battery.count()}，站点={station.count()}")
    spark.stop()


if __name__ == "__main__":
    sys.exit(main())
