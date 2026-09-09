#include "LocationProvider.h"

#include <QDBusConnection>
#include <QDBusInterface>
#include <QDBusObjectPath>
#include <QDBusReply>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QTimer>
#include <QUrl>
#include <QVariantMap>

namespace {

bool looksLikeVirtualMachine()
{
    const QStringList paths = {
        QStringLiteral("/sys/class/dmi/id/product_name"),
        QStringLiteral("/sys/class/dmi/id/sys_vendor"),
        QStringLiteral("/sys/class/dmi/id/bios_vendor")
    };
    for (const QString &path : paths) {
        QFile f(path);
        if (!f.open(QIODevice::ReadOnly | QIODevice::Text))
            continue;
        const QString text = QString::fromUtf8(f.readAll()).toLower();
        if (text.contains(QLatin1String("vmware"))
            || text.contains(QLatin1String("virtualbox"))
            || text.contains(QLatin1String("qemu"))
            || text.contains(QLatin1String("kvm"))
            || text.contains(QLatin1String("xen"))
            || text.contains(QLatin1String("microsoft corporation"))
            || text.contains(QLatin1String("bochs"))
            || text.contains(QLatin1String("innotek"))) {
            return true;
        }
    }
    return false;
}

} // namespace

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
    m_ipPending = false;

    // 整体超时：给 IP 回退留足时间，避免与 GeoClue 轮询抢超时
    QTimer::singleShot(15000, this, [this]() {
        if (!m_busy)
            return;
        if (!m_triedIp) {
            tryIpLocate();
            return;
        }
        // IP 请求还在路上时继续等 onIpFinished，不要提前判失败
        if (m_ipPending)
            return;
        finishFail(QStringLiteral(
            "定位超时。虚拟机通常没有 Wi‑Fi/GPS，系统定位会失败；"
            "请检查外网，或改用手动地址（如「国贸」「海淀区」）。"));
    });

    // 虚拟机无法获得可靠系统定位：直接使用良乡校区默认坐标（课堂演示）
    if (looksLikeVirtualMachine()) {
        finishOk(39.735678, 116.171271,
                 QStringLiteral("北京理工大学良乡校区"),
                 QStringLiteral("default"));
        return;
    }

    tryGeoClue();
}

void LocationProvider::finishOk(double lat, double lng, const QString &label, const QString &source)
{
    m_busy = false;
    m_ipPending = false;
    emit locationUpdated(lat, lng, label, source);
}

void LocationProvider::finishFail(const QString &reason)
{
    m_busy = false;
    m_ipPending = false;
    emit locationFailed(reason);
}

void LocationProvider::tryGeoClue()
{
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

    // 需在 /etc/geoclue/geoclue.conf 增加 [charge-pile-user] allowed=true
    client.setProperty("DesktopId", QStringLiteral("charge-pile-user"));
    client.setProperty("RequestedAccuracyLevel", QVariant::fromValue(uint(4))); // city
    client.call(QStringLiteral("Start"));

    auto *timer = new QTimer(this);
    timer->setInterval(500);
    connect(timer, &QTimer::timeout, this, [this, path, timer, tries = 0]() mutable {
        if (!m_busy) {
            timer->stop();
            timer->deleteLater();
            return;
        }
        ++tries;
        QDBusInterface client(QStringLiteral("org.freedesktop.GeoClue2"),
                              path,
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
        // 约 6 秒仍无结果则回退 IP
        if (tries >= 12) {
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
        if (!m_ipPending) {
            finishFail(QStringLiteral(
                "无法获取当前位置（系统定位与 IP 定位均失败）。"
                "若在虚拟机中，请改用手动地址，或到带 Wi‑Fi/GPS 的物理机运行用户端。"));
        }
        return;
    }
    m_triedIp = true;
    m_ipPending = true;
    // 多源：ip-api 为主
    QNetworkRequest req(QUrl(QStringLiteral(
        "http://ip-api.com/json/?lang=zh-CN&fields=status,message,lat,lon,city,regionName,country,query")));
    req.setHeader(QNetworkRequest::UserAgentHeader, QStringLiteral("ChargePileUser/1.0"));
    req.setTransferTimeout(8000);
    m_nam->get(req);
}

void LocationProvider::onIpFinished(QNetworkReply *reply)
{
    reply->deleteLater();
    m_ipPending = false;
    if (!m_busy)
        return;

    if (reply->error() != QNetworkReply::NoError) {
        finishFail(QStringLiteral("IP 定位失败：%1\n可填写「国贸」「朝阳区」等后点定位。")
                       .arg(reply->errorString()));
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
    const QString query = obj.value(QStringLiteral("query")).toString();
    QString label = QStringLiteral("%1 %2 %3")
                        .arg(country, region, city)
                        .simplified();
    if (!query.isEmpty())
        label += QStringLiteral(" (出口IP %1)").arg(query);
    if (looksLikeVirtualMachine())
        label = QStringLiteral("[虚拟机·公网IP粗定位] ") + label;

    finishOk(lat, lng,
             label.isEmpty() ? QStringLiteral("IP 定位") : label,
             QStringLiteral("IP"));
}
