#include "LoginDialog.h"
#include "DatabaseManager.h"
#include "StyleHelper.h"

#include <QHBoxLayout>
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

    auto *subtitle = new QLabel(QStringLiteral("用户名 + 密码登录"), this);
    subtitle->setObjectName(QStringLiteral("muted"));
    subtitle->setAlignment(Qt::AlignCenter);

    m_usernameEdit = new QLineEdit(this);
    m_usernameEdit->setPlaceholderText(QStringLiteral("用户名，如 zhangsan"));
    m_passwordEdit = new QLineEdit(this);
    m_passwordEdit->setEchoMode(QLineEdit::Password);
    m_passwordEdit->setPlaceholderText(QStringLiteral("密码，默认 123456"));

    auto *loginBtn = new QPushButton(QStringLiteral("登录"), this);
    auto *regBtn = new QPushButton(QStringLiteral("注册新用户"), this);
    regBtn->setObjectName(QStringLiteral("secondaryBtn"));

    auto *btnRow = new QHBoxLayout;
    btnRow->addWidget(regBtn);
    btnRow->addWidget(loginBtn);

    auto *hint = new QLabel(QStringLiteral("演示账号：zhangsan / 123456"), this);
    hint->setObjectName(QStringLiteral("muted"));
    hint->setAlignment(Qt::AlignCenter);

    root->addStretch();
    root->addWidget(badge);
    root->addWidget(title);
    root->addWidget(subtitle);
    root->addSpacing(20);
    root->addWidget(m_usernameEdit);
    root->addWidget(m_passwordEdit);
    root->addLayout(btnRow);
    root->addWidget(hint);
    root->addStretch();

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
    user.phone.clear();
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
