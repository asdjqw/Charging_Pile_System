#include "LoginDialog.h"
#include "ServerApiClient.h"
#include "StyleHelper.h"

#include <QLabel>
#include <QLineEdit>
#include <QMessageBox>
#include <QPushButton>
#include <QRegularExpression>
#include <QRegularExpressionValidator>
#include <QVBoxLayout>

LoginDialog::LoginDialog(QWidget *parent)
    : QDialog(parent)
{
    setWindowTitle(QStringLiteral("用户登录"));
    // 与用户端主窗口同一手机竖屏尺度
    setFixedSize(400, 700);
    setStyleSheet(StyleHelper::userClientStyle());

    auto *root = new QVBoxLayout(this);
    root->setContentsMargins(28, 36, 28, 28);
    root->setSpacing(12);

    auto *title = new QLabel(QStringLiteral("充电用户端"), this);
    title->setObjectName(QStringLiteral("pageTitle"));
    title->setStyleSheet(QStringLiteral("font-size:22px; font-weight:700;"));

    auto *subtitle = new QLabel(
        QStringLiteral("使用手机号登录。尚未注册的号码会自动开户。"), this);
    subtitle->setObjectName(QStringLiteral("muted"));
    subtitle->setWordWrap(true);

    auto *phoneLabel = new QLabel(QStringLiteral("手机号"), this);

    m_phoneEdit = new QLineEdit(this);
    m_phoneEdit->setPlaceholderText(QStringLiteral("11 位手机号"));
    m_phoneEdit->setMaxLength(11);
    m_phoneEdit->setMinimumHeight(44);
    m_phoneEdit->setAlignment(Qt::AlignLeft | Qt::AlignVCenter);
    m_phoneEdit->setCursorPosition(0);
    // 勿用 InputMask：空白掩码位会把光标顶到中间，需左拖才能输入
    m_phoneEdit->setValidator(new QRegularExpressionValidator(
        QRegularExpression(QStringLiteral("^\\d{0,11}$")), m_phoneEdit));

    auto *loginBtn = new QPushButton(QStringLiteral("登录"), this);
    loginBtn->setMinimumHeight(46);

    auto *hint = new QLabel(QStringLiteral("可用：13800001111"), this);
    hint->setObjectName(QStringLiteral("muted"));

    root->addWidget(title);
    root->addWidget(subtitle);
    root->addSpacing(28);
    root->addWidget(phoneLabel);
    root->addWidget(m_phoneEdit);
    root->addSpacing(10);
    root->addWidget(loginBtn);
    root->addSpacing(6);
    root->addWidget(hint);
    root->addStretch(); // 下方留白，保持竖屏手机比例观感

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
