-- Handoff migration only. This file is NOT executed by ML startup.
-- Apply to the selected MySQL database only after the database owner integrates it.
-- All time fields use Asia/Shanghai, ISO 8601, no implicit server timezone conversion.
CREATE TABLE IF NOT EXISTS ml_forecast_runs (
    run_id VARCHAR(100) PRIMARY KEY,
    input_sha256 CHAR(64) NOT NULL,
    source_kind VARCHAR(16) NOT NULL,
    data_cutoff_time VARCHAR(32) NOT NULL,
    generated_at VARCHAR(32) NOT NULL,
    payload JSON NOT NULL,
    INDEX idx_ml_latest (source_kind, data_cutoff_time, generated_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS ads_station_forecast (
    run_id VARCHAR(100) NOT NULL,
    station_id BIGINT NOT NULL,
    target_name VARCHAR(16) NOT NULL,
    horizon_hours INT NOT NULL,
    target_start VARCHAR(32) NOT NULL,
    target_end VARCHAR(32) NOT NULL,
    prediction_value DOUBLE NOT NULL,
    model_version VARCHAR(100) NOT NULL,
    PRIMARY KEY (run_id, station_id, target_name, horizon_hours),
    INDEX idx_ml_station_target (station_id, target_start),
    FOREIGN KEY (run_id) REFERENCES ml_forecast_runs(run_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
