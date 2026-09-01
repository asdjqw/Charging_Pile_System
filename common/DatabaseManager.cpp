#include "DatabaseManager.h"

#include <algorithm>

#include <QCoreApplication>
#include <QDateTime>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QHash>
#include <QSqlError>
#include <QSqlQuery>
#include <QStandardPaths>
#include <QStringConverter>
#include <QTextStream>
#include <QtMath>
#include <QVariant>
#include <QVector>

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
    if (!q.exec(QStringLiteral("PRAGMA foreign_keys = ON"))) {
        m_lastError = q.lastError().text();
        return false;
    }
    // WAL 允许服务端读写并发；短事务争用时最多等待 5 秒。
    q.exec(QStringLiteral("PRAGMA journal_mode = WAL"));
    q.exec(QStringLiteral("PRAGMA synchronous = NORMAL"));
    q.exec(QStringLiteral("PRAGMA busy_timeout = 5000"));
    return true;
}

bool DatabaseManager::execSqlFile(const QString &filePath)
{
    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        m_lastError = QStringLiteral("无法打开 SQL 文件: %1").arg(filePath);
        return false;
    }

    // 先逐行移除注释。旧实现会误删位于注释之后的整个 CREATE TABLE 语句。
    QString cleanedContent;
    const QString content = QString::fromUtf8(file.readAll());
    for (const QString &line : content.split('\n')) {
        if (!line.trimmed().startsWith(QStringLiteral("--")))
            cleanedContent += line + '\n';
    }

    const QStringList statements = cleanedContent.split(';', Qt::SkipEmptyParts);
    QSqlQuery query(m_db);
    for (QString stmt : statements) {
        stmt = stmt.trimmed();
        if (stmt.isEmpty())
            continue;
        if (!query.exec(stmt)) {
            m_lastError = query.lastError().text() + " | SQL: " + stmt.left(120);
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

    if (needInit) {
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
    }

    if (!ensurePileColumns())
        return false;

    const int stations = stationCount();
    const int piles = pileCount();
    if (stations == 0 || piles < stations * 3) {
        if (!importBeijingCsv(QString(), stations > 0))
            return false;
    }
    return true;
}

bool DatabaseManager::ensurePileColumns()
{
    QSqlQuery q(m_db);
    q.exec(QStringLiteral("ALTER TABLE piles ADD COLUMN speed_class TEXT NOT NULL DEFAULT 'slow'"));
    q.exec(QStringLiteral("ALTER TABLE piles ADD COLUMN connector_standard TEXT NOT NULL DEFAULT 'GB_T_AC'"));
    q.exec(QStringLiteral("ALTER TABLE piles ADD COLUMN phase TEXT NOT NULL DEFAULT 'single'"));
    q.exec(QStringLiteral("ALTER TABLE piles ADD COLUMN voltage_v INTEGER NOT NULL DEFAULT 220"));
    q.exec(QStringLiteral("ALTER TABLE piles ADD COLUMN category_label TEXT NOT NULL DEFAULT ''"));
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
    if (user.username.trimmed().isEmpty() || user.password.isEmpty()) {
        m_lastError = QStringLiteral("用户名和密码不能为空");
        return false;
    }
    QString phone = user.phone.trimmed();
    if (phone.length() != 11) {
        const uint h = qHash(user.username.trimmed());
        phone = QStringLiteral("139%1").arg(h % 100000000, 8, 10, QChar('0'));
    }
    QSqlQuery q(m_db);
    q.prepare(QStringLiteral("INSERT INTO users(username, password, phone, nickname, balance, car_model, plate_number) "
                             "VALUES(?,?,?,?,?,?,?)"));
    q.addBindValue(user.username.trimmed());
    q.addBindValue(user.password);
    q.addBindValue(phone);
    q.addBindValue(user.nickname.isEmpty() ? user.username.trimmed() : user.nickname);
    q.addBindValue(user.balance > 0 ? user.balance : 50.0);
    q.addBindValue(user.carModel.isEmpty() ? QStringLiteral("未填写") : user.carModel);
    q.addBindValue(user.plateNumber.isEmpty() ? QStringLiteral("未填写") : user.plateNumber);
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

QVector<Station> DatabaseManager::listStations(double userLat, double userLng,
                                               const QString &keyword,
                                               const QString &district,
                                               int limit)
{
    QVector<Station> list;
    QSqlQuery q(m_db);
    QString sql = QStringLiteral(
        "SELECT s.id, s.name, s.address, s.region_code, s.latitude, s.longitude, s.open_hours, s.status, "
        "COUNT(p.id) AS total_piles, "
        "SUM(CASE WHEN p.status='idle' THEN 1 ELSE 0 END) AS idle_piles "
        "FROM stations s LEFT JOIN piles p ON p.station_id = s.id WHERE 1=1 ");
    QStringList binds;
    if (!keyword.trimmed().isEmpty()) {
        sql += QStringLiteral("AND (s.name LIKE ? OR s.address LIKE ?) ");
        const QString key = QStringLiteral("%") + keyword.trimmed() + QStringLiteral("%");
        binds << key << key;
    }
    if (!district.trimmed().isEmpty()) {
        sql += QStringLiteral("AND s.region_code LIKE ? ");
        binds << (QStringLiteral("%") + district.trimmed() + QStringLiteral("%"));
    }
    sql += QStringLiteral("GROUP BY s.id");

    q.prepare(sql);
    for (const QString &b : binds)
        q.addBindValue(b);
    if (!q.exec()) {
        m_lastError = q.lastError().text();
        return list;
    }

    while (q.next()) {
        Station s;
        s.id = q.value(0).toInt();
        s.name = q.value(1).toString();
        s.address = q.value(2).toString();
        s.regionCode = q.value(3).toString();
        s.latitude = q.value(4).toDouble();
        s.longitude = q.value(5).toDouble();
        s.openHours = q.value(6).toString();
        s.status = q.value(7).toString();
        s.totalPiles = q.value(8).toInt();
        s.idlePiles = q.value(9).toInt();
        s.distanceKm = haversineKm(userLat, userLng, s.latitude, s.longitude);
        list.push_back(s);
    }

    std::sort(list.begin(), list.end(), [](const Station &a, const Station &b) {
        return a.distanceKm < b.distanceKm;
    });
    if (limit > 0 && list.size() > limit)
        list.resize(limit);
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

QVector<Pile> DatabaseManager::listPiles(int stationId, const QString &status,
                                         const QString &speedClass, const QString &connector)
{
    QVector<Pile> list;
    QString sql = QStringLiteral(
        "SELECT p.id, p.station_id, p.pile_code, p.pile_type, "
        "COALESCE(p.speed_class,'slow'), COALESCE(p.connector_standard,'GB_T_AC'), "
        "COALESCE(p.phase,'single'), COALESCE(p.voltage_v,220), COALESCE(p.category_label,''), "
        "p.power_kw, p.price_per_kwh, p.status, s.name "
        "FROM piles p JOIN stations s ON s.id = p.station_id WHERE 1=1");
    if (stationId > 0)
        sql += QStringLiteral(" AND p.station_id=%1").arg(stationId);
    if (!status.isEmpty())
        sql += QStringLiteral(" AND p.status='%1'").arg(status);
    if (!speedClass.isEmpty())
        sql += QStringLiteral(" AND p.speed_class='%1'").arg(speedClass);
    if (!connector.isEmpty())
        sql += QStringLiteral(" AND p.connector_standard='%1'").arg(connector);
    sql += QStringLiteral(" ORDER BY p.id");
    if (stationId <= 0)
        sql += QStringLiteral(" LIMIT 500");

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
        p.speedClass = q.value(4).toString();
        p.connectorStandard = q.value(5).toString();
        p.phase = q.value(6).toString();
        p.voltageV = q.value(7).toInt();
        p.categoryLabel = q.value(8).toString();
        p.powerKw = q.value(9).toDouble();
        p.pricePerKwh = q.value(10).toDouble();
        p.status = q.value(11).toString();
        p.stationName = q.value(12).toString();
        list.push_back(p);
    }
    return list;
}

bool DatabaseManager::getPile(int id, Pile &out)
{
    QSqlQuery q(m_db);
    q.prepare(QStringLiteral(
        "SELECT p.id, p.station_id, p.pile_code, p.pile_type, "
        "COALESCE(p.speed_class,'slow'), COALESCE(p.connector_standard,'GB_T_AC'), "
        "COALESCE(p.phase,'single'), COALESCE(p.voltage_v,220), COALESCE(p.category_label,''), "
        "p.power_kw, p.price_per_kwh, p.status, s.name "
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
    out.speedClass = q.value(4).toString();
    out.connectorStandard = q.value(5).toString();
    out.phase = q.value(6).toString();
    out.voltageV = q.value(7).toInt();
    out.categoryLabel = q.value(8).toString();
    out.powerKw = q.value(9).toDouble();
    out.pricePerKwh = q.value(10).toDouble();
    out.status = q.value(11).toString();
    out.stationName = q.value(12).toString();
    return true;
}

bool DatabaseManager::savePile(Pile &pile)
{
    if (pile.categoryLabel.isEmpty())
        pile.categoryLabel = pileCategoryText(pile);
    QSqlQuery q(m_db);
    if (pile.id == 0) {
        q.prepare(QStringLiteral(
            "INSERT INTO piles(station_id, pile_code, pile_type, speed_class, connector_standard, "
            "phase, voltage_v, category_label, power_kw, price_per_kwh, status) "
            "VALUES(?,?,?,?,?,?,?,?,?,?,?)"));
        q.addBindValue(pile.stationId);
        q.addBindValue(pile.pileCode);
        q.addBindValue(pile.pileType);
        q.addBindValue(pile.speedClass.isEmpty() ? QStringLiteral("slow") : pile.speedClass);
        q.addBindValue(pile.connectorStandard.isEmpty() ? QStringLiteral("GB_T_AC") : pile.connectorStandard);
        q.addBindValue(pile.phase.isEmpty() ? QStringLiteral("single") : pile.phase);
        q.addBindValue(pile.voltageV > 0 ? pile.voltageV : 220);
        q.addBindValue(pile.categoryLabel);
        q.addBindValue(pile.powerKw);
        q.addBindValue(pile.pricePerKwh);
        q.addBindValue(pile.status);
        if (!q.exec()) {
            m_lastError = q.lastError().text();
            return false;
        }
        pile.id = q.lastInsertId().toInt();
    } else {
        q.prepare(QStringLiteral(
            "UPDATE piles SET station_id=?, pile_code=?, pile_type=?, speed_class=?, connector_standard=?, "
            "phase=?, voltage_v=?, category_label=?, power_kw=?, price_per_kwh=?, status=? WHERE id=?"));
        q.addBindValue(pile.stationId);
        q.addBindValue(pile.pileCode);
        q.addBindValue(pile.pileType);
        q.addBindValue(pile.speedClass);
        q.addBindValue(pile.connectorStandard);
        q.addBindValue(pile.phase);
        q.addBindValue(pile.voltageV);
        q.addBindValue(pile.categoryLabel);
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
    q.prepare(QStringLiteral("INSERT INTO charging_orders(order_no, user_id, pile_id, start_time, energy_kwh, amount, "
                             "price_per_kwh, status) VALUES(?,?,?,?,0,0,?,'ongoing')"));
    q.addBindValue(orderNo);
    q.addBindValue(userId);
    q.addBindValue(pileId);
    q.addBindValue(now);
    q.addBindValue(pile.pricePerKwh);
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
        "SELECT o.id, o.order_no, o.user_id, o.pile_id, o.start_time, o.status, "
        "COALESCE(NULLIF(o.price_per_kwh, 0), p.price_per_kwh) "
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
    u.prepare(QStringLiteral("UPDATE charging_orders SET end_time=?, energy_kwh=?, amount=?, "
                             "status='finished', payment_status='paid', paid_at=? WHERE id=?"));
    u.addBindValue(endTime);
    u.addBindValue(energyKwh);
    u.addBindValue(amount);
    u.addBindValue(endTime);
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

int DatabaseManager::stationCount() const
{
    QSqlQuery q(m_db);
    if (q.exec(QStringLiteral("SELECT COUNT(*) FROM stations")) && q.next())
        return q.value(0).toInt();
    return 0;
}

int DatabaseManager::pileCount() const
{
    QSqlQuery q(m_db);
    if (q.exec(QStringLiteral("SELECT COUNT(*) FROM piles")) && q.next())
        return q.value(0).toInt();
    return 0;
}

QStringList DatabaseManager::districts() const
{
    QStringList list;
    QSqlQuery q(m_db);
    if (!q.exec(QStringLiteral("SELECT DISTINCT region_code FROM stations "
                               "WHERE region_code IS NOT NULL AND region_code!='' "
                               "ORDER BY region_code")))
        return list;
    while (q.next())
        list << q.value(0).toString();
    return list;
}

QString DatabaseManager::resolveCsvPath(const QString &preferred) const
{
    if (!preferred.isEmpty() && QFileInfo::exists(preferred))
        return preferred;
    const QString fileName = QStringLiteral("北京市充电桩数据.csv");
    const QStringList candidates = {
        QCoreApplication::applicationDirPath() + QStringLiteral("/data/") + fileName,
        QCoreApplication::applicationDirPath() + QStringLiteral("/../data/") + fileName,
        QDir(QCoreApplication::applicationDirPath() + QStringLiteral("/../..")).absolutePath()
            + QStringLiteral("/data/") + fileName,
        QDir::currentPath() + QStringLiteral("/data/") + fileName,
        QStringLiteral("/home/bit/test/Charging_Pile_System/data/") + fileName,
    };
    for (const QString &path : candidates) {
        if (QFileInfo::exists(path))
            return path;
    }
    return {};
}

QStringList DatabaseManager::splitCsvLine(const QString &line)
{
    QStringList fields;
    QString cur;
    bool inQuotes = false;
    for (int i = 0; i < line.size(); ++i) {
        const QChar c = line.at(i);
        if (c == QLatin1Char('"')) {
            if (inQuotes && i + 1 < line.size() && line.at(i + 1) == QLatin1Char('"')) {
                cur.append(QLatin1Char('"'));
                ++i;
            } else {
                inQuotes = !inQuotes;
            }
        } else if (c == QLatin1Char(',') && !inQuotes) {
            fields.append(cur);
            cur.clear();
        } else {
            cur.append(c);
        }
    }
    fields.append(cur);
    return fields;
}

void DatabaseManager::appendClassifiedPiles(int stationId, const QString &stationCode, uint seed,
                                            double priceHint, QSqlQuery &q)
{
    struct Spec {
        const char *type;
        const char *speed;
        const char *connector;
        const char *phase;
        int voltage;
        double power;
        double priceMul;
        const char *status;
    };
    static const Spec kCatalog[] = {
        {"AC", "slow", "GB_T_AC", "single", 220, 7.0, 1.00, "idle"},
        {"AC", "standard", "GB_T_AC", "three", 380, 22.0, 1.05, "idle"},
        {"DC", "fast", "GB_T_DC", "three", 750, 60.0, 1.20, "idle"},
        {"DC", "ultra", "CCS2", "three", 800, 120.0, 1.35, "idle"},
    };
    static const Spec kExtra[] = {
        {"DC", "fast", "CHAdeMO", "three", 500, 50.0, 1.25, "idle"},
        {"DC", "ultra", "TeslaNACS", "three", 900, 250.0, 1.45, "idle"},
    };

    QVector<Spec> specs;
    for (const Spec &s : kCatalog)
        specs.push_back(s);
    specs.push_back(kExtra[seed % 2]);

    for (int i = 0; i < specs.size(); ++i) {
        const Spec &spec = specs[i];
        Pile p;
        p.stationId = stationId;
        p.pileCode = QStringLiteral("%1-P%2").arg(stationCode).arg(i + 1, 2, 10, QChar('0'));
        p.pileType = QString::fromLatin1(spec.type);
        p.speedClass = QString::fromLatin1(spec.speed);
        p.connectorStandard = QString::fromLatin1(spec.connector);
        p.phase = QString::fromLatin1(spec.phase);
        p.voltageV = spec.voltage;
        p.powerKw = spec.power;
        p.pricePerKwh = qMax(0.5, priceHint * spec.priceMul);
        p.status = QString::fromLatin1(spec.status);
        if ((seed + static_cast<uint>(i)) % 11 == 0)
            p.status = QStringLiteral("charging");
        else if ((seed + static_cast<uint>(i)) % 17 == 0)
            p.status = QStringLiteral("fault");
        p.categoryLabel = pileCategoryText(p);

        q.prepare(QStringLiteral(
            "INSERT INTO piles(station_id, pile_code, pile_type, speed_class, connector_standard, "
            "phase, voltage_v, category_label, power_kw, price_per_kwh, status) "
            "VALUES(?,?,?,?,?,?,?,?,?,?,?)"));
        q.addBindValue(p.stationId);
        q.addBindValue(p.pileCode);
        q.addBindValue(p.pileType);
        q.addBindValue(p.speedClass);
        q.addBindValue(p.connectorStandard);
        q.addBindValue(p.phase);
        q.addBindValue(p.voltageV);
        q.addBindValue(p.categoryLabel);
        q.addBindValue(p.powerKw);
        q.addBindValue(p.pricePerKwh);
        q.addBindValue(p.status);
        q.exec();
    }
}

bool DatabaseManager::importBeijingCsv(const QString &csvPath, bool force)
{
    const QString path = resolveCsvPath(csvPath);
    if (path.isEmpty()) {
        m_lastError = QStringLiteral("未找到 北京市充电桩数据.csv");
        return false;
    }
    if (!force && stationCount() > 0)
        return true;

    QFile file(path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        m_lastError = QStringLiteral("无法打开 CSV: %1").arg(path);
        return false;
    }

    QTextStream in(&file);
    in.setEncoding(QStringConverter::Utf8);
    const QString headerLine = in.readLine();
    if (headerLine.isEmpty()) {
        m_lastError = QStringLiteral("CSV 为空");
        return false;
    }

    const QStringList headers = splitCsvLine(headerLine);
    auto col = [&](const QStringList &aliases) -> int {
        for (int i = 0; i < headers.size(); ++i) {
            const QString h = headers.at(i).trimmed();
            for (const QString &a : aliases) {
                if (h.compare(a, Qt::CaseInsensitive) == 0)
                    return i;
            }
        }
        return -1;
    };

    const int cPoi = col({QStringLiteral("POI_ID"), QStringLiteral("ID")});
    const int cName = col({QStringLiteral("名称"), QStringLiteral("name")});
    const int cLng = col({QStringLiteral("经度"), QStringLiteral("longitude")});
    const int cLat = col({QStringLiteral("纬度"), QStringLiteral("latitude")});
    const int cAddr = col({QStringLiteral("地址"), QStringLiteral("address")});
    const int cDistrict = col({QStringLiteral("区县"), QStringLiteral("district")});
    if (cName < 0 || cLng < 0 || cLat < 0) {
        m_lastError = QStringLiteral("CSV 缺少必要列");
        return false;
    }

    m_db.transaction();
    QSqlQuery q(m_db);
    if (force) {
        q.exec(QStringLiteral("DELETE FROM charging_orders"));
        q.exec(QStringLiteral("DELETE FROM charging_reservations"));
        q.exec(QStringLiteral("DELETE FROM piles"));
        q.exec(QStringLiteral("DELETE FROM stations"));
    }

    int imported = 0;
    int seed = 0;
    while (!in.atEnd()) {
        const QString line = in.readLine();
        if (line.trimmed().isEmpty())
            continue;
        const QStringList cols = splitCsvLine(line);
        auto at = [&](int idx) -> QString {
            return (idx >= 0 && idx < cols.size()) ? cols.at(idx).trimmed() : QString();
        };
        const QString name = at(cName);
        const double lng = at(cLng).toDouble();
        const double lat = at(cLat).toDouble();
        if (name.isEmpty() || lat < 1.0 || lng < 1.0)
            continue;

        QString poi = at(cPoi);
        if (poi.isEmpty())
            poi = QStringLiteral("BJ%1").arg(++seed, 5, 10, QChar('0'));
        const QString stationCode = QStringLiteral("ST-%1").arg(poi);
        const QString address = at(cAddr).isEmpty() ? name : at(cAddr);
        const QString region = at(cDistrict);
        const double priceHint = 1.0 + (qHash(region) % 40) / 100.0;

        q.prepare(QStringLiteral(
            "INSERT OR IGNORE INTO stations(station_code, name, address, region_code, latitude, longitude, "
            "open_hours, status) VALUES(?,?,?,?,?,?, '00:00-24:00', 'open')"));
        q.addBindValue(stationCode);
        q.addBindValue(name);
        q.addBindValue(address);
        q.addBindValue(region);
        q.addBindValue(lat);
        q.addBindValue(lng);
        if (!q.exec()) {
            m_db.rollback();
            m_lastError = q.lastError().text();
            return false;
        }

        int stationId = 0;
        if (q.numRowsAffected() > 0) {
            stationId = q.lastInsertId().toInt();
        } else {
            QSqlQuery find(m_db);
            find.prepare(QStringLiteral("SELECT id FROM stations WHERE station_code=?"));
            find.addBindValue(stationCode);
            if (find.exec() && find.next())
                stationId = find.value(0).toInt();
        }
        if (stationId <= 0)
            continue;

        appendClassifiedPiles(stationId, stationCode, qHash(poi), priceHint, q);
        ++imported;
    }

    if (!m_db.commit()) {
        m_lastError = m_db.lastError().text();
        return false;
    }
    if (imported == 0) {
        m_lastError = QStringLiteral("CSV 未导入任何站点");
        return false;
    }
    return true;
}
