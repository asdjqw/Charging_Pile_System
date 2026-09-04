#include "LoginDialog.h"
#include "MainWindow.h"
#include "ServerApiClient.h"
#include "StyleHelper.h"

#include <QApplication>
#include <QMessageBox>

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    QApplication::setApplicationName(QStringLiteral("ChargePileUser"));
    QApplication::setOrganizationName(QStringLiteral("ChargePileLab"));
    app.setStyleSheet(StyleHelper::userClientStyle());
    app.setQuitOnLastWindowClosed(false);

    const QString host = qEnvironmentVariable("CHARGE_PILE_HOST", "127.0.0.1");
    bool portOk = false;
    const int configuredPort = qEnvironmentVariableIntValue("CHARGE_PILE_PORT", &portOk);
    const quint16 port = portOk && configuredPort > 0 && configuredPort <= 65535
                             ? static_cast<quint16>(configuredPort)
                             : 9000;
    if (!ServerApiClient::instance().initialize(host, port)
        || !ServerApiClient::instance().ping()) {
        QMessageBox::critical(nullptr, QStringLiteral("服务端不可用"),
                              ServerApiClient::instance().lastError()
                                  + QStringLiteral("\n请先启动 admin_server。"));
        return 1;
    }

    while (true) {
        LoginDialog login;
        if (login.exec() != QDialog::Accepted)
            return 0;

        MainWindow w(login.loggedInUser());
        bool logout = false;
        QObject::connect(&w, &MainWindow::logoutRequested, &w, [&]() {
            logout = true;
            QApplication::exit(1);
        });
        w.show();
        const int code = app.exec();
        ServerApiClient::instance().logout();
        if (!logout)
            return code;
    }
}
