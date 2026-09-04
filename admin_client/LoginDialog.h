#pragma once

#include "Models.h"

#include <QDialog>

class QLineEdit;
class QStackedWidget;

class LoginDialog : public QDialog
{
    Q_OBJECT
public:
    explicit LoginDialog(QWidget *parent = nullptr);
    Admin loggedInAdmin() const { return m_admin; }

private slots:
    void onLogin();
    void onRegister();
    void showLoginPage();
    void showRegisterPage();

private:
    QStackedWidget *m_stack = nullptr;
    QLineEdit *m_usernameEdit = nullptr;
    QLineEdit *m_passwordEdit = nullptr;
    QLineEdit *m_regUsernameEdit = nullptr;
    QLineEdit *m_regPasswordEdit = nullptr;
    QLineEdit *m_regNameEdit = nullptr;
    QLineEdit *m_inviteEdit = nullptr;
    Admin m_admin;
};
