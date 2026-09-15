# 北京市充电桩运营数据可视化大屏

> **所属项目**：本项目是《充电桩综合管理系统》中的数据大屏与分析平台子模块（Qt 业务系统 + Spark/Flask/DataV 大屏，
> 合并后的总说明见仓库根目录 `README.md`）；既可在合并工程里通过 `bigscreen/` 访问，也可作为独立工程单独运行。
>

> **一句话介绍**：把充电桩订单、电池遥测、充电站三张原始表，用 **Spark** 完成数据清洗与 15 个维度的统计分析，
> 结果落到 **MySQL**，由 **Flask** 提供 REST 接口，前端用 **Vue3 + DataV + ECharts** 渲染成 16 个面板的可视化大屏；
> 数据同时存储在 **Hadoop 3.x（HDFS）**，作业支持提交到 **Spark on YARN**。

![大屏预览](docs/大屏预览.png)

---

## 一、项目要求对照

| 项目要求 | 本项目实现 |
| --- | --- |
| Python 3.11 或 3.12 | 清洗/分析/后端全部运行在 Python **3.12**（虚拟机实测 3.12.13） |
| 文件存储：本地测试 + 答辩放 Hadoop 3.x | 本地默认读写 `data/`、`output/`；答辩模式把原始数据与结果存入 **HDFS**（Hadoop 3.2.1） |
| 使用 Spark 做清洗与分析，分析维度 ≥ 8，至少两组对比分析 | **15 个分析维度**，其中 **5 组对比分析**（站点类型、工作日 vs 周末、峰平谷、平台、行政区） |
| 使用 Flask 处理 Web 请求并响应数据 | **23 个 REST 接口**（含大屏首屏聚合接口），30 秒内存缓存，MySQL 不可用时自动切 CSV 兜底 |
| MySQL 版本不限 | MySQL 8.0，库 `charging_screen`，**27 张表**（明细表 + 分析结果表） |
| Node.js 23 及以上，前端 Vue3 | Node.js **23.11.1** + Vue **3.5** + Vite 构建（`package.json` 声明 `"node": ">=23"`） |
| 使用 DataV 大屏展示，图表类型丰富、不单一 | DataV（边框盒/装饰/滚动榜/锥形柱/环形图/水球图）+ ECharts **16 类图表**，共 16 个面板 |
| 大屏双主题（可选加分项） | 顶部按钮一键切换 **暗色 / 亮色** 两套配色，全部图表与组件同步换肤，支持 `?theme=light` 直达 |
| 与 Charging_Pile_System 集成 | 用本大屏**替换**对方 `web/` 运营大屏，并融合对方的北京充电站 POI 数据**扩容**本项目数据 |

## 二、系统架构

```
 data/raw_expanded/*.csv（或 HDFS /data/charging/raw_expanded）
          │
          ▼  ① Spark 清洗   spark/jobs/etl_clean.py
   清洗宽表：session_detail / battery_detail / station_dim（parquet + csv）
          │
          ▼  ② Spark 分析   spark/jobs/analysis.py   （15 个维度、5 组对比）
   分析结果：output/ads/*.csv（26 张交换表：23 张 ADS + 3 张明细/维度）
          │
          ▼  ③ 装载 MySQL   spark/jobs/load_mysql.py （自动建表、建索引）
        MySQL  charging_screen
          │
          ▼  ④ Flask 接口   backend/app.py （23 个 REST 接口 + 30s 缓存 + CSV 兜底）
          │
          ▼  ⑤ 可视化       frontend/  Vue3 + DataV + ECharts（60 秒自动刷新，1920×1080 等比缩放）
```

虚拟机上的完整链路（已实测跑通）：**HDFS 原始数据 → Spark on YARN 清洗与分析 → 结果写回 HDFS（parquet + csv）→ 取回本地 → 装载 MySQL → Flask 接口 → 大屏展示**。

新增的标准 Hive 数仓链路为：**Hive LOAD 分区采集 → ODS 外部表 → PySpark DWD → HQL DWS → HQL ADS**。表结构、脚本参数、集群运行和验证方法见 [`docs/Hive四层数据仓建设与运行.md`](docs/Hive四层数据仓建设与运行.md)。原 Spark/MySQL 试运行链路继续保留。

单机伪分布式与多虚拟机集群的完整环境依赖、地址配置、节点角色、端口和启动检查见 [`docs/环境与部署模式配置.md`](docs/环境与部署模式配置.md)。

## 三、Hadoop 使用说明（HDFS 存储 + YARN 计算）

项目**确实使用了 Hadoop 3.x**，不是只连 MySQL：

| 使用方式 | 具体做法 |
| --- | --- |
| 文件存储 | 原始数据与计算结果全部放在 HDFS：`/user/bit/charging-bigscreen/{raw_expanded,warehouse,ads}`，结果同时输出 parquet 与 csv |
| 计算引擎 | `SPARK_MASTER=yarn` 时把 Spark 清洗 + 分析作业提交到 **YARN** 运行（客户端模式，驱动在本地、执行器在 YARN 容器） |
| 结果回流 | 用 `hdfs dfs -getmerge` 把 HDFS 上的结果表取回本地，再装载 MySQL 供 Flask / 大屏查询 |
| 大屏可见 | 大屏顶部有 **「存储 HDFS (Hadoop)」「计算 Spark on YARN」** 两个标识，数据来自作业写入的 `ads_pipeline_info` 表 |

```bash
# 一键：上传原始数据到 HDFS → 提交 Spark on YARN → 结果取回 → 装载 MySQL
bash deploy/spark_submit.sh
# 如需临时使用未扩容的小数据：LOCAL_RAW=data/raw HDFS_RAW=/data/charging/raw bash deploy/spark_submit.sh

# 分步执行（本地模式与 HDFS 模式是同一份代码，只差路径参数）
source deploy/hadoop_env.sh && export SPARK_MASTER=yarn
export PYSPARK_PYTHON=$PWD/.venv/bin/python
.venv/bin/python spark/jobs/run_all.py \
  --raw       hdfs://bitdev:9000/user/bit/charging-bigscreen/raw_expanded \
  --warehouse hdfs://bitdev:9000/user/bit/charging-bigscreen/warehouse \
  --ads       hdfs://bitdev:9000/user/bit/charging-bigscreen/ads
bash deploy/fetch_from_hdfs.sh && .venv/bin/python spark/jobs/load_mysql.py
```

验证 Hadoop 确实在工作（答辩时可现场演示）：

```bash
source deploy/hadoop_env.sh
hdfs dfs -ls /user/bit/charging-bigscreen            # raw_expanded / warehouse / ads 三个目录
hdfs dfs -du -h /user/bit/charging-bigscreen         # 各目录占用（raw 523K、warehouse 1.5M、ads 1.2M）
yarn application -list -appStates ALL | grep SPARK   # 已完成的 Spark 应用（ChargingPile-Batch，SUCCEEDED）
```

- NameNode Web UI：<http://192.168.44.129:9870>
- YARN Web UI：<http://192.168.44.129:8088>
- 已提交并成功的 YARN 应用：`application_1789135071729_0005 / 0006 / 0007`（应用名 `ChargingPile-Batch`，类型 SPARK，Final-State SUCCEEDED）

每次作业都会把「运行时间 / 计算引擎 / 存储位置 / 输入输出路径 / 记录数」写入 `ads_pipeline_info` 表，
接口 `GET /api/pipeline` 可查询，例如当前为：`Spark on YARN` + `HDFS (Hadoop)` + `54944 条有效订单`。

## 四、目录结构

```
charging-bigscreen/
├─ README.md                    本文件：项目说明与操作手册
├─ data/raw/                    原始数据（3 个 CSV，可直接替换成新数据）
│   ├─ nvv2t.csv                充电订单明细   3395 行
│   ├─ dsv13r2.csv              电池充电遥测   1594 行
│   └─ nvv2t_md_end.csv         充电站维度表   105 行
├─ spark/jobs/
│   ├─ etl_clean.py             ① 数据清洗：时间修复、去重、异常剔除、维度关联、指标派生
│   ├─ analysis.py              ② 多维分析：15 个维度 / 5 组对比，产出 ads_* 结果表
│   ├─ run_all.py               一键执行清洗 + 分析（支持 --raw/--warehouse/--ads 指定 HDFS 路径）
│   └─ load_mysql.py            ③ 结果装载 MySQL（自动推断列类型、建索引、幂等重建表）
├─ backend/                     Flask 后端
│   ├─ app.py                   全部 REST 接口 + 静态托管前端 dist
│   ├─ db.py                    连接池、TTL 缓存、CSV 兜底数据源
│   ├─ config.py                读取 config/database.env 与环境变量
│   ├─ wsgi.py                  gunicorn 入口
│   └─ requirements.txt         Flask / flask-cors / PyMySQL / gunicorn
├─ frontend/                    Vue3 + DataV 大屏
│   ├─ src/views/Screen.vue     大屏布局（16 个面板）与数据加载
│   ├─ src/charts/options.js    16 类图表的 ECharts 配置构造器
│   ├─ src/components/          HeaderBar（标题栏）、KpiBar（翻牌器/环形图/水球图）、
│   │                           PanelBox（DataV 边框面板）、EChart（图表容器）、
│   │                           RealtimeBoard（滚动榜）、CountUp（数字滚动）
│   ├─ src/api/index.js         接口封装
│   ├─ dist/                    已构建产物（Flask 直接托管，无需再装 Node 也能跑）
│   └─ package.json             依赖与构建脚本（node >= 23）
├─ config/database.env.example  数据库配置模板（复制为忽略提交的 database.env）
├─ sql/charging_screen.sql      MySQL 备份快照（可还原；当前表以流水线输出为准）
├─ output/
│   ├─ warehouse/               清洗层结果（Spark 输出）
│   └─ ads/                     分析层结果 26 张 CSV（大屏数据源，可离线查看）
├─ deploy/
│   ├─ deploy.sh                一键部署：依赖 → MySQL 初始化 → Spark → 前端构建 → 启动服务
│   ├─ setup_hadoop.sh          没有 Hadoop 时一键搭伪分布式（HDFS + YARN）
│   ├─ hadoop_env.example.sh    Hadoop 环境变量模板（复制为 hadoop_env.sh 使用）
│   ├─ spark_submit.sh          HDFS + Spark on YARN 全链路（上传数据、提交作业、取回结果、装载 MySQL）
│   ├─ fetch_from_hdfs.sh       把 HDFS 上的结果表 getmerge 回本地
│   ├─ run_pipeline.sh          重跑离线计算（数据更新后刷新大屏）
│   ├─ install_service.sh       注册 systemd 服务 + nginx 反向代理（开机自启）
│   ├─ gunicorn.conf.py         gunicorn 生产配置
│   └─ systemd/、nginx/         服务与反向代理配置模板
├─ docs/
│   ├─ 大屏预览.png             实际运行截图
│   ├─ 答辩要点.md              清洗发现、维度设计、可直接口述的结论
│   ├─ 答辩演示流程.md          10 分钟演示脚本 + 常见提问应答
│   └─ 虚拟机部署记录.md        虚拟机实际部署状态、命令与踩坑记录
├─ start_backend.bat            Windows 本地启动后端
├─ data/external/               外部数据（对方项目的北京充电站 POI）
│   └─ 北京市充电桩数据.csv     3025 条北京充电站 POI（用于扩容站点维度）
├─ data/raw_expanded/           默认原始数据（3 张扩容 CSV，已纳入 Git，可直接运行）
└─ run_pipeline.bat             Windows 本地一键跑离线计算
```

## 五、数据扩容（融合对方数据 + 增加数据量）

原始数据只有 105 座站、3395 单，其中**周末仅 85 单、谷时段仅 17 单**，统计结论不稳定；
站点维度也没有经纬度与区县信息。为此新增 `spark/jobs/generate_expanded_data.py`：
以**本项目数据为主**（原始订单原样保留），融合 Charging_Pile_System 的北京充电站 POI 数据扩容。

| 维度 | 扩容前 | 扩容后 | 说明 |
| --- | --- | --- | --- |
| 充电站 | 105 座（无经纬度） | **3024 座**（真实北京区县：海淀/朝阳/丰台/密云/西城…） | 站点维度来自对方 POI 数据 |
| 充电桩 | 562 台 | **11866 台** | 按站点规模分配 1~12 台 |
| 订单 | 3395 单 | **55000 单**（有效 54944） | 原始 3395 单原样保留，新增 51605 单 |
| 电池遥测 | 1594 条 | **24816 条** | 按 45% 比例随订单生成 |
| 充电用户 | 84 人 | **2314 人** | 高频池 + 长尾池，服从二八分布 |
| 周末订单占比 | 2.5% | **27.8%** | 修复"周末几乎没有数据"的不合理现象 |
| 谷时段订单占比 | 0.51% | **11.8%** | 修复夜间样本过少 |
| 有订单的日期 | 236 天 | **321 天** | 覆盖统计区间内所有自然日 |

生成规则（答辩可讲）：

1. **原始订单零改动保留**，只把站点映射到新的北京站点维度（原站点稳定映射到同一新站点，站点排行结构不变）；
2. 从原始订单学习经验分布（电量、时长、单价、平台、车队车占比），按分布外推生成新订单；
3. 时段权重按实际运营规律重排，补齐夜间与早晚高峰；周末占比由参数控制（默认 29%）；
4. 加入物理约束：单枪功率不超过 60kW（避免"0.1 小时充 25 度电"这类不合理记录）；
5. 遥测取值范围与原始遥测一致（SOC 15~80%、单体压差 10~32mV、温度 32~38℃）。

```bash
# 生成扩容数据（默认读取 data/raw 与 data/external/北京市充电桩数据.csv）
.venv/bin/python spark/jobs/generate_expanded_data.py --orders 55000 --weekend-rate 0.29
# 用扩容数据跑完整链路
.venv/bin/python spark/jobs/run_all.py --raw data/raw_expanded && .venv/bin/python spark/jobs/load_mysql.py
```

## 六、环境要求

| 组件 | 版本要求 | 说明 |
| --- | --- | --- |
| Python | 3.11 / 3.12 | 虚拟环境解释器 |
| PySpark | 3.5.3 | 清洗与分析作业 |
| Java | 11（或 8u371+/17） | Spark 运行需要；Hadoop 自身可用 Java 8 |
| MySQL | 5.7 / 8.x | 存清洗明细与分析结果 |
| Node.js | **23 及以上** | 仅前端构建需要，运行大屏不需要 |
| Hadoop（可选） | 3.x | 答辩模式用于 HDFS 存储与 YARN 计算 |

## 七、快速开始

### 7.0 从零启动的完整顺序（虚拟机重启后照着做）

```bash
# ① 启动 MySQL（后端的数据来源）
sudo systemctl start mysql
sudo systemctl status mysql | head -3          # active (running) 即正常

# ② 启动 Hadoop（HDFS + YARN，只有答辩/重算数据时才需要）
source /home/bit/charging-bigscreen/deploy/hadoop_env.sh
hdfs --daemon start namenode
hdfs --daemon start datanode
yarn --daemon start resourcemanager
yarn --daemon start nodemanager
jps                                            # 应看到 NameNode/DataNode/ResourceManager/NodeManager

# ③ 启动本项目后端（已注册 systemd 且开机自启，一般不用手动起）
sudo systemctl start charging-screen
curl http://127.0.0.1:5000/api/health          # 返回 {"code":0,...} 即正常

# ④ 启动 nginx（80 端口入口，已开机自启）
sudo systemctl start nginx

# ⑤（可选）启动对方系统 Charging_Pile_System，它的大屏就是我们的
cd /home/bit/Charging_Pile_System
export CHARGE_PILE_WEB_ROOT=/home/bit/Charging_Pile_System/web \
       CHARGE_PILE_BIND_ADDRESS=0.0.0.0 \
       CHARGE_PILE_PORT=9100 CHARGE_PILE_HTTP_PORT=8080
nohup ./build/admin_server/admin_server > /tmp/admin_server.log 2>&1 &

# ⑥ 打开大屏
#    http://192.168.44.129/                （推荐：nginx + Flask）
#    http://192.168.44.129:5000/           （Flask 直连）
#    http://192.168.44.129:8080/index.html （对方系统里的大屏）
```

### 7.1 全新机器从零部署（第一次装）

```bash
# 1) 把项目放到 /home/bit/charging-bigscreen（或 git clone 自己的仓库）
# 2) 一键部署：装 Java/Python/MySQL/Node → 建库 → 跑 Spark → 构建前端 → 起服务
bash deploy/deploy.sh
# 3) （可选）搭建 Hadoop 伪分布式（HDFS + YARN）
bash deploy/setup_hadoop.sh
# 4) （可选）HDFS + Spark on YARN 计算并装载 MySQL
cp deploy/hadoop_env.example.sh deploy/hadoop_env.sh    # 按实际 Hadoop 路径修改
bash deploy/spark_submit.sh
# 5) （可选）注册 systemd 开机自启 + nginx 反向代理
sudo bash deploy/install_service.sh
```

### 7.2 数据更新后重新计算（大屏会自动刷新）

```bash
cd /home/bit/charging-bigscreen
# 需要的话先生成扩容数据（默认融合对方的北京站点 POI）
.venv/bin/python spark/jobs/generate_expanded_data.py --poi "/home/bit/Charging_Pile_System/data/北京市充电桩数据.csv"
# 用 HDFS + Spark on YARN 重算，结果取回并装载 MySQL
source deploy/hadoop_env.sh && export SPARK_MASTER=yarn PYSPARK_PYTHON=$PWD/.venv/bin/python
.venv/bin/python spark/jobs/run_all.py \
  --raw       hdfs://bitdev:9000/user/bit/charging-bigscreen/raw_expanded \
  --warehouse hdfs://bitdev:9000/user/bit/charging-bigscreen/warehouse \
  --ads       hdfs://bitdev:9000/user/bit/charging-bigscreen/ads
bash deploy/fetch_from_hdfs.sh && .venv/bin/python spark/jobs/load_mysql.py
curl -X POST http://127.0.0.1:5000/api/cache/refresh    # 清缓存，立即生效
```

### 7.2.1 VMware 共享目录（hgfs）部署：一条命令搞定

如果项目是通过 VMware 共享目录挂载进虚拟机的（例如 `/mnt/hgfs/<共享名>/charge_pile/bigscreen`），
hgfs 不支持符号链接、chmod 也不生效，**虚拟环境不能建在共享目录里**，否则 venv 会创建失败。
部署脚本已自动处理：检测到 `/mnt/hgfs/` 路径时，会把 venv 放到 `~/.venvs/charge-pile-bigscreen`，
并把位置写入 `deploy/venv_path.sh` 供其它脚本复用。

最快的起步方式（已有 `sql/charging_screen.sql` 备份，不需要装 PySpark 与 Node）：

```bash
cd /mnt/hgfs/<共享名>/charge_pile/bigscreen       # 换成实际的共享目录路径
cp config/database.env.example config/database.env      # 默认 charging/charging123
SKIP_SPARK=1 bash deploy/deploy.sh                      # 装 MySQL/Python + 导入 SQL 备份 + 起服务
sudo bash deploy/install_service.sh                     # 可选：systemd 开机自启 + nginx
curl -s http://127.0.0.1:5000/api/health                # 看到 mysql.connected=true 即成功
```

需要在本机重算数据时（要装 PySpark，约 350MB）：

```bash
bash deploy/deploy.sh            # 不设 SKIP_SPARK，会安装 PySpark 并跑 Spark 计算
```

### 7.3 Windows 本地运行（3 步）

```bat
:: 第 1 步：安装后端与 Spark 依赖
python -m venv .venv
.venv\Scripts\pip install -r backend\requirements.txt
.venv\Scripts\pip install pyspark==3.5.3 pandas

:: 第 2 步：配置好 MySQL 后执行离线计算（清洗 → 分析 → 装载 MySQL）
::         连接信息写在 config\database.env
run_pipeline.bat

:: 第 3 步：构建前端并启动服务
cd frontend && npm install && npm run build && cd ..
start_backend.bat
```

浏览器打开 <http://127.0.0.1:5000/> 即可看到大屏（`frontend/dist` 已随项目提供，可跳过 npm 构建）。

### 7.4 Linux 虚拟机 / 服务器一键部署

```bash
cd charging-bigscreen
bash deploy/deploy.sh           # 安装依赖 + 初始化 MySQL + 跑 Spark + 构建前端 + 启动服务
bash deploy/install_service.sh  # 可选：注册 systemd 开机自启 + nginx 80 端口反向代理
```

脚本特点：自动识别 `apt/yum/dnf`；Ubuntu 上 root 走 `auth_socket` 时自动创建应用账号；
Python 优先 3.12，其次 3.11/3.10；Node 23 通过 nodesource 安装；可重复执行（幂等）。

### 7.5 答辩模式：HDFS + Spark on YARN

```bash
# 1) 机器上还没有 Hadoop 时，一键搭伪分布式（HDFS + YARN）
bash deploy/setup_hadoop.sh

# 2) 生成 Hadoop 环境变量文件（按实际安装路径修改，模板在 deploy/hadoop_env.example.sh）
cp deploy/hadoop_env.example.sh deploy/hadoop_env.sh

# 3) 上传原始数据到 HDFS → 提交 Spark on YARN → 结果取回 → 装载 MySQL
bash deploy/spark_submit.sh

# 也可以分步执行（本地与 HDFS 是同一份代码，只差路径参数）
source deploy/hadoop_env.sh && export SPARK_MASTER=yarn
export PYSPARK_PYTHON=$PWD/.venv/bin/python
.venv/bin/python spark/jobs/run_all.py \
  --raw       hdfs://<NameNode>:9000/user/bit/charging-bigscreen/raw_expanded \
  --warehouse hdfs://<NameNode>:9000/user/bit/charging-bigscreen/warehouse \
  --ads       hdfs://<NameNode>:9000/user/bit/charging-bigscreen/ads
bash deploy/fetch_from_hdfs.sh && .venv/bin/python spark/jobs/load_mysql.py
```

## 八、数据说明

| 文件 | 含义 | 行数 | 关键字段 |
| --- | --- | --- | --- |
| `nvv2t.csv` | 充电订单明细 | 3395 | sessionId、kwhTotal、charging_fees、created/ended、chargeTimeHrs、weekday、platform、userId、stationId、facilityType、Mon~Sun |
| `dsv13r2.csv` | 电池充电遥测 | 1594 | esd(会话号)、soc、pack_voltage、charge_current、单体最高/最低电压、最高/最低温度、可用能量/容量、record_time |
| `nvv2t_md_end.csv` | 充电站维度 | 105 | stationId、locationId、facilityType、station_name、address、device_count、open_time |

原始数据存在三类质量问题，也是清洗的重点：

1. **订单时间年份被抹掉高两位**：`0014-11-18 15:40:26` 实际是 2014-11-18；
2. **存在异常订单**：0 电量订单、55.2 小时的超长时长记录；
3. **遥测 `record_time` 全为科学计数法 `2.02E+13`**，有效数字丢失、无法还原真实时间。

## 九、数据清洗规则（`spark/jobs/etl_clean.py`）

| # | 规则 | 结果 |
| --- | --- | --- |
| 1 | 年份修复：缺失的高两位统一 +2000 后解析为标准 timestamp | 用 `Mon~Sun` 独热列交叉验证，**3395/3395 条星期完全一致**，证明修正正确 |
| 2 | 业务主键去重（`sessionId`）+ 关键字段空值校验 | 无重复、无空值 |
| 3 | 异常订单剔除：电量 ≤0（55 条）或 >40kWh、时长 ≤0 或 >12h、金额为负 | 共剔除 **56 条**，有效订单 **3339 条** |
| 4 | 遥测字段规范化：电流为负值（充电方向约定）统一取幅值 | `charge_current` 全部为正 |
| 5 | 无效字段丢弃：`record_time` 精度丢失且无法复原 | 丢弃该字段并在质量报告中说明 |
| 6 | 派生指标：平均功率、单价、峰平谷时段、是否周末、单体压差、温升、SOC 分箱 | 供后续多维分析使用 |
| 7 | 维度关联与解析：订单关联站点维度，从站名解析行政区/道路/站点类型 | 站名关键字与 `facilityType` 编码 105/105 一致（1=交流、2=直流、3=交直流、4=超充） |

清洗各阶段的记录数落到 `ads_data_quality` 表，大屏顶部实时展示「原始 3395 → 有效 3339」。

## 十、分析维度（15 个，含 5 组对比分析）

| # | 分析维度 | 结果表 | 大屏面板 |
| --- | --- | --- | --- |
| 1 | 运营总览 KPI | `ads_overview` | 顶部 9 项翻牌器 + 环形图 + 水球图 |
| 2 | 日充电量/订单趋势 | `ads_daily_trend` | 日充电量与订单趋势（双轴） |
| 3 | 月度充电量趋势 | `ads_monthly_trend` | 月度趋势（柱 + 折线） |
| 4 | 24 小时充电负荷 | `ads_hour_load` | 24 小时负荷（峰/平/谷着色 + 峰值标注） |
| 5 | 星期 × 小时充电热度 | `ads_weekday_hour_heat` | 热力图 |
| 6 | 站点充电量 TOP10 | `ads_station_top` / `ads_station_all` | 站点排行（横向条形） |
| 7 | **行政区分布（对比）** | `ads_district` | 行政区锥形柱图 |
| 8 | **站点类型对比** | `ads_facility_compare` | 雷达图 |
| 9 | **工作日 vs 周末对比** | `ads_weekend_compare` | 分组柱状 + 折线 |
| 10 | **峰平谷时段对比** | `ads_time_period` | 漏斗图 |
| 11 | 用户价值分层（RFM） | `ads_user_value` / `ads_user_segment` | 环形占比图 |
| 12 | 充电时长分布 | `ads_duration_dist` | 玫瑰图 |
| 13 | 单次充电量分布 | `ads_energy_dist` | 柱状 + 占比折线 |
| 14 | 充电功率分布 / 电池健康 | `ads_power_dist` / `ads_battery_health` / `ads_battery_type_compare` | 电池健康画像（柱 + 双折线） |
| 15 | **收入结构与平台对比** | `ads_revenue_struct` / `ads_platform_compare` | 收入结构柱状 + 付费率折线、平台对比 |

### 主要分析结论

以下为**扩容后**（第 5 节）统计区间 **2014-11-18 ~ 2015-10-04** 的结论，括号内为扩容前的原始数据结论：

- **整体规模**：有效订单 **54944 单**（3339）、充电量 **327757.97 kWh**（19719.59）、有订单站点 2993 座（105）、
  充电桩 12026 台（562）、活跃用户 2556 人（84）、累计收入 11225.56 元（398.02）、付费订单占比 17.56%（11.29%）。
- **用户二八分布**：高价值用户 869 人（34.0%）贡献 **88.0%** 的充电量（原数据：30 人 / 35.7% / 80.4%）。
- **站点类型**：直流站占电量 52.7%、交直流 18.5%、交流 15.7%、超充 13.2%；四类站点桩均订单都在 4.3~4.7 单/台，运营效率接近。
- **工作日 vs 周末**：工作日日均 173.18 单 / 1032.21 kWh，周末日均 166.15 单 / 993.28 kWh，两者基本持平（原数据周末样本仅 85 单）。
- **时段特征**：平段 43.68%、峰段 44.51%、谷段 11.81%，夜间谷电仍有错峰引导空间。
- **电池健康**：SOC 由 10~20% 升到 70~80% 时，单体压差由 24.2mV 升至 36.8mV、最高温度 34.9℃→35.1℃，高 SOC 区间一致性变差。
- **区域分布**：石景山区、丰台区、平谷区居前（各约 6.6%~6.9% 电量），全市各区县分布相对均衡；桩均订单最高的区县达 5.2 单/台。

## 十一、大屏说明

- 设计分辨率 **1920×1080**，按浏览器窗口等比缩放，适配任意分辨率；数据 **60 秒自动刷新**，后端结果缓存 30 秒。
- 首屏只发一个聚合请求 `GET /api/screen/bundle`，一次返回 20 个数据集，减少并发与等待。
- 16 个面板使用的图表类型：翻牌数字、环形占比、水球图、柱状、折线、面积、双轴混合、雷达、
  热力图、玫瑰图、漏斗图、锥形柱图、横向条形、分组柱状、堆叠柱 + 折线、滚动榜。

### 11.1 双主题（暗色 / 亮色一键切换）

大屏提供两套完整配色，右上角按钮一键切换，切换后**所有 ECharts 图表 + DataV 组件 + 卡片/文字/背景**同步换肤：

| 方式 | 说明 |
| --- | --- |
| 点击按钮 | 标题栏右上角「☀ 亮色主题 / 🌙 暗色主题」，即时切换 |
| URL 参数 | `http://<地址>/?theme=light` 或 `?theme=dark`，便于演示时直接打开指定主题 |
| 记忆 | 选择结果写入浏览器 `localStorage`，下次打开保持上次主题 |

实现要点：主题色集中定义在 `frontend/src/utils/echartsTheme.js`（`DARK`/`LIGHT` 两套色板），
通过 Vue 响应式对象 `theme` 暴露给全部图表配置构造器，切换即触发图表重绘；
页面级颜色用 CSS 变量（`html[data-theme='light'] { --panel-bg: ... }`）控制，两处配合实现全局换肤。

## 十二、与 Charging_Pile_System 集成（替换对方大屏 + 数据对接）

在虚拟机上拉取了 <https://github.com/asdjqw/Charging_Pile_System>（Qt6/C++ 充电桩综合管理系统，含
`user_client`、`admin_client`、`admin_server`、`web` 运营大屏与 SQLite 业务库），本项目对其做了两件事：

**① 用本项目大屏替换对方的 `web/` 运营大屏**

```bash
# 对方原来的静态页（index.html / app.js / styles.css / echarts.min.js）先备份，再放入本项目的构建产物
cd /home/bit/Charging_Pile_System/web
mkdir -p _legacy_backup && mv index.html app.js styles.css echarts.min.js _legacy_backup/ 2>/dev/null
cp -r /home/bit/charging-bigscreen/frontend/dist/* .      # 放入我们的 index.html 与 assets/
```

对方的 `admin_server` 直接以 `web/` 为静态根目录（`resolveWebRoot()`），替换后
<http://127.0.0.1:8080/index.html> 出来的就是本项目的大屏，Qt 客户端与后端逻辑不受影响。

**② 数据对接与扩容（以本项目数据为主）**

- 接口对接：大屏的接口地址优先走**同源 `/api`**，如果不是我们的服务则自动回退到
  `http://<当前主机>:5000/api`（见 `frontend/src/api/index.js`），因此放在对方系统里也能取到本项目 Flask 的数据；
- 数据扩容：把对方 `data/北京市充电桩数据.csv`（3025 条北京充电站 POI）融入本项目站点维度，
  原始订单原样保留并按经验分布外推生成新订单，形成"本项目为主 + 对方数据扩容"的最终数据集（见第五节）。

## 十三、后端接口

| 接口 | 说明 |
| --- | --- |
| `GET /api/health` | 服务与数据库状态（`data_source` 显示当前是 mysql 还是 csv） |
| `GET /api/screen/bundle` | 大屏首屏聚合数据（19 个数据集，30s 缓存） |
| `GET /api/overview` | 运营总览 KPI |
| `GET /api/trend/daily?days=90`、`GET /api/trend/monthly` | 日趋势、月趋势 |
| `GET /api/hour-load`、`GET /api/heat/weekday-hour` | 24 小时负荷、星期×小时热度 |
| `GET /api/stations/top?limit=10`、`GET /api/districts` | 站点排行、行政区分布 |
| `GET /api/facility/compare`、`GET /api/weekend/compare`、`GET /api/time-period`、`GET /api/platform/compare` | 4 组对比分析接口 |
| `GET /api/users/segments`、`GET /api/users/top` | 用户分层占比、用户价值榜 |
| `GET /api/dist/duration`、`/energy`、`/power` | 时长、电量、功率分布 |
| `GET /api/battery/health`、`GET /api/battery/type-compare` | 电池健康、按站型的电池参数对比 |
| `GET /api/revenue/struct?dim=站点类型` | 收入结构与付费率（维度可切换） |
| `GET /api/quality`、`GET /api/realtime?limit=20` | 清洗质量报告、实时订单流水 |
| `GET /api/pipeline` | 本次作业的数据链路信息（计算引擎 Spark on YARN / 存储 HDFS） |
| `POST /api/cache/refresh` | 清空后端缓存（数据更新后可立即生效） |

数据源模式由 `config/database.env` 的 `DATA_SOURCE` 控制：`mysql`（默认）或 `csv`（MySQL 不可用时直接读 `output/ads/*.csv`）。

## 十四、数据库说明

- 库名：`charging_screen`；`deploy.sh` 会按本机配置初始化账号（演示默认 `charging / charging123`）。密码只写在被 Git 忽略的 `config/database.env`。
- 当前流水线共生成 **27 张表**：3 张明细/维度表（`session_detail`、`battery_detail`、`station_dim`）
  + 23 张分析/作业信息表（`ads_*`）+ 作业日志表 `etl_job_log`。字段和前端接口映射详见
  [`docs/MySQL数据库Schema说明.md`](docs/MySQL数据库Schema说明.md)。Hive 四层表见
  [`docs/Hive四层数据仓建设与运行.md`](docs/Hive四层数据仓建设与运行.md)。
- 备份文件 `sql/charging_screen.sql` 可还原生成时点的数据；当前 Schema 以流水线动态建表结果为准：

```bash
mysql -uroot -p < sql/charging_screen.sql     # 还原整个库（含建表与数据）
```

## 十五、部署记录（虚拟机实际状态）

| 项目 | 状态 |
| --- | --- |
| 大屏地址 | <http://192.168.44.129/>（nginx 80 端口）、<http://192.168.44.129:5000/>（Flask 直连） |
| 后端服务 | systemd 服务 `charging-screen`（gunicorn + Flask），已设置开机自启，运行用户 `bit` |
| 运行环境 | Ubuntu 22.04、MySQL 8.0、Python 3.12.13（项目内 `.venv`）、PySpark 3.5.3、Node v23.11.1 |
| Hadoop | 复用 Hadoop 3.2.1（`/opt/module/hadoop-3.2.1`），HDFS 与 YARN 均 RUNNING |
| HDFS 数据 | `/user/bit/charging-bigscreen/{raw,warehouse,ads}` |
| 项目目录 | `/home/bit/charging-bigscreen` |

常用运维命令：

```bash
sudo systemctl status charging-screen      # 查看后端状态
sudo systemctl restart charging-screen     # 重启后端
sudo nginx -s reload                       # 重载 nginx
tail -f logs/gunicorn.log                  # 后端日志
bash deploy/run_pipeline.sh                # 数据更新后重跑计算
```

### 三个已解决的部署坑（换机器时注意）

1. **HDFS 地址必须用 `bitdev:9000`，不能用 `localhost:9000`**：该虚拟机 `127.0.0.1:9000` 被另一个服务（`admin_server`）占用，
   连 `localhost:9000` 会报 `EOFException`，容易被误判成 Hadoop 版本不兼容。
2. **Spark 用 Java 11，Hadoop 用 Java 8**：Spark 3.5 要求 Java 8u371+/11/17，而机器自带 JDK 1.8.0_261 跑 Hadoop，
   因此额外安装 `openjdk-11-jdk-headless` 给 Spark 使用（在 `deploy/hadoop_env.sh` 中指定）。
3. **nginx 采用全量反向代理**：Ubuntu 家目录默认权限 750，nginx(www-data) 读不到 `frontend/dist`，
   因此由 Flask 托管静态文件、nginx 统一反代到 `127.0.0.1:5000`。

## 十六、常见问题（FAQ）

| 现象 | 处理方式 |
| --- | --- |
| 大屏无数据 / 接口 500 | 先看 `GET /api/health`：`data_source` 是 `csv` 说明 MySQL 没连上，检查 `config/database.env` 并确认已执行 `load_mysql.py` |
| Spark 报 `HADOOP_HOME ... unset` | Linux 安装 JDK 并设置 `JAVA_HOME`；Windows 本地出现该告警正常（会自动回退为驱动端写出，结果一致） |
| `pip install pyspark` 太慢或超时 | 换国内镜像：`pip install -i https://mirrors.aliyun.com/pypi/simple pyspark==3.5.3`（实测阿里云最快） |
| `npm install` 慢 | `frontend/.npmrc` 已配置 `registry.npmmirror.com`，也可换成内网源 |
| 数据更新后大屏没变 | 执行 `bash deploy/run_pipeline.sh`，或 `curl -X POST http://127.0.0.1:5000/api/cache/refresh` |
| 想换城市名称 | 只改 `frontend/src/components/HeaderBar.vue` 与 `frontend/index.html` 的标题，然后 `npm run build`；原始数据保持不动 |

## 十七、文档索引

- [docs/答辩要点.md](docs/答辩要点.md)：清洗发现、维度设计、可直接口述的结论数据
- [docs/答辩演示流程.md](docs/答辩演示流程.md)：10 分钟演示脚本与常见提问应答
- [docs/虚拟机部署记录.md](docs/虚拟机部署记录.md)：虚拟机部署状态、命令与踩坑
- [docs/大屏预览.png](docs/大屏预览.png)：大屏实际运行截图
