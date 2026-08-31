#include "LoginDialog.h"
#include "DatabaseManager.h"

#include <QFormLayout>
#include <QHBoxLayout>
#include <QLabel>
#include <QLineEdit>
#include <QMessageBox>
#include <QPushButton>
#include <QVBoxLayout>

LoginDialog::LoginDialog(QWidget *parent)
    : QDialog(parent)
{
    setWindowTitle(QStringLiteral("充电用户端 - 登录"));
    setFixedSize(420, 360);

    auto *root = new QVBoxLayout(this);
    root->setContentsMargins(28, 28, 28, 28);
    root->setSpacing(14);

    auto *title = new QLabel(QStringLiteral("⚡ 智能充电用户端"), this);
    title->setObjectName(QStringLiteral("titleLabel"));
    auto *sub = new QLabel(QStringLiteral("Linux + Qt6 · 模拟手机交互体验"), this);
    sub->setObjectName(QStringLiteral("subtitleLabel"));

    m_usernameEdit = new QLineEdit(this);
    m_usernameEdit->setPlaceholderText(QStringLiteral("用户名，如 zhangsan"));
    m_passwordEdit = new QLineEdit(this);
    m_passwordEdit->setEchoMode(QLineEdit::Password);
    m_passwordEdit->setPlaceholderText(QStringLiteral("密码，默认 123456"));

    auto *form = new QFormLayout;
    form->addRow(QStringLiteral("用户名"), m_usernameEdit);
    form->addRow(QStringLiteral("密码"), m_passwordEdit);

    auto *tip = new QLabel(QStringLiteral("演示账号：zhangsan / 123456"), this);
    tip->setObjectName(QStringLiteral("subtitleLabel"));

    auto *loginBtn = new QPushButton(QStringLiteral("登录"), this);
    auto *regBtn = new QPushButton(QStringLiteral("注册新用户"), this);
    regBtn->setObjectName(QStringLiteral("secondaryBtn"));

    auto *btnRow = new QHBoxLayout;
    btnRow->addWidget(regBtn);
    btnRow->addWidget(loginBtn);

    root->addWidget(title);
    root->addWidget(sub);
    root->addSpacing(8);
    root->addLayout(form);
    root->addWidget(tip);
    root->addStretch();
    root->addLayout(btnRow);

    connect(loginBtn, &QPushButton::clicked, this, &LoginDialog::onLogin);
    connect(regBtn, &QPushButton::clicked, this, &LoginDialog::onRegister);
    connect(m_passwordEdit, &QLineEdit::returnPressed, this, &LoginDialog::onLogin);
}

void LoginDialog::onLogin()
{
    User user;
    if (!DatabaseManager::instance().loginUser(m_usernameEdit->text().trimmed(),
                                               m_passwordEdit->text(), user)) {
        QMessageBox::warning(this, QStringLiteral("登录失败"),
                             DatabaseManager::instance().lastError());
        return;
    }
    m_user = user;
    accept();
}

void LoginDialog::onRegister()
{
    User user;
    user.username = m_usernameEdit->text().trimmed();
    user.password = m_passwordEdit->text();
    user.phone = QStringLiteral("13800000000");
    user.balance = 50.0;
    user.carModel = QStringLiteral("未填写");
    user.plateNumber = QStringLiteral("未填写");

    if (user.username.isEmpty() || user.password.isEmpty()) {
        QMessageBox::warning(this, QStringLiteral("提示"), QStringLiteral("请先填写用户名和密码"));
        return;
    }
    if (!DatabaseManager::instance().registerUser(user)) {
        QMessageBox::warning(this, QStringLiteral("注册失败"),
                             DatabaseManager::instance().lastError());
        return;
    }
    QMessageBox::information(this, QStringLiteral("注册成功"),
                             QStringLiteral("已注册并赠送余额 ¥50，请直接登录。"));
}
