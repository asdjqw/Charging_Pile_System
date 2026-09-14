"""Read-only frozen artifact loading and integrity checks."""

import hashlib
import json
from pathlib import Path

import joblib

from ml.errors import ErrorCode, MLSubsystemError

PROJECT_ROOT = Path(__file__).resolve().parents[2]


def sha256(path):
    digest = hashlib.sha256()
    with Path(path).open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


class ModelRegistry:
    def __init__(self, release_manifest):
        try:
            self.manifest_bytes = self._resolve(release_manifest).read_bytes()
            self.manifest = json.loads(self.manifest_bytes)
        except (OSError, json.JSONDecodeError) as error:
            raise MLSubsystemError(ErrorCode.MODEL_NOT_FOUND, "Invalid frozen manifest.") from error
        if not isinstance(self.manifest, dict) or self.manifest.get("status") != "FROZEN_NO_RETRAINING":
            raise MLSubsystemError(ErrorCode.MODEL_NOT_FOUND, "A frozen manifest is required.")

    @staticmethod
    def _resolve(value):
        path = Path(value).expanduser()
        return path if path.is_absolute() else PROJECT_ROOT / path

    def load(self, *, target, horizon):
        task = f"{target}_h{horizon}"
        entries = [entry for entry in self.manifest.get("models", []) if entry.get("task") == task]
        if len(entries) != 1:
            raise MLSubsystemError(ErrorCode.MODEL_NOT_FOUND, f"No unique frozen entry for {task}.")
        entry = entries[0]
        try:
            model_path = self._resolve(entry["model_path"])
            metadata = json.loads(self._resolve(entry["metadata_path"]).read_text(encoding="utf-8"))
            if sha256(model_path) != entry["sha256"] or metadata.get("artifact_sha256") not in {None, entry["sha256"]}:
                raise ValueError("Checksum mismatch")
            estimator = joblib.load(model_path)
        except (OSError, ValueError, KeyError, TypeError) as error:
            raise MLSubsystemError(ErrorCode.MODEL_NOT_FOUND, f"Cannot load frozen {task}: {error}") from error
        metadata.update({
            key: entry[key] for key in (
                "model_version", "architecture", "feature_contract",
                "classification_threshold", "deadband_tau", "alpha", "fallback"
            ) if key in entry
        })
        metadata.update(target=target, horizon=horizon, task=task, environment="production", frozen=True)
        return estimator, metadata
