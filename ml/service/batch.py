"""DWS -> unchanged features/frozen estimators -> one atomic ADS batch."""

import hashlib
import json
import tempfile
from datetime import datetime
from pathlib import Path
from zoneinfo import ZoneInfo

import pandas as pd

from ml.config import load_config
from ml.prediction.registry import ModelRegistry
from ml.service.prediction_service import PredictionService
from ml.warehouse.contract import TIMEZONE, local_time
from ml.warehouse.source import ParquetHourlySource


def run_forecast(
    snapshot, as_of, store, audit_root, *,
    allow_simulated=False, station_ids=None, config_path=None,
):
    source = ParquetHourlySource(str(snapshot))
    if source.manifest["source_kind"] == "SIMULATED" and not allow_simulated:
        raise ValueError("SIMULATED input requires explicit --allow-simulated.")
    cutoff = local_time(as_of).floor("h")
    config = load_config(config_path)
    frame, catalog = source.read(cutoff, station_ids, config["prediction"]["history_window_hours"])
    registry = ModelRegistry(config["artifacts"]["current_freeze_manifest"])
    model_manifest_bytes = registry.manifest_bytes
    model_manifest = registry.manifest
    input_hash = hashlib.sha256(
        pd.util.hash_pandas_object(frame, index=False).values.tobytes()
    ).hexdigest()
    config_hash = hashlib.sha256(json.dumps(config, sort_keys=True).encode()).hexdigest()
    identity = json.dumps([
        input_hash,
        source.manifest_sha256,
        hashlib.sha256(model_manifest_bytes).hexdigest(),
        config_hash,
        "warehouse-inference-v1",
        cutoff.isoformat(),
        list(station_ids) if station_ids is not None else None,
    ])
    run_id = "forecast-" + hashlib.sha256(identity.encode()).hexdigest()[:32]
    service = PredictionService(config, registry)
    audit_root = Path(audit_root)
    audit_root.mkdir(parents=True, exist_ok=True)
    # Keep the precise input and actual feature rows used, even on a failed attempt.
    audit_dir = Path(tempfile.mkdtemp(prefix=run_id + "-", dir=audit_root))
    frame.to_parquet(audit_dir / "input_hourly.parquet", index=False)
    (audit_dir / "source_manifest.json").write_text(
        json.dumps(source.manifest, ensure_ascii=False, indent=2), encoding="utf-8"
    )
    (audit_dir / "model_manifest.json").write_bytes(model_manifest_bytes)

    def save_features(horizon, features):
        features.to_parquet(audit_dir / f"features_h{horizon}.parquet", index=False)

    payload = service.predict_hourly(frame, catalog, cutoff, feature_sink=save_features)
    payload.update({
        "run_id": run_id,
        "request_id": run_id,
        "generated_at": (
            datetime.now(ZoneInfo(TIMEZONE)).replace(tzinfo=None).isoformat(timespec="seconds")
        ),
        "data_cutoff_time": cutoff.isoformat(),
        "timezone": TIMEZONE,
        "data_version": source.manifest["data_version"],
        "source_kind": source.manifest["source_kind"],
        "input_sha256": input_hash,
        "source_manifest_sha256": source.manifest_sha256,
        "config_sha256": config_hash,
        "integration_version": "warehouse-inference-v1",
        "model_freeze_id": model_manifest["freeze_id"],
        "quality_status": "PASS",
        "prediction_mode": "direct_h1_h6_h24",
        "occupancy_semantics": "charging_duration_ratio",
        "pile_count_semantics": "equivalent_hourly_counts_not_live_availability",
    })
    (audit_dir / "prediction.json").write_text(
        json.dumps(payload, ensure_ascii=False, indent=2, allow_nan=False), encoding="utf-8"
    )
    store.publish(payload)
    return payload, audit_dir
