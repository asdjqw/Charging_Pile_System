#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""把一期 SQLite 只读导出为大屏 Spark 所需的三张 CSV（不写回原库）。"""

from __future__ import annotations

import argparse
import csv
import os
import sqlite3
from datetime import datetime
from pathlib import Path

WEEKDAYS = ["Mon", "Tues", "Wed", "Thurs", "Fri", "Sat", "Sun"]


def find_db(explicit: str | None) -> Path:
    candidates = []
    if explicit:
        candidates.append(Path(explicit))
    env = os.environ.get("CHARGE_PILE_DB_PATH")
    if env:
        candidates.append(Path(env))
    home = Path.home()
    candidates.extend(
        [
            home / ".local/share/ChargePileLab/charge_pile.db",
            home / "Charge_pile_bin/charge_pile.db",
        ]
    )
    for path in candidates:
        if path.is_file():
            return path
    raise SystemExit(
        "找不到 charge_pile.db。请设置 CHARGE_PILE_DB_PATH 或传入 --db。"
    )


def parse_dt(value: str | None) -> datetime | None:
    if not value:
        return None
    text = str(value).strip().replace("T", " ")
    for fmt in ("%Y-%m-%d %H:%M:%S", "%Y-%m-%d %H:%M:%S.%f", "%Y-%m-%d"):
        try:
            return datetime.strptime(text[:26], fmt)
        except ValueError:
            continue
    return None


def facility_type(pile_types: set[str], speed_classes: set[str]) -> int:
    if "ultra" in speed_classes:
        return 4
    ac = "AC" in pile_types
    dc = "DC" in pile_types
    if ac and dc:
        return 3
    if dc:
        return 2
    return 1


def main() -> None:
    parser = argparse.ArgumentParser(description="导出一期 SQLite 到大屏 raw CSV")
    parser.add_argument("--db", help="charge_pile.db 路径")
    parser.add_argument(
        "--out",
        required=True,
        help="输出目录（将写入 nvv2t.csv / nvv2t_md_end.csv）",
    )
    parser.add_argument(
        "--min-orders",
        type=int,
        default=50,
        help="订单少于此数则拒绝覆盖（避免空大屏）。用 --force 跳过。",
    )
    parser.add_argument("--force", action="store_true")
    args = parser.parse_args()

    db_path = find_db(args.db)
    out_dir = Path(args.out)
    out_dir.mkdir(parents=True, exist_ok=True)
    conn = sqlite3.connect(f"file:{db_path}?mode=ro", uri=True)
    conn.row_factory = sqlite3.Row

    stations = list(conn.execute("SELECT * FROM stations"))
    piles = list(conn.execute("SELECT * FROM piles"))
    orders = list(
        conn.execute(
            "SELECT * FROM charging_orders WHERE status IN ('finished','pending_payment','ongoing')"
        )
    )
    if len(orders) < args.min_orders and not args.force:
        raise SystemExit(
            f"订单仅 {len(orders)} 条（阈值 {args.min_orders}）。"
            "大屏样例数据更完整，未覆盖 data/raw。需要强制导出请加 --force。"
        )

    piles_by_id = {row["id"]: row for row in piles}
    piles_by_station: dict[int, list] = {}
    for row in piles:
        piles_by_station.setdefault(row["station_id"], []).append(row)

    station_path = out_dir / "nvv2t_md_end.csv"
    with station_path.open("w", encoding="utf-8", newline="") as fh:
        writer = csv.writer(fh)
        writer.writerow(
            [
                "stationId",
                "locationId",
                "facilityType",
                "station_name",
                "address",
                "device_count",
                "open_time",
                "update_time",
            ]
        )
        for station in stations:
            station_piles = piles_by_station.get(station["id"], [])
            types = {p["pile_type"] for p in station_piles}
            speeds = {p["speed_class"] for p in station_piles}
            writer.writerow(
                [
                    station["id"],
                    station["id"],
                    facility_type(types, speeds),
                    station["name"],
                    station["address"],
                    len(station_piles),
                    station["open_hours"] or "00:00-24:00",
                    (station["updated_at"] or "")[:10].replace("-", "/"),
                ]
            )

    order_path = out_dir / "nvv2t.csv"
    with order_path.open("w", encoding="utf-8", newline="") as fh:
        writer = csv.writer(fh)
        writer.writerow(
            [
                "sessionId",
                "kwhTotal",
                "charging_fees",
                "created",
                "ended",
                "startTime",
                "endTime",
                "chargeTimeHrs",
                "weekday",
                "platform",
                "userId",
                "stationId",
                "locationId",
                "managerVehicle",
                "facilityType",
                "Mon",
                "Tues",
                "Wed",
                "Thurs",
                "Fri",
                "Sat",
                "Sun",
            ]
        )
        for order in orders:
            pile = piles_by_id.get(order["pile_id"])
            station_id = pile["station_id"] if pile else 0
            start = parse_dt(order["start_time"]) or parse_dt(order["created_at"])
            end = parse_dt(order["end_time"]) or start
            if not start:
                continue
            hours = max((end - start).total_seconds() / 3600.0, 0.05) if end else 0.5
            one_hot = [0] * 7
            one_hot[start.weekday()] = 1
            writer.writerow(
                [
                    order["order_no"] or order["id"],
                    round(float(order["energy_kwh"] or 0), 2),
                    round(float(order["amount"] or 0), 2),
                    start.strftime("%Y-%m-%d %H:%M:%S"),
                    (end or start).strftime("%Y-%m-%d %H:%M:%S"),
                    start.hour,
                    (end or start).hour,
                    round(hours, 6),
                    start.strftime("%a"),
                    "android",
                    order["user_id"],
                    station_id,
                    station_id,
                    0,
                    facility_type(
                        {pile["pile_type"]} if pile else set(),
                        {pile["speed_class"]} if pile else set(),
                    ),
                    *one_hot,
                ]
            )

    print(f"已导出 {len(stations)} 座电站、{len(orders)} 条订单")
    print(f"  {station_path}")
    print(f"  {order_path}")
    print("遥测 dsv13r2.csv 一期基本为空，请保留大屏自带样例，勿覆盖。")


if __name__ == "__main__":
    main()
