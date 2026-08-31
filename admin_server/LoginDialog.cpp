#include "LoginDialog.h"
#include "DatabaseManager.h"

#include <QFormLayout>
#include <QLabel>
#include <QLineEdit>
#include <QMessageBox>
#include <QPushButton>
#include <QVBoxLayout>

LoginDialog::LoginDialog(QWidget *parent)
    : QDialog(parent)
{
    setWindowTitle(QStringLiteral("PC 服务器端 - 管理员登录"));
    setFixedSize(460, 320);

    auto *root = new QVBoxLayout(this);
    root->setContentsMargins(32, 32, 32, 32);
    root->setSpacing(16);

    auto *title = new QLabel(QStringLiteral("充电桩运营管理后台"), this);
    title->setObjectName(QStringLiteral("titleLabel"));
    auto *sub = new QLabel(QStringLiteral("Linux + Qt6 · 宽屏 PC 风格运维控制台"), this);
    sub->setObjectName(QStringLiteral("kpiTitle"));

    m_usernameEdit = new QLineEdit(this);
    m_usernameEdit->setPlaceholderText(QStringLiteral("管理员账号，默认 admin"));
    m_passwordEdit = new QLineEdit(this);
    m_passwordEdit->setEchoMode(QLineEdit::Password);
    m_passwordEdit->setPlaceholderText(QStringLiteral("密码，默认 admin123"));

    auto *form = new QFormLayout;
    form->addRow(QStringLiteral("账号"), m_usernameEdit);
    form->addRow(QStringLiteral("密码"), m_passwordEdit);

    auto *loginBtn = new QPushButton(QStringLiteral("登录系统"), this);
    auto *tip = new QLabel(QStringLiteral("演示账号：admin / admin123"), this);
    tip->setObjectName(QStringLiteral("kpiTitle"));

    root->addWidget(title);
    root->addWidget(sub);
    root->addLayout(form);
    root->addWidget(tip);
    root->addStretch();
    root->addWidget(loginBtn);

    connect(loginBtn, &QPushButton::clicked, this, &LoginDialog::onLogin);
    connect(m_passwordEdit, &QLineEdit::returnPressed, this, &LoginDialog::onLogin);
}

void LoginDialog::onLogin()
{
    Admin admin;
    if (!DatabaseManager::instance().loginAdmin(m_usernameEdit->text().trimmed(),
                                                m_passwordEdit->text(), admin)) {
        QMessageBox::warning(this, QStringLiteral("登录失败"),
                             DatabaseManager::instance().lastError());
        return;
    }
    m_admin = admin;
    accept();
}
