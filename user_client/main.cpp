#include "LoginDialog.h"
#include "MainWindow.h"
#include "DatabaseManager.h"
#include "StyleHelper.h"

#include <QApplication>
#include <QMessageBox>

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    QApplication::setApplicationName(QStringLiteral("ChargePileUser"));
    QApplication::setOrganizationName(QStringLiteral("ChargePileLab"));
    app.setStyleSheet(StyleHelper::userClientStyle());

    if (!DatabaseManager::instance().initialize()) {
        QMessageBox::critical(nullptr, QStringLiteral("数据库错误"),
                              DatabaseManager::instance().lastError());
        return 1;
    }

    LoginDialog login;
    if (login.exec() != QDialog::Accepted)
        return 0;

    MainWindow w(login.loggedInUser());
    w.show();
    return app.exec();
}
