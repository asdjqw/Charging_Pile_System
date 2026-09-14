# -*- coding: utf-8 -*-
"""
将 Spark 计算结果装载到 MySQL，供 Flask 后端查询、数据大屏展示。

装载内容：
    output/ads/*.csv          全部分析结果表（ads_*）+ 明细表（mysql_* -> session_detail/battery_detail/station_dim）
    output/warehouse/ads_*.csv  清洗质量报告

用法：
    python spark/jobs/load_mysql.py --host 127.0.0.1 --user root --password root --database charging_screen
    或通过环境变量 / config/database.env 提供连接信息
"""

import argparse
import csv
import glob
import os
import sys

import pymysql

PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# 列名 -> MySQL 类型（未命中的列按取值自动推断）
DATE_COLUMNS = {"stat_date", "first_date", "last_date", "start_date", "end_date", "update_time"}
DATETIME_COLUMNS = {"created_ts", "ended_ts", "created_time"}
INT_HINT = {
    "sessions", "users", "user_cnt", "station_cnt", "device_cnt", "device_count", "samples",
    "cnt", "active_days", "days", "paid_sessions", "start_hour", "end_hour", "weekday_num",
    "is_weekend", "is_fleet_vehicle", "facility_type", "sessions_per_day_int", "bin_order",
    "peak_hour", "rank", "r_score", "f_score", "m_score", "rfm_score", "location_id",
}


def read_env_file(path):
    env = {}
    if os.path.isfile(path):
        with open(path, encoding="utf-8") as fh:
            for line in fh:
                line = line.strip()
                if not line or line.startswith("#") or "=" not in line:
                    continue
                key, value = line.split("=", 1)
                env[key.strip()] = value.strip()
    return env


def db_config(args):
    env = read_env_file(os.path.join(PROJECT_ROOT, "config", "database.env"))
    cfg = {
        "host": args.host or os.environ.get("DB_HOST") or env.get("DB_HOST", "127.0.0.1"),
        "port": int(args.port or os.environ.get("DB_PORT") or env.get("DB_PORT", 3306)),
        "user": args.user or os.environ.get("DB_USER") or env.get("DB_USER", "root"),
        "password": args.password if args.password is not None else (os.environ.get("DB_PASSWORD") or env.get("DB_PASSWORD", "")),
        "database": args.database or os.environ.get("DB_NAME") or env.get("DB_NAME", "charging_screen"),
        "charset": "utf8mb4",
    }
    return cfg


def sniff_type(values, column):
    """根据列名约定 + 取值推断 MySQL 列类型。"""
    if column in DATE_COLUMNS:
        return "DATE"
    if column in DATETIME_COLUMNS:
        return "DATETIME"
    samples = [v for v in values if v not in ("", None)]
    if not samples:
        return "VARCHAR(160)"
    numeric = True
    has_fraction = False
    for value in samples:
        try:
            number = float(value)
        except ValueError:
            numeric = False
            break
        if number != int(number):
            has_fraction = True
    if not numeric:
        return "VARCHAR(160)" if len(max(samples, key=len)) <= 160 else "TEXT"
    if column in INT_HINT:
        return "BIGINT"
    return "DOUBLE" if has_fraction else "BIGINT"


def load_csv(conn, csv_path, table, truncate_only_new=True):
    """把单个 CSV 文件装载为一张 MySQL 表（删除重建，保证幂等）。"""
    with open(csv_path, encoding="utf-8-sig", newline="") as fh:
        reader = csv.reader(fh)
        header = next(reader)
        rows = [row for row in reader if row and any(cell != "" for cell in row)]
    if not rows:
        print(f"[SKIP] {table}: 无数据")
        return 0

    header = [h.strip() for h in header]
    sample = rows[:200]
    columns = []
    for idx, name in enumerate(header):
        col_type = sniff_type([r[idx] if idx < len(r) else "" for r in sample], name)
        columns.append(f"`{name}` {col_type} NULL")
    ddl = f"CREATE TABLE `{table}` (\n  " + ",\n  ".join(columns) + "\n) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4"

    placeholders = ",".join(["%s"] * len(header))
    insert_sql = (
        f"INSERT INTO `{table}` ({','.join('`' + h + '`' for h in header)}) VALUES ({placeholders})"
    )
    normalized = [
        [None if (cell == "" or cell.upper() in ("NULL", "NAN")) else cell for cell in (row + [""] * (len(header) - len(row)))]
        for row in rows
    ]

    with conn.cursor() as cur:
        cur.execute(f"DROP TABLE IF EXISTS `{table}`")
        cur.execute(ddl)
        for i in range(0, len(normalized), 1000):
            cur.executemany(insert_sql, normalized[i:i + 1000])
    conn.commit()
    print(f"[OK] {table}: {len(rows)} 行 <- {os.path.basename(csv_path)}")
    return len(rows)


def table_name_from_file(path, warehouse_mode):
    name = os.path.splitext(os.path.basename(path))[0]
    if name.startswith("mysql_"):
        return name[len("mysql_"):]
    if warehouse_mode and not name.startswith("ads_"):
        return None
    return name


def main(argv=None):
    parser = argparse.ArgumentParser(description="Spark 结果装载到 MySQL")
    parser.add_argument("--warehouse", default=os.path.join(PROJECT_ROOT, "output", "warehouse"))
    parser.add_argument("--ads", default=os.path.join(PROJECT_ROOT, "output", "ads"))
    parser.add_argument("--host")
    parser.add_argument("--port")
    parser.add_argument("--user")
    parser.add_argument("--password")
    parser.add_argument("--database")
    args = parser.parse_args(argv)

    cfg = db_config(args)
    print(f"[MySQL] 连接 {cfg['user']}@{cfg['host']}:{cfg['port']}")
    conn = pymysql.connect(**{k: v for k, v in cfg.items() if k != "database"})
    with conn.cursor() as cur:
        cur.execute(
            f"CREATE DATABASE IF NOT EXISTS `{cfg['database']}` DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_general_ci"
        )
    conn.select_db(cfg["database"])

    # 明细表建索引，加速后端"最近订单""按站点筛选"等查询
    with conn.cursor() as cur:
        cur.execute(
            """CREATE TABLE IF NOT EXISTS etl_job_log (
                 id INT AUTO_INCREMENT PRIMARY KEY,
                 job_name VARCHAR(80), rows_loaded INT, created_at DATETIME DEFAULT CURRENT_TIMESTAMP
               ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4"""
        )
    conn.commit()

    total = 0
    for path, warehouse_mode in [
        (os.path.join(args.ads, "*.csv"), False),
        (os.path.join(args.warehouse, "*.csv"), True),
    ]:
        for csv_path in sorted(glob.glob(path)):
            table = table_name_from_file(csv_path, warehouse_mode)
            if not table:
                continue
            total += load_csv(conn, csv_path, table)

    # 为明细表补充索引与常用视图
    with conn.cursor() as cur:
        for stmt in [
            "CREATE INDEX idx_session_date ON session_detail (stat_date)",
            "CREATE INDEX idx_session_station ON session_detail (station_id)",
            "CREATE INDEX idx_battery_session ON battery_detail (session_id)",
        ]:
            try:
                cur.execute(stmt)
            except Exception:
                pass
        cur.execute("INSERT INTO etl_job_log (job_name, rows_loaded) VALUES (%s, %s)", ("spark_ads_load", total))
    conn.commit()
    conn.close()
    print(f"[DONE] 共装载 {total} 行到 MySQL 库 {cfg['database']}")


if __name__ == "__main__":
    sys.exit(main())
