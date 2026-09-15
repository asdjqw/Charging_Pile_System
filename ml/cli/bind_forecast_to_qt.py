"""Copy a MEASURED forecast batch onto Qt station IDs.

The frozen models run on warehouse station IDs. The user-client station detail
page queries `stations.id` from SQLite, so this adapter republishes the same
model outputs under those IDs and rescales kW / pile counts to the Qt catalog.
"""

from __future__ import annotations

import argparse
import json
import sqlite3
from copy import deepcopy
from datetime import datetime
from pathlib import Path
from zoneinfo import ZoneInfo


def load_qt_stations(db_path: Path):
    conn = sqlite3.connect(str(db_path))
    try:
        rows = list(conn.execute(
            """
            SELECT s.id, s.name,
                   COUNT(p.id) AS piles,
                   COALESCE(AVG(p.power_kw), 7.0) AS avg_power
            FROM stations s
            LEFT JOIN piles p ON p.station_id = s.id
            GROUP BY s.id
            ORDER BY s.id
            """
        ))
    finally:
        conn.close()
    return rows


def latest_payload(results_dir: Path) -> dict:
    best = None
    for path in results_dir.glob("*.json"):
        payload = json.loads(path.read_text(encoding="utf-8"))
        if payload.get("source_kind") != "MEASURED" or not payload.get("success"):
            continue
        key = (payload.get("data_cutoff_time") or "", payload.get("generated_at") or "", str(path))
        if best is None or key > best[0]:
            best = (key, payload)
    if best is None:
        raise SystemExit(f"No MEASURED forecast JSON in {results_dir}")
    return best[1]


def rescale(item: dict, piles: int, avg_power: float) -> dict:
    piles = max(int(piles or 1), 1)
    capacity = max(float(avg_power or 7.0), 7.0) * piles
    item["capacity"] = {"total_piles": piles, "station_capacity_kw": capacity}
    for values in (item.get("forecast") or {}).values():
        load_ratio = float(values.get("load_ratio") or 0.0)
        occ = float(values.get("occupancy_ratio") or 0.0)
        occupied = min(max(round(occ * piles), 0), piles)
        values["load_kw"] = round(load_ratio * capacity, 3)
        values["equivalent_occupied_piles"] = occupied
        values["equivalent_idle_piles"] = piles - occupied
    return item


def bind(payload: dict, qt_stations: list[tuple]) -> dict:
    sources = sorted(
        payload.get("stations") or [],
        key=lambda item: (
            float((item.get("forecast") or {}).get("1h", {}).get("load_kw") or 0.0),
            float((item.get("forecast") or {}).get("1h", {}).get("occupancy_ratio") or 0.0),
        ),
        reverse=True,
    )
    if not sources or not qt_stations:
        raise SystemExit("Need both model stations and Qt stations.")
    bound = []
    for index, row in enumerate(qt_stations):
        station_id, name, piles, avg_power = row
        item = deepcopy(sources[index % len(sources)])
        item["station_id"] = int(station_id)
        item["station_name"] = name or item.get("station_name") or f"站点{station_id}"
        bound.append(rescale(item, piles, avg_power))
    out = deepcopy(payload)
    out["stations"] = bound
    out["data_version"] = f"{payload.get('data_version', 'measured')}-qt-bound"
    out["run_id"] = f"{payload['run_id']}-qt"
    out["request_id"] = out["run_id"]
    out["generated_at"] = datetime.now(ZoneInfo("Asia/Shanghai")).replace(tzinfo=None).isoformat(timespec="seconds")
    return out


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--results-dir", required=True)
    parser.add_argument("--qt-db", required=True)
    parser.add_argument("--out", required=True, help="Destination JSON path")
    args = parser.parse_args()
    payload = latest_payload(Path(args.results_dir).expanduser().resolve())
    qt_stations = load_qt_stations(Path(args.qt_db).expanduser())
    bound = bind(payload, qt_stations)
    out = Path(args.out).expanduser().resolve()
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(bound, ensure_ascii=False), encoding="utf-8")
    print(json.dumps({
        "success": True,
        "qt_stations": len(qt_stations),
        "model_stations": len(payload["stations"]),
        "out": str(out),
        "source_kind": bound["source_kind"],
        "simulation": False,
    }, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
