#pragma once

#include <QHash>
#include <QJsonObject>
#include <QObject>
#include <QPointer>

class QTcpServer;
class QTcpSocket;

class LocalServer : public QObject
{
    Q_OBJECT
public:
    explicit LocalServer(const QString &bindAddress, quint16 tcpPort, quint16 httpPort,
                         const QString &webRoot,
                         QObject *parent = nullptr);

public slots:
    void start();
    void stop();
    void sendResponse(const QString &channelId, const QJsonObject &response);

signals:
    void requestReceived(const QString &channelId, const QJsonObject &request);
    void started(quint16 tcpPort, quint16 httpPort);
    void fatalError(const QString &message);
    void clientCountChanged(int count);

private:
    struct PendingRequest {
        QPointer<QTcpSocket> socket;
        bool http = false;
    };

    void acceptTcpClients();
    void acceptHttpClients();
    void readTcp(QTcpSocket *socket);
    void readHttp(QTcpSocket *socket);
    void removeSocket(QTcpSocket *socket);
    void dispatch(QTcpSocket *socket, bool http, QJsonObject request);
    void serveStatic(QTcpSocket *socket, const QString &path);
    void respondHttp(QTcpSocket *socket, int status, const QByteArray &contentType,
                     const QByteArray &body);
    QString requestKey(QTcpSocket *socket, const QString &requestId) const;

    QString m_bindAddress;
    quint16 m_tcpPort;
    quint16 m_httpPort;
    QString m_webRoot;
    QTcpServer *m_tcpServer = nullptr;
    QTcpServer *m_httpServer = nullptr;
    QHash<QTcpSocket *, QByteArray> m_tcpBuffers;
    QHash<QTcpSocket *, QByteArray> m_httpBuffers;
    QHash<QString, PendingRequest> m_pending;
};
