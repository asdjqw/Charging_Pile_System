#!/usr/bin/env bash
# 答辩环境：提交 Spark 作业到 YARN，并把原始数据与结果存储在 HDFS（Hadoop 3.x）
#
#   用法： bash deploy/spark_submit.sh
#   默认上传 data/raw_expanded；可用 LOCAL_RAW=data/raw 临时切回小数据集
#   前置： HADOOP_HOME 已配置，hdfs/yarn 命令可用，原始数据已上传到 HDFS
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

# 载入 Hadoop 环境变量（由 deploy/setup_hadoop.sh 生成）
if [[ -f "$ROOT_DIR/deploy/hadoop_env.sh" ]]; then
  # shellcheck disable=SC1090
  source "$ROOT_DIR/deploy/hadoop_env.sh"
else
  echo "[WARN] 未找到 deploy/hadoop_env.sh，请先执行 bash deploy/setup_hadoop.sh"
fi

LOCAL_RAW="${LOCAL_RAW:-data/raw_expanded}"
HDFS_RAW="${HDFS_RAW:-/data/charging/raw_expanded}"
HDFS_WAREHOUSE="${HDFS_WAREHOUSE:-/data/charging/warehouse}"
HDFS_ADS="${HDFS_ADS:-/data/charging/ads}"

VENV_DIR="${VENV_DIR:-}"
if [[ -z "$VENV_DIR" && -f "$ROOT_DIR/deploy/venv_path.sh" ]]; then
  # shellcheck disable=SC1091
  source "$ROOT_DIR/deploy/venv_path.sh"
fi
VENV_DIR="${VENV_DIR:-$ROOT_DIR/.venv}"
SPARK_SUBMIT="$VENV_DIR/bin/spark-submit"

echo "[1/3] 上传原始数据到 HDFS"
[[ -d "$LOCAL_RAW" ]] || { echo "[ERROR] 本地原始数据目录不存在：$LOCAL_RAW"; exit 1; }
hdfs dfs -mkdir -p "$HDFS_RAW"
hdfs dfs -put -f "$LOCAL_RAW"/*.csv "$HDFS_RAW/"
hdfs dfs -ls "$HDFS_RAW"

echo "[2/3] 提交 Spark 作业（YARN 集群模式）"
export PYSPARK_PYTHON="$VENV_DIR/bin/python"
export PYSPARK_DRIVER_PYTHON="$PYSPARK_PYTHON"
"$SPARK_SUBMIT" \
  --master yarn \
  --deploy-mode client \
  --driver-memory 1g \
  --executor-memory 1g \
  --num-executors 1 \
  --conf spark.yarn.maxAppAttempts=1 \
  spark/jobs/run_all.py \
  --raw "$HDFS_RAW" \
  --warehouse "$HDFS_WAREHOUSE" \
  --ads "$HDFS_ADS"

echo "[3/3] 结果表从 HDFS 取回本地并装载 MySQL"
HDFS_ADS="$HDFS_ADS" DEST="output/ads" bash deploy/fetch_from_hdfs.sh
"$VENV_DIR/bin/python" spark/jobs/load_mysql.py
echo "完成：HDFS 存储 + Spark on YARN + MySQL 装载"
