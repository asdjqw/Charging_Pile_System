"""Local read-only forecast API; production integrates the same blueprint."""

import argparse

from ml.warehouse.api import create_forecast_blueprint
from ml.warehouse.results import FileForecastStore, mysql_from_environment


def main():
    from flask import Flask
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--store", choices=["file", "mysql"], default="file")
    parser.add_argument("--results-dir", default="ml/data/warehouse/ads")
    parser.add_argument("--source-kind", choices=["MEASURED", "SIMULATED"], default="MEASURED")
    parser.add_argument("--port", type=int, default=5010)
    args = parser.parse_args()
    store = FileForecastStore(args.results_dir) if args.store == "file" else mysql_from_environment()
    app = Flask(__name__)
    app.register_blueprint(create_forecast_blueprint(store, source_kind=args.source_kind))
    app.run(host="127.0.0.1", port=args.port, debug=False)


if __name__ == "__main__":
    main()
