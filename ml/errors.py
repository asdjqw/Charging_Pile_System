"""Stable, caller-safe error types for the ML subsystem."""

from __future__ import annotations

from dataclasses import dataclass
from enum import StrEnum


class ErrorCode(StrEnum):
    CURRENT_HOUR_NOT_AVAILABLE = "CURRENT_HOUR_NOT_AVAILABLE"
    INSUFFICIENT_HISTORY = "INSUFFICIENT_HISTORY"
    MODEL_NOT_FOUND = "MODEL_NOT_FOUND"
    FEATURE_BUILD_FAILED = "FEATURE_BUILD_FAILED"
    PREDICTION_FAILED = "PREDICTION_FAILED"
    CONFIG_ERROR = "CONFIG_ERROR"


@dataclass(slots=True)
class MLSubsystemError(Exception):
    """An expected failure that can safely cross a CLI or integration boundary."""

    code: ErrorCode
    message: str

    def __str__(self) -> str:
        return f"{self.code}: {self.message}"
