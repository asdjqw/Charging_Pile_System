#include "LoginDialog.h"
#include "AdminApiClient.h"
#include "StyleHelper.h"
#include "ui_LoginDialog.h"

#include <QLineEdit>
#include <QKeyEvent>
#include <QMessageBox>
#include <QPushButton>
#include <QSettings>
#include <QStackedWidget>

LoginDialog::LoginDialog(QWidget *parent)
    : QDialog(parent)
    , ui(new Ui::LoginDialog)
{
    ui->setupUi(this);
    // 登录页可按窗口大小自适应，也支持窗口管理器最大化与 F11 全屏切换。
    setMinimumSize(400, 420);
    setMaximumSize(QWIDGETSIZE_MAX, QWIDGETSIZE_MAX);
    resize(400, 420);
    setWindowFlag(Qt::WindowMaximizeButtonHint, true);
    QSettings settings;
    const bool dark = settings.value(QStringLiteral("ui/darkMode"), false).toBool();
    setStyleSheet(dark ? StyleHelper::adminClientDarkStyle()
                       : StyleHelper::adminClientStyle());

    ui->titleLabel->setObjectName(QStringLiteral("pageTitle"));
    ui->toRegisterBtn->setObjectName(QStringLiteral("secondaryBtn"));
    ui->loginHint->setObjectName(QStringLiteral("muted"));
    ui->toLoginBtn->setObjectName(QStringLiteral("secondaryBtn"));
    ui->regHint->setObjectName(QStringLiteral("muted"));

    m_stack = ui->stack;
    m_usernameEdit = ui->usernameEdit;
    m_passwordEdit = ui->passwordEdit;
    m_regUsernameEdit = ui->regUsernameEdit;
    m_regPasswordEdit = ui->regPasswordEdit;
    m_regNameEdit = ui->regNameEdit;
    m_inviteEdit = ui->inviteEdit;

    connect(ui->loginBtn, &QPushButton::clicked, this, &LoginDialog::onLogin);
    connect(m_passwordEdit, &QLineEdit::returnPressed, this, &LoginDialog::onLogin);
    connect(ui->toRegisterBtn, &QPushButton::clicked, this, &LoginDialog::showRegisterPage);
    connect(ui->regBtn, &QPushButton::clicked, this, &LoginDialog::onRegister);
    connect(ui->toLoginBtn, &QPushButton::clicked, this, &LoginDialog::showLoginPage);
    m_passwordEdit->setFocus();
}

LoginDialog::~LoginDialog()
{
    delete ui;
}

void LoginDialog::keyPressEvent(QKeyEvent *event)
{
    if (event->key() == Qt::Key_F11) {
        if (isFullScreen())
            showNormal();
        else
            showFullScreen();
        event->accept();
        return;
    }
    QDialog::keyPressEvent(event);
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
    const QString username = m_regUsernameEdit->text().trimmed();
    const QString password = m_regPasswordEdit->text();
    if (password.size() < 6) {
        QMessageBox::warning(this, QStringLiteral("提示"), QStringLiteral("密码至少 6 位"));
        return;
    }

    if (!AdminApiClient::instance().registerAdmin(username, password,
                                                 m_regNameEdit->text().trimmed(),
                                                 m_inviteEdit->text().trimmed())) {
        QMessageBox::warning(this, QStringLiteral("注册失败"),
                             AdminApiClient::instance().lastError());
        return;
    }

    Admin admin;
    if (!AdminApiClient::instance().loginAdmin(username, password, admin)) {
        QMessageBox::warning(this, QStringLiteral("登录失败"),
                             AdminApiClient::instance().lastError());
        return;
    }
    m_admin = admin;
    accept();
}
