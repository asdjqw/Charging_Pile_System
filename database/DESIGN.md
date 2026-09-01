# 充电桩系统数据库与 Socket 设计

## 1. 部署边界

SQLite 是嵌入式数据库，不提供远程数据库协议。正确结构是：

```text
Qt 用户端 ── TCP/JSON ──> Qt PC 服务器 ── QSQLITE ──> charge_pile.db
Qt 管理界面 ────────────> 业务服务层 ────┘
Web 大屏 ── HTTP JSON（端口 8080）────────┘
机器学习服务 ── 批量读取/写入预测结果 ──┘
```

只有 PC 服务器进程可以打开 `charge_pile.db`。客户端不得共享数据库文件，也不得发送原始 SQL；客户端只发送业务动作，服务端校验参数、权限和业务状态后执行参数化 SQL。

## 2. 核心关系

```text
stations 1 ── N piles 1 ── N charging_orders N ── 1 users
                    │                  │                 │
                    │                  └── wallet_transactions
                    ├── pile_telemetry
                    ├── pile_status_logs
                    └── fault_events

stations ── weather_observations / station_load_samples / load_forecasts
users ── user_sessions / charging_reservations
admins ── admin_audit_logs
ml_models ── load_forecasts
```

完整字段、外键、检查约束和索引见 [schema.sql](schema.sql)，演示数据见 [seed.sql](seed.sql)。

## 3. 表职责

| 表 | 作用 |
|---|---|
| `users` | 手机号、昵称、头像、余额快照、冻结状态 |
| `admins` | 管理员身份和角色 |
| `stations` | 电站地址、坐标、营业状态 |
| `piles` | 电桩规格、价格、实时状态、累计统计 |
| `charging_reservations` | 预约及超时释放 |
| `charging_orders` | 充电、计费、结算全生命周期 |
| `wallet_transactions` | 充值、扣费、退款的账务流水 |
| `user_sessions` | Socket 登录令牌，数据库只存令牌摘要 |
| `pile_telemetry` | 电压、电流、功率、温度和故障码时序数据 |
| `pile_status_logs` / `fault_events` | 运维状态轨迹与故障闭环 |
| `weather_observations` / `station_load_samples` | 负荷预测训练特征 |
| `ml_models` / `load_forecasts` | 模型版本和 1/6/24 小时预测结果 |
| `admin_audit_logs` | 冻结用户、重启电桩等敏感操作审计 |

## 4. TCP Socket 协议

系统使用 `QTcpServer` + `QTcpSocket`。每个消息采用“4 字节大端无符号长度 + UTF-8 JSON”帧，解决 TCP 粘包/拆包问题。所有请求都携带唯一 `requestId`；服务端原样返回该 ID，使客户端能够匹配响应。

请求示例：

```json
{
  "version": 1,
  "requestId": "8d03b4a2-...",
  "action": "user.phoneLogin",
  "token": "",
  "data": { "phone": "13800001111" }
}
```

响应示例：

```json
{
  "version": 1,
  "requestId": "8d03b4a2-...",
  "ok": true,
  "code": "OK",
  "message": "登录成功",
  "data": { "userId": 1, "nickname": "张三", "balance": 200.0, "token": "..." }
}
```

已实现的主要业务动作：

| 动作 | 主要事务 |
|---|---|
| `user.phoneLogin` | 查询手机号；不存在则创建默认昵称；签发会话 |
| `stations.list` | 查询站点与空闲桩；服务端计算距离并排序 |
| `piles.list` | 查询站内电桩实时状态 |
| `reservation.create/cancel` | 锁定或释放一个空闲桩 |
| `charge.start` | 校验用户和桩状态，创建订单并把桩改为 `charging` |
| `charge.stop` | 固化电量与价格，订单进入待支付或直接结算 |
| `wallet.recharge` | 同一事务更新余额并写入钱包流水 |
| `charge.stop` | 同一事务扣款、结束订单、释放电桩并写入钱包流水 |
| `admin.user.freeze` | 更新用户状态并写审计日志 |
| `admin.pile.restart` | 写状态日志，向设备端发送模拟指令 |

## 5. 必须保证的事务规则

开始充电、结算、充值、预约都应使用 `QSqlDatabase::transaction()`。失败时必须 `rollback()`，成功时检查 `commit()` 返回值。

- 一个用户最多一个 `ongoing/pending_payment` 订单。
- 一个电桩最多一个 `ongoing` 订单或一个有效预约。
- 订单创建时保存 `price_per_kwh` 快照，后续调价不改变历史账单。
- 余额更新和 `wallet_transactions` 流水必须在同一事务完成。
- 管理员冻结、远程重启等操作必须写 `admin_audit_logs`。
- `QSqlDatabase` 连接只能在创建它的线程中使用；若服务端使用线程池，每个工作线程必须创建独立命名连接。

## 6. SQLite 运行参数与数据维护

服务端连接后启用：`foreign_keys=ON`、`journal_mode=WAL`、`synchronous=NORMAL`、`busy_timeout=5000`。这些参数已写入 `DatabaseManager::openDatabase()`。

建议定时任务：

- 每分钟把电桩瞬时数据批量写入遥测表。
- 每 5～15 分钟聚合 `station_load_samples`，供大屏和模型使用。
- 按月归档高频遥测；业务订单和钱包流水长期保留。
- 每日使用 SQLite Online Backup API 或停写后复制数据库，并定期执行 `PRAGMA integrity_check`。

## 7. 安全说明

当前 `password` 字段仅为兼容已有演示程序。正式版本应只保存带随机盐的 Argon2id/bcrypt 密码摘要到 `password_hash`，并移除明文密码。手机号免密登录若用于真实环境，应增加短信验证码；Socket 上线时应使用 TLS，令牌只回传一次，数据库只保存令牌 SHA-256 摘要。
