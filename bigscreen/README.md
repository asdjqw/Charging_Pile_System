# 分析大屏（bigscreen/）

《充电桩综合管理系统》的 **Spark + MySQL + Flask + Vue/DataV** 子工程。仓库总说明见根目录 [README.md](../README.md)。

**浏览器入口：`http://127.0.0.1:5000/`**（Flask）。不要用一期 `:8080` 当分析大屏。

![大屏预览](docs/大屏预览.png)

## 在本仓库中如何启动

推荐走仓库脚本（会把代码同步到 `~/charging-bigscreen`）：

```bash
bash scripts/setup_phase2_ubuntu.sh          # 或 setup_all_ubuntu.sh
bash ~/start_charge_pile.sh                  # 日常
# 只要大屏：
bash ~/charging-bigscreen/deploy/phase2_services.sh start
```

HDFS RPC **8020**，数据目录 **`/data/charging/{raw,warehouse,ads}`**。旧文档里的 `bitdev:9000`、`/user/bit/charging-bigscreen` 不是本仓库安装脚本的默认值。

安装脚本默认导入 `sql/charging_screen.sql`，**不自动重跑 Spark**。重算：

```bash
cd ~/charging-bigscreen
source .venv/bin/activate
export PYSPARK_PYTHON="$PWD/.venv/bin/python"
python spark/jobs/run_all.py --raw data/raw --warehouse output/warehouse --ads output/ads
python spark/jobs/load_mysql.py
curl -X POST http://127.0.0.1:5000/api/cache/refresh
```

YARN 模式先 `source deploy/hadoop_env.sh`，`SPARK_MASTER=yarn`，路径换成 `hdfs://<主机>:8020/data/charging/...`。一键提交还可试 `bash deploy/spark_submit.sh`（先核对脚本内地址是否仍写 9000）。

## 架构

```text
CSV 或 HDFS raw
  → spark/jobs/etl_clean.py
  → spark/jobs/analysis.py     15 维 / 5 组对比
  → spark/jobs/load_mysql.py   库 charging_screen
  → backend/app.py             :5000，约 23 个 REST，30s 缓存，可切 CSV
  → frontend/                  Vue3 + DataV + ECharts，暗/亮主题
```

Hadoop 存离线文件；在线查询走 MySQL（或 `output/ads/*.csv`）。

## 数据

原始三表：`data/raw/nvv2t.csv`（订单）、`dsv13r2.csv`（遥测）、`nvv2t_md_end.csv`（站点）。扩容脚本 `spark/jobs/generate_expanded_data.py` 融合仓库 `data/北京市充电桩数据.csv`，规则见 [docs/数据扩容生成规则.md](docs/数据扩容生成规则.md)。

清洗要点：年份 `0014` → 2014；剔除 0 电量与超长订单；遥测 `record_time` 科学计数无法还原则丢弃；电流取幅值。

## 15 个分析维度

| # | 维度 | 结果表 |
|---|---|---|
| 1 | 运营 KPI | `ads_overview` |
| 2–3 | 日/月趋势 | `ads_daily_trend` / `ads_monthly_trend` |
| 4–5 | 24h 负荷、星期×小时 | `ads_hour_load` / `ads_weekday_hour_heat` |
| 6 | 站点 TOP | `ads_station_top` |
| 7–10 | 行政区、站型、工作日周末、峰平谷 | `ads_district` 等 |
| 11 | 用户 RFM | `ads_user_value` |
| 12–14 | 时长/电量/功率与电池健康 | `ads_*_dist` / `ads_battery_*` |
| 15 | 收入结构与平台 | `ads_revenue_struct` / `ads_platform_compare` |

扩容后量级约：有效订单 5.5 万、电量 32.8 万 kWh、站点约 3000、用户 2556。口述结论见 [docs/答辩要点.md](docs/答辩要点.md)。

## 主要接口

| 接口 | 说明 |
|---|---|
| `GET /api/health` | 健康与 `data_source` |
| `GET /api/screen/bundle` | 首屏聚合 |
| `GET /api/overview` ` /api/trend/*` `/api/hour-load` `/api/heat/weekday-hour` | KPI 与趋势 |
| `GET /api/stations/top` `/api/districts` `/api/facility/compare` `/api/weekend/compare` | 对比 |
| `GET /api/users/segments` `/api/dist/*` `/api/battery/*` `/api/revenue/struct` | 用户与分布 |
| `GET /api/quality` `/api/realtime` `/api/pipeline` | 质量、流水、作业信息 |
| `POST /api/cache/refresh` | 清缓存 |

账号在被 git 忽略的 `config/database.env`。本仓库安装默认用户 `charging` / `charging123`。

## 前端

源码 `frontend/`，Node **≥ 23** 才需要重新 `npm run build`。日常用现成 `frontend/dist` 或仓库 `web/`。源码里若 Flask 不在同源，可能回退 `:5000`；**已打包进 `web/` 的 JS 以相对 `/api` 为准**，所以要用 Flask 当网站根。

双主题：大屏顶栏切换，或 `?theme=light`。

## 与一期的关系

不写 `charge_pile.db`。可选 `scripts/export_sqlite_to_bigscreen.py` 导出一期订单；订单很少时脚本会拒绝覆盖扩容样本。

机器学习不在本大屏展示。
