-- MySQL 展示层固定 Schema。仅由 ADS ORC 导出的管道符文本装载，禁止由 CSV 自动推断重建。
CREATE TABLE IF NOT EXISTS ads_overview (
  total_sessions BIGINT, total_kwh DOUBLE, total_revenue DOUBLE, paid_sessions BIGINT,
  user_cnt BIGINT, station_cnt BIGINT, active_days BIGINT, avg_kwh DOUBLE, avg_hours DOUBLE, avg_power DOUBLE,
  device_cnt BIGINT, paid_rate DOUBLE, start_date DATE, end_date DATE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE IF NOT EXISTS ads_daily_trend (stat_date DATE, sessions BIGINT, kwh DOUBLE, revenue DOUBLE, users BIGINT, avg_kwh DOUBLE) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE IF NOT EXISTS ads_monthly_trend (stat_month_str VARCHAR(16), sessions BIGINT, kwh DOUBLE, revenue DOUBLE, avg_kwh DOUBLE, users BIGINT) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE IF NOT EXISTS ads_hour_load (start_hour INT, sessions BIGINT, kwh DOUBLE, avg_power DOUBLE) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE IF NOT EXISTS ads_weekday_hour_heat (weekday_num INT, weekday_cn VARCHAR(16), start_hour INT, sessions BIGINT, kwh DOUBLE) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE IF NOT EXISTS ads_station_top (station_id VARCHAR(80), station_name VARCHAR(255), district VARCHAR(80), facility_type_cn VARCHAR(32), device_count INT, sessions BIGINT, kwh DOUBLE, revenue DOUBLE, users BIGINT, avg_power DOUBLE, orders_per_device DOUBLE, rank_no INT) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE IF NOT EXISTS ads_facility_compare (facility_type INT, facility_type_cn VARCHAR(32), sessions BIGINT, kwh DOUBLE, revenue DOUBLE, users BIGINT, avg_kwh DOUBLE, avg_hours DOUBLE, avg_power DOUBLE, paid_rate DOUBLE) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE IF NOT EXISTS ads_weekend_compare (day_type VARCHAR(16), days BIGINT, sessions BIGINT, kwh DOUBLE, revenue DOUBLE, users BIGINT, avg_kwh DOUBLE, avg_hours DOUBLE, avg_power DOUBLE) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE IF NOT EXISTS ads_time_period_compare (time_period VARCHAR(16), sessions BIGINT, kwh DOUBLE, revenue DOUBLE, avg_kwh DOUBLE, avg_hours DOUBLE, avg_power DOUBLE) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE IF NOT EXISTS ads_platform_compare (platform VARCHAR(32), sessions BIGINT, kwh DOUBLE, revenue DOUBLE, users BIGINT, avg_kwh DOUBLE, paid_rate DOUBLE) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE IF NOT EXISTS ads_district_compare (district VARCHAR(80), sessions BIGINT, kwh DOUBLE, revenue DOUBLE, station_cnt BIGINT, users BIGINT, avg_kwh DOUBLE) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE IF NOT EXISTS ads_duration_dist (bin_label VARCHAR(24), bin_order INT, sessions BIGINT, kwh DOUBLE, pct DOUBLE) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE IF NOT EXISTS ads_energy_dist (bin_label VARCHAR(24), bin_order INT, sessions BIGINT, kwh DOUBLE, pct DOUBLE) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE IF NOT EXISTS ads_user_segment (segment VARCHAR(32), user_cnt BIGINT, sessions BIGINT, kwh DOUBLE, avg_sessions DOUBLE, avg_kwh DOUBLE, user_pct DOUBLE, kwh_pct DOUBLE) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE IF NOT EXISTS ads_battery_health (soc_bin VARCHAR(24), facility_type_cn VARCHAR(32), samples BIGINT, avg_soc DOUBLE, avg_power DOUBLE, avg_voltage_diff DOUBLE, avg_temp_rise DOUBLE) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE IF NOT EXISTS ads_revenue_struct (dim_name VARCHAR(80), sessions BIGINT, kwh DOUBLE, revenue DOUBLE, paid_sessions BIGINT, paid_rate DOUBLE, avg_price DOUBLE, dim_type VARCHAR(32)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE IF NOT EXISTS ads_realtime_sessions (created_time DATETIME, station_name VARCHAR(255), district VARCHAR(80), facility_type_cn VARCHAR(32), platform VARCHAR(32), kwh_total DOUBLE, charging_fees DOUBLE, charge_hours DOUBLE, time_period VARCHAR(16)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE IF NOT EXISTS ads_data_quality (stage VARCHAR(80), data_type VARCHAR(32), cnt BIGINT) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE IF NOT EXISTS ads_pipeline_info (run_time DATETIME, engine VARCHAR(64), storage VARCHAR(80), raw_path VARCHAR(255), warehouse_path VARCHAR(255), ads_path VARCHAR(255), valid_sessions BIGINT, battery_records BIGINT, station_cnt BIGINT, note VARCHAR(500)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE TABLE IF NOT EXISTS etl_ads_sync_log (
  id BIGINT AUTO_INCREMENT PRIMARY KEY, load_dt DATE NOT NULL, table_name VARCHAR(80) NOT NULL,
  rows_loaded BIGINT NOT NULL, synced_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_ads_sync_batch (load_dt, table_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
