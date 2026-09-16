#!/usr/bin/env bash
# 本地管道符 TXT -> MySQL。MySQL 必须启用 local_infile=1。
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
LOAD_DT="${1:-${LOAD_DT:-$(date +%F)}}"
STAGE_DIR="${LOCAL_MYSQL_STAGE_DIR:-$ROOT_DIR/output/mysql_stage/$LOAD_DT}"
PYTHON_BIN="${PYTHON_BIN:-$ROOT_DIR/.venv/bin/python}"
[[ -x "$PYTHON_BIN" ]] || PYTHON_BIN="python3"
"$PYTHON_BIN" "$ROOT_DIR/mysql/scripts/import_ads_pipe_text.py" --load-date "$LOAD_DT" --stage-dir "$STAGE_DIR"
