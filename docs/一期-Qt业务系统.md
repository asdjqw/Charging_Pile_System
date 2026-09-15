# 一期：Qt 业务系统

> 本文替代旧的「feature 分支改动说明」。描述的是当前 `user_client` / `admin_client` / `admin_server`。

## 职责边界

| 进程 | 职责 | 不做什么 |
|---|---|---|
| `admin_server` | 独占 SQLite；TCP 业务；HTTP 静态 `web/` + 三个只读接口 | 不跑 Spark，不直接给分析大屏提供 `/api/screen/bundle` |
| `user_client` | 车主 GUI，只发 TCP 动作 | 不打开 `charge_pile.db` |
| `admin_client` | 运营 GUI，只发 TCP 动作 | 同上 |

客户端与后端约定：长度前缀 4 字节大端 + UTF-8 JSON。字段含 `action`、`requestId`、`token`、`data`。

## 默认端口

| 端口 | 用途 |
|---|---|
| **9000** | Qt TCP（用户端、管理端） |
| **8080** | Qt HTTP：静态 `web/`，以及 `/api/health`、`/api/dashboard`、`/api/stations` |

Hadoop NameNode 已改为 **8020**，不必再把 Qt 改成 9100。

## 进程模型

`admin_server` 无窗口。主线程持有 `DatabaseManager` 和 `ApiDispatcher`；网络线程跑 `LocalServer` 的两个 `QTcpServer`。请求经队列回到主线程串行执行 SQL。

## 用户端能力

注册 / 手机号登录、定位找站、收藏、预约、模拟充电与结算、钱包充值、订单、站点评价。电站详情里有 **充电预测**（TCP `forecast.station` → 后端转 HTTP `CHARGE_PILE_ML_URL`，默认 `http://127.0.0.1:5010`）。有实测批次时页面显示冻结模型结果（`source_kind=MEASURED`），不再使用 `demo_forecast.json` 模拟数据。

演示账号：手机号 `13800001111` / `123456`。新用户必须走注册，登录不会自动建号。

## 管理端能力

侧栏九页（下标与 `QStackedWidget` 一致）：

0. 销售业绩  
1. 电桩状态  
2. 充电桩管理  
3. 充电站管理  
4. **充电预测**（机器学习结果展示）  
5. **评价管理**  
6. 用户管理  
7. 预约管理  
8. 权限管理（邀请码 + 角色权限）

「充电站管理」上的「充电预测」会跳到第 4 页并查询。预测需要本机 ML 查询服务已启动。

演示管理员：`admin` / `123456`。运维员示例：`ops01` / `ops123`。

## HTTP 与分析大屏的关系

打包后的 `web/` 是 Vue 分析大屏的构建产物，但运行时仍请求 **`/api/...` 相对路径**。`admin_server` 只实现三个运营快照接口，**没有** `/api/screen/bundle`。因此：

- 看 **15 维分析大屏**：浏览器打开 Flask **`http://127.0.0.1:5000/`**
- 打开 `http://127.0.0.1:8080/` 容易出现「数据接口异常」，这不是管理端缺页，是走错了入口

## 构建

需要 Qt 6（含 Charts）。根工程 `ChargePile.pro`。

```bash
# Ubuntu 依赖
bash scripts/install_deps_ubuntu.sh
# 编译
bash scripts/build.sh
# 只编译并拉起三个 Qt 程序
bash scripts/rebuild_run.sh
```

`.pro` 变更后必须在 Qt Creator 里 **Run qmake** 再编译。共享盘 `noexec` 时脚本会把二进制拷到 `~/Charge_pile_bin`。

环境变量见根目录 `README.md`。
