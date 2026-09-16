# -*- coding: utf-8 -*-
"""将 Hive ADS ORC 分区导出为供 MySQL 导入的管道符文本（先写 HDFS）。"""

import argparse
import sys

from pyspark.sql import SparkSession


# 顺序同时是 MySQL 导入顺序；表名在此白名单中，禁止由命令行任意拼接 SQL 标识符。
ADS_TABLES = (
    "ads_overview", "ads_daily_trend", "ads_monthly_trend", "ads_hour_load",
    "ads_weekday_hour_heat", "ads_station_top", "ads_facility_compare",
    "ads_weekend_compare", "ads_time_period_compare", "ads_platform_compare",
    "ads_district_compare", "ads_duration_dist", "ads_energy_dist", "ads_user_segment",
    "ads_battery_health", "ads_revenue_struct", "ads_realtime_sessions",
    "ads_data_quality", "ads_pipeline_info",
)


def main(argv=None):
    parser = argparse.ArgumentParser(description="ADS ORC -> HDFS pipe-delimited text")
    parser.add_argument("--load-date", required=True, help="ADS load_dt，例如 2026-09-16")
    parser.add_argument("--hdfs-export-root", required=True, help="HDFS 临时导出根目录")
    args = parser.parse_args(argv)

    spark = (
        SparkSession.builder.appName("ChargingPile-Ads-Orc-To-PipeText")
        .enableHiveSupport()
        .config("spark.sql.orc.compression.codec", "snappy")
        .getOrCreate()
    )
    spark.sparkContext.setLogLevel("WARN")
    root = args.hdfs_export_root.rstrip("/")

    for table in ADS_TABLES:
        source = f"charging_ads.{table}"
        target = f"{root}/{args.load_date}/{table}"
        frame = spark.table(source).where(f"load_dt = '{args.load_date}'").drop("load_dt")
        rows = frame.count()
        if rows == 0:
            raise RuntimeError(f"{source} 分区为空：load_dt={args.load_date}")
        (
            frame.coalesce(1).write.mode("overwrite")
            .option("header", "false")
            .option("sep", "|")
            .option("quote", '"')
            .option("escape", "\\")
            .option("nullValue", "\\N")
            .option("dateFormat", "yyyy-MM-dd")
            .option("timestampFormat", "yyyy-MM-dd HH:mm:ss")
            .csv(target)
        )
        print(f"[OK] {source}: {rows} 行 -> {target}", flush=True)
    spark.stop()


if __name__ == "__main__":
    sys.exit(main())
