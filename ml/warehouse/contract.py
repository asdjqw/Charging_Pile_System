"""Warehouse boundary: China local hours, measured ratios, no imputation."""

from __future__ import annotations

import numpy as np
import pandas as pd

from ml.features.schema import CANONICAL_HOURLY_COLUMNS

TIMEZONE = "Asia/Shanghai"
CONTRACT = "station-hourly-v1"
QUALITY_COLUMNS = ("is_complete", "quality_status")
SEMANTICS = {
    "load_ratio": "energy_kwh/(station_capacity_kw*1h)",
    "occupancy_ratio": "charging_duration_hours/(total_piles*1h)",
    "timestamp": "interval_start",
    "denominator": "fixed_total_installed",
}


def local_time(value) -> pd.Timestamp:
    timestamp = pd.Timestamp(value)
    if pd.isna(timestamp):
        raise ValueError("Time must not be missing.")
    if timestamp.tzinfo is not None:
        timestamp = timestamp.tz_convert(TIMEZONE).tz_localize(None)
    return timestamp


def validate_manifest(manifest: dict) -> None:
    if manifest.get("contract") != CONTRACT or manifest.get("timezone") != TIMEZONE:
        raise ValueError("DWS contract/timezone mismatch.")
    if manifest.get("semantics") != SEMANTICS:
        raise ValueError("DWS measurement semantics differ from the frozen models.")
    if manifest.get("source_kind") not in {"MEASURED", "SIMULATED"}:
        raise ValueError("source_kind must explicitly be MEASURED or SIMULATED.")
    if not isinstance(manifest.get("data_version"), str) or not manifest["data_version"].strip():
        raise ValueError("DWS data_version is required.")
    ids = manifest.get("station_ids")
    if not isinstance(ids, list) or not ids or any(type(sid) is not int or sid <= 0 for sid in ids) or len(set(ids)) != len(ids):
        raise ValueError("Manifest station_ids must list all unique positive station IDs in this snapshot.")


def validate_hourly(frame: pd.DataFrame) -> pd.DataFrame:
    required = {*CANONICAL_HOURLY_COLUMNS, *QUALITY_COLUMNS}
    if missing := required.difference(frame.columns):
        raise ValueError(f"DWS missing columns: {sorted(missing)}")
    if frame.empty:
        raise ValueError("DWS contains no hours in the requested history window.")
    result = frame.copy()
    result["timestamp"] = pd.to_datetime(result["timestamp"], errors="raise")
    if result["timestamp"].dt.tz is not None:
        result["timestamp"] = result["timestamp"].dt.tz_convert(TIMEZONE).dt.tz_localize(None)
    if result["timestamp"].isna().any() or (result["timestamp"] != result["timestamp"].dt.floor("h")).any():
        raise ValueError("DWS timestamp must be a nonmissing hour boundary.")
    for column in ("station_id", "total_piles", "station_capacity_kw"):
        result[column] = pd.to_numeric(result[column], errors="raise")
        if not np.isfinite(result[column]).all() or (result[column] <= 0).any():
            raise ValueError(f"{column} must be finite and positive.")
    for column in ("station_id", "total_piles"):
        if (result[column] % 1 != 0).any():
            raise ValueError(f"{column} must contain integers.")
        result[column] = result[column].astype("int64")
    if result.duplicated(["station_id", "timestamp"]).any():
        raise ValueError("Duplicate DWS station-hour keys; do not silently keep one.")
    for column in ("total_piles", "station_capacity_kw"):
        if (result.groupby("station_id")[column].nunique() != 1).any():
            raise ValueError(f"{column} changed within the input history; capacity adaptation is required.")
    if not result["is_complete"].isin([True, False, 0, 1]).all():
        raise ValueError("is_complete must be boolean or 0/1.")
    if result["quality_status"].isna().any():
        raise ValueError("quality_status must be explicit.")
    accepted = result["is_complete"].eq(1) & result["quality_status"].eq("PASS")
    for column, upper in (("load_ratio", 1.05), ("occupancy_ratio", 1.000001)):
        values = pd.to_numeric(result[column], errors="coerce")
        valid = np.isfinite(values) & values.between(-1e-9, upper)
        if (accepted & ~valid).any():
            raise ValueError(f"PASS row contains missing/nonfinite/out-of-range {column}.")
        # Keep invalid hours on the grid as NaN: deletion would hide missing history.
        result[column] = values.where(accepted).clip(0.0, 1.0)
    return result.sort_values(["station_id", "timestamp"]).reset_index(drop=True)


def require_history(frame: pd.DataFrame, cutoff, station_ids=None) -> tuple[pd.DataFrame, pd.DataFrame]:
    """24 lags plus the observed current hour require 25 consecutive valid rows."""
    cutoff = local_time(cutoff).floor("h")
    expected = pd.date_range(cutoff - pd.Timedelta(hours=25), periods=25, freq="h")
    selected = frame if station_ids is None else frame[frame.station_id.isin(station_ids)]
    ids = set(selected.station_id)
    if not ids or (station_ids is not None and ids != set(station_ids)):
        raise ValueError("Requested station is absent from the DWS snapshot.")
    for station_id, group in selected.groupby("station_id"):
        window = group.set_index("timestamp").reindex(expected)
        if window[["load_ratio", "occupancy_ratio"]].isna().any(axis=None):
            raise ValueError(f"Station {station_id}: need 25 consecutive valid hours ending at {cutoff - pd.Timedelta(hours=1)}.")
    catalog = selected.groupby("station_id", as_index=False).tail(1)[
        ["station_id", "total_piles", "station_capacity_kw"]
    ].copy()
    catalog["station_name"] = catalog.station_id.map(lambda sid: f"站点{sid}")
    return selected, catalog
