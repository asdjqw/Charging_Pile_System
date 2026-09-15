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

if [[ -z "${HIVE_CMD:-}" ]]; then
  if command -v hive >/dev/null 2>&1 && [[ "$(command -v hive)" != "$ROOT_DIR/.venv/bin/hive" ]]; then
    HIVE_CMD=hive
  elif [[ -x "$ROOT_DIR/.venv/bin/spark-sql" ]]; then
    HIVE_CMD="$ROOT_DIR/.venv/bin/spark-sql --master ${SPARK_MASTER}"
  else
    echo "[ERROR] 找不到 hive 或 .venv/bin/spark-sql"; exit 1
  fi
fi
SPARK_SUBMIT="${SPARK_SUBMIT:-$ROOT_DIR/.venv/bin/spark-submit}"
[[ -x "${SPARK_SUBMIT%% *}" || -x "$SPARK_SUBMIT" ]] || SPARK_SUBMIT=spark-submit

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
