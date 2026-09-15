# Hive 四层数据仓建设与运行

部署模式、系统依赖、单机与多虚拟机地址配置请先阅读 [`环境与部署模式配置.md`](环境与部署模式配置.md)。本文专注于 Hive 四层表结构、加载脚本和数仓运行。

## 1. 建设目标

项目采用“离线批量采集 + Hive LOAD + 外部表 ODS + PySpark DWD + HQL DWS/ADS”的模式。Hive 表数据存放在 HDFS，MySQL 只保存 Flask 大屏需要高频查询的结果，不承担原始数据仓职责。

```text
本地 CSV / HDFS staging
  -> Hive LOAD DATA
charging_ods（贴源外部表，dt 装载日分区）
  -> 原项目 PySpark 清洗规则
charging_dwd（规范明细，load_dt + biz_date 分区）
  -> HQL 公共聚合
charging_dws（公共汇总，load_dt 分区）
  -> HQL 主题加工
charging_ads（大屏主题，load_dt 分区）
  -> 导出/同步 MySQL -> Flask -> Vue3 + DataV
```

## 2. 目录、库和分区规范

默认 HDFS 根目录为 `/warehouse/charging_pile`，可通过 `WAREHOUSE_ROOT` 修改。

| 层 | Hive 库 | 默认 HDFS 目录 | 分区 | 作用 |
| --- | --- | --- | --- | --- |
| ODS | `charging_ods` | `/warehouse/charging_pile/ods` | `dt` | 按装载日期保存原始字符串，不改变源值 |
| DWD | `charging_dwd` | `/warehouse/charging_pile/dwd` | `load_dt,biz_date` | 类型转换、时间修复、去重、异常剔除、维度关联 |
| DWS | `charging_dws` | `/warehouse/charging_pile/dws` | `load_dt` | 日、站点、小时、类型、用户、电池公共汇总 |
| ADS | `charging_ads` | `/warehouse/charging_pile/ads` | `load_dt` | 面向大屏的 10 张主题分析表 |

`dt/load_dt` 表示文件装载批次；`biz_date` 表示订单真实发生日期。两者不能混用。当前一批 CSV 覆盖多个历史业务日期，所以 ODS 必须按装载日分区，DWD 清洗后再按业务日组织明细。

ODS、DWD、DWS、ADS 均为 Hive 外部表。ODS 是 CSV/TEXTFILE；其余三层统一使用 Parquet + Snappy。加载脚本先在 `/tmp` 创建去表头副本，再执行 Hive LOAD；源 CSV 不会改变，任务结束后临时副本自动删除。这样可避免 Hive CLI 与 Spark SQL 对 `skip.header.line.count` 支持不一致。

## 3. 文件清单

```text
hive/
├── hql/
│   ├── 00_create_databases.hql     四层数据库
│   ├── 01_create_ods_tables.hql    三张 ODS 外部表
│   ├── 02_load_ods_local.hql       从本机 Hive LOAD
│   ├── 02_load_ods_hdfs.hql        从 HDFS staging Hive LOAD
│   ├── 03_create_dwd_tables.hql    DWD 表结构
│   ├── 04_create_dws_tables.hql    DWS 表结构
│   ├── 05_build_dws.hql            DWS 聚合
│   ├── 06_create_ads_tables.hql    ADS 表结构
│   ├── 07_build_ads.hql             ADS 主题指标
│   └── 08_validate_warehouse.hql   分层数量与质量检查
└── scripts/
    ├── load_ods.sh                 ODS 采集封装
    ├── build_warehouse.sh          四层数仓一键构建
    └── validate_warehouse.sh       独立验证
```

DWD 作业为 `spark/jobs/hive_dwd.py`。它直接调用 `etl_clean.py` 的清洗函数，因此本地旧链路与 Hive 新链路不会形成两套清洗口径。

## 4. 首次运行前提

集群各节点需已安装并配置 Hadoop 3.x、Hive 和 Spark，客户端机器能够执行：

```bash
hdfs dfs -ls /
hive -e 'SHOW DATABASES;'
spark-submit --version
```

`hive-site.xml` 必须位于 Spark 可读取的配置目录（通常是 `$SPARK_HOME/conf`），并指向与 Hive CLI 相同的 Metastore。若使用 Beeline，可设置例如：

```bash
export HIVE_CMD='beeline -u jdbc:hive2://master:10000/default'
```

集群模式不要写死 `localhost`。`fs.defaultFS`、ResourceManager、Metastore 地址应统一使用主机名或局域网 IP，并保证所有虚拟机能互相解析和访问。

### 本机单机伪分布式安装

本项目提供可重复执行的安装和启停脚本。安装采用 Hive 3.1.3、MySQL Metastore，并将运行文件放入已忽略提交的 `.runtime`：

```bash
cd /root/Charging_Pile_System/bigscreen
bash deploy/setup_hive_local.sh
bash deploy/start_hive_local.sh
```

本次已安装并验证的组合为：Python 3.12、PySpark 3.5.3、Hadoop 服务端
3.5.0（Java 17）、Hive/HiveServer2 3.1.3（Java 8）、Hive 使用的 Hadoop
客户端 3.3.6、MySQL 8.0.46、Connector/J 8.4.0。OpenJDK 11 也保留给
普通 Spark/兼容性调试使用。以上 Java/Hadoop/Hive/MySQL 属于系统或 `.runtime`
依赖，不应写成 pip 包；Python 依赖仍统一由 `requirements.txt` 管理。

Ubuntu 24.04 上 Hive 3.1.3/HiveServer2 使用 OpenJDK 8u371+；现有 Hadoop 3.5.0 守护进程继续使用 Java 17。由于本机 Hadoop 3.5.0 本身由 Java 17 编译，安装脚本会额外部署 Hadoop 3.3.6 客户端供 Hive 使用，两套 Hadoop 并存但访问同一个 HDFS。脚本还会处理 Hive/Hadoop 的 Guava 版本冲突，并补齐 Metastore 使用的 Commons Collections 3.x。

本机服务地址：

```text
HDFS             hdfs://127.0.0.1:9000
NameNode UI      http://127.0.0.1:9870
YARN UI          http://127.0.0.1:8088
Hive Metastore   thrift://127.0.0.1:9083
HiveServer2      jdbc:hive2://127.0.0.1:${HIVE_SERVER2_PORT:-10000}/default
MySQL Metastore  hive_metastore（与 charging_screen 分离）
```

本机端口 `10000` 曾被其他进程占用，因此本次实际安装使用 `10050`。安装时可配置：

```bash
HIVE_SERVER2_PORT=10050 bash deploy/setup_hive_local.sh
source deploy/hive_env.sh
bash deploy/start_hive_local.sh
beeline -u 'jdbc:hive2://127.0.0.1:10050/default' -n root -e 'SHOW DATABASES;'
```

停止全部本地大数据服务：

```bash
bash deploy/stop_hive_local.sh
```

## 5. 一键构建

默认从已纳入仓库的 55,000 条扩容订单采集，装载日期建议明确传入：

```bash
cd /root/Charging_Pile_System/bigscreen
source deploy/hive_env.sh
LOAD_DT=2026-09-15 \
LOCAL_RAW="$PWD/data/raw_expanded" \
MODE=hdfs \
SPARK_MASTER='local[2]' \
SPARK_SUBMIT="$PWD/.venv/bin/spark-submit" \
ANALYTICS_SQL_CMD="$PWD/.venv/bin/spark-sql --master local[2]" \
bash hive/scripts/build_warehouse.sh
```

这里的 Spark 使用本地执行器是为了避免单机为每张小汇总表反复启动 YARN
Application；HDFS、Hive 外部表、MySQL Metastore、分区和 LOAD 链路均为正式形态。
集群答辩时去掉 `ANALYTICS_SQL_CMD`，并将 `SPARK_MASTER` 改为 `yarn` 即可。

正式集群也可以先上传到 HDFS staging，再由 Hive LOAD 移动到 ODS：

```bash
LOAD_DT=2026-09-15 \
MODE=hdfs \
LOCAL_RAW="$PWD/data/raw_expanded" \
STAGING_ROOT=/tmp/charging_pile_staging \
SPARK_MASTER=yarn \
bash hive/scripts/build_warehouse.sh
```

常用覆盖参数：

| 变量 | 默认值 | 含义 |
| --- | --- | --- |
| `LOAD_DT` | 当天 | 装载批次 `yyyy-MM-dd` |
| `MODE` | `local` | `local` 或 `hdfs` |
| `LOCAL_RAW` | `data/raw_expanded` | 三张扩容 CSV 所在目录 |
| `WAREHOUSE_ROOT` | `/warehouse/charging_pile` | 四层 HDFS 根目录 |
| `STAGING_ROOT` | `/tmp/charging_pile_staging` | HDFS 临时采集目录 |
| `HIVE_CMD` | `hive` | Hive CLI 或 Beeline 命令 |
| `ANALYTICS_SQL_CMD` | 与 `HIVE_CMD` 相同 | DWS/ADS/验证所用 SQL 引擎；单机可设为 Spark SQL |
| `SPARK_SUBMIT` | `spark-submit` | Spark 提交程序 |
| `SPARK_MASTER` | `yarn` | `yarn` 或本地测试用 `local[*]` |

脚本检测到项目 `.venv` 时会自动把 Driver 和 Worker 都锁定到该 Python。多机 YARN 环境应保证相同路径在每台工作节点存在；若路径不同，应预先设置 `PYSPARK_PYTHON` 为集群各节点共有的 Python 3.11/3.12 路径，避免 Driver/Worker 小版本不一致。

## 6. DWD 清洗口径

DWD 保留原项目方法：

1. `sessionId` 业务主键去重，关键字段为空则拒绝；
2. `0014/0015` 年份按已验证规则加 2000，解析为时间戳；
3. 电量、金额、时长、电压、电流、温度显式转为数值类型；
4. 电流取绝对值，统一充电方向口径；
5. 剔除电量小于等于 0、超过 40kWh、时长小于等于 0、超过 12 小时、金额为负的订单；
6. 保留 0 元订单，用于支付率和收入结构分析；
7. 订单关联站点维度，遥测通过 `esd=sessionId` 关联订单；
8. 派生行政区、道路、峰平谷、工作日/周末、平均功率、电芯压差和温升；
9. `record_time` 原值只有 `2.02E+13` 等有限有效数字，精度不可恢复，明确丢弃而不伪造时间。

## 7. DWS 与 ADS 内容

DWS 包含 6 张可复用汇总表：日运营、站点运营、小时运营、站点类型、用户运营、电池健康。

ADS 包含 10 张主题表：运营总览、日趋势、站点 TOP、小时负荷、站点类型对比、工作日/周末对比、峰平谷对比、平台对比、行政区对比、电池健康。分析维度不少于 8 个，且包含多组双维或多维对比。

现有 `spark/jobs/analysis.py` 仍负责生成当前 MySQL/Flask 大屏的完整 23 张交换表。本次 Hive ADS 是数仓内的标准主题层；后续可选择用 Sqoop、DataX 或 Spark JDBC 将 Hive ADS 同步到 MySQL。当前已有 `load_mysql.py` 读取 CSV 的稳定路径继续保留，不影响试运行。

## 8. 验证与重跑

独立验证指定批次：

```bash
LOAD_DT=2026-09-15 bash hive/scripts/validate_warehouse.sh
```

扩容数据的预期基线为：ODS 订单 55,000、遥测 24,816、站点 3,024；按当前规则 DWD 有效订单约 54,944。最终以脚本输出的数据质量表为准。

2026-09-15 本机正式链路实跑结果：ODS 为 `55000/24816/3024`，DWD 为
`54944/24816/3024`，异常订单 56 条；DWS 六张表行数依次为
`321/2993/48/4/2556/39`，ADS 十张表行数依次为
`1/321/15/24/4/2/3/3/16/39`。

同一 `LOAD_DT` 重跑采用 `OVERWRITE`，覆盖该批次，不重复累加。使用新的 `LOAD_DT` 会保留历史装载批次。不要把同一份全量历史 CSV 每天用新日期装载，否则跨批次查询会重复统计。

## 9. 常见故障

- ODS 多出 1 行：确认通过 `load_ods.sh` 装载；不要绕过脚本直接 LOAD 带表头的 CSV。
- Spark 查不到 Hive 表：检查 Spark 读取的 `hive-site.xml` 和 Metastore URI。
- HDFS LOAD 后 staging 文件消失：`LOAD DATA INPATH` 是移动；脚本下次会重新上传。`LOAD DATA LOCAL` 是复制。
- ADS 为 0 行：先按 ODS → DWD → DWS 顺序检查相同 `load_dt`。
- 小文件过多：ODS 保留原始批次文件；DWD 按日分区，DWS/ADS 只按批次分区，避免过度分区。
