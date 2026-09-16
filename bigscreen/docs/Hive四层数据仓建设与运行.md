# 四层数据仓建设与运行

本文描述当前正式数仓，不包含已移除的 CSV 清洗、CSV ADS 或自动推断 MySQL Schema 的旧链路。

## 1. 分层与引擎

```text
data/raw_expanded/*.csv
  → Hive LOAD DATA
ODS：charging_ods，TextFile，dt 分区
  → Spark SQL
DWD：charging_dwd，ORC + Snappy，load_dt / biz_date 分区
  → Spark SQL
DWS：charging_dws，ORC + Snappy，load_dt 分区
  → Spark SQL
ADS：charging_ads，ORC + Snappy，load_dt 分区
  → Spark 读取 ORC，导出 HDFS 管道符 TXT
  → MySQL → Flask → Vue/DataV
```

| 层 | 存储与分区 | 目的 |
| --- | --- | --- |
| ODS | 外部 TextFile；`dt` | 三张原始 CSV 的贴源副本，不改变业务字段 |
| DWD | 外部 ORC + Snappy；`load_dt,biz_date` | 清洗、类型规范、维度关联和明细派生 |
| DWS | 外部 ORC + Snappy；`load_dt` | 复用型日、小时、站点、用户和电池汇总 |
| ADS | 外部 ORC + Snappy；`load_dt` | 一图一表的大屏主题指标和辅助状态表 |

默认根目录是 `/warehouse/charging_pile_orc`，可用 `WAREHOUSE_ROOT` 覆盖。`dt/load_dt` 是装载批次；`biz_date` 是订单实际业务日期。全量历史 CSV 不应在不同 `LOAD_DT` 下重复加载后再做跨批次汇总。

ODS 使用 Hive `LOAD DATA`。DWD、DWS、ADS 的 DDL、INSERT OVERWRITE、验证均由 `spark-sql` 直接执行，**不是 Hive on Spark**。

## 2. 文件职责

```text
hive/hql/
  00_create_databases.hql       创建 charging_ods/dwd/dws/ads
  01_create_ods_tables.hql      ODS TextFile 外部表
  02_load_ods_{local,hdfs}.hql  本地/HDFS staging 的 LOAD DATA
  03_create_dwd_tables.hql      DWD ORC 表
  03_build_dwd.sql              Spark SQL 清洗与 DWD 写入
  04_create_dws_tables.hql      DWS ORC 表
  05_build_dws.hql              Spark SQL DWS 聚合
  06_create_ads_tables.hql      ADS ORC 表
  07_build_ads.hql              Spark SQL ADS 指标
  08_validate_warehouse.hql     分层行数与质量校验

hive/scripts/
  load_ods.sh                   ODS 采集入口
  run_etl_all.sh                DWD → DWS → ADS → TXT → MySQL
  export_ads_to_local_text.sh   ADS ORC 导出本地管道符 TXT
  build_warehouse.sh            ODS + run_etl_all 的组合入口
```

## 3. ODS 采集

`load_ods.sh` 要求 `LOCAL_RAW` 中包含：

```text
nvv2t.csv             订单
dsv13r2.csv           电池遥测
nvv2t_md_end.csv      站点维度
```

脚本会创建不含表头的 `/tmp` 临时副本，原 CSV 不被修改。`MODE=local` 使用 `LOAD DATA LOCAL`；`MODE=hdfs` 先上传至 `STAGING_ROOT/<load_dt>`，再使用 `LOAD DATA INPATH`。后者是答辩中可展示的 HDFS 采集模式。

```bash
cd /root/Charging_Pile_System/bigscreen
LOAD_DT=2026-09-16 MODE=hdfs \
  LOCAL_RAW="$PWD/data/raw_expanded" \
  WAREHOUSE_ROOT=/warehouse/charging_pile_orc \
  bash hive/scripts/load_ods.sh
```

## 4. DWD 清洗口径

1. 按 `sessionId` 去重，关键字段为空即拒绝。
2. 将 `0014/0015` 年份修复为 2014/2015，并解析时间。
3. 显式转换电量、金额、时长、电压、电流、温度等数值字段。
4. 订单电流取绝对值；剔除电量不在 `(0,40]` kWh、时长不在 `(0,12]` 小时、金额为负等异常订单。
5. 保留 0 元订单，用于支付率与收入结构；关联站点维度及 `esd=sessionId` 的电池遥测。
6. 派生行政区、道路、峰平谷、工作日/周末、平均功率、电芯压差和温升。
7. `record_time` 含 `2.02E+13` 等精度不可恢复值，明确不伪造时间。

扩容基线：ODS 为订单 55,000、遥测 24,816、站点 3,024；当前规则下 DWD 有效订单为 54,944，异常订单为 56。实际答辩以指定批次的 `ads_data_quality` 和验证日志为准。

## 5. ETL 与 MySQL 同步

```bash
# ODS 完成后；首次需要重建正式 ADS MySQL 表时才设 MYSQL_RESET_SCHEMA=1
MYSQL_RESET_SCHEMA=1 bash run_etl_all.sh 2026-09-16

# 后续重跑
bash run_etl_all.sh 2026-09-16
```

`run_etl_all.sh` 使用 `set -euo pipefail`：DWD、DWS、ADS、分层校验、ORC 导出、MySQL 导入每一步单独写入 `logs/etl/<load_dt>/`，出错立即停止。

Spark 从 ADS ORC 分区导出无表头 UTF-8 管道符文本到 `output/mysql_stage/<load_dt>/`。导入端在每张表导入前验证 TXT 存在、非空、列数正确，再执行 `TRUNCATE` 与 `LOAD DATA LOCAL INFILE`。TXT 属于可再生产物，已被 Git 忽略。

ADS 共 19 张表：16 张图表表加 `ads_overview`、`ads_data_quality`、`ads_pipeline_info` 三张辅助表。详细的一图一表映射见 [`正式SparkSQL_ORC_ETL与大屏接口.md`](正式SparkSQL_ORC_ETL与大屏接口.md)。

## 6. 单机与集群执行

单机伪分布式：

```bash
source deploy/hive_env.sh
LOAD_DT=2026-09-16 MODE=hdfs SPARK_MASTER='local[2]' \
  bash deploy/run_warehouse_local.sh
```

多虚拟机集群：确保所有节点共享 Hadoop/Hive 配置和兼容的 Python 3.11/3.12，然后执行：

```bash
LOAD_DT=2026-09-16 MODE=hdfs SPARK_MASTER=yarn \
  bash deploy/spark_submit.sh
```

集群不能使用 `localhost` 作为 HDFS、YARN、Metastore 地址；应使用可达主机名或局域网 IP。详细环境配置见 [`环境与部署模式配置.md`](环境与部署模式配置.md)。
