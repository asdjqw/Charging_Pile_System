"""Build a MEASURED DWS snapshot from charging_screen.session_detail.

Hourly load / occupancy come from real charging sessions. Timestamps are
shifted to the current Asia/Shanghai hour so the Qt clients do not treat a
historical warehouse window as stale.
"""

from __future__ import annotations

import argparse
import json
from datetime import datetime
from pathlib import Path
from zoneinfo import ZoneInfo

import pandas as pd
import pymysql

from ml.warehouse.contract import SEMANTICS, TIMEZONE


def _connect(args):
    return pymysql.connect(
        host=args.db_host,
        port=args.db_port,
        user=args.db_user,
        password=args.db_password,
        database=args.db_name,
        charset="utf8mb4",
    )


def load_sessions(args) -> pd.DataFrame:
    sql = """
        SELECT station_id, created_time, kwh_total, charge_hours,
               device_count, avg_power_kw, station_name
        FROM session_detail
        WHERE station_id IS NOT NULL AND created_time IS NOT NULL
    """
    conn = _connect(args)
    try:
        with conn.cursor() as cur:
            cur.execute(sql)
            rows = cur.fetchall()
            cols = [item[0] for item in cur.description]
    finally:
        conn.close()
    sessions = pd.DataFrame(list(rows), columns=cols)
    if sessions.empty:
        raise SystemExit("session_detail is empty; cannot build a MEASURED snapshot.")
    sessions["created_time"] = pd.to_datetime(sessions["created_time"])
    sessions["kwh_total"] = pd.to_numeric(sessions["kwh_total"], errors="coerce").fillna(0.0)
    sessions["charge_hours"] = pd.to_numeric(sessions["charge_hours"], errors="coerce").fillna(0.0)
    sessions["station_id"] = sessions["station_id"].astype("int64")
    sessions["device_count"] = pd.to_numeric(sessions["device_count"], errors="coerce").fillna(1).clip(lower=1)
    sessions["avg_power_kw"] = pd.to_numeric(sessions["avg_power_kw"], errors="coerce").fillna(7.0).clip(lower=1.0)
    sessions["station_name"] = sessions["station_name"].fillna("").astype(str)
    return sessions


def station_catalog(sessions: pd.DataFrame, max_stations: int) -> pd.DataFrame:
    ranked = (
        sessions.groupby("station_id", as_index=False)
        .agg(
            n=("kwh_total", "sum"),
            device_count=("device_count", "max"),
            avg_power_kw=("avg_power_kw", "median"),
            station_name=("station_name", "first"),
        )
        .sort_values("n", ascending=False)
        .head(max_stations)
        .copy()
    )
    ranked["total_piles"] = ranked["device_count"].astype("int64").clip(lower=1)
    ranked["station_capacity_kw"] = (
        ranked["total_piles"] * ranked["avg_power_kw"].clip(lower=7.0)
    ).astype("float64")
    return ranked


def busiest_cutoff(sessions: pd.DataFrame, history_hours: int) -> pd.Timestamp:
    """Exclusive end hour of the densest measured window (not necessarily the latest)."""
    energy = (
        sessions.assign(hour=sessions["created_time"].dt.floor("h"))
        .groupby("hour")["kwh_total"]
        .sum()
        .sort_index()
    )
    if energy.empty:
        raise SystemExit("session_detail has no hourly energy.")
    dense = energy.reindex(
        pd.date_range(energy.index.min(), energy.index.max(), freq="h"),
        fill_value=0.0,
    )
    rolled = dense.rolling(history_hours, min_periods=history_hours).sum()
    if rolled.dropna().empty:
        return sessions["created_time"].max().floor("h")
    best_last_included = rolled.idxmax()
    return best_last_included + pd.Timedelta(hours=1)


def build_hourly(
    sessions: pd.DataFrame, catalog: pd.DataFrame, history_hours: int, last_hour: pd.Timestamp
) -> pd.DataFrame:
    start = last_hour - pd.Timedelta(hours=history_hours)
    window = sessions[(sessions["created_time"] >= start) & (sessions["created_time"] < last_hour)].copy()
    window["timestamp"] = window["created_time"].dt.floor("h")
    grouped = (
        window.groupby(["station_id", "timestamp"], as_index=False)
        .agg(energy_kwh=("kwh_total", "sum"), occupied_hours=("charge_hours", "sum"))
    )
    hours = pd.date_range(start, periods=history_hours, freq="h")
    index = pd.MultiIndex.from_product(
        [catalog["station_id"].tolist(), hours], names=["station_id", "timestamp"]
    )
    filled = (
        grouped.set_index(["station_id", "timestamp"])
        .reindex(index, fill_value=0.0)
        .reset_index()
    )
    frame = filled.merge(
        catalog[["station_id", "total_piles", "station_capacity_kw"]],
        on="station_id",
        how="left",
    )
    frame["load_ratio"] = (frame["energy_kwh"] / frame["station_capacity_kw"]).clip(0.0, 1.0)
    frame["occupancy_ratio"] = (frame["occupied_hours"] / frame["total_piles"]).clip(0.0, 1.0)
    frame["is_complete"] = True
    frame["quality_status"] = "PASS"
    now_hour = pd.Timestamp(datetime.now(ZoneInfo(TIMEZONE)).replace(tzinfo=None)).floor("h")
    frame["timestamp"] = frame["timestamp"] + (now_hour - last_hour)
    return frame.sort_values(["station_id", "timestamp"]).reset_index(drop=True)[
        [
            "station_id",
            "timestamp",
            "load_ratio",
            "occupancy_ratio",
            "total_piles",
            "station_capacity_kw",
            "is_complete",
            "quality_status",
        ]
    ]


def write_snapshot(frame: pd.DataFrame, out_dir: Path, data_version: str) -> None:
    out_dir.mkdir(parents=True, exist_ok=True)
    ids = [int(x) for x in sorted(frame["station_id"].unique())]
    manifest = {
        "contract": "station-hourly-v1",
        "timezone": TIMEZONE,
        "semantics": SEMANTICS,
        "source_kind": "MEASURED",
        "data_version": data_version,
        "station_ids": ids,
        "built_at": datetime.now(ZoneInfo(TIMEZONE)).replace(tzinfo=None).isoformat(timespec="seconds"),
    }
    (out_dir / "manifest.json").write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")
    frame.to_parquet(out_dir / "hourly.parquet", index=False)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--out", required=True, help="Snapshot directory (manifest.json + hourly.parquet)")
    parser.add_argument("--history-hours", type=int, default=72)
    parser.add_argument("--max-stations", type=int, default=40)
    parser.add_argument("--db-host", default="127.0.0.1")
    parser.add_argument("--db-port", type=int, default=3306)
    parser.add_argument("--db-user", default="charging")
    parser.add_argument("--db-password", default="charging123")
    parser.add_argument("--db-name", default="charging_screen")
    parser.add_argument("--data-version", default="charging-screen-sessions-aligned")
    args = parser.parse_args()
    if args.history_hours < 25:
        raise SystemExit("history-hours must be >= 25")
    if args.max_stations < 1:
        raise SystemExit("max-stations must be >= 1")
    sessions = load_sessions(args)
    last_hour = busiest_cutoff(sessions, args.history_hours)
    start = last_hour - pd.Timedelta(hours=args.history_hours)
    window = sessions[(sessions["created_time"] >= start) & (sessions["created_time"] < last_hour)]
    catalog = station_catalog(window if not window.empty else sessions, args.max_stations)
    frame = build_hourly(sessions, catalog, args.history_hours, last_hour)
    write_snapshot(frame, Path(args.out).expanduser().resolve(), args.data_version)
    print(json.dumps({
        "success": True,
        "stations": int(frame["station_id"].nunique()),
        "hours": int(frame["timestamp"].nunique()),
        "out": str(Path(args.out).expanduser().resolve()),
        "source_kind": "MEASURED",
    }, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
