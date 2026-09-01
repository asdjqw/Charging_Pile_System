# 充电桩综合管理系统（Qt6）

项目包含 **Qt 用户端 + PC 管理/服务器端 + SQLite + Web 运营大屏**。所有组件可在同一台
设备运行：用户端通过 TCP 业务协议访问服务器，只有服务器进程可以打开 SQLite 数据库。

## 系统组成

| 子系统 | 技术 | 功能 |
|---|---|---|
| 充电用户端 | Qt6 Widgets + Network | 手机号免密登录、找桩导航、预约、充电、资料、充值和订单 |
| PC 管理/服务器端 | Qt6 Widgets + Network | 营收统计、设备运维、用户风控、TCP/HTTP 服务和核心业务 |
| 数据库端 | Qt SQL + SQLite | 用户、站点、电桩、订单、账务、遥测与审计 |
| Web 大屏 | HTML + CSS + ECharts | 7/30 日营收、在线率、电桩状态、订单和站点实时展示 |

数据库默认位于 `~/.local/share/ChargePileLab/charge_pile.db`。协议、数据模型和事务边界见
[`database/DESIGN.md`](database/DESIGN.md)。

## Ubuntu 环境

```bash
chmod +x scripts/install_deps_ubuntu.sh scripts/build.sh
./scripts/install_deps_ubuntu.sh
```

手动安装：

```bash
sudo apt update
sudo apt install -y build-essential cmake \
  qt6-base-dev qt6-tools-dev libqt6sql6-sqlite \
  libgl1-mesa-dev pkg-config
```

项目以 Ubuntu Qt 6.2.4、CMake 3.22、GCC 11 和 C++17 为兼容基准。

## 编译与运行

```bash
./scripts/build.sh

# 终端 1：管理端，同时启动 TCP 9000 和 HTTP 8080
./build/admin_server/admin_server

# 终端 2：用户端
./build/user_client/user_client

# 浏览器打开 Web 大屏
firefox http://127.0.0.1:8080
```

也可使用 Qt Creator 打开顶层 `CMakeLists.txt`，选择 Qt6 Desktop Kit 后构建。

### 演示账号

用户端输入 11 位手机号免密登录，手机号不存在时自动创建用户。内置演示手机号：
`13800001111`、`13900002222`、`13700003333`。

| 类型 | 用户名 | 密码 |
|---|---|---|
| 管理员 | `admin` | `123456` |
| 运维 | `ops01` | `ops123` |

## 运行架构

```text
Qt 用户端 ── TCP/JSON :9000 ──┐
                               ├── PC 管理/服务器端 ── SQLite
Web 浏览器 ── HTTP :8080 ──────┘
```

TCP 消息使用“4 字节大端长度 + UTF-8 JSON”帧，并通过 `requestId` 匹配响应。网络监听
运行在独立 `QThread`，数据库操作回到创建数据库连接的主线程执行。充电进度、遥测、
钱包流水和状态日志都由服务器持久化。

## 服务配置

| 环境变量 | 默认值 | 说明 |
|---|---|---|
| `CHARGE_PILE_HOST` | `127.0.0.1` | 用户端连接地址 |
| `CHARGE_PILE_PORT` | `9000` | TCP 业务端口 |
| `CHARGE_PILE_HTTP_PORT` | `8080` | Web 大屏端口 |
| `CHARGE_PILE_BIND_ADDRESS` | `127.0.0.1` | 服务监听地址；局域网使用 `0.0.0.0` |
| `CHARGE_PILE_DB_PATH` | 系统应用数据目录 | 服务端 SQLite 路径 |
| `CHARGE_PILE_WEB_ROOT` | 程序旁的 `web` | Web 静态资源目录 |
| `CHARGE_PILE_HEADLESS` | `0` | 设为 `1` 时仅运行服务 |

局域网运行时，将服务端 `CHARGE_PILE_BIND_ADDRESS` 设为 `0.0.0.0`，并将用户端的
`CHARGE_PILE_HOST` 改为服务器 IP。

## 目录结构

```text
common/        公共模型、JSON 编解码、帧协议和数据库
user_client/   Qt 用户端和 TCP API 客户端
admin_server/  管理 GUI、请求分发、TCP/HTTP 服务
database/      SQLite schema、seed 和协议设计
data/          北京充电站 CSV
web/           离线 Web 运营大屏
tests/         协议测试和 TCP 端到端测试客户端
scripts/       Ubuntu 依赖安装与跨平台构建脚本
```

## 测试

```bash
ctest --test-dir build --output-on-failure
```

`database_behavior_test` 验证手机号自动建号、冻结/解冻和模拟远程重启；
`server_api_smoke` 在运行中的独立服务上验证预约/取消、预约转充电、进度持久化、结算和订单查询。

## 尚未包含

机器学习训练与推理属于后续模块；数据库已经保留模型、负荷样本和预测结果表供其接入。
