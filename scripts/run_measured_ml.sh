#!/usr/bin/env bash
# Run frozen models on MEASURED session hours, bind results to Qt station IDs,
# and (re)start the :5010 query service so the user-client station page is not simulated.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENV="${CHARGING_ML_FULL_VENV:-$HOME/charging-ml-full}"
QUERY_VENV="${CHARGING_ML_VENV:-$HOME/charging-ml-venv}"
SNAP="${ML_SNAPSHOT_DIR:-$HOME/ml-warehouse/dws-measured}"
ADS="${ML_ADS_DIR:-$HOME/ml-warehouse/ads}"
QT_DB="${CHARGE_PILE_DB:-$HOME/.local/share/ChargePileLab/charge_pile.db}"
PIP_INDEX="${PIP_INDEX:-https://pypi.tuna.tsinghua.edu.cn/simple}"
LOG_DIR="${CHARGE_ALL_LOGDIR:-$HOME/charge-pile-logs}"
LOCAL_ML="${CHARGING_ML_LOCAL:-$HOME/charging-ml-run}"

log() { printf '\033[36m[%s]\033[0m %s\n' "$(date '+%H:%M:%S')" "$*"; }

if [[ ! -x "$VENV/bin/python" ]]; then
  log "创建推理环境 $VENV （Python 3.12）"
  python3.12 -m venv "$VENV"
fi
if ! "$VENV/bin/python" -c "import xgboost, sklearn, pyarrow, pymysql, flask" 2>/dev/null; then
  log "安装 ml/requirements.txt"
  "$VENV/bin/python" -m pip install -U pip -i "$PIP_INDEX"
  "$VENV/bin/pip" install -r "$ROOT/ml/requirements.txt" -i "$PIP_INDEX"
fi

mkdir -p "$SNAP" "$ADS" "$ROOT/ml/data/warehouse/ads" "$LOG_DIR" "$LOCAL_ML/ml"
log "同步推理代码到 $LOCAL_ML"
rsync -a --delete \
  --exclude 'data/' --exclude 'datasets/' --exclude '__pycache__/' \
  --exclude '*.joblib' \
  "$ROOT/ml/" "$LOCAL_ML/ml/"
if [[ ! -f "$LOCAL_ML/ml/artifacts/models/urbanev-local-v1-20260902/load_h6/model.joblib" ]]; then
  log "同步模型文件到本地盘（共享盘加载极慢）"
  rsync -a "$ROOT/ml/artifacts/models/" "$LOCAL_ML/ml/artifacts/models/"
fi

cd "$LOCAL_ML"
export PYTHONUNBUFFERED=1
export PYTHONPATH="$LOCAL_ML"

log "从 MySQL session_detail 构建 MEASURED 小时快照"
"$VENV/bin/python" -m ml.cli.build_measured_snapshot --out "$SNAP"

log "运行六个冻结模型（首次加载约数分钟）"
"$VENV/bin/python" -m ml.cli.warehouse_predict --snapshot "$SNAP" --store file --results-dir "$ADS"

log "发布仓库实测批次到 ml/fixtures"
"$VENV/bin/python" - <<PY
import json, shutil
from pathlib import Path
ads = Path("$ADS")
best = None
for path in ads.glob("*.json"):
    payload = json.loads(path.read_text(encoding="utf-8"))
    if payload.get("source_kind") != "MEASURED" or not payload.get("success"):
        continue
    key = (payload.get("data_cutoff_time") or "", payload.get("generated_at") or "")
    if best is None or key > best[0]:
        best = (key, path)
if best is None:
    raise SystemExit("no MEASURED batch")
dest = Path("$ROOT/ml/fixtures/measured_forecast.json")
shutil.copyfile(best[1], dest)
print(json.dumps({"copied": str(best[1]), "dest": str(dest)}, ensure_ascii=False))
PY

if [[ -f "$QT_DB" ]]; then
  log "把预测结果绑定到 Qt 电站 ID"
  "$VENV/bin/python" -m ml.cli.bind_forecast_to_qt \
    --results-dir "$ADS" \
    --qt-db "$QT_DB" \
    --out "$ROOT/ml/data/warehouse/ads/measured_forecast.json"
  cp -f "$ROOT/ml/data/warehouse/ads/measured_forecast.json" "$ADS/measured_forecast.json"
fi

if [[ ! -x "$QUERY_VENV/bin/python" ]]; then
  QUERY_VENV="$VENV"
fi

log "重启查询服务 :5010 （MEASURED）"
if [[ -f "$LOG_DIR/ml.pid" ]]; then
  kill "$(tr -d ' \n' < "$LOG_DIR/ml.pid")" 2>/dev/null || true
  rm -f "$LOG_DIR/ml.pid"
fi
fuser -k 5010/tcp >/dev/null 2>&1 || true
sleep 1
RESULTS="$ROOT/ml/data/warehouse/ads"
if [[ ! -f "$RESULTS/measured_forecast.json" ]]; then
  RESULTS="$ROOT/ml/fixtures"
fi
(
  cd "$ROOT"
  nohup "$QUERY_VENV/bin/python" -m ml.cli.warehouse_api \
    --store file --results-dir "$RESULTS" --source-kind MEASURED --port 5010 \
    >>"$LOG_DIR/ml.log" 2>&1 &
  echo $! > "$LOG_DIR/ml.pid"
)
for i in $(seq 1 20); do
  if curl -sf http://127.0.0.1:5010/api/forecast/station/1 >/dev/null; then
    log "已就绪 http://127.0.0.1:5010/api/forecast/station/1"
    curl -s http://127.0.0.1:5010/api/forecast/station/1 | "$VENV/bin/python" -c \
      'import json,sys; d=json.load(sys.stdin)["data"]; print("simulation=", d.get("simulation"), "source=", d.get("source_kind"), "stations=", len(d.get("stations") or []))'
    exit 0
  fi
  sleep 1
done
log "查询服务未在 20s 内就绪，见 $LOG_DIR/ml.log"
exit 1
