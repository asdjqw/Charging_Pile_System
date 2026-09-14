# 充电预测子模块：文件说明与启动指南

## 运行预测必须先下载模型

**仓库只包含代码和轻量清单。运行预测必须下载下面三个模型包；只克隆仓库不能直接预测。**

资源统一放在 [GitHub Releases：机器学习模型资源](https://github.com/asdjqw/Charging_Pile_System/releases/tag/ml-resources-20260914)。

| 资源 | 下载链接 | 是否必须 |
|---|---|---|
| H1 两个模型 | [ml-models-h1.tar.gz](https://github.com/asdjqw/Charging_Pile_System/releases/download/ml-resources-20260914/ml-models-h1.tar.gz) | 必须 |
| H6 两个模型 | [ml-models-h6.tar.gz](https://github.com/asdjqw/Charging_Pile_System/releases/download/ml-resources-20260914/ml-models-h6.tar.gz) | 必须 |
| H24 两个模型 | [ml-models-h24.tar.gz](https://github.com/asdjqw/Charging_Pile_System/releases/download/ml-resources-20260914/ml-models-h24.tar.gz) | 必须 |
| 文件校验清单 | [SHA256SUMS](https://github.com/asdjqw/Charging_Pile_System/releases/download/ml-resources-20260914/SHA256SUMS) | 校验下载完整性 |
| 训练／验证／Test-A 数据 | [ml-training-data.tar.gz](https://github.com/asdjqw/Charging_Pile_System/releases/download/ml-resources-20260914/ml-training-data.tar.gz) | 可选；仅重训或复核时需要 |

### 校验和解压位置

压缩包保存在项目之外，例如单独的下载目录，不要提交回 Git。先在下载目录计算校验值，与 `SHA256SUMS` 对照：

```bash
shasum -a 256 ml-models-h1.tar.gz ml-models-h6.tar.gz ml-models-h24.tar.gz
```

如果下载了可选数据包，也运行 `shasum -a 256 ml-training-data.tar.gz` 对照清单。Linux 可以使用 `sha256sum` 代替 `shasum -a 256`。

然后进入项目根目录（包含 `ml/` 的目录），将以下下载路径替换为实际路径并解压：

```bash
tar -xzf /模型包下载目录/ml-models-h1.tar.gz
tar -xzf /模型包下载目录/ml-models-h6.tar.gz
tar -xzf /模型包下载目录/ml-models-h24.tar.gz
```

压缩包已包含 `ml/` 路径，**不要进入 `ml/` 后再解压**，否则会多出一层 `ml/ml/`。解压后六个模型应位于 `ml/artifacts/models/` 下，路径与统一冻结清单一致，不需要手动改名。

可选训练数据也在项目根目录解压：

```bash
tar -xzf /模型包下载目录/ml-training-data.tar.gz
```

解压后数据位于 `ml/datasets/cache/` 和 `ml/datasets/splits/`。这些文件已由 `ml/.gitignore` 排除，不进入普通 Git 提交。

模型包不是预测输入数据。即使已下载模型，运行时仍需要第 3 节规定的数仓小时快照；训练数据不能替代它。

本说明中的文件路径以 `ml/` 为起点。启动命令必须在包含 `ml/`、`bigscreen/` 和 `ChargePile.pro` 的项目根目录执行。

## 1. 当前能做什么，尚未完成什么

当前模块读取数仓提供的站点小时数据，构造特征，调用六个冻结模型，保存预测结果，并提供查询接口。查询读取最新成功批次，不现场训练或预测。

| 任务 | 预测内容 | 输入特征数 |
|---|---|---:|
| `load_h1` | H1 目标小时的平均负荷率 | 20 |
| `occupancy_h1` | H1 目标小时的充电时长占用率 | 20 |
| `load_h6` | H6 目标小时的平均负荷率 | 18 |
| `occupancy_h6` | H6 目标小时的充电时长占用率 | 18 |
| `load_h24` | H24 目标小时的平均负荷率 | 18 |
| `occupancy_h24` | H24 目标小时的充电时长占用率 | 18 |

例如当天 14:05 执行预测，数据必须完整到 `[13:00,14:00)`：

| 名称 | 对应时间 |
|---|---|
| 数据截止时间 `data_cutoff_time` | 当天 14:00 |
| 最后完整小时的起点 `t` | 当天 13:00 |
| H1 目标区间 | 当天 `[14:00,15:00)` |
| H6 目标区间 | 当天 `[19:00,20:00)` |
| H24 目标区间 | 次日 `[13:00,14:00)` |

这是三个目标小时，不是未来 1/6/24 小时的累计值，也不是连续 24 点曲线。

**已具备 ML 子模块代码和本地运行链路；真实 HDFS、MySQL、中台路由、用户端／管理员端／大屏界面尚需联调。** 原项目其他层未在此次整理中修改。模型保持冻结，没有重新训练或调整阈值。

## 2. 目录和每个文件的用途

```text
ml/
├── README.md                  ML 内唯一的说明文档
├── requirements.txt           Python 依赖
├── INTEGRATION_MANIFEST.json   整合来源和原项目完整性记录
├── __init__.py                ML 包初始化
├── errors.py                  公共异常
├── config/                    配置读取
├── features/                  特征定义和构造
├── prediction/                模型加载、推理、业务结果换算
├── service/                   一次完整预测的流程组织
├── warehouse/                 数仓读取、结果存储、查询接口及部署模板
├── cli/                       命令行入口
├── training/                  固定参数训练链路
├── datasets/                  共享训练数据及训练／验证／测试划分
└── artifacts/                 六个模型和当前 Test-A 评测结果
```

### 2.1 根目录

| 文件 | 具体用途 |
|---|---|
| `README.md` | 解释每个文件、输入要求、启动方式和后续交接工作 |
| `requirements.txt` | 固定模型计算、Parquet、HTTP、MySQL 所需的 Python 依赖版本，创建环境时安装 |
| `.gitignore` | 排除单独下载的模型和数据数组、运行输出、虚拟环境及缓存；轻量清单和评测记录仍保留在 Git 中 |
| `INTEGRATION_MANIFEST.json` | 记录第 16 版源压缩包、原项目文件校验值、模型来源及整合时的环境信息。用于追溯，不参与预测 |
| `__init__.py` | 声明 Python 包和包版本；包版本不等于各模型版本 |
| `errors.py` | 定义共用异常类型和六个错误码：配置错误、模型缺失、历史不足、当前小时缺失、特征错误、预测失败。各类均有实际调用；它不负责自动重试或记录日志 |

### 2.2 config/：配置

| 文件 | 具体用途 |
|---|---|
| `__init__.py` | 提供 `load_config()`，读取 YAML，检查必需配置分组、非空模型清单路径和至少 25 小时的整数历史窗口。原 `loader.py` 已合并到这里，不再多一层转接 |
| `default.yaml` | 保存模型清单路径、历史读取窗口及业务分级阈值 |

当前配置：

| 配置项 | 当前值与含义 |
|---|---|
| `artifacts.current_freeze_manifest` | 六模型统一清单的路径 |
| `prediction.history_window_hours` | 72：默认读取截止时间之前 72 小时，最后 25 小时必须完整 |
| `congestion.medium_threshold` / `high_threshold` | 0.50 / 0.80：按 H1 占用率划分低／中／高拥堵 |
| `warning.warning_threshold` / `critical_threshold` | 0.80 / 0.90：按 H1 负荷率划分正常／预警／严重预警 |

这份 YAML 不是模型调参文件。特征顺序及模型分类阈值、死区阈值、缩放系数由冻结清单管理，不要为了接数仓而修改。

### 2.3 features/：小时数据如何变成特征

| 文件 | 具体用途 |
|---|---|
| `__init__.py` | 导出 `FeaturePipeline`，供其他模块导入 |
| `schema.py` | 定义六个基础小时字段，以及 18／20 个模型特征的名称和固定列顺序 |
| `pipeline.py` | 按站点补齐小时网格并保留缺失，计算历史滞后、滚动均值及时间特征，输出 H1／H6／H24 各一份特征矩阵 |

令 `t` 为最后完整小时的起点，`h` 为 1、6 或 24：

| 特征 | 定义 |
|---|---|
| `hour`、`weekday`、`is_weekend` | `t` 的小时、星期和周末标记；星期一为 0、星期日为 6，周末标记为 0/1 |
| `target_hour`、`target_weekday`、`target_is_weekend` | 目标小时 `t+h` 的小时、星期和周末标记 |
| `load_lag_1`、`load_lag_6`、`load_lag_24` | `t-1`、`t-6`、`t-24` 小时的负荷率 |
| `load_rolling_mean_6`、`load_rolling_mean_24` | `t-6` 到 `t-1`、`t-24` 到 `t-1` 的负荷率均值，不含 `t` |
| `occupancy_lag_1`、`occupancy_lag_6`、`occupancy_lag_24` | 对应滞后小时的占用率 |
| `occupancy_rolling_mean_6`、`occupancy_rolling_mean_24` | 对应历史窗口的占用率均值，不含 `t` |
| `total_piles`、`station_capacity_kw` | 固定充电单元总数和站点总额定容量 |
| `current_load_ratio`、`current_occupancy_ratio` | `t` 小时的实际负荷率和占用率，仅 H1 使用 |

前 18 个特征供 H6/H24 使用，H1 再加最后两个。输入转为 `float32`，不额外标准化、平滑或填补缺失。数仓只需要提供第 3 节的小时字段，不需要重复构造上述特征。

### 2.4 prediction/：加载模型、执行预测、换算结果

| 文件 | 具体用途 |
|---|---|
| `__init__.py` | 声明预测包 |
| `registry.py` | 单次读取并保留冻结清单原文，供批次留档与推理共用；统一按项目根目录解析相对模型路径，按任务加载模型并核对 SHA-256，合并运行参数 |
| `predictor.py` | 核对特征名称及顺序，通过统一 `predict_ratio()` 执行单站推理；内部区分 RF 和 H1 两阶段结构。批量 `predict_h1_values()` 同时供训练评估使用，避免重复实现 H1 规则 |
| `postprocessor.py` | 校验业务阈值有序且位于 0～1，将比例换算成平均负荷 kW、等效占用／空闲数量和业务等级，直接使用最终字段名并按接口精度舍入 |

H1 是分类器加残差回归，H6/H24 是随机森林。统一入口不代表把不同模型强行改为同一种结构。六模型的必要推理参数集中在同一份冻结清单，不依赖独立修正规则文件。

### 2.5 service/：组织完整预测流程

| 文件 | 具体用途 |
|---|---|
| `__init__.py` | 声明服务包 |
| `prediction_service.py` | 接收小时数据及批次共用的模型注册器，构造特征，调用六模型并直接形成最终站点结果和目标区间；按跨度加载两个模型，计算后释放引用 |
| `batch.py` | 提供 `run_forecast()`，读取快照、配置及截止时间，创建唯一模型注册器，生成批次 ID，留存实际输入和特征，调用预测服务并发布结果；不再二次重命名预测字段 |

前者负责“数据到预测”，后者负责“读取、留档、预测、发布”。分开后替换存储或调度方式不需要改模型计算，因此保留两个文件。

### 2.6 warehouse/：数仓、结果存储和中台边界

| 文件 | 具体用途 |
|---|---|
| `__init__.py` | 声明数仓接入包 |
| `contract.py` | 定义字段、时间和单位；检查站点标识、重复小时、固定容量、质量标记和比例范围；确认最后 25 小时有效 |
| `source.py` | 从本地或 HDFS 读取 `manifest.json`、`hourly.parquet`，按时间和站点过滤，只加载所需小时数据 |
| `results.py` | 实现本地文件和 MySQL 两种存储；发布完整成功批次、处理重复提交、读取数据库环境变量；文件模式逐个扫描历史结果取最新批次，不一次性载入全部历史结果 |
| `api.py` | 提供 Flask 只读查询路由，筛选站点，附加模拟与过期标记；不启动服务器、不执行模型 |
| `sql/mysql_forecast.sql` | 供数据库负责人确认后执行的结果表 SQL；ML 启动不会自动建表 |
| `deploy/charging-ml.service` | Linux 单次预测服务模板，指定运行用户、目录、Python、环境文件、超时和重试 |
| `deploy/charging-ml.timer` | Linux 每小时第 5 分钟运行的定时器模板；文件存在不代表任务已安装或启用 |

结果表分工：

| 表 | 保存什么 |
|---|---|
| `ml_forecast_runs` | 每个成功批次的来源、截止时间、生成时间及完整预测 JSON，当前 API 从这里取结果 |
| `ads_station_forecast` | 每站点、每目标、每跨度一条预测比例，便于 SQL 查询；每站点每批次六行 |

文件模式用于没有数据库时联调，MySQL 模式用于部署，不是重复模块。若数据库采用其他结果表，必须适配 `results.py` 和对应查询，不能只改表名就认为接通。

### 2.7 cli/：两个启动入口

| 文件 | 具体用途 |
|---|---|
| `__init__.py` | 声明命令行包 |
| `warehouse_predict.py` | 执行一次预测，解析快照、时间、站点、存储和输出参数；成功退出码为 0，预测过程失败为 1 |
| `warehouse_api.py` | 启动本地查询服务，默认监听 `127.0.0.1:5010`，用于联调 |

两个入口分别负责“产生结果”和“查询结果”。只启动查询服务不会生成预测，也不会启动每小时任务。

### 2.8 training/：唯一的固定参数训练链路

| 文件 | 具体用途 |
|---|---|
| `__init__.py` | 声明训练包 |
| `dataset.py` | 只读内存映射加载共享数组和 Train／Validation／Test-A 索引，补齐目标时间与 H1 当前值，返回特征、真实标签和 Persistence 基准 |
| `train.py` | 从冻结模型读取已选参数，克隆并重新拟合，计算验证／测试指标，将新模型、元数据、指标写入新目录，不自动上线 |

日常预测不使用训练入口。它用于固定参数重跑，不回放全部历史参数搜索，也不保证跨环境生成完全相同的模型二进制。

H1 最终拟合使用 Train；RF 最终拟合使用 Train+Validation；Test-A 不参与拟合。H1 训练及验证行还会按原规则剔除标签越过下一划分边界的样本。本次整理未执行重新训练。

### 2.9 datasets/：保留的数据具体在哪

此目录是离线训练／评测资料，不是线上实时数据源。

| 文件 | 含义 |
|---|---|
| `split_manifest.json` | 原始划分边界及来源记录；Validation 从 2023-01-05 16:00 开始，Test-A 从 2023-02-01 20:00 开始 |
| `cache/cache_manifest.json` | 数组名称、形状、类型和校验值 |
| `cache/X_common.npy` | 6,159,792 行、15 列共享特征，补三个目标时间特征后为 18 列；H1 再补两个当前比例 |
| `cache/station_id.npy` | 每行的站点编号 |
| `cache/timestamp_ns.npy` | 每行小时起点的纳秒时间值，与其他数组逐行对应 |
| `cache/persistence_load.npy` | 当前小时负荷率，供 Persistence 基准及 H1 输入／残差计算使用 |
| `cache/persistence_occupancy.npy` | 当前小时占用率，用途同上 |
| `cache/y_load_h1.npy` | H1 负荷真实标签 |
| `cache/y_load_h6.npy` | H6 负荷真实标签 |
| `cache/y_load_h24.npy` | H24 负荷真实标签 |
| `cache/y_occupancy_h1.npy` | H1 占用率真实标签 |
| `cache/y_occupancy_h6.npy` | H6 占用率真实标签 |
| `cache/y_occupancy_h24.npy` | H24 占用率真实标签 |

`splits/` 下有 `load_h1`、`load_h6`、`load_h24`、`occupancy_h1`、`occupancy_h6`、`occupancy_h24` 六个目录，每个保留三个文件，共 18 个：

| 文件 | 含义 |
|---|---|
| `train.npy` | 训练样本在共享数组中的行号 |
| `validation.npy` | 验证样本在共享数组中的行号 |
| `test_a.npy` | 原始 Test-A 样本在共享数组中的行号 |

训练、验证、测试集都已保留，只是共享一份大数组，不复制三份相同特征。`y_*` 是实际标签，`persistence_*` 是实际当前值，都不是待删除的历史预测结果。

本目录没有深圳原始 5 分钟 CSV，也没有从原始 CSV 重建缓存的全套清洗代码。清单中的旧绝对路径及历史状态用于追溯，接入机器不需要存在那些旧路径；实际训练读取本目录数组和索引。

### 2.10 artifacts/：六个模型和六份评测

`models/CURRENT_MODEL_FREEZE_20260914.json` 是统一清单，保存模型路径、元数据路径、SHA-256、特征契约和推理参数。程序以它为准，不按目录日期猜测使用哪个模型。

| 任务 | 相对于 `artifacts/models/` 的目录 |
|---|---|
| `load_h1` | `urbanev-local-v1_1-h1-20260903/models/load_h1/` |
| `occupancy_h1` | `urbanev-local-v1_1-h1-20260903/models/occupancy_h1/` |
| `load_h6` | `urbanev-local-v1-20260902/load_h6/` |
| `occupancy_h6` | `urbanev-local-v1-20260902/occupancy_h6/` |
| `load_h24` | `urbanev-local-v1-20260902/load_h24/` |
| `occupancy_h24` | `urbanev-local-v1-20260902/occupancy_h24/` |

每组只有：

| 文件 | 含义 |
|---|---|
| `model.joblib` | 已训练模型本体；H1 内含分类器和残差回归器，RF 内含随机森林 |
| `metadata.json` | 原始特征顺序、参数、校验值及来源；重合的运行参数由统一清单覆盖。不要脱离清单单独加载后就认为行为相同 |

目录日期和原始版本是来源标识，不代表保留了多套候选。当前只有六个模型，不另设修正规则目录，不重写来源记录。

`test_a_current/` 保留：

| 文件 | 样本数 |
|---|---:|
| `load_h1.json` | 923,118 |
| `occupancy_h1.json` | 923,118 |
| `load_h6.json` | 916,028 |
| `occupancy_h6.json` | 916,028 |
| `load_h24.json` | 890,504 |
| `occupancy_h24.json` | 890,504 |

每份包含 RMSE、MAE、R²、误差在 ±5／±10 个百分点内的比例、Persistence 对比、裁剪情况和模型／数据校验信息。保留原任务全部 Test-A 索引，不同跨度的有效结束时间不同。

这是已使用过的原始 Test-A 上的统一回归评测，不是全新未见数据的泛化测试。`EVALUATION_COMPLETED` 只表示完成，不表示全部质量门槛通过。清单的 `previous_manifest_sha256` 对应评测当时的清单；合并配置没有改写历史结果。

### 2.11 实际预测后才生成的文件

| 位置或文件 | 内容 |
|---|---|
| `data/warehouse/ads/<run_id>.json` | 文件模式下的完整成功批次；MySQL 模式改为写数据库 |
| `data/warehouse/audit/<批次标识和随机后缀>/input_hourly.parquet` | 实际读取并校验后的小时输入，不合格比例保留缺失 |
| 同目录 `source_manifest.json` | 输入快照说明 |
| 同目录 `model_manifest.json` | 本次实际使用的模型清单 |
| 同目录 `features_h1.parquet` | 两个 H1 模型实际使用的特征，含站点编号 |
| 同目录 `features_h6.parquet` | 两个 H6 模型实际使用的特征 |
| 同目录 `features_h24.parquet` | 两个 H24 模型实际使用的特征 |
| 同目录 `prediction.json` | 发布前形成的完整预测结果 |

运行失败可能留下部分留档，是否发布成功以存储和命令退出码为准，不能只看 `prediction.json` 是否存在。同一输入、模型和时间重复提交不会覆盖原成功批次，但仍留下本次尝试的留档。部署时需要约定留档保留时间，当前没有自动清理任务。

## 3. 模型现在还需要提供什么

### 3.1 必须提供：小时数据快照

数仓负责原始去重、单位统一、小时聚合及质量检查，再发布：

```text
snapshot/
├── hourly.parquet    单个 Parquet 文件，或包含多个 Parquet 分片的同名目录
└── manifest.json     全部数据写完后最后发布
```

Parquet 是列式数据文件，这里用它在数仓与 Python 间交接，不要求在 Spark 内运行模型。每个版本发布后保持不可变，不能让 ML 读取 Spark 还在写入的目录。

`hourly.parquet` 必须含 8 个字段，每行一个站点、一个小时：

| 字段 | 类型及单位 | 应填内容 |
|---|---|---|
| `station_id` | 正整数 | 与项目界面一致的站点 ID |
| `timestamp` | 无时区 Arrow timestamp，按 Asia/Shanghai 本地时间解释 | 小时起点，13:00 表示 `[13:00,14:00)`；Parquet 中不能用字符串列代替时间类型 |
| `load_ratio` | 数值比例 | 小时电量 kWh ÷（站点固定总额定容量 kW × 1 小时） |
| `occupancy_ratio` | 数值比例 | 小时内所有充电单元累计充电时长 h ÷（固定充电单元数 × 1 小时） |
| `total_piles` | 正整数 | 固定充电单元总数，需与累计时长使用相同物理单元口径 |
| `station_capacity_kw` | 正数，kW | 对应站点全部充电单元的固定总额定容量 |
| `is_complete` | bool 或 0/1 | 采集完整为 true/1，否则 false/0 |
| `quality_status` | 非空字符串 | 合格为 `PASS`，不合格填原因 |

0.35 表示 35%，不要传入 35。占用率不是瞬时 `busy/总桩数`，也不包含停车占位或暂停充电占位。分母不能改为当小时在线设备数或在线容量。

数据规则：

1. 同站同小时只能一行，时间必须整点，读取窗口内桩数和总容量保持不变。
2. `is_complete=1` 且 `quality_status=PASS` 才接受比例值，其余小时保留缺失，不补零。
3. PASS 行出现缺失、无穷或超出兼容范围时整批拒绝。负荷兼容范围 `[-1e-9,1.05]`，占用 `[-1e-9,1.000001]`，接受后裁剪至 `[0,1]`；容差不是允许任意超额累计。
4. 默认读取最近 72 小时，最后 25 小时必须连续有效。例如 14:05 执行，要有前一天 13:00 至当天 13:00 的 25 行，含两个端点。
5. 缺失不等于零。确认采集完整且确实无充电才可记零，不完整小时不得部分求和后标为 PASS。
6. 源数据为 5 分钟记录时，上游须检查每小时 12 个不同且正确的时间槽，不能只数 12 行。订单／会话数据须先按业务键去重，核对物理端口和实际小时重叠。
7. “额定功率乘订单时长”或“将订单总电量均摊到各小时”均是估计，不等于实际分时电量，不能默认与训练目标等价。

数仓计算小时电量、累计充电时长及比例，ML 负责边界检查和模型特征构造。ML 不会猜容量或自动改写输入口径。

### 3.2 必须提供：快照说明

`manifest.json` 示例：

```json
{
  "contract": "station-hourly-v1",
  "timezone": "Asia/Shanghai",
  "data_version": "station-hourly-20260914-1400",
  "source_kind": "MEASURED",
  "station_ids": [1001, 1002],
  "semantics": {
    "load_ratio": "energy_kwh/(station_capacity_kw*1h)",
    "occupancy_ratio": "charging_duration_hours/(total_piles*1h)",
    "timestamp": "interval_start",
    "denominator": "fixed_total_installed"
  }
}
```

- `contract`、`timezone`、`semantics` 必须与示例一致。
- `data_version` 填本批数据的非空唯一版本名，不是固定使用示例日期。
- `station_ids` 列出本快照全部站点，正整数、不重复，且都有所需历史。
- 真实观测标 `MEASURED`，模拟数据标 `SIMULATED`，不得混淆。

### 3.3 部署还需要确认的事项

| 事项 | 由谁提供 | 本地联调是否必须 |
|---|---|---|
| 快照目录、站点 ID、口径、每小时发布时间 | 数仓负责人 | 必须；没有真实数据时需准备明确标为模拟的快照 |
| HDFS 地址、客户端环境和权限 | 数仓／部署负责人 | 本地快照模式不需要 |
| MySQL 地址、端口、数据库、账号权限和结果表 | 数据库负责人 | 文件存储模式不需要 |
| 中台地址、认证方式、站点授权 | 中台负责人 | 对外提供服务前必须 |
| 三端站点选择、预测区间和状态展示 | Qt／前端负责人 | 不影响模型计算，但展示模块需要完成 |

**启动现有模型不需要先提供新训练数据，需要的是符合定义的预测历史。** 字段对齐能让接口工作，不代表不同数据分布上的精度必然相同。

## 4. 如何启动

### 4.1 准备环境

当前验证环境为 Python 3.13，依赖版本见 `requirements.txt`。模型文件约 3.4 GB，共享训练数据约 891 MB；模型加载需要额外内存，部署前应实测峰值，不能用文件大小代替内存需求。

在项目根目录执行一次：

```bash
python3.13 -m venv .venv
source .venv/bin/activate
python -m pip install -r ml/requirements.txt
```

已有正确环境只需激活，不必重复创建。Qt 编译成功不代表 Python 环境已准备好。仅加载本项目可信的冻结模型文件。

### 4.2 执行一次预测

先准备第 3 节快照。以下路径要替换为真实目录，日期必须对应数据覆盖范围：

```bash
python -m ml.cli.warehouse_predict --snapshot /绝对路径/snapshot --as-of 2026-09-14T14:05:00 --store file
```

快照标为 `SIMULATED` 时必须显式允许：

```bash
python -m ml.cli.warehouse_predict --snapshot /绝对路径/snapshot --as-of 2026-09-14T14:05:00 --store file --allow-simulated
```

时间仅为示例。正式运行可省略 `--as-of` 使用当前上海时间；历史快照应指定对应时间，否则可能因当前时段无数据而失败。程序不会将旧快照自动视为今天的数据。

成功后终端显示含 `success: true`、`run_id`、站点数量和留档目录的 JSON。完整结果默认写入 `ml/data/warehouse/ads/`，实际输入和特征写入 `ml/data/warehouse/audit/`。没有快照不能直接执行，程序不会自动用训练缓存冒充线上输入。

| 可选参数 | 含义 |
|---|---|
| `--station-ids 1001 1002` | 仅预测这些站点，默认预测清单全部站点 |
| `--results-dir /绝对路径/ads` | 更换文件结果目录 |
| `--audit-dir /绝对路径/audit` | 更换运行留档目录，两种存储模式都使用 |
| `--config /绝对路径/config.yaml` | 使用另一份完整运行配置 |
| `--store mysql` | 写入数据库，见 4.4 节 |

`python -m ml.cli.warehouse_predict --help` 可查看参数，不会启动训练或预测。

### 4.3 启动查询服务

另开终端，进入同一项目根目录并激活环境：

```bash
python -m ml.cli.warehouse_api --store file
```

默认查询真实数据结果。若上一步生成模拟结果，改用：

```bash
python -m ml.cli.warehouse_api --store file --source-kind SIMULATED
```

然后请求：

```bash
curl http://127.0.0.1:5010/api/forecast/latest
curl http://127.0.0.1:5010/api/forecast/station/1001
```

也支持 `/api/forecast/latest?station_id=1001`。预测和查询必须使用相同存储及目录／数据库；预测改了 `--results-dir`，API 也要传相同目录。端口可用 `--port` 修改。

成功响应外层为 `{"code":0,"msg":"ok","data":...}`：

| 返回位置或字段 | 含义 |
|---|---|
| `data.stations[]` | 最新成功批次的站点结果；指定站点查询仅保留该站点 |
| `stations[].forecast["1h"/"6h"/"24h"]` | 三个目标小时的预测 |
| 预测内 `target_start`、`target_end` | 目标区间起止时间 |
| `load_ratio`、`load_kw` | 负荷率及乘固定总容量得到的平均功率 |
| `occupancy_ratio` | 充电时长口径占用率 |
| `equivalent_occupied_piles`、`equivalent_idle_piles` | 占用率乘固定单元数取整，以及总数减占用数量；不是实时可预约桩数 |
| `stations[].business_status` | 按 H1 结果生成的拥堵和负荷预警等级 |
| `data_cutoff_time`、`generated_at` | 数据截止时间、预测生成时间，不能混为一谈 |
| `run_id`、`data_version`、`models` | 批次、数据版本及模型版本 |
| `source_kind`、`simulation` | 来源及是否模拟 |
| `stale`、`age_seconds` | 按数据截止时间计算的过期状态和年龄；达到 2 小时标为过期 |

比例保留 6 位小数，功率保留 3 位小数。当前站点名称由 ID 生成，如“站点1001”；真实名称需展示层按 ID 关联。`peak` 和 `hourly_forecast` 是兼容保留的空字段，不代表已有峰值预测或 24 点曲线。

无成功批次／最新批次无此站点返回 404，非法查询站点参数返回 400，存储不可用返回 503。接口不会自动回查某站点更老批次。历史快照显示 `stale=true` 正常，不代表预测失败。

### 4.4 接 MySQL

数据库负责人先确认并应用 `warehouse/sql/mysql_forecast.sql`，再为预测和 API 两个进程配置：

| 环境变量 | 含义 | 未设置时 |
|---|---|---|
| `DB_HOST` | MySQL 主机 | `127.0.0.1` |
| `DB_PORT` | MySQL 端口 | `3306` |
| `DB_USER` | 数据库账号 | 必须提供 |
| `DB_PASSWORD` | 数据库密码 | 必须提供 |
| `DB_NAME` | 结果数据库 | `charging_screen` |

凭据通过终端环境或受控部署环境文件提供，不写入源代码。ML 不会自动读取其他模块的 `.env` 文件。

```bash
python -m ml.cli.warehouse_predict --snapshot /绝对路径/snapshot --store mysql
python -m ml.cli.warehouse_api --store mysql
```

第一条执行完单批次，第二条启动查询。模拟来源仍需分别增加 `--allow-simulated` 和 `--source-kind SIMULATED`。查询进程可用只读账号，发布进程需结果表写权限。ML 不自动创建数据库或修改其他业务表。

### 4.5 接 HDFS、定时运行和中台

HDFS 使用相同快照结构，只更换地址：

```bash
python -m ml.cli.warehouse_predict --snapshot hdfs://namenode:9000/warehouse/station_hourly/已发布版本 --store mysql
```

运行机器需 Hadoop 客户端、Java/libhdfs 环境、Hadoop 配置及访问权限；开启 Kerberos 时还需有效凭据。安装 Python 依赖不等于 HDFS 已接通。也可以先由数仓将同一已发布快照交付到本地进行联调。

每小时运行使用 `warehouse/deploy/` 中的 systemd 模板，部署负责人需要：

1. 将模板中的 `/opt/charging`、Python 路径、`charging` 用户改为实际值。
2. 在 `/etc/charging-ml.env` 提供 `ML_SNAPSHOT` 和数据库变量；运行用户对快照可读，对 `/var/lib/charging-ml/audit` 可写。
3. 确定上游每小时如何更新 `ML_SNAPSHOT` 或安全切换发布指针。ML 不会自动搜索最新 Spark 目录；读取期间快照内容不能变化。
4. 确认数仓在默认的每小时第 5 分钟前完成发布。模板失败后每 60 秒重试，启动限流每小时 5 次，单次超时 1800 秒，应根据实际耗时和发布时间确认配置。
5. 手工运行真实批次成功后再安装启用 service/timer，检查下一小时是否继续产出。模板不包含 API 常驻服务，查询服务需另行部署。

本地 Flask 查询入口没有认证和站点授权，不能直接作为公网接口。正式接入可由现有 Flask 中台注册 `warehouse.api.create_forecast_blueprint()`，或由中台转发本模块结果。`bigscreen/backend/app.py` 已使用 Flask，但当前未注册预测路由；认证、站点权限、对外部署仍由中台统一处理。

## 5. 后续工作：按此顺序推进

| 顺序 | 负责方 | 要做什么 | 如何确认完成 |
|---|---|---|---|
| 1 | 数仓 + ML | 确认 ID、单位、时间起点及容量口径，交付快照 | 8 个字段齐全，每站最后 25 小时有效 |
| 2 | ML | 文件模式运行单批次，核对实际特征和区间 | 每站三个时点、六个比例；14:05 的 H1 对应 14:00～15:00 |
| 3 | 数据库 + ML | 确认结果表及账号，接通数据库发布／查询 | 六项结果整批写入，重复提交不重复生成批次 |
| 4 | 数仓 + 部署 + ML | 接真实目录及每小时调度 | 连续多个小时有新结果；缺失时不发布半批，旧结果保留并显示过期 |
| 5 | 中台 | 注册／转发路由，加入认证和站点权限 | 用户能取授权站点结果，不能访问未授权站点 |
| 6 | Qt／前端 | 用户端、管理员端增加入口，大屏增加模块，关联站点名称 | 三端展示同一来源，明确目标小时、单位、模拟和过期状态，不假装有 24 点曲线 |
| 7 | 部署 + ML | 日志、失败告警、留档保留时间、资源和耗时检查 | 异常有人处理，长期运行不会因文件无限增长占满磁盘 |
