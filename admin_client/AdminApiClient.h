#pragma once

#include "Models.h"

#include <QHash>
#include <QJsonObject>
#include <QObject>
#include <QVector>

class QTcpSocket;

class AdminApiClient : public QObject
{
    Q_OBJECT
public:
    static AdminApiClient &instance();

    bool initialize(const QString &host = QStringLiteral("127.0.0.1"), quint16 port = 9000);
    QString lastError() const { return m_lastError; }
    QString serverDescription() const;
    bool ping();

    bool loginAdmin(const QString &username, const QString &password, Admin &outAdmin);

    QJsonObject dashboard(int days);
    QVector<Pile> listPiles(int stationId = -1, const QString &status = QString());
    QJsonObject pileStats();
    bool restartPile(int pileId);

    QVector<Station> listStations(const QString &keyword = QString());
    bool saveStation(Station &station, int pileCount);
    QVector<Pile> listStationPiles(int stationId, Station *outStation = nullptr);

    QVector<User> listUsers(const QString &keyword = QString());
    bool setUserStatus(int userId, const QString &status);

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
    QByteArray m_readBuffer;
    QHash<QString, QJsonObject> m_queuedResponses;
};
