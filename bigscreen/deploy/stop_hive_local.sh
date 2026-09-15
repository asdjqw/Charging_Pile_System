#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/deploy/hive_env.sh"

for item in hiveserver2 metastore; do
  pid_file="$HIVE_PID_DIR/$item.pid"
  if [[ -f "$pid_file" ]]; then
    pid="$(cat "$pid_file")"
    kill "$pid" 2>/dev/null || true
  fi
done
source "$ROOT_DIR/deploy/hadoop_env.sh"
yarn --daemon stop nodemanager || true
yarn --daemon stop resourcemanager || true
hdfs --daemon stop datanode || true
hdfs --daemon stop namenode || true
echo "[OK] 本地 Hive/Hadoop 服务已停止"
