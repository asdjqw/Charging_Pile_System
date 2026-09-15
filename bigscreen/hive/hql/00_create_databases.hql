-- 四层 Hive 数据库。LOCATION 均可通过 -hiveconf warehouse_root=... 覆盖。
CREATE DATABASE IF NOT EXISTS charging_ods
LOCATION '${hiveconf:warehouse_root}/ods';

CREATE DATABASE IF NOT EXISTS charging_dwd
LOCATION '${hiveconf:warehouse_root}/dwd';

CREATE DATABASE IF NOT EXISTS charging_dws
LOCATION '${hiveconf:warehouse_root}/dws';

CREATE DATABASE IF NOT EXISTS charging_ads
LOCATION '${hiveconf:warehouse_root}/ads';
