#include "LoginDialog.h"
#include "ServerApiClient.h"
#include "StyleHelper.h"

#include <QApplication>
#include <QFrame>
#include <QLabel>
#include <QLineEdit>
#include <QMessageBox>
#include <QPushButton>
#include <QRegularExpression>
#include <QRegularExpressionValidator>
#include <QScrollArea>
#include <QSettings>
#include <QStackedWidget>
#include <QVBoxLayout>

LoginDialog::LoginDialog(QWidget *parent)
    : QDialog(parent)
{
    setWindowTitle(QStringLiteral("用户登录"));
    setFixedSize(520, 920);
    QSettings settings;
    const bool dark = settings.value(QStringLiteral("ui/darkMode"), false).toBool();
    setStyleSheet(dark ? StyleHelper::userClientDarkStyle()
                       : StyleHelper::userClientStyle());

    auto *outer = new QVBoxLayout(this);
    outer->setContentsMargins(0, 0, 0, 0);
    auto *scroll = new QScrollArea(this);
    scroll->setWidgetResizable(true);
    scroll->setFrameShape(QFrame::NoFrame);
    scroll->setHorizontalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
    outer->addWidget(scroll);

    auto *rootWidget = new QWidget(scroll);
    auto *root = new QVBoxLayout(rootWidget);
    root->setContentsMargins(28, 28, 28, 28);
    root->setSpacing(10);

    auto *title = new QLabel(QStringLiteral("充电用户端"), rootWidget);
    title->setObjectName(QStringLiteral("pageTitle"));

    m_stack = new QStackedWidget(rootWidget);

    auto *loginPage = new QWidget(m_stack);
    auto *loginLayout = new QVBoxLayout(loginPage);
    loginLayout->setContentsMargins(0, 0, 0, 0);
    loginLayout->setSpacing(10);
    auto *loginHint = new QLabel(QStringLiteral("使用已注册的手机号和密码登录。没有账号请先注册。"), loginPage);
    loginHint->setObjectName(QStringLiteral("muted"));
    loginHint->setWordWrap(true);
    m_phoneEdit = new QLineEdit(loginPage);
    m_phoneEdit->setPlaceholderText(QStringLiteral("11 位手机号"));
    m_phoneEdit->setMaxLength(11);
    m_phoneEdit->setMinimumHeight(40);
    m_phoneEdit->setValidator(new QRegularExpressionValidator(
        QRegularExpression(QStringLiteral("^\\d{0,11}$")), m_phoneEdit));
    m_passwordEdit = new QLineEdit(loginPage);
    m_passwordEdit->setEchoMode(QLineEdit::Password);
    m_passwordEdit->setPlaceholderText(QStringLiteral("密码"));
    m_passwordEdit->setMinimumHeight(40);
    auto *loginBtn = new QPushButton(QStringLiteral("登录"), loginPage);
    loginBtn->setMinimumHeight(44);
    auto *toRegister = new QPushButton(QStringLiteral("没有账号？去注册"), loginPage);
    toRegister->setObjectName(QStringLiteral("secondaryBtn"));
    auto *demo = new QLabel(QStringLiteral("演示：13800001111 / 123456"), loginPage);
    demo->setObjectName(QStringLiteral("muted"));
    loginLayout->addWidget(loginHint);
    loginLayout->addWidget(new QLabel(QStringLiteral("手机号"), loginPage));
    loginLayout->addWidget(m_phoneEdit);
    loginLayout->addWidget(new QLabel(QStringLiteral("密码"), loginPage));
    loginLayout->addWidget(m_passwordEdit);
    loginLayout->addWidget(loginBtn);
    loginLayout->addWidget(toRegister);
    loginLayout->addWidget(demo);
    loginLayout->addStretch();

    auto *regPage = new QWidget(m_stack);
    auto *regLayout = new QVBoxLayout(regPage);
    regLayout->setContentsMargins(0, 0, 0, 0);
    regLayout->setSpacing(10);
    auto *regHint = new QLabel(QStringLiteral("填写手机号和密码创建账号。"), regPage);
    regHint->setObjectName(QStringLiteral("muted"));
    regHint->setWordWrap(true);
    m_regPhoneEdit = new QLineEdit(regPage);
    m_regPhoneEdit->setPlaceholderText(QStringLiteral("11 位手机号"));
    m_regPhoneEdit->setMaxLength(11);
    m_regPhoneEdit->setMinimumHeight(40);
    m_regPhoneEdit->setValidator(new QRegularExpressionValidator(
        QRegularExpression(QStringLiteral("^\\d{0,11}$")), m_regPhoneEdit));
    m_regNicknameEdit = new QLineEdit(regPage);
    m_regNicknameEdit->setPlaceholderText(QStringLiteral("昵称，可留空"));
    m_regNicknameEdit->setMinimumHeight(40);
    m_regPasswordEdit = new QLineEdit(regPage);
    m_regPasswordEdit->setEchoMode(QLineEdit::Password);
    m_regPasswordEdit->setPlaceholderText(QStringLiteral("至少 6 位"));
    m_regPasswordEdit->setMinimumHeight(40);
    m_regConfirmEdit = new QLineEdit(regPage);
    m_regConfirmEdit->setEchoMode(QLineEdit::Password);
    m_regConfirmEdit->setPlaceholderText(QStringLiteral("再次输入密码"));
    m_regConfirmEdit->setMinimumHeight(40);
    auto *regBtn = new QPushButton(QStringLiteral("注册并登录"), regPage);
    regBtn->setMinimumHeight(44);
    auto *toLogin = new QPushButton(QStringLiteral("已有账号？去登录"), regPage);
    toLogin->setObjectName(QStringLiteral("secondaryBtn"));
    regLayout->addWidget(regHint);
    regLayout->addWidget(new QLabel(QStringLiteral("手机号"), regPage));
    regLayout->addWidget(m_regPhoneEdit);
    regLayout->addWidget(new QLabel(QStringLiteral("昵称"), regPage));
    regLayout->addWidget(m_regNicknameEdit);
    regLayout->addWidget(new QLabel(QStringLiteral("密码"), regPage));
    regLayout->addWidget(m_regPasswordEdit);
    regLayout->addWidget(new QLabel(QStringLiteral("确认密码"), regPage));
    regLayout->addWidget(m_regConfirmEdit);
    regLayout->addWidget(regBtn);
    regLayout->addWidget(toLogin);
    regLayout->addStretch();

    m_stack->addWidget(loginPage);
    m_stack->addWidget(regPage);

    root->addWidget(title);
    root->addSpacing(8);
    root->addWidget(m_stack, 1);
    scroll->setWidget(rootWidget);

    connect(loginBtn, &QPushButton::clicked, this, &LoginDialog::onLogin);
    connect(m_passwordEdit, &QLineEdit::returnPressed, this, &LoginDialog::onLogin);
    connect(m_phoneEdit, &QLineEdit::returnPressed, this, [this]() { m_passwordEdit->setFocus(); });
    connect(toRegister, &QPushButton::clicked, this, &LoginDialog::showRegisterPage);
    connect(regBtn, &QPushButton::clicked, this, &LoginDialog::onRegister);
    connect(m_regConfirmEdit, &QLineEdit::returnPressed, this, &LoginDialog::onRegister);
    connect(toLogin, &QPushButton::clicked, this, &LoginDialog::showLoginPage);
}

void LoginDialog::showLoginPage()
{
    m_stack->setCurrentIndex(0);
    m_phoneEdit->setFocus();
}

void LoginDialog::showRegisterPage()
{
    m_stack->setCurrentIndex(1);
    m_regPhoneEdit->setFocus();
}

void LoginDialog::onLogin()
{
    if (m_phoneEdit->text().trimmed().size() != 11) {
        QMessageBox::warning(this, QStringLiteral("提示"), QStringLiteral("请输入 11 位手机号"));
        return;
    }
    if (m_passwordEdit->text().isEmpty()) {
        QMessageBox::warning(this, QStringLiteral("提示"),
                             QStringLiteral("请输入密码。未注册请先点击下方注册。"));
        return;
    }
    setEnabled(false);
    QApplication::setOverrideCursor(Qt::WaitCursor);
    User user;
    bool created = false;
    const bool ok = ServerApiClient::instance().phoneLogin(m_phoneEdit->text().trimmed(), user,
                                                           created, m_passwordEdit->text());
    QApplication::restoreOverrideCursor();
    setEnabled(true);
    if (!ok) {
        QMessageBox::warning(this, QStringLiteral("登录失败"),
                             ServerApiClient::instance().lastError());
        return;
    }
    m_user = user;
    accept();
}

void LoginDialog::onRegister()
{
    if (m_regPhoneEdit->text().trimmed().size() != 11) {
        QMessageBox::warning(this, QStringLiteral("提示"), QStringLiteral("请输入 11 位手机号"));
        return;
    }
    if (m_regPasswordEdit->text().size() < 6) {
        QMessageBox::warning(this, QStringLiteral("提示"), QStringLiteral("密码至少 6 位"));
        return;
    }
    if (m_regPasswordEdit->text() != m_regConfirmEdit->text()) {
        QMessageBox::warning(this, QStringLiteral("提示"), QStringLiteral("两次输入的密码不一致"));
        return;
    }
    User user;
    user.phone = m_regPhoneEdit->text().trimmed();
    user.password = m_regPasswordEdit->text();
    user.nickname = m_regNicknameEdit->text().trimmed();
    setEnabled(false);
    QApplication::setOverrideCursor(Qt::WaitCursor);
    const bool registered = ServerApiClient::instance().registerUser(user);
    bool created = false;
    const bool loggedIn = registered
        && ServerApiClient::instance().phoneLogin(user.phone, m_user, created, user.password);
    QApplication::restoreOverrideCursor();
    setEnabled(true);
    if (!registered) {
        QMessageBox::warning(this, QStringLiteral("注册失败"),
                             ServerApiClient::instance().lastError());
        return;
    }
    if (!loggedIn) {
        QMessageBox::warning(this, QStringLiteral("登录失败"),
                             ServerApiClient::instance().lastError());
        return;
    }
    accept();
}
