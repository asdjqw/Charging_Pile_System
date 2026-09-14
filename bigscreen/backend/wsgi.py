# -*- coding: utf-8 -*-
"""WSGI 入口（生产环境使用 gunicorn 启动：gunicorn -c deploy/gunicorn.conf.py backend.wsgi:application）。"""

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app import app as application  # noqa: E402

if __name__ == "__main__":
    application.run(host="0.0.0.0", port=int(os.environ.get("PORT", 5000)))
