"""Frozen 18/20-column inference features, calculated once per hourly batch."""

import numpy as np
import pandas as pd

from .schema import CANONICAL_HOURLY_COLUMNS, FEATURE_COLUMNS
from ml.errors import ErrorCode, MLSubsystemError


class FeaturePipeline:
    def __init__(self, config):
        frozen = {"load_lags": [1, 6, 24], "occupancy_lags": [1, 6, 24], "rolling_windows": [6, 24]}
        if any(value != frozen.get(key) for key, value in config.get("features", {}).items()):
            raise MLSubsystemError(ErrorCode.FEATURE_BUILD_FAILED, "Frozen feature settings cannot be changed.")

    def transform(self, hourly_data, horizons=(1, 6, 24)):
        missing = set(CANONICAL_HOURLY_COLUMNS).difference(hourly_data.columns)
        if missing or hourly_data.empty:
            raise MLSubsystemError(ErrorCode.FEATURE_BUILD_FAILED, f"Missing hourly input: {sorted(missing)}")
        source = hourly_data.copy()
        source["timestamp"] = pd.to_datetime(source["timestamp"])
        if source.duplicated(["station_id", "timestamp"]).any():
            raise MLSubsystemError(ErrorCode.FEATURE_BUILD_FAILED, "Duplicate station-hour rows.")
        pieces = []
        for station_id, group in source.groupby("station_id", sort=True):
            ordered = group.sort_values("timestamp").set_index("timestamp")
            grid = pd.date_range(ordered.index.min(), ordered.index.max(), freq="h")
            regular = ordered.reindex(grid)
            regular.index.name = "timestamp"
            regular["station_id"] = int(station_id)
            for column in ("total_piles", "station_capacity_kw"):
                values = ordered[column].dropna().unique()
                if len(values) != 1:
                    raise MLSubsystemError(ErrorCode.FEATURE_BUILD_FAILED, f"Nonconstant {column}.")
                regular[column] = values[0]
            pieces.append(regular.reset_index())
        result = pd.concat(pieces, ignore_index=True).sort_values(["station_id", "timestamp"]).reset_index(drop=True)
        result["hour"] = result.timestamp.dt.hour
        result["weekday"] = result.timestamp.dt.weekday
        result["is_weekend"] = (result.weekday >= 5).astype(int)
        for target in ("load", "occupancy"):
            grouped = result.groupby("station_id", sort=False)[f"{target}_ratio"]
            for lag in (1, 6, 24):
                result[f"{target}_lag_{lag}"] = grouped.shift(lag)
            for window in (6, 24):
                result[f"{target}_rolling_mean_{window}"] = grouped.transform(
                    lambda series: series.shift(1).rolling(window, min_periods=window).mean()
                )
        for horizon in horizons:
            if horizon not in (1, 6, 24):
                raise MLSubsystemError(ErrorCode.FEATURE_BUILD_FAILED, f"Unsupported horizon: {horizon}")
            target_time = result.timestamp + pd.Timedelta(hours=horizon)
            result[f"target_hour_{horizon}"] = target_time.dt.hour
            result[f"target_weekday_{horizon}"] = target_time.dt.weekday
            result[f"target_is_weekend_{horizon}"] = (target_time.dt.weekday >= 5).astype(int)
        return result

    @staticmethod
    def _select(rows, horizon):
        temporal = {"target_hour", "target_weekday", "target_is_weekend"}
        columns = [f"{name}_{horizon}" if name in temporal else name for name in FEATURE_COLUMNS]
        features = rows.loc[:, columns].copy()
        features.columns = FEATURE_COLUMNS
        if horizon == 1:
            features["current_load_ratio"] = rows["load_ratio"]
            features["current_occupancy_ratio"] = rows["occupancy_ratio"]
        features = features.astype("float32")
        if features.empty or not np.isfinite(features.to_numpy()).all():
            raise MLSubsystemError(ErrorCode.INSUFFICIENT_HISTORY, "Incomplete inference features.")
        features.index = pd.Index(rows.station_id.to_numpy(dtype="int64"), name="station_id")
        return features

    def build_forecast_features(self, hourly_data, current_hour):
        current_hour = pd.Timestamp(current_hour).floor("h")
        history = hourly_data.loc[hourly_data.timestamp <= current_hour]
        transformed = self.transform(history)
        rows = transformed.loc[transformed.timestamp == current_hour]
        if set(rows.station_id) != set(hourly_data.station_id):
            raise MLSubsystemError(ErrorCode.CURRENT_HOUR_NOT_AVAILABLE, "A station is missing the current hour.")
        return {horizon: self._select(rows, horizon) for horizon in (1, 6, 24)}
