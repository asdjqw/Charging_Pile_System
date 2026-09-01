-- 基础账号（站点/电桩由 CSV 导入）

INSERT OR IGNORE INTO admins (id, username, password, password_hash, real_name, role) VALUES
(1, 'admin', '123456', '', '系统管理员', 'admin'),
(2, 'ops01', 'ops123', '', '运维小王', 'operator');

INSERT OR IGNORE INTO users (id, username, password, phone, nickname, balance, car_model, plate_number) VALUES
(1, 'zhangsan', '123456', '13800001111', '张三', 200.00, '比亚迪汉EV', '京A·D1234'),
(2, 'lisi', '123456', '13900002222', '李四', 80.50, '特斯拉Model 3', '京B·T8888'),
(3, 'wangwu', '123456', '13700003333', '王五', 500.00, '小鹏P7', '京C·X6666');

INSERT OR IGNORE INTO recharge_records (id, user_id, amount, created_at) VALUES
(1, 1, 100.00, '2026-08-20 12:00:00'),
(2, 1, 100.00, '2026-08-25 09:30:00'),
(3, 2, 80.50, '2026-08-22 16:00:00'),
(4, 3, 500.00, '2026-08-18 10:00:00');
