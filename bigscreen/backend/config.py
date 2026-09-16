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
    """
    环境变量优先，其次 config/database.env，最后默认值。
    注意：这里用"键是否存在"判断，而不是取值真值——
    否则 Windows 本地开发写成 DB_PASSWORD=（空密码）会被默认值覆盖，导致连不上库。
    """
    if key in os.environ:
        return os.environ[key]
    if key in _FILE_ENV:
        return _FILE_ENV[key]
    return default


class Config:
    # 默认值与 deploy/deploy.sh 创建的应用账号保持一致：
    #   部署机（Ubuntu/CentOS）用 charging/charging123；本地 Windows 开发请在
    #   config/database.env 里改成 DB_USER=root / DB_PASSWORD=（root 通常免密）
    DB_HOST = env("DB_HOST", "127.0.0.1")
    DB_PORT = int(env("DB_PORT", 3306))
    DB_USER = env("DB_USER", "charging")
    DB_PASSWORD = env("DB_PASSWORD", "charging123")
    DB_NAME = env("DB_NAME", "charging_screen")

    # mysql：从 MySQL 读取 Spark 分析结果；csv：直接读取 Spark 输出的 CSV（MySQL 不可用时兜底）
    DATA_SOURCE = env("DATA_SOURCE", "mysql").lower()
    ADS_DIR = env("ADS_DIR", os.path.join(PROJECT_ROOT, "output", "ads"))

    CACHE_TTL = int(env("CACHE_TTL", 30))          # 秒，大屏自动刷新间隔大于该值即可命中缓存
    POOL_SIZE = int(env("DB_POOL_SIZE", 8))

    # 充电负荷智能预测（ml/ 子模块）：大屏只读读取"已发布的预测批次"，
    # 不在这里训练、也不在请求时推理。
    #   ML_FORECAST_RESULTS_DIR 留空时自动探测：先找真实推理产出
    #   ml/data/warehouse/ads/，没有就退回仓库内置批次 ml/fixtures/。
    ML_FORECAST_ENABLED = env("ML_FORECAST_ENABLED", "1").strip().lower() not in {"0", "false", "no", "off"}
    ML_FORECAST_SOURCE_KIND = env("ML_FORECAST_SOURCE_KIND", "MEASURED").strip().upper()
    ML_FORECAST_RESULTS_DIR = env("ML_FORECAST_RESULTS_DIR", "").strip()

    # 数据库超时与熔断（避免 MySQL 重启/网络半开时请求假死，导致大屏接口 20s 超时）
    DB_CONNECT_TIMEOUT = int(env("DB_CONNECT_TIMEOUT", 3))    # 建立连接超时
    DB_READ_TIMEOUT = int(env("DB_READ_TIMEOUT", 8))          # 读取响应超时
    DB_WRITE_TIMEOUT = int(env("DB_WRITE_TIMEOUT", 8))        # 发送请求超时
    DB_POOL_TIMEOUT = float(env("DB_POOL_TIMEOUT", 1))        # 连接池等待超时
    DB_BREAKER_SECONDS = int(env("DB_BREAKER_SECONDS", 30))   # 连接失败后的熔断时长
    JSON_AS_ASCII = False


config = Config()
