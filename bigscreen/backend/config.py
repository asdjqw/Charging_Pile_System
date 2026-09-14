# -*- coding: utf-8 -*-
"""后端配置：数据库连接、数据源模式、跨域白名单等。"""

import os

PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def _read_env_file(path):
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


_FILE_ENV = _read_env_file(os.path.join(PROJECT_ROOT, "config", "database.env"))


def env(key, default=None):
    """环境变量优先，其次 config/database.env，最后默认值。"""
    return os.environ.get(key) or _FILE_ENV.get(key) or default


class Config:
    DB_HOST = env("DB_HOST", "127.0.0.1")
    DB_PORT = int(env("DB_PORT", 3306))
    DB_USER = env("DB_USER", "root")
    DB_PASSWORD = env("DB_PASSWORD", "")
    DB_NAME = env("DB_NAME", "charging_screen")

    # mysql：从 MySQL 读取 Spark 分析结果；csv：直接读取 Spark 输出的 CSV（MySQL 不可用时兜底）
    DATA_SOURCE = env("DATA_SOURCE", "mysql").lower()
    ADS_DIR = env("ADS_DIR", os.path.join(PROJECT_ROOT, "output", "ads"))

    CACHE_TTL = int(env("CACHE_TTL", 30))          # 秒，大屏自动刷新间隔大于该值即可命中缓存
    POOL_SIZE = int(env("DB_POOL_SIZE", 8))
    JSON_AS_ASCII = False


config = Config()
