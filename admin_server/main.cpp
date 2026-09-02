#include "ApiDispatcher.h"
#include "LocalServer.h"
#include "DatabaseManager.h"

#include <QCoreApplication>
#include <QDir>
#include <QFileInfo>
#include <QDebug>
#include <QJsonObject>
#include <QMetaType>
#include <QThread>

namespace {

quint16 configuredPort(const char *name, quint16 fallback)
{
    bool ok = false;
    const int value = qEnvironmentVariableIntValue(name, &ok);
    return ok && value > 0 && value <= 65535 ? static_cast<quint16>(value) : fallback;
}

QString resolveWebRoot()
{
    const QString configured = qEnvironmentVariable("CHARGE_PILE_WEB_ROOT");
    const QStringList candidates = {
        configured,
        QCoreApplication::applicationDirPath() + QStringLiteral("/web"),
        QDir(QCoreApplication::applicationDirPath() + QStringLiteral("/../web")).absolutePath(),
        QDir::currentPath() + QStringLiteral("/web")
    };
    for (const QString &path : candidates) {
        if (!path.isEmpty() && QFileInfo::exists(path + QStringLiteral("/index.html")))
            return path;
    }
    return QCoreApplication::applicationDirPath() + QStringLiteral("/web");
}

} // namespace

int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);
    QCoreApplication::setApplicationName(QStringLiteral("ChargePileServer"));
    QCoreApplication::setOrganizationName(QStringLiteral("ChargePileLab"));
    qRegisterMetaType<QJsonObject>("QJsonObject");

    if (!DatabaseManager::instance().initialize(qEnvironmentVariable("CHARGE_PILE_DB_PATH"))) {
        qCritical().noquote() << QStringLiteral("数据库错误：")
                              << DatabaseManager::instance().lastError();
        return 1;
    }

    const quint16 tcpPort = configuredPort("CHARGE_PILE_PORT", 9000);
    const quint16 httpPort = configuredPort("CHARGE_PILE_HTTP_PORT", 8080);
    ApiDispatcher dispatcher;
    QThread networkThread;
    auto *server = new LocalServer(qEnvironmentVariable("CHARGE_PILE_BIND_ADDRESS", "127.0.0.1"),
                                   tcpPort, httpPort, resolveWebRoot());
    server->moveToThread(&networkThread);
    QObject::connect(&networkThread, &QThread::started, server, &LocalServer::start);
    QObject::connect(&networkThread, &QThread::finished, server, &QObject::deleteLater);
    QObject::connect(server, &LocalServer::requestReceived, &dispatcher,
                     [&dispatcher, server](const QString &channelId, const QJsonObject &request) {
        const QJsonObject response = dispatcher.dispatch(request);
        QMetaObject::invokeMethod(server, "sendResponse", Qt::QueuedConnection,
                                  Q_ARG(QString, channelId), Q_ARG(QJsonObject, response));
    });
    QObject::connect(server, &LocalServer::fatalError, &app, [&app](const QString &message) {
        qCritical().noquote() << message;
        app.exit(2);
    });
    QObject::connect(server, &LocalServer::started, &app,
                     [](quint16 startedTcpPort, quint16 startedHttpPort) {
        qInfo().noquote() << QStringLiteral("后端服务已启动：TCP %1，Web http://127.0.0.1:%2")
                                .arg(startedTcpPort).arg(startedHttpPort);
        qInfo().noquote() << QStringLiteral("请分别启动 user_client 与 admin_client 接入本服务。");
    });
    QObject::connect(&app, &QCoreApplication::aboutToQuit, [&]() {
        if (networkThread.isRunning())
            QMetaObject::invokeMethod(server, "stop", Qt::BlockingQueuedConnection);
        networkThread.quit();
        networkThread.wait();
    });

    networkThread.start();
    return app.exec();
}
