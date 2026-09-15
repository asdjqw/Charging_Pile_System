# -*- coding: utf-8 -*-
"""
数据访问层：
    - MySQL 模式：使用轻量连接池执行查询，把 Spark 分析结果表读为 dict 列表
    - CSV  模式：MySQL 不可用时，直接读取 Spark 输出的 CSV，保证大屏始终可用
    - 统一带 TTL 的内存缓存，降低大屏轮询压力
"""

import csv
import datetime
import decimal
import glob
import os
import queue
import threading
import time

import pymysql

from config import config

_pool = queue.Queue(maxsize=config.POOL_SIZE)
_pool_lock = threading.Lock()
_pool_created = 0

_cache = {}
_cache_lock = threading.Lock()

_breaker_until = 0.0          # 熔断截止时间戳：期间不再尝试 MySQL，直接走 CSV 兜底
_last_error = ""              # 最近一次数据库错误，供 /api/health 展示


def _new_connection():
    return pymysql.connect(
        host=config.DB_HOST,
        port=config.DB_PORT,
        user=config.DB_USER,
        password=config.DB_PASSWORD,
        database=config.DB_NAME,
        charset="utf8mb4",
        cursorclass=pymysql.cursors.DictCursor,
        autocommit=True,
        connect_timeout=config.DB_CONNECT_TIMEOUT,
        read_timeout=config.DB_READ_TIMEOUT,
        write_timeout=config.DB_WRITE_TIMEOUT,
    )


def db_breaker_open():
    """MySQL 是否处于熔断期（此前连接失败，短时间内不再重试）。"""
    return time.time() < _breaker_until


def db_last_error():
    return _last_error


def _trip_breaker(reason):
    """记录错误并进入熔断期，让接口快速降级而不是逐个查询等待超时。"""
    global _breaker_until, _last_error
    _breaker_until = time.time() + config.DB_BREAKER_SECONDS
    _last_error = str(reason)[:300]


def _reset_breaker():
    global _breaker_until, _last_error
    _breaker_until = 0.0
    _last_error = ""


def _borrow():
    global _pool_created
    try:
        return _pool.get_nowait(), False
    except queue.Empty:
        pass
    with _pool_lock:
        if _pool_created < config.POOL_SIZE:
            _pool_created += 1
            return _new_connection(), True
    try:
        return _pool.get(timeout=config.DB_POOL_TIMEOUT), False
    except queue.Empty:
        return _new_connection(), True


def _release(conn):
    try:
        _pool.put_nowait(conn)
    except queue.Full:
        try:
            conn.close()
        except Exception:
            pass


def _serialize_row(row):
    """把 MySQL 的 date/datetime/Decimal 转成 JSON 友好的类型，避免 Flask 输出 HTTP 日期格式。"""
    out = {}
    for key, value in row.items():
        if isinstance(value, datetime.datetime):
            out[key] = value.strftime("%Y-%m-%d %H:%M:%S")
        elif isinstance(value, datetime.date):
            out[key] = value.strftime("%Y-%m-%d")
        elif isinstance(value, decimal.Decimal):
            out[key] = float(value)
        elif isinstance(value, datetime.timedelta):
            out[key] = value.total_seconds()
        else:
            out[key] = value
    return out


def query(sql, params=None):
    """执行查询，返回 dict 列表。"""
    global _last_error
    conn, _ = _borrow()
    try:
        with conn.cursor() as cur:
            cur.execute(sql, params or ())
            _reset_breaker()
            return [_serialize_row(row) for row in cur.fetchall()]
    except (pymysql.err.OperationalError, pymysql.err.InterfaceError):
        # 连接失效则重建一次
        try:
            conn.close()
        except Exception:
            pass
        conn = _new_connection()
        with conn.cursor() as cur:
            cur.execute(sql, params or ())
            _reset_breaker()
            return [_serialize_row(row) for row in cur.fetchall()]
    finally:
        _release(conn)


def db_available():
    try:
        if db_breaker_open():
            return False
        query("SELECT 1")
        return True
    except Exception as exc:
        _trip_breaker(exc)
        return False


def _csv_path(table):
    for pattern in (f"mysql_{table}.csv", f"{table}.csv"):
        hits = glob.glob(os.path.join(config.ADS_DIR, pattern))
        if hits:
            return hits[0]
    return None


def _csv_rows(table):
    path = _csv_path(table)
    if not path:
        return []
    rows = []
    with open(path, encoding="utf-8-sig", newline="") as fh:
        for row in csv.DictReader(fh):
            conv = {}
            for key, value in row.items():
                if value in ("", None):
                    conv[key] = None
                    continue
                try:
                    number = float(value)
                    conv[key] = int(number) if number == int(number) and "." not in value and "e" not in value.lower() else number
                except (ValueError, AttributeError):
                    conv[key] = value
            rows.append(conv)
    return rows


def fetch(table, where="", params=None, order="", limit=None):
    """
    读取一张结果表：
        MySQL 模式 -> SELECT * FROM `table` [WHERE ...] [ORDER BY ...] [LIMIT n]
        CSV  模式 -> 读取 Spark 输出 CSV 后在内存中过滤/排序
    """
    if config.DATA_SOURCE == "mysql":
        if db_breaker_open():
            # 熔断期内直接读 CSV，避免每次请求都去等数据库超时（大屏首屏有 ~20 个查询）
            return _fetch_from_csv(table, where, order, limit)
        sql = f"SELECT * FROM `{table}`"
        if where:
            sql += f" WHERE {where}"
        if order:
            sql += f" ORDER BY {order}"
        if limit:
            sql += f" LIMIT {int(limit)}"
        try:
            return query(sql, params)
        except Exception as exc:
            _trip_breaker(exc)
            print(f"[WARN] MySQL 查询失败（已熔断 {config.DB_BREAKER_SECONDS}s），回退 CSV：{exc}")
    return _fetch_from_csv(table, where, order, limit)


def _fetch_from_csv(table, where="", order="", limit=None):
    """CSV 兜底数据源：读取 Spark 输出的结果表。"""
    rows = _csv_rows(table)
    if where:
        print(f"[WARN] CSV 模式忽略过滤条件：{where}")
    if order:
        key, _, direction = order.partition(" ")
        key = key.strip().strip("`")
        rows.sort(key=lambda r: (r.get(key) is None, r.get(key)), reverse=direction.strip().lower().startswith("desc"))
    return rows[:limit] if limit else rows


def cached(key, builder, ttl=None):
    """带 TTL 的内存缓存，大屏 30~60 秒轮询时避免频繁打库。"""
    ttl = config.CACHE_TTL if ttl is None else ttl
    now = time.time()
    with _cache_lock:
        hit = _cache.get(key)
        if hit and now - hit[0] < ttl:
            return hit[1]
    value = builder()
    with _cache_lock:
        _cache[key] = (now, value)
    return value


def clear_cache():
    with _cache_lock:
        _cache.clear()
