#pragma once

#include "Models.h"

#include <QDialog>

class QLineEdit;

class LoginDialog : public QDialog
{
    Q_OBJECT
public:
    explicit LoginDialog(QWidget *parent = nullptr);
    User loggedInUser() const { return m_user; }

private slots:
    void onLogin();
    void onRegister();

private:
    QLineEdit *m_usernameEdit = nullptr;
    QLineEdit *m_passwordEdit = nullptr;
    User m_user;
};
