"""Fixed-parameter training entry. Runs only when explicitly invoked; never promotes models."""

import argparse
import json
from pathlib import Path

import joblib
import numpy as np
import pandas as pd
from sklearn.base import clone

from ml.prediction.registry import ModelRegistry, sha256
from ml.prediction.predictor import predict_h1_values
from ml.training.dataset import TrainingDataset


def fit(estimator, X, y, current):
    if isinstance(estimator, dict):
        result = dict(estimator)
        result["classifier"] = clone(estimator["classifier"])
        result["regressor"] = clone(estimator["regressor"])
        delta = y - current
        result["classifier"].fit(X, (np.abs(delta) > 0.01).astype("int8"))
        result["regressor"].fit(X, delta)
    else:
        result = clone(estimator)
        result.fit(X, y)
    return result


def metrics(estimator, metadata, X, y):
    if isinstance(estimator, dict):
        frame = pd.DataFrame(X, columns=metadata["feature_names"])
        predicted = predict_h1_values(estimator, metadata, frame, target=metadata["target"])
    else:
        predicted = estimator.predict(X)
    if not np.isfinite(predicted).all():
        raise ValueError("Nonfinite prediction during evaluation.")
    clipped = np.clip(predicted, 0, 1)
    error = clipped - y
    return {"rows": len(y), "RMSE": float(np.sqrt(np.mean(error ** 2))), "MAE": float(np.mean(np.abs(error))),
            "clip_rate": float(np.mean(predicted != clipped))}


def train_task(dataset, registry, task, output):
    target, horizon = task.split("_h")
    prototype, metadata = registry.load(target=target, horizon=int(horizon))
    train_indices = dataset.indices(task, "train")
    validation_indices = dataset.indices(task, "validation")
    model = fit(prototype, *dataset.matrix(task, train_indices))
    validation = metrics(model, metadata, *dataset.matrix(task, validation_indices)[:2])
    # Current RFs used Train+Validation final refit; H1 used Train only.
    if int(horizon) != 1:
        model = fit(prototype, *dataset.matrix(task, np.concatenate([train_indices, validation_indices])))
    test_a = metrics(model, metadata, *dataset.matrix(task, dataset.indices(task, "test_a"))[:2])
    output.mkdir()
    joblib.dump(model, output / "model.joblib")
    metadata.update(model_version="fixed-parameter-refit", frozen=False, model_path=str(output / "model.joblib"),
                    artifact_sha256=sha256(output / "model.joblib"))
    (output / "metadata.json").write_text(json.dumps(metadata, indent=2))
    (output / "metrics.json").write_text(json.dumps({"validation": validation, "test_a": test_a}, indent=2))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dataset", default="ml/datasets")
    parser.add_argument("--manifest", default="ml/artifacts/models/CURRENT_MODEL_FREEZE_20260914.json")
    parser.add_argument("--output", required=True, help="New directory; cannot be inside frozen artifacts")
    args = parser.parse_args()
    output = Path(args.output).resolve()
    artifacts = Path(__file__).resolve().parents[1] / "artifacts"
    if output == artifacts or artifacts in output.parents:
        raise ValueError("Training output must not modify frozen artifacts.")
    output.mkdir(parents=True, exist_ok=False)
    dataset = TrainingDataset(args.dataset)
    registry = ModelRegistry(args.manifest)
    for target in ("load", "occupancy"):
        for horizon in (1, 6, 24):
            task = f"{target}_h{horizon}"
            train_task(dataset, registry, task, output / task)


if __name__ == "__main__":
    main()
