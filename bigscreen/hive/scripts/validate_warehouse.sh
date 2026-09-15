#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"
LOAD_DT="${LOAD_DT:-$(date +%F)}"
HIVE_CMD="${HIVE_CMD:-hive}"
read -r -a HIVE_CLI <<< "$HIVE_CMD"
"${HIVE_CLI[@]}" --hiveconf load_dt="$LOAD_DT" \
  -f "$ROOT_DIR/hive/hql/08_validate_warehouse.hql"
