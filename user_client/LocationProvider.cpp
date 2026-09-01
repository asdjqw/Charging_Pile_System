#include "LocationProvider.h"

#include <QDBusConnection>
#include <QDBusInterface>
#include <QDBusMessage>
#include <QDBusReply>
#include <QDBusVariant>
#include <QJsonDocument>
#include <QJsonObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QTimer>
#include <QUrl>
#include <QVariantMap>

LocationProvider::LocationProvider(QObject *parent)
    : QObject(parent)
    , m_nam(new QNetworkAccessManager(this))
{
    connect(m_nam, &QNetworkAccessManager::finished, this, &LocationProvider::onIpFinished);
}

void LocationProvider::requestCurrentLocation()
{
    if (m_busy)
        return;
    m_busy = true;
    m_triedIp = false;
    tryGeoClue();
}

void LocationProvider::finishOk(double lat, double lng, const QString &label, const QString &source)
{
    m_busy = false;
    emit locationUpdated(lat, lng, label, source);
}

void LocationProvider::finishFail(const QString &reason)
{
    m_busy = false;
    emit locationFailed(reason);
}

void LocationProvider::tryGeoClue()
{
    // GeoClue2 系统总线定位（有 GPS/Wi‑Fi 代理时可用）
    QDBusInterface manager(QStringLiteral("org.freedesktop.GeoClue2"),
                           QStringLiteral("/org/freedesktop/GeoClue2/Manager"),
                           QStringLiteral("org.freedesktop.GeoClue2.Manager"),
                           QDBusConnection::systemBus());
    if (!manager.isValid()) {
        tryIpLocate();
        return;
    }

    QDBusReply<QDBusObjectPath> clientPath = manager.call(QStringLiteral("GetClient"));
    if (!clientPath.isValid()) {
        tryIpLocate();
        return;
    }

    const QString path = clientPath.value().path();
    QDBusInterface client(QStringLiteral("org.freedesktop.GeoClue2"),
                          path,
                          QStringLiteral("org.freedesktop.GeoClue2.Client"),
                          QDBusConnection::systemBus());
    if (!client.isValid()) {
        tryIpLocate();
        return;
    }

    client.setProperty("DesktopId", QStringLiteral("charge-pile-user"));
    client.setProperty("RequestedAccuracyLevel", QVariant::fromValue(uint(4))); // Exact
    client.call(QStringLiteral("Start"));

    // 轮询等待定位结果（最多约 4 秒）
    auto *timer = new QTimer(this);
    timer->setInterval(400);
    connect(timer, &QTimer::timeout, this, [this, clientPath = path, timer, tries = 0]() mutable {
        ++tries;
        QDBusInterface client(QStringLiteral("org.freedesktop.GeoClue2"),
                              clientPath,
                              QStringLiteral("org.freedesktop.GeoClue2.Client"),
                              QDBusConnection::systemBus());
        const QVariant locPathVar = client.property("Location");
        const QDBusObjectPath locPath = qvariant_cast<QDBusObjectPath>(locPathVar);
        if (locPath.path().size() > 1 && locPath.path() != QLatin1String("/")) {
            QDBusInterface loc(QStringLiteral("org.freedesktop.GeoClue2"),
                               locPath.path(),
                               QStringLiteral("org.freedesktop.GeoClue2.Location"),
                               QDBusConnection::systemBus());
            const double lat = loc.property("Latitude").toDouble();
            const double lng = loc.property("Longitude").toDouble();
            timer->stop();
            timer->deleteLater();
            client.call(QStringLiteral("Stop"));
            if (qAbs(lat) > 0.01 || qAbs(lng) > 0.01) {
                finishOk(lat, lng,
                         QStringLiteral("系统定位 (%1, %2)").arg(lat, 0, 'f', 5).arg(lng, 0, 'f', 5),
                         QStringLiteral("GeoClue"));
                return;
            }
        }
        if (tries >= 10) {
            timer->stop();
            timer->deleteLater();
            client.call(QStringLiteral("Stop"));
            tryIpLocate();
        }
    });
    timer->start();
}

void LocationProvider::tryIpLocate()
{
    if (m_triedIp) {
        finishFail(QStringLiteral("无法获取当前位置（系统定位与 IP 定位均失败）"));
        return;
    }
    m_triedIp = true;
    // ip-api.com 免费接口，返回公网出口大致经纬度
    QNetworkRequest req(QUrl(QStringLiteral(
        "http://ip-api.com/json/?fields=status,message,lat,lon,city,regionName,country")));
    req.setHeader(QNetworkRequest::UserAgentHeader, QStringLiteral("ChargePileUser/1.0"));
    m_nam->get(req);
}

void LocationProvider::onIpFinished(QNetworkReply *reply)
{
    reply->deleteLater();
    if (!m_busy)
        return;

    if (reply->error() != QNetworkReply::NoError) {
        finishFail(QStringLiteral("IP 定位失败：%1").arg(reply->errorString()));
        return;
    }

    const QJsonObject obj = QJsonDocument::fromJson(reply->readAll()).object();
    if (obj.value(QStringLiteral("status")).toString() != QLatin1String("success")) {
        finishFail(QStringLiteral("IP 定位失败：%1")
                       .arg(obj.value(QStringLiteral("message")).toString()));
        return;
    }

    const double lat = obj.value(QStringLiteral("lat")).toDouble();
    const double lng = obj.value(QStringLiteral("lon")).toDouble();
    const QString city = obj.value(QStringLiteral("city")).toString();
    const QString region = obj.value(QStringLiteral("regionName")).toString();
    const QString country = obj.value(QStringLiteral("country")).toString();
    const QString label = QStringLiteral("%1 %2 %3")
                              .arg(country, region, city)
                              .simplified();
    finishOk(lat, lng,
             label.isEmpty() ? QStringLiteral("IP 定位") : label,
             QStringLiteral("IP"));
}
