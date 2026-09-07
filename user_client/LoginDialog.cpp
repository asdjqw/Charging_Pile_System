#include "LoginDialog.h"
#include "ServerApiClient.h"
#include "StyleHelper.h"
#include "ui_LoginDialog.h"

#include <QApplication>
#include <QLineEdit>
#include <QMessageBox>
#include <QPushButton>
#include <QRegularExpression>
#include <QRegularExpressionValidator>
#include <QSettings>
#include <QStackedWidget>

LoginDialog::LoginDialog(QWidget *parent)
    : QDialog(parent)
    , ui(new Ui::LoginDialog)
{
    ui->setupUi(this);
    setFixedSize(520, 920);

    ui->hero->setObjectName(QStringLiteral("loginHero"));
    ui->hero->setAttribute(Qt::WA_StyledBackground, true);
    ui->titleLabel->setObjectName(QStringLiteral("heroTitle"));
    ui->heroSub->setObjectName(QStringLiteral("heroSub"));
    ui->loginCard->setObjectName(QStringLiteral("loginCard"));
    ui->formWrap->setObjectName(QStringLiteral("centralRoot"));
    ui->formWrap->setAttribute(Qt::WA_StyledBackground, true);
    ui->loginWelcome->setObjectName(QStringLiteral("pageTitle"));
    ui->regWelcome->setObjectName(QStringLiteral("pageTitle"));
    ui->loginHint->setObjectName(QStringLiteral("muted"));
    ui->toRegisterBtn->setObjectName(QStringLiteral("secondaryBtn"));
    ui->demoHint->setObjectName(QStringLiteral("muted"));
    ui->regHint->setObjectName(QStringLiteral("muted"));
    ui->toLoginBtn->setObjectName(QStringLiteral("secondaryBtn"));
    ui->footerHint->setObjectName(QStringLiteral("muted"));
    ui->loginBtn->setDefault(true);

    QSettings settings;
    const bool dark = settings.value(QStringLiteral("ui/darkMode"), false).toBool();
    setStyleSheet(dark ? StyleHelper::userClientDarkStyle()
                       : StyleHelper::userClientStyle());

    m_stack = ui->stack;
    m_phoneEdit = ui->phoneEdit;
    m_passwordEdit = ui->passwordEdit;
    m_regPhoneEdit = ui->regPhoneEdit;
    m_regNicknameEdit = ui->regNicknameEdit;
    m_regPasswordEdit = ui->regPasswordEdit;
    m_regConfirmEdit = ui->regConfirmEdit;

    m_phoneEdit->setValidator(new QRegularExpressionValidator(
        QRegularExpression(QStringLiteral("^\\d{0,11}$")), m_phoneEdit));
    m_regPhoneEdit->setValidator(new QRegularExpressionValidator(
        QRegularExpression(QStringLiteral("^\\d{0,11}$")), m_regPhoneEdit));

    connect(ui->loginBtn, &QPushButton::clicked, this, &LoginDialog::onLogin);
    connect(m_passwordEdit, &QLineEdit::returnPressed, this, &LoginDialog::onLogin);
    connect(m_phoneEdit, &QLineEdit::returnPressed, this, [this]() { m_passwordEdit->setFocus(); });
    connect(ui->toRegisterBtn, &QPushButton::clicked, this, &LoginDialog::showRegisterPage);
    connect(ui->regBtn, &QPushButton::clicked, this, &LoginDialog::onRegister);
    connect(m_regConfirmEdit, &QLineEdit::returnPressed, this, &LoginDialog::onRegister);
    connect(ui->toLoginBtn, &QPushButton::clicked, this, &LoginDialog::showLoginPage);
}

LoginDialog::~LoginDialog()
{
    delete ui;
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
