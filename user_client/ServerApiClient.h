#pragma once

#include "Models.h"

#include <QHash>
#include <QJsonObject>
#include <QObject>
#include <QVector>

class QTcpSocket;

class ServerApiClient : public QObject
{
    Q_OBJECT
public:
    static ServerApiClient &instance();

    bool initialize(const QString &host = QStringLiteral("127.0.0.1"), quint16 port = 9000);
    QString lastError() const { return m_lastError; }
    QString serverDescription() const;
    bool ping();

    bool loginUser(const QString &username, const QString &password, User &outUser);
    bool phoneLogin(const QString &phone, User &outUser, bool &created,
                    const QString &password = QString());
    bool registerUser(const User &user);
    bool logout();
    bool getUserById(int id, User &outUser);
    bool updateUser(const User &user);
    bool rechargeUser(int userId, double amount);

    bool listFavorites(QVector<int> &stationIds, QVector<int> &pileIds);
    bool toggleFavorite(const QString &targetType, int targetId, bool &nowFavorite);

    QVector<Station> listStations(double userLat, double userLng, const QString &keyword,
                                  const QString &district, int limit);
    QStringList districts();
    int stationCount() const { return m_stationCount; }
    int pileCount() const { return m_pileCount; }

    QVector<Pile> listPiles(int stationId, const QString &status = QString(),
                            const QString &speedClass = QString(),
                            const QString &connector = QString());
    bool getPile(int id, Pile &out);

    bool createReservation(int pileId, ChargingReservation &outReservation);
    bool cancelReservation(int reservationId);
    bool getActiveReservation(ChargingReservation &outReservation);

    bool startCharging(int userId, int pileId, ChargingOrder &outOrder);
    bool updateChargingProgress(int userId, int orderId, double energyKwh);
    bool stopCharging(int orderId, double energyKwh, ChargingOrder &outOrder);
    bool getOngoingOrderByUser(int userId, ChargingOrder &outOrder);
    QVector<ChargingOrder> listOrders(int userId, const QString &status = QString());

private:
    explicit ServerApiClient(QObject *parent = nullptr);
    bool ensureConnected();
    QJsonObject call(const QString &action, const QJsonObject &data = QJsonObject(),
                     bool authenticated = true);
    bool accept(const QJsonObject &response);

    QTcpSocket *m_socket = nullptr;
    QString m_host;
    quint16 m_port = 9000;
    QString m_token;
    QString m_lastError;
    QByteArray m_readBuffer;
    QHash<QString, QJsonObject> m_queuedResponses;
    int m_stationCount = 0;
    int m_pileCount = 0;
};
