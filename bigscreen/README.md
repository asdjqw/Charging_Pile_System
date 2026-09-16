# 北京市充电桩运营数据可视化大屏

`bigscreen/` 是充电桩管理系统第二阶段的数据工程与可视化子项目。它使用 Hadoop/HDFS、Hive ODS、Spark SQL、MySQL、Flask、Vue3、DataV 与 ECharts，展示扩容后的充电订单、站点和电池遥测数据。

## 正式数据链路

```text
CSV
  → Hive LOAD DATA / ODS TextFile（按 dt 分区）
  → Spark SQL / DWD ORC + Snappy
  → Spark SQL / DWS ORC + Snappy
  → Spark SQL / ADS ORC + Snappy
  → HDFS 管道符 TXT
  → output/mysql_stage/<load_dt>/*.txt
  → MySQL（TRUNCATE + LOAD DATA LOCAL INFILE）
  → Flask API
  → Vue3 + DataV + ECharts 大屏
```

ODS 使用 Hive `LOAD DATA` 保存贴源 TextFile；DWD、DWS、ADS 的表创建、清洗和聚合均由 `spark-sql` 执行，不使用旧 PySpark CSV 脚本或 Hive on Spark。DWD/DWS/ADS 统一为 **ORC + Snappy**。

## 数据与分析

- 原始扩容数据：`data/raw_expanded/`，含 55,000 笔订单、24,816 条遥测和 3,024 座站点。
- DWD 清洗：修复 `0014/0015` 年份、主键去重、关键字段校验、异常订单剔除、订单/站点/遥测关联和指标派生。
- ADS 共 19 张表：16 张图表数据表及总览、质量、链路状态 3 张辅助表。
- 分析维度包括日/月趋势、小时负荷、星期×小时、站点、站型、工作日/周末、峰平谷、平台、行政区、时长、电量、用户分层、电池健康与收入结构等，满足不少于 8 个维度和多组对比分析要求。

## 快速运行

### 1. 安装 Python 和前端依赖

```bash
cd /root/Charging_Pile_System/bigscreen
python3.12 -m venv .venv
.venv/bin/python -m pip install -r requirements.txt

cd frontend
npm ci
npm run build
cd ..
```

Node.js 的答辩环境要求为 23+，前端采用 Vue 3。

### 2. 配置 MySQL

```bash
cp config/database.env.example config/database.env
# 编辑 config/database.env，填写 DB_HOST、DB_USER、DB_PASSWORD 等真实连接信息
```

`config/database.env` 仅存放本机凭据，已被 Git 忽略。首次导入正式 ADS 表时使用：

```bash
MYSQL_RESET_SCHEMA=1 bash run_etl_all.sh 2026-09-16
```

之后同一 Schema 的普通重跑：

```bash
bash run_etl_all.sh 2026-09-16
```

脚本会先校验 19 份 TXT；每张表再执行 `TRUNCATE` 和 `LOAD DATA LOCAL INFILE`，因此可重复运行且不会累加旧数据。

### 3. 构建 ODS 与数仓

单机伪分布式环境先启动 Hadoop/Hive（首次安装方式见 `docs/环境与部署模式配置.md`）：

```bash
source deploy/hive_env.sh
LOAD_DT=2026-09-16 MODE=hdfs SPARK_MASTER='local[2]' \
  bash deploy/run_warehouse_local.sh
```

集群答辩可在具备 HDFS、Hive Metastore 和 YARN 配置的节点运行：

```bash
LOAD_DT=2026-09-16 MODE=hdfs SPARK_MASTER=yarn \
  bash deploy/spark_submit.sh
```

也可以把两个阶段拆开执行：

```bash
LOAD_DT=2026-09-16 MODE=hdfs bash hive/scripts/load_ods.sh
bash run_etl_all.sh 2026-09-16
```

`run_etl_all.sh` 采用 `set -euo pipefail`，按 DWD → DWS → ADS → TXT 导出 → MySQL 导入逐步记录日志到 `logs/etl/<load_dt>/`，任一阶段失败立即停止。

### 4. 启动大屏

```bash
PORT=5000 .venv/bin/gunicorn -c deploy/gunicorn.conf.py backend.wsgi:application
```

访问 `http://127.0.0.1:5000/`。局域网访问时 Flask 监听 `0.0.0.0`，使用部署机器的实际 IP，例如 `http://<flask-host>:5000/`。

## 大屏接口与表的对应关系

每张图表只调用一个 Flask 接口，接口只查询一张同名的 MySQL ADS 表。16 个图表对应关系、TXT 规范和导入校验见 [`docs/正式SparkSQL_ORC_ETL与大屏接口.md`](docs/正式SparkSQL_ORC_ETL与大屏接口.md)；字段说明见 [`docs/MySQL数据库Schema说明.md`](docs/MySQL数据库Schema说明.md)。

## 目录说明

```text
bigscreen/
├── data/raw_expanded/        55,000 条模拟扩容原始 CSV
├── hive/hql/                 ODS 与 Spark SQL 分层建表/ETL SQL
├── hive/scripts/             ODS 加载、ETL、ORC 导出与验证脚本
├── mysql/                    固定 Schema 与 TXT 幂等导入脚本
├── spark/jobs/               扩容数据生成、ADS ORC 导出程序
├── backend/                  Flask API（MySQL 数据源）
├── frontend/                 Vue3 + DataV + ECharts
├── deploy/                   单机伪分布式与集群部署入口
├── docs/                     环境、数仓、答辩和数据口径说明
└── output/mysql_stage/       ORC 导出 TXT（运行产物，Git 忽略）
```

## 相关文档

- [`docs/正式SparkSQL_ORC_ETL与大屏接口.md`](docs/正式SparkSQL_ORC_ETL与大屏接口.md)：正式 ETL、ORC、TXT、接口契约。
- [`docs/Hive四层数据仓建设与运行.md`](docs/Hive四层数据仓建设与运行.md)：ODS/DWD/DWS/ADS 表、分区、清洗和验证。
- [`docs/环境与部署模式配置.md`](docs/环境与部署模式配置.md)：Python、Hadoop、Hive、MySQL、单机与多虚拟机配置。
- [`docs/答辩演示流程.md`](docs/答辩演示流程.md)：答辩演示步骤。
- [`docs/数据扩容生成规则.md`](docs/数据扩容生成规则.md)：55,000 条模拟数据的来源和可复现规则。
