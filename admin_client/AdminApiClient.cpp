#include "AdminApiClient.h"

#include "FramedJson.h"
#include "JsonCodec.h"

#include <QElapsedTimer>
#include <QJsonArray>
#include <QTcpSocket>
#include <QUuid>

AdminApiClient &AdminApiClient::instance()
{
    static AdminApiClient client;
    return client;
}

AdminApiClient::AdminApiClient(QObject *parent)
    : QObject(parent)
    , m_socket(new QTcpSocket(this))
{
}

bool AdminApiClient::initialize(const QString &host, quint16 port)
{
    m_host = host.trimmed().isEmpty() ? QStringLiteral("127.0.0.1") : host.trimmed();
    m_port = port > 0 ? port : 9000;
    return ensureConnected();
}

QString AdminApiClient::serverDescription() const
{
    return QStringLiteral("%1:%2").arg(m_host).arg(m_port);
}

bool AdminApiClient::ensureConnected()
{
    if (m_socket->state() == QAbstractSocket::ConnectedState)
        return true;
    m_socket->abort();
    m_readBuffer.clear();
    m_socket->connectToHost(m_host, m_port);
    if (!m_socket->waitForConnected(3000)) {
        m_lastError = QStringLiteral("无法连接服务端 %1：%2")
                          .arg(serverDescription(), m_socket->errorString());
        return false;
    }
    return true;
}

QJsonObject AdminApiClient::call(const QString &action, const QJsonObject &data, bool authenticated)
{
    if (!ensureConnected())
        return {};

    const QString requestId = QUuid::createUuid().toString(QUuid::WithoutBraces);
    QJsonObject request{{"version", 1}, {"requestId", requestId}, {"action", action}, {"data", data}};
    if (authenticated)
        request.insert("token", m_token);

    const QByteArray frame = FramedJson::encode(request);
    if (m_socket->write(frame) != frame.size() || !m_socket->waitForBytesWritten(3000)) {
        m_lastError = QStringLiteral("发送请求失败：%1").arg(m_socket->errorString());
        return {};
    }

    QElapsedTimer timer;
    timer.start();
    while (timer.elapsed() < 8000) {
        const auto queued = m_queuedResponses.find(requestId);
        if (queued != m_queuedResponses.end()) {
            const QJsonObject response = queued.value();
            m_queuedResponses.erase(queued);
            return response;
        }

        if (m_socket->bytesAvailable() == 0 && !m_socket->waitForReadyRead(500)) {
            if (m_socket->state() != QAbstractSocket::ConnectedState) {
                m_lastError = QStringLiteral("服务端连接已断开：%1").arg(m_socket->errorString());
                return {};
            }
            continue;
        }
        m_readBuffer.append(m_socket->readAll());
        while (true) {
            QJsonObject response;
            QString error;
            const auto result = FramedJson::take(m_readBuffer, response, error);
            if (result == FramedJson::ReadResult::NeedMoreData)
                break;
            if (result == FramedJson::ReadResult::InvalidFrame) {
                m_lastError = error;
                m_socket->abort();
                return {};
            }
            const QString responseId = response.value("requestId").toString();
            if (responseId == requestId)
                return response;
            m_queuedResponses.insert(responseId, response);
        }
    }
    m_lastError = QStringLiteral("服务端请求超时：%1").arg(action);
    return {};
}

bool AdminApiClient::accept(const QJsonObject &response)
{
    if (response.isEmpty())
        return false;
    if (!response.value("ok").toBool()) {
        m_lastError = response.value("message").toString(QStringLiteral("服务端请求失败"));
        if (response.value("code").toString() == QLatin1String("UNAUTHORIZED"))
            m_token.clear();
        return false;
    }
    m_lastError.clear();
    return true;
}

bool AdminApiClient::ping()
{
    return accept(call(QStringLiteral("server.health"), QJsonObject(), false));
}

bool AdminApiClient::loginAdmin(const QString &username, const QString &password, Admin &outAdmin)
{
    const QJsonObject response = call(QStringLiteral("admin.login"),
                                      {{"username", username}, {"password", password}}, false);
    if (!accept(response))
        return false;
    const QJsonObject data = response.value("data").toObject();
    m_token = data.value("token").toString();
    outAdmin = JsonCodec::adminFromJson(data.value("admin").toObject());
    return !m_token.isEmpty() && outAdmin.id > 0;
}

QJsonObject AdminApiClient::dashboard(int days)
{
    const QJsonObject response = call(QStringLiteral("admin.dashboard"), {{"days", days}});
    if (!accept(response))
        return {};
    return response.value("data").toObject();
}

QStringList AdminApiClient::districts()
{
    QStringList values;
    const QJsonObject response = call(QStringLiteral("admin.stations.districts"));
    if (!accept(response))
        return values;
    for (const QJsonValue &value : response.value("data").toObject().value("items").toArray())
        values << value.toString();
    return values;
}

QVector<Pile> AdminApiClient::listPiles(int stationId, const QString &status, const QString &district)
{
    QVector<Pile> values;
    const QJsonObject response = call(QStringLiteral("admin.piles.list"),
                                      {{"stationId", stationId},
                                       {"status", status},
                                       {"district", district}});
    if (!accept(response))
        return values;
    for (const QJsonValue &value : response.value("data").toObject().value("items").toArray())
        values.push_back(JsonCodec::pileFromJson(value.toObject()));
    return values;
}

QJsonObject AdminApiClient::pileStats()
{
    const QJsonObject payload = dashboard(7);
    if (payload.isEmpty())
        return {};
    return payload.value("stats").toObject();
}

bool AdminApiClient::restartPile(int pileId)
{
    return accept(call(QStringLiteral("admin.piles.restart"), {{"pileId", pileId}}));
}

QVector<Station> AdminApiClient::listStations(const QString &keyword, const QString &district)
{
    QVector<Station> values;
    const QJsonObject response = call(QStringLiteral("admin.stations.list"),
                                      {{"keyword", keyword}, {"district", district}});
    if (!accept(response))
        return values;
    for (const QJsonValue &value : response.value("data").toObject().value("items").toArray())
        values.push_back(JsonCodec::stationFromJson(value.toObject()));
    return values;
}

bool AdminApiClient::saveStation(Station &station, int pileCount)
{
    QJsonObject payload = JsonCodec::toJson(station);
    payload.insert("pileCount", pileCount);
    const QJsonObject response = call(QStringLiteral("admin.stations.save"), payload);
    if (!accept(response))
        return false;
    station = JsonCodec::stationFromJson(response.value("data").toObject());
    return true;
}

QVector<Pile> AdminApiClient::listStationPiles(int stationId, Station *outStation)
{
    QVector<Pile> values;
    const QJsonObject response = call(QStringLiteral("admin.stations.piles"), {{"stationId", stationId}});
    if (!accept(response))
        return values;
    const QJsonObject data = response.value("data").toObject();
    if (outStation)
        *outStation = JsonCodec::stationFromJson(data.value("station").toObject());
    for (const QJsonValue &value : data.value("items").toArray())
        values.push_back(JsonCodec::pileFromJson(value.toObject()));
    return values;
}

QVector<User> AdminApiClient::listUsers(const QString &keyword)
{
    QVector<User> values;
    const QJsonObject response = call(QStringLiteral("admin.users.list"), {{"keyword", keyword}});
    if (!accept(response))
        return values;
    for (const QJsonValue &value : response.value("data").toObject().value("items").toArray())
        values.push_back(JsonCodec::userFromJson(value.toObject()));
    return values;
}

bool AdminApiClient::setUserStatus(int userId, const QString &status)
{
    return accept(call(QStringLiteral("admin.users.setStatus"),
                       {{"userId", userId}, {"status", status}}));
}
