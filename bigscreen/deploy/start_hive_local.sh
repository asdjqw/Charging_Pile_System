#!/usr/bin/env bash
# 启动本地 HDFS/YARN、Hive Metastore 与 HiveServer2。
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"
source "$ROOT_DIR/deploy/hive_env.sh"
source "$ROOT_DIR/deploy/hadoop_env.sh"
HIVE_SERVER2_PORT="${HIVE_SERVER2_PORT:-10000}"

# 只检查监听表，不主动建立 TCP 连接。WSL 下高频 /dev/tcp 探测可能与
# 正在启动的 HiveServer2 竞争同一端口，造成误报 Address already in use。
port_up() { ss -H -ltn "sport = :$1" 2>/dev/null | grep -q .; }

mkdir -p "$HIVE_LOG_DIR" "$HIVE_PID_DIR"

# 本仓库伪分布式 NameNode 默认 8020（避开 Qt TCP 9000）。已在跑则跳过。
if ! hdfs dfs -ls / >/dev/null 2>&1; then
  hdfs --daemon start namenode || true
  hdfs --daemon start datanode || true
fi
port_up 8032 || yarn --daemon start resourcemanager || true
port_up 8042 || yarn --daemon start nodemanager || true

for _ in $(seq 1 30); do hdfs dfs -ls / >/dev/null 2>&1 && break; sleep 1; done
hdfs dfs -mkdir -p /tmp /tmp/hive /user/hive/warehouse \
  /warehouse/tablespace/managed/hive /warehouse/tablespace/external/hive
hdfs dfs -chmod 1777 /tmp /tmp/hive
hdfs dfs -chmod -R 777 /user/hive/warehouse /warehouse/tablespace

# Hadoop 服务就绪后再切换到 Hive 专用 Java 8/客户端配置。
source "$ROOT_DIR/deploy/hive_env.sh"

if ! port_up 9083; then
  nohup "$HIVE_HOME/bin/hive" --service metastore \
    > "$HIVE_LOG_DIR/metastore.log" 2>&1 &
  echo $! > "$HIVE_PID_DIR/metastore.pid"
fi
for _ in $(seq 1 60); do port_up 9083 && break; sleep 1; done
port_up 9083 || {
  tail -80 "$HIVE_LOG_DIR/metastore.log"; echo "[ERROR] Hive Metastore 启动失败"; exit 1;
}

if ! port_up "$HIVE_SERVER2_PORT"; then
  nohup "$HIVE_HOME/bin/hive" --service hiveserver2 \
    --hiveconf "hive.server2.thrift.port=$HIVE_SERVER2_PORT" \
    > "$HIVE_LOG_DIR/hiveserver2.log" 2>&1 &
  echo $! > "$HIVE_PID_DIR/hiveserver2.pid"
fi
for _ in $(seq 1 90); do port_up "$HIVE_SERVER2_PORT" && break; sleep 1; done
port_up "$HIVE_SERVER2_PORT" || {
  tail -80 "$HIVE_LOG_DIR/hiveserver2.log"; echo "[ERROR] HiveServer2 启动失败"; exit 1;
}

echo "[OK] 本地 Hadoop/Hive 服务状态"
jps
hdfs dfs -ls /
echo "NameNode:    http://127.0.0.1:9870"
echo "YARN:        http://127.0.0.1:8088"
echo "HiveServer2: jdbc:hive2://127.0.0.1:$HIVE_SERVER2_PORT/default"
