#include "LoginDialog.h"
#include "AdminApiClient.h"
#include "StyleHelper.h"

#include <QFormLayout>
#include <QLabel>
#include <QLineEdit>
#include <QMessageBox>
#include <QPushButton>
#include <QSettings>
#include <QStackedWidget>
#include <QVBoxLayout>

LoginDialog::LoginDialog(QWidget *parent)
    : QDialog(parent)
{
    setWindowTitle(QStringLiteral("管理员登录"));
    setFixedSize(400, 420);
    QSettings settings;
    const bool dark = settings.value(QStringLiteral("ui/darkMode"), false).toBool();
    setStyleSheet(dark ? StyleHelper::adminClientDarkStyle()
                       : StyleHelper::adminClientStyle());

    auto *root = new QVBoxLayout(this);
    root->setContentsMargins(24, 20, 24, 20);
    root->setSpacing(10);

    auto *title = new QLabel(QStringLiteral("充电桩管理端"), this);
    title->setObjectName(QStringLiteral("pageTitle"));
    m_stack = new QStackedWidget(this);

    auto *loginPage = new QWidget(m_stack);
    auto *loginLayout = new QVBoxLayout(loginPage);
    loginLayout->setContentsMargins(0, 0, 0, 0);
    loginLayout->setSpacing(10);
    m_usernameEdit = new QLineEdit(loginPage);
    m_usernameEdit->setPlaceholderText(QStringLiteral("账号"));
    m_usernameEdit->setText(QStringLiteral("admin"));
    m_passwordEdit = new QLineEdit(loginPage);
    m_passwordEdit->setEchoMode(QLineEdit::Password);
    m_passwordEdit->setPlaceholderText(QStringLiteral("密码"));
    auto *loginForm = new QFormLayout;
    loginForm->addRow(QStringLiteral("账号"), m_usernameEdit);
    loginForm->addRow(QStringLiteral("密码"), m_passwordEdit);
    auto *loginBtn = new QPushButton(QStringLiteral("登录"), loginPage);
    auto *toRegister = new QPushButton(QStringLiteral("没有账号？邀请码注册"), loginPage);
    toRegister->setObjectName(QStringLiteral("secondaryBtn"));
    auto *hint = new QLabel(QStringLiteral("演示：admin / 123456"), loginPage);
    hint->setObjectName(QStringLiteral("muted"));
    loginLayout->addLayout(loginForm);
    loginLayout->addWidget(loginBtn);
    loginLayout->addWidget(toRegister);
    loginLayout->addWidget(hint);
    loginLayout->addStretch();

    auto *regPage = new QWidget(m_stack);
    auto *regLayout = new QVBoxLayout(regPage);
    regLayout->setContentsMargins(0, 0, 0, 0);
    m_regUsernameEdit = new QLineEdit(regPage);
    m_regUsernameEdit->setPlaceholderText(QStringLiteral("管理员账号"));
    m_regPasswordEdit = new QLineEdit(regPage);
    m_regPasswordEdit->setEchoMode(QLineEdit::Password);
    m_regPasswordEdit->setPlaceholderText(QStringLiteral("至少 6 位"));
    m_regNameEdit = new QLineEdit(regPage);
    m_regNameEdit->setPlaceholderText(QStringLiteral("真实姓名"));
    m_inviteEdit = new QLineEdit(regPage);
    m_inviteEdit->setPlaceholderText(QStringLiteral("邀请码，如 CHARGE-ADMIN-2026"));
    auto *regForm = new QFormLayout;
    regForm->addRow(QStringLiteral("账号"), m_regUsernameEdit);
    regForm->addRow(QStringLiteral("密码"), m_regPasswordEdit);
    regForm->addRow(QStringLiteral("姓名"), m_regNameEdit);
    regForm->addRow(QStringLiteral("邀请码"), m_inviteEdit);
    auto *regBtn = new QPushButton(QStringLiteral("注册并登录"), regPage);
    auto *toLogin = new QPushButton(QStringLiteral("已有账号？去登录"), regPage);
    toLogin->setObjectName(QStringLiteral("secondaryBtn"));
    auto *regHint = new QLabel(QStringLiteral("需使用系统管理员发放的邀请码。账号重复会提示“账户已存在”。"),
                               regPage);
    regHint->setObjectName(QStringLiteral("muted"));
    regHint->setWordWrap(true);
    regLayout->addWidget(regHint);
    regLayout->addLayout(regForm);
    regLayout->addWidget(regBtn);
    regLayout->addWidget(toLogin);
    regLayout->addStretch();

    m_stack->addWidget(loginPage);
    m_stack->addWidget(regPage);
    root->addWidget(title);
    root->addWidget(m_stack, 1);

    connect(loginBtn, &QPushButton::clicked, this, &LoginDialog::onLogin);
    connect(m_passwordEdit, &QLineEdit::returnPressed, this, &LoginDialog::onLogin);
    connect(toRegister, &QPushButton::clicked, this, &LoginDialog::showRegisterPage);
    connect(regBtn, &QPushButton::clicked, this, &LoginDialog::onRegister);
    connect(toLogin, &QPushButton::clicked, this, &LoginDialog::showLoginPage);
    m_passwordEdit->setFocus();
}

void LoginDialog::showLoginPage()
{
    m_stack->setCurrentIndex(0);
    m_usernameEdit->setFocus();
}

void LoginDialog::showRegisterPage()
{
    m_stack->setCurrentIndex(1);
    m_regUsernameEdit->setFocus();
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

void LoginDialog::onRegister()
{
    Admin admin;
    if (!AdminApiClient::instance().registerAdmin(m_regUsernameEdit->text().trimmed(),
                                                  m_regPasswordEdit->text(),
                                                  m_regNameEdit->text().trimmed(),
                                                  m_inviteEdit->text().trimmed(),
                                                  admin)) {
        QMessageBox::warning(this, QStringLiteral("注册失败"),
                             AdminApiClient::instance().lastError());
        return;
    }
    m_admin = admin;
    accept();
}
