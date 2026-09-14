# 变更说明：用数据大屏替换原 Web 大屏，并新增 `bigscreen/` 分析平台

## 1. 变更目的

原项目的 Web 运营大屏是单页 HTML + 原生 JS + ECharts（`web/index.html`、`web/app.js`、`web/styles.css`、
`web/echarts.min.js`），数据直接来自 `admin_server` 的 `/api/dashboard`、`/api/stations`。
本次变更为课程/答辩的数据分析要求做升级：

1. **用完整的数据大屏替换原 Web 大屏**（Spark 清洗 + 15 维分析 + Flask 接口 + Vue 3 + DataV）；
2. 新增 `bigscreen/` 目录，作为数据大屏与分析平台的独立工程（可在合并工程内直接运行，也可单独部署）；
3. 原有 Qt 业务系统、SQLite 业务库、`/api/dashboard` 与 `/api/stations` 接口**保持不变**。

## 2. 具体改动

### 2.1 删除原 Web 大屏（完全移除）

以下文件已从仓库中**彻底删除**（不再保留备份目录）：

| 文件 | 说明 |
| --- | --- |
| `web/index.html` | 原大屏结构页（已被新大屏入口替换） |
| `web/app.js` | 原大屏的 API 请求、图表更新、分页逻辑 |
| `web/styles.css` | 原大屏样式 |
| `web/echarts.min.js` | 原大屏离线 ECharts 资源 |

`web/` 目录现在只包含新大屏的构建产物：`web/index.html` + `web/assets/index-*.js`、`web/assets/index-*.css`
（ECharts、DataV 组件、业务代码均已打包进该 JS 文件，不再需要单独引入 CDN 资源）。

> 静态资源服务方式不变：`admin_server` 仍以 `web/` 为静态根目录（`resolveWebRoot()`），
> 访问 `http://<主机>:8080/index.html` 打开的就是新数据大屏。Qt 客户端与后端接口行为不变。

### 2.2 新增 `bigscreen/` 数据大屏与分析平台

| 目录 | 内容 |
| --- | --- |
| `bigscreen/spark/jobs/` | `etl_clean.py` 数据清洗、`analysis.py` 15 维分析、`generate_expanded_data.py` 数据扩容、`run_all.py`、`load_mysql.py` |
| `bigscreen/backend/` | Flask REST 服务（23 个接口、TTL 缓存、MySQL/CSV 双数据源） |
| `bigscreen/frontend/` | Vue 3 + DataV + ECharts 大屏源码（Vite 构建，Node ≥ 23） |
| `bigscreen/deploy/` | 一键部署、Hadoop 伪分布式搭建、Spark on YARN、systemd/nginx 配置 |
| `bigscreen/data/` | 原始数据（订单/遥测/站点）与扩容脚本 |
| `bigscreen/docs/` | 答辩要点、演示流程、虚拟机部署记录、大屏预览图 |
| `bigscreen/README.md` | 数据大屏完整手册（数据扩容、清洗规则、分析维度、接口清单、双主题、HDFS/YARN 部署、FAQ） |

技术对照（课程要求逐条落地）：

| 要求 | 实现 |
| --- | --- |
| Python 3.11/3.12 | 3.12（虚拟机实测 3.12.13） |
| Spark 清洗与分析、维度 ≥ 8、对比分析 ≥ 2 组 | 15 个分析维度，其中 5 组对比分析（站点类型、工作日 vs 周末、峰平谷、平台、行政区） |
| Flask 处理请求 | 23 个 REST 接口，含大屏首屏聚合接口 |
| MySQL 存储结果 | 库 `charging_screen`，26 张表 |
| Node ≥ 23 + Vue 3 | Node 23.11.1 + Vue 3.5 + Vite |
| DataV 大屏、图表丰富 | DataV（边框盒/装饰/滚动榜/锥形柱/环形图/水球图）+ ECharts 16 类图表，共 16 个面板 |
| 文件存储放到 Hadoop 3.x | 原始数据与结果存 HDFS（`/user/bit/charging-bigscreen/{raw,raw_expanded,warehouse,ads}`），Spark 作业提交 YARN（应用名 `ChargingPile-Batch`） |

### 2.3 数据侧改动（以本项目数据为主 + 对方 POI 扩容）

- 原项目 `data/北京市充电桩数据.csv`（3025 条北京充电站 POI）被纳入新大屏的站点维度：站点 105 → **3024 座**（真实北京区县）；
- 订单 3395 → **55000 单**（原始订单原样保留，其余按原始经验分布外推生成），遥测 1594 → **24816 条**，用户 84 → **2556 人**；
- 修复原数据集中"周末几乎无数据（2.5%）、夜间谷段几乎无数据（0.51%）"的问题（现状 27.8% / 11.8%）；
- 扩容脚本：`bigscreen/spark/jobs/generate_expanded_data.py`（可重复执行，随机种子固定，结果可复现）。

## 3. 启动方式（两套服务）

```bash
# ① Qt 业务系统后端（静态托管新大屏）
cd Charging_Pile_System
bash scripts/build.sh
export CHARGE_PILE_WEB_ROOT=$PWD/web CHARGE_PILE_BIND_ADDRESS=0.0.0.0 \
       CHARGE_PILE_PORT=9100 CHARGE_PILE_HTTP_PORT=8080
nohup ./build/admin_server/admin_server > /tmp/admin_server.log 2>&1 &
#   大屏： http://<主机>:8080/index.html

# ② 数据大屏服务（Flask 接口 + nginx 入口 + MySQL）
cd Charging_Pile_System/bigscreen
sudo systemctl start mysql charging-screen nginx
#   大屏： http://<主机>/   或   http://<主机>:5000/
```

> 新大屏的接口地址为"同源 `/api` 优先、失败自动回退 `http://<主机>:5000/api`"，
> 因此放在 `admin_server`（8080）里托管或由 Flask/nginx（80、5000）托管都能正常取数。

## 4. 回归验证清单

| 项目 | 结果 |
| --- | --- |
| Qt 项目编译（`bash scripts/build.sh`，Qt 6.4 + g++） | ✅ 通过（admin_server / admin_client / user_client 全部生成） |
| `tests/protocol_test` | ✅ exit 0 |
| `tests/database_behavior_test` | ✅ exit 0（`ok user=44 pile=7186`，见下方"顺带修复"） |
| `tests/server_api_smoke 127.0.0.1 9100` | ✅ exit 0（`ok stations=3024 piles=15120 order=ORD…`） |
| `admin_server` 启动与接口 `/api/health`、`/api/dashboard?days=7`、`/api/stations` | ✅ 全部 200（SQLite 业务库数据保留） |
| 8080 静态大屏（替换后） | ✅ 打开即为新数据大屏，`index.html` 与 `assets/*` 均 200 |
| 新大屏接口 `/api/health`、`/api/screen/bundle`、各面板接口 | ✅ 全部 200，数据与 MySQL 一致 |
| 前端构建（`npm run build`，Node 23.11.1） | ✅ 通过，产物已提交到 `web/` |
| 双主题（暗/亮）切换、60 秒自动刷新、1920×1080 自适应 | ✅ 正常 |
| HDFS + Spark on YARN 全链路重算 → 取回 → 装载 MySQL | ✅ 通过（YARN 应用 `ChargingPile-Batch` SUCCEEDED） |

### 顺带修复与说明

1. **`tests/DatabaseBehaviorTest.cpp`（1 行）**：原测试调用 `updatePileStatus(..., "test", ...)`，
   而 `database/schema.sql` 的约束是 `CHECK(source IN ('pile','system','admin'))`，
   导致该测试在本仓库上必然失败（属于历史遗留问题）。本次改为 `"system"` 并补充注释，测试通过。
2. **运行环境准备**：`server_api_smoke` 需要 `build/` 目录下的运行资产与一个可登录的演示账号
   （`13800001111 / 123456`）。若本地演示库中该账号被置为 `frozen`，先改回 `normal` 再跑冒烟测试：
   `sqlite3 ~/.local/share/ChargePileLab/charge_pile.db "update users set status='normal' where phone='13800001111';"`
   （此项只影响本机运行库，不改动仓库代码）。
3. **端口**：`admin_server` 默认 TCP 9000 与 Hadoop NameNode RPC 冲突，示例改用 `CHARGE_PILE_PORT=9100`；
   冒烟测试支持传参：`./server_api_smoke 127.0.0.1 9100`。

## 5. 兼容性与影响面

- **不影响** `admin_client`、`user_client`、`admin_server` 的业务逻辑、SQLite 结构、TCP 协议与既有 HTTP 接口；
- **不影响** 原项目的数据文件 `data/北京市充电桩数据.csv`（仅被读取用于站点维度扩容）；
- 新增依赖只在 `bigscreen/` 内（Java 11 + Python 3.12 + MySQL + Node 23，详见 `bigscreen/README.md`）；
- 若端口冲突：`admin_server` 默认 TCP 9000 与 Hadoop NameNode RPC 冲突，示例中改用 9100。
