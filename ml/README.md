# 充电预测子模块（ml/）

命令一律在**仓库根目录**执行（与 `ChargePile.pro` 同级）。和 Qt / 大屏怎么接，见 [docs/机器学习.md](../docs/机器学习.md)。

## 现状

| 能力 | 状态 |
|---|---|
| 六个冻结模型推理（H1 XGBoost 两阶段，H6/H24 随机森林） | 代码在；**模型文件不在 git** |
| 文件或 MySQL 发布结果 + Flask 只读查询 `:5010` | 可用 |
| Qt 用户端 / 管理端展示 | 已接（经 `admin_server` 转发） |
| Vue 分析大屏 | **未注册**预测路由 |
| Spark ADS 自动产出小时 parquet | **没有**，快照要另供 |

## 演示查询（无 3.4GB 模型）

仓库 `ml/fixtures/demo_forecast.json` 是 `SIMULATED` 批次。Ubuntu 22.04（Python 3.10）**不要**安装 `ml/requirements.txt`（numpy/pandas 版本过新）。

```bash
python3 -m venv "$HOME/charging-ml-venv"
source "$HOME/charging-ml-venv/bin/activate"
pip install Flask
python3 -m ml.cli.warehouse_api --store file --results-dir ml/fixtures --source-kind SIMULATED --port 5010
curl -s http://127.0.0.1:5010/api/forecast/latest
```

`scripts/start_all.sh` 会按同样方式拉起查询服务。

## 真预测：先下载模型

资源：[GitHub Releases ml-resources-20260914](https://github.com/asdjqw/Charging_Pile_System/releases/tag/ml-resources-20260914)

必须：`ml-models-h1.tar.gz`、`ml-models-h6.tar.gz`、`ml-models-h24.tar.gz`，以及 `SHA256SUMS`。可选训练数据 `ml-training-data.tar.gz`。

在**仓库根**解压（包内已含 `ml/` 路径，不要在 `ml/` 里再解一层）：

```bash
tar -xzf /下载目录/ml-models-h1.tar.gz
tar -xzf /下载目录/ml-models-h6.tar.gz
tar -xzf /下载目录/ml-models-h24.tar.gz
```

六个模型应出现在 `ml/artifacts/models/`。模型不是输入数据；推理还要小时快照。

建议 Python **3.12+** 独立 venv：

```bash
python3.12 -m venv "$HOME/charging-ml-full"
source "$HOME/charging-ml-full/bin/activate"
pip install -r ml/requirements.txt
```

## 预测含义

三个**目标小时**的点预测，不是未来 1/6/24 小时累计，也不是 24 点曲线。若数据截止 14:00：H1=`[14:00,15:00)`，H6=`[19:00,20:00)`，H24=次日 `[13:00,14:00)`。占用率是充电时长口径，不是实时空闲桩。

## 目录

```text
ml/
├─ cli/warehouse_predict.py    跑一批预测
├─ cli/warehouse_api.py        只读查询 Flask
├─ warehouse/                  读快照、写结果、API 蓝图、SQL 模板
├─ prediction/                 加载 joblib、推理、换算 kW / 桩数
├─ features/  config/  service/  training/
├─ fixtures/demo_forecast.json 演示批次
├─ artifacts/models/           下载后的六个模型（gitignore）
└─ data/                       运行产出（gitignore）
```

## 快照与推理

快照需含站点小时序列，语义见模块内 `INTEGRATION_MANIFEST.json` 与 `warehouse` 契约（`load_ratio`、`occupancy_ratio`、时区 `Asia/Shanghai`、`source_kind` 为 `MEASURED` 或 `SIMULATED`）。最后 25 小时必须完整。模拟快照要加 `--allow-simulated`。

```bash
python -m ml.cli.warehouse_predict --snapshot /绝对路径/snapshot --as-of 2026-09-14T14:05:00 --store file
python -m ml.cli.warehouse_predict --snapshot /路径 --store file --allow-simulated
python -m ml.cli.warehouse_api --store file --results-dir ml/data/warehouse/ads
python -m ml.cli.warehouse_api --store file --source-kind SIMULATED
```

HDFS 路径同样结构，NameNode 在本仓库安装里是 **8020**，不要照抄旧文档的 `hdfs://bitdev:9000`。

MySQL 结果表见 `ml/warehouse/sql/mysql_forecast.sql`。凭据用环境变量 `DB_HOST` `DB_PORT` `DB_USER` `DB_PASSWORD` `DB_NAME`，不写进源码。查询默认库名也是 `charging_screen`，但表与大屏 ADS **不是**同一套。

## 查询接口

- `GET /api/forecast/latest`
- `GET /api/forecast/station/<id>` 或 `?station_id=`

成功：`{"code":0,"msg":"ok","data":...}`。`data.stale` 在截止时间超过 2 小时为 true。无批次 404。本地 Flask **无鉴权**，不要对公网打开。

## 定时与中台

`ml/warehouse/deploy/` 有 systemd 模板，部署前改路径和用户。查询服务需另外部署。`bigscreen/backend/app.py` 目前未挂预测蓝图。
