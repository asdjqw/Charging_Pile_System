#pragma once

#include "Models.h"

#include <QDialog>

class QLabel;
class QLineEdit;
class QPushButton;
class QStackedWidget;

class LoginDialog : public QDialog
{
    Q_OBJECT
public:
    explicit LoginDialog(QWidget *parent = nullptr);
    User loggedInUser() const { return m_user; }

private slots:
    void onLogin();
    void onRegister();
    void showLoginPage();
    void showRegisterPage();

private:
    QStackedWidget *m_stack = nullptr;
    QLineEdit *m_phoneEdit = nullptr;
    QLineEdit *m_passwordEdit = nullptr;
    QLineEdit *m_regPhoneEdit = nullptr;
    QLineEdit *m_regNicknameEdit = nullptr;
    QLineEdit *m_regPasswordEdit = nullptr;
    QLineEdit *m_regConfirmEdit = nullptr;
    User m_user;
};
