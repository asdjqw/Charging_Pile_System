# 充电桩综合管理系统

Qt 一期业务系统 + Spark/Flask 分析大屏 + 站点负荷预测。面向课程设计与答辩演示，**不是生产充电平台**。

交接请先读本文，再按需打开 [docs/README.md](docs/README.md)。

## 三部分各干什么

| 部分 | 目录 | 技术 | 职责 |
|---|---|---|---|
| 一期 | `user_client/` `admin_client/` `admin_server/` `common/` `database/` | Qt 6、C++17、SQLite | 找站、预约、充电、结算、运维。客户端只走 TCP |
| 分析大屏 | `bigscreen/`（主），`web/`（前端构建产物） | Spark SQL、HDFS ORC、MySQL、Flask、Vue/DataV | 清洗、19 张 ADS、16 维图表 + 负荷预测页。浏览器看 **:5000** |
| 机器学习 | `ml/` | 冻结 XGBoost/RF + Flask 查询 | 站点 H1/H6/H24 负荷与占用。Qt 经后端访问 **:5010**；大屏同源 `/api/forecast/*` |

```text
用户端 / 管理端  --TCP 9000-->  admin_server  --SQLite-->  charge_pile.db
                                      |
                                      | HTTP GET CHARGE_PILE_ML_URL
                                      v
                              ml 查询服务 :5010  （读 JSON 批次，默认可演示 fixtures）

浏览器  --:5000-->  Flask  --MySQL charging_screen-->  Spark SQL ADS（ORC）
Hadoop HDFS :8020  只存离线文件，不是大屏在线库
```

## 端口（以当前脚本为准）

| 端口 | 服务 |
|---|---|
| 9000 | Qt TCP |
| 8080 | Qt HTTP（静态 `web/` + `/api/health|dashboard|stations`） |
| 5000 | 分析大屏 Flask（图表 `/api/charts/*`、预测 `/api/forecast/*`） |
| 5010 | ML 查询 |
| 3306 | MySQL |
| **8020** | HDFS NameNode RPC（避开 9000） |
| 9870 / 8088 | HDFS UI / YARN UI |

不要再用「Qt 改 9100、HDFS 占 9000」当默认方案。

分析大屏入口是 `http://127.0.0.1:5000/`，负荷预测页是 `http://127.0.0.1:5000/#/forecast`。`:8080` 只是一期运营快照，不是 16 维分析接口。

## 目录

```text
Charge_pile/
├─ ChargePile.pro          根工程（qmake）
├─ admin_server/           一期后端（含 MlForecastGateway）
├─ admin_client/           管理端（含充电预测页、评价管理）
├─ user_client/            用户端（电站详情「充电预测」）
├─ common/                 协议、SQLite、样式、ForecastPanel
├─ database/               schema.sql / seed / DESIGN.md
├─ data/                   北京市充电桩 POI CSV
├─ web/                    大屏前端构建产物（给 Flask 与 8080 静态用）
├─ bigscreen/              二期主工程（Spark SQL ORC ETL + Flask + Vue）
├─ ml/                     预测子模块
├─ scripts/                安装与一键启动
└─ docs/                   交接文档
```

## 一键启动（Ubuntu 虚拟机）

共享盘无执行权限时用 `bash` 调脚本。`~/start_charge_pile.sh` 要先生成一次。

```bash
# 第一次装齐 Java/MySQL/Hadoop/大屏/ML 查询环境（15～40 分钟）
bash /mnt/hgfs/Small_s3/Charge_pile/scripts/setup_all_ubuntu.sh

# 若提示没有 ~/start_charge_pile.sh
bash /mnt/hgfs/Small_s3/Charge_pile/scripts/install_start_shortcut.sh

# 以后每次登录
bash ~/start_charge_pile.sh
bash ~/start_charge_pile.sh --no-gui     # 只起后台
bash ~/start_charge_pile.sh --hadoop     # 加上 HDFS/YARN
bash ~/start_charge_pile.sh stop
bash ~/start_charge_pile.sh status
```

只编译一期三个 Qt 程序：`bash scripts/rebuild_run.sh`。系统依赖：`bash scripts/install_deps_ubuntu.sh`。

重跑正式数仓（ODS 已在 HDFS 时）：

```bash
cd ~/charging-bigscreen   # 或共享盘上的 bigscreen/
MYSQL_RESET_SCHEMA=1 bash run_etl_all.sh
```

Windows 本机：Qt Creator 打开 `ChargePile.pro`，先起 `admin_server`，再起两个客户端。大屏和 ML 建议在 Ubuntu 虚机里跑。

## 演示账号

| 角色 | 账号 | 密码 |
|---|---|---|
| 用户 | 手机号 `13800001111` | `123456` |
| 管理员 | `admin` | `123456` |
| 运维 | `ops01` | `ops123` |

用户必须先注册。登录失败不会自动建号。

## 管理端侧栏

销售业绩、电桩状态、充电桩管理、充电站管理、**充电预测**、**评价管理**、用户管理、预约管理、权限管理。

预测页依赖 `:5010`。有 `ml/fixtures/measured_forecast.json` 时，`start_all.sh` 以 **MEASURED** 实测批次启动，并把结果绑定到 Qt 电站 ID。没有实测批次时才退回 `ml/fixtures/demo_forecast.json` 模拟查询。重新跑冻结模型：`bash scripts/run_measured_ml.sh`。

## 环境变量

| 变量 | 默认 | 谁用 |
|---|---|---|
| `CHARGE_PILE_HOST` | `127.0.0.1` | 两个客户端 |
| `CHARGE_PILE_PORT` | `9000` | 客户端、服务端 TCP |
| `CHARGE_PILE_HTTP_PORT` | `8080` | 服务端 HTTP |
| `CHARGE_PILE_BIND_ADDRESS` | `127.0.0.1` | 服务端监听 |
| `CHARGE_PILE_DB_PATH` | 系统数据目录 | SQLite |
| `CHARGE_PILE_WEB_ROOT` | 程序旁 `web/` | 静态资源 |
| `CHARGE_PILE_ML_URL` | `http://127.0.0.1:5010` | 服务端转预测 |

监听改成 `0.0.0.0` 会把明文 TCP/HTTP 暴露到局域网，演示外不建议。

## 测试

```text
./build/protocol_test/protocol_test
./build/database_behavior_test/database_behavior_test
./build/server_api_smoke/server_api_smoke   # 需要后端已启动
curl -s http://127.0.0.1:5000/api/health
curl -s http://127.0.0.1:5000/api/overview
```

## 已知限制（演示可过、不能当生产）

- 订单列表等处存在拼接 SQL 的风险；充电电量由客户端上报。
- TCP/HTTP 明文；密码为盐 + 单次 SHA-256，不是 Argon2。
- `/api/dashboard` 无鉴权。
- 客户端在 GUI 线程同步等网络；会话主要在内存。
- ML 真实推理需要 Releases 模型 + 小时快照；大屏预测页读已发布的 JSON 批次。
- 本机 MySQL 若关闭 `local_infile`，ADS 导入会回退为逐行 INSERT。

更细的表结构、图表接口、模型 CLI 见 `docs/`、`database/DESIGN.md`、`bigscreen/README.md`、`ml/README.md`。
