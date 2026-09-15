"""Read a committed local/HDFS Parquet snapshot, with predicate pushdown."""

import hashlib
import json
from pathlib import Path

import pandas as pd
import pyarrow as pa
import pyarrow.dataset as ds
from pyarrow import fs

from .contract import local_time, require_history, validate_hourly, validate_manifest


class ParquetHourlySource:
    def __init__(self, snapshot: str):
        uri = str(snapshot) if "://" in str(snapshot) else str(Path(snapshot).expanduser().resolve())
        self.filesystem, self.root = fs.FileSystem.from_uri(uri)
        self.root = self.root.rstrip("/")
        with self.filesystem.open_input_file(self.root + "/manifest.json") as handle:
            raw = handle.read()
        self.manifest = json.loads(raw)
        validate_manifest(self.manifest)
        self.manifest_sha256 = hashlib.sha256(raw).hexdigest()

    def read(self, as_of, station_ids=None, history_hours=72):
        if history_hours < 25:
            raise ValueError("history_hours must be at least 25.")
        cutoff = local_time(as_of).floor("h")
        requested = self.manifest["station_ids"] if station_ids is None else list(station_ids)
        if not requested or len(set(requested)) != len(requested) or not set(requested).issubset(self.manifest["station_ids"]):
            raise ValueError("Requested station IDs must uniquely match the snapshot catalog.")
        dataset = ds.dataset(self.root + "/hourly.parquet", filesystem=self.filesystem, format="parquet")
        timestamp_type = dataset.schema.field("timestamp").type
        if not pa.types.is_timestamp(timestamp_type) or timestamp_type.tz is not None:
            raise ValueError("Parquet timestamp must be a timezone-naive Arrow timestamp in Asia/Shanghai.")
        expression = (ds.field("timestamp") >= cutoff - pd.Timedelta(hours=history_hours)) & (ds.field("timestamp") < cutoff)
        expression = expression & ds.field("station_id").isin(requested)
        frame = validate_hourly(dataset.to_table(filter=expression).to_pandas())
        return require_history(frame, cutoff, requested)
