"""Deterministic business values derived from model ratio outputs."""

from __future__ import annotations

from typing import Any, Mapping

from ml.errors import ErrorCode, MLSubsystemError


class PostProcessor:
    def __init__(self, config: Mapping[str, Any]):
        congestion = config.get("congestion", {})
        warning = config.get("warning", {})
        try:
            self._medium = float(congestion.get("medium_threshold", 0.50))
            self._high = float(congestion.get("high_threshold", 0.80))
            self._warning = float(warning.get("warning_threshold", 0.80))
            self._critical = float(warning.get("critical_threshold", 0.90))
        except (AttributeError, TypeError, ValueError) as error:
            raise MLSubsystemError(ErrorCode.CONFIG_ERROR, "Business thresholds must be numeric.") from error
        if not (0 <= self._medium <= self._high <= 1 and 0 <= self._warning <= self._critical <= 1):
            raise MLSubsystemError(ErrorCode.CONFIG_ERROR, "Business thresholds must be ordered within [0, 1].")

    def process(
        self, *, load_ratio: float, occupancy_ratio: float, station: Mapping[str, Any]
    ) -> dict[str, Any]:
        total_piles = int(station["total_piles"])
        capacity_kw = float(station["station_capacity_kw"])
        safe_load = min(max(float(load_ratio), 0.0), 1.0)
        safe_occupancy = min(max(float(occupancy_ratio), 0.0), 1.0)
        occupied = min(max(round(safe_occupancy * total_piles), 0), total_piles)
        return {
            "load_ratio": round(safe_load, 6),
            "load_kw": round(safe_load * capacity_kw, 3),
            "occupancy_ratio": round(safe_occupancy, 6),
            "equivalent_occupied_piles": occupied,
            "equivalent_idle_piles": total_piles - occupied,
            "congestion_level": self._congestion_level(safe_occupancy),
            "warning_level": self._warning_level(safe_load),
        }

    def _congestion_level(self, ratio: float) -> str:
        if ratio < self._medium:
            return "low"
        if ratio < self._high:
            return "medium"
        return "high"

    def _warning_level(self, ratio: float) -> str:
        if ratio < self._warning:
            return "normal"
        if ratio < self._critical:
            return "warning"
        return "critical"
