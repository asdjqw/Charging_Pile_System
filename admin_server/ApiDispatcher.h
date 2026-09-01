#pragma once

#include <QDateTime>
#include <QHash>
#include <QJsonObject>
#include <QObject>

class ApiDispatcher : public QObject
{
    Q_OBJECT
public:
    explicit ApiDispatcher(QObject *parent = nullptr);

public slots:
    QJsonObject dispatch(const QJsonObject &request);

private:
    struct Session {
        int userId = 0;
        QDateTime expiresAt;
    };

    QJsonObject success(const QJsonObject &request, const QJsonValue &data = QJsonObject(),
                        const QString &message = QString()) const;
    QJsonObject failure(const QJsonObject &request, const QString &code,
                        const QString &message) const;
    int authorizedUser(const QJsonObject &request);

    QHash<QString, Session> m_sessions;
};
