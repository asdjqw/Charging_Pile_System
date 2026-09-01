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
    setWindowTitle(QStringLiteral("电动汽车充电 - 登录"));
    setFixedSize(420, 780); // 手机竖屏比例
    setStyleSheet(StyleHelper::userClientStyle());

    auto *root = new QVBoxLayout(this);
    root->setContentsMargins(32, 72, 32, 32);
    root->setSpacing(18);

    auto *badge = new QLabel(QStringLiteral("EV Charge"), this);
    badge->setAlignment(Qt::AlignCenter);
    badge->setStyleSheet(QStringLiteral(
        "font-size:28px; font-weight:800; color:white;"
        "background:qlineargradient(x1:0,y1:0,x2:1,y2:1,stop:0 #38BDF8, stop:1 #0284C7);"
        "border-radius:18px; padding:28px;"));

    auto *title = new QLabel(QStringLiteral("电动汽车充电"), this);
    title->setObjectName(QStringLiteral("pageTitle"));
    title->setAlignment(Qt::AlignCenter);

    auto *subtitle = new QLabel(QStringLiteral("手机号免密登录，首次使用自动注册"), this);
    subtitle->setObjectName(QStringLiteral("muted"));
    subtitle->setAlignment(Qt::AlignCenter);

    m_phoneEdit = new QLineEdit(this);
    m_phoneEdit->setPlaceholderText(QStringLiteral("请输入 11 位手机号"));
    m_phoneEdit->setMaxLength(11);
    m_phoneEdit->setInputMask(QStringLiteral("00000000000"));

    auto *loginBtn = new QPushButton(QStringLiteral("手机号登录"), this);

    auto *hint = new QLabel(QStringLiteral("演示手机号：13800001111"), this);
    hint->setObjectName(QStringLiteral("muted"));
    hint->setAlignment(Qt::AlignCenter);

    root->addStretch();
    root->addWidget(badge);
    root->addWidget(title);
    root->addWidget(subtitle);
    root->addSpacing(20);
    root->addWidget(m_phoneEdit);
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
        QMessageBox::information(this, QStringLiteral("欢迎使用"),
                                 QStringLiteral("已自动创建账号，默认昵称：%1").arg(user.nickname));
    }
    accept();
}
