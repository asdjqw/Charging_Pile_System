#!/usr/bin/env bash
# 单机把 Hive 四层数仓跑到现有 HDFS（默认 RPC 8020）。
# 有独立 Hive CLI 就用 hive；否则用项目 venv 的 spark-sql（本机无外网/无 Hive 安装包时的路径）。
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [[ -f "$ROOT_DIR/deploy/hadoop_env.sh" ]]; then
  # shellcheck disable=SC1091
  source "$ROOT_DIR/deploy/hadoop_env.sh"
fi

CONF="$ROOT_DIR/.runtime/spark-conf"
mkdir -p "$CONF" "$ROOT_DIR/.runtime/hive-tmp" "$ROOT_DIR/.runtime/hive-logs"
if [[ -n "${HADOOP_CONF_DIR:-}" && -f "$HADOOP_CONF_DIR/core-site.xml" ]]; then
  cp "$HADOOP_CONF_DIR/core-site.xml" "$CONF/"
  [[ -f "$HADOOP_CONF_DIR/hdfs-site.xml" ]] && cp "$HADOOP_CONF_DIR/hdfs-site.xml" "$CONF/"
  [[ -f "$HADOOP_CONF_DIR/yarn-site.xml" ]] && cp "$HADOOP_CONF_DIR/yarn-site.xml" "$CONF/"
  [[ -f "$HADOOP_CONF_DIR/mapred-site.xml" ]] && cp "$HADOOP_CONF_DIR/mapred-site.xml" "$CONF/"
  [[ -f "$HADOOP_CONF_DIR/log4j.properties" ]] && cp "$HADOOP_CONF_DIR/log4j.properties" "$CONF/"
fi
if [[ ! -f "$CONF/hive-site.xml" ]]; then
  cat > "$CONF/hive-site.xml" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
  <property><name>javax.jdo.option.ConnectionURL</name><value>jdbc:derby:;databaseName=$ROOT_DIR/.runtime/metastore_db;create=true</value></property>
  <property><name>javax.jdo.option.ConnectionDriverName</name><value>org.apache.derby.jdbc.EmbeddedDriver</value></property>
  <property><name>hive.metastore.warehouse.dir</name><value>/warehouse/tablespace/managed/hive</value></property>
  <property><name>hive.exec.scratchdir</name><value>/tmp/hive</value></property>
  <property><name>hive.exec.local.scratchdir</name><value>$ROOT_DIR/.runtime/hive-tmp</value></property>
  <property><name>hive.exec.dynamic.partition</name><value>true</value></property>
  <property><name>hive.exec.dynamic.partition.mode</name><value>nonstrict</value></property>
</configuration>
EOF
fi
cat > "$CONF/spark-defaults.conf" <<'EOF'
spark.driver.memory                 1g
spark.driver.maxResultSize          512m
spark.sql.shuffle.partitions        4
spark.ui.enabled                    false
EOF

export HADOOP_CONF_DIR="$CONF"
export SPARK_CONF_DIR="$CONF"
export HIVE_CONF_DIR="$CONF"
export SPARK_LOCAL_IP="${SPARK_LOCAL_IP:-127.0.0.1}"
export SPARK_MASTER="${SPARK_MASTER:-local[2]}"
if [[ -x "$ROOT_DIR/.venv/bin/python" ]]; then
  export PYSPARK_PYTHON="$ROOT_DIR/.venv/bin/python"
  export PYSPARK_DRIVER_PYTHON="$ROOT_DIR/.venv/bin/python"
fi

command -v hdfs >/dev/null || { echo "[ERROR] 找不到 hdfs，请先 source deploy/hadoop_env.sh 并启动 HDFS"; exit 1; }
hdfs dfs -mkdir -p /tmp/hive /warehouse/charging_pile \
  /warehouse/tablespace/managed/hive /warehouse/tablespace/external/hive
hdfs dfs -chmod 1777 /tmp /tmp/hive || true

# pip 安装的 pyspark 不会把 spark-sql/spark-submit 软链到 venv/bin，
# 因此这里同时检查 venv/bin 与 site-packages/pyspark/bin 两处。
PYSPARK_BIN=""
for candidate in "$ROOT_DIR"/.venv/lib/python*/site-packages/pyspark/bin; do
  [[ -x "$candidate/spark-sql" ]] && PYSPARK_BIN="$candidate" && break
done

if [[ -z "${HIVE_CMD:-}" ]]; then
  if command -v hive >/dev/null 2>&1 && [[ "$(command -v hive)" != "$ROOT_DIR/.venv/bin/hive" ]]; then
    HIVE_CMD=hive
  elif [[ -x "$ROOT_DIR/.venv/bin/spark-sql" ]]; then
    HIVE_CMD="$ROOT_DIR/.venv/bin/spark-sql --master ${SPARK_MASTER}"
  elif [[ -n "$PYSPARK_BIN" ]]; then
    HIVE_CMD="$PYSPARK_BIN/spark-sql --master ${SPARK_MASTER}"
  else
    echo "[ERROR] 找不到 hive 或 spark-sql（可 pip install pyspark==3.5.3）"; exit 1
  fi
fi
SPARK_SUBMIT="${SPARK_SUBMIT:-$ROOT_DIR/.venv/bin/spark-submit}"
if [[ ! -x "$SPARK_SUBMIT" && -n "$PYSPARK_BIN" ]]; then
  SPARK_SUBMIT="$PYSPARK_BIN/spark-submit"
fi
[[ -x "${SPARK_SUBMIT%% *}" || -x "$SPARK_SUBMIT" ]] || SPARK_SUBMIT=spark-submit

# 如果用的是系统自带 Hive CLI，则让 Spark 复用它的元数据库（否则 Hive 建的表 Spark 看不到，
# 会出现 "UnresolvedRelation [charging_ods, ...]" 之类的错误）。
HIVE_CLI_PATH="${HIVE_CMD%% *}"
HIVE_CLI_REAL="$(command -v "$HIVE_CLI_PATH" 2>/dev/null || echo "$HIVE_CLI_PATH")"
if [[ "$HIVE_CLI_REAL" == *hive* && "$HIVE_CLI_REAL" != *spark-sql* ]]; then
  SYS_HIVE_SITE="$(dirname "$(dirname "$HIVE_CLI_REAL")")/conf/hive-site.xml"
  if [[ -f "$SYS_HIVE_SITE" ]]; then
    jdo_url="$(grep -A1 'javax.jdo.option.ConnectionURL' "$SYS_HIVE_SITE" | grep -o '<value>[^<]*' | head -1 | sed 's#<value>##')"
    jdo_driver="$(grep -A1 'javax.jdo.option.ConnectionDriverName' "$SYS_HIVE_SITE" | grep -o '<value>[^<]*' | head -1 | sed 's#<value>##')"
    if [[ -n "$jdo_url" ]]; then
      log_msg="[INFO] 复用系统 Hive 元数据库：$jdo_url"
      echo "$log_msg"
      python3 - "$CONF/hive-site.xml" "$jdo_url" "$jdo_driver" <<'PY'
import sys, re
path, url, driver = sys.argv[1], sys.argv[2], sys.argv[3]
with open(path, encoding="utf-8") as fh:
    text = fh.read()
text = re.sub(r'(<name>javax\.jdo\.option\.ConnectionURL</name>\s*<value>)[^<]*(</value>)', r'\g<1>' + url + r'\g<2>', text)
if driver:
    text = re.sub(r'(<name>javax\.jdo\.option\.ConnectionDriverName</name>\s*<value>)[^<]*(</value>)', r'\g<1>' + driver + r'\g<2>', text)
with open(path, "w", encoding="utf-8") as fh:
    fh.write(text)
PY
    fi
  fi
fi

LOAD_DT="${LOAD_DT:-$(date +%F)}"
LOCAL_RAW="${LOCAL_RAW:-$ROOT_DIR/data/raw_expanded}"
if [[ ! -f "$LOCAL_RAW/nvv2t.csv" ]]; then
  echo "[INFO] 缺少扩容数据，先生成 data/raw_expanded"
  python3 "$ROOT_DIR/spark/jobs/generate_expanded_data.py" \
    --raw "$ROOT_DIR/data/raw" \
    --out "$LOCAL_RAW"
fi

echo "[INFO] HIVE_CMD=$HIVE_CMD"
LOAD_DT="$LOAD_DT" MODE="${MODE:-hdfs}" LOCAL_RAW="$LOCAL_RAW" \
  WAREHOUSE_ROOT="${WAREHOUSE_ROOT:-/warehouse/charging_pile}" \
  SPARK_MASTER="$SPARK_MASTER" SPARK_SUBMIT="$SPARK_SUBMIT" \
  HIVE_CMD="$HIVE_CMD" ANALYTICS_SQL_CMD="${ANALYTICS_SQL_CMD:-$HIVE_CMD}" \
  bash "$ROOT_DIR/hive/scripts/build_warehouse.sh"
