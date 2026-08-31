-- 充电桩综合管理系统 - SQLite 建表脚本
-- 适用于 Ubuntu + Qt6 (QSQLITE)

PRAGMA foreign_keys = ON;

-- 普通用户
CREATE TABLE IF NOT EXISTS users (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    username      TEXT    NOT NULL UNIQUE,
    password      TEXT    NOT NULL,
    phone         TEXT,
    balance       REAL    NOT NULL DEFAULT 0,
    car_model     TEXT,
    plate_number  TEXT,
    created_at    TEXT    NOT NULL DEFAULT (datetime('now','localtime'))
);

-- 管理员
CREATE TABLE IF NOT EXISTS admins (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    username      TEXT    NOT NULL UNIQUE,
    password      TEXT    NOT NULL,
    real_name     TEXT,
    role          TEXT    NOT NULL DEFAULT 'operator'
);

-- 充电站
CREATE TABLE IF NOT EXISTS stations (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    name          TEXT    NOT NULL,
    address       TEXT    NOT NULL,
    latitude      REAL    NOT NULL DEFAULT 0,
    longitude     REAL    NOT NULL DEFAULT 0,
    open_hours    TEXT    DEFAULT '00:00-24:00',
    status        TEXT    NOT NULL DEFAULT 'open', -- open / closed / maintenance
    created_at    TEXT    NOT NULL DEFAULT (datetime('now','localtime'))
);

-- 充电桩
CREATE TABLE IF NOT EXISTS piles (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    station_id    INTEGER NOT NULL,
    pile_code     TEXT    NOT NULL UNIQUE,
    pile_type     TEXT    NOT NULL DEFAULT 'AC',   -- AC 慢充 / DC 快充
    power_kw      REAL    NOT NULL DEFAULT 7.0,
    price_per_kwh REAL    NOT NULL DEFAULT 1.2,
    status        TEXT    NOT NULL DEFAULT 'idle', -- idle / charging / fault / offline
    FOREIGN KEY (station_id) REFERENCES stations(id) ON DELETE CASCADE
);

-- 充电订单
CREATE TABLE IF NOT EXISTS charging_orders (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    order_no      TEXT    NOT NULL UNIQUE,
    user_id       INTEGER NOT NULL,
    pile_id       INTEGER NOT NULL,
    start_time    TEXT,
    end_time      TEXT,
    energy_kwh    REAL    NOT NULL DEFAULT 0,
    amount        REAL    NOT NULL DEFAULT 0,
    status        TEXT    NOT NULL DEFAULT 'ongoing', -- ongoing / finished / cancelled
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (pile_id) REFERENCES piles(id)
);

-- 充值记录
CREATE TABLE IF NOT EXISTS recharge_records (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id       INTEGER NOT NULL,
    amount        REAL    NOT NULL,
    created_at    TEXT    NOT NULL DEFAULT (datetime('now','localtime')),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE INDEX IF NOT EXISTS idx_piles_station ON piles(station_id);
CREATE INDEX IF NOT EXISTS idx_orders_user ON charging_orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON charging_orders(status);
