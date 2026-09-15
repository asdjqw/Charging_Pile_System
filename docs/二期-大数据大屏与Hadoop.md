# 二期：分析大屏、Spark 与 Hadoop

> 本文替代旧「第二阶段实践方案」里尚未落地的 `bigdata/`、8090 端口等设想。现状以 `bigscreen/` 为准。

## 在整个项目中的位置

二期**不读写**一期 SQLite。它用自己的原始 CSV（可扩容）→ Spark → MySQL `charging_screen`（或 CSV 兜底）→ Flask **:5000** → Vue/DataV。

Hadoop 是**离线文件存储 + 可选 YARN 计算**，不是大屏的在线库。日常看大屏只需要 MySQL + Flask。

## 目录

| 路径 | 作用 |
|---|---|
| `bigscreen/` | **主工程**（改这里） |
| `bigscreen/spark/jobs/` | `etl_clean.py`、`analysis.py`、`load_mysql.py`、`run_all.py`、扩容脚本 |
| `bigscreen/backend/` | Flask |
| `bigscreen/frontend/` | Vue 源码；运行用 `frontend/dist` 或仓库 `web/` |
| `bigscreen/sql/charging_screen.sql` | 预置分析结果，安装脚本默认导入，避免空屏 |
| `charging-bigscreen-export/` | 历史导出副本，不要双线修改 |

安装脚本会把 `bigscreen/` 同步到 `~/charging-bigscreen`（避开共享盘 `noexec`）。

## 数据流

```text
CSV（或 HDFS /data/charging/raw）
    → Spark 清洗（parquet/csv warehouse）
    → Spark 15 维分析（ads）
    → MySQL charging_screen  或  本地 output/ads/*.csv
    → Flask :5000
    → 浏览器大屏
```

本仓库 `setup_phase2_ubuntu.sh` 默认 **导入 SQL 备份，不自动重跑 Spark**，以免用少量原始订单覆盖扩容后的指标。需要重算时再 `RUN_SPARK=1` 或手动 `run_all.py`。

HDFS 在本仓库安装脚本中的约定：

| 项 | 值 |
|---|---|
| NameNode RPC | **8020**（避开 Qt 9000） |
| 目录 | `/data/charging/{raw,warehouse,ads}` |
| Web | NameNode `9870`，YARN `8088` |

部分旧文档写 `/user/bit/charging-bigscreen` 和 `hdfs://bitdev:9000`，那是另一台机器上的历史路径。

## 分析规模（扩容后，答辩常用口径）

充电站约 3024 座（融合北京 POI）、订单约 5.5 万、遥测约 2.5 万、用户约 2556。扩容规则见 `bigscreen/docs/数据扩容生成规则.md`。15 个维度与接口清单见 `bigscreen/README.md`。

## 不要做的事

- 不要用 `scripts/setup_bigscreen_ubuntu.sh` 当主安装路径（它偏向 export 副本，且可能空 `output/ads`）。
- 不要对 Ubuntu 3.10 整包安装 `ml/requirements.txt` 来“顺便”跑大屏。
- 不要把分析大屏的入口说成 `:8080`。
