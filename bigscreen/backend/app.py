# -*- coding: utf-8 -*-
"""
Flask 后端：为数据大屏提供 REST 接口

数据链路：Spark SQL ADS ORC -> 管道符 TXT -> MySQL -> Flask -> Vue3 + DataV 大屏。
每个图表接口只读取一张同名 MySQL ADS 表；不在 Flask 二次聚合。

接口一览（/api/...）：
    GET /api/health                服务与数据库状态
    GET /api/overview              运营总览 KPI（翻牌器）
    GET /api/charts/<name>         16 个图表各自唯一的数据接口
    GET /api/quality               数据清洗质量报告
    GET /api/realtime              实时订单流水（滚动榜）
"""

import os
import sys

from flask import Flask, jsonify, request, send_from_directory
from flask_cors import CORS

from config import config
from db import cached, clear_cache, db_available, db_breaker_open, db_last_error, fetch

app = Flask(__name__, static_folder=None)
app.config["JSON_AS_ASCII"] = False
app.json.ensure_ascii = False
CORS(app, resources={r"/api/*": {"origins": "*"}})

# 前端静态目录：优先 frontend/dist（npm 构建产物），没有时回退到合并工程里的 ../web
_BACKEND_DIR = os.path.dirname(os.path.abspath(__file__))
_PROJECT_DIR = os.path.dirname(_BACKEND_DIR)
_DIST_CANDIDATES = [
    os.path.join(_PROJECT_DIR, "frontend", "dist"),
    os.path.join(os.path.dirname(_PROJECT_DIR), "web"),
]
DIST_DIR = next((p for p in _DIST_CANDIDATES if os.path.isfile(os.path.join(p, "index.html"))), _DIST_CANDIDATES[0])


# --------------------------------------------------------------------------
# 充电负荷智能预测：把 ml/ 子模块的只读查询蓝图挂到同一个 Flask 上
# --------------------------------------------------------------------------
# Qt 端走 admin_server -> 127.0.0.1:5010；大屏和 nginx 只有一个服务，
# 所以这里直接复用 ml.warehouse.api 的蓝图，前端同源调 /api/forecast/latest。
_REPO_ROOT = os.path.dirname(_PROJECT_DIR)
_ML_RESULTS_CANDIDATES = (
    os.path.join(_REPO_ROOT, "ml", "data", "warehouse", "ads"),  # 真实推理产出（run_measured_ml.sh）
    os.path.join(_REPO_ROOT, "ml", "fixtures"),                  # 仓库内置批次（可直接演示）
)
FORECAST_STATUS = {"enabled": False, "results_dir": "", "source_kind": config.ML_FORECAST_SOURCE_KIND, "reason": ""}


def _dir_has_batch(directory, source_kind):
    """目录里是否存在"该来源、且成功"的批次 JSON。"""
    import json
    if not os.path.isdir(directory):
        return False
    for name in os.listdir(directory):
        if not name.endswith(".json"):
            continue
        try:
            with open(os.path.join(directory, name), encoding="utf-8") as handle:
                payload = json.load(handle)
        except Exception:
            continue
        if isinstance(payload, dict) and payload.get("success") and payload.get("source_kind") == source_kind:
            return True
    return False


def resolve_forecast_dir(source_kind):
    """定位预测批次目录：显式配置优先，否则「真实产出 > 仓库内置」自动探测。"""
    if config.ML_FORECAST_RESULTS_DIR:
        return config.ML_FORECAST_RESULTS_DIR
    for path in _ML_RESULTS_CANDIDATES:
        if _dir_has_batch(path, source_kind):
            return path
    for path in _ML_RESULTS_CANDIDATES:
        if os.path.isdir(path):
            return path
    return ""


def register_forecast_blueprint(flask_app):
    """挂载 /api/forecast/latest 与 /api/forecast/station/<id>；失败也不影响大屏其它接口。"""
    if not config.ML_FORECAST_ENABLED:
        FORECAST_STATUS["reason"] = "ML_FORECAST_ENABLED=0"
        return
    try:
        if _REPO_ROOT not in sys.path:
            sys.path.insert(0, _REPO_ROOT)
        from ml.warehouse.api import create_forecast_blueprint
        from ml.warehouse.results import FileForecastStore
    except Exception as exc:  # ml 依赖缺失时不拖垮整个后端
        FORECAST_STATUS["reason"] = f"ml 模块不可用：{exc}"
        return
    results_dir = resolve_forecast_dir(config.ML_FORECAST_SOURCE_KIND)
    if not results_dir or not os.path.isdir(results_dir):
        FORECAST_STATUS["reason"] = "未找到预测批次目录"
        return
    store = FileForecastStore(results_dir)
    flask_app.register_blueprint(
        create_forecast_blueprint(store, source_kind=config.ML_FORECAST_SOURCE_KIND)
    )
    FORECAST_STATUS.update(enabled=True, results_dir=results_dir, reason="")


register_forecast_blueprint(app)


def ok(data, **extra):
    body = {"code": 0, "msg": "ok", "data": data}
    body.update(extra)
    return jsonify(body)


def panel(table, **kwargs):
    """统一的面板数据读取 + 缓存。"""
    key = table + "|" + repr(sorted(kwargs.items()))
    return cached(key, lambda: fetch(table, **kwargs))


# --------------------------------------------------------------------------
# 顶部 KPI
# --------------------------------------------------------------------------
@app.get("/api/overview")
def api_overview():
    rows = panel("ads_overview")
    row = rows[0] if rows else {}
    for key in ("start_date", "end_date"):
        if row.get(key):
            row[key] = str(row[key])
    return ok(row)


# --------------------------------------------------------------------------
# 时间维度
# --------------------------------------------------------------------------
@app.get("/api/charts/daily-trend")
def api_trend_daily():
    days = request.args.get("days", type=int)
    rows = panel("ads_daily_trend", order="stat_date")
    for row in rows:
        row["stat_date"] = str(row.get("stat_date"))
    if days:
        rows = rows[-days:]
    return ok(rows)


@app.get("/api/charts/monthly-trend")
def api_trend_monthly():
    return ok(panel("ads_monthly_trend", order="stat_month_str"))


@app.get("/api/charts/hour-load")
def api_hour_load():
    return ok(panel("ads_hour_load", order="start_hour"))


@app.get("/api/charts/weekday-hour-heat")
def api_heat():
    return ok(panel("ads_weekday_hour_heat", order="weekday_num, start_hour"))


@app.get("/api/charts/time-period-compare")
def api_time_period():
    return ok(panel("ads_time_period_compare", order="time_period"))


# --------------------------------------------------------------------------
# 站点 / 区域 / 类型
# --------------------------------------------------------------------------
@app.get("/api/charts/station-top")
def api_stations_top():
    return ok(panel("ads_station_top", order="rank_no"))


@app.get("/api/charts/district-compare")
def api_districts():
    return ok(panel("ads_district_compare", order="kwh DESC"))


@app.get("/api/charts/facility-compare")
def api_facility():
    return ok(panel("ads_facility_compare", order="kwh DESC"))


# --------------------------------------------------------------------------
# 对比分析
# --------------------------------------------------------------------------
@app.get("/api/charts/weekend-compare")
def api_weekend():
    rows = panel("ads_weekend_compare")
    order = {"工作日": 0, "周末": 1}
    return ok(sorted(rows, key=lambda r: order.get(r.get("day_type"), 9)))


@app.get("/api/charts/platform-compare")
def api_platform():
    return ok(panel("ads_platform_compare", order="sessions DESC"))


# --------------------------------------------------------------------------
# 用户维度
# --------------------------------------------------------------------------
@app.get("/api/charts/user-segment")
def api_user_segments():
    return ok(panel("ads_user_segment", order="kwh DESC"))


# --------------------------------------------------------------------------
# 分布 / 电池 / 收入
# --------------------------------------------------------------------------
@app.get("/api/charts/duration-dist")
def api_dist_duration():
    return ok(panel("ads_duration_dist", order="bin_order"))


@app.get("/api/charts/energy-dist")
def api_dist_energy():
    return ok(panel("ads_energy_dist", order="bin_order"))


@app.get("/api/charts/battery-health")
def api_battery_health():
    rows = panel("ads_battery_health")
    return ok(sorted(rows, key=lambda r: int(str(r.get("soc_bin", "0")).split("-")[0])))


@app.get("/api/charts/revenue-struct")
def api_revenue():
    return ok(panel("ads_revenue_struct", order="revenue DESC"))


@app.get("/api/quality")
def api_quality():
    return ok(panel("ads_data_quality"))


@app.get("/api/pipeline")
def api_pipeline():
    """本次离线作业的数据链路信息（计算引擎 / 存储位置），用于大屏顶部展示。"""
    rows = panel("ads_pipeline_info")
    return ok(rows[0] if rows else {})


@app.get("/api/charts/realtime-sessions")
def api_realtime():
    limit = request.args.get("limit", 15, type=int)
    return ok(panel("ads_realtime_sessions", limit=limit))


@app.post("/api/cache/refresh")
def api_refresh():
    clear_cache()
    return ok(True)


@app.get("/api/health")
def api_health():
    available = db_available()
    hint = "" if available else "MySQL 未连接：请完成 ADS ORC→TXT→MySQL 同步，或检查 config/database.env。"
    return ok(
        {
            "status": "up",
            "data_source": "mysql",
            "configured_source": config.DATA_SOURCE,
            "hint": hint,
            "forecast": FORECAST_STATUS,
            "mysql": {
                "host": config.DB_HOST,
                "port": config.DB_PORT,
                "database": config.DB_NAME,
                "user": config.DB_USER,
                "connected": available,
                "breaker_open": db_breaker_open(),
                "last_error": db_last_error(),
            },
        }
    )


# --------------------------------------------------------------------------
# 静态资源：直接托管前端构建产物（frontend/dist），单服务部署
# --------------------------------------------------------------------------
@app.get("/")
def index():
    if os.path.isfile(os.path.join(DIST_DIR, "index.html")):
        return send_from_directory(DIST_DIR, "index.html")
    return ok({"message": "前端尚未构建，请先执行 npm run build", "dist": DIST_DIR})


@app.get("/<path:filename>")
def static_files(filename):
    target = os.path.join(DIST_DIR, filename)
    if os.path.isfile(target):
        return send_from_directory(DIST_DIR, filename)
    if os.path.isfile(os.path.join(DIST_DIR, "index.html")):
        return send_from_directory(DIST_DIR, "index.html")
    return jsonify({"code": 404, "msg": "not found"}), 404


if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(host="0.0.0.0", port=port, debug=bool(os.environ.get("FLASK_DEBUG")))
