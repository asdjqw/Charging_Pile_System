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

private:
    QLineEdit *m_phoneEdit = nullptr;
    User m_user;
};
