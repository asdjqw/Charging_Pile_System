# 修复说明：大屏"接口超时/面板全 0"问题

## 1. 现象

拉取最新代码后打开大屏（`http://127.0.0.1:5000`）出现：

- 顶部 KPI 全部为 **0**，所有图表为空，`数据源` 显示 **CSV**，`更新`/`清洗记录` 为空；
- 页面底部提示 **`数据接口异常：timeout of 20000ms exceeded`**。

## 2. 原因（两个独立问题叠加）

### 2.1 接口超时：数据库连接"半开"导致请求假死

后端（gunicorn + Flask）使用连接池访问 MySQL。当 **mysqld 在服务运行期间重启过**
（本次是 09-15 10:38 重启），池中的旧连接会变成"半开"状态：服务端已经关闭，客户端还不知道，
此时执行查询会一直等待 TCP 重传超时（可达十几分钟）。

本项目的首屏聚合接口 `/api/screen/bundle` 一次要查 ~20 张结果表，几秒钟内就会把 4 个 gunicorn
worker 全部占住 → 后续请求全部排队 → 前端 axios **20 秒超时**，页面呈现"全空 + 超时"。

### 2.2 面板全 0：新克隆的仓库没有数据库配置，静默降级到 CSV

`config/database.env` 属于本机凭据（已被 `.gitignore` 忽略，仓库只提供 `database.env.example`），
而 `backend/config.py` 的内置默认值是 `root` + 空密码。Ubuntu 上 MySQL 的 root 使用 `auth_socket`
认证，**TCP 连接必然 `Access denied`**；后端捕获异常后自动降级到 CSV 数据源，
而新克隆的 `output/ads/` 是空的（被 `.gitignore` 忽略）→ 所有面板都是 0。

## 3. 修复内容

| 文件 | 修改 |
| --- | --- |
| `bigscreen/backend/db.py` | 连接增加 `read_timeout`/`write_timeout`（默认 8s）、`connect_timeout`（3s）；连接池等待 1s；**新增熔断**：连接失败后 30s 内直接走 CSV，不再逐个查询等待；错误信息记录供健康检查展示 |
| `bigscreen/backend/config.py` | 内置默认账号改为与 `deploy.sh` 一致：`DB_USER=charging` / `DB_PASSWORD=charging123`（本地 Windows 开发按 README 改成 root/空密码），并新增超时/熔断参数 |
| `bigscreen/backend/app.py` | `/api/health` 增加 `mysql.last_error`、`mysql.breaker_open`、`csv_results`、`hint`，一眼看出"连不上库"还是"没有结果文件" |
| `bigscreen/frontend/src/views/Screen.vue` | 接口成功但数据为空时，页面提示具体排查方向（而不是静默显示 0） |
| `bigscreen/config/database.env.example` | 默认值改为部署机的应用账号，并补充超时/熔断说明 |
| `bigscreen/deploy/deploy.sh` | 只要有 root/sudo 的 MySQL 访问权限，就**幂等创建** `charging` 账号；配置仍是 root/空密码时自动改写为应用账号 |
| `web/` | 同步重新构建的大屏静态产物（含上面的前端提示） |

## 4. 修复后的行为

| 场景 | 修复前 | 修复后 |
| --- | --- | --- |
| MySQL 正常 | 正常 | 正常（不变） |
| MySQL 重启导致连接失效 | 请求假死，前端 20s 超时 | 单次请求最多等 3~8s 即熔断，之后 **毫秒级** 返回 CSV 结果；`/api/health` 给出 `last_error` |
| 未配置数据库 + 没有 CSV 结果 | 所有面板 0，无提示 | 页面提示"未取到数据：请确认后端已连上 MySQL，或已执行 deploy.sh / run_pipeline" |
| 未配置数据库 + 有 CSV 结果 | 部分接口报错 | 自动降级到 CSV，大屏可用（数据来自上一次离线计算） |

## 5. 部署机操作（已在本虚拟机执行过一遍）

```bash
cd Charging_Pile_System/bigscreen
cp config/database.env.example config/database.env     # 默认 charging/charging123
python3.12 -m venv .venv && .venv/bin/pip install -r backend/requirements.txt
sudo systemctl restart charging-screen                 # 或 gunicorn -c deploy/gunicorn.conf.py backend.wsgi:application
curl -s http://127.0.0.1:5000/api/health               # 期望 mysql.connected = true
```

## 6. 验证结果

| 验证项 | 结果 |
| --- | --- |
| MySQL 不可达（模拟 10.255.255.1）时请求 `/api/screen/bundle` | 首次 3.1s（触发熔断）→ 之后 **3ms**，HTTP 200（原为 20s 超时/500） |
| 熔断期间 `/api/overview` | 200，**2ms** |
| `/api/health` | 返回 `breaker_open=true`、`last_error=(2003, "Can't connect to MySQL server ...")` |
| 恢复 MySQL 后 | `breaker_open=false`、`mysql.connected=true`，数据正常 |

> 提示：仓库 `main` 中目前还包含 `charging-bigscreen-export/` 与 `charging-bigscreen-export.tar.gz`
> （约 70MB 的导出产物），建议单独清理，避免仓库体积持续膨胀。
