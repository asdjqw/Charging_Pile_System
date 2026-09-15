# 客户端与后端（当前实现）

> 原 `feature/User_client` 分支演进说明已过时。请改读 [一期-Qt业务系统.md](一期-Qt业务系统.md)。

当前事实：两个 Qt 客户端只走 TCP；`admin_server` 独占 SQLite；机器学习经服务端转发到 `:5010`；分析大屏是独立的 Flask `:5000`。
