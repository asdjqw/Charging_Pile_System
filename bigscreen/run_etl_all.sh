#!/usr/bin/env bash
# 答辩入口：ODS 加载完成后执行 DWD -> DWS -> ADS -> MySQL。
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$ROOT_DIR/hive/scripts/run_etl_all.sh" "$@"
