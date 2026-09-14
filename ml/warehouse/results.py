"""Atomic ADS snapshots: local JSON for integration, MySQL for deployment."""

from __future__ import annotations

import json
import os
from pathlib import Path
import re
import tempfile


def forecast_rows(payload):
    rows = []
    for station in payload["stations"]:
        for key, values in station["forecast"].items():
            for target in ("load", "occupancy"):
                rows.append((payload["run_id"], station["station_id"], target, int(key[:-1]),
                             values["target_start"], values["target_end"], values[target + "_ratio"],
                             payload["models"][target][key]))
    return rows


class FileForecastStore:
    def __init__(self, root):
        self.root = Path(root)

    def publish(self, payload):
        run_id = payload["run_id"]
        if not re.fullmatch(r"[a-zA-Z0-9_-]{1,100}", run_id) or not payload.get("success"):
            raise ValueError("Only successful, valid run IDs may be published.")
        self.root.mkdir(parents=True, exist_ok=True)
        destination = self.root / f"{run_id}.json"
        fd, temporary = tempfile.mkstemp(prefix=".pending-", dir=self.root)
        try:
            with os.fdopen(fd, "w", encoding="utf-8") as handle:
                json.dump(payload, handle, ensure_ascii=False, allow_nan=False)
                handle.flush()
                os.fsync(handle.fileno())
            try:
                os.link(temporary, destination)  # publish without replacing an existing run
            except FileExistsError:
                existing = json.loads(destination.read_text(encoding="utf-8"))
                if existing["input_sha256"] != payload["input_sha256"]:
                    raise ValueError("Conflicting run_id.")
        finally:
            os.unlink(temporary)

    def latest(self, source_kind="MEASURED"):
        # Scan lazily: keep the best batch, not every historical payload in memory.
        candidates = (json.loads(path.read_text(encoding="utf-8")) for path in self.root.glob("*.json"))
        candidates = (p for p in candidates if p.get("source_kind") == source_kind and p.get("success"))
        return max(candidates, key=lambda p: (p["data_cutoff_time"], p["generated_at"]), default=None)


class MySQLForecastStore:
    """Caller supplies a fresh DB-API connection; credentials stay outside code."""

    def __init__(self, connection_factory):
        self.connection_factory = connection_factory

    def publish(self, payload):
        if not payload.get("success"):
            raise ValueError("Failed batches cannot replace ADS results.")
        connection = self.connection_factory()
        try:
            connection.begin()
            with connection.cursor() as cursor:
                cursor.execute(
                    "INSERT INTO ml_forecast_runs (run_id, input_sha256, source_kind, data_cutoff_time, generated_at, payload) "
                    "VALUES (%s,%s,%s,%s,%s,%s)",
                    (payload["run_id"], payload["input_sha256"], payload["source_kind"], payload["data_cutoff_time"],
                     payload["generated_at"], json.dumps(payload, ensure_ascii=False, allow_nan=False)),
                )
                cursor.executemany(
                    "INSERT INTO ads_station_forecast "
                    "(run_id,station_id,target_name,horizon_hours,target_start,target_end,prediction_value,model_version) "
                    "VALUES (%s,%s,%s,%s,%s,%s,%s,%s)", forecast_rows(payload)
                )
            connection.commit()
        except Exception as error:
            connection.rollback()
            # A repeated input/model/cutoff batch has the same deterministic ID.
            if getattr(error, "args", (None,))[0] == 1062:
                with connection.cursor() as cursor:
                    cursor.execute("SELECT input_sha256 FROM ml_forecast_runs WHERE run_id=%s", (payload["run_id"],))
                    row = cursor.fetchone()
                checksum = row.get("input_sha256") if isinstance(row, dict) else row[0] if row else None
                if checksum != payload["input_sha256"]:
                    raise
            else:
                raise
        finally:
            connection.close()

    def latest(self, source_kind="MEASURED"):
        connection = self.connection_factory()
        try:
            with connection.cursor() as cursor:
                cursor.execute("SELECT payload FROM ml_forecast_runs WHERE source_kind=%s "
                               "ORDER BY data_cutoff_time DESC, generated_at DESC LIMIT 1", (source_kind,))
                row = cursor.fetchone()
            if row is None:
                return None
            return json.loads(row["payload"] if isinstance(row, dict) else row[0])
        finally:
            connection.close()


def mysql_from_environment():
    import pymysql
    def connect():
        return pymysql.connect(
            host=os.environ.get("DB_HOST", "127.0.0.1"), port=int(os.environ.get("DB_PORT", "3306")),
            user=os.environ["DB_USER"], password=os.environ["DB_PASSWORD"],
            database=os.environ.get("DB_NAME", "charging_screen"), charset="utf8mb4",
            connect_timeout=5, read_timeout=30, write_timeout=30,
        )
    return MySQLForecastStore(connect)
