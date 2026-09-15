# -*- coding: utf-8 -*-
"""
一键执行 Spark 离线计算：数据清洗(ETL) -> 多维分析(ADS)

用法：
    python spark/jobs/run_all.py                     # 本地扩容数据（默认 data/raw_expanded）
    python spark/jobs/run_all.py --raw hdfs:///data/charging/raw --warehouse hdfs:///data/charging/warehouse
    SPARK_MASTER=yarn python spark/jobs/run_all.py   # 提交到 YARN（答辩环境）
"""

import argparse
import os
import sys
from datetime import datetime

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from analysis import build_ads  # noqa: E402
from etl_clean import (  # noqa: E402
    build_spark,
    clean_battery,
    clean_sessions,
    clean_station,
    save_quality_report,
    save_small_table,
    save_table,
)


def main(argv=None):
    parser = argparse.ArgumentParser(description="充电桩数据离线计算总入口")
    parser.add_argument("--raw", default="data/raw_expanded", help="原始数据目录（默认扩容数据，支持 hdfs://）")
    parser.add_argument("--warehouse", default="output/warehouse", help="清洗层输出目录")
    parser.add_argument("--ads", default="output/ads", help="分析层输出目录")
    parser.add_argument("--top-n", type=int, default=15, help="站点排行条数")
    args = parser.parse_args(argv)

    spark = build_spark("ChargingPile-Batch")
    spark.sparkContext.setLogLevel("WARN")

    raw = args.raw.rstrip("/")
    print("=" * 78)
    print("[1/2] 数据清洗 Spark ETL")
    print("=" * 78)
    station_dim = clean_station(spark, f"{raw}/nvv2t_md_end.csv")
    session_detail, session_report = clean_sessions(spark, f"{raw}/nvv2t.csv", station_dim)
    battery_detail, battery_report = clean_battery(spark, f"{raw}/dsv13r2.csv", session_detail, station_dim)
    save_table(station_dim, args.warehouse, "station_dim")
    save_table(session_detail, args.warehouse, "session_detail")
    save_table(battery_detail, args.warehouse, "battery_detail")
    report_rows = [(s, "订单", c) for s, c in session_report] + [(s, "遥测", c) for s, c in battery_report]
    save_quality_report(spark, args.warehouse, report_rows)
    save_quality_report(spark, args.ads, report_rows)
    for stage, cnt in session_report + battery_report:
        print(f"       - {stage}: {cnt}")

    print("=" * 78)
    print("[2/2] 多维统计分析 Spark ADS")
    print("=" * 78)
    build_ads(spark, args.warehouse, args.ads, args.top_n)

    # 记录本次作业的数据链路（计算引擎 / 存储位置），大屏顶部与 MySQL 均可见
    # 以 SparkContext 的实际 master 为准；spark-submit --master yarn 不一定会写入 SPARK_MASTER 环境变量。
    master = spark.sparkContext.master
    engine = "Spark on YARN" if master.lower().startswith("yarn") else f"Spark {master}"
    storage = "HDFS (Hadoop)" if "://" in args.raw and "file:" not in args.raw else "本地文件系统"
    info = [[
        datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        engine,
        storage,
        args.raw,
        args.warehouse,
        args.ads,
        int(session_detail.count()),
        int(battery_detail.count()),
        int(station_dim.count()),
        "Spark 清理 + 15 维分析；结果写入 %s 并装载 MySQL" % storage,
    ]]
    save_small_table(
        spark, args.ads, "ads_pipeline_info",
        header=["run_time", "engine", "storage", "raw_path", "warehouse_path", "ads_path",
                "valid_sessions", "battery_records", "station_cnt", "note"],
        rows=info,
        schema=("run_time string, engine string, storage string, raw_path string, warehouse_path string, "
                "ads_path string, valid_sessions long, battery_records long, station_cnt long, note string"),
    )

    spark.stop()
    print("全部 Spark 作业执行完成。")


if __name__ == "__main__":
    sys.exit(main())
