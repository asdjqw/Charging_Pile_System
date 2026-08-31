-- 可选：MySQL / MariaDB 建表脚本（与 SQLite 字段对应）
-- 使用方法：
--   mysql -u root -p -e "CREATE DATABASE charge_pile DEFAULT CHARSET utf8mb4;"
--   mysql -u root -p charge_pile < schema_mysql.sql

CREATE TABLE IF NOT EXISTS users (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    username      VARCHAR(64)  NOT NULL UNIQUE,
    password      VARCHAR(128) NOT NULL,
    phone         VARCHAR(32),
    balance       DECIMAL(10,2) NOT NULL DEFAULT 0,
    car_model     VARCHAR(64),
    plate_number  VARCHAR(32),
    created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS admins (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    username      VARCHAR(64)  NOT NULL UNIQUE,
    password      VARCHAR(128) NOT NULL,
    real_name     VARCHAR(64),
    role          VARCHAR(32)  NOT NULL DEFAULT 'operator'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS stations (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    name          VARCHAR(128) NOT NULL,
    address       VARCHAR(255) NOT NULL,
    latitude      DOUBLE NOT NULL DEFAULT 0,
    longitude     DOUBLE NOT NULL DEFAULT 0,
    open_hours    VARCHAR(64) DEFAULT '00:00-24:00',
    status        VARCHAR(32) NOT NULL DEFAULT 'open',
    created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS piles (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    station_id    INT NOT NULL,
    pile_code     VARCHAR(64) NOT NULL UNIQUE,
    pile_type     VARCHAR(16) NOT NULL DEFAULT 'AC',
    power_kw      DECIMAL(8,2) NOT NULL DEFAULT 7.0,
    price_per_kwh DECIMAL(8,2) NOT NULL DEFAULT 1.2,
    status        VARCHAR(32) NOT NULL DEFAULT 'idle',
    CONSTRAINT fk_piles_station FOREIGN KEY (station_id) REFERENCES stations(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS charging_orders (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    order_no      VARCHAR(64) NOT NULL UNIQUE,
    user_id       INT NOT NULL,
    pile_id       INT NOT NULL,
    start_time    DATETIME NULL,
    end_time      DATETIME NULL,
    energy_kwh    DECIMAL(10,2) NOT NULL DEFAULT 0,
    amount        DECIMAL(10,2) NOT NULL DEFAULT 0,
    status        VARCHAR(32) NOT NULL DEFAULT 'ongoing',
    CONSTRAINT fk_orders_user FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT fk_orders_pile FOREIGN KEY (pile_id) REFERENCES piles(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS recharge_records (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    user_id       INT NOT NULL,
    amount        DECIMAL(10,2) NOT NULL,
    created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_recharge_user FOREIGN KEY (user_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
