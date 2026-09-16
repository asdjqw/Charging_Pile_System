# 二期：分析大屏、Spark 与 Hadoop

> 现状以 `bigscreen/` 为准。正式计算链路是 Spark SQL + ORC，不再使用旧 PySpark CSV 脚本或 `/api/screen/bundle`。

## 在整个项目中的位置

二期**不读写**一期 SQLite。它用扩容 CSV → HDFS ODS TextFile → Spark SQL DWD/DWS/ADS（ORC + Snappy）→ 管道符 TXT → MySQL `charging_screen` → Flask **:5000** → Vue/DataV。

Hadoop 是**离线文件存储 + 可选 YARN 计算**，不是大屏的在线库。日常看大屏只需要 MySQL + Flask。

## 目录

| 路径 | 作用 |
|---|---|
| `bigscreen/` | **唯一大屏工程** |
| `bigscreen/hive/hql/` | ODS 与 Spark SQL 分层建表 / ETL |
| `bigscreen/spark/jobs/` | 扩容数据生成、ADS ORC 导出 |
| `bigscreen/mysql/` | 固定 Schema 与 TXT 幂等导入 |
| `bigscreen/backend/` | Flask（一图一表一接口 + 预测蓝图） |
| `bigscreen/frontend/` | Vue 源码；构建产物提交到仓库 `web/` |
| `web/` | 已构建的静态页，供 Flask 与一期 `:8080` 托管 |

安装脚本会把 `bigscreen/` 同步到 `~/charging-bigscreen`（避开共享盘 `noexec`）。

## 数据流

```text
CSV（data/raw_expanded）
    → Hive / Spark SQL LOAD ODS TextFile
    → Spark SQL DWD / DWS / ADS（ORC + Snappy）
    → HDFS 管道符 TXT → output/mysql_stage/<load_dt>/*.txt
    → MySQL charging_screen（TRUNCATE + LOAD DATA LOCAL，必要时 INSERT）
    → Flask :5000  /api/overview  /api/charts/<name>  /api/forecast/*
    → 浏览器大屏与 #/forecast
```

重跑数仓：

```bash
LOAD_DT=2026-09-16 MODE=hdfs bash hive/scripts/load_ods.sh
MYSQL_RESET_SCHEMA=1 bash run_etl_all.sh 2026-09-16
```

`setup_phase2_ubuntu.sh` 默认只建 MySQL Schema 并启动 Flask，**不自动重跑 Spark**。需要重算时再 `RUN_SPARK=1`（要求 HDFS 已启动）或手动执行上面的脚本。

HDFS 在本仓库安装脚本中的约定：

| 项 | 值 |
|---|---|
| NameNode RPC | **8020**（避开 Qt 9000） |
| 数仓根目录 | `/warehouse/charging_pile` 或 `/warehouse/charging_pile_orc` |
| Web | NameNode `9870`，YARN `8088` |

## 分析规模（扩容后，答辩常用口径）

充电站约 3024 座（融合北京 POI）、订单约 5.5 万（清洗后 54,944）、遥测约 2.5 万、用户约 2556。扩容规则见 `bigscreen/docs/数据扩容生成规则.md`。图表与接口清单见 `bigscreen/README.md` 和 `bigscreen/docs/正式SparkSQL_ORC_ETL与大屏接口.md`。

## 不要做的事

- 不要再维护第二套大屏副本。
- 不要对 Ubuntu 3.10 整包安装 `ml/requirements.txt` 来“顺便”跑大屏。
- 不要把分析大屏的入口说成 `:8080`。
