"""Run one warehouse prediction batch. systemd handles timing and retries."""

import argparse
from datetime import datetime
import json
from zoneinfo import ZoneInfo

from ml.warehouse.results import FileForecastStore, mysql_from_environment
from ml.service.batch import run_forecast


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--snapshot", required=True, help="Committed DWS snapshot directory, absolute path or hdfs:// URI")
    parser.add_argument("--as-of", help="Trigger time; default now in Asia/Shanghai")
    parser.add_argument("--store", choices=["file", "mysql"], default="file")
    parser.add_argument("--results-dir", default="ml/data/warehouse/ads")
    parser.add_argument("--audit-dir", default="ml/data/warehouse/audit")
    parser.add_argument("--station-ids", type=int, nargs="+")
    parser.add_argument("--allow-simulated", action="store_true")
    parser.add_argument("--config")
    args = parser.parse_args()
    store = FileForecastStore(args.results_dir) if args.store == "file" else mysql_from_environment()
    try:
        payload, audit = run_forecast(
            args.snapshot, args.as_of or datetime.now(ZoneInfo("Asia/Shanghai")), store, args.audit_dir,
            allow_simulated=args.allow_simulated, station_ids=args.station_ids, config_path=args.config,
        )
    except Exception as error:
        print(json.dumps({"success": False, "error": str(error)}, ensure_ascii=False))
        return 1
    print(json.dumps({"success": True, "run_id": payload["run_id"], "stations": len(payload["stations"]),
                      "audit_dir": str(audit), "source_kind": payload["source_kind"]}, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
