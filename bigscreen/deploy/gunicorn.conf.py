# -*- coding: utf-8 -*-
"""gunicorn 生产配置：Flask 后端在大屏场景下的并发与超时设置。"""

import multiprocessing
import os

bind = f"0.0.0.0:{os.environ.get('PORT', '5000')}"
workers = int(os.environ.get("GUNICORN_WORKERS", min(4, multiprocessing.cpu_count() * 2 + 1)))
worker_class = "sync"
threads = 2
timeout = 120
keepalive = 5
accesslog = "-"
errorlog = "-"
loglevel = "info"
graceful_timeout = 30
