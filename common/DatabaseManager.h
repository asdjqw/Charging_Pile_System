#pragma once

#include "Models.h"

#include <QObject>
#include <QSqlDatabase>
#include <QVector>

class DatabaseManager : public QObject
{
    Q_OBJECT
public:
    static DatabaseManager &instance();

    bool initialize(const QString &dbPath = QString());
    QString lastError() const { return m_lastError; }
    QString databasePath() const { return m_dbPath; }

    // 认证
    bool loginUser(const QString &username, const QString &password, User &outUser);
    bool loginAdmin(const QString &username, const QString &password, Admin &outAdmin);
    bool registerUser(const User &user);

    // 用户
    bool getUserById(int id, User &outUser);
    bool updateUser(const User &user);
    bool rechargeUser(int userId, double amount);
    QVector<User> listUsers(const QString &keyword = QString());
    bool deleteUser(int id);

    // 充电站 / 充电桩
    QVector<Station> listStations(double userLat = 39.96, double userLng = 116.36,
                                  const QString &keyword = QString());
    bool getStation(int id, Station &out);
    bool saveStation(Station &station); // id==0 插入
    bool deleteStation(int id);

    QVector<Pile> listPiles(int stationId = -1, const QString &status = QString());
    bool getPile(int id, Pile &out);
    bool savePile(Pile &pile);
    bool deletePile(int id);
    bool updatePileStatus(int pileId, const QString &status);

    // 充电业务
    bool startCharging(int userId, int pileId, ChargingOrder &outOrder);
    bool stopCharging(int orderId, double energyKwh, ChargingOrder &outOrder);
    bool getOngoingOrderByUser(int userId, ChargingOrder &outOrder);
    QVector<ChargingOrder> listOrders(int userId = -1, const QString &status = QString());

    // 统计（管理端）
    struct SalesStats {
        double todayAmount = 0;
        double monthAmount = 0;
        double totalAmount = 0;
        int todayOrders = 0;
        int monthOrders = 0;
        int totalOrders = 0;
        int idlePiles = 0;
        int chargingPiles = 0;
        int faultPiles = 0;
        int offlinePiles = 0;
        int totalUsers = 0;
        int totalStations = 0;
    };
    SalesStats salesStats() const;
    QVector<QPair<QString, double>> dailySales(int days = 7) const;

private:
    explicit DatabaseManager(QObject *parent = nullptr);
    bool openDatabase(const QString &dbPath);
    bool execSqlFile(const QString &filePath);
    bool ensureSchemaAndSeed();
    QString resolveDbPath(const QString &preferred) const;
    double haversineKm(double lat1, double lon1, double lat2, double lon2) const;
    QString makeOrderNo() const;

    QSqlDatabase m_db;
    QString m_lastError;
    QString m_dbPath;
};
