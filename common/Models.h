#pragma once

#include <QString>
#include <QDateTime>

struct User {
    int id = 0;
    QString username;
    QString password;
    QString phone;
    QString nickname;
    QString avatarPath;
    double balance = 0.0;
    QString carModel;
    QString plateNumber;
    QString status;
    QString createdAt;
};

struct Admin {
    int id = 0;
    QString username;
    QString password;
    QString realName;
    QString role;
};

struct InviteCode {
    int id = 0;
    QString code;
    QString role;
    int createdBy = 0;
    int usedBy = 0;
    QString usedUsername;
    QString usedAt;
    QString createdAt;
};

struct Station {
    int id = 0;
    QString stationCode;
    QString name;
    QString address;
    QString regionCode;
    double latitude = 0.0;
    double longitude = 0.0;
    QString openHours;
    QString status;
    int idlePiles = 0;
    int totalPiles = 0;
    double onlineRate = 0.0;
    double distanceKm = 0.0;
};

struct Pile {
    int id = 0;
    int stationId = 0;
    QString pileCode;
    QString pileType;            // AC / DC
    QString speedClass;          // slow / standard / fast / ultra
    QString connectorStandard;   // GB_T_AC / GB_T_DC / CCS2 / CHAdeMO / TeslaNACS
    QString phase;               // single / three
    int voltageV = 220;
    QString categoryLabel;       // 可读分类
    double powerKw = 0.0;
    double pricePerKwh = 0.0;
    QString status;              // idle / charging / fault / offline / reserved / restarting
    QString stationName;
    QString stationAddress;
    int totalChargeCount = 0;
    int totalChargeSeconds = 0;
    double remainingKwh = 100.0;
    bool favorite = false;
};

struct ChargingReservation {
    int id = 0;
    QString reservationNo;
    int userId = 0;
    int pileId = 0;
    QString reservedAt;
    QString expiresAt;
    QString status;
    QString pileCode;
    QString stationName;
    QString username;
    QString phone;
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
    if (status == QLatin1String("idle")) return QStringLiteral("空闲");
    if (status == QLatin1String("reserved")) return QStringLiteral("已预约");
    if (status == QLatin1String("charging")) return QStringLiteral("充电中");
    if (status == QLatin1String("fault")) return QStringLiteral("故障");
    if (status == QLatin1String("offline")) return QStringLiteral("离线");
    if (status == QLatin1String("restarting")) return QStringLiteral("重启中");
    return status;
}

inline QString statusTextStation(const QString &status)
{
    if (status == QLatin1String("open")) return QStringLiteral("营业中");
    if (status == QLatin1String("closed")) return QStringLiteral("已关闭");
    if (status == QLatin1String("maintenance")) return QStringLiteral("维护中");
    return status;
}

inline QString statusTextOrder(const QString &status)
{
    if (status == QLatin1String("ongoing")) return QStringLiteral("进行中");
    if (status == QLatin1String("pending_payment")) return QStringLiteral("待支付");
    if (status == QLatin1String("finished")) return QStringLiteral("已完成");
    if (status == QLatin1String("cancelled")) return QStringLiteral("已取消");
    return status;
}

inline QString statusTextUser(const QString &status)
{
    if (status == QLatin1String("normal")) return QStringLiteral("正常");
    if (status == QLatin1String("frozen")) return QStringLiteral("冻结");
    return status;
}

inline QString speedClassText(const QString &speed)
{
    if (speed == QLatin1String("slow")) return QStringLiteral("慢充");
    if (speed == QLatin1String("standard")) return QStringLiteral("常规");
    if (speed == QLatin1String("fast")) return QStringLiteral("快充");
    if (speed == QLatin1String("ultra")) return QStringLiteral("超充");
    return speed;
}

inline QString connectorText(const QString &c)
{
    if (c == QLatin1String("GB_T_AC")) return QStringLiteral("国标交流");
    if (c == QLatin1String("GB_T_DC")) return QStringLiteral("国标直流");
    if (c == QLatin1String("CCS2")) return QStringLiteral("CCS2");
    if (c == QLatin1String("CHAdeMO")) return QStringLiteral("CHAdeMO");
    if (c == QLatin1String("TeslaNACS")) return QStringLiteral("特斯拉NACS");
    return c;
}

inline QString pileTypeText(const QString &type)
{
    if (type == QLatin1String("AC")) return QStringLiteral("交流");
    if (type == QLatin1String("DC")) return QStringLiteral("直流");
    return type;
}

inline QString chargeKindText(const Pile &p)
{
    if (p.speedClass == QLatin1String("fast") || p.speedClass == QLatin1String("ultra")
        || p.pileType == QLatin1String("DC"))
        return QStringLiteral("快充");
    return QStringLiteral("慢充");
}

inline QString pileCategoryText(const Pile &p)
{
    if (!p.categoryLabel.isEmpty())
        return p.categoryLabel;
    return QStringLiteral("%1%2·%3·%4kW")
        .arg(pileTypeText(p.pileType),
             speedClassText(p.speedClass),
             connectorText(p.connectorStandard))
        .arg(p.powerKw, 0, 'f', 0);
}
