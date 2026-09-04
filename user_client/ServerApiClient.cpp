#include "ServerApiClient.h"

#include "FramedJson.h"
#include "JsonCodec.h"

#include <QElapsedTimer>
#include <QJsonArray>
#include <QTcpSocket>
#include <QUuid>

ServerApiClient &ServerApiClient::instance()
{
    static ServerApiClient client;
    return client;
}

ServerApiClient::ServerApiClient(QObject *parent)
    : QObject(parent)
    , m_socket(new QTcpSocket(this))
{
}

bool ServerApiClient::initialize(const QString &host, quint16 port)
{
    m_host = host.trimmed().isEmpty() ? QStringLiteral("127.0.0.1") : host.trimmed();
    m_port = port > 0 ? port : 9000;
    return ensureConnected();
}

QString ServerApiClient::serverDescription() const
{
    return QStringLiteral("%1:%2").arg(m_host).arg(m_port);
}

bool ServerApiClient::ensureConnected()
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

QJsonObject ServerApiClient::call(const QString &action, const QJsonObject &data, bool authenticated)
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
    while (timer.elapsed() < 5000) {
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

bool ServerApiClient::accept(const QJsonObject &response)
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

bool ServerApiClient::ping()
{
    return accept(call(QStringLiteral("server.health"), QJsonObject(), false));
}

bool ServerApiClient::loginUser(const QString &username, const QString &password, User &outUser)
{
    const QJsonObject response = call(QStringLiteral("user.login"),
                                      {{"username", username}, {"password", password}}, false);
    if (!accept(response))
        return false;
    const QJsonObject data = response.value("data").toObject();
    m_token = data.value("token").toString();
    outUser = JsonCodec::userFromJson(data.value("user").toObject());
    return !m_token.isEmpty() && outUser.id > 0;
}

bool ServerApiClient::phoneLogin(const QString &phone, User &outUser, bool &created,
                                 const QString &password)
{
    QJsonObject payload{{"phone", phone}};
    if (!password.isEmpty())
        payload.insert("password", password);
    const QJsonObject response = call(QStringLiteral("user.phoneLogin"), payload, false);
    if (!accept(response))
        return false;
    const QJsonObject data = response.value("data").toObject();
    m_token = data.value("token").toString();
    created = data.value("created").toBool();
    outUser = JsonCodec::userFromJson(data.value("user").toObject());
    return !m_token.isEmpty() && outUser.id > 0;
}

bool ServerApiClient::registerUser(const User &user)
{
    QJsonObject data = JsonCodec::toJson(user);
    data.insert("password", user.password);
    return accept(call(QStringLiteral("user.register"), data, false));
}

bool ServerApiClient::logout()
{
    const bool ok = accept(call(QStringLiteral("user.logout")));
    m_token.clear();
    return ok;
}

bool ServerApiClient::listFavorites(QVector<int> &stationIds, QVector<int> &pileIds)
{
    stationIds.clear();
    pileIds.clear();
    const QJsonObject response = call(QStringLiteral("favorites.list"));
    if (!accept(response))
        return false;
    const QJsonObject data = response.value("data").toObject();
    for (const QJsonValue &value : data.value("stations").toArray())
        stationIds.push_back(value.toInt());
    for (const QJsonValue &value : data.value("piles").toArray())
        pileIds.push_back(value.toInt());
    return true;
}

bool ServerApiClient::toggleFavorite(const QString &targetType, int targetId, bool &nowFavorite)
{
    const QJsonObject response = call(QStringLiteral("favorites.toggle"),
                                      {{"targetType", targetType}, {"targetId", targetId}});
    if (!accept(response))
        return false;
    nowFavorite = response.value("data").toObject().value("favorite").toBool();
    return true;
}

bool ServerApiClient::getUserById(int, User &outUser)
{
    const QJsonObject response = call(QStringLiteral("user.get"));
    if (!accept(response))
        return false;
    outUser = JsonCodec::userFromJson(response.value("data").toObject());
    return true;
}

bool ServerApiClient::updateUser(const User &user)
{
    QJsonObject data = JsonCodec::toJson(user);
    data.insert("password", user.password);
    const QJsonObject response = call(QStringLiteral("user.update"), data);
    return accept(response);
}

bool ServerApiClient::rechargeUser(int, double amount)
{
    return accept(call(QStringLiteral("wallet.recharge"), {{"amount", amount}}));
}

QVector<Station> ServerApiClient::listStations(double userLat, double userLng,
                                               const QString &keyword, const QString &district,
                                               int limit)
{
    QVector<Station> values;
    const QJsonObject response = call(QStringLiteral("stations.list"),
                                      {{"latitude", userLat}, {"longitude", userLng},
                                       {"keyword", keyword}, {"district", district}, {"limit", limit}});
    if (!accept(response))
        return values;
    const QJsonObject data = response.value("data").toObject();
    m_stationCount = data.value("stationCount").toInt();
    m_pileCount = data.value("pileCount").toInt();
    for (const QJsonValue &value : data.value("items").toArray())
        values.push_back(JsonCodec::stationFromJson(value.toObject()));
    return values;
}

QStringList ServerApiClient::districts()
{
    QStringList values;
    const QJsonObject response = call(QStringLiteral("stations.districts"));
    if (!accept(response))
        return values;
    for (const QJsonValue &value : response.value("data").toObject().value("items").toArray())
        values.append(value.toString());
    return values;
}

QVector<Pile> ServerApiClient::listPiles(int stationId, const QString &status,
                                         const QString &speedClass, const QString &connector)
{
    QVector<Pile> values;
    const QJsonObject response = call(QStringLiteral("piles.list"),
                                      {{"stationId", stationId}, {"status", status},
                                       {"speedClass", speedClass}, {"connector", connector}});
    if (!accept(response))
        return values;
    for (const QJsonValue &value : response.value("data").toObject().value("items").toArray())
        values.push_back(JsonCodec::pileFromJson(value.toObject()));
    return values;
}

bool ServerApiClient::getPile(int id, Pile &out)
{
    const QJsonObject response = call(QStringLiteral("piles.get"), {{"pileId", id}});
    if (!accept(response))
        return false;
    out = JsonCodec::pileFromJson(response.value("data").toObject());
    return true;
}

bool ServerApiClient::createReservation(int pileId, ChargingReservation &outReservation)
{
    const QJsonObject response = call(QStringLiteral("reservation.create"), {{"pileId", pileId}});
    if (!accept(response))
        return false;
    outReservation = JsonCodec::reservationFromJson(response.value("data").toObject());
    return outReservation.id > 0;
}

bool ServerApiClient::cancelReservation(int reservationId)
{
    return accept(call(QStringLiteral("reservation.cancel"), {{"reservationId", reservationId}}));
}

bool ServerApiClient::getActiveReservation(ChargingReservation &outReservation)
{
    const QJsonObject response = call(QStringLiteral("reservation.active"));
    if (!accept(response))
        return false;
    const QJsonObject data = response.value("data").toObject();
    if (!data.value("found").toBool())
        return false;
    outReservation = JsonCodec::reservationFromJson(data.value("reservation").toObject());
    return outReservation.id > 0;
}

bool ServerApiClient::startCharging(int, int pileId, ChargingOrder &outOrder)
{
    const QJsonObject response = call(QStringLiteral("charge.start"), {{"pileId", pileId}});
    if (!accept(response))
        return false;
    outOrder = JsonCodec::orderFromJson(response.value("data").toObject());
    return true;
}

bool ServerApiClient::updateChargingProgress(int, int orderId, double energyKwh)
{
    return accept(call(QStringLiteral("charge.progress"),
                       {{"orderId", orderId}, {"energyKwh", energyKwh}}));
}

bool ServerApiClient::stopCharging(int orderId, double energyKwh, ChargingOrder &outOrder)
{
    const QJsonObject response = call(QStringLiteral("charge.stop"),
                                      {{"orderId", orderId}, {"energyKwh", energyKwh}});
    if (!accept(response))
        return false;
    outOrder = JsonCodec::orderFromJson(response.value("data").toObject());
    return true;
}

bool ServerApiClient::getOngoingOrderByUser(int, ChargingOrder &outOrder)
{
    const QJsonObject response = call(QStringLiteral("charge.ongoing"));
    if (!accept(response))
        return false;
    const QJsonObject data = response.value("data").toObject();
    if (!data.value("found").toBool())
        return false;
    outOrder = JsonCodec::orderFromJson(data.value("order").toObject());
    return true;
}

QVector<ChargingOrder> ServerApiClient::listOrders(int, const QString &status)
{
    QVector<ChargingOrder> values;
    const QJsonObject response = call(QStringLiteral("orders.list"), {{"status", status}});
    if (!accept(response))
        return values;
    for (const QJsonValue &value : response.value("data").toObject().value("items").toArray())
        values.push_back(JsonCodec::orderFromJson(value.toObject()));
    return values;
}
