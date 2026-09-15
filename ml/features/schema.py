"""The exact feature columns and order used by the frozen models."""

FEATURE_COLUMNS = (
    "hour",
    "weekday",
    "is_weekend",
    "target_hour",
    "target_weekday",
    "target_is_weekend",
    "load_lag_1",
    "load_lag_6",
    "load_lag_24",
    "load_rolling_mean_6",
    "load_rolling_mean_24",
    "occupancy_lag_1",
    "occupancy_lag_6",
    "occupancy_lag_24",
    "occupancy_rolling_mean_6",
    "occupancy_rolling_mean_24",
    "total_piles",
    "station_capacity_kw",
)

H1_FEATURE_COLUMNS = (
    *FEATURE_COLUMNS,
    "current_load_ratio",
    "current_occupancy_ratio",
)

CANONICAL_HOURLY_COLUMNS = (
    "station_id",
    "timestamp",
    "load_ratio",
    "occupancy_ratio",
    "total_piles",
    "station_capacity_kw",
)
