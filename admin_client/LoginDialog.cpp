#include "LoginDialog.h"
#include "AdminApiClient.h"
#include "StyleHelper.h"

#include <QFormLayout>
#include <QLabel>
#include <QLineEdit>
#include <QMessageBox>
#include <QPushButton>
#include <QVBoxLayout>

LoginDialog::LoginDialog(QWidget *parent)
    : QDialog(parent)
{
    setWindowTitle(QStringLiteral("管理员登录"));
    setFixedSize(380, 280);
    setStyleSheet(StyleHelper::adminClientStyle());

    auto *root = new QVBoxLayout(this);
    root->setContentsMargins(24, 20, 24, 20);
    root->setSpacing(10);

    auto *title = new QLabel(QStringLiteral("充电桩管理端"), this);
    title->setObjectName(QStringLiteral("pageTitle"));

    m_usernameEdit = new QLineEdit(this);
    m_usernameEdit->setPlaceholderText(QStringLiteral("账号"));
    m_usernameEdit->setText(QStringLiteral("admin"));

    m_passwordEdit = new QLineEdit(this);
    m_passwordEdit->setEchoMode(QLineEdit::Password);
    m_passwordEdit->setPlaceholderText(QStringLiteral("密码"));

    auto *form = new QFormLayout;
    form->setHorizontalSpacing(12);
    form->setVerticalSpacing(8);
    form->setContentsMargins(0, 8, 0, 8);
    form->addRow(QStringLiteral("账号"), m_usernameEdit);
    form->addRow(QStringLiteral("密码"), m_passwordEdit);

    auto *loginBtn = new QPushButton(QStringLiteral("登录"), this);
    auto *hint = new QLabel(QStringLiteral("演示：admin / 123456"), this);
    hint->setObjectName(QStringLiteral("muted"));

    root->addWidget(title);
    root->addLayout(form);
    root->addWidget(loginBtn);
    root->addWidget(hint);
    root->addStretch();

    connect(loginBtn, &QPushButton::clicked, this, &LoginDialog::onLogin);
    connect(m_usernameEdit, &QLineEdit::returnPressed, this, [this]() {
        m_passwordEdit->setFocus();
    });
    connect(m_passwordEdit, &QLineEdit::returnPressed, this, &LoginDialog::onLogin);
    m_passwordEdit->setFocus();
}

void LoginDialog::onLogin()
{
    const QString username = m_usernameEdit->text().trimmed();
    const QString password = m_passwordEdit->text();
    if (username.isEmpty() || password.isEmpty()) {
        QMessageBox::warning(this, QStringLiteral("提示"),
                             QStringLiteral("请输入账号和密码"));
        return;
    }

    Admin admin;
    if (!AdminApiClient::instance().loginAdmin(username, password, admin)) {
        QMessageBox::warning(this, QStringLiteral("登录失败"),
                             AdminApiClient::instance().lastError());
        m_passwordEdit->clear();
        m_passwordEdit->setFocus();
        return;
    }
    m_admin = admin;
    accept();
}
