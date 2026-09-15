"""Small estimator adapter that validates model feature contracts."""

from __future__ import annotations

from typing import Any

import numpy as np
import pandas as pd

from ml.errors import ErrorCode, MLSubsystemError


def predict_ratio(estimator: Any, metadata: dict[str, Any], features: pd.DataFrame) -> float:
    """Single-station inference for either frozen architecture, clipped to [0, 1]."""
    if isinstance(estimator, dict):
        values = predict_h1_values(estimator, metadata, features, target=metadata["target"])
        return float(np.clip(values[0], 0.0, 1.0))
    expected = _validate_feature_contract(metadata, features)
    try:
        matrix = features.loc[:, expected]
        # The frozen RFs were fitted on arrays; names/order were validated above.
        model_input = matrix if hasattr(estimator, "feature_names_in_") else matrix.to_numpy()
        value = float(estimator.predict(model_input)[0])
    except Exception as exc:
        raise MLSubsystemError(ErrorCode.PREDICTION_FAILED, "Estimator prediction failed.") from exc
    if not np.isfinite(value):
        raise MLSubsystemError(ErrorCode.PREDICTION_FAILED, "Estimator returned NaN or infinity.")
    return min(max(value, 0.0), 1.0)


def predict_h1_values(
    artifact: Any, metadata: dict[str, Any], features: pd.DataFrame, *, target: str
) -> np.ndarray:
    """Run the frozen H1 classifier + residual regressor + optional deadband."""
    if target not in {"load", "occupancy"}:
        raise MLSubsystemError(ErrorCode.PREDICTION_FAILED, f"Unsupported H1 target: {target}")
    expected = _validate_feature_contract(metadata, features)
    if not isinstance(artifact, dict) or not {"classifier", "regressor"}.issubset(artifact):
        raise MLSubsystemError(ErrorCode.PREDICTION_FAILED, "H1 artifact is not a two-stage model.")
    artifact_features = artifact.get("feature_names")
    if artifact_features is not None and list(artifact_features) != expected:
        raise MLSubsystemError(ErrorCode.MODEL_NOT_FOUND, "H1 artifact and metadata feature contracts differ.")
    current_column = f"current_{target}_ratio"
    if current_column not in features:
        raise MLSubsystemError(ErrorCode.FEATURE_BUILD_FAILED, f"H1 input is missing {current_column}.")
    try:
        matrix = features.loc[:, expected]
        probability = np.asarray(artifact["classifier"].predict_proba(matrix))[:, 1]
        predicted_delta = np.asarray(artifact["regressor"].predict(matrix))
    except Exception as exc:
        raise MLSubsystemError(ErrorCode.PREDICTION_FAILED, "Two-stage H1 estimator prediction failed.") from exc
    current = features[current_column].to_numpy(dtype="float64")
    values = (probability, predicted_delta, current)
    if not np.isfinite(values).all():
        raise MLSubsystemError(ErrorCode.PREDICTION_FAILED, "Two-stage H1 estimator returned NaN or infinity.")
    threshold = float(metadata.get("classification_threshold", artifact.get("classification_threshold", 0.4)))
    tau = float(metadata.get("deadband_tau", metadata.get("deadband", 0.0)))
    alpha = float(metadata.get("alpha", 1.0))
    if not (
        np.isfinite([threshold, tau, alpha]).all()
        and 0.0 <= threshold <= 1.0
        and tau >= 0.0
        and 0.0 < alpha <= 1.0
    ):
        raise MLSubsystemError(ErrorCode.MODEL_NOT_FOUND, "Frozen H1 inference parameters are invalid.")
    correction = np.where(probability >= threshold, predicted_delta, 0.0)
    correction = np.where(np.abs(correction) < tau, 0.0, correction)
    return current + alpha * correction


def _validate_feature_contract(metadata: dict[str, Any], features: pd.DataFrame) -> list[str]:
    expected = metadata.get("feature_names")
    if not isinstance(expected, list) or not expected:
        raise MLSubsystemError(ErrorCode.MODEL_NOT_FOUND, "Model metadata does not contain feature_names.")
    actual = list(features.columns)
    missing = sorted(set(expected).difference(actual))
    unexpected = sorted(set(actual).difference(expected))
    if missing or unexpected or actual != expected:
        details = []
        if missing:
            details.append(f"missing: {', '.join(missing)}")
        if unexpected:
            details.append(f"unexpected: {', '.join(unexpected)}")
        if not missing and not unexpected and actual != expected:
            details.append("column order differs")
        raise MLSubsystemError(
            ErrorCode.FEATURE_BUILD_FAILED,
            "Inference feature contract mismatch; " + "; ".join(details),
        )
    return expected
