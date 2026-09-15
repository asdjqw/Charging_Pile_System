# 分析大屏（当前实现）

> 原「用数据大屏替换 Web」变更说明已过时。请改读 [二期-大数据大屏与Hadoop.md](二期-大数据大屏与Hadoop.md) 和 [../bigscreen/README.md](../bigscreen/README.md)。

**正确入口**：`http://127.0.0.1:5000/`（Flask）。`admin_server` 的 `:8080` 不是分析接口。

主代码在 `bigscreen/`。`web/` 只是前端构建产物，由一期 HTTP 静态托管，但相对路径 `/api` 对不准 Flask。
