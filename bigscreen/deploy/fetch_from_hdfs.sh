#!/usr/bin/env bash
# 把 HDFS 上的分析结果表（Spark 输出的 csv_dir 目录）取回本地，供装载 MySQL / 大屏使用
#
#   用法： bash deploy/fetch_from_hdfs.sh
#   说明： Spark 写 HDFS 时每张表输出一个目录（<表名>.csv_dir），用 hdfs dfs -getmerge 合并为单文件
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [[ -f "$ROOT_DIR/deploy/hadoop_env.sh" ]]; then
  # shellcheck disable=SC1090
  source "$ROOT_DIR/deploy/hadoop_env.sh"
fi

HDFS_ADS="${HDFS_ADS:-/data/charging/ads}"
DEST="${DEST:-output/ads}"

command -v hdfs >/dev/null 2>&1 || { echo "[ERROR] 未找到 hdfs 命令，请先执行 bash deploy/setup_hadoop.sh"; exit 1; }

rm -rf "$DEST" && mkdir -p "$DEST"

count=0
# hdfs dfs -ls -C 只输出路径，避免解析 ls 详情行
while read -r dir; do
  [[ -n "$dir" ]] || continue
  name="$(basename "$dir" | sed 's/\.csv_dir$//')"
  hdfs dfs -getmerge "$dir" "$DEST/${name}.csv"
  count=$((count + 1))
done < <(hdfs dfs -ls -C "$HDFS_ADS" | grep '\.csv_dir$' || true)

echo "[OK] 已从 $HDFS_ADS 取回 $count 张结果表到 $DEST"
ls -1 "$DEST" | head -5
