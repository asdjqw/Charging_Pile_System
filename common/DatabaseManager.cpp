#include "DatabaseManager.h"

#include <algorithm>

#include <QCoreApplication>
#include <QDateTime>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QSqlError>
#include <QSqlQuery>
#include <QStandardPaths>
#include <QtMath>
#include <QVariant>

DatabaseManager &DatabaseManager::instance()
{
    static DatabaseManager mgr;
    return mgr;
}

DatabaseManager::DatabaseManager(QObject *parent)
    : QObject(parent)
{
}

QString DatabaseManager::resolveDbPath(const QString &preferred) const
{
    if (!preferred.isEmpty())
        return preferred;

    // 用户端与管理端共用同一数据库，避免两端数据不一致
    const QString dataDir =
        QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation)
        + QStringLiteral("/ChargePileLab");
    QDir().mkpath(dataDir);
    return dataDir + QStringLiteral("/charge_pile.db");
}

bool DatabaseManager::initialize(const QString &dbPath)
{
    m_dbPath = resolveDbPath(dbPath);
    if (!openDatabase(m_dbPath))
        return false;
    return ensureSchemaAndSeed();
}

bool DatabaseManager::openDatabase(const QString &dbPath)
{
    if (QSqlDatabase::contains(QStringLiteral("charge_pile_conn"))) {
        m_db = QSqlDatabase::database(QStringLiteral("charge_pile_conn"));
        if (m_db.isOpen())
            return true;
    } else {
        m_db = QSqlDatabase::addDatabase(QStringLiteral("QSQLITE"), QStringLiteral("charge_pile_conn"));
    }

    m_db.setDatabaseName(dbPath);
    if (!m_db.open()) {
        m_lastError = m_db.lastError().text();
        return false;
    }

    QSqlQuery q(m_db);
    q.exec(QStringLiteral("PRAGMA foreign_keys = ON"));
    return true;
}

bool DatabaseManager::execSqlFile(const QString &filePath)
{
    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        m_lastError = QStringLiteral("无法打开 SQL 文件: %1").arg(filePath);
        return false;
    }

    const QString content = QString::fromUtf8(file.readAll());
    const QStringList statements = content.split(';', Qt::SkipEmptyParts);
    QSqlQuery query(m_db);
    for (QString stmt : statements) {
        stmt = stmt.trimmed();
        if (stmt.isEmpty() || stmt.startsWith(QStringLiteral("--")))
            continue;
        // 去掉纯注释行后的空语句
        QString cleaned;
        for (const QString &line : stmt.split('\n')) {
            if (!line.trimmed().startsWith(QStringLiteral("--")))
                cleaned += line + '\n';
        }
        cleaned = cleaned.trimmed();
        if (cleaned.isEmpty())
            continue;
        if (!query.exec(cleaned)) {
            m_lastError = query.lastError().text() + " | SQL: " + cleaned.left(80);
            return false;
        }
    }
    return true;
}

bool DatabaseManager::ensureSchemaAndSeed()
{
    QSqlQuery check(m_db);
    if (!check.exec(QStringLiteral("SELECT name FROM sqlite_master WHERE type='table' AND name='users'"))) {
        m_lastError = check.lastError().text();
        return false;
    }
    const bool needInit = !check.next();

    if (!needInit)
        return true;

    const QStringList candidates = {
        QCoreApplication::applicationDirPath() + "/database",
        QCoreApplication::applicationDirPath() + "/../database",
        QDir(QCoreApplication::applicationDirPath() + "/../..").absolutePath() + "/database",
        QDir::currentPath() + "/database",
        QDir::currentPath() + "/../database"
    };

    QString schemaPath;
    QString seedPath;
    for (const QString &dir : candidates) {
        if (QFileInfo::exists(dir + "/schema.sql")) {
            schemaPath = dir + "/schema.sql";
            seedPath = dir + "/seed.sql";
            break;
        }
    }

    if (schemaPath.isEmpty()) {
        m_lastError = QStringLiteral("未找到 database/schema.sql，请确认构建时已复制 database 目录");
        return false;
    }

    if (!execSqlFile(schemaPath))
        return false;
    if (QFileInfo::exists(seedPath) && !execSqlFile(seedPath))
        return false;
    return true;
}

double DatabaseManager::haversineKm(double lat1, double lon1, double lat2, double lon2) const
{
    constexpr double R = 6371.0;
    const double dLat = qDegreesToRadians(lat2 - lat1);
    const double dLon = qDegreesToRadians(lon2 - lon1);
    const double a = qSin(dLat / 2) * qSin(dLat / 2)
                   + qCos(qDegreesToRadians(lat1)) * qCos(qDegreesToRadians(lat2))
                   * qSin(dLon / 2) * qSin(dLon / 2);
    return R * 2 * qAtan2(qSqrt(a), qSqrt(1 - a));
}

QString DatabaseManager::makeOrderNo() const
{
    return QStringLiteral("ORD%1").arg(QDateTime::currentDateTime().toString("yyyyMMddhhmmsszzz"));
}

bool DatabaseManager::loginUser(const QString &username, const QString &password, User &outUser)
{
    QSqlQuery q(m_db);
    q.prepare(QStringLiteral("SELECT id, username, password, phone, balance, car_model, plate_number, created_at "
                             "FROM users WHERE username=? AND password=?"));
    q.addBindValue(username);
    q.addBindValue(password);
    if (!q.exec() || !q.next()) {
        m_lastError = QStringLiteral("用户名或密码错误");
        return false;
    }
    outUser.id = q.value(0).toInt();
    outUser.username = q.value(1).toString();
    outUser.password = q.value(2).toString();
    outUser.phone = q.value(3).toString();
    outUser.balance = q.value(4).toDouble();
    outUser.carModel = q.value(5).toString();
    outUser.plateNumber = q.value(6).toString();
    outUser.createdAt = q.value(7).toString();
    return true;
}

bool DatabaseManager::loginAdmin(const QString &username, const QString &password, Admin &outAdmin)
{
    QSqlQuery q(m_db);
    q.prepare(QStringLiteral("SELECT id, username, password, real_name, role FROM admins WHERE username=? AND password=?"));
    q.addBindValue(username);
    q.addBindValue(password);
    if (!q.exec() || !q.next()) {
        m_lastError = QStringLiteral("管理员账号或密码错误");
        return false;
    }
    outAdmin.id = q.value(0).toInt();
    outAdmin.username = q.value(1).toString();
    outAdmin.password = q.value(2).toString();
    outAdmin.realName = q.value(3).toString();
    outAdmin.role = q.value(4).toString();
    return true;
}

bool DatabaseManager::registerUser(const User &user)
{
    QSqlQuery q(m_db);
    q.prepare(QStringLiteral("INSERT INTO users(username, password, phone, balance, car_model, plate_number) "
                             "VALUES(?,?,?,?,?,?)"));
    q.addBindValue(user.username);
    q.addBindValue(user.password);
    q.addBindValue(user.phone);
    q.addBindValue(user.balance);
    q.addBindValue(user.carModel);
    q.addBindValue(user.plateNumber);
    if (!q.exec()) {
        m_lastError = q.lastError().text();
        return false;
    }
    return true;
}

bool DatabaseManager::getUserById(int id, User &outUser)
{
    QSqlQuery q(m_db);
    q.prepare(QStringLiteral("SELECT id, username, password, phone, balance, car_model, plate_number, created_at "
                             "FROM users WHERE id=?"));
    q.addBindValue(id);
    if (!q.exec() || !q.next()) {
        m_lastError = QStringLiteral("用户不存在");
        return false;
    }
    outUser.id = q.value(0).toInt();
    outUser.username = q.value(1).toString();
    outUser.password = q.value(2).toString();
    outUser.phone = q.value(3).toString();
    outUser.balance = q.value(4).toDouble();
    outUser.carModel = q.value(5).toString();
    outUser.plateNumber = q.value(6).toString();
    outUser.createdAt = q.value(7).toString();
    return true;
}

bool DatabaseManager::updateUser(const User &user)
{
    QSqlQuery q(m_db);
    q.prepare(QStringLiteral("UPDATE users SET phone=?, car_model=?, plate_number=?, password=? WHERE id=?"));
    q.addBindValue(user.phone);
    q.addBindValue(user.carModel);
    q.addBindValue(user.plateNumber);
    q.addBindValue(user.password);
    q.addBindValue(user.id);
    if (!q.exec()) {
        m_lastError = q.lastError().text();
        return false;
    }
    return true;
}

bool DatabaseManager::rechargeUser(int userId, double amount)
{
    if (amount <= 0) {
        m_lastError = QStringLiteral("充值金额必须大于 0");
        return false;
    }
    m_db.transaction();
    QSqlQuery q(m_db);
    q.prepare(QStringLiteral("UPDATE users SET balance = balance + ? WHERE id=?"));
    q.addBindValue(amount);
    q.addBindValue(userId);
    if (!q.exec()) {
        m_db.rollback();
        m_lastError = q.lastError().text();
        return false;
    }
    q.prepare(QStringLiteral("INSERT INTO recharge_records(user_id, amount) VALUES(?,?)"));
    q.addBindValue(userId);
    q.addBindValue(amount);
    if (!q.exec()) {
        m_db.rollback();
        m_lastError = q.lastError().text();
        return false;
    }
    m_db.commit();
    return true;
}

QVector<User> DatabaseManager::listUsers(const QString &keyword)
{
    QVector<User> list;
    QSqlQuery q(m_db);
    if (keyword.trimmed().isEmpty()) {
        q.exec(QStringLiteral("SELECT id, username, password, phone, balance, car_model, plate_number, created_at "
                              "FROM users ORDER BY id"));
    } else {
        q.prepare(QStringLiteral("SELECT id, username, password, phone, balance, car_model, plate_number, created_at "
                                 "FROM users WHERE username LIKE ? OR phone LIKE ? OR plate_number LIKE ? ORDER BY id"));
        const QString key = "%" + keyword.trimmed() + "%";
        q.addBindValue(key);
        q.addBindValue(key);
        q.addBindValue(key);
        q.exec();
    }
    while (q.next()) {
        User u;
        u.id = q.value(0).toInt();
        u.username = q.value(1).toString();
        u.password = q.value(2).toString();
        u.phone = q.value(3).toString();
        u.balance = q.value(4).toDouble();
        u.carModel = q.value(5).toString();
        u.plateNumber = q.value(6).toString();
        u.createdAt = q.value(7).toString();
        list.push_back(u);
    }
    return list;
}

bool DatabaseManager::deleteUser(int id)
{
    QSqlQuery q(m_db);
    q.prepare(QStringLiteral("DELETE FROM users WHERE id=?"));
    q.addBindValue(id);
    if (!q.exec()) {
        m_lastError = q.lastError().text();
        return false;
    }
    return true;
}

QVector<Station> DatabaseManager::listStations(double userLat, double userLng, const QString &keyword)
{
    QVector<Station> list;
    QSqlQuery q(m_db);
    QString sql = QStringLiteral(
        "SELECT s.id, s.name, s.address, s.latitude, s.longitude, s.open_hours, s.status, "
        "COUNT(p.id) AS total_piles, "
        "SUM(CASE WHEN p.status='idle' THEN 1 ELSE 0 END) AS idle_piles "
        "FROM stations s LEFT JOIN piles p ON p.station_id = s.id ");
    if (!keyword.trimmed().isEmpty()) {
        sql += QStringLiteral("WHERE s.name LIKE ? OR s.address LIKE ? ");
    }
    sql += QStringLiteral("GROUP BY s.id ORDER BY s.id");

    if (!keyword.trimmed().isEmpty()) {
        q.prepare(sql);
        const QString key = "%" + keyword.trimmed() + "%";
        q.addBindValue(key);
        q.addBindValue(key);
        q.exec();
    } else {
        q.exec(sql);
    }

    while (q.next()) {
        Station s;
        s.id = q.value(0).toInt();
        s.name = q.value(1).toString();
        s.address = q.value(2).toString();
        s.latitude = q.value(3).toDouble();
        s.longitude = q.value(4).toDouble();
        s.openHours = q.value(5).toString();
        s.status = q.value(6).toString();
        s.totalPiles = q.value(7).toInt();
        s.idlePiles = q.value(8).toInt();
        s.distanceKm = haversineKm(userLat, userLng, s.latitude, s.longitude);
        list.push_back(s);
    }

    std::sort(list.begin(), list.end(), [](const Station &a, const Station &b) {
        return a.distanceKm < b.distanceKm;
    });
    return list;
}

bool DatabaseManager::getStation(int id, Station &out)
{
    QSqlQuery q(m_db);
    q.prepare(QStringLiteral("SELECT id, name, address, latitude, longitude, open_hours, status FROM stations WHERE id=?"));
    q.addBindValue(id);
    if (!q.exec() || !q.next()) {
        m_lastError = QStringLiteral("充电站不存在");
        return false;
    }
    out.id = q.value(0).toInt();
    out.name = q.value(1).toString();
    out.address = q.value(2).toString();
    out.latitude = q.value(3).toDouble();
    out.longitude = q.value(4).toDouble();
    out.openHours = q.value(5).toString();
    out.status = q.value(6).toString();
    return true;
}

bool DatabaseManager::saveStation(Station &station)
{
    QSqlQuery q(m_db);
    if (station.id == 0) {
        q.prepare(QStringLiteral("INSERT INTO stations(name, address, latitude, longitude, open_hours, status) "
                                 "VALUES(?,?,?,?,?,?)"));
        q.addBindValue(station.name);
        q.addBindValue(station.address);
        q.addBindValue(station.latitude);
        q.addBindValue(station.longitude);
        q.addBindValue(station.openHours);
        q.addBindValue(station.status);
        if (!q.exec()) {
            m_lastError = q.lastError().text();
            return false;
        }
        station.id = q.lastInsertId().toInt();
    } else {
        q.prepare(QStringLiteral("UPDATE stations SET name=?, address=?, latitude=?, longitude=?, open_hours=?, status=? "
                                 "WHERE id=?"));
        q.addBindValue(station.name);
        q.addBindValue(station.address);
        q.addBindValue(station.latitude);
        q.addBindValue(station.longitude);
        q.addBindValue(station.openHours);
        q.addBindValue(station.status);
        q.addBindValue(station.id);
        if (!q.exec()) {
            m_lastError = q.lastError().text();
            return false;
        }
    }
    return true;
}

bool DatabaseManager::deleteStation(int id)
{
    QSqlQuery q(m_db);
    q.prepare(QStringLiteral("DELETE FROM stations WHERE id=?"));
    q.addBindValue(id);
    if (!q.exec()) {
        m_lastError = q.lastError().text();
        return false;
    }
    return true;
}

QVector<Pile> DatabaseManager::listPiles(int stationId, const QString &status)
{
    QVector<Pile> list;
    QString sql = QStringLiteral(
        "SELECT p.id, p.station_id, p.pile_code, p.pile_type, p.power_kw, p.price_per_kwh, p.status, s.name "
        "FROM piles p JOIN stations s ON s.id = p.station_id WHERE 1=1");
    if (stationId > 0)
        sql += QStringLiteral(" AND p.station_id=%1").arg(stationId);
    if (!status.isEmpty())
        sql += QStringLiteral(" AND p.status='%1'").arg(status);
    sql += QStringLiteral(" ORDER BY p.id");

    QSqlQuery q(m_db);
    if (!q.exec(sql)) {
        m_lastError = q.lastError().text();
        return list;
    }
    while (q.next()) {
        Pile p;
        p.id = q.value(0).toInt();
        p.stationId = q.value(1).toInt();
        p.pileCode = q.value(2).toString();
        p.pileType = q.value(3).toString();
        p.powerKw = q.value(4).toDouble();
        p.pricePerKwh = q.value(5).toDouble();
        p.status = q.value(6).toString();
        p.stationName = q.value(7).toString();
        list.push_back(p);
    }
    return list;
}

bool DatabaseManager::getPile(int id, Pile &out)
{
    QSqlQuery q(m_db);
    q.prepare(QStringLiteral(
        "SELECT p.id, p.station_id, p.pile_code, p.pile_type, p.power_kw, p.price_per_kwh, p.status, s.name "
        "FROM piles p JOIN stations s ON s.id = p.station_id WHERE p.id=?"));
    q.addBindValue(id);
    if (!q.exec() || !q.next()) {
        m_lastError = QStringLiteral("充电桩不存在");
        return false;
    }
    out.id = q.value(0).toInt();
    out.stationId = q.value(1).toInt();
    out.pileCode = q.value(2).toString();
    out.pileType = q.value(3).toString();
    out.powerKw = q.value(4).toDouble();
    out.pricePerKwh = q.value(5).toDouble();
    out.status = q.value(6).toString();
    out.stationName = q.value(7).toString();
    return true;
}

bool DatabaseManager::savePile(Pile &pile)
{
    QSqlQuery q(m_db);
    if (pile.id == 0) {
        q.prepare(QStringLiteral("INSERT INTO piles(station_id, pile_code, pile_type, power_kw, price_per_kwh, status) "
                                 "VALUES(?,?,?,?,?,?)"));
        q.addBindValue(pile.stationId);
        q.addBindValue(pile.pileCode);
        q.addBindValue(pile.pileType);
        q.addBindValue(pile.powerKw);
        q.addBindValue(pile.pricePerKwh);
        q.addBindValue(pile.status);
        if (!q.exec()) {
            m_lastError = q.lastError().text();
            return false;
        }
        pile.id = q.lastInsertId().toInt();
    } else {
        q.prepare(QStringLiteral("UPDATE piles SET station_id=?, pile_code=?, pile_type=?, power_kw=?, price_per_kwh=?, status=? "
                                 "WHERE id=?"));
        q.addBindValue(pile.stationId);
        q.addBindValue(pile.pileCode);
        q.addBindValue(pile.pileType);
        q.addBindValue(pile.powerKw);
        q.addBindValue(pile.pricePerKwh);
        q.addBindValue(pile.status);
        q.addBindValue(pile.id);
        if (!q.exec()) {
            m_lastError = q.lastError().text();
            return false;
        }
    }
    return true;
}

bool DatabaseManager::deletePile(int id)
{
    QSqlQuery q(m_db);
    q.prepare(QStringLiteral("DELETE FROM piles WHERE id=?"));
    q.addBindValue(id);
    if (!q.exec()) {
        m_lastError = q.lastError().text();
        return false;
    }
    return true;
}

bool DatabaseManager::updatePileStatus(int pileId, const QString &status)
{
    QSqlQuery q(m_db);
    q.prepare(QStringLiteral("UPDATE piles SET status=? WHERE id=?"));
    q.addBindValue(status);
    q.addBindValue(pileId);
    if (!q.exec()) {
        m_lastError = q.lastError().text();
        return false;
    }
    return true;
}

bool DatabaseManager::startCharging(int userId, int pileId, ChargingOrder &outOrder)
{
    User user;
    if (!getUserById(userId, user))
        return false;
    if (user.balance < 10.0) {
        m_lastError = QStringLiteral("余额不足，请先充值（至少保留 10 元）");
        return false;
    }

    ChargingOrder ongoing;
    if (getOngoingOrderByUser(userId, ongoing)) {
        m_lastError = QStringLiteral("已有进行中的充电订单，请先结束当前充电");
        return false;
    }

    Pile pile;
    if (!getPile(pileId, pile))
        return false;
    if (pile.status != "idle") {
        m_lastError = QStringLiteral("该充电桩当前不可用：%1").arg(statusTextPile(pile.status));
        return false;
    }

    m_db.transaction();
    QSqlQuery q(m_db);
    const QString orderNo = makeOrderNo();
    const QString now = QDateTime::currentDateTime().toString("yyyy-MM-dd HH:mm:ss");
    q.prepare(QStringLiteral("INSERT INTO charging_orders(order_no, user_id, pile_id, start_time, energy_kwh, amount, status) "
                             "VALUES(?,?,?,?,0,0,'ongoing')"));
    q.addBindValue(orderNo);
    q.addBindValue(userId);
    q.addBindValue(pileId);
    q.addBindValue(now);
    if (!q.exec()) {
        m_db.rollback();
        m_lastError = q.lastError().text();
        return false;
    }
    const int orderId = q.lastInsertId().toInt();
    if (!updatePileStatus(pileId, QStringLiteral("charging"))) {
        m_db.rollback();
        return false;
    }
    m_db.commit();

    outOrder.id = orderId;
    outOrder.orderNo = orderNo;
    outOrder.userId = userId;
    outOrder.pileId = pileId;
    outOrder.startTime = now;
    outOrder.energyKwh = 0;
    outOrder.amount = 0;
    outOrder.status = QStringLiteral("ongoing");
    outOrder.pileCode = pile.pileCode;
    outOrder.stationName = pile.stationName;
    return true;
}

bool DatabaseManager::stopCharging(int orderId, double energyKwh, ChargingOrder &outOrder)
{
    QSqlQuery q(m_db);
    q.prepare(QStringLiteral(
        "SELECT o.id, o.order_no, o.user_id, o.pile_id, o.start_time, o.status, p.price_per_kwh "
        "FROM charging_orders o JOIN piles p ON p.id = o.pile_id WHERE o.id=?"));
    q.addBindValue(orderId);
    if (!q.exec() || !q.next()) {
        m_lastError = QStringLiteral("订单不存在");
        return false;
    }
    if (q.value(5).toString() != "ongoing") {
        m_lastError = QStringLiteral("订单不在进行中");
        return false;
    }

    const int userId = q.value(2).toInt();
    const int pileId = q.value(3).toInt();
    const double price = q.value(6).toDouble();
    const double amount = qRound(energyKwh * price * 100.0) / 100.0;
    const QString endTime = QDateTime::currentDateTime().toString("yyyy-MM-dd HH:mm:ss");

    User user;
    if (!getUserById(userId, user))
        return false;
    if (user.balance < amount) {
        m_lastError = QStringLiteral("余额不足以支付本次充电费用 ¥%1").arg(amount, 0, 'f', 2);
        return false;
    }

    m_db.transaction();
    QSqlQuery u(m_db);
    u.prepare(QStringLiteral("UPDATE charging_orders SET end_time=?, energy_kwh=?, amount=?, status='finished' WHERE id=?"));
    u.addBindValue(endTime);
    u.addBindValue(energyKwh);
    u.addBindValue(amount);
    u.addBindValue(orderId);
    if (!u.exec()) {
        m_db.rollback();
        m_lastError = u.lastError().text();
        return false;
    }
    u.prepare(QStringLiteral("UPDATE users SET balance = balance - ? WHERE id=?"));
    u.addBindValue(amount);
    u.addBindValue(userId);
    if (!u.exec()) {
        m_db.rollback();
        m_lastError = u.lastError().text();
        return false;
    }
    if (!updatePileStatus(pileId, QStringLiteral("idle"))) {
        m_db.rollback();
        return false;
    }
    m_db.commit();

    outOrder.id = orderId;
    outOrder.orderNo = q.value(1).toString();
    outOrder.userId = userId;
    outOrder.pileId = pileId;
    outOrder.startTime = q.value(4).toString();
    outOrder.endTime = endTime;
    outOrder.energyKwh = energyKwh;
    outOrder.amount = amount;
    outOrder.status = QStringLiteral("finished");
    return true;
}

bool DatabaseManager::getOngoingOrderByUser(int userId, ChargingOrder &outOrder)
{
    QSqlQuery q(m_db);
    q.prepare(QStringLiteral(
        "SELECT o.id, o.order_no, o.user_id, o.pile_id, o.start_time, o.end_time, o.energy_kwh, o.amount, o.status, "
        "p.pile_code, s.name "
        "FROM charging_orders o "
        "JOIN piles p ON p.id = o.pile_id "
        "JOIN stations s ON s.id = p.station_id "
        "WHERE o.user_id=? AND o.status='ongoing' LIMIT 1"));
    q.addBindValue(userId);
    if (!q.exec() || !q.next())
        return false;

    outOrder.id = q.value(0).toInt();
    outOrder.orderNo = q.value(1).toString();
    outOrder.userId = q.value(2).toInt();
    outOrder.pileId = q.value(3).toInt();
    outOrder.startTime = q.value(4).toString();
    outOrder.endTime = q.value(5).toString();
    outOrder.energyKwh = q.value(6).toDouble();
    outOrder.amount = q.value(7).toDouble();
    outOrder.status = q.value(8).toString();
    outOrder.pileCode = q.value(9).toString();
    outOrder.stationName = q.value(10).toString();
    return true;
}

QVector<ChargingOrder> DatabaseManager::listOrders(int userId, const QString &status)
{
    QVector<ChargingOrder> list;
    QString sql = QStringLiteral(
        "SELECT o.id, o.order_no, o.user_id, o.pile_id, o.start_time, o.end_time, o.energy_kwh, o.amount, o.status, "
        "u.username, p.pile_code, s.name "
        "FROM charging_orders o "
        "JOIN users u ON u.id = o.user_id "
        "JOIN piles p ON p.id = o.pile_id "
        "JOIN stations s ON s.id = p.station_id WHERE 1=1");
    if (userId > 0)
        sql += QStringLiteral(" AND o.user_id=%1").arg(userId);
    if (!status.isEmpty())
        sql += QStringLiteral(" AND o.status='%1'").arg(status);
    sql += QStringLiteral(" ORDER BY o.id DESC");

    QSqlQuery q(m_db);
    if (!q.exec(sql)) {
        m_lastError = q.lastError().text();
        return list;
    }
    while (q.next()) {
        ChargingOrder o;
        o.id = q.value(0).toInt();
        o.orderNo = q.value(1).toString();
        o.userId = q.value(2).toInt();
        o.pileId = q.value(3).toInt();
        o.startTime = q.value(4).toString();
        o.endTime = q.value(5).toString();
        o.energyKwh = q.value(6).toDouble();
        o.amount = q.value(7).toDouble();
        o.status = q.value(8).toString();
        o.username = q.value(9).toString();
        o.pileCode = q.value(10).toString();
        o.stationName = q.value(11).toString();
        list.push_back(o);
    }
    return list;
}

DatabaseManager::SalesStats DatabaseManager::salesStats() const
{
    SalesStats s;
    QSqlQuery q(m_db);

    q.exec(QStringLiteral("SELECT COALESCE(SUM(amount),0), COUNT(*) FROM charging_orders "
                          "WHERE status='finished' AND date(end_time)=date('now','localtime')"));
    if (q.next()) {
        s.todayAmount = q.value(0).toDouble();
        s.todayOrders = q.value(1).toInt();
    }

    q.exec(QStringLiteral("SELECT COALESCE(SUM(amount),0), COUNT(*) FROM charging_orders "
                          "WHERE status='finished' AND strftime('%Y-%m', end_time)=strftime('%Y-%m','now','localtime')"));
    if (q.next()) {
        s.monthAmount = q.value(0).toDouble();
        s.monthOrders = q.value(1).toInt();
    }

    q.exec(QStringLiteral("SELECT COALESCE(SUM(amount),0), COUNT(*) FROM charging_orders WHERE status='finished'"));
    if (q.next()) {
        s.totalAmount = q.value(0).toDouble();
        s.totalOrders = q.value(1).toInt();
    }

    q.exec(QStringLiteral("SELECT status, COUNT(*) FROM piles GROUP BY status"));
    while (q.next()) {
        const QString st = q.value(0).toString();
        const int c = q.value(1).toInt();
        if (st == "idle") s.idlePiles = c;
        else if (st == "charging") s.chargingPiles = c;
        else if (st == "fault") s.faultPiles = c;
        else if (st == "offline") s.offlinePiles = c;
    }

    q.exec(QStringLiteral("SELECT COUNT(*) FROM users"));
    if (q.next()) s.totalUsers = q.value(0).toInt();
    q.exec(QStringLiteral("SELECT COUNT(*) FROM stations"));
    if (q.next()) s.totalStations = q.value(0).toInt();
    return s;
}

QVector<QPair<QString, double>> DatabaseManager::dailySales(int days) const
{
    QVector<QPair<QString, double>> result;
    QSqlQuery q(m_db);
    q.prepare(QStringLiteral(
        "SELECT date(end_time) AS d, COALESCE(SUM(amount),0) "
        "FROM charging_orders "
        "WHERE status='finished' AND date(end_time) >= date('now','localtime', ?) "
        "GROUP BY d ORDER BY d"));
    q.addBindValue(QStringLiteral("-%1 day").arg(days - 1));
    q.exec();
    while (q.next())
        result.push_back({q.value(0).toString(), q.value(1).toDouble()});
    return result;
}
