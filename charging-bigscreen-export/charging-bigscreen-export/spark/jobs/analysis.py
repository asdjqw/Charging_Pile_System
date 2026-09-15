# -*- coding: utf-8 -*-
"""
充电桩运营数据分析作业（PySpark）

输入：etl_clean.py 产出的清洗宽表 output/warehouse/{session_detail, battery_detail, station_dim}
输出：output/ads/ 下 18 张分析结果表（供 Flask 读取 / 导入 MySQL 后由大屏展示）

分析维度（共 15 个，其中对比分析 5 组）：
   1. 运营总览 KPI                        ads_overview
   2. 日充电量趋势                        ads_daily_trend
   3. 月度充电量趋势                      ads_monthly_trend
   4. 24 小时充电负荷分布                 ads_hour_load
   5. 星期 × 小时充电热度                 ads_weekday_hour_heat
   6. 站点充电量 TOP N 排行               ads_station_top
   7. 行政区分布                          ads_district              【对比：区域/行政区】
   8. 站点类型对比（交流/直流/交直流/超充）ads_facility_compare      【对比分析 1】
   9. 工作日 vs 周末对比                  ads_weekend_compare       【对比分析 2】
  10. 峰平谷时段对比                      ads_time_period           【对比分析 3】
  11. 用户价值分层（RFM）                 ads_user_value / ads_user_segment
  12. 充电时长分布                        ads_duration_dist
  13. 单次充电量分布                      ads_energy_dist
  14. 充电功率分布 + 电池健康（SOC/压差/温升） ads_power_dist / ads_battery_health
  15. 收入结构与付费率 / 平台对比          ads_revenue_struct / ads_platform_compare  【对比分析 4、5】
  另：数据清洗质量报告 ads_data_quality、实时订单流水 ads_realtime_sessions
"""

import os
import sys

from pyspark.sql import SparkSession, Window
from pyspark.sql import functions as F

from etl_clean import build_spark, read_table

# 数据类型声明：使用 parquet 时无需转换；回退 CSV 时用于显式还原类型
SESSION_SCHEMA = {
    "kwh_total": "double", "charging_fees": "double", "charge_hours": "double",
    "avg_power_kw": "double", "price_per_kwh": "double", "is_fleet_vehicle": "int",
    "facility_type": "int", "created_ts": "timestamp", "ended_ts": "timestamp",
    "stat_date": "date", "stat_year": "int", "stat_month": "int", "start_hour": "int",
    "end_hour": "int", "weekday_num": "int", "is_weekend": "int", "device_count": "int",
}
BATTERY_SCHEMA = {
    "soc": "double", "pack_voltage": "double", "charge_current": "double",
    "charge_power_kw": "double", "max_cell_voltage": "double", "min_cell_voltage": "double",
    "cell_voltage_diff": "double", "max_temperature": "double", "min_temperature": "double",
    "temp_rise": "double", "available_energy": "double", "available_capacity": "double",
    "stat_date": "date",
}


def ensure_types(df, schema: dict):
    """CSV 回退场景下，把字符串列还原为声明的类型。"""
    types = dict(df.dtypes)
    for col_name, dtype in schema.items():
        if col_name in types and types[col_name] == "string":
            df = df.withColumn(col_name, F.col(col_name).cast(dtype))
    return df


def add_bin(df, col_name, edges, label_col="bin_label", order_col="bin_order"):
    """按区间分箱，返回带标签与排序号的 DataFrame。"""
    label_expr = None
    order_expr = None
    for idx, (low, high) in enumerate(zip(edges[:-1], edges[1:])):
        cond = (F.col(col_name) >= low) & (F.col(col_name) < high)
        label = f"{low:g}-{high:g}"
        label_expr = F.when(cond, F.lit(label)) if label_expr is None else label_expr.when(cond, F.lit(label))
        order_expr = F.when(cond, F.lit(idx)) if order_expr is None else order_expr.when(cond, F.lit(idx))
    return (
        df.withColumn(label_col, label_expr.otherwise(F.lit("其他")))
        .withColumn(order_col, order_expr.otherwise(F.lit(999)))
    )


def build_ads(spark: SparkSession, wh: str, ads_dir: str, top_n: int = 15):
    from etl_clean import save_table

    sessions = ensure_types(read_table(spark, wh, "session_detail"), SESSION_SCHEMA).cache()
    battery = ensure_types(read_table(spark, wh, "battery_detail"), BATTERY_SCHEMA).cache()

    def save(df, name):
        save_table(df, ads_dir, name)

    # ---------------- 1. 运营总览 KPI ----------------
    peak_row = sessions.groupBy("start_hour").agg(F.count("*").alias("c")).orderBy(F.desc("c")).first()
    kpi = sessions.agg(
        F.round(F.sum("kwh_total"), 2).alias("total_kwh"),
        F.count("*").alias("total_sessions"),
        F.round(F.sum("charging_fees"), 2).alias("total_revenue"),
        F.sum(F.when(F.col("charging_fees") > 0, 1).otherwise(0)).alias("paid_sessions"),
        F.countDistinct("station_id").alias("station_cnt"),
        F.countDistinct("user_id").alias("user_cnt"),
        F.countDistinct("stat_date").alias("active_days"),
        F.round(F.avg("kwh_total"), 2).alias("avg_kwh"),
        F.round(F.avg("charge_hours"), 2).alias("avg_hours"),
        F.round(F.avg("avg_power_kw"), 2).alias("avg_power"),
        F.round(F.sum(F.when(F.col("is_fleet_vehicle") == 1, 1).otherwise(0)) / F.count("*") * 100, 2).alias("fleet_rate"),
        F.min("stat_date").alias("start_date"),
        F.max("stat_date").alias("end_date"),
        F.round(F.max("avg_power_kw"), 2).alias("max_power"),
    ).withColumn("device_cnt", F.lit(0)).withColumn("paid_rate", F.round(F.col("paid_sessions") / F.col("total_sessions") * 100, 2))
    station_dim = read_table(spark, wh, "station_dim")
    device_cnt = station_dim.agg(F.sum(F.col("device_count").cast("int")).alias("d")).first()["d"]
    kpi = kpi.withColumn("device_cnt", F.lit(int(device_cnt or 0))).withColumn("peak_hour", F.lit(int(peak_row["start_hour"])))
    save(kpi, "ads_overview")

    # ---------------- 2. 日趋势 ----------------
    save(
        sessions.groupBy("stat_date")
        .agg(
            F.count("*").alias("sessions"),
            F.round(F.sum("kwh_total"), 2).alias("kwh"),
            F.round(F.sum("charging_fees"), 2).alias("revenue"),
            F.countDistinct("user_id").alias("users"),
            F.round(F.avg("kwh_total"), 2).alias("avg_kwh"),
        )
        .orderBy("stat_date"),
        "ads_daily_trend",
    )

    # ---------------- 3. 月度趋势 ----------------
    save(
        sessions.groupBy("stat_month_str")
        .agg(
            F.count("*").alias("sessions"),
            F.round(F.sum("kwh_total"), 2).alias("kwh"),
            F.round(F.sum("charging_fees"), 2).alias("revenue"),
            F.round(F.avg("kwh_total"), 2).alias("avg_kwh"),
            F.countDistinct("user_id").alias("users"),
        )
        .orderBy("stat_month_str"),
        "ads_monthly_trend",
    )

    # ---------------- 4. 24 小时负荷 ----------------
    hour_agg = (
        sessions.groupBy("start_hour")
        .agg(
            F.count("*").alias("sessions"),
            F.round(F.sum("kwh_total"), 2).alias("kwh"),
            F.round(F.avg("avg_power_kw"), 2).alias("avg_power"),
            F.round(F.avg("charge_hours"), 2).alias("avg_hours"),
        )
    )
    # 补齐 0-23 点，缺失小时按 0 处理，保证大屏 24 点曲线完整
    hour_load = (
        spark.range(0, 24)
        .select(F.col("id").cast("int").alias("start_hour"))
        .join(hour_agg, on="start_hour", how="left")
        .na.fill({"sessions": 0, "kwh": 0.0, "avg_power": 0.0, "avg_hours": 0.0})
        .orderBy("start_hour")
    )
    total_sessions = sessions.count()
    hour_load = hour_load.withColumn("sessions_pct", F.round(F.col("sessions") / total_sessions * 100, 2)).withColumn(
        "time_period",
        F.when(F.col("start_hour").isin(0, 1, 2, 3, 4, 5, 6, 23), "谷")
        .when(F.col("start_hour").isin(8, 9, 10, 11, 18, 19, 20), "峰")
        .otherwise("平"),
    )
    save(hour_load, "ads_hour_load")

    # ---------------- 5. 星期 × 小时热力图 ----------------
    save(
        sessions.groupBy("weekday_num", "weekday_cn", "start_hour")
        .agg(F.count("*").alias("sessions"), F.round(F.sum("kwh_total"), 2).alias("kwh"))
        .orderBy("weekday_num", "start_hour"),
        "ads_weekday_hour_heat",
    )

    # ---------------- 6. 站点 TOP N ----------------
    station_top = (
        sessions.groupBy("station_id", "station_name", "district", "road", "facility_type_cn", "device_count")
        .agg(
            F.count("*").alias("sessions"),
            F.round(F.sum("kwh_total"), 2).alias("kwh"),
            F.round(F.sum("charging_fees"), 2).alias("revenue"),
            F.round(F.avg("kwh_total"), 2).alias("avg_kwh"),
            F.round(F.avg("charge_hours"), 2).alias("avg_hours"),
            F.round(F.avg("avg_power_kw"), 2).alias("avg_power"),
            F.countDistinct("user_id").alias("users"),
        )
        .withColumn("orders_per_device", F.round(F.col("sessions") / F.col("device_count"), 2))
        .orderBy(F.desc("kwh"))
    )
    save(station_top.limit(top_n), "ads_station_top")
    save(station_top, "ads_station_all")

    # ---------------- 7. 行政区分布 ----------------
    district = sessions.groupBy("district").agg(
        F.count("*").alias("sessions"),
        F.round(F.sum("kwh_total"), 2).alias("kwh"),
        F.round(F.sum("charging_fees"), 2).alias("revenue"),
        F.round(F.avg("kwh_total"), 2).alias("avg_kwh"),
        F.countDistinct("station_id").alias("station_cnt"),
        F.countDistinct("user_id").alias("users"),
        F.max("device_count").alias("_unused"),
    ).drop("_unused")
    devices_by_district = (
        station_dim.withColumn("device_count", F.col("device_count").cast("int"))
        .groupBy("district")
        .agg(F.sum("device_count").alias("device_cnt"))
    )
    district = (
        district.join(devices_by_district, on="district", how="left")
        .withColumn("device_cnt", F.coalesce("device_cnt", F.lit(0)))
        .withColumn("kwh_pct", F.round(F.col("kwh") / F.sum("kwh").over(Window.partitionBy()) * 100, 2))
        .withColumn("orders_per_device", F.round(F.col("sessions") / F.col("device_cnt"), 2))
        .orderBy(F.desc("kwh"))
    )
    save(district, "ads_district")

    # ---------------- 8. 站点类型对比 ----------------
    facility = sessions.groupBy("facility_type", "facility_type_cn").agg(
        F.count("*").alias("sessions"),
        F.round(F.sum("kwh_total"), 2).alias("kwh"),
        F.round(F.sum("charging_fees"), 2).alias("revenue"),
        F.round(F.avg("kwh_total"), 2).alias("avg_kwh"),
        F.round(F.avg("charge_hours"), 2).alias("avg_hours"),
        F.round(F.avg("avg_power_kw"), 2).alias("avg_power"),
        F.countDistinct("user_id").alias("users"),
        F.round(F.sum(F.when(F.col("charging_fees") > 0, 1).otherwise(0)) / F.count("*") * 100, 2).alias("paid_rate"),
    )
    facility_stat = (
        station_dim.withColumn("device_count", F.col("device_count").cast("int"))
        .groupBy("facility_type_cn")
        .agg(F.countDistinct("station_id").alias("station_cnt"), F.sum("device_count").alias("device_cnt"))
    )
    facility = (
        facility.join(facility_stat, on="facility_type_cn", how="left")
        .withColumn("sessions_pct", F.round(F.col("sessions") / total_sessions * 100, 2))
        .withColumn("kwh_pct", F.round(F.col("kwh") / F.sum("kwh").over(Window.partitionBy()) * 100, 2))
        .withColumn("orders_per_device", F.round(F.col("sessions") / F.col("device_cnt"), 2))
        .orderBy(F.desc("kwh"))
    )
    save(facility, "ads_facility_compare")

    # ---------------- 9. 工作日 vs 周末对比 ----------------
    dt = sessions.groupBy("day_type").agg(
        F.countDistinct("stat_date").alias("days"),
        F.count("*").alias("sessions"),
        F.round(F.sum("kwh_total"), 2).alias("kwh"),
        F.round(F.sum("charging_fees"), 2).alias("revenue"),
        F.round(F.avg("kwh_total"), 2).alias("avg_kwh"),
        F.round(F.avg("charge_hours"), 2).alias("avg_hours"),
        F.round(F.avg("avg_power_kw"), 2).alias("avg_power"),
        F.countDistinct("user_id").alias("users"),
    )
    peak_by_dt = (
        sessions.groupBy("day_type", "start_hour")
        .agg(F.count("*").alias("c"))
        .withColumn("rk", F.row_number().over(Window.partitionBy("day_type").orderBy(F.desc("c"))))
        .filter(F.col("rk") == 1)
        .select("day_type", F.col("start_hour").alias("peak_hour"))
    )
    dt = (
        dt.join(peak_by_dt, on="day_type")
        .withColumn("sessions_per_day", F.round(F.col("sessions") / F.col("days"), 2))
        .withColumn("kwh_per_day", F.round(F.col("kwh") / F.col("days"), 2))
        .withColumn("users_per_day", F.round(F.col("users") / F.col("days"), 2))
    )
    save(dt, "ads_weekend_compare")

    # ---------------- 10. 峰平谷时段对比 ----------------
    period = sessions.groupBy("time_period").agg(
        F.count("*").alias("sessions"),
        F.round(F.sum("kwh_total"), 2).alias("kwh"),
        F.round(F.sum("charging_fees"), 2).alias("revenue"),
        F.round(F.avg("kwh_total"), 2).alias("avg_kwh"),
        F.round(F.avg("charge_hours"), 2).alias("avg_hours"),
    )
    period = period.withColumn("sessions_pct", F.round(F.col("sessions") / total_sessions * 100, 2)).withColumn(
        "kwh_pct", F.round(F.col("kwh") / F.sum("kwh").over(Window.partitionBy()) * 100, 2)
    )
    save(period, "ads_time_period")

    # ---------------- 11. 用户价值分层（RFM） ----------------
    max_date = sessions.agg(F.max("stat_date")).first()[0]
    users = sessions.groupBy("user_id").agg(
        F.count("*").alias("sessions"),
        F.round(F.sum("kwh_total"), 2).alias("kwh"),
        F.round(F.sum("charging_fees"), 2).alias("revenue"),
        F.round(F.avg("kwh_total"), 2).alias("avg_kwh"),
        F.countDistinct("stat_date").alias("active_days"),
        F.min("stat_date").alias("first_date"),
        F.max("stat_date").alias("last_date"),
        F.round(F.avg("charge_hours"), 2).alias("avg_hours"),
    ).withColumn("recency_days", F.datediff(F.lit(max_date), F.col("last_date")))

    def score(col_name, reverse=False):
        q = users.approxQuantile(col_name, [0.33, 0.66], 0.05)
        lo, hi = (q[0], q[1]) if len(q) == 2 else (0.0, 0.0)
        if reverse:  # 数值越小越好（如最近活跃间隔）
            return F.when(F.col(col_name) <= lo, 3).when(F.col(col_name) <= hi, 2).otherwise(1).cast("int")
        return F.when(F.col(col_name) >= hi, 3).when(F.col(col_name) >= lo, 2).otherwise(1).cast("int")

    users = (
        users.withColumn("r_score", score("recency_days", reverse=True))
        .withColumn("f_score", score("sessions"))
        .withColumn("m_score", score("kwh"))
        .withColumn("rfm_score", F.col("r_score") + F.col("f_score") + F.col("m_score"))
        .withColumn(
            "segment",
            F.when(F.col("rfm_score") >= 8, "高价值用户")
            .when(F.col("rfm_score") >= 6, "核心用户")
            .when(F.col("rfm_score") >= 4, "潜力用户")
            .otherwise("流失风险用户"),
        )
    )
    save(users.orderBy(F.desc("kwh")), "ads_user_value")
    seg = (
        users.groupBy("segment")
        .agg(
            F.count("*").alias("user_cnt"),
            F.sum("sessions").alias("sessions"),
            F.round(F.sum("kwh"), 2).alias("kwh"),
            F.round(F.avg("sessions"), 2).alias("avg_sessions"),
            F.round(F.avg("kwh"), 2).alias("avg_kwh"),
        )
        .withColumn("user_pct", F.round(F.col("user_cnt") / users.count() * 100, 2))
        .withColumn("kwh_pct", F.round(F.col("kwh") / F.sum("kwh").over(Window.partitionBy()) * 100, 2))
        .orderBy(F.desc("kwh"))
    )
    save(seg, "ads_user_segment")

    # ---------------- 12/13. 充电时长 / 单次电量分布 ----------------
    duration = add_bin(sessions, "charge_hours", [0, 0.5, 1, 2, 4, 8, 12])
    duration = (
        duration.groupBy("bin_label", "bin_order").agg(F.count("*").alias("sessions"), F.round(F.sum("kwh_total"), 2).alias("kwh"))
        .withColumn("pct", F.round(F.col("sessions") / total_sessions * 100, 2))
        .orderBy("bin_order")
    )
    save(duration, "ads_duration_dist")

    energy = add_bin(sessions, "kwh_total", [0, 2, 4, 6, 8, 12, 16, 40])
    energy = (
        energy.groupBy("bin_label", "bin_order").agg(F.count("*").alias("sessions"), F.round(F.sum("kwh_total"), 2).alias("kwh"))
        .withColumn("pct", F.round(F.col("sessions") / total_sessions * 100, 2))
        .orderBy("bin_order")
    )
    save(energy, "ads_energy_dist")

    battery_cnt = battery.count()

    # ---------------- 14. 充电功率分布 + 电池健康 ----------------
    power = add_bin(battery, "charge_power_kw", [0, 6, 7, 7.5, 8, 10, 15, 25])
    power = (
        power.groupBy("bin_label", "bin_order")
        .agg(F.count("*").alias("samples"), F.round(F.avg("charge_power_kw"), 2).alias("avg_power"))
        .withColumn("pct", F.round(F.col("samples") / battery_cnt * 100, 2))
        .orderBy("bin_order")
    )
    save(power, "ads_power_dist")

    health = (
        battery.groupBy("soc_bin")
        .agg(
            F.count("*").alias("samples"),
            F.round(F.avg("charge_power_kw"), 2).alias("avg_power"),
            F.round(F.avg("pack_voltage"), 2).alias("avg_voltage"),
            F.round(F.avg("cell_voltage_diff") * 1000, 2).alias("avg_cell_diff_mv"),
            F.round(F.avg("temp_rise"), 2).alias("avg_temp_rise"),
            F.round(F.avg("max_temperature"), 2).alias("avg_max_temp"),
            F.round(F.avg("available_energy"), 2).alias("avg_available_energy"),
            F.round(F.avg("available_capacity"), 2).alias("avg_available_capacity"),
        )
        .orderBy("soc_bin")
    )
    save(health, "ads_battery_health")

    save(
        battery.groupBy("facility_type_cn")
        .agg(
            F.count("*").alias("samples"),
            F.round(F.avg("charge_power_kw"), 2).alias("avg_power"),
            F.round(F.avg("soc"), 2).alias("avg_soc"),
            F.round(F.avg("cell_voltage_diff") * 1000, 2).alias("avg_cell_diff_mv"),
            F.round(F.avg("temp_rise"), 2).alias("avg_temp_rise"),
        )
        .orderBy(F.desc("samples")),
        "ads_battery_type_compare",
    )

    # ---------------- 15. 收入结构 / 平台对比 ----------------
    def revenue_struct(df, dim_type, name_col):
        return df.groupBy(name_col).agg(
            F.count("*").alias("sessions"),
            F.round(F.sum("kwh_total"), 2).alias("kwh"),
            F.round(F.sum("charging_fees"), 2).alias("revenue"),
            F.sum(F.when(F.col("charging_fees") > 0, 1).otherwise(0)).alias("paid_sessions"),
        ).withColumn("paid_rate", F.round(F.col("paid_sessions") / F.col("sessions") * 100, 2)).withColumn(
            "avg_price", F.round(F.col("revenue") / F.col("kwh"), 3)
        ).withColumn("dim_type", F.lit(dim_type)).withColumnRenamed(name_col, "dim_name")

    revenue = (
        revenue_struct(sessions, "站点类型", "facility_type_cn")
        .unionByName(revenue_struct(sessions, "行政区", "district"))
        .unionByName(revenue_struct(sessions, "平台", "platform"))
        .unionByName(revenue_struct(sessions, "日期类型", "day_type"))
        .unionByName(revenue_struct(sessions, "峰平谷", "time_period"))
        .orderBy("dim_type", F.desc("revenue"))
    )
    save(revenue, "ads_revenue_struct")

    platform = sessions.groupBy("platform").agg(
        F.count("*").alias("sessions"),
        F.countDistinct("user_id").alias("users"),
        F.round(F.sum("kwh_total"), 2).alias("kwh"),
        F.round(F.sum("charging_fees"), 2).alias("revenue"),
        F.round(F.avg("kwh_total"), 2).alias("avg_kwh"),
        F.round(F.avg("charge_hours"), 2).alias("avg_hours"),
        F.round(F.avg("avg_power_kw"), 2).alias("avg_power"),
    ).withColumn("sessions_pct", F.round(F.col("sessions") / total_sessions * 100, 2)).orderBy(F.desc("sessions"))
    save(platform, "ads_platform_compare")

    # ---------------- 其他：实时订单流水 ----------------
    save(
        sessions.orderBy(F.desc("created_ts"))
        .select(
            F.date_format("created_ts", "yyyy-MM-dd HH:mm:ss").alias("created_time"),
            "station_name",
            "district",
            F.col("facility_type_cn").alias("facility_type_cn"),
            "platform",
            "kwh_total",
            "charging_fees",
            "charge_hours",
            "time_period",
        )
        .limit(50),
        "ads_realtime_sessions",
    )

    # ---------------- 明细表落 MySQL 供后端灵活查询 ----------------
    save(
        sessions.select(
            "session_id", "user_id", "station_id", "kwh_total", "charging_fees", "charge_hours",
            "avg_power_kw", "price_per_kwh", "is_fleet_vehicle", "facility_type", "facility_type_cn",
            "platform", F.date_format("created_ts", "yyyy-MM-dd HH:mm:ss").alias("created_time"),
            "stat_date", "stat_year", "stat_month", "stat_month_str", "start_hour", "weekday_cn",
            "day_type", "time_period", "station_name", "district", "road", "device_count",
        ),
        "mysql_session_detail",
    )
    save(
        battery.select(
            "session_id", "soc", "soc_bin", "pack_voltage", "charge_current", "charge_power_kw",
            "max_cell_voltage", "min_cell_voltage", "cell_voltage_diff", "max_temperature",
            "min_temperature", "temp_rise", "available_energy", "available_capacity",
            "district", "facility_type_cn", "day_type", "time_period",
        ),
        "mysql_battery_detail",
    )
    save(
        station_dim.select(
            "station_id", "location_id", "station_name", "address", "district", "road",
            F.col("device_count").cast("int").alias("device_count"), "facility_type", "facility_type_cn", "open_time",
        ),
        "mysql_station_dim",
    )
    print(f"[ADS] 分析完成，输出目录：{ads_dir}")


def main(argv=None):
    import argparse

    parser = argparse.ArgumentParser(description="充电桩运营数据分析（Spark）")
    parser.add_argument("--warehouse", default="output/warehouse", help="清洗后宽表目录")
    parser.add_argument("--out", default="output/ads", help="分析结果输出目录")
    parser.add_argument("--top-n", type=int, default=15, help="站点排行条数")
    args = parser.parse_args(argv)

    spark = build_spark("ChargingPile-Analysis")
    spark.sparkContext.setLogLevel("WARN")
    build_ads(spark, args.warehouse, args.out, args.top_n)
    spark.stop()


if __name__ == "__main__":
    sys.exit(main())
