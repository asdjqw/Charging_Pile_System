# 充电桩综合管理系统（Qt6）

项目包含 **Qt 用户端 + Qt 管理端 + PC 后端服务 + SQLite + Web 运营大屏**。所有组件可在同一台
设备运行：用户端与管理端都通过 TCP 业务协议访问服务器，只有 `admin_server` 进程可以打开 SQLite。

## 系统组成

| 子系统 | 技术 | 功能 |
|---|---|---|
| 充电用户端 `user_client` | Qt6 Widgets + Network | 手机号密码登录/注册、找桩导航、预约（最多 3 个）、充电、资料、充值和订单 |
| 管理客户端 `admin_client` | Qt6 Widgets + Charts + Network | 管理员登录、销售业绩、电桩状态、充电桩/站管理、用户风控 |
| 后端服务 `admin_server` | Qt6 Network + SQL | TCP/HTTP 服务、业务校验、事务与 SQLite 独占访问 |
| 数据库端 | Qt SQL + SQLite | 用户、站点、电桩、订单、账务、遥测与审计 |
| Web 大屏 | HTML + CSS + ECharts | 7/30 日营收、在线率、电桩状态、订单和站点实时展示 |

数据库默认位于 `~/.local/share/ChargePileLab/charge_pile.db`。协议、数据模型和事务边界见
[`database/DESIGN.md`](database/DESIGN.md)。

## Ubuntu 环境

```bash
chmod +x scripts/*.sh
./scripts/install_deps_ubuntu.sh
```

若项目在 VMware 共享盘（`/mnt/hgfs/...`）上，`chmod` / `sed -i` 可能报「不允许的操作」。
脚本已使用 Unix 换行；共享盘上请用 `bash` 直接跑（不依赖可执行位）：

```bash
bash scripts/install_deps_ubuntu.sh
bash scripts/build.sh
bash scripts/run_ubuntu.sh
```

更稳妥是拷到虚拟机本地再编：

```bash
cp -a /mnt/hgfs/Small_s3/Charge_pile ~/Charge_pile
cd ~/Charge_pile
```

若项目在 VMware 共享盘（`/mnt/hgfs/...`）上，`chmod` / `sed -i` 可能报「不允许的操作」。
脚本已使用 Unix 换行；共享盘上请用下面方式运行（不依赖可执行权限）：

```bash
bash scripts/install_deps_ubuntu.sh
bash scripts/build.sh
bash scripts/run_ubuntu.sh
```

更稳妥是拷到虚拟机本地再编：`cp -a /mnt/hgfs/Small_s3/Charge_pile ~/Charge_pile && cd ~/Charge_pile`

手动安装：

```bash
sudo apt update
# Ubuntu 22.04 用 libqt6charts6-dev；24.04 可用 qt6-charts-dev
sudo apt install -y build-essential qt6-base-dev qt6-tools-dev qt6-qmake \
    libqt6charts6-dev libqt6sql6-sqlite libgl1-mesa-dev pkg-config
```

项目以 Ubuntu Qt 6.2.4、qmake、GCC 11 和 C++17 为兼容基准。

## 编译与运行

Ubuntu 上一键重新编译并拉起后端、管理端、用户端：

```bash
bash scripts/rebuild_run.sh
```

共享盘（`/mnt/hgfs`）若不能执行二进制，脚本会拷到 `~/Charge_pile_bin` 再启动。`Ctrl+C` 结束全部进程。已编译过、只想重开时用 `bash scripts/rebuild_run.sh --skip-build`。

分终端手动启动：

```bash
./scripts/build.sh

# 终端 1：后端服务，监听 TCP 9000 和 HTTP 8080
./build/admin_server/admin_server

# 终端 2：用户端
./build/user_client/user_client

# 终端 3：管理员客户端
./build/admin_client/admin_client

# 浏览器打开 Web 大屏
firefox http://127.0.0.1:8080
```

也可使用 Qt Creator：菜单「文件 → 打开文件或项目」，选择本目录的 **`ChargePile.pro`**
（本项目是 Qt6 + qmake）。

编译完成后，程序在 `build/` 里，不在源码根目录：

```text
build/admin_server/admin_server    后端（无窗口）
build/admin_client/admin_client    管理员登录 + 后台 GUI
build/user_client/user_client      用户端 GUI
```

### Ubuntu 虚拟机逐步启动

```bash
# 1. 进入项目目录（把路径换成你克隆/拷贝后的实际位置）
cd ~/Charge_pile

# 2. 首次安装依赖并编译（只需一次，约几分钟）
chmod +x scripts/*.sh
./scripts/install_deps_ubuntu.sh
./scripts/build.sh

# 3. 终端 1：后端（先开，一直不要关）
./scripts/run_ubuntu.sh
# 或：./build/admin_server/admin_server
# 首次会导入北京市充电桩 CSV，看到「后端服务已启动」再进行下一步

# 4. 终端 2：管理员界面（登录窗）
./build/admin_client/admin_client

# 5. 终端 3：用户端
./build/user_client/user_client
```

### 演示账号

用户端输入 11 位手机号和密码登录；新用户必须走注册页，登录不会自动建号。演示账号：
`13800001111` / `123456`。用户端默认窗口约 `540×960`。

| 类型 | 用户名 | 密码 |
|---|---|---|
| 管理员 | `admin` | `123456` |
| 运维 | `ops01` | `ops123` |

## 运行架构

```text
Qt 用户端 user_client  ── TCP/JSON :9000 ──┐
Qt 管理端 admin_client ── TCP/JSON :9000 ──┼── admin_server 后端 ── SQLite
Web 浏览器              ── HTTP :8080 ─────┘
```

`admin_server` 是纯后端：不再内嵌管理 GUI。管理员界面在 `admin_client` 中，风格与
`user_client` 同一套天蓝配色，布局改为宽屏表格/图表。TCP 消息使用“4 字节大端长度 +
UTF-8 JSON”帧，并通过 `requestId` 匹配响应。网络监听运行在独立 `QThread`，数据库
操作回到创建数据库连接的主线程执行。

## 服务配置

| 环境变量 | 默认值 | 说明 |
|---|---|---|
| `CHARGE_PILE_HOST` | `127.0.0.1` | 用户端连接地址 |
| `CHARGE_PILE_PORT` | `9000` | TCP 业务端口 |
| `CHARGE_PILE_HTTP_PORT` | `8080` | Web 大屏端口 |
| `CHARGE_PILE_BIND_ADDRESS` | `127.0.0.1` | 服务监听地址；局域网使用 `0.0.0.0` |
| `CHARGE_PILE_DB_PATH` | 系统应用数据目录 | 服务端 SQLite 路径 |
| `CHARGE_PILE_WEB_ROOT` | 程序旁的 `web` | Web 静态资源目录 |

局域网运行时，将服务端 `CHARGE_PILE_BIND_ADDRESS` 设为 `0.0.0.0`，并将用户端/管理端的
`CHARGE_PILE_HOST` 改为服务器 IP。

## 目录结构

```text
common/        公共模型、JSON 编解码、帧协议和数据库
user_client/   Qt 用户端和 TCP API 客户端
admin_client/  Qt 管理端（宽屏 PC 界面，经 TCP 接入后端）
admin_server/  后端服务：请求分发、TCP/HTTP、SQLite
database/      SQLite schema、seed 和协议设计
data/          北京充电站 CSV
web/           离线 Web 运营大屏
tests/         协议测试和 TCP 端到端测试客户端
ChargePile.pro  qmake 总工程（subdirs）
scripts/       Ubuntu 依赖安装与 qmake 构建脚本
```

## 测试

```bash
./build/protocol_test/protocol_test
./build/database_behavior_test/database_behavior_test
# 后端已启动时：
./build/server_api_smoke/server_api_smoke
```

`database_behavior_test` 验证注册登录、冻结/解冻和模拟远程重启；
`server_api_smoke` 在运行中的独立服务上验证「未注册不能登录」、预约/取消、预约转充电、进度持久化、结算和订单查询。

## 尚未包含

机器学习训练与推理属于后续模块；数据库已经保留模型、负荷样本和预测结果表供其接入。
