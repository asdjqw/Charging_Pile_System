#include "FramedJson.h"

#include <QCoreApplication>
#include <QJsonObject>

int main(int argc, char **argv)
{
    QCoreApplication app(argc, argv);
    const QJsonObject first{{"requestId", "one"}, {"value", 42}};
    const QJsonObject second{{"requestId", "two"}, {"text", QStringLiteral("中文消息")}};
    QByteArray buffer = FramedJson::encode(first) + FramedJson::encode(second);

    QJsonObject decoded;
    QString error;
    if (FramedJson::take(buffer, decoded, error) != FramedJson::ReadResult::FrameReady
        || decoded != first)
        return 1;
    if (FramedJson::take(buffer, decoded, error) != FramedJson::ReadResult::FrameReady
        || decoded != second || !buffer.isEmpty())
        return 2;

    QByteArray partial = FramedJson::encode(first).left(5);
    if (FramedJson::take(partial, decoded, error) != FramedJson::ReadResult::NeedMoreData)
        return 3;

    QByteArray invalid(4, '\0');
    if (FramedJson::take(invalid, decoded, error) != FramedJson::ReadResult::InvalidFrame)
        return 4;
    return 0;
}
