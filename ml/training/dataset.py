"""One shared feature cache plus original Train/Validation/Test-A indices."""

import json
from pathlib import Path
import numpy as np

from ml.features.schema import FEATURE_COLUMNS, H1_FEATURE_COLUMNS

HOUR_NS = 3_600_000_000_000


class TrainingDataset:
    def __init__(self, root):
        self.root = Path(root)
        self.manifest = json.loads((self.root / "cache/cache_manifest.json").read_text())
        self.boundaries = json.loads((self.root / "split_manifest.json").read_text())["split_boundaries"]
        self.arrays = {
            name: np.load(self.root / "cache" / entry["file"], mmap_mode="r")
            for name, entry in self.manifest["arrays"].items()
        }
        if self.manifest["feature_columns"] != list(FEATURE_COLUMNS):
            raise ValueError("Training cache feature schema mismatch.")

    def indices(self, task, split):
        if task not in {f"{t}_h{h}" for t in ("load", "occupancy") for h in (1, 6, 24)}:
            raise ValueError("Unknown model task.")
        if split not in {"train", "validation", "test_a"}:
            raise ValueError("Only the three original splits are retained.")
        indices = np.load(self.root / "splits" / task / f"{split}.npy", mmap_mode="r")
        # Preserve the H1 final-fit protocol: targets may not cross split boundaries.
        if task.endswith("_h1") and split != "test_a":
            boundary = self.boundaries["validation_start" if split == "train" else "test_a_start"]
            end = np.datetime64(boundary, "ns").astype("int64")
            indices = indices[self.arrays["timestamp_ns"][indices] + HOUR_NS < end]
        return indices

    def matrix(self, task, indices):
        horizon = int(task.rsplit("h", 1)[1])
        target = task.split("_h")[0]
        common_columns = [name for name in FEATURE_COLUMNS if name not in {"target_hour", "target_weekday", "target_is_weekend"}]
        names = H1_FEATURE_COLUMNS if horizon == 1 else FEATURE_COLUMNS
        X = np.empty((len(indices), len(names)), dtype="float32")
        target_hours = self.arrays["timestamp_ns"][indices].astype("datetime64[ns]").astype("datetime64[h]") + np.timedelta64(horizon, "h")
        hour = target_hours.astype("int64") % 24
        weekday = (target_hours.astype("datetime64[D]").astype("int64") + 3) % 7
        temporal = {"target_hour": hour, "target_weekday": weekday, "target_is_weekend": weekday >= 5}
        for position, name in enumerate(FEATURE_COLUMNS):
            X[:, position] = temporal[name] if name in temporal else self.arrays["X_common"][indices, common_columns.index(name)]
        if horizon == 1:
            X[:, -2] = self.arrays["persistence_load"][indices]
            X[:, -1] = self.arrays["persistence_occupancy"][indices]
        y = self.arrays[f"y_{task}"][indices].astype("float32")
        current = self.arrays[f"persistence_{target}"][indices].astype("float32")
        if not np.isfinite(X).all() or not np.isfinite(y).all() or not np.isfinite(current).all():
            raise ValueError("Nonfinite training input.")
        return X, y, current
