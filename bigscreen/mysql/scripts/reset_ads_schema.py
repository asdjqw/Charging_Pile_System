# -*- coding: utf-8 -*-
"""一次性迁移工具：删除旧 CSV 链路的同名 ADS MySQL 表，创建正式固定 Schema。"""

import os
import sys

import pymysql

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from import_ads_pipe_text import SCHEMA_PATH, TABLES, read_env  # noqa: E402


def main():
    if os.getenv("CONFIRM_RESET_ADS_SCHEMA") != "YES":
        raise RuntimeError("这是一次性破坏性迁移。请显式设置 CONFIRM_RESET_ADS_SCHEMA=YES 后执行。")
    root = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    env = read_env(os.path.join(root, "config", "database.env"))
    database = os.getenv("DB_NAME") or env.get("DB_NAME", "charging_screen")
    conn = pymysql.connect(
        host=os.getenv("DB_HOST") or env.get("DB_HOST", "127.0.0.1"),
        port=int(os.getenv("DB_PORT") or env.get("DB_PORT", "3306")),
        user=os.getenv("DB_USER") or env.get("DB_USER", "charging"),
        password=os.getenv("DB_PASSWORD", env.get("DB_PASSWORD", "")),
        charset="utf8mb4",
        autocommit=False,
    )
    try:
        with conn.cursor() as cur:
            cur.execute(f"CREATE DATABASE IF NOT EXISTS `{database}` DEFAULT CHARSET utf8mb4")
        conn.select_db(database)
        with conn.cursor() as cur:
            for table in TABLES:
                cur.execute(f"DROP TABLE IF EXISTS `{table}`")
            cur.execute("DROP TABLE IF EXISTS `etl_ads_sync_log`")
            for statement in (part.strip() for part in open(SCHEMA_PATH, encoding="utf-8").read().split(";") if part.strip()):
                cur.execute(statement)
        conn.commit()
        print("[OK] 正式 ADS MySQL Schema 已初始化；后续 ETL 仅 TRUNCATE + LOAD DATA。")
    finally:
        conn.close()


if __name__ == "__main__":
    main()
