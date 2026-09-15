# Web 大屏 MySQL 数据库 Schema 说明

本文档面向 Flask 后端和 Vue3/DataV 前端开发，说明第二阶段数据库 `charging_screen` 的数据来源、表结构、字段语义及接口映射。

> 前端不应直接连接 MySQL。正确链路为：Vue3/DataV 请求 Flask `/api/*` 接口，Flask 再读取 MySQL；数据库账号和密码只放在服务端 `config/database.env` 中。

## 1. 数据链路与命名规范

```text
PySpark 清洗和聚合
  -> HDFS <表名>.parquet/                 数仓计算与复用
  -> HDFS <表名>.csv_dir/                 MySQL 交换格式
  -> hdfs dfs -getmerge
  -> 本地 output/ads/<表名>.csv
  -> spark/jobs/load_mysql.py
  -> MySQL charging_screen
  -> Flask API
  -> Vue3 + DataV
```

HDFS CSV 目录统一命名为 `<表名>.csv_dir`，例如：

```text
/data/charging/ads/ads_overview.csv_dir/
/data/charging/ads/mysql_session_detail.csv_dir/
```

`mysql_` 只用于交换文件命名，导入数据库时会去掉该前缀：

| HDFS/CSV 名称 | MySQL 表名 |
| --- | --- |
| `mysql_session_detail` | `session_detail` |
| `mysql_battery_detail` | `battery_detail` |
| `mysql_station_dim` | `station_dim` |

其余 `ads_*` 名称保持不变。`load_mysql.py` 每次执行会删除并重建数据表，再按 1000 行一批全量写入，因此大屏库是可重建的查询库，不是业务交易主库。

## 2. 表分类

当前完整流水线会产生 27 张表：

| 分层 | 数量 | 表 |
| --- | ---: | --- |
| 总览与时间分析 | 6 | `ads_overview`、`ads_daily_trend`、`ads_monthly_trend`、`ads_hour_load`、`ads_weekday_hour_heat`、`ads_time_period` |
| 站点与对比分析 | 6 | `ads_station_all`、`ads_station_top`、`ads_district`、`ads_facility_compare`、`ads_weekend_compare`、`ads_platform_compare` |
| 用户、分布、电池与收入 | 9 | `ads_user_value`、`ads_user_segment`、`ads_duration_dist`、`ads_energy_dist`、`ads_power_dist`、`ads_battery_health`、`ads_battery_type_compare`、`ads_revenue_struct`、`ads_realtime_sessions` |
| 数据治理与作业信息 | 2 | `ads_data_quality`、`ads_pipeline_info` |
| 查询明细与维度 | 3 | `session_detail`、`battery_detail`、`station_dim` |
| 装载日志 | 1 | `etl_job_log` |

## 3. 前端主用 ADS 表

字段格式采用 `字段名 类型：含义`。`BIGINT` 为整数，`DOUBLE` 为小数，`VARCHAR` 为文本，`DATE/DATETIME` 为日期时间。百分比字段的单位均为 `%`，例如 `23.5` 表示 23.5%。电量单位为 kWh，功率为 kW，金额单位为元，时长单位为小时。

### 3.1 总览与时间分析

| 表名 | 字段 | 用途与 Flask 接口 |
| --- | --- | --- |
| `ads_overview` | `total_kwh DOUBLE` 总电量；`total_sessions BIGINT` 总订单；`total_revenue DOUBLE` 总收入；`paid_sessions BIGINT` 付费订单；`station_cnt BIGINT` 活跃站点；`user_cnt BIGINT` 用户数；`active_days BIGINT` 数据天数；`avg_kwh DOUBLE` 单均电量；`avg_hours DOUBLE` 单均时长；`avg_power DOUBLE` 平均功率；`fleet_rate DOUBLE` 营运车辆占比；`start_date DATE`、`end_date DATE` 统计区间；`max_power DOUBLE` 最大功率；`device_cnt BIGINT` 枪口数；`paid_rate DOUBLE` 付费率；`peak_hour BIGINT` 高峰小时 | 顶部 KPI，`GET /api/overview`；首屏字段 `overview` |
| `ads_daily_trend` | `stat_date DATE` 日期；`sessions BIGINT` 订单数；`kwh DOUBLE` 电量；`revenue DOUBLE` 收入；`users BIGINT` 用户数；`avg_kwh DOUBLE` 单均电量 | 日趋势，`GET /api/trend/daily?days=30`；`dailyTrend` |
| `ads_monthly_trend` | `stat_month_str VARCHAR` 月份 `YYYY-MM`；`sessions`、`kwh`、`revenue`、`avg_kwh`、`users` | 月趋势，`GET /api/trend/monthly`；`monthlyTrend` |
| `ads_hour_load` | `start_hour BIGINT` 0–23 时；`sessions`、`kwh`、`avg_power`、`avg_hours`；`sessions_pct DOUBLE` 订单占比；`time_period VARCHAR` 峰/平/谷 | 24 小时负荷，`GET /api/hour-load`；`hourLoad` |
| `ads_weekday_hour_heat` | `weekday_num BIGINT` 星期序号；`weekday_cn VARCHAR` 星期名称；`start_hour BIGINT` 小时；`sessions BIGINT`、`kwh DOUBLE` | 星期×小时热力图，`GET /api/heat/weekday-hour`；`weekdayHeat` |
| `ads_time_period` | `time_period VARCHAR` 峰/平/谷；`sessions`、`kwh`、`revenue`、`avg_kwh`、`avg_hours`、`sessions_pct`、`kwh_pct` | 峰平谷对比，`GET /api/time-period`；`timePeriod` |

### 3.2 站点、区域和多维对比

| 表名 | 字段 | 用途与 Flask 接口 |
| --- | --- | --- |
| `ads_station_all` | `station_id BIGINT` 站点ID；`station_name` 站名；`district` 行政区；`road` 道路；`facility_type_cn` 站型；`device_count BIGINT` 枪口数；`sessions`、`kwh`、`revenue`、`avg_kwh`、`avg_hours`、`avg_power`、`users`；`orders_per_device DOUBLE` 单枪订单数 | 全量站点排行源，`GET /api/stations/top?limit=10&metric=kwh`；`stationTop` |
| `ads_station_top` | 字段与 `ads_station_all` 相同 | Spark 预计算 TOP N；当前 Flask 为支持动态指标，主要读取 `ads_station_all` |
| `ads_district` | `district`；`sessions`、`kwh`、`revenue`、`avg_kwh`；`station_cnt`、`users`、`device_cnt`；`kwh_pct`；`orders_per_device` | 行政区对比，`GET /api/districts`；`district` |
| `ads_facility_compare` | `facility_type_cn`、`facility_type BIGINT`；`sessions`、`kwh`、`revenue`、`avg_kwh`、`avg_hours`、`avg_power`、`users`、`paid_rate`、`station_cnt`、`device_cnt`、`sessions_pct`、`kwh_pct`、`orders_per_device` | 交流/直流/交直流/超充对比，`GET /api/facility/compare`；`facility` |
| `ads_weekend_compare` | `day_type` 工作日/周末；`days`、`sessions`、`kwh`、`revenue`、`avg_kwh`、`avg_hours`、`avg_power`、`users`、`peak_hour`、`sessions_per_day`、`kwh_per_day`、`users_per_day` | 工作日与周末对比，`GET /api/weekend/compare`；`weekend` |
| `ads_platform_compare` | `platform` 平台；`sessions`、`users`、`kwh`、`revenue`、`avg_kwh`、`avg_hours`、`avg_power`、`sessions_pct` | 平台对比，`GET /api/platform/compare`；`platform` |

### 3.3 用户和数值分布

| 表名 | 字段 | 用途与 Flask 接口 |
| --- | --- | --- |
| `ads_user_value` | `user_id`；`sessions`、`kwh`、`revenue`、`avg_kwh`、`active_days`；`first_date`、`last_date`、`avg_hours`、`recency_days`；`r_score`、`f_score`、`m_score`、`rfm_score`；`segment` | RFM 用户榜，`GET /api/users/top?limit=10` |
| `ads_user_segment` | `segment`；`user_cnt`、`sessions`、`kwh`、`avg_sessions`、`avg_kwh`、`user_pct`、`kwh_pct` | 用户价值分层，`GET /api/users/segments`；`userSegment` |
| `ads_duration_dist` | `bin_label` 分箱标签；`bin_order` 排序号；`sessions`、`kwh`、`pct` | 时长分布，`GET /api/dist/duration`；`durationDist` |
| `ads_energy_dist` | `bin_label`、`bin_order`、`sessions`、`kwh`、`pct` | 单次电量分布，`GET /api/dist/energy`；`energyDist` |
| `ads_power_dist` | `bin_label`、`bin_order`、`samples` 样本数、`avg_power`、`pct` | 功率分布，`GET /api/dist/power`；`powerDist` |

前端绘制分箱图时必须按 `bin_order` 排序，不要按 `bin_label` 字符串排序。

### 3.4 电池、收入和滚动数据

| 表名 | 字段 | 用途与 Flask 接口 |
| --- | --- | --- |
| `ads_battery_health` | `soc_bin` SOC区间；`samples`；`avg_power`；`avg_voltage`；`avg_cell_diff_mv` 单体压差mV；`avg_temp_rise` 温升；`avg_max_temp` 最高温度；`avg_available_energy` 可用能量；`avg_available_capacity` 可用容量 | 电池健康，`GET /api/battery/health`；`batteryHealth` |
| `ads_battery_type_compare` | `facility_type_cn`；`samples`、`avg_power`、`avg_soc`、`avg_cell_diff_mv`、`avg_temp_rise` | 不同站型电池指标对比，`GET /api/battery/type-compare` |
| `ads_revenue_struct` | `dim_name` 维度值；`dim_type` 维度类别；`sessions`、`kwh`、`revenue`、`paid_sessions`、`paid_rate`、`avg_price` 平均度电收入 | 收入结构，`GET /api/revenue/struct?dim=行政区`；`revenueStruct`。可选维度：站点类型、行政区、平台、日期类型、峰平谷 |
| `ads_realtime_sessions` | `created_time DATETIME`；`station_name`、`district`、`facility_type_cn`、`platform`；`kwh_total`、`charging_fees`、`charge_hours`、`time_period` | 最新 50 条模拟实时流水，`GET /api/realtime?limit=20`；`realtime` |

`ads_realtime_sessions` 是离线批次中按时间排序得到的最新记录，不是 WebSocket 或消息队列产生的真正实时流。

### 3.5 数据质量和链路说明

| 表名 | 字段 | 用途与 Flask 接口 |
| --- | --- | --- |
| `ads_data_quality` | `stage VARCHAR` 处理阶段；`data_type VARCHAR` 数据类型；`cnt BIGINT` 记录数 | 展示原始、有效、丢弃等数量，`GET /api/quality`；`quality` |
| `ads_pipeline_info` | `run_time VARCHAR` 运行时间；`engine VARCHAR` 引擎；`storage VARCHAR` 存储模式；`raw_path`、`warehouse_path`、`ads_path`；`valid_sessions`、`battery_records`、`station_cnt`；`note` | 证明 Spark/HDFS 链路，`GET /api/pipeline`；`pipeline` |

## 4. 明细表和维度表

这些表主要供后端扩展查询、明细钻取和二次分析使用，当前大屏首屏不会直接返回全部明细。

### `session_detail`：充电会话宽表

| 字段 | 类型 | 含义 |
| --- | --- | --- |
| `session_id`、`user_id`、`station_id` | BIGINT | 会话、用户、站点标识 |
| `kwh_total`、`charging_fees` | DOUBLE | 充电量、费用 |
| `charge_hours`、`avg_power_kw`、`price_per_kwh` | DOUBLE | 时长、平均功率、度电价格 |
| `is_fleet_vehicle` | BIGINT | 是否营运车辆，1是、0否 |
| `facility_type`、`facility_type_cn` | BIGINT、VARCHAR | 站点类型编码和中文名称 |
| `platform` | VARCHAR | 用户/订单来源平台 |
| `created_time`、`stat_date` | DATETIME、DATE | 开始时间、统计日期 |
| `stat_year`、`stat_month`、`stat_month_str` | BIGINT、BIGINT、VARCHAR | 年、月、`YYYY-MM` |
| `start_hour`、`weekday_cn`、`day_type`、`time_period` | BIGINT、VARCHAR | 小时、星期、工作日/周末、峰平谷 |
| `station_name`、`district`、`road` | VARCHAR | 站点及地理维度 |
| `device_count` | BIGINT | 站点枪口数 |

索引：`idx_session_date(stat_date)`、`idx_session_station(station_id)`。

### `battery_detail`：电池采样宽表

| 字段 | 类型 | 含义 |
| --- | --- | --- |
| `session_id` | BIGINT | 关联充电会话 |
| `soc`、`soc_bin` | DOUBLE、VARCHAR | 荷电状态及区间 |
| `pack_voltage`、`charge_current`、`charge_power_kw` | DOUBLE | 包电压、电流、功率 |
| `max_cell_voltage`、`min_cell_voltage`、`cell_voltage_diff` | DOUBLE | 单体最高/最低电压及压差 |
| `max_temperature`、`min_temperature`、`temp_rise` | BIGINT | 最高/最低温度及温升 |
| `available_energy`、`available_capacity` | DOUBLE | 可用能量、可用容量 |
| `district`、`facility_type_cn`、`day_type`、`time_period` | VARCHAR | 区域、站型、日期类型、峰平谷维度 |

索引：`idx_battery_session(session_id)`。

### `station_dim`：站点维度表

| 字段 | 类型 | 含义 |
| --- | --- | --- |
| `station_id`、`location_id` | BIGINT | 站点和位置标识 |
| `station_name`、`address` | VARCHAR | 站名和地址 |
| `district`、`road` | VARCHAR | 行政区和道路 |
| `device_count` | BIGINT | 枪口数量 |
| `facility_type`、`facility_type_cn` | BIGINT、VARCHAR | 站型编码和名称 |
| `open_time` | VARCHAR | 营业时间 |

## 5. 装载日志表

### `etl_job_log`

| 字段 | 类型 | 含义 |
| --- | --- | --- |
| `id` | INT，自增主键 | 日志ID |
| `job_name` | VARCHAR(80) | 作业名，当前为 `spark_ads_load` |
| `rows_loaded` | INT | 本批次装载总行数 |
| `created_at` | DATETIME | 装载完成时间 |

数据表会在装载时重建，但 `etl_job_log` 不会被删除，用于保留历史装载记录。

## 6. Schema 的实际定义位置

| 内容 | 文件 |
| --- | --- |
| ADS 字段和指标计算口径 | `spark/jobs/analysis.py` |
| 清洗宽表字段 | `spark/jobs/etl_clean.py` |
| 作业信息字段 | `spark/jobs/run_all.py` |
| MySQL 类型推断、动态建表和索引 | `spark/jobs/load_mysql.py` |
| Flask 表与接口映射 | `backend/app.py`、`backend/db.py` |
| 数据库备份快照 | `sql/charging_screen.sql` |

`sql/charging_screen.sql` 是某次运行结果的备份快照，不是运行时唯一 Schema 来源。新增或修改 Spark 输出字段后，应先重新执行流水线和 `load_mysql.py`，再用 `mysqldump` 更新该快照。

## 7. 前端调用约定

推荐首屏只请求一次：

```http
GET /api/screen/bundle
```

统一响应格式：

```json
{
  "code": 0,
  "msg": "ok",
  "data": {},
  "updated_at": "2026-09-15 12:00:00"
}
```

使用注意：

- 图表读取 `data`，不要依赖 MySQL 字段类型字符串。
- 日期由后端序列化为 `YYYY-MM-DD`，时间为 `YYYY-MM-DD HH:mm:ss`。
- `NULL` 可能出现在无有效样本的平均值中，前端应显示为 `--` 或 0。
- Flask 默认带 TTL 缓存；数据重载后调用 `POST /api/cache/refresh` 立即刷新。
- `/api/stations/top` 的 `metric` 应使用可信字段，如 `kwh`、`sessions`、`revenue`，不要把任意用户输入直接拼接为数据库字段。
- 用 `GET /api/health` 检查当前 `data_source` 是 `mysql` 还是回退的 `csv`。

## 8. 与第一阶段数据库的边界

本库不是第一阶段 SQLite `charge_pile.db` 的替代品：第一阶段保存用户、预约、订单、充值等在线业务数据；`charging_screen` 保存可由 Hadoop/Spark 重新计算的分析结果。当前两套数据库没有自动同步，若以后接入第一阶段真实业务数据，应新增“SQLite/MySQL业务库 → HDFS ODS”的采集任务，而不是让前端跨库直连。
