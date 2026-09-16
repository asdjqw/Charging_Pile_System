# -*- coding: utf-8 -*-
"""以固定 Schema 将项目内的 ADS 管道符 TXT 幂等导入 MySQL。"""

import argparse
import csv
import os
import sys

import pymysql

PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
SCHEMA_PATH = os.path.join(PROJECT_ROOT, "mysql", "schema", "ads_schema.sql")
TABLES = (
    "ads_overview", "ads_daily_trend", "ads_monthly_trend", "ads_hour_load",
    "ads_weekday_hour_heat", "ads_station_top", "ads_facility_compare",
    "ads_weekend_compare", "ads_time_period_compare", "ads_platform_compare",
    "ads_district_compare", "ads_duration_dist", "ads_energy_dist", "ads_user_segment",
    "ads_battery_health", "ads_revenue_struct", "ads_realtime_sessions",
    "ads_data_quality", "ads_pipeline_info",
)


def read_env(path):
    result = {}
    if os.path.isfile(path):
        for line in open(path, encoding="utf-8"):
            line = line.strip()
            if line and not line.startswith("#") and "=" in line:
                key, value = line.split("=", 1)
                result[key.strip()] = value.strip()
    return result


def main(argv=None):
    parser = argparse.ArgumentParser(description="本地 ADS TXT -> MySQL LOAD DATA LOCAL INFILE")
    parser.add_argument("--load-date", required=True)
    parser.add_argument("--stage-dir", required=True)
    parser.add_argument("--host")
    parser.add_argument("--port", type=int)
    parser.add_argument("--user")
    parser.add_argument("--password")
    parser.add_argument("--database")
    args = parser.parse_args(argv)
    env = read_env(os.path.join(PROJECT_ROOT, "config", "database.env"))
    cfg = {
        "host": args.host or os.getenv("DB_HOST") or env.get("DB_HOST", "127.0.0.1"),
        "port": args.port or int(os.getenv("DB_PORT") or env.get("DB_PORT", "3306")),
        "user": args.user or os.getenv("DB_USER") or env.get("DB_USER", "charging"),
        "password": args.password if args.password is not None else os.getenv("DB_PASSWORD", env.get("DB_PASSWORD", "")),
        "database": args.database or os.getenv("DB_NAME") or env.get("DB_NAME", "charging_screen"),
        "charset": "utf8mb4",
        "local_infile": True,
        "autocommit": False,
    }
    missing = [name for name in TABLES if not os.path.isfile(os.path.join(args.stage_dir, f"{name}.txt"))]
    if missing:
        raise RuntimeError("缺少导入文件：" + ", ".join(missing))
    empty = [name for name in TABLES if os.path.getsize(os.path.join(args.stage_dir, f"{name}.txt")) == 0]
    if empty:
        raise RuntimeError("拒绝清空 MySQL：以下导出文件为空：" + ", ".join(empty))

    server_cfg = dict(cfg)
    database = server_cfg.pop("database")
    conn = pymysql.connect(**server_cfg)
    try:
        with conn.cursor() as cur:
            cur.execute(f"CREATE DATABASE IF NOT EXISTS `{database}` DEFAULT CHARSET utf8mb4")
        conn.select_db(database)
        schema_sql = open(SCHEMA_PATH, encoding="utf-8").read()
        with conn.cursor() as cur:
            for statement in (item.strip() for item in schema_sql.split(";") if item.strip()):
                cur.execute(statement)
        conn.commit()

        # 旧 CSV 链路曾自动推断表结构；列数不一致时禁止 TRUNCATE，要求先做一次显式迁移。
        with conn.cursor() as cur:
            for table in TABLES:
                with open(os.path.join(args.stage_dir, f"{table}.txt"), encoding="utf-8", newline="") as handle:
                    exported_columns = len(next(csv.reader(handle, delimiter="|", quotechar='"', escapechar="\\")))
                cur.execute(f"SHOW COLUMNS FROM `{table}`")
                actual_columns = len(cur.fetchall())
                if actual_columns != exported_columns:
                    raise RuntimeError(
                        f"{table} MySQL 列数为 {actual_columns}，导出 TXT 列数为 {exported_columns}；"
                        "请先执行一次 CONFIRM_RESET_ADS_SCHEMA=YES python mysql/scripts/reset_ads_schema.py"
                    )

        for table in TABLES:
            path = os.path.abspath(os.path.join(args.stage_dir, f"{table}.txt"))
            with conn.cursor() as cur:
                # 按要求先清空再导入；文件检查已在任何 TRUNCATE 前完成。
                cur.execute(f"TRUNCATE TABLE `{table}`")
                cur.execute(
                    f"LOAD DATA LOCAL INFILE %s INTO TABLE `{table}` "
                    "CHARACTER SET utf8mb4 FIELDS TERMINATED BY '|' OPTIONALLY ENCLOSED BY '\"' "
                    "ESCAPED BY '\\\\' LINES TERMINATED BY '\\n'",
                    (path,),
                )
                cur.execute(f"SELECT COUNT(*) FROM `{table}`")
                rows = cur.fetchone()[0]
                cur.execute(
                    "INSERT INTO etl_ads_sync_log (load_dt, table_name, rows_loaded) VALUES (%s,%s,%s) "
                    "ON DUPLICATE KEY UPDATE rows_loaded=VALUES(rows_loaded), synced_at=CURRENT_TIMESTAMP",
                    (args.load_date, table, rows),
                )
            conn.commit()
            print(f"[OK] {table}: {rows} 行 <- {path}", flush=True)
    except Exception:
        conn.rollback()
        raise
    finally:
        conn.close()


if __name__ == "__main__":
    sys.exit(main())
