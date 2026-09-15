# -*- coding: utf-8 -*-
"""
充电桩运营数据清洗作业（PySpark）

输入（本地目录或 HDFS）：
    nvv2t.csv        充电订单明细     3395 条（会话、电量、金额、时间、站点、用户、平台）
    dsv13r2.csv      电池充电遥测明细 1594 条（SOC、电压、电流、单体电压、温度、可用能量）
    nvv2t_md_end.csv 充电站维度表     105 条（站名、地址、设备数、开放时间）

输出：output/warehouse/ 下的三张清洗后宽表 + 数据质量报告（写入 MySQL 供大屏展示）
    session_detail   订单宽表（已关联站点维度、已剔除异常订单）
    battery_detail   遥测宽表（已关联订单与站点维度，派生电池健康指标）
    station_dim      充电站维度表
    ads_data_quality 清洗过程数据质量报告

清洗规则见 README 与代码内注释，核心为：
    1) 时间字段年份缺失 2000 的还原（原始数据 created/ended 为 "0014-11-18"，实际为 2014-11-18，
       已用星期字段 weekday 交叉验证：修正后 3395/3395 条星期完全一致）
    2) 业务主键去重、空值校验
    3) 数值字段规范化（电流统一为幅值、金额/电量/时长转 double）
    4) 异常订单剔除（0 电量、超长时长、电量越界）
    5) 维度关联与解析（行政区、道路、站点类型）
    6) 派生运营/电池指标（峰谷时段、是否周末、平均功率、单体压差、温升等）
"""

import os
import sys
import csv as csv_module

from pyspark.sql import SparkSession, Window
from pyspark.sql import functions as F

# ----------------------------------------------------------------------------
# 常量定义
# ----------------------------------------------------------------------------
WEEKDAY_CN = {1: "周日", 2: "周一", 3: "周二", 4: "周三", 5: "周四", 6: "周五", 7: "周六"}

# 站点类型编码 -> 中文（已与 station_name 中的"交流/直流/交直流/超充"关键字交叉验证，105/105 一致）
FACILITY_TYPE_MAP = {"1": "交流充电站", "2": "直流充电站", "3": "交直流充电站", "4": "超充站"}

# 订单有效范围（用于异常值剔除）
KWH_MIN, KWH_MAX = 0.0, 40.0        # 单次充电量 kWh（数据最大值 23.68，40 为业务上限）
HOURS_MIN, HOURS_MAX = 0.0, 12.0     # 单次充电时长（原始存在 55.2 小时的异常记录）

# 简化的峰平谷时段划分（按小时，参考河南工商业分时电价）
PEAK_HOURS = {8, 9, 10, 11, 18, 19, 20}      # 高峰 08:30-11:30 / 18:00-21:00
VALLEY_HOURS = {0, 1, 2, 3, 4, 5, 6, 23}     # 低谷 23:00-次日 07:00


def build_spark(app_name: str, enable_hive: bool = False) -> SparkSession:
    """创建（或复用）SparkSession，本地模式与 YARN/HDFS 环境通用。"""
    builder = (
        SparkSession.builder.appName(app_name)
        .config("spark.sql.shuffle.partitions", os.environ.get("SPARK_SHUFFLE_PARTITIONS", "8"))
        .config("spark.sql.session.timeZone", "Asia/Shanghai")
        .config("spark.sql.parquet.compression.codec", "snappy")
        .config("spark.sql.sources.partitionOverwriteMode", "dynamic")
        .config("spark.ui.showConsoleProgress", "false")
        .config("spark.sql.warehouse.dir", "spark-warehouse")
    )
    # 答辩环境通过 SPARK_MASTER=yarn 切换为 Spark on YARN（默认本地模式）
    master = os.environ.get("SPARK_MASTER")
    if master:
        builder = builder.master(master)
    if os.name == "nt":  # Windows 本地调试时固定 driver 地址，避免 hostname 反解失败
        builder = builder.config("spark.driver.host", "127.0.0.1").config("spark.driver.bindAddress", "127.0.0.1")
    if enable_hive:
        builder = builder.enableHiveSupport()
    return builder.getOrCreate()


def _read_csv(spark: SparkSession, path: str, header: bool = True):
    """统一读取 CSV：自动推断表头，全部按字符串读入后由清洗逻辑显式转换类型。"""
    return (
        spark.read.option("header", header)
        .option("inferSchema", "false")
        .option("encoding", "UTF-8")
        .option("multiLine", "false")
        .option("escape", '"')
        .csv(path)
    )


def _read_source(spark: SparkSession, source):
    """兼容原 CSV 路径和 Hive ODS DataFrame，保证本地链路与数仓链路共用清洗规则。"""
    return _read_csv(spark, source) if isinstance(source, str) else source


# ----------------------------------------------------------------------------
# 一、时间修复与派生
# ----------------------------------------------------------------------------
def fix_timestamp(col_name: str):
    """
    修复年份：原始 "0014-11-18 15:40:26" 中的年份被抹掉了高两位（实际 2014-11-18），
    这里统一 +2000 再解析为标准 timestamp。
    """
    year = F.substring(F.col(col_name), 1, 4).cast("int") + 2000
    tail = F.substring(F.col(col_name), 5, 100)          # "-11-18 15:40:26"
    return F.to_timestamp(F.concat(F.lpad(year.cast("string"), 4, "0"), tail), "yyyy-MM-dd HH:mm:ss")


def time_period_expr(hour_col):
    """峰平谷时段：0-6/23 谷，8-11/18-20 峰，其余平。"""
    return (
        F.when(F.col(hour_col).isin(*sorted(VALLEY_HOURS)), F.lit("谷"))
        .when(F.col(hour_col).isin(*sorted(PEAK_HOURS)), F.lit("峰"))
        .otherwise(F.lit("平"))
    )


# ----------------------------------------------------------------------------
# 二、订单数据清洗
# ----------------------------------------------------------------------------
def clean_sessions(spark: SparkSession, raw_path, station_dim):
    raw = _read_source(spark, raw_path)
    raw_cnt = raw.count()

    # 1) 去重 + 空值校验（业务主键 sessionId）
    dedup = raw.dropDuplicates(["sessionId"])
    dedup_cnt = dedup.count()
    null_cnt = dedup.filter(
        F.col("sessionId").isNull()
        | F.col("userId").isNull()
        | F.col("stationId").isNull()
        | F.col("created").isNull()
    ).count()
    non_null = dedup.dropna(subset=["sessionId", "userId", "stationId", "created", "ended"])

    # 2) 时间修复 + 时间维度派生
    ts = (
        non_null.withColumn("created_ts", fix_timestamp("created"))
        .withColumn("ended_ts", fix_timestamp("ended"))
        .withColumn("kwh_total", F.col("kwhTotal").cast("double"))
        .withColumn("charging_fees", F.col("charging_fees").cast("double"))
        .withColumn("charge_hours", F.col("chargeTimeHrs").cast("double"))
        .withColumn("start_hour", F.col("startTime").cast("int"))
        .withColumn("end_hour", F.col("endTime").cast("int"))
        .withColumn("weekday_num", F.dayofweek("created_ts"))  # 1=周日 ... 7=周六
    )

    # 3) 一致性校验：原始 Mon..Sun 独热列与 created 日期星期是否一致（全部一致，故只保留统计值）
    weekday_cols = ["Mon", "Tues", "Wed", "Thurs", "Fri", "Sat", "Sun"]
    # 注意：Spark dayofweek 为 1=周日 ... 7=周六，而独热列顺序为 周一...周日，需要做一次序号映射
    onehot_day = F.coalesce(
        *[F.when(F.col(c) == "1", F.lit(((i + 1) % 7) + 1)) for i, c in enumerate(weekday_cols)]
    )
    onehot_ok = ts.filter(onehot_day == F.col("weekday_num")).count()

    # 4) 异常值标记（不直接删除，先打标便于质量报告统计）
    flagged = (
        ts.withColumn(
            "invalid_reason",
            F.concat_ws(
                ";",
                F.when(F.col("kwh_total").isNull() | (F.col("kwh_total") <= KWH_MIN), F.lit("电量为0或缺失")),
                F.when(F.col("kwh_total") > KWH_MAX, F.lit("电量越界")),
                F.when(F.col("charge_hours").isNull() | (F.col("charge_hours") <= HOURS_MIN), F.lit("时长为0或缺失")),
                F.when(F.col("charge_hours") > HOURS_MAX, F.lit("时长异常(>12h)")),
                F.when(F.col("charging_fees") < 0, F.lit("金额为负")),
            ),
        )
        .withColumn("is_valid", F.when(F.length("invalid_reason") == 0, F.lit(1)).otherwise(F.lit(0)))
    )
    invalid_cnt = flagged.filter(F.col("is_valid") == 0).count()

    # 5) 维度关联 + 站点属性解析
    joined = (
        flagged.filter(F.col("is_valid") == 1)
        .join(station_dim, flagged.stationId == station_dim.station_id, how="left")
        .drop("station_id")
        .withColumn("avg_power_kw", F.round(F.col("kwh_total") / F.col("charge_hours"), 3))
        .withColumn("price_per_kwh", F.round(F.col("charging_fees") / F.col("kwh_total"), 3))
        .withColumn("weekday_cn", F.element_at(F.create_map(*[F.lit(x) for kv in WEEKDAY_CN.items() for x in kv]), F.col("weekday_num")))
        .withColumn("is_weekend", F.when(F.col("weekday_num").isin(1, 7), F.lit(1)).otherwise(F.lit(0)))
        .withColumn("day_type", F.when(F.col("weekday_num").isin(1, 7), F.lit("周末")).otherwise(F.lit("工作日")))
        .withColumn("time_period", time_period_expr("start_hour"))
        .withColumn("stat_date", F.to_date("created_ts"))
    )

    detail = joined.select(
        F.col("sessionId").alias("session_id"),
        F.col("userId").alias("user_id"),
        F.col("stationId").alias("station_id"),
        F.col("locationId").alias("location_id"),
        "kwh_total",
        "charging_fees",
        "charge_hours",
        "avg_power_kw",
        "price_per_kwh",
        F.col("managerVehicle").cast("int").alias("is_fleet_vehicle"),
        F.col("facilityType").cast("int").alias("facility_type"),
        "facility_type_cn",
        "platform",
        "created_ts",
        "ended_ts",
        "stat_date",
        F.year("created_ts").alias("stat_year"),
        F.month("created_ts").alias("stat_month"),
        F.date_format("created_ts", "yyyy-MM").alias("stat_month_str"),
        "start_hour",
        "end_hour",
        "weekday_num",
        "weekday_cn",
        "is_weekend",
        "day_type",
        "time_period",
        "station_name",
        "address",
        "district",
        "road",
        "device_count",
    ).cache()

    report = [
        ("原始订单记录", raw_cnt),
        ("业务主键去重后", dedup_cnt),
        ("主键/关键字段为空", null_cnt),
        ("异常订单剔除", invalid_cnt),
        ("有效订单记录", detail.count()),
        ("星期字段一致性校验通过", onehot_ok),
    ]
    return detail, report


# ----------------------------------------------------------------------------
# 三、电池遥测数据清洗
# ----------------------------------------------------------------------------
def clean_battery(spark: SparkSession, raw_path, session_detail, station_dim):
    raw = _read_source(spark, raw_path)
    raw_cnt = raw.count()
    dedup = raw.dropDuplicates()                       # 全字段去重
    dedup_cnt = dedup.count()

    cleaned = (
        dedup.withColumn("soc", F.col("soc").cast("double"))
        .withColumn("pack_voltage", F.col("pack_voltage (V)").cast("double"))
        # 原始电流为负值（充电方向约定），统一取幅值
        .withColumn("charge_current", F.abs(F.col("charge_current (A)").cast("double")))
        .withColumn("max_cell_voltage", F.col("max_cell_voltage (V)").cast("double"))
        .withColumn("min_cell_voltage", F.col("min_cell_voltage (V)").cast("double"))
        .withColumn("max_temperature", F.col("max_temperature (℃)").cast("double"))
        .withColumn("min_temperature", F.col("min_temperature (℃)").cast("double"))
        .withColumn("available_energy", F.col("available_energy (kw)").cast("double"))
        .withColumn("available_capacity", F.col("available_capacity (Ah)").cast("double"))
        # 派生电池健康 / 充电特征指标
        .withColumn("charge_power_kw", F.round(F.col("pack_voltage") * F.col("charge_current") / 1000, 3))
        .withColumn("cell_voltage_diff", F.round(F.col("max_cell_voltage") - F.col("min_cell_voltage"), 4))
        .withColumn("temp_rise", F.col("max_temperature") - F.col("min_temperature"))
        .withColumn("soc_bin", F.concat(F.floor(F.col("soc") / 10).cast("int") * 10, F.lit("-"), (F.floor(F.col("soc") / 10).cast("int") * 10 + 10)))
        .withColumn("sessionId", F.col("esd"))
    )

    # 遥测记录通过 esd = sessionId 关联订单宽表，补齐站点/时间/类型信息（未匹配的记为未知）
    joined = (
        cleaned.join(
            session_detail.select(
                "session_id", "station_id", "district", "facility_type_cn", "day_type", "time_period", "stat_date"
            ),
            cleaned.sessionId == session_detail.session_id,
            how="left",
        )
        .drop("session_id")
        .withColumn("station_id", F.coalesce("station_id", F.lit("unknown")))
        .withColumn("district", F.coalesce("district", F.lit("未知")))
        .withColumn("facility_type_cn", F.coalesce("facility_type_cn", F.lit("未知")))
    )

    detail = joined.select(
        F.col("sessionId").alias("session_id"),
        "soc",
        "soc_bin",
        "pack_voltage",
        "charge_current",
        "charge_power_kw",
        "max_cell_voltage",
        "min_cell_voltage",
        "cell_voltage_diff",
        "max_temperature",
        "min_temperature",
        "temp_rise",
        "available_energy",
        "available_capacity",
        "station_id",
        "district",
        "facility_type_cn",
        "day_type",
        "time_period",
        "stat_date",
    ).cache()

    matched = detail.filter(F.col("district") != "未知").count()
    report = [
        ("原始遥测记录", raw_cnt),
        ("全字段去重后", dedup_cnt),
        ("可关联订单的遥测记录", matched),
        # record_time 原始值全部为科学计数法 "2.02E+13"（有效数字丢失），不可用于时间分析，已丢弃
        ("丢弃的无效字段(record_time 精度丢失)", raw_cnt),
    ]
    return detail, report


# ----------------------------------------------------------------------------
# 四、站点维度表清洗
# ----------------------------------------------------------------------------
def clean_station(spark: SparkSession, raw_path):
    raw = _read_source(spark, raw_path)
    dim = (
        raw.dropDuplicates(["stationId"])
        .withColumn("device_count", F.col("device_count").cast("int"))
        .withColumn("facility_type", F.col("facilityType").cast("int"))
        .withColumn("facility_type_cn", F.col("facilityType").cast("int").cast("string"))
        # 站名形如 "高新区科学大道·交直流充电站1号"，解析出行政区与道路
        .withColumn("district", F.regexp_extract("station_name", r"^([^·]*(区|新区))", 1))
        .withColumn("road", F.regexp_extract("station_name", r"^(?:[^·]*?(?:区|新区))([^·]*)·", 1))
        .withColumn("open_time", F.coalesce("open_time", F.lit("00:00-24:00")))
        .withColumn("update_time", F.to_date("update_time", "yyyy/M/d"))
    )
    facility_map = F.create_map(*[F.lit(x) for kv in FACILITY_TYPE_MAP.items() for x in kv])
    dim = dim.withColumn("facility_type_cn", F.element_at(facility_map, F.col("facility_type").cast("string")))
    return dim.select(
        F.col("stationId").alias("station_id"),
        F.col("locationId").alias("location_id"),
        "station_name",
        "address",
        "district",
        "road",
        "device_count",
        "facility_type",
        "facility_type_cn",
        "open_time",
        "update_time",
    )


# ----------------------------------------------------------------------------
# 落盘 / 读取工具
#   - 优先写出 parquet（HDFS 场景），同时总是产出单文件 CSV，便于导入 MySQL
#   - Windows 本地调试若缺少 winutils，自动回退为驱动端写出，保证流程可跑通
# ----------------------------------------------------------------------------
def save_table(df, out_dir: str, name: str, partitions: int = 1):
    """
    写出结果表：
        - 本地目录（测试）：<out_dir>/<name>.csv 单文件 + <name>.parquet，供直接装载 MySQL
        - HDFS 目录（答辩）：<out_dir>/<name>.parquet + <out_dir>/<name>.csv_dir/（由 hdfs dfs -getmerge 取回）
    """
    df_to_write = df.coalesce(partitions) if df.rdd.getNumPartitions() > partitions else df
    remote = "://" in out_dir
    csv_path = os.path.join(out_dir, name + ".csv").replace("\\", "/")
    tmp_dir = os.path.join(out_dir, f"_tmp_{name}").replace("\\", "/")

    try:
        df_to_write.write.mode("overwrite").parquet(os.path.join(out_dir, name + ".parquet").replace("\\", "/"))
        print(f"[OK] parquet -> {name}.parquet")
    except Exception as exc:
        print(f"[WARN] parquet 写出跳过（{exc.__class__.__name__}：常见于 Windows 缺少 winutils）")

    if remote:
        # HDFS 场景：CSV 由 Spark 直接写到 HDFS 目录，后续用 hdfs dfs -getmerge 取回本地
        try:
            df_to_write.write.mode("overwrite").option("header", True).csv(f"{csv_path}_dir")
            print(f"[OK] hdfs csv dir -> {name}.csv_dir")
        except Exception as exc:
            print(f"[WARN] HDFS CSV 写出失败（{exc.__class__.__name__}）")
        return csv_path

    try:
        df_to_write.write.mode("overwrite").option("header", True).csv(tmp_dir)
        import glob
        import shutil

        parts = [p for p in glob.glob(os.path.join(tmp_dir, "part-*.csv")) if not p.endswith(".crc")]
        if parts:
            shutil.copyfile(parts[0], csv_path)
        else:
            raise FileNotFoundError("未找到 part 文件")
        shutil.rmtree(tmp_dir, ignore_errors=True)
    except Exception as exc:
        print(f"[WARN] Spark 单文件写出失败（{exc.__class__.__name__}），改用驱动端写出")
        rows = df_to_write.collect()
        with open(csv_path, "w", newline="", encoding="utf-8") as fh:
            writer = csv_module.writer(fh)
            writer.writerow(df_to_write.columns)
            for row in rows:
                writer.writerow(["" if value is None else value for value in row])
    print(f"[OK] csv -> {csv_path}")
    return csv_path


def read_table(spark: SparkSession, out_dir: str, name: str):
    """读取清洗结果：优先 parquet，回退单文件 CSV。"""
    parquet_path = os.path.join(out_dir, name + ".parquet").replace("\\", "/")
    csv_path = os.path.join(out_dir, name + ".csv").replace("\\", "/")
    if "://" in out_dir:  # HDFS：直接读取 parquet 目录
        try:
            return spark.read.parquet(parquet_path)
        except Exception:
            return _read_csv(spark, f"{csv_path}_dir")
    if os.path.isdir(parquet_path):
        try:
            return spark.read.parquet(parquet_path)
        except Exception:
            pass
    return _read_csv(spark, csv_path)


def save_rows(out_dir: str, name: str, header, rows):
    """写出小体量结果表（数据质量报告等），避免依赖 Python Worker（Windows 本地调试更稳定）。"""
    os.makedirs(out_dir, exist_ok=True)
    path = os.path.join(out_dir, name + ".csv")
    with open(path, "w", newline="", encoding="utf-8") as fh:
        writer = csv_module.writer(fh)
        writer.writerow(header)
        writer.writerows(rows)
    print(f"[OK] csv -> {path}")
    return path


def save_small_table(spark: SparkSession, out_dir: str, name: str, header, rows, schema: str):
    """
    写出小体量结果表（数据质量报告、作业元信息等）：
        - HDFS：Spark 直接写 CSV 目录，后续用 hdfs dfs -getmerge 取回
        - 本地：优先 Spark 写单文件，失败（Windows 缺 winutils / 无 Python Worker）则驱动端写出
    """
    csv_path = os.path.join(out_dir, name + ".csv").replace("\\", "/")
    if "://" in out_dir:
        df = spark.createDataFrame(rows, schema)
        df.coalesce(1).write.mode("overwrite").option("header", True).csv(f"{csv_path}_dir")
        print(f"[OK] hdfs csv dir -> {name}.csv_dir")
        return f"{csv_path}_dir"
    tmp_dir = os.path.join(out_dir, f"_tmp_{name}").replace("\\", "/")
    try:
        import glob
        import shutil

        df = spark.createDataFrame(rows, schema)
        df.coalesce(1).write.mode("overwrite").option("header", True).csv(tmp_dir)
        parts = [p for p in glob.glob(os.path.join(tmp_dir, "part-*.csv")) if not p.endswith(".crc")]
        if not parts:
            raise FileNotFoundError("未找到 part 文件")
        shutil.copyfile(parts[0], csv_path)
        shutil.rmtree(tmp_dir, ignore_errors=True)
        print(f"[OK] csv -> {csv_path}")
    except Exception as exc:
        print(f"[WARN] Spark 写出失败（{exc.__class__.__name__}），改用驱动端写出")
        save_rows(out_dir, name, header, rows)
    return csv_path


def save_quality_report(spark: SparkSession, out_dir: str, rows):
    """数据质量报告（各清洗阶段的记录数）。"""
    return save_small_table(
        spark, out_dir, "ads_data_quality",
        header=["stage", "data_type", "cnt"], rows=rows,
        schema="stage string, data_type string, cnt long",
    )


def main(argv=None):
    import argparse

    parser = argparse.ArgumentParser(description="充电桩运营数据清洗（Spark）")
    parser.add_argument("--raw", default="data/raw_expanded", help="原始数据目录（默认扩容数据，本地路径或 hdfs:// 路径）")
    parser.add_argument("--out", default="output/warehouse", help="清洗结果输出目录")
    args = parser.parse_args(argv)

    spark = build_spark("ChargingPile-ETL-Clean")
    spark.sparkContext.setLogLevel("WARN")

    raw = args.raw.rstrip("/")
    print(f"[ETL] 读取原始数据：{raw}")
    station_dim = clean_station(spark, f"{raw}/nvv2t_md_end.csv")
    session_detail, session_report = clean_sessions(spark, f"{raw}/nvv2t.csv", station_dim)
    battery_detail, battery_report = clean_battery(spark, f"{raw}/dsv13r2.csv", session_detail, station_dim)

    save_table(station_dim, args.out, "station_dim")
    save_table(session_detail, args.out, "session_detail")
    save_table(battery_detail, args.out, "battery_detail")

    # 数据质量报告（大屏"数据清洗质量"面板数据源）
    report_rows = (
        [(stage, "订单", cnt) for stage, cnt in session_report]
        + [(stage, "遥测", cnt) for stage, cnt in battery_report]
    )
    save_quality_report(spark, args.out, report_rows)

    print("[ETL] 清洗完成：")
    for stage, cnt in session_report + battery_report:
        print(f"       {stage}: {cnt}")
    spark.stop()


if __name__ == "__main__":
    sys.exit(main())
