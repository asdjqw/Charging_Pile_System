#include "FramedJson.h"

#include <QJsonDocument>

namespace FramedJson {

QByteArray encode(const QJsonObject &object)
{
    const QByteArray payload = QJsonDocument(object).toJson(QJsonDocument::Compact);
    const quint32 size = static_cast<quint32>(payload.size());
    QByteArray frame;
    frame.reserve(4 + payload.size());
    frame.append(char((size >> 24) & 0xff));
    frame.append(char((size >> 16) & 0xff));
    frame.append(char((size >> 8) & 0xff));
    frame.append(char(size & 0xff));
    frame.append(payload);
    return frame;
}

ReadResult take(QByteArray &buffer, QJsonObject &object, QString &error)
{
    if (buffer.size() < 4)
        return ReadResult::NeedMoreData;

    const auto byte = [&buffer](int index) {
        return static_cast<quint32>(static_cast<unsigned char>(buffer.at(index)));
    };
    const quint32 size = (byte(0) << 24) | (byte(1) << 16) | (byte(2) << 8) | byte(3);
    if (size == 0 || size > MaxPayloadSize) {
        error = QStringLiteral("非法消息长度: %1").arg(size);
        return ReadResult::InvalidFrame;
    }
    if (buffer.size() < 4 + static_cast<int>(size))
        return ReadResult::NeedMoreData;

    QJsonParseError parseError;
    const QJsonDocument document = QJsonDocument::fromJson(buffer.mid(4, size), &parseError);
    buffer.remove(0, 4 + size);
    if (parseError.error != QJsonParseError::NoError || !document.isObject()) {
        error = QStringLiteral("JSON 消息无效: %1").arg(parseError.errorString());
        return ReadResult::InvalidFrame;
    }
    object = document.object();
    return ReadResult::FrameReady;
}

} // namespace FramedJson
