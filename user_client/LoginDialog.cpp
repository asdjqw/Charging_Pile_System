#include "LoginDialog.h"
#include "ServerApiClient.h"
#include "StyleHelper.h"

#include <QLabel>
#include <QLineEdit>
#include <QMessageBox>
#include <QPushButton>
#include <QVBoxLayout>

LoginDialog::LoginDialog(QWidget *parent)
    : QDialog(parent)
{
    setWindowTitle(QStringLiteral("用户登录"));
    setFixedSize(360, 420);
    setStyleSheet(StyleHelper::userClientStyle());

    auto *root = new QVBoxLayout(this);
    root->setContentsMargins(28, 28, 28, 24);
    root->setSpacing(10);

    auto *title = new QLabel(QStringLiteral("充电用户端"), this);
    title->setObjectName(QStringLiteral("pageTitle"));

    auto *subtitle = new QLabel(QStringLiteral("使用手机号登录。尚未注册的号码会自动开户。"), this);
    subtitle->setObjectName(QStringLiteral("muted"));
    subtitle->setWordWrap(true);

    m_phoneEdit = new QLineEdit(this);
    m_phoneEdit->setPlaceholderText(QStringLiteral("11 位手机号"));
    m_phoneEdit->setMaxLength(11);
    m_phoneEdit->setInputMask(QStringLiteral("00000000000"));

    auto *loginBtn = new QPushButton(QStringLiteral("登录"), this);
    auto *hint = new QLabel(QStringLiteral("可用：13800001111"), this);
    hint->setObjectName(QStringLiteral("muted"));

    root->addWidget(title);
    root->addWidget(subtitle);
    root->addSpacing(12);
    root->addWidget(new QLabel(QStringLiteral("手机号"), this));
    root->addWidget(m_phoneEdit);
    root->addSpacing(8);
    root->addWidget(loginBtn);
    root->addWidget(hint);
    root->addStretch();

    connect(loginBtn, &QPushButton::clicked, this, &LoginDialog::onLogin);
    connect(m_phoneEdit, &QLineEdit::returnPressed, this, &LoginDialog::onLogin);
}

void LoginDialog::onLogin()
{
    User user;
    bool created = false;
    if (!ServerApiClient::instance().phoneLogin(m_phoneEdit->text().trimmed(), user, created)) {
        QMessageBox::warning(this, QStringLiteral("登录失败"),
                             ServerApiClient::instance().lastError());
        return;
    }
    m_user = user;
    if (created) {
        QMessageBox::information(this, QStringLiteral("已开户"),
                                 QStringLiteral("已为该手机号创建账号，昵称：%1").arg(user.nickname));
    }
    accept();
}
