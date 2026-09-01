#include "LocalServer.h"

#include "FramedJson.h"

#include <QFile>
#include <QFileInfo>
#include <QJsonDocument>
#include <QTcpServer>
#include <QTcpSocket>
#include <QUrl>
#include <QUrlQuery>
#include <QUuid>

LocalServer::LocalServer(const QString &bindAddress, quint16 tcpPort, quint16 httpPort,
                         const QString &webRoot, QObject *parent)
    : QObject(parent)
    , m_bindAddress(bindAddress)
    , m_tcpPort(tcpPort)
    , m_httpPort(httpPort)
    , m_webRoot(webRoot)
{
}

void LocalServer::start()
{
    m_tcpServer = new QTcpServer(this);
    m_httpServer = new QTcpServer(this);
    connect(m_tcpServer, &QTcpServer::newConnection, this, &LocalServer::acceptTcpClients);
    connect(m_httpServer, &QTcpServer::newConnection, this, &LocalServer::acceptHttpClients);

    QHostAddress address;
    if (!address.setAddress(m_bindAddress))
        address = QHostAddress::LocalHost;
    if (!m_tcpServer->listen(address, m_tcpPort)) {
        emit fatalError(QStringLiteral("TCP 服务启动失败: %1").arg(m_tcpServer->errorString()));
        return;
    }
    if (!m_httpServer->listen(address, m_httpPort)) {
        m_tcpServer->close();
        emit fatalError(QStringLiteral("HTTP 服务启动失败: %1").arg(m_httpServer->errorString()));
        return;
    }
    emit started(m_tcpServer->serverPort(), m_httpServer->serverPort());
}

void LocalServer::stop()
{
    if (m_tcpServer)
        m_tcpServer->close();
    if (m_httpServer)
        m_httpServer->close();
    const auto tcpSockets = m_tcpBuffers.keys();
    const auto httpSockets = m_httpBuffers.keys();
    for (QTcpSocket *socket : tcpSockets)
        socket->disconnectFromHost();
    for (QTcpSocket *socket : httpSockets)
        socket->disconnectFromHost();
    m_pending.clear();
}

void LocalServer::acceptTcpClients()
{
    while (m_tcpServer->hasPendingConnections()) {
        QTcpSocket *socket = m_tcpServer->nextPendingConnection();
        socket->setProperty("connectionId", QUuid::createUuid().toString(QUuid::WithoutBraces));
        m_tcpBuffers.insert(socket, QByteArray());
        connect(socket, &QTcpSocket::readyRead, this, [this, socket]() { readTcp(socket); });
        connect(socket, &QTcpSocket::disconnected, this, [this, socket]() { removeSocket(socket); });
    }
    emit clientCountChanged(m_tcpBuffers.size());
}

void LocalServer::acceptHttpClients()
{
    while (m_httpServer->hasPendingConnections()) {
        QTcpSocket *socket = m_httpServer->nextPendingConnection();
        socket->setProperty("connectionId", QUuid::createUuid().toString(QUuid::WithoutBraces));
        m_httpBuffers.insert(socket, QByteArray());
        connect(socket, &QTcpSocket::readyRead, this, [this, socket]() { readHttp(socket); });
        connect(socket, &QTcpSocket::disconnected, this, [this, socket]() { removeSocket(socket); });
    }
}

void LocalServer::readTcp(QTcpSocket *socket)
{
    QByteArray &buffer = m_tcpBuffers[socket];
    buffer.append(socket->readAll());
    while (true) {
        QJsonObject request;
        QString error;
        const auto result = FramedJson::take(buffer, request, error);
        if (result == FramedJson::ReadResult::NeedMoreData)
            return;
        if (result == FramedJson::ReadResult::InvalidFrame) {
            socket->disconnectFromHost();
            return;
        }
        dispatch(socket, false, request);
    }
}

void LocalServer::readHttp(QTcpSocket *socket)
{
    QByteArray &buffer = m_httpBuffers[socket];
    buffer.append(socket->readAll());
    const int headerEnd = buffer.indexOf("\r\n\r\n");
    if (headerEnd < 0) {
        if (buffer.size() > 64 * 1024)
            respondHttp(socket, 431, "text/plain; charset=utf-8", "Request headers too large");
        return;
    }

    const QList<QByteArray> requestLine = buffer.left(buffer.indexOf("\r\n")).split(' ');
    if (requestLine.size() != 3 || requestLine.at(0) != "GET") {
        respondHttp(socket, 405, "text/plain; charset=utf-8", "Only GET is supported");
        return;
    }

    const QUrl url = QUrl::fromEncoded(requestLine.at(1));
    const QString path = url.path();
    if (!path.startsWith(QStringLiteral("/api/"))) {
        serveStatic(socket, path);
        return;
    }

    QJsonObject request{{"version", 1},
                        {"requestId", QUuid::createUuid().toString(QUuid::WithoutBraces)}};
    QJsonObject data;
    const QUrlQuery query(url);
    if (path == QLatin1String("/api/health"))
        request.insert("action", "server.health");
    else if (path == QLatin1String("/api/dashboard")) {
        request.insert("action", "dashboard.summary");
        data.insert("days", query.queryItemValue(QStringLiteral("days")).toInt());
    } else if (path == QLatin1String("/api/stations")) {
        request.insert("action", "dashboard.stations");
        data.insert("limit", query.queryItemValue(QStringLiteral("limit")).toInt());
        data.insert("offset", query.queryItemValue(QStringLiteral("offset")).toInt());
        data.insert("keyword", query.queryItemValue(QStringLiteral("q")));
        data.insert("district", query.queryItemValue(QStringLiteral("district")));
    } else {
        respondHttp(socket, 404, "application/json; charset=utf-8", "{\"ok\":false,\"message\":\"Not found\"}");
        return;
    }
    request.insert("data", data);
    dispatch(socket, true, request);
}

void LocalServer::dispatch(QTcpSocket *socket, bool http, QJsonObject request)
{
    QString requestId = request.value("requestId").toString();
    if (requestId.isEmpty()) {
        requestId = QUuid::createUuid().toString(QUuid::WithoutBraces);
        request.insert("requestId", requestId);
    }
    const QString key = requestKey(socket, requestId);
    m_pending.insert(key, {socket, http});
    emit requestReceived(key, request);
}

void LocalServer::sendResponse(const QString &channelId, const QJsonObject &response)
{
    const auto it = m_pending.find(channelId);
    if (it == m_pending.end())
        return;
    const PendingRequest pending = it.value();
    m_pending.erase(it);
    if (!pending.socket)
        return;
    if (pending.http) {
        respondHttp(pending.socket, response.value("ok").toBool() ? 200 : 400,
                    "application/json; charset=utf-8",
                    QJsonDocument(response).toJson(QJsonDocument::Compact));
    } else {
        pending.socket->write(FramedJson::encode(response));
    }
}

void LocalServer::serveStatic(QTcpSocket *socket, const QString &requestedPath)
{
    QString path = requestedPath;
    if (path.isEmpty() || path == QLatin1String("/"))
        path = QStringLiteral("/index.html");
    if (path.contains(QStringLiteral(".."))) {
        respondHttp(socket, 403, "text/plain; charset=utf-8", "Forbidden");
        return;
    }
    const QString filePath = m_webRoot + path;
    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly)) {
        respondHttp(socket, 404, "text/plain; charset=utf-8", "Not found");
        return;
    }
    QByteArray contentType = "application/octet-stream";
    if (path.endsWith(QStringLiteral(".html"))) contentType = "text/html; charset=utf-8";
    else if (path.endsWith(QStringLiteral(".css"))) contentType = "text/css; charset=utf-8";
    else if (path.endsWith(QStringLiteral(".js"))) contentType = "application/javascript; charset=utf-8";
    else if (path.endsWith(QStringLiteral(".svg"))) contentType = "image/svg+xml";
    respondHttp(socket, 200, contentType, file.readAll());
}

void LocalServer::respondHttp(QTcpSocket *socket, int status, const QByteArray &contentType,
                              const QByteArray &body)
{
    if (!socket)
        return;
    QByteArray reason = "OK";
    if (status == 400) reason = "Bad Request";
    else if (status == 403) reason = "Forbidden";
    else if (status == 404) reason = "Not Found";
    else if (status == 405) reason = "Method Not Allowed";
    else if (status == 431) reason = "Request Header Fields Too Large";
    QByteArray response = "HTTP/1.1 " + QByteArray::number(status) + " " + reason + "\r\n";
    response += "Content-Type: " + contentType + "\r\n";
    response += "Content-Length: " + QByteArray::number(body.size()) + "\r\n";
    response += "Cache-Control: no-cache\r\nConnection: close\r\n\r\n";
    response += body;
    socket->write(response);
    socket->disconnectFromHost();
}

void LocalServer::removeSocket(QTcpSocket *socket)
{
    m_tcpBuffers.remove(socket);
    m_httpBuffers.remove(socket);
    for (auto it = m_pending.begin(); it != m_pending.end();) {
        if (it->socket == socket)
            it = m_pending.erase(it);
        else
            ++it;
    }
    socket->deleteLater();
    emit clientCountChanged(m_tcpBuffers.size());
}

QString LocalServer::requestKey(QTcpSocket *socket, const QString &requestId) const
{
    return socket->property("connectionId").toString() + QLatin1Char(':') + requestId;
}
