#pragma once

#include "Models.h"

#include <QDialog>

class QLineEdit;

class LoginDialog : public QDialog
{
    Q_OBJECT
public:
    explicit LoginDialog(QWidget *parent = nullptr);
    Admin loggedInAdmin() const { return m_admin; }

private slots:
    void onLogin();

private:
    QLineEdit *m_usernameEdit = nullptr;
    QLineEdit *m_passwordEdit = nullptr;
    Admin m_admin;
};
