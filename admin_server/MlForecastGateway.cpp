#include "MlForecastGateway.h"

#include <QEventLoop>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonParseError>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QObject>
#include <QtGlobal>
#include <QTimer>
#include <QUrl>

namespace {

QString serviceBase()
{
    QString base = qEnvironmentVariable("CHARGE_PILE_ML_URL", QStringLiteral("http://127.0.0.1:5010"));
    while (base.endsWith(QLatin1Char('/')))
        base.chop(1);
    return base;
}

QJsonObject parseBody(const QByteArray &raw)
{
    QJsonParseError err;
    const QJsonDocument doc = QJsonDocument::fromJson(raw, &err);
    if (err.error != QJsonParseError::NoError || !doc.isObject())
        return {};
    return doc.object();
}

QJsonObject httpGetJson(const QUrl &url, QString *errorOut)
{
    QNetworkAccessManager manager;
    QNetworkRequest request(url);
    request.setRawHeader("Accept", "application/json");
#if QT_VERSION >= QT_VERSION_CHECK(5, 15, 0)
    request.setTransferTimeout(3500);
#endif

    QNetworkReply *reply = manager.get(request);
    QEventLoop loop;
    QTimer timer;
    timer.setSingleShot(true);
    QObject::connect(&timer, &QTimer::timeout, &loop, &QEventLoop::quit);
    QObject::connect(reply, &QNetworkReply::finished, &loop, &QEventLoop::quit);
    timer.start(4000);
    loop.exec();

    if (!reply->isFinished()) {
        reply->abort();
        if (errorOut)
            *errorOut = QStringLiteral("机器学习服务响应超时（%1）").arg(url.toString());
        reply->deleteLater();
        return {};
    }

    const QByteArray raw = reply->readAll();
    const auto netError = reply->error();
    const int httpStatus = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    reply->deleteLater();

    if (netError == QNetworkReply::ConnectionRefusedError
        || netError == QNetworkReply::HostNotFoundError
        || netError == QNetworkReply::TimeoutError) {
        if (errorOut) {
            *errorOut = QStringLiteral("无法连接机器学习服务 %1。请先启动：python -m ml.cli.warehouse_api")
                            .arg(serviceBase());
        }
        return {};
    }

    const QJsonObject body = parseBody(raw);
    if (body.isEmpty()) {
        if (errorOut) {
            *errorOut = httpStatus > 0
                            ? QStringLiteral("机器学习服务返回了无法解析的数据（HTTP %1）").arg(httpStatus)
                            : QStringLiteral("机器学习服务无有效响应");
        }
        return {};
    }
    return body;
}

QJsonObject unwrapPayload(const QJsonObject &body, QString *errorOut)
{
    const int code = body.value(QStringLiteral("code")).toInt(-1);
    if (code == 0)
        return body.value(QStringLiteral("data")).toObject();
    const QString msg = body.value(QStringLiteral("msg")).toString(QStringLiteral("预测查询失败"));
    if (errorOut)
        *errorOut = msg;
    return {};
}

} // namespace

QJsonObject MlForecastGateway::queryStation(int stationId, QString *errorOut)
{
    if (stationId <= 0) {
        if (errorOut)
            *errorOut = QStringLiteral("电站编号无效");
        return {};
    }

    const QString base = serviceBase();
    QString err;
    const QJsonObject stationBody =
        httpGetJson(QUrl(QStringLiteral("%1/api/forecast/station/%2").arg(base).arg(stationId)), &err);
    QJsonObject payload = unwrapPayload(stationBody, &err);
    const QJsonArray matchedStations = payload.value(QStringLiteral("stations")).toArray();
    if (!payload.isEmpty() && !matchedStations.isEmpty()) {
        payload.insert(QStringLiteral("matched"), true);
        payload.insert(QStringLiteral("requested_station_id"), stationId);
        return payload;
    }

    QString latestErr;
    const QJsonObject latestBody =
        httpGetJson(QUrl(QStringLiteral("%1/api/forecast/latest").arg(base)), &latestErr);
    QJsonObject latest = unwrapPayload(latestBody, &latestErr);
    const QJsonArray stations = latest.value(QStringLiteral("stations")).toArray();
    if (!latest.isEmpty() && !stations.isEmpty()) {
        const QJsonObject sample = stations.at(0).toObject();
        latest.insert(QStringLiteral("matched"), false);
        latest.insert(QStringLiteral("requested_station_id"), stationId);
        latest.insert(QStringLiteral("sample_station_id"), sample.value(QStringLiteral("station_id")).toInt());
        latest.insert(QStringLiteral("stations"), QJsonArray{sample});
        return latest;
    }

    if (errorOut) {
        if (!err.isEmpty())
            *errorOut = err;
        else if (!latestErr.isEmpty())
            *errorOut = latestErr;
        else
            *errorOut = QStringLiteral("暂无已发布的预测批次，请先运行机器学习预测");
    }
    return {};
}
