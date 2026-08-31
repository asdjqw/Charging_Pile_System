#pragma once

#include <QString>
#include <QDateTime>

struct User {
    int id = 0;
    QString username;
    QString password;
    QString phone;
    double balance = 0.0;
    QString carModel;
    QString plateNumber;
    QString createdAt;
};

struct Admin {
    int id = 0;
    QString username;
    QString password;
    QString realName;
    QString role;
};

struct Station {
    int id = 0;
    QString name;
    QString address;
    double latitude = 0.0;
    double longitude = 0.0;
    QString openHours;
    QString status;
    int idlePiles = 0;
    int totalPiles = 0;
    double distanceKm = 0.0; // 相对用户位置的估算距离
};

struct Pile {
    int id = 0;
    int stationId = 0;
    QString pileCode;
    QString pileType;   // AC / DC
    double powerKw = 0.0;
    double pricePerKwh = 0.0;
    QString status;     // idle / charging / fault / offline
    QString stationName;
};

struct ChargingOrder {
    int id = 0;
    QString orderNo;
    int userId = 0;
    int pileId = 0;
    QString startTime;
    QString endTime;
    double energyKwh = 0.0;
    double amount = 0.0;
    QString status;
    QString username;
    QString pileCode;
    QString stationName;
};

inline QString statusTextPile(const QString &status)
{
    if (status == "idle") return QStringLiteral("空闲");
    if (status == "charging") return QStringLiteral("充电中");
    if (status == "fault") return QStringLiteral("故障");
    if (status == "offline") return QStringLiteral("离线");
    return status;
}

inline QString statusTextStation(const QString &status)
{
    if (status == "open") return QStringLiteral("营业中");
    if (status == "closed") return QStringLiteral("已关闭");
    if (status == "maintenance") return QStringLiteral("维护中");
    return status;
}

inline QString statusTextOrder(const QString &status)
{
    if (status == "ongoing") return QStringLiteral("进行中");
    if (status == "finished") return QStringLiteral("已完成");
    if (status == "cancelled") return QStringLiteral("已取消");
    return status;
}

inline QString pileTypeText(const QString &type)
{
    if (type == "AC") return QStringLiteral("交流慢充");
    if (type == "DC") return QStringLiteral("直流快充");
    return type;
}
