"""Read-only Flask blueprint shared by the three presentation clients."""

from copy import deepcopy
from datetime import datetime
from zoneinfo import ZoneInfo


def create_forecast_blueprint(store, *, source_kind="MEASURED"):
    from flask import Blueprint, jsonify, request
    blueprint = Blueprint("ml_forecast", __name__)

    @blueprint.get("/api/forecast/latest")
    @blueprint.get("/api/forecast/station/<int:station_id>")
    def latest(station_id=None):
        query_id = request.args.get("station_id")
        if query_id is not None:
            try:
                parsed = int(query_id)
                if parsed <= 0 or (station_id is not None and station_id != parsed):
                    raise ValueError
                station_id = parsed
            except ValueError:
                return jsonify(code=400, msg="station_id must be a positive integer matching the path", data=None), 400
        try:
            payload = store.latest(source_kind)
        except Exception:
            return jsonify(code=503, msg="Prediction store unavailable", data=None), 503
        if payload is None:
            return jsonify(code=404, msg="No published forecast", data=None), 404
        payload = deepcopy(payload)
        if station_id is not None:
            exact = [s for s in payload["stations"] if s["station_id"] == station_id]
            if exact:
                payload["stations"] = exact
                payload["station_mapped"] = False
            elif payload.get("source_kind") == "MEASURED" and payload.get("stations"):
                source = deepcopy(payload["stations"][station_id % len(payload["stations"])])
                payload["mapped_from_station_id"] = source["station_id"]
                source["station_id"] = station_id
                payload["stations"] = [source]
                payload["station_mapped"] = True
            else:
                return jsonify(code=404, msg="Station absent from latest batch", data=None), 404
        now = datetime.now(ZoneInfo("Asia/Shanghai")).replace(tzinfo=None)
        age = (now - datetime.fromisoformat(payload["data_cutoff_time"])).total_seconds()
        payload["age_seconds"] = max(0, int(age))
        payload["stale"] = age >= 7200
        payload["simulation"] = payload["source_kind"] == "SIMULATED"
        return jsonify(code=0, msg="ok", data=payload)

    return blueprint
