# -*- coding: utf-8 -*-
"""
数据访问层：MySQL 是正式大屏唯一数据源；统一带 TTL 内存缓存。
"""

import datetime
import decimal
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

_breaker_until = 0.0          # 熔断截止时间戳：期间快速返回数据库不可用错误，避免接口阻塞
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


def fetch(table, where="", params=None, order="", limit=None):
    """
    读取一张结果表：
        SELECT * FROM `table` [WHERE ...] [ORDER BY ...] [LIMIT n]
    """
    if config.DATA_SOURCE != "mysql":
        raise RuntimeError("正式大屏仅支持 DATA_SOURCE=mysql")
    if db_breaker_open():
        raise RuntimeError(f"MySQL 连接熔断中：{db_last_error()}")
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
        raise RuntimeError(f"MySQL 查询失败：{exc}") from exc


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
