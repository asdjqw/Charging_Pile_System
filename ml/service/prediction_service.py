"""One canonical feature build, followed by the six frozen estimators."""

import gc
from collections.abc import Callable

import pandas as pd

from ml.features.pipeline import FeaturePipeline
from ml.prediction.registry import ModelRegistry
from ml.prediction.postprocessor import PostProcessor
from ml.prediction.predictor import predict_ratio


class PredictionService:
    def __init__(self, config, registry: ModelRegistry):
        self._features = FeaturePipeline(config)
        self._registry = registry
        self._postprocessor = PostProcessor(config)

    def predict_hourly(
        self,
        hourly: pd.DataFrame,
        catalog: pd.DataFrame,
        cutoff: pd.Timestamp,
        *,
        feature_sink: Callable[[int, pd.DataFrame], None],
    ) -> dict:
        """Use and retain exactly the same features; upstream validates history."""
        current_hour = cutoff - pd.Timedelta(hours=1)
        matrices = self._features.build_forecast_features(hourly, current_hour)
        stations = {
            int(row["station_id"]): {
                "station_id": int(row["station_id"]),
                "station_name": row["station_name"],
                "status": "ok",
                "capacity": {
                    "total_piles": int(row["total_piles"]),
                    "station_capacity_kw": float(row["station_capacity_kw"]),
                },
                "forecast": {},
                # Stable response fields retained for existing consumers.
                "peak": {"time": None, "load_ratio": None},
                "hourly_forecast": [],
            }
            for row in catalog.to_dict(orient="records")
        }
        versions = {"load": {}, "occupancy": {}}
        for horizon, features in matrices.items():
            feature_sink(horizon, features.reset_index())
            target_start = cutoff + pd.Timedelta(hours=horizon - 1)
            target_end = target_start + pd.Timedelta(hours=1)
            models = {
                target: self._registry.load(target=target, horizon=horizon)
                for target in versions
            }
            for target in versions:
                versions[target][f"{horizon}h"] = models[target][1]["model_version"]
            for station_id, station in stations.items():
                row = features.loc[[station_id]]
                ratios = {}
                for target, (estimator, metadata) in models.items():
                    ratios[target] = predict_ratio(estimator, metadata, row)
                values = self._postprocessor.process(
                    load_ratio=ratios["load"],
                    occupancy_ratio=ratios["occupancy"],
                    station=station["capacity"],
                )
                station["forecast"][f"{horizon}h"] = {
                    "load_ratio": values["load_ratio"],
                    "load_kw": values["load_kw"],
                    "occupancy_ratio": values["occupancy_ratio"],
                    "target_start": target_start.isoformat(),
                    "target_end": target_end.isoformat(),
                    "equivalent_occupied_piles": values["equivalent_occupied_piles"],
                    "equivalent_idle_piles": values["equivalent_idle_piles"],
                }
                if horizon == 1:
                    station["business_status"] = {
                        key: values[key] for key in ("congestion_level", "warning_level")
                    }
            # Bound memory to the current horizon; no cross-batch model cache.
            del models, estimator
            gc.collect()
        return {
            "schema_version": "1.0",
            "success": True,
            "errors": [],
            "stations": list(stations.values()),
            "models": versions,
        }
