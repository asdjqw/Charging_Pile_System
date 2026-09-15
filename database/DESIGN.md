# 充电桩系统数据库与通信设计

## 1. 部署边界

SQLite 没有远程协议。只有 `admin_server` 打开 `charge_pile.db`。

```text
user_client  ──TCP JSON──┐
admin_client ──TCP JSON──┴──► admin_server ──QSQLITE──► charge_pile.db
浏览器运营快照 ──HTTP :8080──┘         │
                                       └──HTTP──► ML 查询 :5010（不写本库）

分析大屏 MySQL charging_screen 与本文件无关。
```

客户端不得共享 db 文件，不得发原始 SQL。

## 2. 核心关系

```text
stations 1 ── N piles 1 ── N charging_orders N ── 1 users
                    │                  │
                    ├── pile_telemetry
                    └── charging_reservations

users ── user_sessions / wallet_transactions / station_reviews
admins ── admin_audit_logs / 邀请码与权限表
```

`schema.sql` 里仍有 `ml_models` / `load_forecasts` 等预留表。**当前预测结果不写这些表**，而走 `ml/` 的 JSON 批次或 ML 侧 MySQL。

完整字段见 [schema.sql](schema.sql)，演示数据见 [seed.sql](seed.sql)。

## 3. 表职责（业务库）

| 表 | 作用 |
|---|---|
| `users` | 手机号、昵称、余额、冻结 |
| `admins` | 管理员与角色 |
| `stations` / `piles` | 站与桩 |
| `charging_reservations` | 预约 |
| `charging_orders` | 充电订单 |
| `wallet_transactions` | 账务 |
| `user_sessions` | 令牌摘要（会话仍主要在内存） |
| `station_reviews` | 用户评价（管理端「评价管理」） |
| `admin_audit_logs` | 敏感操作审计 |

## 4. TCP 协议

`4 字节大端长度 + UTF-8 JSON`。请求带 `requestId`，响原样返回。

```json
{
  "version": 1,
  "requestId": "…",
  "action": "user.phoneLogin",
  "token": "",
  "data": { "phone": "13800001111", "password": "123456" }
}
```

常用 `action`：`user.phoneLogin` / `user.register`、`stations.list`、`reservation.*`、`charge.*`、`wallet.recharge`、`forecast.station`、`admin.login`、`admin.dashboard`、`admin.piles.*`、`admin.stations.*`、`admin.reviews.*`、`admin.forecast.station`、`admin.users.*`、`admin.reservations.*`、`admin.invites.*`、`admin.permissions.*`。

## 5. 事务规则

开始充电、结算、充值、预约使用 `transaction()`，失败 `rollback()`。

- 一用户最多一个进行中/待支付订单。
- 一用户最多 3 条有效预约；一桩最多一条有效预约。
- 订单保存当时 `price_per_kwh`。
- 余额与钱包流水同一事务。
- `QSqlDatabase` 不得跨线程共享连接。

## 6. 运行参数

`foreign_keys=ON`、`journal_mode=WAL`、`synchronous=NORMAL`、`busy_timeout=5000`。路径由 `CHARGE_PILE_DB_PATH` 或 Qt 标准数据目录决定。

## 7. 安全（演示现状）

明文 TCP/HTTP；密码为随机盐 + SHA-256。新用户必须注册。不宜对公网暴露 `0.0.0.0`。
