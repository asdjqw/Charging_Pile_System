-- 充电桩综合管理系统 - SQLite 2.0
-- 由 PC 服务器端通过 Qt QSQLITE 独占访问，用户端只通过 TCP Socket 调用服务端。

PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS schema_meta (
    version       INTEGER NOT NULL,
    applied_at    TEXT    NOT NULL DEFAULT (datetime('now','localtime'))
);

-- 用户。username/password 为兼容现有界面保留；新客户端以 phone 免密登录。
CREATE TABLE IF NOT EXISTS users (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    username      TEXT    NOT NULL UNIQUE,
    password      TEXT    NOT NULL DEFAULT '',
    phone         TEXT    NOT NULL UNIQUE
                          CHECK(length(phone) = 11 AND phone NOT GLOB '*[^0-9]*'),
    nickname      TEXT    NOT NULL DEFAULT '',
    avatar_path   TEXT    NOT NULL DEFAULT '',
    balance       REAL    NOT NULL DEFAULT 0 CHECK(balance >= 0),
    car_model     TEXT    NOT NULL DEFAULT '',
    plate_number  TEXT    NOT NULL DEFAULT '',
    status        TEXT    NOT NULL DEFAULT 'normal'
                          CHECK(status IN ('normal','frozen')),
    created_at    TEXT    NOT NULL DEFAULT (datetime('now','localtime')),
    updated_at    TEXT    NOT NULL DEFAULT (datetime('now','localtime'))
);

CREATE TABLE IF NOT EXISTS admins (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    username      TEXT    NOT NULL UNIQUE,
    password      TEXT    NOT NULL,
    password_hash TEXT    NOT NULL DEFAULT '',
    real_name     TEXT    NOT NULL DEFAULT '',
    role          TEXT    NOT NULL DEFAULT 'operator'
                          CHECK(role IN ('admin','operator','auditor')),
    status        TEXT    NOT NULL DEFAULT 'normal'
                          CHECK(status IN ('normal','disabled')),
    last_login_at TEXT,
    created_at    TEXT    NOT NULL DEFAULT (datetime('now','localtime'))
);

CREATE TABLE IF NOT EXISTS stations (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    station_code  TEXT    UNIQUE,
    name          TEXT    NOT NULL,
    address       TEXT    NOT NULL,
    region_code   TEXT    NOT NULL DEFAULT '',
    latitude      REAL    NOT NULL CHECK(latitude BETWEEN -90 AND 90),
    longitude     REAL    NOT NULL CHECK(longitude BETWEEN -180 AND 180),
    open_hours    TEXT    NOT NULL DEFAULT '00:00-24:00',
    contact_phone TEXT    NOT NULL DEFAULT '',
    parking_fee   REAL    NOT NULL DEFAULT 0 CHECK(parking_fee >= 0),
    status        TEXT    NOT NULL DEFAULT 'open'
                          CHECK(status IN ('open','closed','maintenance')),
    created_at    TEXT    NOT NULL DEFAULT (datetime('now','localtime')),
    updated_at    TEXT    NOT NULL DEFAULT (datetime('now','localtime'))
);

CREATE TABLE IF NOT EXISTS piles (
    id                   INTEGER PRIMARY KEY AUTOINCREMENT,
    station_id           INTEGER NOT NULL,
    pile_code            TEXT    NOT NULL UNIQUE,
    pile_type            TEXT    NOT NULL DEFAULT 'AC'
                                 CHECK(pile_type IN ('AC','DC')),
    speed_class          TEXT    NOT NULL DEFAULT 'slow'
                                 CHECK(speed_class IN ('slow','standard','fast','ultra')),
    connector_standard   TEXT    NOT NULL DEFAULT 'GB_T_AC'
                                 CHECK(connector_standard IN ('GB_T_AC','GB_T_DC','CCS2','CHAdeMO','TeslaNACS')),
    phase                TEXT    NOT NULL DEFAULT 'single'
                                 CHECK(phase IN ('single','three')),
    voltage_v            INTEGER NOT NULL DEFAULT 220 CHECK(voltage_v > 0),
    category_label       TEXT    NOT NULL DEFAULT '',
    connector_no         INTEGER NOT NULL DEFAULT 1 CHECK(connector_no > 0),
    power_kw             REAL    NOT NULL DEFAULT 7.0 CHECK(power_kw > 0),
    price_per_kwh        REAL    NOT NULL DEFAULT 1.2 CHECK(price_per_kwh >= 0),
    status               TEXT    NOT NULL DEFAULT 'idle'
                                 CHECK(status IN ('idle','reserved','charging','fault','offline','restarting')),
    total_charge_count   INTEGER NOT NULL DEFAULT 0 CHECK(total_charge_count >= 0),
    total_charge_seconds INTEGER NOT NULL DEFAULT 0 CHECK(total_charge_seconds >= 0),
    firmware_version     TEXT    NOT NULL DEFAULT '',
    last_heartbeat       TEXT,
    created_at           TEXT    NOT NULL DEFAULT (datetime('now','localtime')),
    updated_at           TEXT    NOT NULL DEFAULT (datetime('now','localtime')),
    FOREIGN KEY (station_id) REFERENCES stations(id) ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS idx_piles_type_speed ON piles(pile_type, speed_class);
CREATE INDEX IF NOT EXISTS idx_piles_connector ON piles(connector_standard);

CREATE TABLE IF NOT EXISTS charging_reservations (
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    reservation_no TEXT    NOT NULL UNIQUE,
    user_id        INTEGER NOT NULL,
    pile_id        INTEGER NOT NULL,
    reserved_at    TEXT    NOT NULL DEFAULT (datetime('now','localtime')),
    expires_at     TEXT    NOT NULL,
    status         TEXT    NOT NULL DEFAULT 'active'
                           CHECK(status IN ('active','used','expired','cancelled')),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE RESTRICT,
    FOREIGN KEY (pile_id) REFERENCES piles(id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS charging_orders (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    order_no        TEXT    NOT NULL UNIQUE,
    user_id         INTEGER NOT NULL,
    pile_id         INTEGER NOT NULL,
    reservation_id  INTEGER,
    start_time      TEXT,
    end_time        TEXT,
    energy_kwh      REAL    NOT NULL DEFAULT 0 CHECK(energy_kwh >= 0),
    price_per_kwh   REAL    NOT NULL DEFAULT 0 CHECK(price_per_kwh >= 0),
    service_fee     REAL    NOT NULL DEFAULT 0 CHECK(service_fee >= 0),
    amount          REAL    NOT NULL DEFAULT 0 CHECK(amount >= 0),
    status          TEXT    NOT NULL DEFAULT 'ongoing'
                            CHECK(status IN ('ongoing','pending_payment','finished','cancelled')),
    payment_status  TEXT    NOT NULL DEFAULT 'unpaid'
                            CHECK(payment_status IN ('unpaid','paid','refunded')),
    paid_at         TEXT,
    created_at      TEXT    NOT NULL DEFAULT (datetime('now','localtime')),
    updated_at      TEXT    NOT NULL DEFAULT (datetime('now','localtime')),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE RESTRICT,
    FOREIGN KEY (pile_id) REFERENCES piles(id) ON DELETE RESTRICT,
    FOREIGN KEY (reservation_id) REFERENCES charging_reservations(id) ON DELETE SET NULL
);

-- 钱包流水是账务审计依据；users.balance 是供界面快速读取的余额快照。
CREATE TABLE IF NOT EXISTS wallet_transactions (
    id               INTEGER PRIMARY KEY AUTOINCREMENT,
    transaction_no   TEXT    NOT NULL UNIQUE,
    user_id          INTEGER NOT NULL,
    order_id         INTEGER,
    transaction_type TEXT    NOT NULL
                            CHECK(transaction_type IN ('recharge','charge_payment','refund','adjustment')),
    amount           REAL    NOT NULL CHECK(amount != 0),
    balance_after    REAL    NOT NULL CHECK(balance_after >= 0),
    status           TEXT    NOT NULL DEFAULT 'success'
                            CHECK(status IN ('pending','success','failed')),
    remark           TEXT    NOT NULL DEFAULT '',
    created_at       TEXT    NOT NULL DEFAULT (datetime('now','localtime')),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE RESTRICT,
    FOREIGN KEY (order_id) REFERENCES charging_orders(id) ON DELETE RESTRICT
);

-- 兼容现有 DatabaseManager::rechargeUser。
CREATE TABLE IF NOT EXISTS recharge_records (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id       INTEGER NOT NULL,
    payment_no    TEXT    UNIQUE,
    amount        REAL    NOT NULL CHECK(amount > 0),
    status        TEXT    NOT NULL DEFAULT 'success'
                          CHECK(status IN ('pending','success','failed')),
    created_at    TEXT    NOT NULL DEFAULT (datetime('now','localtime')),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS user_sessions (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    token_hash    TEXT    NOT NULL UNIQUE,
    user_id       INTEGER NOT NULL,
    client_id     TEXT    NOT NULL DEFAULT '',
    peer_ip       TEXT    NOT NULL DEFAULT '',
    expires_at    TEXT    NOT NULL,
    revoked_at    TEXT,
    created_at    TEXT    NOT NULL DEFAULT (datetime('now','localtime')),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS pile_telemetry (
    id               INTEGER PRIMARY KEY AUTOINCREMENT,
    pile_id          INTEGER NOT NULL,
    sampled_at       TEXT    NOT NULL,
    voltage_v        REAL,
    current_a        REAL,
    power_kw         REAL    NOT NULL DEFAULT 0 CHECK(power_kw >= 0),
    energy_kwh       REAL    NOT NULL DEFAULT 0 CHECK(energy_kwh >= 0),
    temperature_c    REAL,
    connector_status TEXT    NOT NULL DEFAULT '',
    error_code       TEXT    NOT NULL DEFAULT '',
    FOREIGN KEY (pile_id) REFERENCES piles(id) ON DELETE CASCADE,
    UNIQUE (pile_id, sampled_at)
);

CREATE TABLE IF NOT EXISTS pile_status_logs (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    pile_id       INTEGER NOT NULL,
    old_status    TEXT,
    new_status    TEXT    NOT NULL,
    source        TEXT    NOT NULL DEFAULT 'system'
                          CHECK(source IN ('pile','system','admin')),
    reason        TEXT    NOT NULL DEFAULT '',
    changed_at    TEXT    NOT NULL DEFAULT (datetime('now','localtime')),
    FOREIGN KEY (pile_id) REFERENCES piles(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS fault_events (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    pile_id       INTEGER NOT NULL,
    fault_code    TEXT    NOT NULL,
    severity      TEXT    NOT NULL DEFAULT 'warning'
                          CHECK(severity IN ('info','warning','critical')),
    description   TEXT    NOT NULL DEFAULT '',
    occurred_at   TEXT    NOT NULL,
    resolved_at   TEXT,
    status        TEXT    NOT NULL DEFAULT 'open'
                          CHECK(status IN ('open','processing','resolved')),
    model_score   REAL    CHECK(model_score IS NULL OR model_score BETWEEN 0 AND 1),
    FOREIGN KEY (pile_id) REFERENCES piles(id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS weather_observations (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    station_id    INTEGER NOT NULL,
    observed_at   TEXT    NOT NULL,
    temperature_c REAL,
    humidity_pct  REAL    CHECK(humidity_pct IS NULL OR humidity_pct BETWEEN 0 AND 100),
    weather_type  TEXT    NOT NULL DEFAULT '',
    is_holiday    INTEGER NOT NULL DEFAULT 0 CHECK(is_holiday IN (0,1)),
    FOREIGN KEY (station_id) REFERENCES stations(id) ON DELETE CASCADE,
    UNIQUE (station_id, observed_at)
);

CREATE TABLE IF NOT EXISTS station_load_samples (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    station_id    INTEGER NOT NULL,
    sampled_at    TEXT    NOT NULL,
    active_piles  INTEGER NOT NULL DEFAULT 0 CHECK(active_piles >= 0),
    idle_piles    INTEGER NOT NULL DEFAULT 0 CHECK(idle_piles >= 0),
    load_kw       REAL    NOT NULL DEFAULT 0 CHECK(load_kw >= 0),
    energy_kwh    REAL    NOT NULL DEFAULT 0 CHECK(energy_kwh >= 0),
    FOREIGN KEY (station_id) REFERENCES stations(id) ON DELETE CASCADE,
    UNIQUE (station_id, sampled_at)
);

CREATE TABLE IF NOT EXISTS ml_models (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    model_name    TEXT    NOT NULL,
    model_version TEXT    NOT NULL,
    algorithm     TEXT    NOT NULL,
    artifact_path TEXT    NOT NULL,
    metrics_json  TEXT    NOT NULL DEFAULT '{}',
    status        TEXT    NOT NULL DEFAULT 'training'
                          CHECK(status IN ('training','active','retired','failed')),
    trained_at    TEXT,
    deployed_at   TEXT,
    UNIQUE(model_name, model_version)
);

CREATE TABLE IF NOT EXISTS load_forecasts (
    id                    INTEGER PRIMARY KEY AUTOINCREMENT,
    station_id            INTEGER NOT NULL,
    model_id              INTEGER NOT NULL,
    generated_at          TEXT    NOT NULL,
    target_time           TEXT    NOT NULL,
    horizon_hours         INTEGER NOT NULL CHECK(horizon_hours IN (1,6,24)),
    predicted_load_kw     REAL    NOT NULL CHECK(predicted_load_kw >= 0),
    predicted_idle_piles  INTEGER NOT NULL CHECK(predicted_idle_piles >= 0),
    congestion_level      TEXT    NOT NULL
                                  CHECK(congestion_level IN ('low','medium','high')),
    lower_bound_kw        REAL,
    upper_bound_kw        REAL,
    FOREIGN KEY (station_id) REFERENCES stations(id) ON DELETE CASCADE,
    FOREIGN KEY (model_id) REFERENCES ml_models(id) ON DELETE RESTRICT,
    UNIQUE(station_id, model_id, generated_at, target_time)
);

CREATE TABLE IF NOT EXISTS admin_audit_logs (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    admin_id      INTEGER NOT NULL,
    action        TEXT    NOT NULL,
    target_type   TEXT    NOT NULL,
    target_id     INTEGER,
    request_id    TEXT    NOT NULL DEFAULT '',
    detail_json   TEXT    NOT NULL DEFAULT '{}',
    created_at    TEXT    NOT NULL DEFAULT (datetime('now','localtime')),
    FOREIGN KEY (admin_id) REFERENCES admins(id) ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS idx_users_phone ON users(phone);
CREATE INDEX IF NOT EXISTS idx_users_status ON users(status);
CREATE UNIQUE INDEX IF NOT EXISTS uq_station_code
    ON stations(station_code) WHERE station_code IS NOT NULL AND station_code != '';
CREATE UNIQUE INDEX IF NOT EXISTS uq_recharge_payment_no
    ON recharge_records(payment_no) WHERE payment_no IS NOT NULL AND payment_no != '';
CREATE INDEX IF NOT EXISTS idx_stations_region_status ON stations(region_code, status);
CREATE INDEX IF NOT EXISTS idx_piles_station_status ON piles(station_id, status);
CREATE INDEX IF NOT EXISTS idx_orders_user_status ON charging_orders(user_id, status);
CREATE INDEX IF NOT EXISTS idx_orders_pile_start ON charging_orders(pile_id, start_time);
CREATE INDEX IF NOT EXISTS idx_orders_end_status ON charging_orders(end_time, status);
CREATE UNIQUE INDEX IF NOT EXISTS uq_user_ongoing_order
    ON charging_orders(user_id) WHERE status IN ('ongoing','pending_payment');
CREATE UNIQUE INDEX IF NOT EXISTS uq_pile_ongoing_order
    ON charging_orders(pile_id) WHERE status = 'ongoing';
CREATE UNIQUE INDEX IF NOT EXISTS uq_user_active_reservation
    ON charging_reservations(user_id) WHERE status = 'active';
CREATE UNIQUE INDEX IF NOT EXISTS uq_pile_active_reservation
    ON charging_reservations(pile_id) WHERE status = 'active';
CREATE INDEX IF NOT EXISTS idx_wallet_user_time ON wallet_transactions(user_id, created_at);
CREATE INDEX IF NOT EXISTS idx_sessions_user_expiry ON user_sessions(user_id, expires_at);
CREATE INDEX IF NOT EXISTS idx_telemetry_pile_time ON pile_telemetry(pile_id, sampled_at);
CREATE INDEX IF NOT EXISTS idx_fault_pile_status ON fault_events(pile_id, status, occurred_at);
CREATE INDEX IF NOT EXISTS idx_load_samples_station_time ON station_load_samples(station_id, sampled_at);
CREATE INDEX IF NOT EXISTS idx_forecasts_station_target ON load_forecasts(station_id, target_time, horizon_hours);
CREATE INDEX IF NOT EXISTS idx_audit_admin_time ON admin_audit_logs(admin_id, created_at);

INSERT INTO schema_meta(version)
SELECT 2 WHERE NOT EXISTS (SELECT 1 FROM schema_meta);
