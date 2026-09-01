#include "ApiDispatcher.h"
#include "LoginDialog.h"
#include "LocalServer.h"
#include "MainWindow.h"
#include "DatabaseManager.h"
#include "StyleHelper.h"

#include <QApplication>
#include <QCoreApplication>
#include <QDir>
#include <QDebug>
#include <QFileInfo>
#include <QMessageBox>
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
    QApplication app(argc, argv);
    QApplication::setApplicationName(QStringLiteral("ChargePileAdmin"));
    QApplication::setOrganizationName(QStringLiteral("ChargePileLab"));
    app.setStyleSheet(StyleHelper::adminServerStyle());

    if (!DatabaseManager::instance().initialize(qEnvironmentVariable("CHARGE_PILE_DB_PATH"))) {
        QMessageBox::critical(nullptr, QStringLiteral("数据库错误"),
                              DatabaseManager::instance().lastError());
        return 1;
    }

    const bool headless = qEnvironmentVariableIntValue("CHARGE_PILE_HEADLESS") == 1;
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
    QObject::connect(server, &LocalServer::fatalError, &app, [&app, headless](const QString &message) {
        if (headless)
            qCritical().noquote() << message;
        else
            QMessageBox::critical(nullptr, QStringLiteral("服务启动失败"), message);
        app.exit(2);
    });
    QObject::connect(server, &LocalServer::started, &app,
                     [](quint16 startedTcpPort, quint16 startedHttpPort) {
        qInfo().noquote() << QStringLiteral("服务已启动：TCP %1，Web http://127.0.0.1:%2")
                                .arg(startedTcpPort).arg(startedHttpPort);
    });
    networkThread.start();

    const auto runEventLoop = [&]() {
        const int result = app.exec();
        if (networkThread.isRunning())
            QMetaObject::invokeMethod(server, "stop", Qt::BlockingQueuedConnection);
        networkThread.quit();
        networkThread.wait();
        return result;
    };

    if (headless)
        return runEventLoop();

    LoginDialog login;
    if (login.exec() != QDialog::Accepted) {
        QMetaObject::invokeMethod(server, "stop", Qt::BlockingQueuedConnection);
        networkThread.quit();
        networkThread.wait();
        return 0;
    }

    MainWindow w(login.loggedInAdmin());
    w.setWindowTitle(QStringLiteral("充电桩运营管理后台 · TCP %1 · Web %2")
                         .arg(tcpPort).arg(httpPort));
    w.show();
    return runEventLoop();
}
