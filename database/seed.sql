-- 示例数据（首次初始化时导入）

INSERT OR IGNORE INTO admins (id, username, password, real_name, role) VALUES
(1, 'admin', '123456', '系统管理员', 'admin'),
(2, 'ops01', 'ops123', '运维小王', 'operator');

INSERT OR IGNORE INTO users (id, username, password, phone, nickname, balance, car_model, plate_number) VALUES
(1, 'zhangsan', '123456', '13800001111', '张三', 200.00, '比亚迪汉EV', '京A·D1234'),
(2, 'lisi', '123456', '13900002222', '李四', 80.50, '特斯拉Model 3', '京B·T8888'),
(3, 'wangwu', '123456', '13700003333', '王五', 500.00, '小鹏P7', '京C·X6666');

INSERT OR IGNORE INTO stations (id, name, address, latitude, longitude, open_hours, status) VALUES
(1, '理工充电站·东门站', '北京市海淀区理工东路1号', 39.9600, 116.3600, '00:00-24:00', 'open'),
(2, '中关村科技园站', '北京市海淀区中关村大街27号', 39.9830, 116.3160, '06:00-23:00', 'open'),
(3, '奥体中心快充站', '北京市朝阳区北辰东路15号', 39.9930, 116.3970, '00:00-24:00', 'open'),
(4, '西二旗地铁站', '北京市海淀区西二旗西路', 40.0530, 116.3060, '07:00-22:00', 'maintenance');

INSERT OR IGNORE INTO piles (id, station_id, pile_code, pile_type, power_kw, price_per_kwh, status) VALUES
(1, 1, 'ST01-A01', 'AC', 7.0, 1.20, 'idle'),
(2, 1, 'ST01-A02', 'AC', 7.0, 1.20, 'idle'),
(3, 1, 'ST01-D01', 'DC', 60.0, 1.80, 'charging'),
(4, 1, 'ST01-D02', 'DC', 120.0, 2.00, 'idle'),
(5, 2, 'ST02-A01', 'AC', 7.0, 1.15, 'idle'),
(6, 2, 'ST02-A02', 'AC', 11.0, 1.25, 'fault'),
(7, 2, 'ST02-D01', 'DC', 60.0, 1.75, 'idle'),
(8, 3, 'ST03-D01', 'DC', 120.0, 2.10, 'idle'),
(9, 3, 'ST03-D02', 'DC', 120.0, 2.10, 'charging'),
(10, 3, 'ST03-D03', 'DC', 180.0, 2.30, 'offline'),
(11, 4, 'ST04-A01', 'AC', 7.0, 1.10, 'offline'),
(12, 4, 'ST04-A02', 'AC', 7.0, 1.10, 'offline');

INSERT OR IGNORE INTO charging_orders
(id, order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh,
 amount, status, payment_status, paid_at) VALUES
(1, 'ORD20260828001', 1, 3, '2026-08-28 09:10:00', '2026-08-28 09:45:00', 28.5, 1.80, 51.30, 'finished', 'paid', '2026-08-28 09:45:00'),
(2, 'ORD20260829001', 2, 9, '2026-08-29 14:00:00', '2026-08-29 14:35:00', 42.0, 2.10, 88.20, 'finished', 'paid', '2026-08-29 14:35:00'),
(3, 'ORD20260830001', 1, 7, '2026-08-30 18:20:00', '2026-08-30 19:05:00', 35.2, 1.75, 61.60, 'finished', 'paid', '2026-08-30 19:05:00'),
(4, 'ORD20260831001', 3, 3, '2026-08-31 10:00:00', NULL, 12.0, 1.80, 21.60, 'ongoing', 'unpaid', NULL),
(5, 'ORD20260831002', 2, 9, '2026-08-31 11:30:00', NULL, 8.5, 2.10, 17.85, 'ongoing', 'unpaid', NULL);

INSERT OR IGNORE INTO recharge_records (id, user_id, amount, created_at) VALUES
(1, 1, 100.00, '2026-08-20 12:00:00'),
(2, 1, 100.00, '2026-08-25 09:30:00'),
(3, 2, 80.50, '2026-08-22 16:00:00'),
(4, 3, 500.00, '2026-08-18 10:00:00');
