#pragma once

#include "Models.h"

#include <QHash>
#include <QJsonObject>
#include <QObject>
#include <QPair>
#include <QVector>

class QTcpSocket;

class AdminApiClient : public QObject
{
    Q_OBJECT
public:
    static AdminApiClient &instance();

    bool initialize(const QString &host = QStringLiteral("127.0.0.1"), quint16 port = 9000);
    QString lastError() const { return m_lastError; }
    QString lastCode() const { return m_lastCode; }
    bool needsForce() const { return m_lastCode == QLatin1String("NEED_FORCE"); }
    QString serverDescription() const;
    bool ping();

    bool loginAdmin(const QString &username, const QString &password, Admin &outAdmin);
    bool registerAdmin(const QString &username, const QString &password,
                       const QString &realName, const QString &inviteCode, Admin &outAdmin);
    bool logout();

    QJsonObject dashboard(int days);
    QVector<Pile> listPiles(int stationId = -1, const QString &status = QString());
    QJsonObject pileStats();
    bool restartPile(int pileId);
    bool savePile(Pile &pile);
    bool deletePile(int pileId, bool force = false);

    QVector<Station> listStations(const QString &keyword = QString());
    bool saveStation(Station &station, int pileCount);
    bool deleteStation(int stationId, bool force = false);
    QVector<Pile> listStationPiles(int stationId, Station *outStation = nullptr);

    QVector<User> listUsers(const QString &keyword = QString());
    bool setUserStatus(int userId, const QString &status);
    QVector<ChargingOrder> listUserOrders(int userId);
    bool deleteOrder(int orderId);

    QVector<ChargingReservation> listReservations();
    bool cancelReservation(int reservationId);

    QVector<InviteCode> listInviteCodes();
    bool createInviteCode(const QString &role, QString &outCode);
    QVector<QPair<QString, bool>> listPermissions(const QString &role);
    bool setPermission(const QString &role, const QString &permission, bool allowed);

private:
    explicit AdminApiClient(QObject *parent = nullptr);
    bool ensureConnected();
    QJsonObject call(const QString &action, const QJsonObject &data = QJsonObject(),
                     bool authenticated = true);
    bool accept(const QJsonObject &response);

    QTcpSocket *m_socket = nullptr;
    QString m_host;
    quint16 m_port = 9000;
    QString m_token;
    QString m_lastError;
    QString m_lastCode;
    QByteArray m_readBuffer;
    QHash<QString, QJsonObject> m_queuedResponses;
};
