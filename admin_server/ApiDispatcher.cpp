#include "ApiDispatcher.h"

#include "DatabaseManager.h"
#include "JsonCodec.h"
#include "Models.h"

#include <algorithm>
#include <QDateTime>
#include <QJsonArray>
#include <QSet>
#include <QTimer>
#include <QUuid>

namespace {

QJsonArray stationsJson(const QVector<Station> &values)
{
    QJsonArray array;
    for (const Station &value : values)
        array.append(JsonCodec::toJson(value));
    return array;
}

QJsonArray pilesJson(const QVector<Pile> &values)
{
    QJsonArray array;
    for (const Pile &value : values)
        array.append(JsonCodec::toJson(value));
    return array;
}

QJsonArray ordersJson(const QVector<ChargingOrder> &values, int limit = -1)
{
    QJsonArray array;
    const int count = limit > 0 ? qMin(limit, values.size()) : values.size();
    for (int i = 0; i < count; ++i)
        array.append(JsonCodec::toJson(values.at(i)));
    return array;
}

} // namespace

ApiDispatcher::ApiDispatcher(QObject *parent)
    : QObject(parent)
{
}

QJsonObject ApiDispatcher::success(const QJsonObject &request, const QJsonValue &data,
                                   const QString &message) const
{
    return {{"version", 1}, {"requestId", request.value("requestId").toString()},
            {"ok", true}, {"code", "OK"}, {"message", message}, {"data", data}};
}

QJsonObject ApiDispatcher::failure(const QJsonObject &request, const QString &code,
                                   const QString &message) const
{
    return {{"version", 1}, {"requestId", request.value("requestId").toString()},
            {"ok", false}, {"code", code}, {"message", message}, {"data", QJsonObject()}};
}

int ApiDispatcher::authorizedUser(const QJsonObject &request)
{
    const QString token = request.value("token").toString();
    const auto it = m_sessions.find(token);
    if (it == m_sessions.end())
        return 0;
    if (it->expiresAt < QDateTime::currentDateTimeUtc()) {
        m_sessions.erase(it);
        return 0;
    }
    User user;
    if (!DatabaseManager::instance().getUserById(it->userId, user)
        || user.status == QLatin1String("frozen")) {
        m_sessions.erase(it);
        return 0;
    }
    return it->userId;
}

QJsonObject ApiDispatcher::dispatch(const QJsonObject &request)
{
    auto &db = DatabaseManager::instance();
    const QString action = request.value("action").toString();
    const QJsonObject data = request.value("data").toObject();

    if (action == QLatin1String("server.health")) {
        return success(request, QJsonObject{{"status", "ok"}, {"time", QDateTime::currentDateTime().toString(Qt::ISODate)},
                                 {"stations", db.stationCount()}, {"piles", db.pileCount()}});
    }

    if (action == QLatin1String("user.login")) {
        User user;
        if (!db.loginUser(data.value("username").toString(), data.value("password").toString(), user))
            return failure(request, QStringLiteral("AUTH_FAILED"), db.lastError());
        const QString token = QUuid::createUuid().toString(QUuid::WithoutBraces);
        m_sessions.insert(token, {user.id, QDateTime::currentDateTimeUtc().addSecs(12 * 60 * 60)});
        return success(request, QJsonObject{{"token", token}, {"user", JsonCodec::toJson(user)}});
    }

    if (action == QLatin1String("user.phoneLogin")) {
        User user;
        bool created = false;
        const QString password = data.value("password").toString();
        if (!password.isEmpty()) {
            if (!db.loginByPhone(data.value("phone").toString(), password, user)) {
                if (!db.lastError().contains(QStringLiteral("不存在")))
                    return failure(request, QStringLiteral("AUTH_FAILED"), db.lastError());
                User createdUser;
                createdUser.phone = data.value("phone").toString();
                createdUser.password = password;
                if (!db.registerUser(createdUser)
                    || !db.loginByPhone(createdUser.phone, password, user))
                    return failure(request, QStringLiteral("AUTH_FAILED"), db.lastError());
                created = true;
            }
        } else if (!db.phoneLogin(data.value("phone").toString(), user, created)) {
            return failure(request, QStringLiteral("AUTH_FAILED"), db.lastError());
        }
        const QString token = QUuid::createUuid().toString(QUuid::WithoutBraces);
        m_sessions.insert(token, {user.id, QDateTime::currentDateTimeUtc().addSecs(12 * 60 * 60)});
        return success(request, QJsonObject{{"token", token}, {"created", created},
                                            {"user", JsonCodec::toJson(user)}},
                       created ? QStringLiteral("已创建新用户") : QStringLiteral("登录成功"));
    }

    if (action == QLatin1String("user.register")) {
        User user;
        user.username = data.value("username").toString();
        user.password = data.value("password").toString();
        user.phone = data.value("phone").toString();
        user.nickname = data.value("nickname").toString();
        user.carModel = data.value("carModel").toString();
        user.plateNumber = data.value("plateNumber").toString();
        user.balance = data.value("balance").toDouble(50.0);
        if (!db.registerUser(user)) {
            const QString err = db.lastError();
            const QString code = err.contains(QStringLiteral("已注册"))
                                     ? QStringLiteral("ACCOUNT_EXISTS")
                                     : QStringLiteral("REGISTER_FAILED");
            return failure(request, code, err);
        }
        return success(request, QJsonObject(), QStringLiteral("注册成功"));
    }

    if (action == QLatin1String("admin.register")) {
        Admin admin;
        if (!db.registerAdmin(data.value("username").toString(),
                              data.value("password").toString(),
                              data.value("realName").toString(),
                              data.value("inviteCode").toString(), admin)) {
            const QString err = db.lastError();
            const QString code = err == QStringLiteral("账户已存在")
                                     ? QStringLiteral("ACCOUNT_EXISTS")
                                     : QStringLiteral("REGISTER_FAILED");
            return failure(request, code, err);
        }
        const QString token = QUuid::createUuid().toString(QUuid::WithoutBraces);
        m_adminSessions.insert(token, {admin.id, QDateTime::currentDateTimeUtc().addSecs(12 * 60 * 60)});
        return success(request, QJsonObject{{"token", token}, {"admin", JsonCodec::toJson(admin)}},
                       QStringLiteral("注册成功"));
    }

    if (action == QLatin1String("dashboard.summary")) {
        const int days = data.value("days").toInt(30) == 7 ? 7 : 30;
        return success(request, dashboardPayload(days));
    }

    if (action == QLatin1String("dashboard.stations")) {
        const int limit = qBound(1, data.value("limit").toInt(30), 100);
        const int offset = qMax(0, data.value("offset").toInt());
        const QString keyword = data.value("keyword").toString().trimmed();
        const QString district = data.value("district").toString().trimmed();
        return success(request, QJsonObject{{"items", stationsJson(db.listStations(39.9042, 116.4074,
                                                                          keyword, district, limit, offset))},
                                            {"total", db.stationCount(keyword, district)}, {"offset", offset},
                                            {"limit", limit}});
    }

    if (action == QLatin1String("admin.login")) {
        Admin admin;
        if (!db.loginAdmin(data.value("username").toString(), data.value("password").toString(), admin))
            return failure(request, QStringLiteral("AUTH_FAILED"), db.lastError());
        const QString token = QUuid::createUuid().toString(QUuid::WithoutBraces);
        m_adminSessions.insert(token, {admin.id, QDateTime::currentDateTimeUtc().addSecs(12 * 60 * 60)});
        return success(request, QJsonObject{{"token", token}, {"admin", JsonCodec::toJson(admin)}},
                       QStringLiteral("登录成功"));
    }

    if (action.startsWith(QLatin1String("admin."))) {
        const int adminId = authorizedAdmin(request);
        if (adminId <= 0)
            return failure(request, QStringLiteral("UNAUTHORIZED"), QStringLiteral("管理员登录已失效，请重新登录"));
        return dispatchAdmin(request, adminId);
    }

    const int userId = authorizedUser(request);
    if (userId <= 0)
        return failure(request, QStringLiteral("UNAUTHORIZED"), QStringLiteral("登录已失效，请重新登录"));

    if (action == QLatin1String("stations.list")) {
        auto values = db.listStations(data.value("latitude").toDouble(39.9042),
                                            data.value("longitude").toDouble(116.4074),
                                            data.value("keyword").toString(),
                                            data.value("district").toString(),
                                            qBound(1, data.value("limit").toInt(80), 500));
        QVector<int> favStations;
        db.listFavorites(userId, QStringLiteral("station"), favStations);
        const QSet<int> favSet(favStations.begin(), favStations.end());
        std::sort(values.begin(), values.end(), [&](const Station &a, const Station &b) {
            const bool af = favSet.contains(a.id);
            const bool bf = favSet.contains(b.id);
            if (af != bf)
                return af;
            return a.distanceKm < b.distanceKm;
        });
        QJsonArray favoriteIds;
        for (int id : favStations)
            favoriteIds.append(id);
        return success(request, QJsonObject{{"items", stationsJson(values)}, {"stationCount", db.stationCount()},
                                 {"pileCount", db.pileCount()}, {"favoriteStationIds", favoriteIds}});
    }

    if (action == QLatin1String("stations.districts")) {
        QJsonArray values;
        for (const QString &district : db.districts())
            values.append(district);
        return success(request, QJsonObject{{"items", values}});
    }

    if (action == QLatin1String("piles.list")) {
        auto values = db.listPiles(data.value("stationId").toInt(-1),
                                        data.value("status").toString(),
                                        data.value("speedClass").toString(),
                                        data.value("connector").toString());
        QVector<int> favPiles;
        db.listFavorites(userId, QStringLiteral("pile"), favPiles);
        const QSet<int> favSet(favPiles.begin(), favPiles.end());
        for (Pile &pile : values)
            pile.favorite = favSet.contains(pile.id);
        std::sort(values.begin(), values.end(), [](const Pile &a, const Pile &b) {
            if (a.favorite != b.favorite)
                return a.favorite;
            return a.id < b.id;
        });
        return success(request, QJsonObject{{"items", pilesJson(values)}});
    }

    if (action == QLatin1String("piles.get")) {
        Pile pile;
        if (!db.getPile(data.value("pileId").toInt(), pile))
            return failure(request, QStringLiteral("NOT_FOUND"), db.lastError());
        return success(request, JsonCodec::toJson(pile));
    }

    if (action == QLatin1String("user.get")) {
        User user;
        if (!db.getUserById(userId, user))
            return failure(request, QStringLiteral("NOT_FOUND"), db.lastError());
        return success(request, JsonCodec::toJson(user));
    }

    if (action == QLatin1String("user.update")) {
        User user;
        if (!db.getUserById(userId, user))
            return failure(request, QStringLiteral("NOT_FOUND"), db.lastError());
        user.nickname = data.value("nickname").toString();
        user.avatarPath = data.value("avatarPath").toString();
        user.carModel = data.value("carModel").toString();
        user.plateNumber = data.value("plateNumber").toString();
        if (!data.value("password").toString().isEmpty())
            user.password = data.value("password").toString();
        if (!db.updateUser(user))
            return failure(request, QStringLiteral("UPDATE_FAILED"), db.lastError());
        return success(request, JsonCodec::toJson(user));
    }

    if (action == QLatin1String("user.logout")) {
        m_sessions.remove(request.value("token").toString());
        return success(request, QJsonObject(), QStringLiteral("已退出登录"));
    }

    if (action == QLatin1String("favorites.list")) {
        QVector<int> stations;
        QVector<int> piles;
        db.listFavorites(userId, QStringLiteral("station"), stations);
        db.listFavorites(userId, QStringLiteral("pile"), piles);
        QJsonArray stationIds;
        QJsonArray pileIds;
        for (int id : stations)
            stationIds.append(id);
        for (int id : piles)
            pileIds.append(id);
        return success(request, QJsonObject{{"stations", stationIds}, {"piles", pileIds}});
    }

    if (action == QLatin1String("favorites.toggle")) {
        bool nowFavorite = false;
        if (!db.toggleFavorite(userId, data.value("targetType").toString(),
                               data.value("targetId").toInt(), nowFavorite))
            return failure(request, QStringLiteral("FAVORITE_FAILED"), db.lastError());
        return success(request, QJsonObject{{"favorite", nowFavorite}},
                       nowFavorite ? QStringLiteral("已加入收藏") : QStringLiteral("已取消收藏"));
    }

    if (action == QLatin1String("wallet.recharge")) {
        if (!db.rechargeUser(userId, data.value("amount").toDouble()))
            return failure(request, QStringLiteral("RECHARGE_FAILED"), db.lastError());
        User user;
        db.getUserById(userId, user);
        return success(request, JsonCodec::toJson(user));
    }

    if (action == QLatin1String("reservation.create")) {
        ChargingReservation reservation;
        if (!db.createReservation(userId, data.value("pileId").toInt(), reservation))
            return failure(request, QStringLiteral("RESERVATION_FAILED"), db.lastError());
        return success(request, JsonCodec::toJson(reservation), QStringLiteral("预约成功，15 分钟内有效"));
    }

    if (action == QLatin1String("reservation.cancel")) {
        if (!db.cancelReservation(userId, data.value("reservationId").toInt()))
            return failure(request, QStringLiteral("RESERVATION_CANCEL_FAILED"), db.lastError());
        return success(request, QJsonObject(), QStringLiteral("预约已取消"));
    }

    if (action == QLatin1String("reservation.active")) {
        ChargingReservation reservation;
        const bool found = db.getActiveReservation(userId, reservation);
        return success(request, QJsonObject{{"found", found},
                                            {"reservation", found
                                                                ? QJsonValue(JsonCodec::toJson(reservation))
                                                                : QJsonValue(QJsonObject())}});
    }

    if (action == QLatin1String("charge.start")) {
        ChargingOrder order;
        if (!db.startCharging(userId, data.value("pileId").toInt(), order))
            return failure(request, QStringLiteral("CHARGE_START_FAILED"), db.lastError());
        return success(request, JsonCodec::toJson(order));
    }

    if (action == QLatin1String("charge.progress")) {
        if (!db.updateChargingProgress(userId, data.value("orderId").toInt(),
                                       data.value("energyKwh").toDouble()))
            return failure(request, QStringLiteral("CHARGE_PROGRESS_FAILED"), db.lastError());
        return success(request);
    }

    if (action == QLatin1String("charge.stop")) {
        ChargingOrder ongoing;
        if (!db.getOngoingOrderByUser(userId, ongoing) || ongoing.id != data.value("orderId").toInt())
            return failure(request, QStringLiteral("ORDER_MISMATCH"), QStringLiteral("进行中的订单不存在"));
        ChargingOrder order;
        if (!db.stopCharging(ongoing.id, data.value("energyKwh").toDouble(), order))
            return failure(request, QStringLiteral("CHARGE_STOP_FAILED"), db.lastError());
        return success(request, JsonCodec::toJson(order));
    }

    if (action == QLatin1String("charge.ongoing")) {
        ChargingOrder order;
        const bool found = db.getOngoingOrderByUser(userId, order);
        return success(request, QJsonObject{{"found", found}, {"order", found ? QJsonValue(JsonCodec::toJson(order))
                                                               : QJsonValue(QJsonObject())}});
    }

    if (action == QLatin1String("orders.list"))
        return success(request, QJsonObject{{"items", ordersJson(db.listOrders(userId, data.value("status").toString()))}});

    return failure(request, QStringLiteral("UNKNOWN_ACTION"),
                   QStringLiteral("未知请求: %1").arg(action));
}

int ApiDispatcher::authorizedAdmin(const QJsonObject &request)
{
    const QString token = request.value("token").toString();
    const auto it = m_adminSessions.find(token);
    if (it == m_adminSessions.end())
        return 0;
    if (it->expiresAt < QDateTime::currentDateTimeUtc()) {
        m_adminSessions.erase(it);
        return 0;
    }
    Admin admin;
    if (!DatabaseManager::instance().getAdminById(it->adminId, admin)) {
        m_adminSessions.erase(it);
        return 0;
    }
    return it->adminId;
}

bool ApiDispatcher::adminHasPermission(int adminId, const QString &permission) const
{
    Admin admin;
    if (!DatabaseManager::instance().getAdminById(adminId, admin))
        return false;
    return DatabaseManager::instance().hasPermission(admin.role, permission);
}

QJsonObject ApiDispatcher::denyIfNoPermission(const QJsonObject &request, int adminId,
                                              const QString &permission) const
{
    if (adminHasPermission(adminId, permission))
        return {};
    return failure(request, QStringLiteral("FORBIDDEN"), QStringLiteral("当前角色无权执行该操作"));
}

QJsonObject ApiDispatcher::dashboardPayload(int days) const
{
    auto &db = DatabaseManager::instance();
    const auto stats = db.salesStats();
    QJsonObject statJson{{"todayAmount", stats.todayAmount}, {"monthAmount", stats.monthAmount},
                         {"totalAmount", stats.totalAmount}, {"todayOrders", stats.todayOrders},
                         {"monthOrders", stats.monthOrders}, {"totalOrders", stats.totalOrders},
                         {"idlePiles", stats.idlePiles}, {"chargingPiles", stats.chargingPiles},
                         {"faultPiles", stats.faultPiles}, {"offlinePiles", stats.offlinePiles},
                         {"reservedPiles", stats.reservedPiles}, {"restartingPiles", stats.restartingPiles},
                         {"totalPiles", stats.totalPiles},
                         {"inUsePiles", stats.chargingPiles + stats.reservedPiles},
                         {"onlineRate", stats.totalPiles > 0
                                            ? (stats.totalPiles - stats.offlinePiles) * 100.0 / stats.totalPiles
                                            : 0.0},
                         {"totalUsers", stats.totalUsers}, {"totalStations", stats.totalStations}};
    QJsonArray daily;
    for (const auto &entry : db.dailySales(days == 7 ? 7 : 30))
        daily.append(QJsonObject{{"date", entry.first}, {"amount", entry.second}});
    return {{"stats", statJson}, {"dailySales", daily}, {"recentOrders", ordersJson(db.listOrders(), 12)}};
}

QJsonObject ApiDispatcher::dispatchAdmin(const QJsonObject &request, int adminId)
{
    auto &db = DatabaseManager::instance();
    const QString action = request.value("action").toString();
    const QJsonObject data = request.value("data").toObject();

    if (action == QLatin1String("admin.logout")) {
        m_adminSessions.remove(request.value("token").toString());
        return success(request, QJsonObject(), QStringLiteral("已退出登录"));
    }

    if (action == QLatin1String("admin.dashboard")) {
        if (const auto denied = denyIfNoPermission(request, adminId, QStringLiteral("dashboard.read"));
            !denied.isEmpty())
            return denied;
        const int days = data.value("days").toInt(7) == 30 ? 30 : 7;
        return success(request, dashboardPayload(days));
    }

    if (action == QLatin1String("admin.stations.districts")) {
        QJsonArray values;
        for (const QString &district : db.districts())
            values.append(district);
        return success(request, QJsonObject{{"items", values}});
    }

    if (action == QLatin1String("admin.piles.list")) {
        if (const auto denied = denyIfNoPermission(request, adminId, QStringLiteral("piles.read"));
            !denied.isEmpty())
            return denied;
        return success(request, QJsonObject{{"items", pilesJson(db.listPiles(
                                            data.value("stationId").toInt(-1),
                                            data.value("status").toString(),
                                            QString(), QString(),
                                            data.value("district").toString()))},
                                            {"stats", dashboardPayload(7).value("stats").toObject()}});
    }

    if (action == QLatin1String("admin.piles.save")) {
        if (const auto denied = denyIfNoPermission(request, adminId, QStringLiteral("piles.write"));
            !denied.isEmpty())
            return denied;
        Pile pile = JsonCodec::pileFromJson(data);
        if (!db.savePile(pile))
            return failure(request, QStringLiteral("PILE_SAVE_FAILED"), db.lastError());
        db.writeAdminAudit(adminId, QStringLiteral("admin.pile.save"),
                           QStringLiteral("pile"), pile.id, QStringLiteral("{}"));
        Pile saved;
        db.getPile(pile.id, saved);
        return success(request, JsonCodec::toJson(saved),
                       pile.id > 0 && data.value("id").toInt() > 0
                           ? QStringLiteral("电桩已更新") : QStringLiteral("电桩已新增"));
    }

    if (action == QLatin1String("admin.piles.delete")) {
        if (const auto denied = denyIfNoPermission(request, adminId, QStringLiteral("piles.write"));
            !denied.isEmpty())
            return denied;
        const int pileId = data.value("pileId").toInt();
        const bool force = data.value("force").toBool();
        if (!db.deletePile(pileId, force, adminId)) {
            const QString err = db.lastError();
            if (err.startsWith(QLatin1String("IN_USE:")))
                return failure(request, QStringLiteral("NEED_FORCE"), err.mid(7));
            return failure(request, QStringLiteral("PILE_DELETE_FAILED"), err);
        }
        return success(request, QJsonObject(), QStringLiteral("电桩已删除"));
    }

    if (action == QLatin1String("admin.piles.restart")) {
        if (const auto denied = denyIfNoPermission(request, adminId, QStringLiteral("piles.write"));
            !denied.isEmpty())
            return denied;
        const int pileId = data.value("pileId").toInt();
        if (!db.restartPile(pileId, adminId))
            return failure(request, QStringLiteral("RESTART_FAILED"), db.lastError());
        QTimer::singleShot(1500, this, [pileId]() {
            DatabaseManager::instance().updatePileStatus(
                pileId, QStringLiteral("idle"), QStringLiteral("pile"),
                QStringLiteral("模拟维修完成，电桩恢复空闲"));
        });
        return success(request, QJsonObject(), QStringLiteral("已进入模拟维修（远程重启）"));
    }

    if (action == QLatin1String("admin.stations.list")) {
        if (const auto denied = denyIfNoPermission(request, adminId, QStringLiteral("stations.read"));
            !denied.isEmpty())
            return denied;
        const QString keyword = data.value("keyword").toString();
        const QString district = data.value("district").toString();
        return success(request, QJsonObject{
            {"items", stationsJson(db.listStations(39.9042, 116.4074, keyword, district, 1000, 0))},
            {"total", db.stationCount(keyword, district)}});
    }

    if (action == QLatin1String("admin.stations.save")) {
        if (const auto denied = denyIfNoPermission(request, adminId, QStringLiteral("stations.write"));
            !denied.isEmpty())
            return denied;
        Station station;
        station.id = data.value("id").toInt();
        station.name = data.value("name").toString().trimmed();
        station.address = data.value("address").toString().trimmed();
        station.latitude = data.value("latitude").toDouble();
        station.longitude = data.value("longitude").toDouble();
        station.openHours = data.value("openHours").toString(QStringLiteral("00:00-24:00"));
        station.status = data.value("status").toString(QStringLiteral("open"));
        const int pileCount = data.value("pileCount").toInt(4);
        if (station.id == 0) {
            if (!db.createStationWithPiles(station, pileCount))
                return failure(request, QStringLiteral("STATION_CREATE_FAILED"), db.lastError());
            return success(request, JsonCodec::toJson(station),
                           QStringLiteral("已新增电站并生成 %1 个电桩").arg(station.totalPiles));
        }
        if (!db.saveStation(station))
            return failure(request, QStringLiteral("STATION_SAVE_FAILED"), db.lastError());
        return success(request, JsonCodec::toJson(station), QStringLiteral("电站已更新"));
    }

    if (action == QLatin1String("admin.stations.delete")) {
        if (const auto denied = denyIfNoPermission(request, adminId, QStringLiteral("stations.write"));
            !denied.isEmpty())
            return denied;
        const int stationId = data.value("stationId").toInt();
        const bool force = data.value("force").toBool();
        if (!db.deleteStation(stationId, force, adminId)) {
            const QString err = db.lastError();
            if (err.startsWith(QLatin1String("IN_USE:")))
                return failure(request, QStringLiteral("NEED_FORCE"), err.mid(7));
            return failure(request, QStringLiteral("STATION_DELETE_FAILED"), err);
        }
        return success(request, QJsonObject(), QStringLiteral("电站及所属电桩已删除"));
    }

    if (action == QLatin1String("admin.stations.piles")) {
        if (const auto denied = denyIfNoPermission(request, adminId, QStringLiteral("stations.read"));
            !denied.isEmpty())
            return denied;
        const int stationId = data.value("stationId").toInt();
        Station station;
        if (!db.getStation(stationId, station))
            return failure(request, QStringLiteral("NOT_FOUND"), db.lastError());
        return success(request, QJsonObject{{"station", JsonCodec::toJson(station)},
                                            {"items", pilesJson(db.listPiles(stationId))}});
    }

    if (action == QLatin1String("admin.users.list")) {
        if (const auto denied = denyIfNoPermission(request, adminId, QStringLiteral("users.read"));
            !denied.isEmpty())
            return denied;
        QJsonArray items;
        for (const User &user : db.listUsers(data.value("keyword").toString()))
            items.append(JsonCodec::toJson(user));
        return success(request, QJsonObject{{"items", items}});
    }

    if (action == QLatin1String("admin.users.setStatus")) {
        if (const auto denied = denyIfNoPermission(request, adminId, QStringLiteral("users.write"));
            !denied.isEmpty())
            return denied;
        const int userId = data.value("userId").toInt();
        const QString status = data.value("status").toString();
        if (!db.setUserStatus(userId, status, adminId))
            return failure(request, QStringLiteral("USER_STATUS_FAILED"), db.lastError());
        return success(request, QJsonObject(),
                       status == QLatin1String("frozen") ? QStringLiteral("用户已冻结")
                                                         : QStringLiteral("用户已解冻"));
    }

    if (action == QLatin1String("admin.users.orders")) {
        if (const auto denied = denyIfNoPermission(request, adminId, QStringLiteral("orders.read"));
            !denied.isEmpty())
            return denied;
        const int userId = data.value("userId").toInt();
        return success(request, QJsonObject{{"items", ordersJson(db.listOrders(userId))}});
    }

    if (action == QLatin1String("admin.orders.delete")) {
        if (const auto denied = denyIfNoPermission(request, adminId, QStringLiteral("orders.write"));
            !denied.isEmpty())
            return denied;
        if (!db.deleteOrder(data.value("orderId").toInt(), adminId))
            return failure(request, QStringLiteral("ORDER_DELETE_FAILED"), db.lastError());
        return success(request, QJsonObject(), QStringLiteral("订单已删除"));
    }

    if (action == QLatin1String("admin.reservations.list")) {
        if (const auto denied = denyIfNoPermission(request, adminId, QStringLiteral("reservations.read"));
            !denied.isEmpty())
            return denied;
        QJsonArray items;
        for (const ChargingReservation &r : db.listActiveReservations())
            items.append(JsonCodec::toJson(r));
        return success(request, QJsonObject{{"items", items}});
    }

    if (action == QLatin1String("admin.reservations.cancel")) {
        if (const auto denied = denyIfNoPermission(request, adminId, QStringLiteral("reservations.write"));
            !denied.isEmpty())
            return denied;
        if (!db.adminCancelReservation(data.value("reservationId").toInt(), adminId))
            return failure(request, QStringLiteral("RESERVATION_CANCEL_FAILED"), db.lastError());
        return success(request, QJsonObject(), QStringLiteral("预约已解除"));
    }

    if (action == QLatin1String("admin.invites.list")) {
        if (const auto denied = denyIfNoPermission(request, adminId, QStringLiteral("invites.write"));
            !denied.isEmpty())
            return denied;
        QJsonArray items;
        for (const InviteCode &code : db.listInviteCodes())
            items.append(JsonCodec::toJson(code));
        return success(request, QJsonObject{{"items", items}});
    }

    if (action == QLatin1String("admin.invites.create")) {
        if (const auto denied = denyIfNoPermission(request, adminId, QStringLiteral("invites.write"));
            !denied.isEmpty())
            return denied;
        QString code;
        if (!db.createInviteCode(adminId, data.value("role").toString(), code))
            return failure(request, QStringLiteral("INVITE_FAILED"), db.lastError());
        return success(request, QJsonObject{{"code", code}}, QStringLiteral("邀请码已生成"));
    }

    if (action == QLatin1String("admin.permissions.list")) {
        if (const auto denied = denyIfNoPermission(request, adminId, QStringLiteral("permissions.write"));
            !denied.isEmpty())
            return denied;
        const QString role = data.value("role").toString(QStringLiteral("operator"));
        QJsonArray items;
        for (const auto &entry : db.listRolePermissions(role))
            items.append(QJsonObject{{"permission", entry.first}, {"allowed", entry.second}});
        QJsonArray keys;
        for (const QString &key : DatabaseManager::allPermissionKeys())
            keys.append(key);
        return success(request, QJsonObject{{"role", role}, {"items", items}, {"keys", keys}});
    }

    if (action == QLatin1String("admin.permissions.set")) {
        if (const auto denied = denyIfNoPermission(request, adminId, QStringLiteral("permissions.write"));
            !denied.isEmpty())
            return denied;
        if (!db.setRolePermission(data.value("role").toString(),
                                  data.value("permission").toString(),
                                  data.value("allowed").toBool(), adminId))
            return failure(request, QStringLiteral("PERMISSION_FAILED"), db.lastError());
        return success(request, QJsonObject(), QStringLiteral("权限已更新"));
    }

    return failure(request, QStringLiteral("UNKNOWN_ACTION"),
                   QStringLiteral("未知管理员请求: %1").arg(action));
}
