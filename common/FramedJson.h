#pragma once

#include <QByteArray>
#include <QJsonObject>
#include <QString>

namespace FramedJson {

constexpr quint32 MaxPayloadSize = 4 * 1024 * 1024;

enum class ReadResult {
    NeedMoreData,
    FrameReady,
    InvalidFrame
};

QByteArray encode(const QJsonObject &object);
ReadResult take(QByteArray &buffer, QJsonObject &object, QString &error);

} // namespace FramedJson
