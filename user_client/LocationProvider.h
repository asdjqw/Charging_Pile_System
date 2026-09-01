#pragma once

#include <QObject>
#include <QString>

class QNetworkAccessManager;
class QNetworkReply;

/**
 * 检测当前真实地理位置：
 * 1) 优先 GeoClue2（系统定位，含 GPS/Wi‑Fi）
 * 2) 回退 IP 定位（公网出口大致位置）
 */
class LocationProvider : public QObject
{
    Q_OBJECT
public:
    explicit LocationProvider(QObject *parent = nullptr);

    void requestCurrentLocation();
    bool isBusy() const { return m_busy; }

signals:
    void locationUpdated(double latitude, double longitude,
                         const QString &label, const QString &source);
    void locationFailed(const QString &reason);

private slots:
    void onIpFinished(QNetworkReply *reply);

private:
    void tryGeoClue();
    void tryIpLocate();
    void finishOk(double lat, double lng, const QString &label, const QString &source);
    void finishFail(const QString &reason);

    QNetworkAccessManager *m_nam = nullptr;
    bool m_busy = false;
    bool m_triedIp = false;
};
