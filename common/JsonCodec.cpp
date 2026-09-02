#include "JsonCodec.h"

namespace JsonCodec {

QJsonObject toJson(const User &v)
{
    return {{"id", v.id}, {"username", v.username}, {"phone", v.phone},
            {"nickname", v.nickname}, {"avatarPath", v.avatarPath}, {"balance", v.balance},
            {"carModel", v.carModel}, {"plateNumber", v.plateNumber}, {"status", v.status},
            {"createdAt", v.createdAt}};
}

QJsonObject toJson(const Admin &v)
{
    return {{"id", v.id}, {"username", v.username}, {"realName", v.realName}, {"role", v.role}};
}

QJsonObject toJson(const Station &v)
{
    return {{"id", v.id}, {"stationCode", v.stationCode}, {"name", v.name},
            {"address", v.address}, {"regionCode", v.regionCode},
            {"latitude", v.latitude}, {"longitude", v.longitude}, {"openHours", v.openHours},
            {"status", v.status}, {"idlePiles", v.idlePiles}, {"totalPiles", v.totalPiles},
            {"onlineRate", v.onlineRate}, {"distanceKm", v.distanceKm}};
}

QJsonObject toJson(const Pile &v)
{
    return {{"id", v.id}, {"stationId", v.stationId}, {"pileCode", v.pileCode},
            {"pileType", v.pileType}, {"speedClass", v.speedClass},
            {"connectorStandard", v.connectorStandard}, {"phase", v.phase},
            {"voltageV", v.voltageV}, {"categoryLabel", v.categoryLabel},
            {"powerKw", v.powerKw}, {"pricePerKwh", v.pricePerKwh},
            {"status", v.status}, {"stationName", v.stationName},
            {"totalChargeCount", v.totalChargeCount},
            {"totalChargeSeconds", v.totalChargeSeconds}};
}

QJsonObject toJson(const ChargingReservation &v)
{
    return {{"id", v.id}, {"reservationNo", v.reservationNo}, {"userId", v.userId},
            {"pileId", v.pileId}, {"reservedAt", v.reservedAt}, {"expiresAt", v.expiresAt},
            {"status", v.status}, {"pileCode", v.pileCode}, {"stationName", v.stationName}};
}

QJsonObject toJson(const ChargingOrder &v)
{
    return {{"id", v.id}, {"orderNo", v.orderNo}, {"userId", v.userId},
            {"pileId", v.pileId}, {"startTime", v.startTime}, {"endTime", v.endTime},
            {"energyKwh", v.energyKwh}, {"amount", v.amount}, {"status", v.status},
            {"username", v.username}, {"pileCode", v.pileCode},
            {"stationName", v.stationName}};
}

User userFromJson(const QJsonObject &o)
{
    User v;
    v.id = o.value("id").toInt();
    v.username = o.value("username").toString();
    v.password = o.value("password").toString();
    v.phone = o.value("phone").toString();
    v.nickname = o.value("nickname").toString();
    v.avatarPath = o.value("avatarPath").toString();
    v.balance = o.value("balance").toDouble();
    v.carModel = o.value("carModel").toString();
    v.plateNumber = o.value("plateNumber").toString();
    v.status = o.value("status").toString();
    v.createdAt = o.value("createdAt").toString();
    return v;
}

Admin adminFromJson(const QJsonObject &o)
{
    Admin v;
    v.id = o.value("id").toInt();
    v.username = o.value("username").toString();
    v.realName = o.value("realName").toString();
    v.role = o.value("role").toString();
    return v;
}

Station stationFromJson(const QJsonObject &o)
{
    Station v;
    v.id = o.value("id").toInt();
    v.stationCode = o.value("stationCode").toString();
    v.name = o.value("name").toString();
    v.address = o.value("address").toString();
    v.regionCode = o.value("regionCode").toString();
    v.latitude = o.value("latitude").toDouble();
    v.longitude = o.value("longitude").toDouble();
    v.openHours = o.value("openHours").toString();
    v.status = o.value("status").toString();
    v.idlePiles = o.value("idlePiles").toInt();
    v.totalPiles = o.value("totalPiles").toInt();
    v.onlineRate = o.value("onlineRate").toDouble();
    v.distanceKm = o.value("distanceKm").toDouble();
    return v;
}

Pile pileFromJson(const QJsonObject &o)
{
    Pile v;
    v.id = o.value("id").toInt();
    v.stationId = o.value("stationId").toInt();
    v.pileCode = o.value("pileCode").toString();
    v.pileType = o.value("pileType").toString();
    v.speedClass = o.value("speedClass").toString();
    v.connectorStandard = o.value("connectorStandard").toString();
    v.phase = o.value("phase").toString();
    v.voltageV = o.value("voltageV").toInt(220);
    v.categoryLabel = o.value("categoryLabel").toString();
    v.powerKw = o.value("powerKw").toDouble();
    v.pricePerKwh = o.value("pricePerKwh").toDouble();
    v.status = o.value("status").toString();
    v.stationName = o.value("stationName").toString();
    v.totalChargeCount = o.value("totalChargeCount").toInt();
    v.totalChargeSeconds = o.value("totalChargeSeconds").toInt();
    return v;
}

ChargingReservation reservationFromJson(const QJsonObject &o)
{
    ChargingReservation v;
    v.id = o.value("id").toInt();
    v.reservationNo = o.value("reservationNo").toString();
    v.userId = o.value("userId").toInt();
    v.pileId = o.value("pileId").toInt();
    v.reservedAt = o.value("reservedAt").toString();
    v.expiresAt = o.value("expiresAt").toString();
    v.status = o.value("status").toString();
    v.pileCode = o.value("pileCode").toString();
    v.stationName = o.value("stationName").toString();
    return v;
}

ChargingOrder orderFromJson(const QJsonObject &o)
{
    ChargingOrder v;
    v.id = o.value("id").toInt();
    v.orderNo = o.value("orderNo").toString();
    v.userId = o.value("userId").toInt();
    v.pileId = o.value("pileId").toInt();
    v.startTime = o.value("startTime").toString();
    v.endTime = o.value("endTime").toString();
    v.energyKwh = o.value("energyKwh").toDouble();
    v.amount = o.value("amount").toDouble();
    v.status = o.value("status").toString();
    v.username = o.value("username").toString();
    v.pileCode = o.value("pileCode").toString();
    v.stationName = o.value("stationName").toString();
    return v;
}

} // namespace JsonCodec
