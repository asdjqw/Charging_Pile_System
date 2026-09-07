-- 运营展示数据：40 位模拟用户、近 30 天已完成充电订单。
-- 所有记录均使用固定业务标识和 INSERT OR IGNORE，可安全重复执行。
BEGIN TRANSACTION;

INSERT OR IGNORE INTO users(username, password, phone, nickname, balance, car_model, plate_number) VALUES('presentation_user_01', '123456', '13620260001', '陈晨', 120.00, '比亚迪 海豹', '京A·1200');
INSERT OR IGNORE INTO users(username, password, phone, nickname, balance, car_model, plate_number) VALUES('presentation_user_02', '123456', '13620260002', '林晓', 167.35, '特斯拉 Model 3', '京B·1201');
INSERT OR IGNORE INTO users(username, password, phone, nickname, balance, car_model, plate_number) VALUES('presentation_user_03', '123456', '13620260003', '周宇', 214.70, '小米 SU7', '京C·1202');
INSERT OR IGNORE INTO users(username, password, phone, nickname, balance, car_model, plate_number) VALUES('presentation_user_04', '123456', '13620260004', '吴然', 262.05, '极氪 007', '京D·1203');
INSERT OR IGNORE INTO users(username, password, phone, nickname, balance, car_model, plate_number) VALUES('presentation_user_05', '123456', '13620260005', '郑宁', 308.00, '小鹏 P7', '京E·1204');
INSERT OR IGNORE INTO users(username, password, phone, nickname, balance, car_model, plate_number) VALUES('presentation_user_06', '123456', '13620260006', '孙悦', 355.35, '理想 L6', '京F·1205');
INSERT OR IGNORE INTO users(username, password, phone, nickname, balance, car_model, plate_number) VALUES('presentation_user_07', '123456', '13620260007', '赵航', 402.70, '蔚来 ET5', '京G·1206');
INSERT OR IGNORE INTO users(username, password, phone, nickname, balance, car_model, plate_number) VALUES('presentation_user_08', '123456', '13620260008', '钱妍', 450.05, '大众 ID.4', '京H·1207');
INSERT OR IGNORE INTO users(username, password, phone, nickname, balance, car_model, plate_number) VALUES('presentation_user_09', '123456', '13620260009', '冯博', 496.00, '广汽 AION S', '京I·1208');
INSERT OR IGNORE INTO users(username, password, phone, nickname, balance, car_model, plate_number) VALUES('presentation_user_10', '123456', '13620260010', '宋琪', 543.35, '问界 M7', '京J·1209');
INSERT OR IGNORE INTO users(username, password, phone, nickname, balance, car_model, plate_number) VALUES('presentation_user_11', '123456', '13620260011', '蒋晨', 590.70, '比亚迪 海豹', '京K·1210');
INSERT OR IGNORE INTO users(username, password, phone, nickname, balance, car_model, plate_number) VALUES('presentation_user_12', '123456', '13620260012', '沈晓', 638.05, '特斯拉 Model 3', '京L·1211');
INSERT OR IGNORE INTO users(username, password, phone, nickname, balance, car_model, plate_number) VALUES('presentation_user_13', '123456', '13620260013', '韩宇', 684.00, '小米 SU7', '京M·1212');
INSERT OR IGNORE INTO users(username, password, phone, nickname, balance, car_model, plate_number) VALUES('presentation_user_14', '123456', '13620260014', '杨然', 731.35, '极氪 007', '京N·1213');
INSERT OR IGNORE INTO users(username, password, phone, nickname, balance, car_model, plate_number) VALUES('presentation_user_15', '123456', '13620260015', '朱宁', 158.70, '小鹏 P7', '京O·1214');
INSERT OR IGNORE INTO users(username, password, phone, nickname, balance, car_model, plate_number) VALUES('presentation_user_16', '123456', '13620260016', '秦悦', 206.05, '理想 L6', '京P·1215');
INSERT OR IGNORE INTO users(username, password, phone, nickname, balance, car_model, plate_number) VALUES('presentation_user_17', '123456', '13620260017', '许航', 252.00, '蔚来 ET5', '京Q·1216');
INSERT OR IGNORE INTO users(username, password, phone, nickname, balance, car_model, plate_number) VALUES('presentation_user_18', '123456', '13620260018', '何妍', 299.35, '大众 ID.4', '京R·1217');
INSERT OR IGNORE INTO users(username, password, phone, nickname, balance, car_model, plate_number) VALUES('presentation_user_19', '123456', '13620260019', '曹博', 346.70, '广汽 AION S', '京S·1218');
INSERT OR IGNORE INTO users(username, password, phone, nickname, balance, car_model, plate_number) VALUES('presentation_user_20', '123456', '13620260020', '邓琪', 394.05, '问界 M7', '京T·1219');
INSERT OR IGNORE INTO users(username, password, phone, nickname, balance, car_model, plate_number) VALUES('presentation_user_21', '123456', '13620260021', '陈晨', 440.00, '比亚迪 海豹', '京A·1220');
INSERT OR IGNORE INTO users(username, password, phone, nickname, balance, car_model, plate_number) VALUES('presentation_user_22', '123456', '13620260022', '林晓', 487.35, '特斯拉 Model 3', '京B·1221');
INSERT OR IGNORE INTO users(username, password, phone, nickname, balance, car_model, plate_number) VALUES('presentation_user_23', '123456', '13620260023', '周宇', 534.70, '小米 SU7', '京C·1222');
INSERT OR IGNORE INTO users(username, password, phone, nickname, balance, car_model, plate_number) VALUES('presentation_user_24', '123456', '13620260024', '吴然', 582.05, '极氪 007', '京D·1223');
INSERT OR IGNORE INTO users(username, password, phone, nickname, balance, car_model, plate_number) VALUES('presentation_user_25', '123456', '13620260025', '郑宁', 628.00, '小鹏 P7', '京E·1224');
INSERT OR IGNORE INTO users(username, password, phone, nickname, balance, car_model, plate_number) VALUES('presentation_user_26', '123456', '13620260026', '孙悦', 675.35, '理想 L6', '京F·1225');
INSERT OR IGNORE INTO users(username, password, phone, nickname, balance, car_model, plate_number) VALUES('presentation_user_27', '123456', '13620260027', '赵航', 722.70, '蔚来 ET5', '京G·1226');
INSERT OR IGNORE INTO users(username, password, phone, nickname, balance, car_model, plate_number) VALUES('presentation_user_28', '123456', '13620260028', '钱妍', 150.05, '大众 ID.4', '京H·1227');
INSERT OR IGNORE INTO users(username, password, phone, nickname, balance, car_model, plate_number) VALUES('presentation_user_29', '123456', '13620260029', '冯博', 196.00, '广汽 AION S', '京I·1228');
INSERT OR IGNORE INTO users(username, password, phone, nickname, balance, car_model, plate_number) VALUES('presentation_user_30', '123456', '13620260030', '宋琪', 243.35, '问界 M7', '京J·1229');
INSERT OR IGNORE INTO users(username, password, phone, nickname, balance, car_model, plate_number) VALUES('presentation_user_31', '123456', '13620260031', '蒋晨', 290.70, '比亚迪 海豹', '京K·1230');
INSERT OR IGNORE INTO users(username, password, phone, nickname, balance, car_model, plate_number) VALUES('presentation_user_32', '123456', '13620260032', '沈晓', 338.05, '特斯拉 Model 3', '京L·1231');
INSERT OR IGNORE INTO users(username, password, phone, nickname, balance, car_model, plate_number) VALUES('presentation_user_33', '123456', '13620260033', '韩宇', 384.00, '小米 SU7', '京M·1232');
INSERT OR IGNORE INTO users(username, password, phone, nickname, balance, car_model, plate_number) VALUES('presentation_user_34', '123456', '13620260034', '杨然', 431.35, '极氪 007', '京N·1233');
INSERT OR IGNORE INTO users(username, password, phone, nickname, balance, car_model, plate_number) VALUES('presentation_user_35', '123456', '13620260035', '朱宁', 478.70, '小鹏 P7', '京O·1234');
INSERT OR IGNORE INTO users(username, password, phone, nickname, balance, car_model, plate_number) VALUES('presentation_user_36', '123456', '13620260036', '秦悦', 526.05, '理想 L6', '京P·1235');
INSERT OR IGNORE INTO users(username, password, phone, nickname, balance, car_model, plate_number) VALUES('presentation_user_37', '123456', '13620260037', '许航', 572.00, '蔚来 ET5', '京Q·1236');
INSERT OR IGNORE INTO users(username, password, phone, nickname, balance, car_model, plate_number) VALUES('presentation_user_38', '123456', '13620260038', '何妍', 619.35, '大众 ID.4', '京R·1237');
INSERT OR IGNORE INTO users(username, password, phone, nickname, balance, car_model, plate_number) VALUES('presentation_user_39', '123456', '13620260039', '曹博', 666.70, '广汽 AION S', '京S·1238');
INSERT OR IGNORE INTO users(username, password, phone, nickname, balance, car_model, plate_number) VALUES('presentation_user_40', '123456', '13620260040', '邓琪', 714.05, '问界 M7', '京T·1239');

-- 兼容已导入的旧版展示用户：仅移除本项目展示账号的昵称后缀。
UPDATE users SET nickname='陈晨' WHERE username='presentation_user_01' AND nickname='陈晨（展示）';
UPDATE users SET nickname='林晓' WHERE username='presentation_user_02' AND nickname='林晓（展示）';
UPDATE users SET nickname='周宇' WHERE username='presentation_user_03' AND nickname='周宇（展示）';
UPDATE users SET nickname='吴然' WHERE username='presentation_user_04' AND nickname='吴然（展示）';
UPDATE users SET nickname='郑宁' WHERE username='presentation_user_05' AND nickname='郑宁（展示）';
UPDATE users SET nickname='孙悦' WHERE username='presentation_user_06' AND nickname='孙悦（展示）';
UPDATE users SET nickname='赵航' WHERE username='presentation_user_07' AND nickname='赵航（展示）';
UPDATE users SET nickname='钱妍' WHERE username='presentation_user_08' AND nickname='钱妍（展示）';
UPDATE users SET nickname='冯博' WHERE username='presentation_user_09' AND nickname='冯博（展示）';
UPDATE users SET nickname='宋琪' WHERE username='presentation_user_10' AND nickname='宋琪（展示）';
UPDATE users SET nickname='蒋晨' WHERE username='presentation_user_11' AND nickname='蒋晨（展示）';
UPDATE users SET nickname='沈晓' WHERE username='presentation_user_12' AND nickname='沈晓（展示）';
UPDATE users SET nickname='韩宇' WHERE username='presentation_user_13' AND nickname='韩宇（展示）';
UPDATE users SET nickname='杨然' WHERE username='presentation_user_14' AND nickname='杨然（展示）';
UPDATE users SET nickname='朱宁' WHERE username='presentation_user_15' AND nickname='朱宁（展示）';
UPDATE users SET nickname='秦悦' WHERE username='presentation_user_16' AND nickname='秦悦（展示）';
UPDATE users SET nickname='许航' WHERE username='presentation_user_17' AND nickname='许航（展示）';
UPDATE users SET nickname='何妍' WHERE username='presentation_user_18' AND nickname='何妍（展示）';
UPDATE users SET nickname='曹博' WHERE username='presentation_user_19' AND nickname='曹博（展示）';
UPDATE users SET nickname='邓琪' WHERE username='presentation_user_20' AND nickname='邓琪（展示）';
UPDATE users SET nickname='陈晨' WHERE username='presentation_user_21' AND nickname='陈晨（展示）';
UPDATE users SET nickname='林晓' WHERE username='presentation_user_22' AND nickname='林晓（展示）';
UPDATE users SET nickname='周宇' WHERE username='presentation_user_23' AND nickname='周宇（展示）';
UPDATE users SET nickname='吴然' WHERE username='presentation_user_24' AND nickname='吴然（展示）';
UPDATE users SET nickname='郑宁' WHERE username='presentation_user_25' AND nickname='郑宁（展示）';
UPDATE users SET nickname='孙悦' WHERE username='presentation_user_26' AND nickname='孙悦（展示）';
UPDATE users SET nickname='赵航' WHERE username='presentation_user_27' AND nickname='赵航（展示）';
UPDATE users SET nickname='钱妍' WHERE username='presentation_user_28' AND nickname='钱妍（展示）';
UPDATE users SET nickname='冯博' WHERE username='presentation_user_29' AND nickname='冯博（展示）';
UPDATE users SET nickname='宋琪' WHERE username='presentation_user_30' AND nickname='宋琪（展示）';
UPDATE users SET nickname='蒋晨' WHERE username='presentation_user_31' AND nickname='蒋晨（展示）';
UPDATE users SET nickname='沈晓' WHERE username='presentation_user_32' AND nickname='沈晓（展示）';
UPDATE users SET nickname='韩宇' WHERE username='presentation_user_33' AND nickname='韩宇（展示）';
UPDATE users SET nickname='杨然' WHERE username='presentation_user_34' AND nickname='杨然（展示）';
UPDATE users SET nickname='朱宁' WHERE username='presentation_user_35' AND nickname='朱宁（展示）';
UPDATE users SET nickname='秦悦' WHERE username='presentation_user_36' AND nickname='秦悦（展示）';
UPDATE users SET nickname='许航' WHERE username='presentation_user_37' AND nickname='许航（展示）';
UPDATE users SET nickname='何妍' WHERE username='presentation_user_38' AND nickname='何妍（展示）';
UPDATE users SET nickname='曹博' WHERE username='presentation_user_39' AND nickname='曹博（展示）';
UPDATE users SET nickname='邓琪' WHERE username='presentation_user_40' AND nickname='邓琪（展示）';

-- 每天 8～16 笔完成订单；工作日早晚高峰略高，周末午后较多。
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0001', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 10),
       datetime(date('now','localtime','-29 days'), '+21 hours', '+23 minutes'), datetime(datetime(date('now','localtime','-29 days'), '+21 hours', '+23 minutes'), '+2114 seconds'), 18.2, 1.16, 2.00, 23.11, 'finished', 'paid', datetime(datetime(date('now','localtime','-29 days'), '+21 hours', '+23 minutes'), '+2114 seconds')
FROM users u WHERE u.username='presentation_user_15'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0002', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 3),
       datetime(date('now','localtime','-29 days'), '+09 hours', '+36 minutes'), datetime(datetime(date('now','localtime','-29 days'), '+09 hours', '+36 minutes'), '+1828 seconds'), 19.3, 1.43, 3.00, 30.60, 'finished', 'paid', datetime(datetime(date('now','localtime','-29 days'), '+09 hours', '+36 minutes'), '+1828 seconds')
FROM users u WHERE u.username='presentation_user_22'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0003', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 8),
       datetime(date('now','localtime','-29 days'), '+12 hours', '+49 minutes'), datetime(datetime(date('now','localtime','-29 days'), '+12 hours', '+49 minutes'), '+1632 seconds'), 20.4, 1.24, 4.00, 29.30, 'finished', 'paid', datetime(datetime(date('now','localtime','-29 days'), '+12 hours', '+49 minutes'), '+1632 seconds')
FROM users u WHERE u.username='presentation_user_29'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0004', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 1),
       datetime(date('now','localtime','-29 days'), '+15 hours', '+02 minutes'), datetime(datetime(date('now','localtime','-29 days'), '+15 hours', '+02 minutes'), '+3225 seconds'), 21.5, 1.12, 5.00, 29.08, 'finished', 'paid', datetime(datetime(date('now','localtime','-29 days'), '+15 hours', '+02 minutes'), '+3225 seconds')
FROM users u WHERE u.username='presentation_user_36'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0005', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 6),
       datetime(date('now','localtime','-29 days'), '+18 hours', '+15 minutes'), datetime(datetime(date('now','localtime','-29 days'), '+18 hours', '+15 minutes'), '+2625 seconds'), 22.6, 1.39, 2.00, 33.41, 'finished', 'paid', datetime(datetime(date('now','localtime','-29 days'), '+18 hours', '+15 minutes'), '+2625 seconds')
FROM users u WHERE u.username='presentation_user_03'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0006', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 11),
       datetime(date('now','localtime','-29 days'), '+21 hours', '+28 minutes'), datetime(datetime(date('now','localtime','-29 days'), '+21 hours', '+28 minutes'), '+2245 seconds'), 23.7, 1.20, 3.00, 31.44, 'finished', 'paid', datetime(datetime(date('now','localtime','-29 days'), '+21 hours', '+28 minutes'), '+2245 seconds')
FROM users u WHERE u.username='presentation_user_10'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0007', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 4),
       datetime(date('now','localtime','-29 days'), '+09 hours', '+41 minutes'), datetime(datetime(date('now','localtime','-29 days'), '+09 hours', '+41 minutes'), '+1984 seconds'), 24.8, 1.47, 4.00, 40.46, 'finished', 'paid', datetime(datetime(date('now','localtime','-29 days'), '+09 hours', '+41 minutes'), '+1984 seconds')
FROM users u WHERE u.username='presentation_user_17'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0008', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 9),
       datetime(date('now','localtime','-29 days'), '+12 hours', '+54 minutes'), datetime(datetime(date('now','localtime','-29 days'), '+12 hours', '+54 minutes'), '+3885 seconds'), 25.9, 1.12, 5.00, 34.01, 'finished', 'paid', datetime(datetime(date('now','localtime','-29 days'), '+12 hours', '+54 minutes'), '+3885 seconds')
FROM users u WHERE u.username='presentation_user_24'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0009', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 2),
       datetime(date('now','localtime','-29 days'), '+15 hours', '+07 minutes'), datetime(datetime(date('now','localtime','-29 days'), '+15 hours', '+07 minutes'), '+3135 seconds'), 27.0, 1.16, 2.00, 33.32, 'finished', 'paid', datetime(datetime(date('now','localtime','-29 days'), '+15 hours', '+07 minutes'), '+3135 seconds')
FROM users u WHERE u.username='presentation_user_31'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0010', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 7),
       datetime(date('now','localtime','-29 days'), '+18 hours', '+20 minutes'), datetime(datetime(date('now','localtime','-29 days'), '+18 hours', '+20 minutes'), '+2662 seconds'), 28.1, 1.43, 3.00, 43.18, 'finished', 'paid', datetime(datetime(date('now','localtime','-29 days'), '+18 hours', '+20 minutes'), '+2662 seconds')
FROM users u WHERE u.username='presentation_user_38'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0011', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 0),
       datetime(date('now','localtime','-29 days'), '+21 hours', '+33 minutes'), datetime(datetime(date('now','localtime','-29 days'), '+21 hours', '+33 minutes'), '+2336 seconds'), 29.2, 1.24, 4.00, 40.21, 'finished', 'paid', datetime(datetime(date('now','localtime','-29 days'), '+21 hours', '+33 minutes'), '+2336 seconds')
FROM users u WHERE u.username='presentation_user_05'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0012', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 4),
       datetime(date('now','localtime','-28 days'), '+20 hours', '+16 minutes'), datetime(datetime(date('now','localtime','-28 days'), '+20 hours', '+16 minutes'), '+4500 seconds'), 30.0, 1.12, 2.00, 35.60, 'finished', 'paid', datetime(datetime(date('now','localtime','-28 days'), '+20 hours', '+16 minutes'), '+4500 seconds')
FROM users u WHERE u.username='presentation_user_09'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0013', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 9),
       datetime(date('now','localtime','-28 days'), '+08 hours', '+29 minutes'), datetime(datetime(date('now','localtime','-28 days'), '+08 hours', '+29 minutes'), '+3612 seconds'), 31.1, 1.39, 3.00, 46.23, 'finished', 'paid', datetime(datetime(date('now','localtime','-28 days'), '+08 hours', '+29 minutes'), '+3612 seconds')
FROM users u WHERE u.username='presentation_user_16'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0014', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 2),
       datetime(date('now','localtime','-28 days'), '+11 hours', '+42 minutes'), datetime(datetime(date('now','localtime','-28 days'), '+11 hours', '+42 minutes'), '+3051 seconds'), 32.2, 1.20, 4.00, 42.64, 'finished', 'paid', datetime(datetime(date('now','localtime','-28 days'), '+11 hours', '+42 minutes'), '+3051 seconds')
FROM users u WHERE u.username='presentation_user_23'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0015', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 7),
       datetime(date('now','localtime','-28 days'), '+14 hours', '+55 minutes'), datetime(datetime(date('now','localtime','-28 days'), '+14 hours', '+55 minutes'), '+2664 seconds'), 33.3, 1.24, 5.00, 46.29, 'finished', 'paid', datetime(datetime(date('now','localtime','-28 days'), '+14 hours', '+55 minutes'), '+2664 seconds')
FROM users u WHERE u.username='presentation_user_30'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0016', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 0),
       datetime(date('now','localtime','-28 days'), '+17 hours', '+08 minutes'), datetime(datetime(date('now','localtime','-28 days'), '+17 hours', '+08 minutes'), '+5160 seconds'), 34.4, 1.35, 2.00, 48.44, 'finished', 'paid', datetime(datetime(date('now','localtime','-28 days'), '+17 hours', '+08 minutes'), '+5160 seconds')
FROM users u WHERE u.username='presentation_user_37'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0017', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 5),
       datetime(date('now','localtime','-28 days'), '+20 hours', '+21 minutes'), datetime(datetime(date('now','localtime','-28 days'), '+20 hours', '+21 minutes'), '+4123 seconds'), 35.5, 1.16, 3.00, 44.18, 'finished', 'paid', datetime(datetime(date('now','localtime','-28 days'), '+20 hours', '+21 minutes'), '+4123 seconds')
FROM users u WHERE u.username='presentation_user_04'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0018', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 10),
       datetime(date('now','localtime','-28 days'), '+08 hours', '+34 minutes'), datetime(datetime(date('now','localtime','-28 days'), '+08 hours', '+34 minutes'), '+3467 seconds'), 36.6, 1.43, 4.00, 56.34, 'finished', 'paid', datetime(datetime(date('now','localtime','-28 days'), '+08 hours', '+34 minutes'), '+3467 seconds')
FROM users u WHERE u.username='presentation_user_11'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0019', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 3),
       datetime(date('now','localtime','-28 days'), '+11 hours', '+47 minutes'), datetime(datetime(date('now','localtime','-28 days'), '+11 hours', '+47 minutes'), '+3016 seconds'), 37.7, 1.24, 5.00, 51.75, 'finished', 'paid', datetime(datetime(date('now','localtime','-28 days'), '+11 hours', '+47 minutes'), '+3016 seconds')
FROM users u WHERE u.username='presentation_user_18'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0020', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 8),
       datetime(date('now','localtime','-28 days'), '+14 hours', '+00 minutes'), datetime(datetime(date('now','localtime','-28 days'), '+14 hours', '+00 minutes'), '+5820 seconds'), 38.8, 1.12, 2.00, 45.46, 'finished', 'paid', datetime(datetime(date('now','localtime','-28 days'), '+14 hours', '+00 minutes'), '+5820 seconds')
FROM users u WHERE u.username='presentation_user_25'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0021', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 1),
       datetime(date('now','localtime','-28 days'), '+17 hours', '+13 minutes'), datetime(datetime(date('now','localtime','-28 days'), '+17 hours', '+13 minutes'), '+4634 seconds'), 39.9, 1.39, 3.00, 58.46, 'finished', 'paid', datetime(datetime(date('now','localtime','-28 days'), '+17 hours', '+13 minutes'), '+4634 seconds')
FROM users u WHERE u.username='presentation_user_32'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0022', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 6),
       datetime(date('now','localtime','-28 days'), '+20 hours', '+26 minutes'), datetime(datetime(date('now','localtime','-28 days'), '+20 hours', '+26 minutes'), '+853 seconds'), 9.0, 1.20, 4.00, 14.80, 'finished', 'paid', datetime(datetime(date('now','localtime','-28 days'), '+20 hours', '+26 minutes'), '+853 seconds')
FROM users u WHERE u.username='presentation_user_39'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0023', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 11),
       datetime(date('now','localtime','-28 days'), '+08 hours', '+39 minutes'), datetime(datetime(date('now','localtime','-28 days'), '+08 hours', '+39 minutes'), '+808 seconds'), 10.1, 1.47, 5.00, 19.85, 'finished', 'paid', datetime(datetime(date('now','localtime','-28 days'), '+08 hours', '+39 minutes'), '+808 seconds')
FROM users u WHERE u.username='presentation_user_06'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0024', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 3),
       datetime(date('now','localtime','-27 days'), '+19 hours', '+09 minutes'), datetime(datetime(date('now','localtime','-27 days'), '+19 hours', '+09 minutes'), '+1635 seconds'), 10.9, 1.47, 2.00, 18.02, 'finished', 'paid', datetime(datetime(date('now','localtime','-27 days'), '+19 hours', '+09 minutes'), '+1635 seconds')
FROM users u WHERE u.username='presentation_user_10'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0025', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 8),
       datetime(date('now','localtime','-27 days'), '+07 hours', '+22 minutes'), datetime(datetime(date('now','localtime','-27 days'), '+07 hours', '+22 minutes'), '+1394 seconds'), 12.0, 1.12, 3.00, 16.44, 'finished', 'paid', datetime(datetime(date('now','localtime','-27 days'), '+07 hours', '+22 minutes'), '+1394 seconds')
FROM users u WHERE u.username='presentation_user_17'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0026', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 1),
       datetime(date('now','localtime','-27 days'), '+10 hours', '+35 minutes'), datetime(datetime(date('now','localtime','-27 days'), '+10 hours', '+35 minutes'), '+1241 seconds'), 13.1, 1.16, 4.00, 19.20, 'finished', 'paid', datetime(datetime(date('now','localtime','-27 days'), '+10 hours', '+35 minutes'), '+1241 seconds')
FROM users u WHERE u.username='presentation_user_24'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0027', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 6),
       datetime(date('now','localtime','-27 days'), '+13 hours', '+48 minutes'), datetime(datetime(date('now','localtime','-27 days'), '+13 hours', '+48 minutes'), '+1136 seconds'), 14.2, 1.20, 5.00, 22.04, 'finished', 'paid', datetime(datetime(date('now','localtime','-27 days'), '+13 hours', '+48 minutes'), '+1136 seconds')
FROM users u WHERE u.username='presentation_user_31'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0028', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 11),
       datetime(date('now','localtime','-27 days'), '+16 hours', '+01 minutes'), datetime(datetime(date('now','localtime','-27 days'), '+16 hours', '+01 minutes'), '+2295 seconds'), 15.3, 1.24, 2.00, 20.97, 'finished', 'paid', datetime(datetime(date('now','localtime','-27 days'), '+16 hours', '+01 minutes'), '+2295 seconds')
FROM users u WHERE u.username='presentation_user_38'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0029', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 4),
       datetime(date('now','localtime','-27 days'), '+19 hours', '+14 minutes'), datetime(datetime(date('now','localtime','-27 days'), '+19 hours', '+14 minutes'), '+1905 seconds'), 16.4, 1.35, 3.00, 25.14, 'finished', 'paid', datetime(datetime(date('now','localtime','-27 days'), '+19 hours', '+14 minutes'), '+1905 seconds')
FROM users u WHERE u.username='presentation_user_05'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0030', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 9),
       datetime(date('now','localtime','-27 days'), '+07 hours', '+27 minutes'), datetime(datetime(date('now','localtime','-27 days'), '+07 hours', '+27 minutes'), '+1658 seconds'), 17.5, 1.16, 4.00, 24.30, 'finished', 'paid', datetime(datetime(date('now','localtime','-27 days'), '+07 hours', '+27 minutes'), '+1658 seconds')
FROM users u WHERE u.username='presentation_user_12'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0031', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 2),
       datetime(date('now','localtime','-27 days'), '+10 hours', '+40 minutes'), datetime(datetime(date('now','localtime','-27 days'), '+10 hours', '+40 minutes'), '+1488 seconds'), 18.6, 1.20, 5.00, 27.32, 'finished', 'paid', datetime(datetime(date('now','localtime','-27 days'), '+10 hours', '+40 minutes'), '+1488 seconds')
FROM users u WHERE u.username='presentation_user_19'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0032', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 7),
       datetime(date('now','localtime','-27 days'), '+13 hours', '+53 minutes'), datetime(datetime(date('now','localtime','-27 days'), '+13 hours', '+53 minutes'), '+2955 seconds'), 19.7, 1.24, 2.00, 26.43, 'finished', 'paid', datetime(datetime(date('now','localtime','-27 days'), '+13 hours', '+53 minutes'), '+2955 seconds')
FROM users u WHERE u.username='presentation_user_26'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0033', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 0),
       datetime(date('now','localtime','-27 days'), '+16 hours', '+06 minutes'), datetime(datetime(date('now','localtime','-27 days'), '+16 hours', '+06 minutes'), '+2415 seconds'), 20.8, 1.12, 3.00, 26.30, 'finished', 'paid', datetime(datetime(date('now','localtime','-27 days'), '+16 hours', '+06 minutes'), '+2415 seconds')
FROM users u WHERE u.username='presentation_user_33'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0034', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 5),
       datetime(date('now','localtime','-27 days'), '+19 hours', '+19 minutes'), datetime(datetime(date('now','localtime','-27 days'), '+19 hours', '+19 minutes'), '+2075 seconds'), 21.9, 1.39, 4.00, 34.44, 'finished', 'paid', datetime(datetime(date('now','localtime','-27 days'), '+19 hours', '+19 minutes'), '+2075 seconds')
FROM users u WHERE u.username='presentation_user_40'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0035', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 10),
       datetime(date('now','localtime','-27 days'), '+07 hours', '+32 minutes'), datetime(datetime(date('now','localtime','-27 days'), '+07 hours', '+32 minutes'), '+1840 seconds'), 23.0, 1.20, 5.00, 32.60, 'finished', 'paid', datetime(datetime(date('now','localtime','-27 days'), '+07 hours', '+32 minutes'), '+1840 seconds')
FROM users u WHERE u.username='presentation_user_07'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0036', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 3),
       datetime(date('now','localtime','-27 days'), '+10 hours', '+45 minutes'), datetime(datetime(date('now','localtime','-27 days'), '+10 hours', '+45 minutes'), '+3615 seconds'), 24.1, 1.24, 2.00, 31.88, 'finished', 'paid', datetime(datetime(date('now','localtime','-27 days'), '+10 hours', '+45 minutes'), '+3615 seconds')
FROM users u WHERE u.username='presentation_user_14'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0037', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 8),
       datetime(date('now','localtime','-27 days'), '+13 hours', '+58 minutes'), datetime(datetime(date('now','localtime','-27 days'), '+13 hours', '+58 minutes'), '+2926 seconds'), 25.2, 1.12, 3.00, 31.22, 'finished', 'paid', datetime(datetime(date('now','localtime','-27 days'), '+13 hours', '+58 minutes'), '+2926 seconds')
FROM users u WHERE u.username='presentation_user_21'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0038', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 1),
       datetime(date('now','localtime','-27 days'), '+16 hours', '+11 minutes'), datetime(datetime(date('now','localtime','-27 days'), '+16 hours', '+11 minutes'), '+2492 seconds'), 26.3, 1.16, 4.00, 34.51, 'finished', 'paid', datetime(datetime(date('now','localtime','-27 days'), '+16 hours', '+11 minutes'), '+2492 seconds')
FROM users u WHERE u.username='presentation_user_28'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0039', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 6),
       datetime(date('now','localtime','-27 days'), '+19 hours', '+24 minutes'), datetime(datetime(date('now','localtime','-27 days'), '+19 hours', '+24 minutes'), '+2192 seconds'), 27.4, 1.43, 5.00, 44.18, 'finished', 'paid', datetime(datetime(date('now','localtime','-27 days'), '+19 hours', '+24 minutes'), '+2192 seconds')
FROM users u WHERE u.username='presentation_user_35'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0040', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 10),
       datetime(date('now','localtime','-26 days'), '+18 hours', '+02 minutes'), datetime(datetime(date('now','localtime','-26 days'), '+18 hours', '+02 minutes'), '+4230 seconds'), 28.2, 1.43, 2.00, 42.33, 'finished', 'paid', datetime(datetime(date('now','localtime','-26 days'), '+18 hours', '+02 minutes'), '+4230 seconds')
FROM users u WHERE u.username='presentation_user_39'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0041', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 3),
       datetime(date('now','localtime','-26 days'), '+21 hours', '+15 minutes'), datetime(datetime(date('now','localtime','-26 days'), '+21 hours', '+15 minutes'), '+3403 seconds'), 29.3, 1.24, 3.00, 39.33, 'finished', 'paid', datetime(datetime(date('now','localtime','-26 days'), '+21 hours', '+15 minutes'), '+3403 seconds')
FROM users u WHERE u.username='presentation_user_06'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0042', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 8),
       datetime(date('now','localtime','-26 days'), '+09 hours', '+28 minutes'), datetime(datetime(date('now','localtime','-26 days'), '+09 hours', '+28 minutes'), '+2880 seconds'), 30.4, 1.35, 4.00, 45.04, 'finished', 'paid', datetime(datetime(date('now','localtime','-26 days'), '+09 hours', '+28 minutes'), '+2880 seconds')
FROM users u WHERE u.username='presentation_user_13'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0043', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 1),
       datetime(date('now','localtime','-26 days'), '+12 hours', '+41 minutes'), datetime(datetime(date('now','localtime','-26 days'), '+12 hours', '+41 minutes'), '+2520 seconds'), 31.5, 1.16, 5.00, 41.54, 'finished', 'paid', datetime(datetime(date('now','localtime','-26 days'), '+12 hours', '+41 minutes'), '+2520 seconds')
FROM users u WHERE u.username='presentation_user_20'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0044', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 6),
       datetime(date('now','localtime','-26 days'), '+15 hours', '+54 minutes'), datetime(datetime(date('now','localtime','-26 days'), '+15 hours', '+54 minutes'), '+4890 seconds'), 32.6, 1.20, 2.00, 41.12, 'finished', 'paid', datetime(datetime(date('now','localtime','-26 days'), '+15 hours', '+54 minutes'), '+4890 seconds')
FROM users u WHERE u.username='presentation_user_27'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0045', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 11),
       datetime(date('now','localtime','-26 days'), '+18 hours', '+07 minutes'), datetime(datetime(date('now','localtime','-26 days'), '+18 hours', '+07 minutes'), '+3914 seconds'), 33.7, 1.47, 3.00, 52.54, 'finished', 'paid', datetime(datetime(date('now','localtime','-26 days'), '+18 hours', '+07 minutes'), '+3914 seconds')
FROM users u WHERE u.username='presentation_user_34'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0046', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 4),
       datetime(date('now','localtime','-26 days'), '+21 hours', '+20 minutes'), datetime(datetime(date('now','localtime','-26 days'), '+21 hours', '+20 minutes'), '+3297 seconds'), 34.8, 1.12, 4.00, 42.98, 'finished', 'paid', datetime(datetime(date('now','localtime','-26 days'), '+21 hours', '+20 minutes'), '+3297 seconds')
FROM users u WHERE u.username='presentation_user_01'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0047', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 9),
       datetime(date('now','localtime','-26 days'), '+09 hours', '+33 minutes'), datetime(datetime(date('now','localtime','-26 days'), '+09 hours', '+33 minutes'), '+2872 seconds'), 35.9, 1.39, 5.00, 54.90, 'finished', 'paid', datetime(datetime(date('now','localtime','-26 days'), '+09 hours', '+33 minutes'), '+2872 seconds')
FROM users u WHERE u.username='presentation_user_08'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0048', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 2),
       datetime(date('now','localtime','-26 days'), '+12 hours', '+46 minutes'), datetime(datetime(date('now','localtime','-26 days'), '+12 hours', '+46 minutes'), '+5550 seconds'), 37.0, 1.20, 2.00, 46.40, 'finished', 'paid', datetime(datetime(date('now','localtime','-26 days'), '+12 hours', '+46 minutes'), '+5550 seconds')
FROM users u WHERE u.username='presentation_user_15'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0049', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 7),
       datetime(date('now','localtime','-26 days'), '+15 hours', '+59 minutes'), datetime(datetime(date('now','localtime','-26 days'), '+15 hours', '+59 minutes'), '+4425 seconds'), 38.1, 1.24, 3.00, 50.24, 'finished', 'paid', datetime(datetime(date('now','localtime','-26 days'), '+15 hours', '+59 minutes'), '+4425 seconds')
FROM users u WHERE u.username='presentation_user_22'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0050', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 0),
       datetime(date('now','localtime','-26 days'), '+18 hours', '+12 minutes'), datetime(datetime(date('now','localtime','-26 days'), '+18 hours', '+12 minutes'), '+3714 seconds'), 39.2, 1.35, 4.00, 56.92, 'finished', 'paid', datetime(datetime(date('now','localtime','-26 days'), '+18 hours', '+12 minutes'), '+3714 seconds')
FROM users u WHERE u.username='presentation_user_29'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0051', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 5),
       datetime(date('now','localtime','-26 days'), '+21 hours', '+25 minutes'), datetime(datetime(date('now','localtime','-26 days'), '+21 hours', '+25 minutes'), '+3224 seconds'), 40.3, 1.16, 5.00, 51.75, 'finished', 'paid', datetime(datetime(date('now','localtime','-26 days'), '+21 hours', '+25 minutes'), '+3224 seconds')
FROM users u WHERE u.username='presentation_user_36'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0052', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 10),
       datetime(date('now','localtime','-26 days'), '+09 hours', '+38 minutes'), datetime(datetime(date('now','localtime','-26 days'), '+09 hours', '+38 minutes'), '+1410 seconds'), 9.4, 1.43, 2.00, 15.44, 'finished', 'paid', datetime(datetime(date('now','localtime','-26 days'), '+09 hours', '+38 minutes'), '+1410 seconds')
FROM users u WHERE u.username='presentation_user_03'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0053', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 2),
       datetime(date('now','localtime','-25 days'), '+17 hours', '+55 minutes'), datetime(datetime(date('now','localtime','-25 days'), '+17 hours', '+55 minutes'), '+1185 seconds'), 10.2, 1.39, 2.00, 16.18, 'finished', 'paid', datetime(datetime(date('now','localtime','-25 days'), '+17 hours', '+55 minutes'), '+1185 seconds')
FROM users u WHERE u.username='presentation_user_07'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0054', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 7),
       datetime(date('now','localtime','-25 days'), '+20 hours', '+08 minutes'), datetime(datetime(date('now','localtime','-25 days'), '+20 hours', '+08 minutes'), '+1071 seconds'), 11.3, 1.20, 3.00, 16.56, 'finished', 'paid', datetime(datetime(date('now','localtime','-25 days'), '+20 hours', '+08 minutes'), '+1071 seconds')
FROM users u WHERE u.username='presentation_user_14'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0055', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 0),
       datetime(date('now','localtime','-25 days'), '+08 hours', '+21 minutes'), datetime(datetime(date('now','localtime','-25 days'), '+08 hours', '+21 minutes'), '+992 seconds'), 12.4, 1.47, 4.00, 22.23, 'finished', 'paid', datetime(datetime(date('now','localtime','-25 days'), '+08 hours', '+21 minutes'), '+992 seconds')
FROM users u WHERE u.username='presentation_user_21'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0056', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 5),
       datetime(date('now','localtime','-25 days'), '+11 hours', '+34 minutes'), datetime(datetime(date('now','localtime','-25 days'), '+11 hours', '+34 minutes'), '+2025 seconds'), 13.5, 1.12, 5.00, 20.12, 'finished', 'paid', datetime(datetime(date('now','localtime','-25 days'), '+11 hours', '+34 minutes'), '+2025 seconds')
FROM users u WHERE u.username='presentation_user_28'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0057', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 10),
       datetime(date('now','localtime','-25 days'), '+14 hours', '+47 minutes'), datetime(datetime(date('now','localtime','-25 days'), '+14 hours', '+47 minutes'), '+1695 seconds'), 14.6, 1.16, 2.00, 18.94, 'finished', 'paid', datetime(datetime(date('now','localtime','-25 days'), '+14 hours', '+47 minutes'), '+1695 seconds')
FROM users u WHERE u.username='presentation_user_35'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0058', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 3),
       datetime(date('now','localtime','-25 days'), '+17 hours', '+00 minutes'), datetime(datetime(date('now','localtime','-25 days'), '+17 hours', '+00 minutes'), '+1487 seconds'), 15.7, 1.43, 3.00, 25.45, 'finished', 'paid', datetime(datetime(date('now','localtime','-25 days'), '+17 hours', '+00 minutes'), '+1487 seconds')
FROM users u WHERE u.username='presentation_user_02'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0059', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 8),
       datetime(date('now','localtime','-25 days'), '+20 hours', '+13 minutes'), datetime(datetime(date('now','localtime','-25 days'), '+20 hours', '+13 minutes'), '+1344 seconds'), 16.8, 1.24, 4.00, 24.83, 'finished', 'paid', datetime(datetime(date('now','localtime','-25 days'), '+20 hours', '+13 minutes'), '+1344 seconds')
FROM users u WHERE u.username='presentation_user_09'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0060', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 1),
       datetime(date('now','localtime','-25 days'), '+08 hours', '+26 minutes'), datetime(datetime(date('now','localtime','-25 days'), '+08 hours', '+26 minutes'), '+2685 seconds'), 17.9, 1.35, 5.00, 29.16, 'finished', 'paid', datetime(datetime(date('now','localtime','-25 days'), '+08 hours', '+26 minutes'), '+2685 seconds')
FROM users u WHERE u.username='presentation_user_16'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0061', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 6),
       datetime(date('now','localtime','-25 days'), '+11 hours', '+39 minutes'), datetime(datetime(date('now','localtime','-25 days'), '+11 hours', '+39 minutes'), '+2206 seconds'), 19.0, 1.16, 2.00, 24.04, 'finished', 'paid', datetime(datetime(date('now','localtime','-25 days'), '+11 hours', '+39 minutes'), '+2206 seconds')
FROM users u WHERE u.username='presentation_user_23'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0062', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 11),
       datetime(date('now','localtime','-25 days'), '+14 hours', '+52 minutes'), datetime(datetime(date('now','localtime','-25 days'), '+14 hours', '+52 minutes'), '+1904 seconds'), 20.1, 1.20, 3.00, 27.12, 'finished', 'paid', datetime(datetime(date('now','localtime','-25 days'), '+14 hours', '+52 minutes'), '+1904 seconds')
FROM users u WHERE u.username='presentation_user_30'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0063', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 4),
       datetime(date('now','localtime','-25 days'), '+17 hours', '+05 minutes'), datetime(datetime(date('now','localtime','-25 days'), '+17 hours', '+05 minutes'), '+1696 seconds'), 21.2, 1.47, 4.00, 35.16, 'finished', 'paid', datetime(datetime(date('now','localtime','-25 days'), '+17 hours', '+05 minutes'), '+1696 seconds')
FROM users u WHERE u.username='presentation_user_37'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0064', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 9),
       datetime(date('now','localtime','-25 days'), '+20 hours', '+18 minutes'), datetime(datetime(date('now','localtime','-25 days'), '+20 hours', '+18 minutes'), '+3345 seconds'), 22.3, 1.12, 5.00, 29.98, 'finished', 'paid', datetime(datetime(date('now','localtime','-25 days'), '+20 hours', '+18 minutes'), '+3345 seconds')
FROM users u WHERE u.username='presentation_user_04'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0065', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 2),
       datetime(date('now','localtime','-25 days'), '+08 hours', '+31 minutes'), datetime(datetime(date('now','localtime','-25 days'), '+08 hours', '+31 minutes'), '+2717 seconds'), 23.4, 1.39, 2.00, 34.53, 'finished', 'paid', datetime(datetime(date('now','localtime','-25 days'), '+08 hours', '+31 minutes'), '+2717 seconds')
FROM users u WHERE u.username='presentation_user_11'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0066', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 7),
       datetime(date('now','localtime','-25 days'), '+11 hours', '+44 minutes'), datetime(datetime(date('now','localtime','-25 days'), '+11 hours', '+44 minutes'), '+2321 seconds'), 24.5, 1.20, 3.00, 32.40, 'finished', 'paid', datetime(datetime(date('now','localtime','-25 days'), '+11 hours', '+44 minutes'), '+2321 seconds')
FROM users u WHERE u.username='presentation_user_18'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0067', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 0),
       datetime(date('now','localtime','-25 days'), '+14 hours', '+57 minutes'), datetime(datetime(date('now','localtime','-25 days'), '+14 hours', '+57 minutes'), '+2048 seconds'), 25.6, 1.24, 4.00, 35.74, 'finished', 'paid', datetime(datetime(date('now','localtime','-25 days'), '+14 hours', '+57 minutes'), '+2048 seconds')
FROM users u WHERE u.username='presentation_user_25'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0068', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 4),
       datetime(date('now','localtime','-24 days'), '+16 hours', '+48 minutes'), datetime(datetime(date('now','localtime','-24 days'), '+16 hours', '+48 minutes'), '+3960 seconds'), 26.4, 1.12, 2.00, 31.57, 'finished', 'paid', datetime(datetime(date('now','localtime','-24 days'), '+16 hours', '+48 minutes'), '+3960 seconds')
FROM users u WHERE u.username='presentation_user_29'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0069', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 9),
       datetime(date('now','localtime','-24 days'), '+19 hours', '+01 minutes'), datetime(datetime(date('now','localtime','-24 days'), '+19 hours', '+01 minutes'), '+3194 seconds'), 27.5, 1.39, 3.00, 41.23, 'finished', 'paid', datetime(datetime(date('now','localtime','-24 days'), '+19 hours', '+01 minutes'), '+3194 seconds')
FROM users u WHERE u.username='presentation_user_36'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0070', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 2),
       datetime(date('now','localtime','-24 days'), '+07 hours', '+14 minutes'), datetime(datetime(date('now','localtime','-24 days'), '+07 hours', '+14 minutes'), '+2709 seconds'), 28.6, 1.20, 4.00, 38.32, 'finished', 'paid', datetime(datetime(date('now','localtime','-24 days'), '+07 hours', '+14 minutes'), '+2709 seconds')
FROM users u WHERE u.username='presentation_user_03'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0071', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 7),
       datetime(date('now','localtime','-24 days'), '+10 hours', '+27 minutes'), datetime(datetime(date('now','localtime','-24 days'), '+10 hours', '+27 minutes'), '+2376 seconds'), 29.7, 1.24, 5.00, 41.83, 'finished', 'paid', datetime(datetime(date('now','localtime','-24 days'), '+10 hours', '+27 minutes'), '+2376 seconds')
FROM users u WHERE u.username='presentation_user_10'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0072', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 0),
       datetime(date('now','localtime','-24 days'), '+13 hours', '+40 minutes'), datetime(datetime(date('now','localtime','-24 days'), '+13 hours', '+40 minutes'), '+4620 seconds'), 30.8, 1.12, 2.00, 36.50, 'finished', 'paid', datetime(datetime(date('now','localtime','-24 days'), '+13 hours', '+40 minutes'), '+4620 seconds')
FROM users u WHERE u.username='presentation_user_17'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0073', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 5),
       datetime(date('now','localtime','-24 days'), '+16 hours', '+53 minutes'), datetime(datetime(date('now','localtime','-24 days'), '+16 hours', '+53 minutes'), '+3705 seconds'), 31.9, 1.16, 3.00, 40.00, 'finished', 'paid', datetime(datetime(date('now','localtime','-24 days'), '+16 hours', '+53 minutes'), '+3705 seconds')
FROM users u WHERE u.username='presentation_user_24'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0074', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 10),
       datetime(date('now','localtime','-24 days'), '+19 hours', '+06 minutes'), datetime(datetime(date('now','localtime','-24 days'), '+19 hours', '+06 minutes'), '+3126 seconds'), 33.0, 1.43, 4.00, 51.19, 'finished', 'paid', datetime(datetime(date('now','localtime','-24 days'), '+19 hours', '+06 minutes'), '+3126 seconds')
FROM users u WHERE u.username='presentation_user_31'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0075', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 3),
       datetime(date('now','localtime','-24 days'), '+07 hours', '+19 minutes'), datetime(datetime(date('now','localtime','-24 days'), '+07 hours', '+19 minutes'), '+2728 seconds'), 34.1, 1.24, 5.00, 47.28, 'finished', 'paid', datetime(datetime(date('now','localtime','-24 days'), '+07 hours', '+19 minutes'), '+2728 seconds')
FROM users u WHERE u.username='presentation_user_38'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0076', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 8),
       datetime(date('now','localtime','-24 days'), '+10 hours', '+32 minutes'), datetime(datetime(date('now','localtime','-24 days'), '+10 hours', '+32 minutes'), '+5280 seconds'), 35.2, 1.12, 2.00, 41.42, 'finished', 'paid', datetime(datetime(date('now','localtime','-24 days'), '+10 hours', '+32 minutes'), '+5280 seconds')
FROM users u WHERE u.username='presentation_user_05'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0077', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 1),
       datetime(date('now','localtime','-24 days'), '+13 hours', '+45 minutes'), datetime(datetime(date('now','localtime','-24 days'), '+13 hours', '+45 minutes'), '+4215 seconds'), 36.3, 1.16, 3.00, 45.11, 'finished', 'paid', datetime(datetime(date('now','localtime','-24 days'), '+13 hours', '+45 minutes'), '+4215 seconds')
FROM users u WHERE u.username='presentation_user_12'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0078', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 6),
       datetime(date('now','localtime','-24 days'), '+16 hours', '+58 minutes'), datetime(datetime(date('now','localtime','-24 days'), '+16 hours', '+58 minutes'), '+3543 seconds'), 37.4, 1.20, 4.00, 48.88, 'finished', 'paid', datetime(datetime(date('now','localtime','-24 days'), '+16 hours', '+58 minutes'), '+3543 seconds')
FROM users u WHERE u.username='presentation_user_19'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0079', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 11),
       datetime(date('now','localtime','-24 days'), '+19 hours', '+11 minutes'), datetime(datetime(date('now','localtime','-24 days'), '+19 hours', '+11 minutes'), '+3080 seconds'), 38.5, 1.47, 5.00, 61.60, 'finished', 'paid', datetime(datetime(date('now','localtime','-24 days'), '+19 hours', '+11 minutes'), '+3080 seconds')
FROM users u WHERE u.username='presentation_user_26'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0080', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 4),
       datetime(date('now','localtime','-24 days'), '+07 hours', '+24 minutes'), datetime(datetime(date('now','localtime','-24 days'), '+07 hours', '+24 minutes'), '+5940 seconds'), 39.6, 1.12, 2.00, 46.35, 'finished', 'paid', datetime(datetime(date('now','localtime','-24 days'), '+07 hours', '+24 minutes'), '+5940 seconds')
FROM users u WHERE u.username='presentation_user_33'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0081', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 9),
       datetime(date('now','localtime','-24 days'), '+10 hours', '+37 minutes'), datetime(datetime(date('now','localtime','-24 days'), '+10 hours', '+37 minutes'), '+1010 seconds'), 8.7, 1.16, 3.00, 13.09, 'finished', 'paid', datetime(datetime(date('now','localtime','-24 days'), '+10 hours', '+37 minutes'), '+1010 seconds')
FROM users u WHERE u.username='presentation_user_40'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0082', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 1),
       datetime(date('now','localtime','-23 days'), '+15 hours', '+41 minutes'), datetime(datetime(date('now','localtime','-23 days'), '+15 hours', '+41 minutes'), '+900 seconds'), 9.5, 1.24, 2.00, 13.78, 'finished', 'paid', datetime(datetime(date('now','localtime','-23 days'), '+15 hours', '+41 minutes'), '+900 seconds')
FROM users u WHERE u.username='presentation_user_04'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0083', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 6),
       datetime(date('now','localtime','-23 days'), '+18 hours', '+54 minutes'), datetime(datetime(date('now','localtime','-23 days'), '+18 hours', '+54 minutes'), '+848 seconds'), 10.6, 1.35, 3.00, 17.31, 'finished', 'paid', datetime(datetime(date('now','localtime','-23 days'), '+18 hours', '+54 minutes'), '+848 seconds')
FROM users u WHERE u.username='presentation_user_11'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0084', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 11),
       datetime(date('now','localtime','-23 days'), '+21 hours', '+07 minutes'), datetime(datetime(date('now','localtime','-23 days'), '+21 hours', '+07 minutes'), '+1755 seconds'), 11.7, 1.16, 4.00, 17.57, 'finished', 'paid', datetime(datetime(date('now','localtime','-23 days'), '+21 hours', '+07 minutes'), '+1755 seconds')
FROM users u WHERE u.username='presentation_user_18'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0085', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 4),
       datetime(date('now','localtime','-23 days'), '+09 hours', '+20 minutes'), datetime(datetime(date('now','localtime','-23 days'), '+09 hours', '+20 minutes'), '+1486 seconds'), 12.8, 1.43, 5.00, 23.30, 'finished', 'paid', datetime(datetime(date('now','localtime','-23 days'), '+09 hours', '+20 minutes'), '+1486 seconds')
FROM users u WHERE u.username='presentation_user_25'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0086', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 9),
       datetime(date('now','localtime','-23 days'), '+12 hours', '+33 minutes'), datetime(datetime(date('now','localtime','-23 days'), '+12 hours', '+33 minutes'), '+1317 seconds'), 13.9, 1.24, 2.00, 19.24, 'finished', 'paid', datetime(datetime(date('now','localtime','-23 days'), '+12 hours', '+33 minutes'), '+1317 seconds')
FROM users u WHERE u.username='presentation_user_32'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0087', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 2),
       datetime(date('now','localtime','-23 days'), '+15 hours', '+46 minutes'), datetime(datetime(date('now','localtime','-23 days'), '+15 hours', '+46 minutes'), '+1200 seconds'), 15.0, 1.12, 3.00, 19.80, 'finished', 'paid', datetime(datetime(date('now','localtime','-23 days'), '+15 hours', '+46 minutes'), '+1200 seconds')
FROM users u WHERE u.username='presentation_user_39'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0088', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 7),
       datetime(date('now','localtime','-23 days'), '+18 hours', '+59 minutes'), datetime(datetime(date('now','localtime','-23 days'), '+18 hours', '+59 minutes'), '+2415 seconds'), 16.1, 1.39, 4.00, 26.38, 'finished', 'paid', datetime(datetime(date('now','localtime','-23 days'), '+18 hours', '+59 minutes'), '+2415 seconds')
FROM users u WHERE u.username='presentation_user_06'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0089', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 0),
       datetime(date('now','localtime','-23 days'), '+21 hours', '+12 minutes'), datetime(datetime(date('now','localtime','-23 days'), '+21 hours', '+12 minutes'), '+1997 seconds'), 17.2, 1.20, 5.00, 25.64, 'finished', 'paid', datetime(datetime(date('now','localtime','-23 days'), '+21 hours', '+12 minutes'), '+1997 seconds')
FROM users u WHERE u.username='presentation_user_13'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0090', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 5),
       datetime(date('now','localtime','-23 days'), '+09 hours', '+25 minutes'), datetime(datetime(date('now','localtime','-23 days'), '+09 hours', '+25 minutes'), '+1734 seconds'), 18.3, 1.47, 2.00, 28.90, 'finished', 'paid', datetime(datetime(date('now','localtime','-23 days'), '+09 hours', '+25 minutes'), '+1734 seconds')
FROM users u WHERE u.username='presentation_user_20'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0091', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 10),
       datetime(date('now','localtime','-23 days'), '+12 hours', '+38 minutes'), datetime(datetime(date('now','localtime','-23 days'), '+12 hours', '+38 minutes'), '+1552 seconds'), 19.4, 1.12, 3.00, 24.73, 'finished', 'paid', datetime(datetime(date('now','localtime','-23 days'), '+12 hours', '+38 minutes'), '+1552 seconds')
FROM users u WHERE u.username='presentation_user_27'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0092', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 3),
       datetime(date('now','localtime','-23 days'), '+15 hours', '+51 minutes'), datetime(datetime(date('now','localtime','-23 days'), '+15 hours', '+51 minutes'), '+3075 seconds'), 20.5, 1.16, 4.00, 27.78, 'finished', 'paid', datetime(datetime(date('now','localtime','-23 days'), '+15 hours', '+51 minutes'), '+3075 seconds')
FROM users u WHERE u.username='presentation_user_34'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0093', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 7),
       datetime(date('now','localtime','-22 days'), '+14 hours', '+34 minutes'), datetime(datetime(date('now','localtime','-22 days'), '+14 hours', '+34 minutes'), '+2474 seconds'), 21.3, 1.20, 2.00, 27.56, 'finished', 'paid', datetime(datetime(date('now','localtime','-22 days'), '+14 hours', '+34 minutes'), '+2474 seconds')
FROM users u WHERE u.username='presentation_user_38'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0094', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 0),
       datetime(date('now','localtime','-22 days'), '+17 hours', '+47 minutes'), datetime(datetime(date('now','localtime','-22 days'), '+17 hours', '+47 minutes'), '+2122 seconds'), 22.4, 1.47, 3.00, 35.93, 'finished', 'paid', datetime(datetime(date('now','localtime','-22 days'), '+17 hours', '+47 minutes'), '+2122 seconds')
FROM users u WHERE u.username='presentation_user_05'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0095', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 5),
       datetime(date('now','localtime','-22 days'), '+20 hours', '+00 minutes'), datetime(datetime(date('now','localtime','-22 days'), '+20 hours', '+00 minutes'), '+1880 seconds'), 23.5, 1.12, 4.00, 30.32, 'finished', 'paid', datetime(datetime(date('now','localtime','-22 days'), '+20 hours', '+00 minutes'), '+1880 seconds')
FROM users u WHERE u.username='presentation_user_12'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0096', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 10),
       datetime(date('now','localtime','-22 days'), '+08 hours', '+13 minutes'), datetime(datetime(date('now','localtime','-22 days'), '+08 hours', '+13 minutes'), '+3690 seconds'), 24.6, 1.39, 5.00, 39.19, 'finished', 'paid', datetime(datetime(date('now','localtime','-22 days'), '+08 hours', '+13 minutes'), '+3690 seconds')
FROM users u WHERE u.username='presentation_user_19'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0097', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 3),
       datetime(date('now','localtime','-22 days'), '+11 hours', '+26 minutes'), datetime(datetime(date('now','localtime','-22 days'), '+11 hours', '+26 minutes'), '+2985 seconds'), 25.7, 1.20, 2.00, 32.84, 'finished', 'paid', datetime(datetime(date('now','localtime','-22 days'), '+11 hours', '+26 minutes'), '+2985 seconds')
FROM users u WHERE u.username='presentation_user_26'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0098', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 8),
       datetime(date('now','localtime','-22 days'), '+14 hours', '+39 minutes'), datetime(datetime(date('now','localtime','-22 days'), '+14 hours', '+39 minutes'), '+2539 seconds'), 26.8, 1.24, 3.00, 36.23, 'finished', 'paid', datetime(datetime(date('now','localtime','-22 days'), '+14 hours', '+39 minutes'), '+2539 seconds')
FROM users u WHERE u.username='presentation_user_33'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0099', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 1),
       datetime(date('now','localtime','-22 days'), '+17 hours', '+52 minutes'), datetime(datetime(date('now','localtime','-22 days'), '+17 hours', '+52 minutes'), '+2232 seconds'), 27.9, 1.35, 4.00, 41.66, 'finished', 'paid', datetime(datetime(date('now','localtime','-22 days'), '+17 hours', '+52 minutes'), '+2232 seconds')
FROM users u WHERE u.username='presentation_user_40'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0100', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 6),
       datetime(date('now','localtime','-22 days'), '+20 hours', '+05 minutes'), datetime(datetime(date('now','localtime','-22 days'), '+20 hours', '+05 minutes'), '+4350 seconds'), 29.0, 1.16, 5.00, 38.64, 'finished', 'paid', datetime(datetime(date('now','localtime','-22 days'), '+20 hours', '+05 minutes'), '+4350 seconds')
FROM users u WHERE u.username='presentation_user_07'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0101', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 11),
       datetime(date('now','localtime','-22 days'), '+08 hours', '+18 minutes'), datetime(datetime(date('now','localtime','-22 days'), '+08 hours', '+18 minutes'), '+3495 seconds'), 30.1, 1.43, 2.00, 45.04, 'finished', 'paid', datetime(datetime(date('now','localtime','-22 days'), '+08 hours', '+18 minutes'), '+3495 seconds')
FROM users u WHERE u.username='presentation_user_14'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0102', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 4),
       datetime(date('now','localtime','-22 days'), '+11 hours', '+31 minutes'), datetime(datetime(date('now','localtime','-22 days'), '+11 hours', '+31 minutes'), '+2956 seconds'), 31.2, 1.24, 3.00, 41.69, 'finished', 'paid', datetime(datetime(date('now','localtime','-22 days'), '+11 hours', '+31 minutes'), '+2956 seconds')
FROM users u WHERE u.username='presentation_user_21'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0103', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 8),
       datetime(date('now','localtime','-21 days'), '+13 hours', '+27 minutes'), datetime(datetime(date('now','localtime','-21 days'), '+13 hours', '+27 minutes'), '+2560 seconds'), 32.0, 1.16, 2.00, 39.12, 'finished', 'paid', datetime(datetime(date('now','localtime','-21 days'), '+13 hours', '+27 minutes'), '+2560 seconds')
FROM users u WHERE u.username='presentation_user_25'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0104', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 1),
       datetime(date('now','localtime','-21 days'), '+16 hours', '+40 minutes'), datetime(datetime(date('now','localtime','-21 days'), '+16 hours', '+40 minutes'), '+4965 seconds'), 33.1, 1.20, 3.00, 42.72, 'finished', 'paid', datetime(datetime(date('now','localtime','-21 days'), '+16 hours', '+40 minutes'), '+4965 seconds')
FROM users u WHERE u.username='presentation_user_32'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0105', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 6),
       datetime(date('now','localtime','-21 days'), '+19 hours', '+53 minutes'), datetime(datetime(date('now','localtime','-21 days'), '+19 hours', '+53 minutes'), '+3972 seconds'), 34.2, 1.47, 4.00, 54.27, 'finished', 'paid', datetime(datetime(date('now','localtime','-21 days'), '+19 hours', '+53 minutes'), '+3972 seconds')
FROM users u WHERE u.username='presentation_user_39'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0106', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 11),
       datetime(date('now','localtime','-21 days'), '+07 hours', '+06 minutes'), datetime(datetime(date('now','localtime','-21 days'), '+07 hours', '+06 minutes'), '+3344 seconds'), 35.3, 1.12, 5.00, 44.54, 'finished', 'paid', datetime(datetime(date('now','localtime','-21 days'), '+07 hours', '+06 minutes'), '+3344 seconds')
FROM users u WHERE u.username='presentation_user_06'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0107', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 4),
       datetime(date('now','localtime','-21 days'), '+10 hours', '+19 minutes'), datetime(datetime(date('now','localtime','-21 days'), '+10 hours', '+19 minutes'), '+2912 seconds'), 36.4, 1.16, 2.00, 44.22, 'finished', 'paid', datetime(datetime(date('now','localtime','-21 days'), '+10 hours', '+19 minutes'), '+2912 seconds')
FROM users u WHERE u.username='presentation_user_13'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0108', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 9),
       datetime(date('now','localtime','-21 days'), '+13 hours', '+32 minutes'), datetime(datetime(date('now','localtime','-21 days'), '+13 hours', '+32 minutes'), '+5625 seconds'), 37.5, 1.20, 3.00, 48.00, 'finished', 'paid', datetime(datetime(date('now','localtime','-21 days'), '+13 hours', '+32 minutes'), '+5625 seconds')
FROM users u WHERE u.username='presentation_user_20'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0109', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 2),
       datetime(date('now','localtime','-21 days'), '+16 hours', '+45 minutes'), datetime(datetime(date('now','localtime','-21 days'), '+16 hours', '+45 minutes'), '+4483 seconds'), 38.6, 1.24, 4.00, 51.86, 'finished', 'paid', datetime(datetime(date('now','localtime','-21 days'), '+16 hours', '+45 minutes'), '+4483 seconds')
FROM users u WHERE u.username='presentation_user_27'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0110', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 7),
       datetime(date('now','localtime','-21 days'), '+19 hours', '+58 minutes'), datetime(datetime(date('now','localtime','-21 days'), '+19 hours', '+58 minutes'), '+3761 seconds'), 39.7, 1.35, 5.00, 58.60, 'finished', 'paid', datetime(datetime(date('now','localtime','-21 days'), '+19 hours', '+58 minutes'), '+3761 seconds')
FROM users u WHERE u.username='presentation_user_34'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0111', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 0),
       datetime(date('now','localtime','-21 days'), '+07 hours', '+11 minutes'), datetime(datetime(date('now','localtime','-21 days'), '+07 hours', '+11 minutes'), '+704 seconds'), 8.8, 1.16, 2.00, 12.21, 'finished', 'paid', datetime(datetime(date('now','localtime','-21 days'), '+07 hours', '+11 minutes'), '+704 seconds')
FROM users u WHERE u.username='presentation_user_01'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0112', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 5),
       datetime(date('now','localtime','-21 days'), '+10 hours', '+24 minutes'), datetime(datetime(date('now','localtime','-21 days'), '+10 hours', '+24 minutes'), '+1485 seconds'), 9.9, 1.20, 3.00, 14.88, 'finished', 'paid', datetime(datetime(date('now','localtime','-21 days'), '+10 hours', '+24 minutes'), '+1485 seconds')
FROM users u WHERE u.username='presentation_user_08'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0113', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 10),
       datetime(date('now','localtime','-21 days'), '+13 hours', '+37 minutes'), datetime(datetime(date('now','localtime','-21 days'), '+13 hours', '+37 minutes'), '+1277 seconds'), 11.0, 1.24, 4.00, 17.64, 'finished', 'paid', datetime(datetime(date('now','localtime','-21 days'), '+13 hours', '+37 minutes'), '+1277 seconds')
FROM users u WHERE u.username='presentation_user_15'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0114', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 3),
       datetime(date('now','localtime','-21 days'), '+16 hours', '+50 minutes'), datetime(datetime(date('now','localtime','-21 days'), '+16 hours', '+50 minutes'), '+1146 seconds'), 12.1, 1.12, 5.00, 18.55, 'finished', 'paid', datetime(datetime(date('now','localtime','-21 days'), '+16 hours', '+50 minutes'), '+1146 seconds')
FROM users u WHERE u.username='presentation_user_22'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0115', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 7),
       datetime(date('now','localtime','-20 days'), '+12 hours', '+20 minutes'), datetime(datetime(date('now','localtime','-20 days'), '+12 hours', '+20 minutes'), '+1032 seconds'), 12.9, 1.12, 2.00, 16.45, 'finished', 'paid', datetime(datetime(date('now','localtime','-20 days'), '+12 hours', '+20 minutes'), '+1032 seconds')
FROM users u WHERE u.username='presentation_user_26'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0116', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 0),
       datetime(date('now','localtime','-20 days'), '+15 hours', '+33 minutes'), datetime(datetime(date('now','localtime','-20 days'), '+15 hours', '+33 minutes'), '+2100 seconds'), 14.0, 1.16, 3.00, 19.24, 'finished', 'paid', datetime(datetime(date('now','localtime','-20 days'), '+15 hours', '+33 minutes'), '+2100 seconds')
FROM users u WHERE u.username='presentation_user_33'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0117', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 5),
       datetime(date('now','localtime','-20 days'), '+18 hours', '+46 minutes'), datetime(datetime(date('now','localtime','-20 days'), '+18 hours', '+46 minutes'), '+1754 seconds'), 15.1, 1.43, 4.00, 25.59, 'finished', 'paid', datetime(datetime(date('now','localtime','-20 days'), '+18 hours', '+46 minutes'), '+1754 seconds')
FROM users u WHERE u.username='presentation_user_40'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0118', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 10),
       datetime(date('now','localtime','-20 days'), '+21 hours', '+59 minutes'), datetime(datetime(date('now','localtime','-20 days'), '+21 hours', '+59 minutes'), '+1535 seconds'), 16.2, 1.24, 5.00, 25.09, 'finished', 'paid', datetime(datetime(date('now','localtime','-20 days'), '+21 hours', '+59 minutes'), '+1535 seconds')
FROM users u WHERE u.username='presentation_user_07'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0119', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 3),
       datetime(date('now','localtime','-20 days'), '+09 hours', '+12 minutes'), datetime(datetime(date('now','localtime','-20 days'), '+09 hours', '+12 minutes'), '+1384 seconds'), 17.3, 1.35, 2.00, 25.36, 'finished', 'paid', datetime(datetime(date('now','localtime','-20 days'), '+09 hours', '+12 minutes'), '+1384 seconds')
FROM users u WHERE u.username='presentation_user_14'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0120', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 8),
       datetime(date('now','localtime','-20 days'), '+12 hours', '+25 minutes'), datetime(datetime(date('now','localtime','-20 days'), '+12 hours', '+25 minutes'), '+2760 seconds'), 18.4, 1.16, 3.00, 24.34, 'finished', 'paid', datetime(datetime(date('now','localtime','-20 days'), '+12 hours', '+25 minutes'), '+2760 seconds')
FROM users u WHERE u.username='presentation_user_21'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0121', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 1),
       datetime(date('now','localtime','-20 days'), '+15 hours', '+38 minutes'), datetime(datetime(date('now','localtime','-20 days'), '+15 hours', '+38 minutes'), '+2265 seconds'), 19.5, 1.20, 4.00, 27.40, 'finished', 'paid', datetime(datetime(date('now','localtime','-20 days'), '+15 hours', '+38 minutes'), '+2265 seconds')
FROM users u WHERE u.username='presentation_user_28'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0122', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 6),
       datetime(date('now','localtime','-20 days'), '+18 hours', '+51 minutes'), datetime(datetime(date('now','localtime','-20 days'), '+18 hours', '+51 minutes'), '+1952 seconds'), 20.6, 1.47, 5.00, 35.28, 'finished', 'paid', datetime(datetime(date('now','localtime','-20 days'), '+18 hours', '+51 minutes'), '+1952 seconds')
FROM users u WHERE u.username='presentation_user_35'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0123', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 11),
       datetime(date('now','localtime','-20 days'), '+21 hours', '+04 minutes'), datetime(datetime(date('now','localtime','-20 days'), '+21 hours', '+04 minutes'), '+1736 seconds'), 21.7, 1.12, 2.00, 26.30, 'finished', 'paid', datetime(datetime(date('now','localtime','-20 days'), '+21 hours', '+04 minutes'), '+1736 seconds')
FROM users u WHERE u.username='presentation_user_02'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0124', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 4),
       datetime(date('now','localtime','-20 days'), '+09 hours', '+17 minutes'), datetime(datetime(date('now','localtime','-20 days'), '+09 hours', '+17 minutes'), '+3420 seconds'), 22.8, 1.39, 3.00, 34.69, 'finished', 'paid', datetime(datetime(date('now','localtime','-20 days'), '+09 hours', '+17 minutes'), '+3420 seconds')
FROM users u WHERE u.username='presentation_user_09'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0125', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 9),
       datetime(date('now','localtime','-20 days'), '+12 hours', '+30 minutes'), datetime(datetime(date('now','localtime','-20 days'), '+12 hours', '+30 minutes'), '+2775 seconds'), 23.9, 1.20, 4.00, 32.68, 'finished', 'paid', datetime(datetime(date('now','localtime','-20 days'), '+12 hours', '+30 minutes'), '+2775 seconds')
FROM users u WHERE u.username='presentation_user_16'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0126', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 2),
       datetime(date('now','localtime','-20 days'), '+15 hours', '+43 minutes'), datetime(datetime(date('now','localtime','-20 days'), '+15 hours', '+43 minutes'), '+2368 seconds'), 25.0, 1.24, 5.00, 36.00, 'finished', 'paid', datetime(datetime(date('now','localtime','-20 days'), '+15 hours', '+43 minutes'), '+2368 seconds')
FROM users u WHERE u.username='presentation_user_23'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0127', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 7),
       datetime(date('now','localtime','-20 days'), '+18 hours', '+56 minutes'), datetime(datetime(date('now','localtime','-20 days'), '+18 hours', '+56 minutes'), '+2088 seconds'), 26.1, 1.35, 2.00, 37.24, 'finished', 'paid', datetime(datetime(date('now','localtime','-20 days'), '+18 hours', '+56 minutes'), '+2088 seconds')
FROM users u WHERE u.username='presentation_user_30'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0128', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 0),
       datetime(date('now','localtime','-20 days'), '+21 hours', '+09 minutes'), datetime(datetime(date('now','localtime','-20 days'), '+21 hours', '+09 minutes'), '+4080 seconds'), 27.2, 1.16, 3.00, 34.55, 'finished', 'paid', datetime(datetime(date('now','localtime','-20 days'), '+21 hours', '+09 minutes'), '+4080 seconds')
FROM users u WHERE u.username='presentation_user_37'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0129', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 5),
       datetime(date('now','localtime','-20 days'), '+09 hours', '+22 minutes'), datetime(datetime(date('now','localtime','-20 days'), '+09 hours', '+22 minutes'), '+3286 seconds'), 28.3, 1.43, 4.00, 44.47, 'finished', 'paid', datetime(datetime(date('now','localtime','-20 days'), '+09 hours', '+22 minutes'), '+3286 seconds')
FROM users u WHERE u.username='presentation_user_04'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0130', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 10),
       datetime(date('now','localtime','-20 days'), '+12 hours', '+35 minutes'), datetime(datetime(date('now','localtime','-20 days'), '+12 hours', '+35 minutes'), '+2785 seconds'), 29.4, 1.24, 5.00, 41.46, 'finished', 'paid', datetime(datetime(date('now','localtime','-20 days'), '+12 hours', '+35 minutes'), '+2785 seconds')
FROM users u WHERE u.username='presentation_user_11'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0131', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 2),
       datetime(date('now','localtime','-19 days'), '+11 hours', '+13 minutes'), datetime(datetime(date('now','localtime','-19 days'), '+11 hours', '+13 minutes'), '+2416 seconds'), 30.2, 1.24, 2.00, 39.45, 'finished', 'paid', datetime(datetime(date('now','localtime','-19 days'), '+11 hours', '+13 minutes'), '+2416 seconds')
FROM users u WHERE u.username='presentation_user_15'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0132', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 7),
       datetime(date('now','localtime','-19 days'), '+14 hours', '+26 minutes'), datetime(datetime(date('now','localtime','-19 days'), '+14 hours', '+26 minutes'), '+4695 seconds'), 31.3, 1.12, 3.00, 38.06, 'finished', 'paid', datetime(datetime(date('now','localtime','-19 days'), '+14 hours', '+26 minutes'), '+4695 seconds')
FROM users u WHERE u.username='presentation_user_22'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0133', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 0),
       datetime(date('now','localtime','-19 days'), '+17 hours', '+39 minutes'), datetime(datetime(date('now','localtime','-19 days'), '+17 hours', '+39 minutes'), '+3763 seconds'), 32.4, 1.39, 4.00, 49.04, 'finished', 'paid', datetime(datetime(date('now','localtime','-19 days'), '+17 hours', '+39 minutes'), '+3763 seconds')
FROM users u WHERE u.username='presentation_user_29'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0134', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 5),
       datetime(date('now','localtime','-19 days'), '+20 hours', '+52 minutes'), datetime(datetime(date('now','localtime','-19 days'), '+20 hours', '+52 minutes'), '+3174 seconds'), 33.5, 1.20, 5.00, 45.20, 'finished', 'paid', datetime(datetime(date('now','localtime','-19 days'), '+20 hours', '+52 minutes'), '+3174 seconds')
FROM users u WHERE u.username='presentation_user_36'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0135', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 10),
       datetime(date('now','localtime','-19 days'), '+08 hours', '+05 minutes'), datetime(datetime(date('now','localtime','-19 days'), '+08 hours', '+05 minutes'), '+2768 seconds'), 34.6, 1.47, 2.00, 52.86, 'finished', 'paid', datetime(datetime(date('now','localtime','-19 days'), '+08 hours', '+05 minutes'), '+2768 seconds')
FROM users u WHERE u.username='presentation_user_03'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0136', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 3),
       datetime(date('now','localtime','-19 days'), '+11 hours', '+18 minutes'), datetime(datetime(date('now','localtime','-19 days'), '+11 hours', '+18 minutes'), '+5355 seconds'), 35.7, 1.12, 3.00, 42.98, 'finished', 'paid', datetime(datetime(date('now','localtime','-19 days'), '+11 hours', '+18 minutes'), '+5355 seconds')
FROM users u WHERE u.username='presentation_user_10'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0137', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 8),
       datetime(date('now','localtime','-19 days'), '+14 hours', '+31 minutes'), datetime(datetime(date('now','localtime','-19 days'), '+14 hours', '+31 minutes'), '+4274 seconds'), 36.8, 1.16, 4.00, 46.69, 'finished', 'paid', datetime(datetime(date('now','localtime','-19 days'), '+14 hours', '+31 minutes'), '+4274 seconds')
FROM users u WHERE u.username='presentation_user_17'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0138', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 1),
       datetime(date('now','localtime','-19 days'), '+17 hours', '+44 minutes'), datetime(datetime(date('now','localtime','-19 days'), '+17 hours', '+44 minutes'), '+3591 seconds'), 37.9, 1.43, 5.00, 59.20, 'finished', 'paid', datetime(datetime(date('now','localtime','-19 days'), '+17 hours', '+44 minutes'), '+3591 seconds')
FROM users u WHERE u.username='presentation_user_24'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0139', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 6),
       datetime(date('now','localtime','-19 days'), '+20 hours', '+57 minutes'), datetime(datetime(date('now','localtime','-19 days'), '+20 hours', '+57 minutes'), '+3120 seconds'), 39.0, 1.24, 2.00, 50.36, 'finished', 'paid', datetime(datetime(date('now','localtime','-19 days'), '+20 hours', '+57 minutes'), '+3120 seconds')
FROM users u WHERE u.username='presentation_user_31'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0140', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 11),
       datetime(date('now','localtime','-19 days'), '+08 hours', '+10 minutes'), datetime(datetime(date('now','localtime','-19 days'), '+08 hours', '+10 minutes'), '+6015 seconds'), 40.1, 1.35, 3.00, 57.14, 'finished', 'paid', datetime(datetime(date('now','localtime','-19 days'), '+08 hours', '+10 minutes'), '+6015 seconds')
FROM users u WHERE u.username='presentation_user_38'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0141', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 4),
       datetime(date('now','localtime','-19 days'), '+11 hours', '+23 minutes'), datetime(datetime(date('now','localtime','-19 days'), '+11 hours', '+23 minutes'), '+1068 seconds'), 9.2, 1.16, 4.00, 14.67, 'finished', 'paid', datetime(datetime(date('now','localtime','-19 days'), '+11 hours', '+23 minutes'), '+1068 seconds')
FROM users u WHERE u.username='presentation_user_05'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0142', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 9),
       datetime(date('now','localtime','-19 days'), '+14 hours', '+36 minutes'), datetime(datetime(date('now','localtime','-19 days'), '+14 hours', '+36 minutes'), '+976 seconds'), 10.3, 1.20, 5.00, 17.36, 'finished', 'paid', datetime(datetime(date('now','localtime','-19 days'), '+14 hours', '+36 minutes'), '+976 seconds')
FROM users u WHERE u.username='presentation_user_12'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0143', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 2),
       datetime(date('now','localtime','-19 days'), '+17 hours', '+49 minutes'), datetime(datetime(date('now','localtime','-19 days'), '+17 hours', '+49 minutes'), '+912 seconds'), 11.4, 1.47, 2.00, 18.76, 'finished', 'paid', datetime(datetime(date('now','localtime','-19 days'), '+17 hours', '+49 minutes'), '+912 seconds')
FROM users u WHERE u.username='presentation_user_19'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0144', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 7),
       datetime(date('now','localtime','-19 days'), '+20 hours', '+02 minutes'), datetime(datetime(date('now','localtime','-19 days'), '+20 hours', '+02 minutes'), '+1875 seconds'), 12.5, 1.12, 3.00, 17.00, 'finished', 'paid', datetime(datetime(date('now','localtime','-19 days'), '+20 hours', '+02 minutes'), '+1875 seconds')
FROM users u WHERE u.username='presentation_user_26'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0145', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 0),
       datetime(date('now','localtime','-19 days'), '+08 hours', '+15 minutes'), datetime(datetime(date('now','localtime','-19 days'), '+08 hours', '+15 minutes'), '+1579 seconds'), 13.6, 1.39, 4.00, 22.90, 'finished', 'paid', datetime(datetime(date('now','localtime','-19 days'), '+08 hours', '+15 minutes'), '+1579 seconds')
FROM users u WHERE u.username='presentation_user_33'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0146', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 4),
       datetime(date('now','localtime','-18 days'), '+10 hours', '+06 minutes'), datetime(datetime(date('now','localtime','-18 days'), '+10 hours', '+06 minutes'), '+1364 seconds'), 14.4, 1.20, 2.00, 19.28, 'finished', 'paid', datetime(datetime(date('now','localtime','-18 days'), '+10 hours', '+06 minutes'), '+1364 seconds')
FROM users u WHERE u.username='presentation_user_37'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0147', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 9),
       datetime(date('now','localtime','-18 days'), '+13 hours', '+19 minutes'), datetime(datetime(date('now','localtime','-18 days'), '+13 hours', '+19 minutes'), '+1240 seconds'), 15.5, 1.24, 3.00, 22.22, 'finished', 'paid', datetime(datetime(date('now','localtime','-18 days'), '+13 hours', '+19 minutes'), '+1240 seconds')
FROM users u WHERE u.username='presentation_user_04'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0148', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 2),
       datetime(date('now','localtime','-18 days'), '+16 hours', '+32 minutes'), datetime(datetime(date('now','localtime','-18 days'), '+16 hours', '+32 minutes'), '+2490 seconds'), 16.6, 1.12, 4.00, 22.59, 'finished', 'paid', datetime(datetime(date('now','localtime','-18 days'), '+16 hours', '+32 minutes'), '+2490 seconds')
FROM users u WHERE u.username='presentation_user_11'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0149', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 7),
       datetime(date('now','localtime','-18 days'), '+19 hours', '+45 minutes'), datetime(datetime(date('now','localtime','-18 days'), '+19 hours', '+45 minutes'), '+2055 seconds'), 17.7, 1.39, 5.00, 29.60, 'finished', 'paid', datetime(datetime(date('now','localtime','-18 days'), '+19 hours', '+45 minutes'), '+2055 seconds')
FROM users u WHERE u.username='presentation_user_18'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0150', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 0),
       datetime(date('now','localtime','-18 days'), '+07 hours', '+58 minutes'), datetime(datetime(date('now','localtime','-18 days'), '+07 hours', '+58 minutes'), '+1781 seconds'), 18.8, 1.20, 2.00, 24.56, 'finished', 'paid', datetime(datetime(date('now','localtime','-18 days'), '+07 hours', '+58 minutes'), '+1781 seconds')
FROM users u WHERE u.username='presentation_user_25'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0151', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 5),
       datetime(date('now','localtime','-18 days'), '+10 hours', '+11 minutes'), datetime(datetime(date('now','localtime','-18 days'), '+10 hours', '+11 minutes'), '+1592 seconds'), 19.9, 1.24, 3.00, 27.68, 'finished', 'paid', datetime(datetime(date('now','localtime','-18 days'), '+10 hours', '+11 minutes'), '+1592 seconds')
FROM users u WHERE u.username='presentation_user_32'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0152', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 10),
       datetime(date('now','localtime','-18 days'), '+13 hours', '+24 minutes'), datetime(datetime(date('now','localtime','-18 days'), '+13 hours', '+24 minutes'), '+3150 seconds'), 21.0, 1.12, 4.00, 27.52, 'finished', 'paid', datetime(datetime(date('now','localtime','-18 days'), '+13 hours', '+24 minutes'), '+3150 seconds')
FROM users u WHERE u.username='presentation_user_39'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0153', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 3),
       datetime(date('now','localtime','-18 days'), '+16 hours', '+37 minutes'), datetime(datetime(date('now','localtime','-18 days'), '+16 hours', '+37 minutes'), '+2566 seconds'), 22.1, 1.16, 5.00, 30.64, 'finished', 'paid', datetime(datetime(date('now','localtime','-18 days'), '+16 hours', '+37 minutes'), '+2566 seconds')
FROM users u WHERE u.username='presentation_user_06'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0154', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 8),
       datetime(date('now','localtime','-18 days'), '+19 hours', '+50 minutes'), datetime(datetime(date('now','localtime','-18 days'), '+19 hours', '+50 minutes'), '+2198 seconds'), 23.2, 1.43, 2.00, 35.18, 'finished', 'paid', datetime(datetime(date('now','localtime','-18 days'), '+19 hours', '+50 minutes'), '+2198 seconds')
FROM users u WHERE u.username='presentation_user_13'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0155', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 1),
       datetime(date('now','localtime','-18 days'), '+07 hours', '+03 minutes'), datetime(datetime(date('now','localtime','-18 days'), '+07 hours', '+03 minutes'), '+1944 seconds'), 24.3, 1.24, 3.00, 33.13, 'finished', 'paid', datetime(datetime(date('now','localtime','-18 days'), '+07 hours', '+03 minutes'), '+1944 seconds')
FROM users u WHERE u.username='presentation_user_20'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0156', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 6),
       datetime(date('now','localtime','-18 days'), '+10 hours', '+16 minutes'), datetime(datetime(date('now','localtime','-18 days'), '+10 hours', '+16 minutes'), '+3810 seconds'), 25.4, 1.12, 4.00, 32.45, 'finished', 'paid', datetime(datetime(date('now','localtime','-18 days'), '+10 hours', '+16 minutes'), '+3810 seconds')
FROM users u WHERE u.username='presentation_user_27'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0157', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 11),
       datetime(date('now','localtime','-18 days'), '+13 hours', '+29 minutes'), datetime(datetime(date('now','localtime','-18 days'), '+13 hours', '+29 minutes'), '+3077 seconds'), 26.5, 1.16, 5.00, 35.74, 'finished', 'paid', datetime(datetime(date('now','localtime','-18 days'), '+13 hours', '+29 minutes'), '+3077 seconds')
FROM users u WHERE u.username='presentation_user_34'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0158', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 4),
       datetime(date('now','localtime','-18 days'), '+16 hours', '+42 minutes'), datetime(datetime(date('now','localtime','-18 days'), '+16 hours', '+42 minutes'), '+2615 seconds'), 27.6, 1.20, 2.00, 35.12, 'finished', 'paid', datetime(datetime(date('now','localtime','-18 days'), '+16 hours', '+42 minutes'), '+2615 seconds')
FROM users u WHERE u.username='presentation_user_01'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0159', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 8),
       datetime(date('now','localtime','-17 days'), '+09 hours', '+59 minutes'), datetime(datetime(date('now','localtime','-17 days'), '+09 hours', '+59 minutes'), '+2272 seconds'), 28.4, 1.39, 2.00, 41.48, 'finished', 'paid', datetime(datetime(date('now','localtime','-17 days'), '+09 hours', '+59 minutes'), '+2272 seconds')
FROM users u WHERE u.username='presentation_user_05'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0160', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 1),
       datetime(date('now','localtime','-17 days'), '+12 hours', '+12 minutes'), datetime(datetime(date('now','localtime','-17 days'), '+12 hours', '+12 minutes'), '+4425 seconds'), 29.5, 1.20, 3.00, 38.40, 'finished', 'paid', datetime(datetime(date('now','localtime','-17 days'), '+12 hours', '+12 minutes'), '+4425 seconds')
FROM users u WHERE u.username='presentation_user_12'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0161', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 6),
       datetime(date('now','localtime','-17 days'), '+15 hours', '+25 minutes'), datetime(datetime(date('now','localtime','-17 days'), '+15 hours', '+25 minutes'), '+3554 seconds'), 30.6, 1.24, 4.00, 41.94, 'finished', 'paid', datetime(datetime(date('now','localtime','-17 days'), '+15 hours', '+25 minutes'), '+3554 seconds')
FROM users u WHERE u.username='presentation_user_19'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0162', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 11),
       datetime(date('now','localtime','-17 days'), '+18 hours', '+38 minutes'), datetime(datetime(date('now','localtime','-17 days'), '+18 hours', '+38 minutes'), '+3003 seconds'), 31.7, 1.35, 5.00, 47.80, 'finished', 'paid', datetime(datetime(date('now','localtime','-17 days'), '+18 hours', '+38 minutes'), '+3003 seconds')
FROM users u WHERE u.username='presentation_user_26'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0163', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 4),
       datetime(date('now','localtime','-17 days'), '+21 hours', '+51 minutes'), datetime(datetime(date('now','localtime','-17 days'), '+21 hours', '+51 minutes'), '+2624 seconds'), 32.8, 1.16, 2.00, 40.05, 'finished', 'paid', datetime(datetime(date('now','localtime','-17 days'), '+21 hours', '+51 minutes'), '+2624 seconds')
FROM users u WHERE u.username='presentation_user_33'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0164', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 9),
       datetime(date('now','localtime','-17 days'), '+09 hours', '+04 minutes'), datetime(datetime(date('now','localtime','-17 days'), '+09 hours', '+04 minutes'), '+5085 seconds'), 33.9, 1.43, 3.00, 51.48, 'finished', 'paid', datetime(datetime(date('now','localtime','-17 days'), '+09 hours', '+04 minutes'), '+5085 seconds')
FROM users u WHERE u.username='presentation_user_40'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0165', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 2),
       datetime(date('now','localtime','-17 days'), '+12 hours', '+17 minutes'), datetime(datetime(date('now','localtime','-17 days'), '+12 hours', '+17 minutes'), '+4065 seconds'), 35.0, 1.24, 4.00, 47.40, 'finished', 'paid', datetime(datetime(date('now','localtime','-17 days'), '+12 hours', '+17 minutes'), '+4065 seconds')
FROM users u WHERE u.username='presentation_user_07'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0166', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 7),
       datetime(date('now','localtime','-17 days'), '+15 hours', '+30 minutes'), datetime(datetime(date('now','localtime','-17 days'), '+15 hours', '+30 minutes'), '+3420 seconds'), 36.1, 1.12, 5.00, 45.43, 'finished', 'paid', datetime(datetime(date('now','localtime','-17 days'), '+15 hours', '+30 minutes'), '+3420 seconds')
FROM users u WHERE u.username='presentation_user_14'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0167', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 0),
       datetime(date('now','localtime','-17 days'), '+18 hours', '+43 minutes'), datetime(datetime(date('now','localtime','-17 days'), '+18 hours', '+43 minutes'), '+2976 seconds'), 37.2, 1.39, 2.00, 53.71, 'finished', 'paid', datetime(datetime(date('now','localtime','-17 days'), '+18 hours', '+43 minutes'), '+2976 seconds')
FROM users u WHERE u.username='presentation_user_21'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0168', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 5),
       datetime(date('now','localtime','-17 days'), '+21 hours', '+56 minutes'), datetime(datetime(date('now','localtime','-17 days'), '+21 hours', '+56 minutes'), '+5745 seconds'), 38.3, 1.20, 3.00, 48.96, 'finished', 'paid', datetime(datetime(date('now','localtime','-17 days'), '+21 hours', '+56 minutes'), '+5745 seconds')
FROM users u WHERE u.username='presentation_user_28'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0169', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 10),
       datetime(date('now','localtime','-17 days'), '+09 hours', '+09 minutes'), datetime(datetime(date('now','localtime','-17 days'), '+09 hours', '+09 minutes'), '+4575 seconds'), 39.4, 1.47, 4.00, 61.92, 'finished', 'paid', datetime(datetime(date('now','localtime','-17 days'), '+09 hours', '+09 minutes'), '+4575 seconds')
FROM users u WHERE u.username='presentation_user_35'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0170', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 3),
       datetime(date('now','localtime','-17 days'), '+12 hours', '+22 minutes'), datetime(datetime(date('now','localtime','-17 days'), '+12 hours', '+22 minutes'), '+805 seconds'), 8.5, 1.12, 5.00, 14.52, 'finished', 'paid', datetime(datetime(date('now','localtime','-17 days'), '+12 hours', '+22 minutes'), '+805 seconds')
FROM users u WHERE u.username='presentation_user_02'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0171', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 8),
       datetime(date('now','localtime','-17 days'), '+15 hours', '+35 minutes'), datetime(datetime(date('now','localtime','-17 days'), '+15 hours', '+35 minutes'), '+768 seconds'), 9.6, 1.16, 2.00, 13.14, 'finished', 'paid', datetime(datetime(date('now','localtime','-17 days'), '+15 hours', '+35 minutes'), '+768 seconds')
FROM users u WHERE u.username='presentation_user_09'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0172', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 1),
       datetime(date('now','localtime','-17 days'), '+18 hours', '+48 minutes'), datetime(datetime(date('now','localtime','-17 days'), '+18 hours', '+48 minutes'), '+1605 seconds'), 10.7, 1.43, 3.00, 18.30, 'finished', 'paid', datetime(datetime(date('now','localtime','-17 days'), '+18 hours', '+48 minutes'), '+1605 seconds')
FROM users u WHERE u.username='presentation_user_16'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0173', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 5),
       datetime(date('now','localtime','-16 days'), '+08 hours', '+52 minutes'), datetime(datetime(date('now','localtime','-16 days'), '+08 hours', '+52 minutes'), '+1335 seconds'), 11.5, 1.35, 2.00, 17.52, 'finished', 'paid', datetime(datetime(date('now','localtime','-16 days'), '+08 hours', '+52 minutes'), '+1335 seconds')
FROM users u WHERE u.username='presentation_user_20'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0174', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 10),
       datetime(date('now','localtime','-16 days'), '+11 hours', '+05 minutes'), datetime(datetime(date('now','localtime','-16 days'), '+11 hours', '+05 minutes'), '+1194 seconds'), 12.6, 1.16, 3.00, 17.62, 'finished', 'paid', datetime(datetime(date('now','localtime','-16 days'), '+11 hours', '+05 minutes'), '+1194 seconds')
FROM users u WHERE u.username='presentation_user_27'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0175', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 3),
       datetime(date('now','localtime','-16 days'), '+14 hours', '+18 minutes'), datetime(datetime(date('now','localtime','-16 days'), '+14 hours', '+18 minutes'), '+1096 seconds'), 13.7, 1.20, 4.00, 20.44, 'finished', 'paid', datetime(datetime(date('now','localtime','-16 days'), '+14 hours', '+18 minutes'), '+1096 seconds')
FROM users u WHERE u.username='presentation_user_34'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0176', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 8),
       datetime(date('now','localtime','-16 days'), '+17 hours', '+31 minutes'), datetime(datetime(date('now','localtime','-16 days'), '+17 hours', '+31 minutes'), '+2220 seconds'), 14.8, 1.47, 5.00, 26.76, 'finished', 'paid', datetime(datetime(date('now','localtime','-16 days'), '+17 hours', '+31 minutes'), '+2220 seconds')
FROM users u WHERE u.username='presentation_user_01'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0177', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 1),
       datetime(date('now','localtime','-16 days'), '+20 hours', '+44 minutes'), datetime(datetime(date('now','localtime','-16 days'), '+20 hours', '+44 minutes'), '+1846 seconds'), 15.9, 1.12, 2.00, 19.81, 'finished', 'paid', datetime(datetime(date('now','localtime','-16 days'), '+20 hours', '+44 minutes'), '+1846 seconds')
FROM users u WHERE u.username='presentation_user_08'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0178', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 6),
       datetime(date('now','localtime','-16 days'), '+08 hours', '+57 minutes'), datetime(datetime(date('now','localtime','-16 days'), '+08 hours', '+57 minutes'), '+1611 seconds'), 17.0, 1.39, 3.00, 26.63, 'finished', 'paid', datetime(datetime(date('now','localtime','-16 days'), '+08 hours', '+57 minutes'), '+1611 seconds')
FROM users u WHERE u.username='presentation_user_15'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0179', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 11),
       datetime(date('now','localtime','-16 days'), '+11 hours', '+10 minutes'), datetime(datetime(date('now','localtime','-16 days'), '+11 hours', '+10 minutes'), '+1448 seconds'), 18.1, 1.20, 4.00, 25.72, 'finished', 'paid', datetime(datetime(date('now','localtime','-16 days'), '+11 hours', '+10 minutes'), '+1448 seconds')
FROM users u WHERE u.username='presentation_user_22'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0180', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 4),
       datetime(date('now','localtime','-16 days'), '+14 hours', '+23 minutes'), datetime(datetime(date('now','localtime','-16 days'), '+14 hours', '+23 minutes'), '+2880 seconds'), 19.2, 1.24, 5.00, 28.81, 'finished', 'paid', datetime(datetime(date('now','localtime','-16 days'), '+14 hours', '+23 minutes'), '+2880 seconds')
FROM users u WHERE u.username='presentation_user_29'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0181', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 9),
       datetime(date('now','localtime','-16 days'), '+17 hours', '+36 minutes'), datetime(datetime(date('now','localtime','-16 days'), '+17 hours', '+36 minutes'), '+2357 seconds'), 20.3, 1.35, 2.00, 29.41, 'finished', 'paid', datetime(datetime(date('now','localtime','-16 days'), '+17 hours', '+36 minutes'), '+2357 seconds')
FROM users u WHERE u.username='presentation_user_36'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0182', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 2),
       datetime(date('now','localtime','-16 days'), '+20 hours', '+49 minutes'), datetime(datetime(date('now','localtime','-16 days'), '+20 hours', '+49 minutes'), '+2027 seconds'), 21.4, 1.16, 3.00, 27.82, 'finished', 'paid', datetime(datetime(date('now','localtime','-16 days'), '+20 hours', '+49 minutes'), '+2027 seconds')
FROM users u WHERE u.username='presentation_user_03'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0183', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 7),
       datetime(date('now','localtime','-16 days'), '+08 hours', '+02 minutes'), datetime(datetime(date('now','localtime','-16 days'), '+08 hours', '+02 minutes'), '+1800 seconds'), 22.5, 1.43, 4.00, 36.18, 'finished', 'paid', datetime(datetime(date('now','localtime','-16 days'), '+08 hours', '+02 minutes'), '+1800 seconds')
FROM users u WHERE u.username='presentation_user_10'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0184', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 0),
       datetime(date('now','localtime','-16 days'), '+11 hours', '+15 minutes'), datetime(datetime(date('now','localtime','-16 days'), '+11 hours', '+15 minutes'), '+3540 seconds'), 23.6, 1.24, 5.00, 34.26, 'finished', 'paid', datetime(datetime(date('now','localtime','-16 days'), '+11 hours', '+15 minutes'), '+3540 seconds')
FROM users u WHERE u.username='presentation_user_17'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0185', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 4),
       datetime(date('now','localtime','-15 days'), '+07 hours', '+45 minutes'), datetime(datetime(date('now','localtime','-15 days'), '+07 hours', '+45 minutes'), '+2834 seconds'), 24.4, 1.24, 2.00, 32.26, 'finished', 'paid', datetime(datetime(date('now','localtime','-15 days'), '+07 hours', '+45 minutes'), '+2834 seconds')
FROM users u WHERE u.username='presentation_user_21'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0186', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 9),
       datetime(date('now','localtime','-15 days'), '+10 hours', '+58 minutes'), datetime(datetime(date('now','localtime','-15 days'), '+10 hours', '+58 minutes'), '+2416 seconds'), 25.5, 1.12, 3.00, 31.56, 'finished', 'paid', datetime(datetime(date('now','localtime','-15 days'), '+10 hours', '+58 minutes'), '+2416 seconds')
FROM users u WHERE u.username='presentation_user_28'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0187', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 2),
       datetime(date('now','localtime','-15 days'), '+13 hours', '+11 minutes'), datetime(datetime(date('now','localtime','-15 days'), '+13 hours', '+11 minutes'), '+2128 seconds'), 26.6, 1.16, 4.00, 34.86, 'finished', 'paid', datetime(datetime(date('now','localtime','-15 days'), '+13 hours', '+11 minutes'), '+2128 seconds')
FROM users u WHERE u.username='presentation_user_35'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0188', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 7),
       datetime(date('now','localtime','-15 days'), '+16 hours', '+24 minutes'), datetime(datetime(date('now','localtime','-15 days'), '+16 hours', '+24 minutes'), '+4155 seconds'), 27.7, 1.20, 5.00, 38.24, 'finished', 'paid', datetime(datetime(date('now','localtime','-15 days'), '+16 hours', '+24 minutes'), '+4155 seconds')
FROM users u WHERE u.username='presentation_user_02'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0189', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 0),
       datetime(date('now','localtime','-15 days'), '+19 hours', '+37 minutes'), datetime(datetime(date('now','localtime','-15 days'), '+19 hours', '+37 minutes'), '+3345 seconds'), 28.8, 1.47, 2.00, 44.34, 'finished', 'paid', datetime(datetime(date('now','localtime','-15 days'), '+19 hours', '+37 minutes'), '+3345 seconds')
FROM users u WHERE u.username='presentation_user_09'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0190', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 5),
       datetime(date('now','localtime','-15 days'), '+07 hours', '+50 minutes'), datetime(datetime(date('now','localtime','-15 days'), '+07 hours', '+50 minutes'), '+2833 seconds'), 29.9, 1.12, 3.00, 36.49, 'finished', 'paid', datetime(datetime(date('now','localtime','-15 days'), '+07 hours', '+50 minutes'), '+2833 seconds')
FROM users u WHERE u.username='presentation_user_16'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0191', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 10),
       datetime(date('now','localtime','-15 days'), '+10 hours', '+03 minutes'), datetime(datetime(date('now','localtime','-15 days'), '+10 hours', '+03 minutes'), '+2480 seconds'), 31.0, 1.16, 4.00, 39.96, 'finished', 'paid', datetime(datetime(date('now','localtime','-15 days'), '+10 hours', '+03 minutes'), '+2480 seconds')
FROM users u WHERE u.username='presentation_user_23'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0192', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 3),
       datetime(date('now','localtime','-15 days'), '+13 hours', '+16 minutes'), datetime(datetime(date('now','localtime','-15 days'), '+13 hours', '+16 minutes'), '+4815 seconds'), 32.1, 1.20, 5.00, 43.52, 'finished', 'paid', datetime(datetime(date('now','localtime','-15 days'), '+13 hours', '+16 minutes'), '+4815 seconds')
FROM users u WHERE u.username='presentation_user_30'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0193', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 8),
       datetime(date('now','localtime','-15 days'), '+16 hours', '+29 minutes'), datetime(datetime(date('now','localtime','-15 days'), '+16 hours', '+29 minutes'), '+3855 seconds'), 33.2, 1.24, 2.00, 43.17, 'finished', 'paid', datetime(datetime(date('now','localtime','-15 days'), '+16 hours', '+29 minutes'), '+3855 seconds')
FROM users u WHERE u.username='presentation_user_37'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0194', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 0),
       datetime(date('now','localtime','-14 days'), '+21 hours', '+38 minutes'), datetime(datetime(date('now','localtime','-14 days'), '+21 hours', '+38 minutes'), '+3221 seconds'), 34.0, 1.20, 2.00, 42.80, 'finished', 'paid', datetime(datetime(date('now','localtime','-14 days'), '+21 hours', '+38 minutes'), '+3221 seconds')
FROM users u WHERE u.username='presentation_user_01'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0195', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 5),
       datetime(date('now','localtime','-14 days'), '+09 hours', '+51 minutes'), datetime(datetime(date('now','localtime','-14 days'), '+09 hours', '+51 minutes'), '+2808 seconds'), 35.1, 1.47, 3.00, 54.60, 'finished', 'paid', datetime(datetime(date('now','localtime','-14 days'), '+09 hours', '+51 minutes'), '+2808 seconds')
FROM users u WHERE u.username='presentation_user_08'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0196', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 10),
       datetime(date('now','localtime','-14 days'), '+12 hours', '+04 minutes'), datetime(datetime(date('now','localtime','-14 days'), '+12 hours', '+04 minutes'), '+5430 seconds'), 36.2, 1.12, 4.00, 44.54, 'finished', 'paid', datetime(datetime(date('now','localtime','-14 days'), '+12 hours', '+04 minutes'), '+5430 seconds')
FROM users u WHERE u.username='presentation_user_15'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0197', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 3),
       datetime(date('now','localtime','-14 days'), '+15 hours', '+17 minutes'), datetime(datetime(date('now','localtime','-14 days'), '+15 hours', '+17 minutes'), '+4332 seconds'), 37.3, 1.16, 5.00, 48.27, 'finished', 'paid', datetime(datetime(date('now','localtime','-14 days'), '+15 hours', '+17 minutes'), '+4332 seconds')
FROM users u WHERE u.username='presentation_user_22'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0198', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 8),
       datetime(date('now','localtime','-14 days'), '+18 hours', '+30 minutes'), datetime(datetime(date('now','localtime','-14 days'), '+18 hours', '+30 minutes'), '+3638 seconds'), 38.4, 1.43, 2.00, 56.91, 'finished', 'paid', datetime(datetime(date('now','localtime','-14 days'), '+18 hours', '+30 minutes'), '+3638 seconds')
FROM users u WHERE u.username='presentation_user_29'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0199', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 1),
       datetime(date('now','localtime','-14 days'), '+21 hours', '+43 minutes'), datetime(datetime(date('now','localtime','-14 days'), '+21 hours', '+43 minutes'), '+3160 seconds'), 39.5, 1.24, 3.00, 51.98, 'finished', 'paid', datetime(datetime(date('now','localtime','-14 days'), '+21 hours', '+43 minutes'), '+3160 seconds')
FROM users u WHERE u.username='presentation_user_36'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0200', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 6),
       datetime(date('now','localtime','-14 days'), '+09 hours', '+56 minutes'), datetime(datetime(date('now','localtime','-14 days'), '+09 hours', '+56 minutes'), '+1290 seconds'), 8.6, 1.35, 4.00, 15.61, 'finished', 'paid', datetime(datetime(date('now','localtime','-14 days'), '+09 hours', '+56 minutes'), '+1290 seconds')
FROM users u WHERE u.username='presentation_user_03'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0201', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 11),
       datetime(date('now','localtime','-14 days'), '+12 hours', '+09 minutes'), datetime(datetime(date('now','localtime','-14 days'), '+12 hours', '+09 minutes'), '+1126 seconds'), 9.7, 1.16, 5.00, 16.25, 'finished', 'paid', datetime(datetime(date('now','localtime','-14 days'), '+12 hours', '+09 minutes'), '+1126 seconds')
FROM users u WHERE u.username='presentation_user_10'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0202', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 4),
       datetime(date('now','localtime','-14 days'), '+15 hours', '+22 minutes'), datetime(datetime(date('now','localtime','-14 days'), '+15 hours', '+22 minutes'), '+1023 seconds'), 10.8, 1.20, 2.00, 14.96, 'finished', 'paid', datetime(datetime(date('now','localtime','-14 days'), '+15 hours', '+22 minutes'), '+1023 seconds')
FROM users u WHERE u.username='presentation_user_17'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0203', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 9),
       datetime(date('now','localtime','-14 days'), '+18 hours', '+35 minutes'), datetime(datetime(date('now','localtime','-14 days'), '+18 hours', '+35 minutes'), '+952 seconds'), 11.9, 1.47, 3.00, 20.49, 'finished', 'paid', datetime(datetime(date('now','localtime','-14 days'), '+18 hours', '+35 minutes'), '+952 seconds')
FROM users u WHERE u.username='presentation_user_24'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0204', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 2),
       datetime(date('now','localtime','-14 days'), '+21 hours', '+48 minutes'), datetime(datetime(date('now','localtime','-14 days'), '+21 hours', '+48 minutes'), '+1950 seconds'), 13.0, 1.12, 4.00, 18.56, 'finished', 'paid', datetime(datetime(date('now','localtime','-14 days'), '+21 hours', '+48 minutes'), '+1950 seconds')
FROM users u WHERE u.username='presentation_user_31'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0205', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 6),
       datetime(date('now','localtime','-13 days'), '+20 hours', '+31 minutes'), datetime(datetime(date('now','localtime','-13 days'), '+20 hours', '+31 minutes'), '+1603 seconds'), 13.8, 1.16, 2.00, 18.01, 'finished', 'paid', datetime(datetime(date('now','localtime','-13 days'), '+20 hours', '+31 minutes'), '+1603 seconds')
FROM users u WHERE u.username='presentation_user_35'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0206', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 11),
       datetime(date('now','localtime','-13 days'), '+08 hours', '+44 minutes'), datetime(datetime(date('now','localtime','-13 days'), '+08 hours', '+44 minutes'), '+1412 seconds'), 14.9, 1.43, 3.00, 24.31, 'finished', 'paid', datetime(datetime(date('now','localtime','-13 days'), '+08 hours', '+44 minutes'), '+1412 seconds')
FROM users u WHERE u.username='presentation_user_02'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0207', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 4),
       datetime(date('now','localtime','-13 days'), '+11 hours', '+57 minutes'), datetime(datetime(date('now','localtime','-13 days'), '+11 hours', '+57 minutes'), '+1280 seconds'), 16.0, 1.24, 4.00, 23.84, 'finished', 'paid', datetime(datetime(date('now','localtime','-13 days'), '+11 hours', '+57 minutes'), '+1280 seconds')
FROM users u WHERE u.username='presentation_user_09'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0208', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 9),
       datetime(date('now','localtime','-13 days'), '+14 hours', '+10 minutes'), datetime(datetime(date('now','localtime','-13 days'), '+14 hours', '+10 minutes'), '+2565 seconds'), 17.1, 1.12, 5.00, 24.15, 'finished', 'paid', datetime(datetime(date('now','localtime','-13 days'), '+14 hours', '+10 minutes'), '+2565 seconds')
FROM users u WHERE u.username='presentation_user_16'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0209', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 2),
       datetime(date('now','localtime','-13 days'), '+17 hours', '+23 minutes'), datetime(datetime(date('now','localtime','-13 days'), '+17 hours', '+23 minutes'), '+2114 seconds'), 18.2, 1.39, 2.00, 27.30, 'finished', 'paid', datetime(datetime(date('now','localtime','-13 days'), '+17 hours', '+23 minutes'), '+2114 seconds')
FROM users u WHERE u.username='presentation_user_23'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0210', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 7),
       datetime(date('now','localtime','-13 days'), '+20 hours', '+36 minutes'), datetime(datetime(date('now','localtime','-13 days'), '+20 hours', '+36 minutes'), '+1828 seconds'), 19.3, 1.20, 3.00, 26.16, 'finished', 'paid', datetime(datetime(date('now','localtime','-13 days'), '+20 hours', '+36 minutes'), '+1828 seconds')
FROM users u WHERE u.username='presentation_user_30'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0211', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 0),
       datetime(date('now','localtime','-13 days'), '+08 hours', '+49 minutes'), datetime(datetime(date('now','localtime','-13 days'), '+08 hours', '+49 minutes'), '+1632 seconds'), 20.4, 1.47, 4.00, 33.99, 'finished', 'paid', datetime(datetime(date('now','localtime','-13 days'), '+08 hours', '+49 minutes'), '+1632 seconds')
FROM users u WHERE u.username='presentation_user_37'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0212', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 5),
       datetime(date('now','localtime','-13 days'), '+11 hours', '+02 minutes'), datetime(datetime(date('now','localtime','-13 days'), '+11 hours', '+02 minutes'), '+3225 seconds'), 21.5, 1.12, 5.00, 29.08, 'finished', 'paid', datetime(datetime(date('now','localtime','-13 days'), '+11 hours', '+02 minutes'), '+3225 seconds')
FROM users u WHERE u.username='presentation_user_04'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0213', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 10),
       datetime(date('now','localtime','-13 days'), '+14 hours', '+15 minutes'), datetime(datetime(date('now','localtime','-13 days'), '+14 hours', '+15 minutes'), '+2625 seconds'), 22.6, 1.16, 2.00, 28.22, 'finished', 'paid', datetime(datetime(date('now','localtime','-13 days'), '+14 hours', '+15 minutes'), '+2625 seconds')
FROM users u WHERE u.username='presentation_user_11'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0214', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 3),
       datetime(date('now','localtime','-13 days'), '+17 hours', '+28 minutes'), datetime(datetime(date('now','localtime','-13 days'), '+17 hours', '+28 minutes'), '+2245 seconds'), 23.7, 1.43, 3.00, 36.89, 'finished', 'paid', datetime(datetime(date('now','localtime','-13 days'), '+17 hours', '+28 minutes'), '+2245 seconds')
FROM users u WHERE u.username='presentation_user_18'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0215', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 8),
       datetime(date('now','localtime','-13 days'), '+20 hours', '+41 minutes'), datetime(datetime(date('now','localtime','-13 days'), '+20 hours', '+41 minutes'), '+1984 seconds'), 24.8, 1.24, 4.00, 34.75, 'finished', 'paid', datetime(datetime(date('now','localtime','-13 days'), '+20 hours', '+41 minutes'), '+1984 seconds')
FROM users u WHERE u.username='presentation_user_25'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0216', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 1),
       datetime(date('now','localtime','-13 days'), '+08 hours', '+54 minutes'), datetime(datetime(date('now','localtime','-13 days'), '+08 hours', '+54 minutes'), '+3885 seconds'), 25.9, 1.35, 5.00, 39.97, 'finished', 'paid', datetime(datetime(date('now','localtime','-13 days'), '+08 hours', '+54 minutes'), '+3885 seconds')
FROM users u WHERE u.username='presentation_user_32'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0217', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 6),
       datetime(date('now','localtime','-13 days'), '+11 hours', '+07 minutes'), datetime(datetime(date('now','localtime','-13 days'), '+11 hours', '+07 minutes'), '+3135 seconds'), 27.0, 1.16, 2.00, 33.32, 'finished', 'paid', datetime(datetime(date('now','localtime','-13 days'), '+11 hours', '+07 minutes'), '+3135 seconds')
FROM users u WHERE u.username='presentation_user_39'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0218', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 11),
       datetime(date('now','localtime','-13 days'), '+14 hours', '+20 minutes'), datetime(datetime(date('now','localtime','-13 days'), '+14 hours', '+20 minutes'), '+2662 seconds'), 28.1, 1.20, 3.00, 36.72, 'finished', 'paid', datetime(datetime(date('now','localtime','-13 days'), '+14 hours', '+20 minutes'), '+2662 seconds')
FROM users u WHERE u.username='presentation_user_06'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0219', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 4),
       datetime(date('now','localtime','-13 days'), '+17 hours', '+33 minutes'), datetime(datetime(date('now','localtime','-13 days'), '+17 hours', '+33 minutes'), '+2336 seconds'), 29.2, 1.47, 4.00, 46.92, 'finished', 'paid', datetime(datetime(date('now','localtime','-13 days'), '+17 hours', '+33 minutes'), '+2336 seconds')
FROM users u WHERE u.username='presentation_user_13'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0220', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 9),
       datetime(date('now','localtime','-13 days'), '+20 hours', '+46 minutes'), datetime(datetime(date('now','localtime','-13 days'), '+20 hours', '+46 minutes'), '+4545 seconds'), 30.3, 1.12, 5.00, 38.94, 'finished', 'paid', datetime(datetime(date('now','localtime','-13 days'), '+20 hours', '+46 minutes'), '+4545 seconds')
FROM users u WHERE u.username='presentation_user_20'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0221', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 1),
       datetime(date('now','localtime','-12 days'), '+19 hours', '+24 minutes'), datetime(datetime(date('now','localtime','-12 days'), '+19 hours', '+24 minutes'), '+3612 seconds'), 31.1, 1.35, 2.00, 43.99, 'finished', 'paid', datetime(datetime(date('now','localtime','-12 days'), '+19 hours', '+24 minutes'), '+3612 seconds')
FROM users u WHERE u.username='presentation_user_24'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0222', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 6),
       datetime(date('now','localtime','-12 days'), '+07 hours', '+37 minutes'), datetime(datetime(date('now','localtime','-12 days'), '+07 hours', '+37 minutes'), '+3051 seconds'), 32.2, 1.16, 3.00, 40.35, 'finished', 'paid', datetime(datetime(date('now','localtime','-12 days'), '+07 hours', '+37 minutes'), '+3051 seconds')
FROM users u WHERE u.username='presentation_user_31'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0223', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 11),
       datetime(date('now','localtime','-12 days'), '+10 hours', '+50 minutes'), datetime(datetime(date('now','localtime','-12 days'), '+10 hours', '+50 minutes'), '+2664 seconds'), 33.3, 1.20, 4.00, 43.96, 'finished', 'paid', datetime(datetime(date('now','localtime','-12 days'), '+10 hours', '+50 minutes'), '+2664 seconds')
FROM users u WHERE u.username='presentation_user_38'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0224', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 4),
       datetime(date('now','localtime','-12 days'), '+13 hours', '+03 minutes'), datetime(datetime(date('now','localtime','-12 days'), '+13 hours', '+03 minutes'), '+5160 seconds'), 34.4, 1.24, 5.00, 47.66, 'finished', 'paid', datetime(datetime(date('now','localtime','-12 days'), '+13 hours', '+03 minutes'), '+5160 seconds')
FROM users u WHERE u.username='presentation_user_05'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0225', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 9),
       datetime(date('now','localtime','-12 days'), '+16 hours', '+16 minutes'), datetime(datetime(date('now','localtime','-12 days'), '+16 hours', '+16 minutes'), '+4123 seconds'), 35.5, 1.12, 2.00, 41.76, 'finished', 'paid', datetime(datetime(date('now','localtime','-12 days'), '+16 hours', '+16 minutes'), '+4123 seconds')
FROM users u WHERE u.username='presentation_user_12'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0226', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 2),
       datetime(date('now','localtime','-12 days'), '+19 hours', '+29 minutes'), datetime(datetime(date('now','localtime','-12 days'), '+19 hours', '+29 minutes'), '+3467 seconds'), 36.6, 1.39, 3.00, 53.87, 'finished', 'paid', datetime(datetime(date('now','localtime','-12 days'), '+19 hours', '+29 minutes'), '+3467 seconds')
FROM users u WHERE u.username='presentation_user_19'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0227', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 7),
       datetime(date('now','localtime','-12 days'), '+07 hours', '+42 minutes'), datetime(datetime(date('now','localtime','-12 days'), '+07 hours', '+42 minutes'), '+3016 seconds'), 37.7, 1.20, 4.00, 49.24, 'finished', 'paid', datetime(datetime(date('now','localtime','-12 days'), '+07 hours', '+42 minutes'), '+3016 seconds')
FROM users u WHERE u.username='presentation_user_26'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0228', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 0),
       datetime(date('now','localtime','-12 days'), '+10 hours', '+55 minutes'), datetime(datetime(date('now','localtime','-12 days'), '+10 hours', '+55 minutes'), '+5820 seconds'), 38.8, 1.24, 5.00, 53.11, 'finished', 'paid', datetime(datetime(date('now','localtime','-12 days'), '+10 hours', '+55 minutes'), '+5820 seconds')
FROM users u WHERE u.username='presentation_user_33'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0229', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 5),
       datetime(date('now','localtime','-12 days'), '+13 hours', '+08 minutes'), datetime(datetime(date('now','localtime','-12 days'), '+13 hours', '+08 minutes'), '+4634 seconds'), 39.9, 1.12, 2.00, 46.69, 'finished', 'paid', datetime(datetime(date('now','localtime','-12 days'), '+13 hours', '+08 minutes'), '+4634 seconds')
FROM users u WHERE u.username='presentation_user_40'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0230', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 10),
       datetime(date('now','localtime','-12 days'), '+16 hours', '+21 minutes'), datetime(datetime(date('now','localtime','-12 days'), '+16 hours', '+21 minutes'), '+853 seconds'), 9.0, 1.16, 3.00, 13.44, 'finished', 'paid', datetime(datetime(date('now','localtime','-12 days'), '+16 hours', '+21 minutes'), '+853 seconds')
FROM users u WHERE u.username='presentation_user_07'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0231', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 3),
       datetime(date('now','localtime','-12 days'), '+19 hours', '+34 minutes'), datetime(datetime(date('now','localtime','-12 days'), '+19 hours', '+34 minutes'), '+808 seconds'), 10.1, 1.43, 4.00, 18.44, 'finished', 'paid', datetime(datetime(date('now','localtime','-12 days'), '+19 hours', '+34 minutes'), '+808 seconds')
FROM users u WHERE u.username='presentation_user_14'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0232', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 8),
       datetime(date('now','localtime','-12 days'), '+07 hours', '+47 minutes'), datetime(datetime(date('now','localtime','-12 days'), '+07 hours', '+47 minutes'), '+1680 seconds'), 11.2, 1.24, 5.00, 18.89, 'finished', 'paid', datetime(datetime(date('now','localtime','-12 days'), '+07 hours', '+47 minutes'), '+1680 seconds')
FROM users u WHERE u.username='presentation_user_21'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0233', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 1),
       datetime(date('now','localtime','-12 days'), '+10 hours', '+00 minutes'), datetime(datetime(date('now','localtime','-12 days'), '+10 hours', '+00 minutes'), '+1428 seconds'), 12.3, 1.12, 2.00, 15.78, 'finished', 'paid', datetime(datetime(date('now','localtime','-12 days'), '+10 hours', '+00 minutes'), '+1428 seconds')
FROM users u WHERE u.username='presentation_user_28'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0234', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 6),
       datetime(date('now','localtime','-12 days'), '+13 hours', '+13 minutes'), datetime(datetime(date('now','localtime','-12 days'), '+13 hours', '+13 minutes'), '+1269 seconds'), 13.4, 1.16, 3.00, 18.54, 'finished', 'paid', datetime(datetime(date('now','localtime','-12 days'), '+13 hours', '+13 minutes'), '+1269 seconds')
FROM users u WHERE u.username='presentation_user_35'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0235', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 11),
       datetime(date('now','localtime','-12 days'), '+16 hours', '+26 minutes'), datetime(datetime(date('now','localtime','-12 days'), '+16 hours', '+26 minutes'), '+1160 seconds'), 14.5, 1.20, 4.00, 21.40, 'finished', 'paid', datetime(datetime(date('now','localtime','-12 days'), '+16 hours', '+26 minutes'), '+1160 seconds')
FROM users u WHERE u.username='presentation_user_02'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0236', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 3),
       datetime(date('now','localtime','-11 days'), '+18 hours', '+17 minutes'), datetime(datetime(date('now','localtime','-11 days'), '+18 hours', '+17 minutes'), '+2295 seconds'), 15.3, 1.47, 2.00, 24.49, 'finished', 'paid', datetime(datetime(date('now','localtime','-11 days'), '+18 hours', '+17 minutes'), '+2295 seconds')
FROM users u WHERE u.username='presentation_user_06'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0237', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 8),
       datetime(date('now','localtime','-11 days'), '+21 hours', '+30 minutes'), datetime(datetime(date('now','localtime','-11 days'), '+21 hours', '+30 minutes'), '+1905 seconds'), 16.4, 1.12, 3.00, 21.37, 'finished', 'paid', datetime(datetime(date('now','localtime','-11 days'), '+21 hours', '+30 minutes'), '+1905 seconds')
FROM users u WHERE u.username='presentation_user_13'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0238', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 1),
       datetime(date('now','localtime','-11 days'), '+09 hours', '+43 minutes'), datetime(datetime(date('now','localtime','-11 days'), '+09 hours', '+43 minutes'), '+1658 seconds'), 17.5, 1.39, 4.00, 28.33, 'finished', 'paid', datetime(datetime(date('now','localtime','-11 days'), '+09 hours', '+43 minutes'), '+1658 seconds')
FROM users u WHERE u.username='presentation_user_20'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0239', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 6),
       datetime(date('now','localtime','-11 days'), '+12 hours', '+56 minutes'), datetime(datetime(date('now','localtime','-11 days'), '+12 hours', '+56 minutes'), '+1488 seconds'), 18.6, 1.20, 5.00, 27.32, 'finished', 'paid', datetime(datetime(date('now','localtime','-11 days'), '+12 hours', '+56 minutes'), '+1488 seconds')
FROM users u WHERE u.username='presentation_user_27'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0240', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 11),
       datetime(date('now','localtime','-11 days'), '+15 hours', '+09 minutes'), datetime(datetime(date('now','localtime','-11 days'), '+15 hours', '+09 minutes'), '+2955 seconds'), 19.7, 1.24, 2.00, 26.43, 'finished', 'paid', datetime(datetime(date('now','localtime','-11 days'), '+15 hours', '+09 minutes'), '+2955 seconds')
FROM users u WHERE u.username='presentation_user_34'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0241', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 4),
       datetime(date('now','localtime','-11 days'), '+18 hours', '+22 minutes'), datetime(datetime(date('now','localtime','-11 days'), '+18 hours', '+22 minutes'), '+2415 seconds'), 20.8, 1.35, 3.00, 31.08, 'finished', 'paid', datetime(datetime(date('now','localtime','-11 days'), '+18 hours', '+22 minutes'), '+2415 seconds')
FROM users u WHERE u.username='presentation_user_01'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0242', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 9),
       datetime(date('now','localtime','-11 days'), '+21 hours', '+35 minutes'), datetime(datetime(date('now','localtime','-11 days'), '+21 hours', '+35 minutes'), '+2075 seconds'), 21.9, 1.16, 4.00, 29.40, 'finished', 'paid', datetime(datetime(date('now','localtime','-11 days'), '+21 hours', '+35 minutes'), '+2075 seconds')
FROM users u WHERE u.username='presentation_user_08'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0243', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 2),
       datetime(date('now','localtime','-11 days'), '+09 hours', '+48 minutes'), datetime(datetime(date('now','localtime','-11 days'), '+09 hours', '+48 minutes'), '+1840 seconds'), 23.0, 1.43, 5.00, 37.89, 'finished', 'paid', datetime(datetime(date('now','localtime','-11 days'), '+09 hours', '+48 minutes'), '+1840 seconds')
FROM users u WHERE u.username='presentation_user_15'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0244', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 7),
       datetime(date('now','localtime','-11 days'), '+12 hours', '+01 minutes'), datetime(datetime(date('now','localtime','-11 days'), '+12 hours', '+01 minutes'), '+3615 seconds'), 24.1, 1.24, 2.00, 31.88, 'finished', 'paid', datetime(datetime(date('now','localtime','-11 days'), '+12 hours', '+01 minutes'), '+3615 seconds')
FROM users u WHERE u.username='presentation_user_22'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0245', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 0),
       datetime(date('now','localtime','-11 days'), '+15 hours', '+14 minutes'), datetime(datetime(date('now','localtime','-11 days'), '+15 hours', '+14 minutes'), '+2926 seconds'), 25.2, 1.12, 3.00, 31.22, 'finished', 'paid', datetime(datetime(date('now','localtime','-11 days'), '+15 hours', '+14 minutes'), '+2926 seconds')
FROM users u WHERE u.username='presentation_user_29'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0246', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 5),
       datetime(date('now','localtime','-11 days'), '+18 hours', '+27 minutes'), datetime(datetime(date('now','localtime','-11 days'), '+18 hours', '+27 minutes'), '+2492 seconds'), 26.3, 1.39, 4.00, 40.56, 'finished', 'paid', datetime(datetime(date('now','localtime','-11 days'), '+18 hours', '+27 minutes'), '+2492 seconds')
FROM users u WHERE u.username='presentation_user_36'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0247', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 10),
       datetime(date('now','localtime','-11 days'), '+21 hours', '+40 minutes'), datetime(datetime(date('now','localtime','-11 days'), '+21 hours', '+40 minutes'), '+2192 seconds'), 27.4, 1.20, 5.00, 37.88, 'finished', 'paid', datetime(datetime(date('now','localtime','-11 days'), '+21 hours', '+40 minutes'), '+2192 seconds')
FROM users u WHERE u.username='presentation_user_03'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0248', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 3),
       datetime(date('now','localtime','-11 days'), '+09 hours', '+53 minutes'), datetime(datetime(date('now','localtime','-11 days'), '+09 hours', '+53 minutes'), '+4275 seconds'), 28.5, 1.47, 2.00, 43.90, 'finished', 'paid', datetime(datetime(date('now','localtime','-11 days'), '+09 hours', '+53 minutes'), '+4275 seconds')
FROM users u WHERE u.username='presentation_user_10'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0249', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 7),
       datetime(date('now','localtime','-10 days'), '+17 hours', '+10 minutes'), datetime(datetime(date('now','localtime','-10 days'), '+17 hours', '+10 minutes'), '+3403 seconds'), 29.3, 1.43, 2.00, 43.90, 'finished', 'paid', datetime(datetime(date('now','localtime','-10 days'), '+17 hours', '+10 minutes'), '+3403 seconds')
FROM users u WHERE u.username='presentation_user_14'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0250', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 0),
       datetime(date('now','localtime','-10 days'), '+20 hours', '+23 minutes'), datetime(datetime(date('now','localtime','-10 days'), '+20 hours', '+23 minutes'), '+2880 seconds'), 30.4, 1.24, 3.00, 40.70, 'finished', 'paid', datetime(datetime(date('now','localtime','-10 days'), '+20 hours', '+23 minutes'), '+2880 seconds')
FROM users u WHERE u.username='presentation_user_21'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0251', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 5),
       datetime(date('now','localtime','-10 days'), '+08 hours', '+36 minutes'), datetime(datetime(date('now','localtime','-10 days'), '+08 hours', '+36 minutes'), '+2520 seconds'), 31.5, 1.35, 4.00, 46.53, 'finished', 'paid', datetime(datetime(date('now','localtime','-10 days'), '+08 hours', '+36 minutes'), '+2520 seconds')
FROM users u WHERE u.username='presentation_user_28'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0252', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 10),
       datetime(date('now','localtime','-10 days'), '+11 hours', '+49 minutes'), datetime(datetime(date('now','localtime','-10 days'), '+11 hours', '+49 minutes'), '+4890 seconds'), 32.6, 1.16, 5.00, 42.82, 'finished', 'paid', datetime(datetime(date('now','localtime','-10 days'), '+11 hours', '+49 minutes'), '+4890 seconds')
FROM users u WHERE u.username='presentation_user_35'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0253', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 3),
       datetime(date('now','localtime','-10 days'), '+14 hours', '+02 minutes'), datetime(datetime(date('now','localtime','-10 days'), '+14 hours', '+02 minutes'), '+3914 seconds'), 33.7, 1.20, 2.00, 42.44, 'finished', 'paid', datetime(datetime(date('now','localtime','-10 days'), '+14 hours', '+02 minutes'), '+3914 seconds')
FROM users u WHERE u.username='presentation_user_02'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0254', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 8),
       datetime(date('now','localtime','-10 days'), '+17 hours', '+15 minutes'), datetime(datetime(date('now','localtime','-10 days'), '+17 hours', '+15 minutes'), '+3297 seconds'), 34.8, 1.47, 3.00, 54.16, 'finished', 'paid', datetime(datetime(date('now','localtime','-10 days'), '+17 hours', '+15 minutes'), '+3297 seconds')
FROM users u WHERE u.username='presentation_user_09'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0255', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 1),
       datetime(date('now','localtime','-10 days'), '+20 hours', '+28 minutes'), datetime(datetime(date('now','localtime','-10 days'), '+20 hours', '+28 minutes'), '+2872 seconds'), 35.9, 1.12, 4.00, 44.21, 'finished', 'paid', datetime(datetime(date('now','localtime','-10 days'), '+20 hours', '+28 minutes'), '+2872 seconds')
FROM users u WHERE u.username='presentation_user_16'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0256', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 6),
       datetime(date('now','localtime','-10 days'), '+08 hours', '+41 minutes'), datetime(datetime(date('now','localtime','-10 days'), '+08 hours', '+41 minutes'), '+5550 seconds'), 37.0, 1.39, 5.00, 56.43, 'finished', 'paid', datetime(datetime(date('now','localtime','-10 days'), '+08 hours', '+41 minutes'), '+5550 seconds')
FROM users u WHERE u.username='presentation_user_23'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0257', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 11),
       datetime(date('now','localtime','-10 days'), '+11 hours', '+54 minutes'), datetime(datetime(date('now','localtime','-10 days'), '+11 hours', '+54 minutes'), '+4425 seconds'), 38.1, 1.20, 2.00, 47.72, 'finished', 'paid', datetime(datetime(date('now','localtime','-10 days'), '+11 hours', '+54 minutes'), '+4425 seconds')
FROM users u WHERE u.username='presentation_user_30'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0258', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 4),
       datetime(date('now','localtime','-10 days'), '+14 hours', '+07 minutes'), datetime(datetime(date('now','localtime','-10 days'), '+14 hours', '+07 minutes'), '+3714 seconds'), 39.2, 1.24, 3.00, 51.61, 'finished', 'paid', datetime(datetime(date('now','localtime','-10 days'), '+14 hours', '+07 minutes'), '+3714 seconds')
FROM users u WHERE u.username='presentation_user_37'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0259', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 9),
       datetime(date('now','localtime','-10 days'), '+17 hours', '+20 minutes'), datetime(datetime(date('now','localtime','-10 days'), '+17 hours', '+20 minutes'), '+3224 seconds'), 40.3, 1.35, 4.00, 58.41, 'finished', 'paid', datetime(datetime(date('now','localtime','-10 days'), '+17 hours', '+20 minutes'), '+3224 seconds')
FROM users u WHERE u.username='presentation_user_04'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0260', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 2),
       datetime(date('now','localtime','-10 days'), '+20 hours', '+33 minutes'), datetime(datetime(date('now','localtime','-10 days'), '+20 hours', '+33 minutes'), '+1410 seconds'), 9.4, 1.16, 5.00, 15.90, 'finished', 'paid', datetime(datetime(date('now','localtime','-10 days'), '+20 hours', '+33 minutes'), '+1410 seconds')
FROM users u WHERE u.username='presentation_user_11'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0261', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 7),
       datetime(date('now','localtime','-10 days'), '+08 hours', '+46 minutes'), datetime(datetime(date('now','localtime','-10 days'), '+08 hours', '+46 minutes'), '+1219 seconds'), 10.5, 1.43, 2.00, 17.02, 'finished', 'paid', datetime(datetime(date('now','localtime','-10 days'), '+08 hours', '+46 minutes'), '+1219 seconds')
FROM users u WHERE u.username='presentation_user_18'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0262', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 0),
       datetime(date('now','localtime','-10 days'), '+11 hours', '+59 minutes'), datetime(datetime(date('now','localtime','-10 days'), '+11 hours', '+59 minutes'), '+1099 seconds'), 11.6, 1.24, 3.00, 17.38, 'finished', 'paid', datetime(datetime(date('now','localtime','-10 days'), '+11 hours', '+59 minutes'), '+1099 seconds')
FROM users u WHERE u.username='presentation_user_25'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0263', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 4),
       datetime(date('now','localtime','-9 days'), '+16 hours', '+03 minutes'), datetime(datetime(date('now','localtime','-9 days'), '+16 hours', '+03 minutes'), '+992 seconds'), 12.4, 1.16, 2.00, 16.38, 'finished', 'paid', datetime(datetime(date('now','localtime','-9 days'), '+16 hours', '+03 minutes'), '+992 seconds')
FROM users u WHERE u.username='presentation_user_29'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0264', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 9),
       datetime(date('now','localtime','-9 days'), '+19 hours', '+16 minutes'), datetime(datetime(date('now','localtime','-9 days'), '+19 hours', '+16 minutes'), '+2025 seconds'), 13.5, 1.43, 3.00, 22.31, 'finished', 'paid', datetime(datetime(date('now','localtime','-9 days'), '+19 hours', '+16 minutes'), '+2025 seconds')
FROM users u WHERE u.username='presentation_user_36'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0265', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 2),
       datetime(date('now','localtime','-9 days'), '+07 hours', '+29 minutes'), datetime(datetime(date('now','localtime','-9 days'), '+07 hours', '+29 minutes'), '+1695 seconds'), 14.6, 1.24, 4.00, 22.10, 'finished', 'paid', datetime(datetime(date('now','localtime','-9 days'), '+07 hours', '+29 minutes'), '+1695 seconds')
FROM users u WHERE u.username='presentation_user_03'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0266', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 7),
       datetime(date('now','localtime','-9 days'), '+10 hours', '+42 minutes'), datetime(datetime(date('now','localtime','-9 days'), '+10 hours', '+42 minutes'), '+1487 seconds'), 15.7, 1.12, 5.00, 22.58, 'finished', 'paid', datetime(datetime(date('now','localtime','-9 days'), '+10 hours', '+42 minutes'), '+1487 seconds')
FROM users u WHERE u.username='presentation_user_10'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0267', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 0),
       datetime(date('now','localtime','-9 days'), '+13 hours', '+55 minutes'), datetime(datetime(date('now','localtime','-9 days'), '+13 hours', '+55 minutes'), '+1344 seconds'), 16.8, 1.16, 2.00, 21.49, 'finished', 'paid', datetime(datetime(date('now','localtime','-9 days'), '+13 hours', '+55 minutes'), '+1344 seconds')
FROM users u WHERE u.username='presentation_user_17'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0268', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 5),
       datetime(date('now','localtime','-9 days'), '+16 hours', '+08 minutes'), datetime(datetime(date('now','localtime','-9 days'), '+16 hours', '+08 minutes'), '+2685 seconds'), 17.9, 1.20, 3.00, 24.48, 'finished', 'paid', datetime(datetime(date('now','localtime','-9 days'), '+16 hours', '+08 minutes'), '+2685 seconds')
FROM users u WHERE u.username='presentation_user_24'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0269', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 10),
       datetime(date('now','localtime','-9 days'), '+19 hours', '+21 minutes'), datetime(datetime(date('now','localtime','-9 days'), '+19 hours', '+21 minutes'), '+2206 seconds'), 19.0, 1.47, 4.00, 31.93, 'finished', 'paid', datetime(datetime(date('now','localtime','-9 days'), '+19 hours', '+21 minutes'), '+2206 seconds')
FROM users u WHERE u.username='presentation_user_31'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0270', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 3),
       datetime(date('now','localtime','-9 days'), '+07 hours', '+34 minutes'), datetime(datetime(date('now','localtime','-9 days'), '+07 hours', '+34 minutes'), '+1904 seconds'), 20.1, 1.12, 5.00, 27.51, 'finished', 'paid', datetime(datetime(date('now','localtime','-9 days'), '+07 hours', '+34 minutes'), '+1904 seconds')
FROM users u WHERE u.username='presentation_user_38'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0271', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 8),
       datetime(date('now','localtime','-9 days'), '+10 hours', '+47 minutes'), datetime(datetime(date('now','localtime','-9 days'), '+10 hours', '+47 minutes'), '+1696 seconds'), 21.2, 1.16, 2.00, 26.59, 'finished', 'paid', datetime(datetime(date('now','localtime','-9 days'), '+10 hours', '+47 minutes'), '+1696 seconds')
FROM users u WHERE u.username='presentation_user_05'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0272', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 1),
       datetime(date('now','localtime','-9 days'), '+13 hours', '+00 minutes'), datetime(datetime(date('now','localtime','-9 days'), '+13 hours', '+00 minutes'), '+3345 seconds'), 22.3, 1.20, 3.00, 29.76, 'finished', 'paid', datetime(datetime(date('now','localtime','-9 days'), '+13 hours', '+00 minutes'), '+3345 seconds')
FROM users u WHERE u.username='presentation_user_12'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0273', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 6),
       datetime(date('now','localtime','-9 days'), '+16 hours', '+13 minutes'), datetime(datetime(date('now','localtime','-9 days'), '+16 hours', '+13 minutes'), '+2717 seconds'), 23.4, 1.24, 4.00, 33.02, 'finished', 'paid', datetime(datetime(date('now','localtime','-9 days'), '+16 hours', '+13 minutes'), '+2717 seconds')
FROM users u WHERE u.username='presentation_user_19'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0274', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 11),
       datetime(date('now','localtime','-9 days'), '+19 hours', '+26 minutes'), datetime(datetime(date('now','localtime','-9 days'), '+19 hours', '+26 minutes'), '+2321 seconds'), 24.5, 1.35, 5.00, 38.08, 'finished', 'paid', datetime(datetime(date('now','localtime','-9 days'), '+19 hours', '+26 minutes'), '+2321 seconds')
FROM users u WHERE u.username='presentation_user_26'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0275', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 3),
       datetime(date('now','localtime','-8 days'), '+15 hours', '+56 minutes'), datetime(datetime(date('now','localtime','-8 days'), '+15 hours', '+56 minutes'), '+2024 seconds'), 25.3, 1.12, 2.00, 30.34, 'finished', 'paid', datetime(datetime(date('now','localtime','-8 days'), '+15 hours', '+56 minutes'), '+2024 seconds')
FROM users u WHERE u.username='presentation_user_30'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0276', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 8),
       datetime(date('now','localtime','-8 days'), '+18 hours', '+09 minutes'), datetime(datetime(date('now','localtime','-8 days'), '+18 hours', '+09 minutes'), '+3960 seconds'), 26.4, 1.39, 3.00, 39.70, 'finished', 'paid', datetime(datetime(date('now','localtime','-8 days'), '+18 hours', '+09 minutes'), '+3960 seconds')
FROM users u WHERE u.username='presentation_user_37'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0277', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 1),
       datetime(date('now','localtime','-8 days'), '+21 hours', '+22 minutes'), datetime(datetime(date('now','localtime','-8 days'), '+21 hours', '+22 minutes'), '+3194 seconds'), 27.5, 1.20, 4.00, 37.00, 'finished', 'paid', datetime(datetime(date('now','localtime','-8 days'), '+21 hours', '+22 minutes'), '+3194 seconds')
FROM users u WHERE u.username='presentation_user_04'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0278', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 6),
       datetime(date('now','localtime','-8 days'), '+09 hours', '+35 minutes'), datetime(datetime(date('now','localtime','-8 days'), '+09 hours', '+35 minutes'), '+2709 seconds'), 28.6, 1.47, 5.00, 47.04, 'finished', 'paid', datetime(datetime(date('now','localtime','-8 days'), '+09 hours', '+35 minutes'), '+2709 seconds')
FROM users u WHERE u.username='presentation_user_11'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0279', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 11),
       datetime(date('now','localtime','-8 days'), '+12 hours', '+48 minutes'), datetime(datetime(date('now','localtime','-8 days'), '+12 hours', '+48 minutes'), '+2376 seconds'), 29.7, 1.12, 2.00, 35.26, 'finished', 'paid', datetime(datetime(date('now','localtime','-8 days'), '+12 hours', '+48 minutes'), '+2376 seconds')
FROM users u WHERE u.username='presentation_user_18'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0280', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 4),
       datetime(date('now','localtime','-8 days'), '+15 hours', '+01 minutes'), datetime(datetime(date('now','localtime','-8 days'), '+15 hours', '+01 minutes'), '+4620 seconds'), 30.8, 1.16, 3.00, 38.73, 'finished', 'paid', datetime(datetime(date('now','localtime','-8 days'), '+15 hours', '+01 minutes'), '+4620 seconds')
FROM users u WHERE u.username='presentation_user_25'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0281', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 9),
       datetime(date('now','localtime','-8 days'), '+18 hours', '+14 minutes'), datetime(datetime(date('now','localtime','-8 days'), '+18 hours', '+14 minutes'), '+3705 seconds'), 31.9, 1.43, 4.00, 49.62, 'finished', 'paid', datetime(datetime(date('now','localtime','-8 days'), '+18 hours', '+14 minutes'), '+3705 seconds')
FROM users u WHERE u.username='presentation_user_32'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0282', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 2),
       datetime(date('now','localtime','-8 days'), '+21 hours', '+27 minutes'), datetime(datetime(date('now','localtime','-8 days'), '+21 hours', '+27 minutes'), '+3126 seconds'), 33.0, 1.24, 5.00, 45.92, 'finished', 'paid', datetime(datetime(date('now','localtime','-8 days'), '+21 hours', '+27 minutes'), '+3126 seconds')
FROM users u WHERE u.username='presentation_user_39'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0283', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 6),
       datetime(date('now','localtime','-7 days'), '+14 hours', '+49 minutes'), datetime(datetime(date('now','localtime','-7 days'), '+14 hours', '+49 minutes'), '+2704 seconds'), 33.8, 1.24, 2.00, 43.91, 'finished', 'paid', datetime(datetime(date('now','localtime','-7 days'), '+14 hours', '+49 minutes'), '+2704 seconds')
FROM users u WHERE u.username='presentation_user_03'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0284', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 11),
       datetime(date('now','localtime','-7 days'), '+17 hours', '+02 minutes'), datetime(datetime(date('now','localtime','-7 days'), '+17 hours', '+02 minutes'), '+5235 seconds'), 34.9, 1.35, 3.00, 50.12, 'finished', 'paid', datetime(datetime(date('now','localtime','-7 days'), '+17 hours', '+02 minutes'), '+5235 seconds')
FROM users u WHERE u.username='presentation_user_10'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0285', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 4),
       datetime(date('now','localtime','-7 days'), '+20 hours', '+15 minutes'), datetime(datetime(date('now','localtime','-7 days'), '+20 hours', '+15 minutes'), '+4181 seconds'), 36.0, 1.16, 4.00, 45.76, 'finished', 'paid', datetime(datetime(date('now','localtime','-7 days'), '+20 hours', '+15 minutes'), '+4181 seconds')
FROM users u WHERE u.username='presentation_user_17'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0286', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 9),
       datetime(date('now','localtime','-7 days'), '+08 hours', '+28 minutes'), datetime(datetime(date('now','localtime','-7 days'), '+08 hours', '+28 minutes'), '+3515 seconds'), 37.1, 1.43, 5.00, 58.05, 'finished', 'paid', datetime(datetime(date('now','localtime','-7 days'), '+08 hours', '+28 minutes'), '+3515 seconds')
FROM users u WHERE u.username='presentation_user_24'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0287', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 2),
       datetime(date('now','localtime','-7 days'), '+11 hours', '+41 minutes'), datetime(datetime(date('now','localtime','-7 days'), '+11 hours', '+41 minutes'), '+3056 seconds'), 38.2, 1.24, 2.00, 49.37, 'finished', 'paid', datetime(datetime(date('now','localtime','-7 days'), '+11 hours', '+41 minutes'), '+3056 seconds')
FROM users u WHERE u.username='presentation_user_31'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0288', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 7),
       datetime(date('now','localtime','-7 days'), '+14 hours', '+54 minutes'), datetime(datetime(date('now','localtime','-7 days'), '+14 hours', '+54 minutes'), '+5895 seconds'), 39.3, 1.12, 3.00, 47.02, 'finished', 'paid', datetime(datetime(date('now','localtime','-7 days'), '+14 hours', '+54 minutes'), '+5895 seconds')
FROM users u WHERE u.username='presentation_user_38'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0289', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 0),
       datetime(date('now','localtime','-7 days'), '+17 hours', '+07 minutes'), datetime(datetime(date('now','localtime','-7 days'), '+17 hours', '+07 minutes'), '+975 seconds'), 8.4, 1.39, 4.00, 15.68, 'finished', 'paid', datetime(datetime(date('now','localtime','-7 days'), '+17 hours', '+07 minutes'), '+975 seconds')
FROM users u WHERE u.username='presentation_user_05'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0290', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 5),
       datetime(date('now','localtime','-7 days'), '+20 hours', '+20 minutes'), datetime(datetime(date('now','localtime','-7 days'), '+20 hours', '+20 minutes'), '+900 seconds'), 9.5, 1.20, 5.00, 16.40, 'finished', 'paid', datetime(datetime(date('now','localtime','-7 days'), '+20 hours', '+20 minutes'), '+900 seconds')
FROM users u WHERE u.username='presentation_user_12'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0291', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 10),
       datetime(date('now','localtime','-7 days'), '+08 hours', '+33 minutes'), datetime(datetime(date('now','localtime','-7 days'), '+08 hours', '+33 minutes'), '+848 seconds'), 10.6, 1.47, 2.00, 17.58, 'finished', 'paid', datetime(datetime(date('now','localtime','-7 days'), '+08 hours', '+33 minutes'), '+848 seconds')
FROM users u WHERE u.username='presentation_user_19'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0292', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 3),
       datetime(date('now','localtime','-7 days'), '+11 hours', '+46 minutes'), datetime(datetime(date('now','localtime','-7 days'), '+11 hours', '+46 minutes'), '+1755 seconds'), 11.7, 1.12, 3.00, 16.10, 'finished', 'paid', datetime(datetime(date('now','localtime','-7 days'), '+11 hours', '+46 minutes'), '+1755 seconds')
FROM users u WHERE u.username='presentation_user_26'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0293', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 7),
       datetime(date('now','localtime','-6 days'), '+13 hours', '+42 minutes'), datetime(datetime(date('now','localtime','-6 days'), '+13 hours', '+42 minutes'), '+1452 seconds'), 12.5, 1.20, 2.00, 17.00, 'finished', 'paid', datetime(datetime(date('now','localtime','-6 days'), '+13 hours', '+42 minutes'), '+1452 seconds')
FROM users u WHERE u.username='presentation_user_30'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0294', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 0),
       datetime(date('now','localtime','-6 days'), '+16 hours', '+55 minutes'), datetime(datetime(date('now','localtime','-6 days'), '+16 hours', '+55 minutes'), '+1288 seconds'), 13.6, 1.24, 3.00, 19.86, 'finished', 'paid', datetime(datetime(date('now','localtime','-6 days'), '+16 hours', '+55 minutes'), '+1288 seconds')
FROM users u WHERE u.username='presentation_user_37'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0295', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 5),
       datetime(date('now','localtime','-6 days'), '+19 hours', '+08 minutes'), datetime(datetime(date('now','localtime','-6 days'), '+19 hours', '+08 minutes'), '+1176 seconds'), 14.7, 1.35, 4.00, 23.84, 'finished', 'paid', datetime(datetime(date('now','localtime','-6 days'), '+19 hours', '+08 minutes'), '+1176 seconds')
FROM users u WHERE u.username='presentation_user_04'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0296', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 10),
       datetime(date('now','localtime','-6 days'), '+07 hours', '+21 minutes'), datetime(datetime(date('now','localtime','-6 days'), '+07 hours', '+21 minutes'), '+2370 seconds'), 15.8, 1.16, 5.00, 23.33, 'finished', 'paid', datetime(datetime(date('now','localtime','-6 days'), '+07 hours', '+21 minutes'), '+2370 seconds')
FROM users u WHERE u.username='presentation_user_11'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0297', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 3),
       datetime(date('now','localtime','-6 days'), '+10 hours', '+34 minutes'), datetime(datetime(date('now','localtime','-6 days'), '+10 hours', '+34 minutes'), '+1963 seconds'), 16.9, 1.20, 2.00, 22.28, 'finished', 'paid', datetime(datetime(date('now','localtime','-6 days'), '+10 hours', '+34 minutes'), '+1963 seconds')
FROM users u WHERE u.username='presentation_user_18'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0298', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 8),
       datetime(date('now','localtime','-6 days'), '+13 hours', '+47 minutes'), datetime(datetime(date('now','localtime','-6 days'), '+13 hours', '+47 minutes'), '+1705 seconds'), 18.0, 1.24, 3.00, 25.32, 'finished', 'paid', datetime(datetime(date('now','localtime','-6 days'), '+13 hours', '+47 minutes'), '+1705 seconds')
FROM users u WHERE u.username='presentation_user_25'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0299', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 1),
       datetime(date('now','localtime','-6 days'), '+16 hours', '+00 minutes'), datetime(datetime(date('now','localtime','-6 days'), '+16 hours', '+00 minutes'), '+1528 seconds'), 19.1, 1.12, 4.00, 25.39, 'finished', 'paid', datetime(datetime(date('now','localtime','-6 days'), '+16 hours', '+00 minutes'), '+1528 seconds')
FROM users u WHERE u.username='presentation_user_32'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0300', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 6),
       datetime(date('now','localtime','-6 days'), '+19 hours', '+13 minutes'), datetime(datetime(date('now','localtime','-6 days'), '+19 hours', '+13 minutes'), '+3030 seconds'), 20.2, 1.39, 5.00, 33.08, 'finished', 'paid', datetime(datetime(date('now','localtime','-6 days'), '+19 hours', '+13 minutes'), '+3030 seconds')
FROM users u WHERE u.username='presentation_user_39'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0301', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 11),
       datetime(date('now','localtime','-6 days'), '+07 hours', '+26 minutes'), datetime(datetime(date('now','localtime','-6 days'), '+07 hours', '+26 minutes'), '+2474 seconds'), 21.3, 1.20, 2.00, 27.56, 'finished', 'paid', datetime(datetime(date('now','localtime','-6 days'), '+07 hours', '+26 minutes'), '+2474 seconds')
FROM users u WHERE u.username='presentation_user_06'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0302', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 4),
       datetime(date('now','localtime','-6 days'), '+10 hours', '+39 minutes'), datetime(datetime(date('now','localtime','-6 days'), '+10 hours', '+39 minutes'), '+2122 seconds'), 22.4, 1.24, 3.00, 30.78, 'finished', 'paid', datetime(datetime(date('now','localtime','-6 days'), '+10 hours', '+39 minutes'), '+2122 seconds')
FROM users u WHERE u.username='presentation_user_13'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0303', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 9),
       datetime(date('now','localtime','-6 days'), '+13 hours', '+52 minutes'), datetime(datetime(date('now','localtime','-6 days'), '+13 hours', '+52 minutes'), '+1880 seconds'), 23.5, 1.12, 4.00, 30.32, 'finished', 'paid', datetime(datetime(date('now','localtime','-6 days'), '+13 hours', '+52 minutes'), '+1880 seconds')
FROM users u WHERE u.username='presentation_user_20'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0304', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 2),
       datetime(date('now','localtime','-6 days'), '+16 hours', '+05 minutes'), datetime(datetime(date('now','localtime','-6 days'), '+16 hours', '+05 minutes'), '+3690 seconds'), 24.6, 1.16, 5.00, 33.54, 'finished', 'paid', datetime(datetime(date('now','localtime','-6 days'), '+16 hours', '+05 minutes'), '+3690 seconds')
FROM users u WHERE u.username='presentation_user_27'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0305', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 7),
       datetime(date('now','localtime','-6 days'), '+19 hours', '+18 minutes'), datetime(datetime(date('now','localtime','-6 days'), '+19 hours', '+18 minutes'), '+2985 seconds'), 25.7, 1.43, 2.00, 38.75, 'finished', 'paid', datetime(datetime(date('now','localtime','-6 days'), '+19 hours', '+18 minutes'), '+2985 seconds')
FROM users u WHERE u.username='presentation_user_34'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0306', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 0),
       datetime(date('now','localtime','-6 days'), '+07 hours', '+31 minutes'), datetime(datetime(date('now','localtime','-6 days'), '+07 hours', '+31 minutes'), '+2539 seconds'), 26.8, 1.24, 3.00, 36.23, 'finished', 'paid', datetime(datetime(date('now','localtime','-6 days'), '+07 hours', '+31 minutes'), '+2539 seconds')
FROM users u WHERE u.username='presentation_user_01'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0307', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 5),
       datetime(date('now','localtime','-6 days'), '+10 hours', '+44 minutes'), datetime(datetime(date('now','localtime','-6 days'), '+10 hours', '+44 minutes'), '+2232 seconds'), 27.9, 1.12, 4.00, 35.25, 'finished', 'paid', datetime(datetime(date('now','localtime','-6 days'), '+10 hours', '+44 minutes'), '+2232 seconds')
FROM users u WHERE u.username='presentation_user_08'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0308', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 9),
       datetime(date('now','localtime','-5 days'), '+12 hours', '+35 minutes'), datetime(datetime(date('now','localtime','-5 days'), '+12 hours', '+35 minutes'), '+4305 seconds'), 28.7, 1.16, 2.00, 35.29, 'finished', 'paid', datetime(datetime(date('now','localtime','-5 days'), '+12 hours', '+35 minutes'), '+4305 seconds')
FROM users u WHERE u.username='presentation_user_12'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0309', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 2),
       datetime(date('now','localtime','-5 days'), '+15 hours', '+48 minutes'), datetime(datetime(date('now','localtime','-5 days'), '+15 hours', '+48 minutes'), '+3461 seconds'), 29.8, 1.20, 3.00, 38.76, 'finished', 'paid', datetime(datetime(date('now','localtime','-5 days'), '+15 hours', '+48 minutes'), '+3461 seconds')
FROM users u WHERE u.username='presentation_user_19'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0310', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 7),
       datetime(date('now','localtime','-5 days'), '+18 hours', '+01 minutes'), datetime(datetime(date('now','localtime','-5 days'), '+18 hours', '+01 minutes'), '+2927 seconds'), 30.9, 1.47, 4.00, 49.42, 'finished', 'paid', datetime(datetime(date('now','localtime','-5 days'), '+18 hours', '+01 minutes'), '+2927 seconds')
FROM users u WHERE u.username='presentation_user_26'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0311', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 0),
       datetime(date('now','localtime','-5 days'), '+21 hours', '+14 minutes'), datetime(datetime(date('now','localtime','-5 days'), '+21 hours', '+14 minutes'), '+2560 seconds'), 32.0, 1.12, 5.00, 40.84, 'finished', 'paid', datetime(datetime(date('now','localtime','-5 days'), '+21 hours', '+14 minutes'), '+2560 seconds')
FROM users u WHERE u.username='presentation_user_33'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0312', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 5),
       datetime(date('now','localtime','-5 days'), '+09 hours', '+27 minutes'), datetime(datetime(date('now','localtime','-5 days'), '+09 hours', '+27 minutes'), '+4965 seconds'), 33.1, 1.39, 2.00, 48.01, 'finished', 'paid', datetime(datetime(date('now','localtime','-5 days'), '+09 hours', '+27 minutes'), '+4965 seconds')
FROM users u WHERE u.username='presentation_user_40'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0313', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 10),
       datetime(date('now','localtime','-5 days'), '+12 hours', '+40 minutes'), datetime(datetime(date('now','localtime','-5 days'), '+12 hours', '+40 minutes'), '+3972 seconds'), 34.2, 1.20, 3.00, 44.04, 'finished', 'paid', datetime(datetime(date('now','localtime','-5 days'), '+12 hours', '+40 minutes'), '+3972 seconds')
FROM users u WHERE u.username='presentation_user_07'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0314', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 3),
       datetime(date('now','localtime','-5 days'), '+15 hours', '+53 minutes'), datetime(datetime(date('now','localtime','-5 days'), '+15 hours', '+53 minutes'), '+3344 seconds'), 35.3, 1.24, 4.00, 47.77, 'finished', 'paid', datetime(datetime(date('now','localtime','-5 days'), '+15 hours', '+53 minutes'), '+3344 seconds')
FROM users u WHERE u.username='presentation_user_14'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0315', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 8),
       datetime(date('now','localtime','-5 days'), '+18 hours', '+06 minutes'), datetime(datetime(date('now','localtime','-5 days'), '+18 hours', '+06 minutes'), '+2912 seconds'), 36.4, 1.35, 5.00, 54.14, 'finished', 'paid', datetime(datetime(date('now','localtime','-5 days'), '+18 hours', '+06 minutes'), '+2912 seconds')
FROM users u WHERE u.username='presentation_user_21'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0316', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 1),
       datetime(date('now','localtime','-5 days'), '+21 hours', '+19 minutes'), datetime(datetime(date('now','localtime','-5 days'), '+21 hours', '+19 minutes'), '+5625 seconds'), 37.5, 1.16, 2.00, 45.50, 'finished', 'paid', datetime(datetime(date('now','localtime','-5 days'), '+21 hours', '+19 minutes'), '+5625 seconds')
FROM users u WHERE u.username='presentation_user_28'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0317', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 6),
       datetime(date('now','localtime','-5 days'), '+09 hours', '+32 minutes'), datetime(datetime(date('now','localtime','-5 days'), '+09 hours', '+32 minutes'), '+4483 seconds'), 38.6, 1.43, 3.00, 58.20, 'finished', 'paid', datetime(datetime(date('now','localtime','-5 days'), '+09 hours', '+32 minutes'), '+4483 seconds')
FROM users u WHERE u.username='presentation_user_35'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0318', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 11),
       datetime(date('now','localtime','-5 days'), '+12 hours', '+45 minutes'), datetime(datetime(date('now','localtime','-5 days'), '+12 hours', '+45 minutes'), '+3761 seconds'), 39.7, 1.24, 4.00, 53.23, 'finished', 'paid', datetime(datetime(date('now','localtime','-5 days'), '+12 hours', '+45 minutes'), '+3761 seconds')
FROM users u WHERE u.username='presentation_user_02'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0319', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 4),
       datetime(date('now','localtime','-5 days'), '+15 hours', '+58 minutes'), datetime(datetime(date('now','localtime','-5 days'), '+15 hours', '+58 minutes'), '+704 seconds'), 8.8, 1.12, 5.00, 14.86, 'finished', 'paid', datetime(datetime(date('now','localtime','-5 days'), '+15 hours', '+58 minutes'), '+704 seconds')
FROM users u WHERE u.username='presentation_user_09'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0320', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 9),
       datetime(date('now','localtime','-5 days'), '+18 hours', '+11 minutes'), datetime(datetime(date('now','localtime','-5 days'), '+18 hours', '+11 minutes'), '+1485 seconds'), 9.9, 1.39, 2.00, 15.76, 'finished', 'paid', datetime(datetime(date('now','localtime','-5 days'), '+18 hours', '+11 minutes'), '+1485 seconds')
FROM users u WHERE u.username='presentation_user_16'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0321', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 2),
       datetime(date('now','localtime','-5 days'), '+21 hours', '+24 minutes'), datetime(datetime(date('now','localtime','-5 days'), '+21 hours', '+24 minutes'), '+1277 seconds'), 11.0, 1.20, 3.00, 16.20, 'finished', 'paid', datetime(datetime(date('now','localtime','-5 days'), '+21 hours', '+24 minutes'), '+1277 seconds')
FROM users u WHERE u.username='presentation_user_23'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0322', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 7),
       datetime(date('now','localtime','-5 days'), '+09 hours', '+37 minutes'), datetime(datetime(date('now','localtime','-5 days'), '+09 hours', '+37 minutes'), '+1146 seconds'), 12.1, 1.47, 4.00, 21.79, 'finished', 'paid', datetime(datetime(date('now','localtime','-5 days'), '+09 hours', '+37 minutes'), '+1146 seconds')
FROM users u WHERE u.username='presentation_user_30'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0323', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 0),
       datetime(date('now','localtime','-5 days'), '+12 hours', '+50 minutes'), datetime(datetime(date('now','localtime','-5 days'), '+12 hours', '+50 minutes'), '+1056 seconds'), 13.2, 1.12, 5.00, 19.78, 'finished', 'paid', datetime(datetime(date('now','localtime','-5 days'), '+12 hours', '+50 minutes'), '+1056 seconds')
FROM users u WHERE u.username='presentation_user_37'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0324', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 4),
       datetime(date('now','localtime','-4 days'), '+11 hours', '+28 minutes'), datetime(datetime(date('now','localtime','-4 days'), '+11 hours', '+28 minutes'), '+2100 seconds'), 14.0, 1.12, 2.00, 17.68, 'finished', 'paid', datetime(datetime(date('now','localtime','-4 days'), '+11 hours', '+28 minutes'), '+2100 seconds')
FROM users u WHERE u.username='presentation_user_01'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0325', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 9),
       datetime(date('now','localtime','-4 days'), '+14 hours', '+41 minutes'), datetime(datetime(date('now','localtime','-4 days'), '+14 hours', '+41 minutes'), '+1754 seconds'), 15.1, 1.16, 3.00, 20.52, 'finished', 'paid', datetime(datetime(date('now','localtime','-4 days'), '+14 hours', '+41 minutes'), '+1754 seconds')
FROM users u WHERE u.username='presentation_user_08'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0326', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 2),
       datetime(date('now','localtime','-4 days'), '+17 hours', '+54 minutes'), datetime(datetime(date('now','localtime','-4 days'), '+17 hours', '+54 minutes'), '+1535 seconds'), 16.2, 1.43, 4.00, 27.17, 'finished', 'paid', datetime(datetime(date('now','localtime','-4 days'), '+17 hours', '+54 minutes'), '+1535 seconds')
FROM users u WHERE u.username='presentation_user_15'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0327', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 7),
       datetime(date('now','localtime','-4 days'), '+20 hours', '+07 minutes'), datetime(datetime(date('now','localtime','-4 days'), '+20 hours', '+07 minutes'), '+1384 seconds'), 17.3, 1.24, 5.00, 26.45, 'finished', 'paid', datetime(datetime(date('now','localtime','-4 days'), '+20 hours', '+07 minutes'), '+1384 seconds')
FROM users u WHERE u.username='presentation_user_22'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0328', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 0),
       datetime(date('now','localtime','-4 days'), '+08 hours', '+20 minutes'), datetime(datetime(date('now','localtime','-4 days'), '+08 hours', '+20 minutes'), '+2760 seconds'), 18.4, 1.35, 2.00, 26.84, 'finished', 'paid', datetime(datetime(date('now','localtime','-4 days'), '+08 hours', '+20 minutes'), '+2760 seconds')
FROM users u WHERE u.username='presentation_user_29'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0329', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 5),
       datetime(date('now','localtime','-4 days'), '+11 hours', '+33 minutes'), datetime(datetime(date('now','localtime','-4 days'), '+11 hours', '+33 minutes'), '+2265 seconds'), 19.5, 1.16, 3.00, 25.62, 'finished', 'paid', datetime(datetime(date('now','localtime','-4 days'), '+11 hours', '+33 minutes'), '+2265 seconds')
FROM users u WHERE u.username='presentation_user_36'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0330', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 10),
       datetime(date('now','localtime','-4 days'), '+14 hours', '+46 minutes'), datetime(datetime(date('now','localtime','-4 days'), '+14 hours', '+46 minutes'), '+1952 seconds'), 20.6, 1.20, 4.00, 28.72, 'finished', 'paid', datetime(datetime(date('now','localtime','-4 days'), '+14 hours', '+46 minutes'), '+1952 seconds')
FROM users u WHERE u.username='presentation_user_03'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0331', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 3),
       datetime(date('now','localtime','-4 days'), '+17 hours', '+59 minutes'), datetime(datetime(date('now','localtime','-4 days'), '+17 hours', '+59 minutes'), '+1736 seconds'), 21.7, 1.47, 5.00, 36.90, 'finished', 'paid', datetime(datetime(date('now','localtime','-4 days'), '+17 hours', '+59 minutes'), '+1736 seconds')
FROM users u WHERE u.username='presentation_user_10'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0332', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 8),
       datetime(date('now','localtime','-4 days'), '+20 hours', '+12 minutes'), datetime(datetime(date('now','localtime','-4 days'), '+20 hours', '+12 minutes'), '+3420 seconds'), 22.8, 1.12, 2.00, 27.54, 'finished', 'paid', datetime(datetime(date('now','localtime','-4 days'), '+20 hours', '+12 minutes'), '+3420 seconds')
FROM users u WHERE u.username='presentation_user_17'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0333', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 1),
       datetime(date('now','localtime','-4 days'), '+08 hours', '+25 minutes'), datetime(datetime(date('now','localtime','-4 days'), '+08 hours', '+25 minutes'), '+2775 seconds'), 23.9, 1.39, 3.00, 36.22, 'finished', 'paid', datetime(datetime(date('now','localtime','-4 days'), '+08 hours', '+25 minutes'), '+2775 seconds')
FROM users u WHERE u.username='presentation_user_24'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0334', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 6),
       datetime(date('now','localtime','-4 days'), '+11 hours', '+38 minutes'), datetime(datetime(date('now','localtime','-4 days'), '+11 hours', '+38 minutes'), '+2368 seconds'), 25.0, 1.20, 4.00, 34.00, 'finished', 'paid', datetime(datetime(date('now','localtime','-4 days'), '+11 hours', '+38 minutes'), '+2368 seconds')
FROM users u WHERE u.username='presentation_user_31'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0335', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 11),
       datetime(date('now','localtime','-4 days'), '+14 hours', '+51 minutes'), datetime(datetime(date('now','localtime','-4 days'), '+14 hours', '+51 minutes'), '+2088 seconds'), 26.1, 1.24, 5.00, 37.36, 'finished', 'paid', datetime(datetime(date('now','localtime','-4 days'), '+14 hours', '+51 minutes'), '+2088 seconds')
FROM users u WHERE u.username='presentation_user_38'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0336', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 4),
       datetime(date('now','localtime','-4 days'), '+17 hours', '+04 minutes'), datetime(datetime(date('now','localtime','-4 days'), '+17 hours', '+04 minutes'), '+4080 seconds'), 27.2, 1.35, 2.00, 38.72, 'finished', 'paid', datetime(datetime(date('now','localtime','-4 days'), '+17 hours', '+04 minutes'), '+4080 seconds')
FROM users u WHERE u.username='presentation_user_05'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0337', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 8),
       datetime(date('now','localtime','-3 days'), '+10 hours', '+21 minutes'), datetime(datetime(date('now','localtime','-3 days'), '+10 hours', '+21 minutes'), '+3252 seconds'), 28.0, 1.24, 2.00, 36.72, 'finished', 'paid', datetime(datetime(date('now','localtime','-3 days'), '+10 hours', '+21 minutes'), '+3252 seconds')
FROM users u WHERE u.username='presentation_user_09'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0338', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 1),
       datetime(date('now','localtime','-3 days'), '+13 hours', '+34 minutes'), datetime(datetime(date('now','localtime','-3 days'), '+13 hours', '+34 minutes'), '+2757 seconds'), 29.1, 1.12, 3.00, 35.59, 'finished', 'paid', datetime(datetime(date('now','localtime','-3 days'), '+13 hours', '+34 minutes'), '+2757 seconds')
FROM users u WHERE u.username='presentation_user_16'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0339', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 6),
       datetime(date('now','localtime','-3 days'), '+16 hours', '+47 minutes'), datetime(datetime(date('now','localtime','-3 days'), '+16 hours', '+47 minutes'), '+2416 seconds'), 30.2, 1.16, 4.00, 39.03, 'finished', 'paid', datetime(datetime(date('now','localtime','-3 days'), '+16 hours', '+47 minutes'), '+2416 seconds')
FROM users u WHERE u.username='presentation_user_23'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0340', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 11),
       datetime(date('now','localtime','-3 days'), '+19 hours', '+00 minutes'), datetime(datetime(date('now','localtime','-3 days'), '+19 hours', '+00 minutes'), '+4695 seconds'), 31.3, 1.43, 5.00, 49.76, 'finished', 'paid', datetime(datetime(date('now','localtime','-3 days'), '+19 hours', '+00 minutes'), '+4695 seconds')
FROM users u WHERE u.username='presentation_user_30'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0341', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 4),
       datetime(date('now','localtime','-3 days'), '+07 hours', '+13 minutes'), datetime(datetime(date('now','localtime','-3 days'), '+07 hours', '+13 minutes'), '+3763 seconds'), 32.4, 1.24, 2.00, 42.18, 'finished', 'paid', datetime(datetime(date('now','localtime','-3 days'), '+07 hours', '+13 minutes'), '+3763 seconds')
FROM users u WHERE u.username='presentation_user_37'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0342', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 9),
       datetime(date('now','localtime','-3 days'), '+10 hours', '+26 minutes'), datetime(datetime(date('now','localtime','-3 days'), '+10 hours', '+26 minutes'), '+3174 seconds'), 33.5, 1.12, 3.00, 40.52, 'finished', 'paid', datetime(datetime(date('now','localtime','-3 days'), '+10 hours', '+26 minutes'), '+3174 seconds')
FROM users u WHERE u.username='presentation_user_04'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0343', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 2),
       datetime(date('now','localtime','-3 days'), '+13 hours', '+39 minutes'), datetime(datetime(date('now','localtime','-3 days'), '+13 hours', '+39 minutes'), '+2768 seconds'), 34.6, 1.16, 4.00, 44.14, 'finished', 'paid', datetime(datetime(date('now','localtime','-3 days'), '+13 hours', '+39 minutes'), '+2768 seconds')
FROM users u WHERE u.username='presentation_user_11'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0344', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 7),
       datetime(date('now','localtime','-3 days'), '+16 hours', '+52 minutes'), datetime(datetime(date('now','localtime','-3 days'), '+16 hours', '+52 minutes'), '+5355 seconds'), 35.7, 1.20, 5.00, 47.84, 'finished', 'paid', datetime(datetime(date('now','localtime','-3 days'), '+16 hours', '+52 minutes'), '+5355 seconds')
FROM users u WHERE u.username='presentation_user_18'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0345', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 0),
       datetime(date('now','localtime','-3 days'), '+19 hours', '+05 minutes'), datetime(datetime(date('now','localtime','-3 days'), '+19 hours', '+05 minutes'), '+4274 seconds'), 36.8, 1.47, 2.00, 56.10, 'finished', 'paid', datetime(datetime(date('now','localtime','-3 days'), '+19 hours', '+05 minutes'), '+4274 seconds')
FROM users u WHERE u.username='presentation_user_25'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0346', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 5),
       datetime(date('now','localtime','-3 days'), '+07 hours', '+18 minutes'), datetime(datetime(date('now','localtime','-3 days'), '+07 hours', '+18 minutes'), '+3591 seconds'), 37.9, 1.12, 3.00, 45.45, 'finished', 'paid', datetime(datetime(date('now','localtime','-3 days'), '+07 hours', '+18 minutes'), '+3591 seconds')
FROM users u WHERE u.username='presentation_user_32'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0347', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 10),
       datetime(date('now','localtime','-3 days'), '+10 hours', '+31 minutes'), datetime(datetime(date('now','localtime','-3 days'), '+10 hours', '+31 minutes'), '+3120 seconds'), 39.0, 1.16, 4.00, 49.24, 'finished', 'paid', datetime(datetime(date('now','localtime','-3 days'), '+10 hours', '+31 minutes'), '+3120 seconds')
FROM users u WHERE u.username='presentation_user_39'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0348', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 3),
       datetime(date('now','localtime','-3 days'), '+13 hours', '+44 minutes'), datetime(datetime(date('now','localtime','-3 days'), '+13 hours', '+44 minutes'), '+6015 seconds'), 40.1, 1.20, 5.00, 53.12, 'finished', 'paid', datetime(datetime(date('now','localtime','-3 days'), '+13 hours', '+44 minutes'), '+6015 seconds')
FROM users u WHERE u.username='presentation_user_06'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0349', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 8),
       datetime(date('now','localtime','-3 days'), '+16 hours', '+57 minutes'), datetime(datetime(date('now','localtime','-3 days'), '+16 hours', '+57 minutes'), '+1068 seconds'), 9.2, 1.24, 2.00, 13.41, 'finished', 'paid', datetime(datetime(date('now','localtime','-3 days'), '+16 hours', '+57 minutes'), '+1068 seconds')
FROM users u WHERE u.username='presentation_user_13'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0350', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 1),
       datetime(date('now','localtime','-3 days'), '+19 hours', '+10 minutes'), datetime(datetime(date('now','localtime','-3 days'), '+19 hours', '+10 minutes'), '+976 seconds'), 10.3, 1.35, 3.00, 16.91, 'finished', 'paid', datetime(datetime(date('now','localtime','-3 days'), '+19 hours', '+10 minutes'), '+976 seconds')
FROM users u WHERE u.username='presentation_user_20'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0351', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 5),
       datetime(date('now','localtime','-2 days'), '+09 hours', '+14 minutes'), datetime(datetime(date('now','localtime','-2 days'), '+09 hours', '+14 minutes'), '+888 seconds'), 11.1, 1.43, 2.00, 17.87, 'finished', 'paid', datetime(datetime(date('now','localtime','-2 days'), '+09 hours', '+14 minutes'), '+888 seconds')
FROM users u WHERE u.username='presentation_user_24'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0352', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 10),
       datetime(date('now','localtime','-2 days'), '+12 hours', '+27 minutes'), datetime(datetime(date('now','localtime','-2 days'), '+12 hours', '+27 minutes'), '+1830 seconds'), 12.2, 1.24, 3.00, 18.13, 'finished', 'paid', datetime(datetime(date('now','localtime','-2 days'), '+12 hours', '+27 minutes'), '+1830 seconds')
FROM users u WHERE u.username='presentation_user_31'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0353', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 3),
       datetime(date('now','localtime','-2 days'), '+15 hours', '+40 minutes'), datetime(datetime(date('now','localtime','-2 days'), '+15 hours', '+40 minutes'), '+1545 seconds'), 13.3, 1.12, 4.00, 18.90, 'finished', 'paid', datetime(datetime(date('now','localtime','-2 days'), '+15 hours', '+40 minutes'), '+1545 seconds')
FROM users u WHERE u.username='presentation_user_38'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0354', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 8),
       datetime(date('now','localtime','-2 days'), '+18 hours', '+53 minutes'), datetime(datetime(date('now','localtime','-2 days'), '+18 hours', '+53 minutes'), '+1364 seconds'), 14.4, 1.39, 5.00, 25.02, 'finished', 'paid', datetime(datetime(date('now','localtime','-2 days'), '+18 hours', '+53 minutes'), '+1364 seconds')
FROM users u WHERE u.username='presentation_user_05'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0355', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 1),
       datetime(date('now','localtime','-2 days'), '+21 hours', '+06 minutes'), datetime(datetime(date('now','localtime','-2 days'), '+21 hours', '+06 minutes'), '+1240 seconds'), 15.5, 1.20, 2.00, 20.60, 'finished', 'paid', datetime(datetime(date('now','localtime','-2 days'), '+21 hours', '+06 minutes'), '+1240 seconds')
FROM users u WHERE u.username='presentation_user_12'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0356', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 6),
       datetime(date('now','localtime','-2 days'), '+09 hours', '+19 minutes'), datetime(datetime(date('now','localtime','-2 days'), '+09 hours', '+19 minutes'), '+2490 seconds'), 16.6, 1.47, 3.00, 27.40, 'finished', 'paid', datetime(datetime(date('now','localtime','-2 days'), '+09 hours', '+19 minutes'), '+2490 seconds')
FROM users u WHERE u.username='presentation_user_19'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0357', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 11),
       datetime(date('now','localtime','-2 days'), '+12 hours', '+32 minutes'), datetime(datetime(date('now','localtime','-2 days'), '+12 hours', '+32 minutes'), '+2055 seconds'), 17.7, 1.12, 4.00, 23.82, 'finished', 'paid', datetime(datetime(date('now','localtime','-2 days'), '+12 hours', '+32 minutes'), '+2055 seconds')
FROM users u WHERE u.username='presentation_user_26'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0358', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 4),
       datetime(date('now','localtime','-2 days'), '+15 hours', '+45 minutes'), datetime(datetime(date('now','localtime','-2 days'), '+15 hours', '+45 minutes'), '+1781 seconds'), 18.8, 1.16, 5.00, 26.81, 'finished', 'paid', datetime(datetime(date('now','localtime','-2 days'), '+15 hours', '+45 minutes'), '+1781 seconds')
FROM users u WHERE u.username='presentation_user_33'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0359', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 9),
       datetime(date('now','localtime','-2 days'), '+18 hours', '+58 minutes'), datetime(datetime(date('now','localtime','-2 days'), '+18 hours', '+58 minutes'), '+1592 seconds'), 19.9, 1.43, 2.00, 30.46, 'finished', 'paid', datetime(datetime(date('now','localtime','-2 days'), '+18 hours', '+58 minutes'), '+1592 seconds')
FROM users u WHERE u.username='presentation_user_40'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0360', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 2),
       datetime(date('now','localtime','-2 days'), '+21 hours', '+11 minutes'), datetime(datetime(date('now','localtime','-2 days'), '+21 hours', '+11 minutes'), '+3150 seconds'), 21.0, 1.24, 3.00, 29.04, 'finished', 'paid', datetime(datetime(date('now','localtime','-2 days'), '+21 hours', '+11 minutes'), '+3150 seconds')
FROM users u WHERE u.username='presentation_user_07'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0361', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 7),
       datetime(date('now','localtime','-2 days'), '+09 hours', '+24 minutes'), datetime(datetime(date('now','localtime','-2 days'), '+09 hours', '+24 minutes'), '+2566 seconds'), 22.1, 1.35, 4.00, 33.84, 'finished', 'paid', datetime(datetime(date('now','localtime','-2 days'), '+09 hours', '+24 minutes'), '+2566 seconds')
FROM users u WHERE u.username='presentation_user_14'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0362', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 0),
       datetime(date('now','localtime','-2 days'), '+12 hours', '+37 minutes'), datetime(datetime(date('now','localtime','-2 days'), '+12 hours', '+37 minutes'), '+2198 seconds'), 23.2, 1.16, 5.00, 31.91, 'finished', 'paid', datetime(datetime(date('now','localtime','-2 days'), '+12 hours', '+37 minutes'), '+2198 seconds')
FROM users u WHERE u.username='presentation_user_21'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0363', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 4),
       datetime(date('now','localtime','-1 days'), '+08 hours', '+07 minutes'), datetime(datetime(date('now','localtime','-1 days'), '+08 hours', '+07 minutes'), '+1920 seconds'), 24.0, 1.39, 2.00, 35.36, 'finished', 'paid', datetime(datetime(date('now','localtime','-1 days'), '+08 hours', '+07 minutes'), '+1920 seconds')
FROM users u WHERE u.username='presentation_user_25'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0364', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 9),
       datetime(date('now','localtime','-1 days'), '+11 hours', '+20 minutes'), datetime(datetime(date('now','localtime','-1 days'), '+11 hours', '+20 minutes'), '+3765 seconds'), 25.1, 1.20, 3.00, 33.12, 'finished', 'paid', datetime(datetime(date('now','localtime','-1 days'), '+11 hours', '+20 minutes'), '+3765 seconds')
FROM users u WHERE u.username='presentation_user_32'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0365', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 2),
       datetime(date('now','localtime','-1 days'), '+14 hours', '+33 minutes'), datetime(datetime(date('now','localtime','-1 days'), '+14 hours', '+33 minutes'), '+3043 seconds'), 26.2, 1.24, 4.00, 36.49, 'finished', 'paid', datetime(datetime(date('now','localtime','-1 days'), '+14 hours', '+33 minutes'), '+3043 seconds')
FROM users u WHERE u.username='presentation_user_39'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0366', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 7),
       datetime(date('now','localtime','-1 days'), '+17 hours', '+46 minutes'), datetime(datetime(date('now','localtime','-1 days'), '+17 hours', '+46 minutes'), '+2586 seconds'), 27.3, 1.35, 5.00, 41.85, 'finished', 'paid', datetime(datetime(date('now','localtime','-1 days'), '+17 hours', '+46 minutes'), '+2586 seconds')
FROM users u WHERE u.username='presentation_user_06'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0367', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 0),
       datetime(date('now','localtime','-1 days'), '+20 hours', '+59 minutes'), datetime(datetime(date('now','localtime','-1 days'), '+20 hours', '+59 minutes'), '+2272 seconds'), 28.4, 1.16, 2.00, 34.94, 'finished', 'paid', datetime(datetime(date('now','localtime','-1 days'), '+20 hours', '+59 minutes'), '+2272 seconds')
FROM users u WHERE u.username='presentation_user_13'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0368', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 5),
       datetime(date('now','localtime','-1 days'), '+08 hours', '+12 minutes'), datetime(datetime(date('now','localtime','-1 days'), '+08 hours', '+12 minutes'), '+4425 seconds'), 29.5, 1.43, 3.00, 45.19, 'finished', 'paid', datetime(datetime(date('now','localtime','-1 days'), '+08 hours', '+12 minutes'), '+4425 seconds')
FROM users u WHERE u.username='presentation_user_20'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0369', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 10),
       datetime(date('now','localtime','-1 days'), '+11 hours', '+25 minutes'), datetime(datetime(date('now','localtime','-1 days'), '+11 hours', '+25 minutes'), '+3554 seconds'), 30.6, 1.24, 4.00, 41.94, 'finished', 'paid', datetime(datetime(date('now','localtime','-1 days'), '+11 hours', '+25 minutes'), '+3554 seconds')
FROM users u WHERE u.username='presentation_user_27'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0370', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 3),
       datetime(date('now','localtime','-1 days'), '+14 hours', '+38 minutes'), datetime(datetime(date('now','localtime','-1 days'), '+14 hours', '+38 minutes'), '+3003 seconds'), 31.7, 1.12, 5.00, 40.50, 'finished', 'paid', datetime(datetime(date('now','localtime','-1 days'), '+14 hours', '+38 minutes'), '+3003 seconds')
FROM users u WHERE u.username='presentation_user_34'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0371', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 8),
       datetime(date('now','localtime','-1 days'), '+17 hours', '+51 minutes'), datetime(datetime(date('now','localtime','-1 days'), '+17 hours', '+51 minutes'), '+2624 seconds'), 32.8, 1.39, 2.00, 47.59, 'finished', 'paid', datetime(datetime(date('now','localtime','-1 days'), '+17 hours', '+51 minutes'), '+2624 seconds')
FROM users u WHERE u.username='presentation_user_01'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0372', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 1),
       datetime(date('now','localtime','-1 days'), '+20 hours', '+04 minutes'), datetime(datetime(date('now','localtime','-1 days'), '+20 hours', '+04 minutes'), '+5085 seconds'), 33.9, 1.20, 3.00, 43.68, 'finished', 'paid', datetime(datetime(date('now','localtime','-1 days'), '+20 hours', '+04 minutes'), '+5085 seconds')
FROM users u WHERE u.username='presentation_user_08'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0373', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 6),
       datetime(date('now','localtime','-1 days'), '+08 hours', '+17 minutes'), datetime(datetime(date('now','localtime','-1 days'), '+08 hours', '+17 minutes'), '+4065 seconds'), 35.0, 1.47, 4.00, 55.45, 'finished', 'paid', datetime(datetime(date('now','localtime','-1 days'), '+08 hours', '+17 minutes'), '+4065 seconds')
FROM users u WHERE u.username='presentation_user_15'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0374', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 10),
       datetime(date('now','localtime','-0 days'), '+07 hours', '+00 minutes'), datetime(datetime(date('now','localtime','-0 days'), '+07 hours', '+00 minutes'), '+3392 seconds'), 35.8, 1.12, 2.00, 42.10, 'finished', 'paid', datetime(datetime(date('now','localtime','-0 days'), '+07 hours', '+00 minutes'), '+3392 seconds')
FROM users u WHERE u.username='presentation_user_19'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0375', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 3),
       datetime(date('now','localtime','-0 days'), '+10 hours', '+13 minutes'), datetime(datetime(date('now','localtime','-0 days'), '+10 hours', '+13 minutes'), '+2952 seconds'), 36.9, 1.16, 3.00, 45.80, 'finished', 'paid', datetime(datetime(date('now','localtime','-0 days'), '+10 hours', '+13 minutes'), '+2952 seconds')
FROM users u WHERE u.username='presentation_user_26'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0376', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 8),
       datetime(date('now','localtime','-0 days'), '+13 hours', '+26 minutes'), datetime(datetime(date('now','localtime','-0 days'), '+13 hours', '+26 minutes'), '+5700 seconds'), 38.0, 1.20, 4.00, 49.60, 'finished', 'paid', datetime(datetime(date('now','localtime','-0 days'), '+13 hours', '+26 minutes'), '+5700 seconds')
FROM users u WHERE u.username='presentation_user_33'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0377', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 1),
       datetime(date('now','localtime','-0 days'), '+16 hours', '+39 minutes'), datetime(datetime(date('now','localtime','-0 days'), '+16 hours', '+39 minutes'), '+4541 seconds'), 39.1, 1.24, 5.00, 53.48, 'finished', 'paid', datetime(datetime(date('now','localtime','-0 days'), '+16 hours', '+39 minutes'), '+4541 seconds')
FROM users u WHERE u.username='presentation_user_40'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0378', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 6),
       datetime(date('now','localtime','-0 days'), '+19 hours', '+52 minutes'), datetime(datetime(date('now','localtime','-0 days'), '+19 hours', '+52 minutes'), '+3808 seconds'), 40.2, 1.35, 2.00, 56.27, 'finished', 'paid', datetime(datetime(date('now','localtime','-0 days'), '+19 hours', '+52 minutes'), '+3808 seconds')
FROM users u WHERE u.username='presentation_user_07'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0379', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 11),
       datetime(date('now','localtime','-0 days'), '+07 hours', '+05 minutes'), datetime(datetime(date('now','localtime','-0 days'), '+07 hours', '+05 minutes'), '+744 seconds'), 9.3, 1.16, 3.00, 13.79, 'finished', 'paid', datetime(datetime(date('now','localtime','-0 days'), '+07 hours', '+05 minutes'), '+744 seconds')
FROM users u WHERE u.username='presentation_user_14'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0380', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 4),
       datetime(date('now','localtime','-0 days'), '+10 hours', '+18 minutes'), datetime(datetime(date('now','localtime','-0 days'), '+10 hours', '+18 minutes'), '+1560 seconds'), 10.4, 1.20, 4.00, 16.48, 'finished', 'paid', datetime(datetime(date('now','localtime','-0 days'), '+10 hours', '+18 minutes'), '+1560 seconds')
FROM users u WHERE u.username='presentation_user_21'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0381', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 9),
       datetime(date('now','localtime','-0 days'), '+13 hours', '+31 minutes'), datetime(datetime(date('now','localtime','-0 days'), '+13 hours', '+31 minutes'), '+1335 seconds'), 11.5, 1.24, 5.00, 19.26, 'finished', 'paid', datetime(datetime(date('now','localtime','-0 days'), '+13 hours', '+31 minutes'), '+1335 seconds')
FROM users u WHERE u.username='presentation_user_28'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');
INSERT OR IGNORE INTO charging_orders(order_no, user_id, pile_id, start_time, end_time, energy_kwh, price_per_kwh, service_fee, amount, status, payment_status, paid_at)
SELECT '1919-810-0382', u.id, (SELECT id FROM piles ORDER BY id LIMIT 1 OFFSET 2),
       datetime(date('now','localtime','-0 days'), '+16 hours', '+44 minutes'), datetime(datetime(date('now','localtime','-0 days'), '+16 hours', '+44 minutes'), '+1194 seconds'), 12.6, 1.12, 2.00, 16.11, 'finished', 'paid', datetime(datetime(date('now','localtime','-0 days'), '+16 hours', '+44 minutes'), '+1194 seconds')
FROM users u WHERE u.username='presentation_user_35'
  AND EXISTS (SELECT 1 FROM piles)
  AND NOT EXISTS (SELECT 1 FROM charging_orders WHERE order_no='PRESENTATION-2026-0001');

-- 默认位置附近 20 个站点的展示评价；评分与评价内容一一对应。
INSERT INTO station_reviews(station_id, user_id, order_id, rating, comment, created_at)
SELECT (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 0)), u.id, NULL, 5, '导航准确，快充功率稳定，午间来基本不用排队。', datetime('now','localtime','-1 hours')
FROM users u WHERE u.username='presentation_user_06'
  AND (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 0)) IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM station_reviews r
                  WHERE r.station_id=(SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 0)) AND r.user_id=u.id AND r.comment='导航准确，快充功率稳定，午间来基本不用排队。');
INSERT INTO station_reviews(station_id, user_id, order_id, rating, comment, created_at)
SELECT (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 0)), u.id, NULL, 4, '场地整洁，车位标识清楚，整体体验不错。', datetime('now','localtime','-2 hours')
FROM users u WHERE u.username='presentation_user_15'
  AND (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 0)) IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM station_reviews r
                  WHERE r.station_id=(SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 0)) AND r.user_id=u.id AND r.comment='场地整洁，车位标识清楚，整体体验不错。');
INSERT INTO station_reviews(station_id, user_id, order_id, rating, comment, created_at)
SELECT (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 1)), u.id, NULL, 5, '充电速度很快，休息区和洗手间都很方便。', datetime('now','localtime','-3 hours')
FROM users u WHERE u.username='presentation_user_24'
  AND (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 1)) IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM station_reviews r
                  WHERE r.station_id=(SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 1)) AND r.user_id=u.id AND r.comment='充电速度很快，休息区和洗手间都很方便。');
INSERT INTO station_reviews(station_id, user_id, order_id, rating, comment, created_at)
SELECT (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 1)), u.id, NULL, 4, '价格透明，扫码开桩顺利，高峰期建议提前预约。', datetime('now','localtime','-4 hours')
FROM users u WHERE u.username='presentation_user_33'
  AND (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 1)) IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM station_reviews r
                  WHERE r.station_id=(SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 1)) AND r.user_id=u.id AND r.comment='价格透明，扫码开桩顺利，高峰期建议提前预约。');
INSERT INTO station_reviews(station_id, user_id, order_id, rating, comment, created_at)
SELECT (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 2)), u.id, NULL, 5, '晚上照明充足，桩位充裕，服务人员很耐心。', datetime('now','localtime','-5 hours')
FROM users u WHERE u.username='presentation_user_02'
  AND (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 2)) IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM station_reviews r
                  WHERE r.station_id=(SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 2)) AND r.user_id=u.id AND r.comment='晚上照明充足，桩位充裕，服务人员很耐心。');
INSERT INTO station_reviews(station_id, user_id, order_id, rating, comment, created_at)
SELECT (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 2)), u.id, NULL, 4, '位置好找，电量结算清晰，停车费说明也明确。', datetime('now','localtime','-6 hours')
FROM users u WHERE u.username='presentation_user_11'
  AND (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 2)) IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM station_reviews r
                  WHERE r.station_id=(SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 2)) AND r.user_id=u.id AND r.comment='位置好找，电量结算清晰，停车费说明也明确。');
INSERT INTO station_reviews(station_id, user_id, order_id, rating, comment, created_at)
SELECT (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 3)), u.id, NULL, 3, '充电正常，但周末车流较多，等待时间略长。', datetime('now','localtime','-7 hours')
FROM users u WHERE u.username='presentation_user_20'
  AND (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 3)) IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM station_reviews r
                  WHERE r.station_id=(SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 3)) AND r.user_id=u.id AND r.comment='充电正常，但周末车流较多，等待时间略长。');
INSERT INTO station_reviews(station_id, user_id, order_id, rating, comment, created_at)
SELECT (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 3)), u.id, NULL, 4, '桩体较新，接口干净，补能效率符合预期。', datetime('now','localtime','-8 hours')
FROM users u WHERE u.username='presentation_user_29'
  AND (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 3)) IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM station_reviews r
                  WHERE r.station_id=(SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 3)) AND r.user_id=u.id AND r.comment='桩体较新，接口干净，补能效率符合预期。');
INSERT INTO station_reviews(station_id, user_id, order_id, rating, comment, created_at)
SELECT (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 4)), u.id, NULL, 5, '附近餐饮很多，等待充电不无聊，推荐过来。', datetime('now','localtime','-9 hours')
FROM users u WHERE u.username='presentation_user_38'
  AND (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 4)) IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM station_reviews r
                  WHERE r.station_id=(SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 4)) AND r.user_id=u.id AND r.comment='附近餐饮很多，等待充电不无聊，推荐过来。');
INSERT INTO station_reviews(station_id, user_id, order_id, rating, comment, created_at)
SELECT (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 4)), u.id, NULL, 4, '场站管理规范，夜间也能顺利找到空闲桩。', datetime('now','localtime','-10 hours')
FROM users u WHERE u.username='presentation_user_07'
  AND (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 4)) IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM station_reviews r
                  WHERE r.station_id=(SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 4)) AND r.user_id=u.id AND r.comment='场站管理规范，夜间也能顺利找到空闲桩。');
INSERT INTO station_reviews(station_id, user_id, order_id, rating, comment, created_at)
SELECT (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 5)), u.id, NULL, 5, '预约后到站直接可用，功率平稳，体验很好。', datetime('now','localtime','-11 hours')
FROM users u WHERE u.username='presentation_user_16'
  AND (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 5)) IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM station_reviews r
                  WHERE r.station_id=(SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 5)) AND r.user_id=u.id AND r.comment='预约后到站直接可用，功率平稳，体验很好。');
INSERT INTO station_reviews(station_id, user_id, order_id, rating, comment, created_at)
SELECT (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 5)), u.id, NULL, 4, '入口指引清楚，充完自动结算，使用很省心。', datetime('now','localtime','-12 hours')
FROM users u WHERE u.username='presentation_user_25'
  AND (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 5)) IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM station_reviews r
                  WHERE r.station_id=(SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 5)) AND r.user_id=u.id AND r.comment='入口指引清楚，充完自动结算，使用很省心。');
INSERT INTO station_reviews(station_id, user_id, order_id, rating, comment, created_at)
SELECT (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 6)), u.id, NULL, 2, '本次充电可用，但有一台桩维护中，建议及时更新状态。', datetime('now','localtime','-13 hours')
FROM users u WHERE u.username='presentation_user_34'
  AND (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 6)) IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM station_reviews r
                  WHERE r.station_id=(SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 6)) AND r.user_id=u.id AND r.comment='本次充电可用，但有一台桩维护中，建议及时更新状态。');
INSERT INTO station_reviews(station_id, user_id, order_id, rating, comment, created_at)
SELECT (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 6)), u.id, NULL, 3, '整体还可以，不过车位转弯空间稍小，新手需注意。', datetime('now','localtime','-14 hours')
FROM users u WHERE u.username='presentation_user_03'
  AND (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 6)) IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM station_reviews r
                  WHERE r.station_id=(SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 6)) AND r.user_id=u.id AND r.comment='整体还可以，不过车位转弯空间稍小，新手需注意。');
INSERT INTO station_reviews(station_id, user_id, order_id, rating, comment, created_at)
SELECT (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 7)), u.id, NULL, 5, '客服响应及时，遇到问题很快就帮忙处理好了。', datetime('now','localtime','-15 hours')
FROM users u WHERE u.username='presentation_user_12'
  AND (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 7)) IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM station_reviews r
                  WHERE r.station_id=(SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 7)) AND r.user_id=u.id AND r.comment='客服响应及时，遇到问题很快就帮忙处理好了。');
INSERT INTO station_reviews(station_id, user_id, order_id, rating, comment, created_at)
SELECT (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 7)), u.id, NULL, 4, '环境安静，遮阳设施不错，夏天充电比较舒适。', datetime('now','localtime','-16 hours')
FROM users u WHERE u.username='presentation_user_21'
  AND (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 7)) IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM station_reviews r
                  WHERE r.station_id=(SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 7)) AND r.user_id=u.id AND r.comment='环境安静，遮阳设施不错，夏天充电比较舒适。');
INSERT INTO station_reviews(station_id, user_id, order_id, rating, comment, created_at)
SELECT (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 8)), u.id, NULL, 5, '电价合适，充电记录完整，下次还会再来。', datetime('now','localtime','-17 hours')
FROM users u WHERE u.username='presentation_user_30'
  AND (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 8)) IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM station_reviews r
                  WHERE r.station_id=(SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 8)) AND r.user_id=u.id AND r.comment='电价合适，充电记录完整，下次还会再来。');
INSERT INTO station_reviews(station_id, user_id, order_id, rating, comment, created_at)
SELECT (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 8)), u.id, NULL, 4, '距离主路近，进出方便，快充速度令人满意。', datetime('now','localtime','-18 hours')
FROM users u WHERE u.username='presentation_user_39'
  AND (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 8)) IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM station_reviews r
                  WHERE r.station_id=(SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 8)) AND r.user_id=u.id AND r.comment='距离主路近，进出方便，快充速度令人满意。');
INSERT INTO station_reviews(station_id, user_id, order_id, rating, comment, created_at)
SELECT (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 9)), u.id, NULL, 3, '设备使用正常，建议增加等候区座椅和饮水设施。', datetime('now','localtime','-19 hours')
FROM users u WHERE u.username='presentation_user_08'
  AND (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 9)) IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM station_reviews r
                  WHERE r.station_id=(SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 9)) AND r.user_id=u.id AND r.comment='设备使用正常，建议增加等候区座椅和饮水设施。');
INSERT INTO station_reviews(station_id, user_id, order_id, rating, comment, created_at)
SELECT (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 9)), u.id, NULL, 4, '站内卫生不错，支付流程顺畅，整体值得推荐。', datetime('now','localtime','-20 hours')
FROM users u WHERE u.username='presentation_user_17'
  AND (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 9)) IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM station_reviews r
                  WHERE r.station_id=(SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 9)) AND r.user_id=u.id AND r.comment='站内卫生不错，支付流程顺畅，整体值得推荐。');
INSERT INTO station_reviews(station_id, user_id, order_id, rating, comment, created_at)
SELECT (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 10)), u.id, NULL, 5, '高峰期仍有空桩，充电过程稳定，体验超出预期。', datetime('now','localtime','-21 hours')
FROM users u WHERE u.username='presentation_user_26'
  AND (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 10)) IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM station_reviews r
                  WHERE r.station_id=(SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 10)) AND r.user_id=u.id AND r.comment='高峰期仍有空桩，充电过程稳定，体验超出预期。');
INSERT INTO station_reviews(station_id, user_id, order_id, rating, comment, created_at)
SELECT (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 10)), u.id, NULL, 4, '停车场宽敞，夜间有工作人员巡查，比较安心。', datetime('now','localtime','-22 hours')
FROM users u WHERE u.username='presentation_user_35'
  AND (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 10)) IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM station_reviews r
                  WHERE r.station_id=(SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 10)) AND r.user_id=u.id AND r.comment='停车场宽敞，夜间有工作人员巡查，比较安心。');
INSERT INTO station_reviews(station_id, user_id, order_id, rating, comment, created_at)
SELECT (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 11)), u.id, NULL, 5, '从导航到拔枪都很顺利，价格和账单一目了然。', datetime('now','localtime','-23 hours')
FROM users u WHERE u.username='presentation_user_04'
  AND (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 11)) IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM station_reviews r
                  WHERE r.station_id=(SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 11)) AND r.user_id=u.id AND r.comment='从导航到拔枪都很顺利，价格和账单一目了然。');
INSERT INTO station_reviews(station_id, user_id, order_id, rating, comment, created_at)
SELECT (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 11)), u.id, NULL, 4, '充电桩布局合理，等候时可以到周边商场休息。', datetime('now','localtime','-24 hours')
FROM users u WHERE u.username='presentation_user_13'
  AND (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 11)) IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM station_reviews r
                  WHERE r.station_id=(SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 11)) AND r.user_id=u.id AND r.comment='充电桩布局合理，等候时可以到周边商场休息。');
INSERT INTO station_reviews(station_id, user_id, order_id, rating, comment, created_at)
SELECT (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 12)), u.id, NULL, 2, '能正常完成充电，但入口标识不够醒目，第一次不太好找。', datetime('now','localtime','-25 hours')
FROM users u WHERE u.username='presentation_user_22'
  AND (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 12)) IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM station_reviews r
                  WHERE r.station_id=(SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 12)) AND r.user_id=u.id AND r.comment='能正常完成充电，但入口标识不够醒目，第一次不太好找。');
INSERT INTO station_reviews(station_id, user_id, order_id, rating, comment, created_at)
SELECT (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 12)), u.id, NULL, 3, '功率基本稳定，偶尔需要重新插枪，整体尚可。', datetime('now','localtime','-26 hours')
FROM users u WHERE u.username='presentation_user_31'
  AND (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 12)) IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM station_reviews r
                  WHERE r.station_id=(SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 12)) AND r.user_id=u.id AND r.comment='功率基本稳定，偶尔需要重新插枪，整体尚可。');
INSERT INTO station_reviews(station_id, user_id, order_id, rating, comment, created_at)
SELECT (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 13)), u.id, NULL, 5, '服务区配套齐全，补电速度快，出行前很方便。', datetime('now','localtime','-27 hours')
FROM users u WHERE u.username='presentation_user_40'
  AND (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 13)) IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM station_reviews r
                  WHERE r.station_id=(SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 13)) AND r.user_id=u.id AND r.comment='服务区配套齐全，补电速度快，出行前很方便。');
INSERT INTO station_reviews(station_id, user_id, order_id, rating, comment, created_at)
SELECT (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 13)), u.id, NULL, 4, '预约时段准确保留，站内秩序好，没有被占位。', datetime('now','localtime','-28 hours')
FROM users u WHERE u.username='presentation_user_09'
  AND (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 13)) IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM station_reviews r
                  WHERE r.station_id=(SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 13)) AND r.user_id=u.id AND r.comment='预约时段准确保留，站内秩序好，没有被占位。');
INSERT INTO station_reviews(station_id, user_id, order_id, rating, comment, created_at)
SELECT (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 14)), u.id, NULL, 5, '桩位干净整齐，充电完成通知及时，体验很棒。', datetime('now','localtime','-29 hours')
FROM users u WHERE u.username='presentation_user_18'
  AND (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 14)) IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM station_reviews r
                  WHERE r.station_id=(SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 14)) AND r.user_id=u.id AND r.comment='桩位干净整齐，充电完成通知及时，体验很棒。');
INSERT INTO station_reviews(station_id, user_id, order_id, rating, comment, created_at)
SELECT (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 14)), u.id, NULL, 4, '电价合理，离公司近，工作日下班常来这里补电。', datetime('now','localtime','-30 hours')
FROM users u WHERE u.username='presentation_user_27'
  AND (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 14)) IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM station_reviews r
                  WHERE r.station_id=(SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 14)) AND r.user_id=u.id AND r.comment='电价合理，离公司近，工作日下班常来这里补电。');
INSERT INTO station_reviews(station_id, user_id, order_id, rating, comment, created_at)
SELECT (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 15)), u.id, NULL, 5, '雨天有棚可用，设备没有受影响，值得五星。', datetime('now','localtime','-31 hours')
FROM users u WHERE u.username='presentation_user_36'
  AND (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 15)) IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM station_reviews r
                  WHERE r.station_id=(SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 15)) AND r.user_id=u.id AND r.comment='雨天有棚可用，设备没有受影响，值得五星。');
INSERT INTO station_reviews(station_id, user_id, order_id, rating, comment, created_at)
SELECT (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 15)), u.id, NULL, 4, '导航终点准确，场站开放时间清晰，使用方便。', datetime('now','localtime','-32 hours')
FROM users u WHERE u.username='presentation_user_05'
  AND (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 15)) IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM station_reviews r
                  WHERE r.station_id=(SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 15)) AND r.user_id=u.id AND r.comment='导航终点准确，场站开放时间清晰，使用方便。');
INSERT INTO station_reviews(station_id, user_id, order_id, rating, comment, created_at)
SELECT (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 16)), u.id, NULL, 3, '整体服务不错，但傍晚排队较多，希望增加快充桩。', datetime('now','localtime','-33 hours')
FROM users u WHERE u.username='presentation_user_14'
  AND (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 16)) IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM station_reviews r
                  WHERE r.station_id=(SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 16)) AND r.user_id=u.id AND r.comment='整体服务不错，但傍晚排队较多，希望增加快充桩。');
INSERT INTO station_reviews(station_id, user_id, order_id, rating, comment, created_at)
SELECT (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 16)), u.id, NULL, 4, '支付和发票信息清楚，充电过程没有出现异常。', datetime('now','localtime','-34 hours')
FROM users u WHERE u.username='presentation_user_23'
  AND (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 16)) IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM station_reviews r
                  WHERE r.station_id=(SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 16)) AND r.user_id=u.id AND r.comment='支付和发票信息清楚，充电过程没有出现异常。');
INSERT INTO station_reviews(station_id, user_id, order_id, rating, comment, created_at)
SELECT (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 17)), u.id, NULL, 5, '电桩响应很快，停车和离场都很顺畅，推荐。', datetime('now','localtime','-35 hours')
FROM users u WHERE u.username='presentation_user_32'
  AND (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 17)) IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM station_reviews r
                  WHERE r.station_id=(SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 17)) AND r.user_id=u.id AND r.comment='电桩响应很快，停车和离场都很顺畅，推荐。');
INSERT INTO station_reviews(station_id, user_id, order_id, rating, comment, created_at)
SELECT (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 17)), u.id, NULL, 4, '周边配套齐全，等待时可以购物，时间利用率高。', datetime('now','localtime','-36 hours')
FROM users u WHERE u.username='presentation_user_01'
  AND (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 17)) IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM station_reviews r
                  WHERE r.station_id=(SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 17)) AND r.user_id=u.id AND r.comment='周边配套齐全，等待时可以购物，时间利用率高。');
INSERT INTO station_reviews(station_id, user_id, order_id, rating, comment, created_at)
SELECT (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 18)), u.id, NULL, 5, '第一次使用也没有障碍，操作提示非常清楚。', datetime('now','localtime','-37 hours')
FROM users u WHERE u.username='presentation_user_10'
  AND (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 18)) IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM station_reviews r
                  WHERE r.station_id=(SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 18)) AND r.user_id=u.id AND r.comment='第一次使用也没有障碍，操作提示非常清楚。');
INSERT INTO station_reviews(station_id, user_id, order_id, rating, comment, created_at)
SELECT (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 18)), u.id, NULL, 4, '场地整洁，工作人员会协助引导，服务细致。', datetime('now','localtime','-38 hours')
FROM users u WHERE u.username='presentation_user_19'
  AND (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 18)) IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM station_reviews r
                  WHERE r.station_id=(SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 18)) AND r.user_id=u.id AND r.comment='场地整洁，工作人员会协助引导，服务细致。');
INSERT INTO station_reviews(station_id, user_id, order_id, rating, comment, created_at)
SELECT (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 19)), u.id, NULL, 5, '最近常来，功率稳定且价格透明，整体非常满意。', datetime('now','localtime','-39 hours')
FROM users u WHERE u.username='presentation_user_28'
  AND (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 19)) IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM station_reviews r
                  WHERE r.station_id=(SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 19)) AND r.user_id=u.id AND r.comment='最近常来，功率稳定且价格透明，整体非常满意。');
INSERT INTO station_reviews(station_id, user_id, order_id, rating, comment, created_at)
SELECT (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 19)), u.id, NULL, 4, '空闲桩信息更新及时，到站后很快就充上了。', datetime('now','localtime','-40 hours')
FROM users u WHERE u.username='presentation_user_37'
  AND (SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 19)) IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM station_reviews r
                  WHERE r.station_id=(SELECT station_id FROM (SELECT p.station_id, MIN((s.latitude-39.9042)*(s.latitude-39.9042) + ((s.longitude-116.4074)*0.77)*((s.longitude-116.4074)*0.77)) AS distance FROM piles p JOIN stations s ON s.id=p.station_id GROUP BY p.station_id ORDER BY distance LIMIT 1 OFFSET 19)) AND r.user_id=u.id AND r.comment='空闲桩信息更新及时，到站后很快就充上了。');
COMMIT;
