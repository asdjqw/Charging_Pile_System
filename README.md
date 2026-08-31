# 充电桩综合管理系统（Linux + Qt6）

项目 **用户端 + PC 服务器端 + 数据库端** 骨架，在 Ubuntu 上使用 Qt6 开发与运行。

> 后续可继续扩展：大数据可视化大屏（Web）、机器学习负荷预测。

## 系统组成

| 子系统 | 技术 | 功能 |
|--------|------|------|
| 充电用户端 | Linux + Qt6 Widgets | 附近电站查询、一键导航、用户信息维护、电动汽车充电 |
| PC 服务器端 | Linux + Qt6 Widgets | 管理员登录、销售业绩、电桩状态、充电站/桩/用户管理 |
| 数据库端 | Qt SQL + SQLite | 用户、站点、电桩、订单、账务、遥测、预测与审计数据 |

数据库：`~/.local/share/ChargePileLab/charge_pile.db`。完整的数据模型、事务边界和
Socket 协议见 [`database/DESIGN.md`](database/DESIGN.md)。

## 环境要求（Ubuntu 22.04 / 24.04）

```bash
chmod +x scripts/install_deps_ubuntu.sh scripts/build.sh
./scripts/install_deps_ubuntu.sh
```

手动安装也可：

```bash
sudo apt update
sudo apt install -y build-essential cmake ninja-build \
  qt6-base-dev qt6-charts-dev qt6-tools-dev \
  libqt6sql6-sqlite libgl1-mesa-dev
```

## 编译与运行

```bash
./scripts/build.sh

# 终端 1：用户端
./build/user_client/user_client

# 终端 2：管理端
./build/admin_server/admin_server
```

或使用 Qt Creator：打开本目录 `CMakeLists.txt`，选择 Qt6 Kit，构建后分别运行两个目标。

## 演示账号

**用户端**

| 用户名 | 密码 | 说明 |
|--------|------|------|
| zhangsan | 123456 | 余额约 200 |
| lisi | 123456 | 余额约 80.5 |
| wangwu | 123456 | 余额约 500 |

**管理端**

| 用户名 | 密码 | 角色 |
|--------|------|------|
| admin | 123456 | 系统管理员 |
| ops01 | ops123 | 运维人员 |

## 目录结构

```
Charge_pile/
├── CMakeLists.txt
├── README.md
├── database/
│   ├── schema.sql          # SQLite 建表
│   ├── seed.sql            # 示例数据
│   └── schema_mysql.sql    # 可选 MySQL 脚本
├── common/                 # 公共库：模型、数据库、样式
├── user_client/            # 充电用户端
├── admin_server/           # PC 服务器端
└── scripts/
    ├── install_deps_ubuntu.sh
    └── build.sh
```

## 业务说明

### 1. 充电用户端

- **附近充电站查询**：按关键字搜索，按当前位置估算距离排序
- **一键导航**：打开 OpenStreetMap 目标坐标（无需商业地图 Key）
- **用户信息维护**：手机号、车型、车牌、密码；支持充值与订单查看
- **电动汽车充电**：选择站点与空闲桩 → 开始充电（功率模拟电量）→ 结束结算扣费

### 2. PC 服务器端

- **管理员登录**
- **销售业绩**：今日/本月营收、近 7 日柱状图、最近订单
- **电桩状态**：按空闲/充电中/故障/离线筛选与改状态
- **充电站管理 / 充电桩管理 / 用户管理**：增删改查

### 3. 数据库端

首次启动自动执行 `schema.sql` + `seed.sql`。若需重置数据：

```bash
rm -f ~/.local/share/ChargePileLab/charge_pile.db
```

然后重新启动任意一端即可重建。

目标部署中仅 PC 服务器端通过 `QSQLITE` 打开数据库，用户端通过
`QTcpSocket` 调用服务器业务接口，不直接访问或共享 SQLite 文件。当前骨架中的
用户端直连数据库代码是单机演示实现，网络化改造接口约定见数据库设计文档。

## 可改用 MySQL

1. 导入 `database/schema_mysql.sql` 与相应数据  
2. 在 `DatabaseManager` 中把驱动从 `QSQLITE` 改为 `QMYSQL`，并配置主机/库名/账号  
3. 安装：`sudo apt install libqt6sql6-mysql`

当前默认 SQLite，便于课堂演示与单机答辩。

## 扩展建议

- Web 大数据可视化大屏（ECharts + 后端 API）
- 充电负荷预测（Python / 简单时序模型）
- 用户端与管理端改为 TCP/HTTP 联网，而不仅是共享本地库
