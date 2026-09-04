#pragma once

#include "Models.h"

#include <QObject>
#include <QPair>
#include <QSqlDatabase>
#include <QStringList>
#include <QVector>

class DatabaseManager : public QObject
{
    Q_OBJECT
public:
    static DatabaseManager &instance();

    bool initialize(const QString &dbPath = QString());
    QString lastError() const { return m_lastError; }
    QString databasePath() const { return m_dbPath; }

    bool importBeijingCsv(const QString &csvPath = QString(), bool force = false);
    int stationCount(const QString &keyword = QString(),
                     const QString &district = QString()) const;
    int pileCount() const;
    QStringList districts() const;

    bool loginUser(const QString &username, const QString &password, User &outUser);
    bool phoneLogin(const QString &phone, User &outUser, bool &created);
    bool loginByPhone(const QString &phone, const QString &password, User &outUser);
    bool loginAdmin(const QString &username, const QString &password, Admin &outAdmin);
    bool registerAdmin(const QString &username, const QString &password,
                       const QString &realName, const QString &inviteCode, Admin &outAdmin);
    bool getAdminById(int id, Admin &outAdmin);
    bool registerUser(const User &user);

    bool getUserById(int id, User &outUser);
    bool updateUser(const User &user);
    bool rechargeUser(int userId, double amount);
    QVector<User> listUsers(const QString &keyword = QString());
    bool setUserStatus(int id, const QString &status, int adminId);
    bool deleteUser(int id);

    QVector<Station> listStations(double userLat = 39.9042, double userLng = 116.4074,
                                  const QString &keyword = QString(),
                                  const QString &district = QString(),
                                  int limit = 80, int offset = 0);
    bool getStation(int id, Station &out);
    bool saveStation(Station &station);
    bool createStationWithPiles(Station &station, int pileCount);
    bool deleteStation(int id);
    bool deleteStation(int id, bool force, int adminId);

    QVector<Pile> listPiles(int stationId = -1,
                            const QString &status = QString(),
                            const QString &speedClass = QString(),
                            const QString &connector = QString(),
                            const QString &district = QString());
    bool getPile(int id, Pile &out);
    bool savePile(Pile &pile);
    bool deletePile(int id);
    bool deletePile(int id, bool force, int adminId);
    bool updatePileStatus(int pileId, const QString &status,
                          const QString &source = QStringLiteral("system"),
                          const QString &reason = QString());
    bool restartPile(int pileId, int adminId);

    bool createReservation(int userId, int pileId, ChargingReservation &outReservation);
    bool cancelReservation(int userId, int reservationId);
    bool getActiveReservation(int userId, ChargingReservation &outReservation);
    QVector<ChargingReservation> listActiveReservations();
    bool adminCancelReservation(int reservationId, int adminId);

    bool listFavorites(int userId, const QString &targetType, QVector<int> &outIds);
    bool toggleFavorite(int userId, const QString &targetType, int targetId, bool &nowFavorite);

    bool createInviteCode(int adminId, const QString &role, QString &outCode);
    QVector<InviteCode> listInviteCodes();
    bool hasPermission(const QString &role, const QString &permission) const;
    QVector<QPair<QString, bool>> listRolePermissions(const QString &role) const;
    bool setRolePermission(const QString &role, const QString &permission, bool allowed, int adminId);
    static QStringList allPermissionKeys();

    bool deleteOrder(int orderId, int adminId);

    bool startCharging(int userId, int pileId, ChargingOrder &outOrder);
    bool updateChargingProgress(int userId, int orderId, double energyKwh);
    bool stopCharging(int orderId, double energyKwh, ChargingOrder &outOrder);
    bool getOngoingOrderByUser(int userId, ChargingOrder &outOrder);
    QVector<ChargingOrder> listOrders(int userId = -1, const QString &status = QString());

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
        int reservedPiles = 0;
        int restartingPiles = 0;
        int totalPiles = 0;
        int totalUsers = 0;
        int totalStations = 0;
    };
    SalesStats salesStats() const;
    QVector<QPair<QString, double>> dailySales(int days = 7) const;
    bool writeAdminAudit(int adminId, const QString &action, const QString &targetType,
                         int targetId, const QString &detail);

private:
    explicit DatabaseManager(QObject *parent = nullptr);
    bool openDatabase(const QString &dbPath);
    bool execSqlFile(const QString &filePath);
    bool ensureSchemaAndSeed();
    bool ensurePileColumns();
    bool ensureDefaultPermissions();
    bool migratePasswordHashes();
    bool upgradePasswordIfNeeded(const QString &table, int id, const QString &plain,
                                 const QString &hash, const QString &legacy);
    QString resolveDbPath(const QString &preferred) const;
    QString resolveCsvPath(const QString &preferred) const;
    double haversineKm(double lat1, double lon1, double lat2, double lon2) const;
    QString makeOrderNo() const;
    bool expireReservations();
    static QStringList splitCsvLine(const QString &line);
    void appendClassifiedPiles(int stationId, const QString &stationCode, uint seed,
                               double priceHint, QSqlQuery &q);

    QSqlDatabase m_db;
    QString m_lastError;
    QString m_dbPath;
};
