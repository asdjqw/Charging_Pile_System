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
    struct AdminSession {
        int adminId = 0;
        QDateTime expiresAt;
    };

    QJsonObject success(const QJsonObject &request, const QJsonValue &data = QJsonObject(),
                        const QString &message = QString()) const;
    QJsonObject failure(const QJsonObject &request, const QString &code,
                        const QString &message) const;
    int authorizedUser(const QJsonObject &request);
    int authorizedAdmin(const QJsonObject &request);
    bool adminHasPermission(int adminId, const QString &permission) const;
    QJsonObject dashboardPayload(int days) const;
    QJsonObject dispatchAdmin(const QJsonObject &request, int adminId);
    QJsonObject denyIfNoPermission(const QJsonObject &request, int adminId,
                                   const QString &permission) const;

    QHash<QString, Session> m_sessions;
    QHash<QString, AdminSession> m_adminSessions;
};
