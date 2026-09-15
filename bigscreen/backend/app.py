# -*- coding: utf-8 -*-
"""
Flask 后端：为数据大屏提供 REST 接口

数据链路：Spark 清洗/分析 -> MySQL（或 CSV 兜底） -> Flask -> Vue3 + DataV 大屏

接口一览（/api/...）：
    GET /api/health                服务与数据库状态
    GET /api/overview              运营总览 KPI（翻牌器）
    GET /api/trend/daily           日充电量/订单趋势
    GET /api/trend/monthly         月度趋势
    GET /api/hour-load             24 小时负荷分布（含峰平谷）
    GET /api/heat/weekday-hour     星期 × 小时充电热度
    GET /api/stations/top          站点 TOP N 排行
    GET /api/districts             行政区分布
    GET /api/facility/compare      站点类型对比（对比分析）
    GET /api/weekend/compare       工作日 vs 周末对比（对比分析）
    GET /api/time-period           峰平谷时段对比（对比分析）
    GET /api/platform/compare      用户平台对比（对比分析）
    GET /api/users/segments        用户价值分层占比
    GET /api/users/top             用户价值榜
    GET /api/dist/duration         充电时长分布
    GET /api/dist/energy           单次电量分布
    GET /api/dist/power            充电功率分布
    GET /api/battery/health        电池健康（SOC 维度）
    GET /api/battery/type-compare  电池参数按站型对比
    GET /api/revenue/struct        收入结构与付费率
    GET /api/quality               数据清洗质量报告
    GET /api/realtime              实时订单流水（滚动榜）
    GET /api/screen/bundle         大屏首屏聚合数据（一次请求拿全部面板）
"""

import os

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
@app.get("/api/trend/daily")
def api_trend_daily():
    days = request.args.get("days", type=int)
    rows = panel("ads_daily_trend", order="stat_date")
    for row in rows:
        row["stat_date"] = str(row.get("stat_date"))
    if days:
        rows = rows[-days:]
    return ok(rows)


@app.get("/api/trend/monthly")
def api_trend_monthly():
    return ok(panel("ads_monthly_trend", order="stat_month_str"))


@app.get("/api/hour-load")
def api_hour_load():
    return ok(panel("ads_hour_load", order="start_hour"))


@app.get("/api/heat/weekday-hour")
def api_heat():
    return ok(panel("ads_weekday_hour_heat", order="weekday_num, start_hour"))


@app.get("/api/time-period")
def api_time_period():
    return ok(panel("ads_time_period"))


# --------------------------------------------------------------------------
# 站点 / 区域 / 类型
# --------------------------------------------------------------------------
@app.get("/api/stations/top")
def api_stations_top():
    limit = request.args.get("limit", 10, type=int)
    metric = request.args.get("metric", "kwh")
    rows = panel("ads_station_all")
    rows = sorted(rows, key=lambda r: (r.get(metric) or 0), reverse=True)[:limit]
    for idx, row in enumerate(rows, 1):
        row["rank"] = idx
    return ok(rows)


@app.get("/api/districts")
def api_districts():
    return ok(panel("ads_district", order="kwh DESC"))


@app.get("/api/facility/compare")
def api_facility():
    return ok(panel("ads_facility_compare", order="kwh DESC"))


# --------------------------------------------------------------------------
# 对比分析
# --------------------------------------------------------------------------
@app.get("/api/weekend/compare")
def api_weekend():
    rows = panel("ads_weekend_compare")
    order = {"工作日": 0, "周末": 1}
    return ok(sorted(rows, key=lambda r: order.get(r.get("day_type"), 9)))


@app.get("/api/platform/compare")
def api_platform():
    return ok(panel("ads_platform_compare", order="sessions DESC"))


# --------------------------------------------------------------------------
# 用户维度
# --------------------------------------------------------------------------
@app.get("/api/users/segments")
def api_user_segments():
    return ok(panel("ads_user_segment", order="kwh DESC"))


@app.get("/api/users/top")
def api_user_top():
    limit = request.args.get("limit", 10, type=int)
    return ok(panel("ads_user_value", order="kwh DESC", limit=limit))


# --------------------------------------------------------------------------
# 分布 / 电池 / 收入
# --------------------------------------------------------------------------
@app.get("/api/dist/duration")
def api_dist_duration():
    return ok(panel("ads_duration_dist", order="bin_order"))


@app.get("/api/dist/energy")
def api_dist_energy():
    return ok(panel("ads_energy_dist", order="bin_order"))


@app.get("/api/dist/power")
def api_dist_power():
    return ok(panel("ads_power_dist", order="bin_order"))


@app.get("/api/battery/health")
def api_battery_health():
    rows = panel("ads_battery_health")
    return ok(sorted(rows, key=lambda r: int(str(r.get("soc_bin", "0")).split("-")[0])))


@app.get("/api/battery/type-compare")
def api_battery_type():
    return ok(panel("ads_battery_type_compare", order="samples DESC"))


@app.get("/api/revenue/struct")
def api_revenue():
    dim = request.args.get("dim")
    rows = panel("ads_revenue_struct")
    if dim:
        rows = [r for r in rows if r.get("dim_type") == dim]
    return ok(rows)


@app.get("/api/quality")
def api_quality():
    return ok(panel("ads_data_quality"))


@app.get("/api/pipeline")
def api_pipeline():
    """本次离线作业的数据链路信息（计算引擎 / 存储位置），用于大屏顶部展示。"""
    rows = panel("ads_pipeline_info")
    return ok(rows[0] if rows else {})


@app.get("/api/realtime")
def api_realtime():
    limit = request.args.get("limit", 15, type=int)
    return ok(panel("ads_realtime_sessions", limit=limit))


# --------------------------------------------------------------------------
# 大屏首屏聚合接口
# --------------------------------------------------------------------------
@app.get("/api/screen/bundle")
def api_bundle():
    def first_row(table):
        rows = api_payload(table)
        return rows[0] if rows else {}

    def build():
        return {
            "overview": first_row("ads_overview"),
            "dailyTrend": api_payload("ads_daily_trend", order="stat_date"),
            "monthlyTrend": api_payload("ads_monthly_trend", order="stat_month_str"),
            "hourLoad": api_payload("ads_hour_load", order="start_hour"),
            "weekdayHeat": api_payload("ads_weekday_hour_heat", order="weekday_num, start_hour"),
            "stationTop": sorted(api_payload("ads_station_all"), key=lambda r: r.get("kwh") or 0, reverse=True)[:10],
            "district": api_payload("ads_district", order="kwh DESC"),
            "facility": api_payload("ads_facility_compare", order="kwh DESC"),
            "weekend": api_payload("ads_weekend_compare"),
            "timePeriod": api_payload("ads_time_period"),
            "platform": api_payload("ads_platform_compare", order="sessions DESC"),
            "userSegment": api_payload("ads_user_segment", order="kwh DESC"),
            "durationDist": api_payload("ads_duration_dist", order="bin_order"),
            "energyDist": api_payload("ads_energy_dist", order="bin_order"),
            "powerDist": api_payload("ads_power_dist", order="bin_order"),
            "batteryHealth": api_payload("ads_battery_health"),
            "revenueStruct": api_payload("ads_revenue_struct"),
            "quality": api_payload("ads_data_quality"),
            "realtime": api_payload("ads_realtime_sessions", limit=20),
            "pipeline": first_row("ads_pipeline_info"),
        }

    data = cached("screen:bundle", build, ttl=config.CACHE_TTL)
    from datetime import datetime

    return ok(data, updated_at=datetime.now().strftime("%Y-%m-%d %H:%M:%S"))


def api_payload(table, **kwargs):
    return fetch(table, **kwargs)


@app.post("/api/cache/refresh")
def api_refresh():
    clear_cache()
    return ok(True)


@app.get("/api/health")
def api_health():
    available = db_available()
    csv_results = os.path.isdir(config.ADS_DIR) and any(
        name.endswith(".csv") for name in os.listdir(config.ADS_DIR)
    )
    hint = ""
    if not available and not csv_results:
        hint = (
            "既没有连上 MySQL，也没有找到 CSV 结果：请在项目根目录执行 bash deploy/deploy.sh "
            "（会创建数据库账号并跑离线计算），或检查 config/database.env 的账号密码"
        )
    elif not available:
        hint = "MySQL 未连接，当前使用 output/ads 下的 CSV 结果（部分面板可能较旧）"
    return ok(
        {
            "status": "up",
            "data_source": "mysql" if available and config.DATA_SOURCE == "mysql" else "csv",
            "configured_source": config.DATA_SOURCE,
            "csv_results": csv_results,
            "hint": hint,
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
