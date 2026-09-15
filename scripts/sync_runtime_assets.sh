#!/usr/bin/env bash
# Copy schema/CSV/web next to a qmake binary.
# Use cp -r (not -a): VMware hgfs rejects preserving permissions.
set -euo pipefail
ROOT="${1:?project root}"
DEST="${2:?binary directory}"
WITH_WEB="${3:-}"

copy_tree() {
    local src="$1"
    local dst="$2"
    mkdir -p "$dst"
    cp -rf "$src/." "$dst/"
}

copy_tree "$ROOT/database" "$DEST/database"
copy_tree "$ROOT/database" "$DEST/../database"
mkdir -p "$DEST/data"
if [[ -f "$ROOT/data/北京市充电桩数据.csv" ]]; then
    cp -f "$ROOT/data/北京市充电桩数据.csv" "$DEST/data/"
fi
if [[ "$WITH_WEB" == "web" ]]; then
    copy_tree "$ROOT/web" "$DEST/web"
    copy_tree "$ROOT/web" "$DEST/../web"
fi
