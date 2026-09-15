#pragma once

#include <QJsonObject>
#include <QString>

namespace MlForecastGateway {

// 向本机机器学习查询服务（默认 :5010）拉取站点预测。
// 失败时返回空对象，并把原因写入 errorOut。
QJsonObject queryStation(int stationId, QString *errorOut = nullptr);

} // namespace MlForecastGateway
