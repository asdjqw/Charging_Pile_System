#pragma once

#include <QApplication>
#include <QColor>
#include <QDialog>
#include <QEvent>
#include <QHBoxLayout>
#include <QLabel>
#include <QMessageBox>
#include <QPushButton>
#include <QString>
#include <QTimer>
#include <QVBoxLayout>

namespace StyleHelper {

/**
 * @brief 自定义居中弹窗：正文在上、小按钮在底部居中，避免文字被挡住。
 */
inline QMessageBox::StandardButton execCenteredDialog(
    QWidget *parent, const QString &title, const QString &text,
    QMessageBox::StandardButtons buttons)
{
    QDialog dlg(parent);
    dlg.setWindowTitle(title);
    dlg.setModal(true);
    dlg.setMinimumWidth(420);
    if (parent)
        dlg.setStyleSheet(parent->styleSheet());
    else if (qApp)
        dlg.setStyleSheet(qApp->styleSheet());

    auto *root = new QVBoxLayout(&dlg);
    root->setContentsMargins(28, 24, 28, 18);
    root->setSpacing(18);

    auto *textLabel = new QLabel(text, &dlg);
    textLabel->setWordWrap(true);
    textLabel->setAlignment(Qt::AlignHCenter | Qt::AlignVCenter);
    textLabel->setTextInteractionFlags(Qt::TextSelectableByMouse);
    textLabel->setMinimumWidth(360);
    textLabel->setMaximumWidth(520);
    textLabel->setStyleSheet(QStringLiteral("font-size: 15px; padding: 4px 8px;"));
    root->addWidget(textLabel, 1, Qt::AlignHCenter);

    auto *btnRow = new QHBoxLayout;
    btnRow->setSpacing(12);
    btnRow->addStretch();

    auto addBtn = [&](const QString &caption, QMessageBox::StandardButton role, bool isDefault) {
        auto *btn = new QPushButton(caption, &dlg);
        btn->setMinimumSize(88, 36);
        btn->setMaximumHeight(36);
        btn->setDefault(isDefault);
        btnRow->addWidget(btn);
        QObject::connect(btn, &QPushButton::clicked, &dlg, [role, &dlg]() {
            dlg.done(static_cast<int>(role));
        });
    };

    const bool hasYes = buttons.testFlag(QMessageBox::Yes);
    const bool hasNo = buttons.testFlag(QMessageBox::No);
    const bool hasOk = buttons.testFlag(QMessageBox::Ok);
    const bool hasCancel = buttons.testFlag(QMessageBox::Cancel);

    if (hasNo)
        addBtn(QStringLiteral("否"), QMessageBox::No, false);
    if (hasCancel && !hasNo)
        addBtn(QStringLiteral("取消"), QMessageBox::Cancel, false);
    if (hasYes)
        addBtn(QStringLiteral("是"), QMessageBox::Yes, true);
    if (hasOk)
        addBtn(QStringLiteral("确定"), QMessageBox::Ok, true);
    if (!hasYes && !hasNo && !hasOk && !hasCancel)
        addBtn(QStringLiteral("确定"), QMessageBox::Ok, true);

    btnRow->addStretch();
    root->addLayout(btnRow);

    dlg.adjustSize();
    if (dlg.width() < 420)
        dlg.resize(420, dlg.height());
    return static_cast<QMessageBox::StandardButton>(dlg.exec());
}

/**
 * @brief 轻量处理残留 QMessageBox：去图标、缩小按钮，避免挡住正文。
 */
inline void polishMessageBox(QMessageBox *box)
{
    if (!box)
        return;
    box->setIcon(QMessageBox::NoIcon);
    box->setMinimumWidth(420);
    for (QLabel *lab : box->findChildren<QLabel *>()) {
        if (!lab)
            continue;
        if (lab->text().isEmpty()) {
            lab->hide();
            lab->setFixedSize(0, 0);
            continue;
        }
        lab->setWordWrap(true);
        lab->setAlignment(Qt::AlignHCenter | Qt::AlignVCenter);
    }
    for (QPushButton *btn : box->findChildren<QPushButton *>()) {
        if (!btn)
            continue;
        btn->setMinimumSize(88, 36);
        btn->setMaximumHeight(36);
    }
}

/**
 * @brief 安装应用级过滤器，兜底处理原生 QMessageBox。
 */
inline void installCenteredMessageBoxes(QObject *owner)
{
    struct Filter final : QObject {
        using QObject::QObject;
        bool eventFilter(QObject *watched, QEvent *event) override
        {
            if (!event)
                return QObject::eventFilter(watched, event);
            if (event->type() == QEvent::Show) {
                if (auto *box = qobject_cast<QMessageBox *>(watched)) {
                    polishMessageBox(box);
                    QTimer::singleShot(0, box, [box]() { polishMessageBox(box); });
                }
            }
            return QObject::eventFilter(watched, event);
        }
    };
    qApp->installEventFilter(new Filter(owner ? owner : qApp));
}

/**
 * @brief 无图标、文字居中的询问框（小按钮置底居中）。
 */
inline QMessageBox::StandardButton question(QWidget *parent, const QString &title, const QString &text,
                                           QMessageBox::StandardButtons buttons = QMessageBox::Yes
                                               | QMessageBox::No)
{
    return execCenteredDialog(parent, title, text, buttons);
}

/** @brief 无图标、文字居中的提示框。 */
inline void information(QWidget *parent, const QString &title, const QString &text)
{
    execCenteredDialog(parent, title, text, QMessageBox::Ok);
}

/** @brief 无图标、文字居中的警告框。 */
inline void warning(QWidget *parent, const QString &title, const QString &text)
{
    execCenteredDialog(parent, title, text, QMessageBox::Ok);
}

/** @brief 无图标、文字居中的错误框。 */
inline void critical(QWidget *parent, const QString &title, const QString &text)
{
    execCenteredDialog(parent, title, text, QMessageBox::Ok);
}

// 收藏高亮颜色。QListWidget 一旦写了 item 的 background，setBackground() 会被样式表盖掉，
// 真正生效的是 FavoriteCardDelegate 读这里的颜色。改黄底只改下面两处即可。
inline QColor favoriteBackground(bool dark)
{
    return dark ? QColor(QStringLiteral("#5C4A1A")) : QColor(QStringLiteral("#FFF4D6"));
}

inline QColor favoriteForeground(bool dark)
{
    return dark ? QColor(QStringLiteral("#F5D76E")) : QColor(QStringLiteral("#8A4B00"));
}

inline QString userClientStyle()
{
    return QStringLiteral(R"(
        QWidget { font-family: 'Noto Sans CJK SC','Microsoft YaHei',sans-serif; color: #15201E; font-size: 13px; }
        QMainWindow, QDialog, QWidget#centralRoot { background: #F3F6F5; }
        QLabel#pageTitle, QLabel#titleLabel { font-size: 16px; font-weight: 600; color: #15201E; }
        QLabel#muted, QLabel#subtitleLabel { color: #64716E; font-size: 12px; }
        QLabel#countdownLabel { color: #0D7565; font-size: 13px; font-weight: 600; }
        QLabel#chargeBanner {
            background: #0D7565; color: white; font-size: 12px; font-weight: 600;
            padding: 8px 14px;
        }
        QLineEdit, QComboBox {
            padding: 7px 10px; border: 1px solid #D8E0DE; border-radius: 4px;
            background: white; selection-background-color: #D7E8E4; color: #15201E;
        }
        QLineEdit:focus, QComboBox:focus { border-color: #0D7565; }
        QComboBox::drop-down {
            border: none; width: 28px;
            border-top-right-radius: 4px; border-bottom-right-radius: 4px;
        }
        QComboBox QAbstractItemView {
            background: white; color: #15201E; border: 1px solid #D8E0DE;
            border-radius: 4px; selection-background-color: #D7E8E4;
            outline: none;
        }
        QPushButton {
            background: #0D7565; color: white; border: 1px solid #0D7565; border-radius: 4px;
            padding: 7px 12px; font-size: 13px;
        }
        QPushButton:hover { background: #0A5F52; }
        QPushButton:disabled { background: #D8E0DE; color: #8A9693; border-color: #D8E0DE; }
        QPushButton#secondaryBtn {
            background: white; color: #15201E; border: 1px solid #D8E0DE;
        }
        QPushButton#secondaryBtn:hover { background: #EEF2F1; }
        QPushButton#successBtn { background: #188568; border-color: #188568; }
        QPushButton#dangerBtn { background: #C34444; border-color: #C34444; }
        QPushButton#dangerBtn:hover { background: #A83737; }
        QPushButton#navBtn {
            border: none; border-radius: 0; background: transparent; color: #64716E; font-size: 13px;
        }
        QPushButton#navBtn[active="true"] {
            color: #0D7565; font-weight: 600; background: #E7F2EF;
        }
        QCheckBox { color: #15201E; spacing: 6px; }
        QFrame#card {
            background: white; border: 1px solid #D8E0DE; border-radius: 8px;
        }
        QWidget#bottomNav {
            background: #FFFFFF; border-top: 1px solid #D8E0DE;
        }
        QListWidget {
            background: transparent; border: none; outline: none;
            show-decoration-selected: 0;
        }
        QListWidget::item {
            border: 1px solid #D8E0DE; border-radius: 8px;
            margin: 5px 2px; padding: 10px 12px; color: #15201E;
        }
        QListWidget::item:selected {
            border: 1px solid #0D7565; border-radius: 8px;
        }
        /* 收藏黄底由 FavoriteCardDelegate 绘制，这里不能写 background */
        QListWidget#stationList::item, QListWidget#pileList::item {
            border: none;
            margin: 0px;
            padding: 0px;
        }
        QListWidget#stationList::item:selected, QListWidget#pileList::item:selected {
            border: none;
        }
        QLabel#starLabel { color: #F5A623; font-size: 15px; font-weight: 600; }
        QWidget#loginHero {
            background-color: #0D7565;
            border: none;
        }
        QLabel#heroTitle { color: #FFFFFF; font-size: 22px; font-weight: 600; }
        QLabel#heroSub { color: #D7E8E4; font-size: 13px; }
        QLabel#brandMark {
            background-color: rgba(255,255,255,0.16); color: #FFFFFF;
            font-size: 22px; font-weight: 700; border-radius: 28px;
            border: 1px solid rgba(255,255,255,0.22);
        }
        QFrame#loginCard {
            background: white; border: 1px solid #D8E0DE; border-radius: 12px;
        }
        QPushButton#starBtn {
            background: transparent; border: none; color: #C5D0CD;
            font-size: 28px; padding: 0; min-width: 40px; min-height: 40px;
        }
        QPushButton#starBtn:hover { color: #F5A623; background: transparent; border: none; }
        QPushButton#starBtn[lit="true"] { color: #F5A623; background: transparent; border: none; }
        QTableWidget {
            background: white; border: 1px solid #D8E0DE; gridline-color: #E8EEEC;
            alternate-background-color: #F7F9F8; color: #15201E; border-radius: 8px;
        }
        QHeaderView::section {
            background: #EEF2F1; color: #3D4A47; padding: 6px 8px;
            border: none; border-bottom: 1px solid #D8E0DE; font-weight: 600;
        }
        QHeaderView::section:first { border-top-left-radius: 8px; }
        QHeaderView::section:last { border-top-right-radius: 8px; }
        QProgressBar {
            border: 1px solid #D8E0DE; background: #EEF2F1; border-radius: 6px;
            height: 14px; text-align: center; color: #15201E;
        }
        QProgressBar::chunk { background: #0D7565; border-radius: 6px; }
        QScrollArea { border: none; background: transparent; }
        QScrollBar:vertical {
            background: transparent; width: 8px; margin: 2px;
        }
        QScrollBar::handle:vertical { background: #C5D0CD; border-radius: 4px; min-height: 24px; }
        QScrollBar::add-line:vertical, QScrollBar::sub-line:vertical { height: 0; }
        QMessageBox {
            background: #F3F6F5;
            min-width: 420px;
        }
        QMessageBox QLabel {
            min-width: 320px;
            font-size: 15px;
            padding: 8px 12px;
            qproperty-alignment: AlignHCenter;
        }
        QMessageBox QPushButton {
            min-width: 88px;
            max-height: 36px;
            min-height: 36px;
            font-size: 14px;
            padding: 6px 14px;
        }
        QStatusBar {
            background: #FFFFFF; color: #3D4A47; border: none; border-top: 1px solid #D8E0DE;
        }
    )");
}

inline QString userClientDarkStyle()
{
    return QStringLiteral(R"(
        QWidget { font-family: 'Noto Sans CJK SC','Microsoft YaHei',sans-serif; color: #E8EEEC; font-size: 13px; }
        QMainWindow, QDialog, QWidget#centralRoot { background: #121A19; }
        QLabel#pageTitle, QLabel#titleLabel { font-size: 16px; font-weight: 600; color: #F3F6F5; }
        QLabel#muted, QLabel#subtitleLabel { color: #8A9693; font-size: 12px; }
        QLabel#countdownLabel { color: #3DDBB5; font-size: 13px; font-weight: 600; }
        QLabel#chargeBanner {
            background: #0A5F52; color: #E8EEEC; font-size: 12px; font-weight: 600;
            padding: 8px 14px;
        }
        QLineEdit, QComboBox {
            padding: 7px 10px; border: 1px solid #2A3835; border-radius: 4px;
            background: #1A2422; selection-background-color: #0D7565; color: #E8EEEC;
        }
        QComboBox::drop-down {
            border: none; width: 28px;
            border-top-right-radius: 4px; border-bottom-right-radius: 4px;
        }
        QComboBox QAbstractItemView {
            background: #1A2422; color: #E8EEEC; border: 1px solid #2A3835;
            border-radius: 4px; selection-background-color: #0D7565;
            outline: none;
        }
        QLineEdit:focus, QComboBox:focus { border-color: #3DDBB5; }
        QPushButton {
            background: #0D7565; color: white; border: 1px solid #0D7565; border-radius: 4px;
            padding: 7px 12px; font-size: 13px;
        }
        QPushButton:hover { background: #11967F; }
        QPushButton:disabled { background: #2A3835; color: #6B7874; border-color: #2A3835; }
        QPushButton#secondaryBtn {
            background: #1A2422; color: #E8EEEC; border: 1px solid #2A3835;
        }
        QPushButton#secondaryBtn:hover { background: #24302D; }
        QPushButton#successBtn { background: #188568; border-color: #188568; }
        QPushButton#dangerBtn { background: #C34444; border-color: #C34444; }
        QPushButton#dangerBtn:hover { background: #A83737; }
        QPushButton#navBtn {
            border: none; border-radius: 0; background: transparent; color: #8A9693; font-size: 13px;
        }
        QPushButton#navBtn[active="true"] {
            color: #3DDBB5; font-weight: 600; background: #20302D;
        }
        QCheckBox { color: #E8EEEC; spacing: 6px; }
        QFrame#card {
            background: #1A2422; border: 1px solid #2A3835; border-radius: 8px;
        }
        QWidget#bottomNav {
            background: #1A2422; border-top: 1px solid #2A3835;
        }
        QListWidget {
            background: transparent; border: none; outline: none;
            show-decoration-selected: 0;
        }
        QListWidget::item {
            border: 1px solid #2A3835; border-radius: 8px;
            margin: 5px 2px; padding: 10px 12px; color: #E8EEEC;
        }
        QListWidget::item:selected {
            border: 1px solid #3DDBB5; border-radius: 8px;
        }
        QListWidget#stationList::item, QListWidget#pileList::item {
            border: none;
            margin: 0px;
            padding: 0px;
        }
        QListWidget#stationList::item:selected, QListWidget#pileList::item:selected {
            border: none;
        }
        QLabel#starLabel { color: #F5A623; font-size: 15px; font-weight: 600; }
        QWidget#loginHero {
            background-color: #0A5F52;
            border: none;
        }
        QLabel#heroTitle { color: #F3F6F5; font-size: 22px; font-weight: 600; }
        QLabel#heroSub { color: #9AA8A4; font-size: 13px; }
        QLabel#brandMark {
            background-color: rgba(255,255,255,0.08); color: #3DDBB5;
            font-size: 22px; font-weight: 700; border-radius: 28px;
            border: 1px solid rgba(61,219,181,0.28);
        }
        QFrame#loginCard {
            background: #1A2422; border: 1px solid #2A3835; border-radius: 12px;
        }
        QPushButton#starBtn {
            background: transparent; border: none; color: #3D4A47;
            font-size: 28px; padding: 0; min-width: 40px; min-height: 40px;
        }
        QPushButton#starBtn:hover { color: #F5A623; background: transparent; border: none; }
        QPushButton#starBtn[lit="true"] { color: #F5A623; background: transparent; border: none; }
        QTableWidget {
            background: #1A2422; border: 1px solid #2A3835; gridline-color: #2A3835;
            alternate-background-color: #15201E; color: #E8EEEC; border-radius: 8px;
        }
        QHeaderView::section {
            background: #20302D; color: #C5D0CD; padding: 6px 8px;
            border: none; border-bottom: 1px solid #2A3835; font-weight: 600;
        }
        QHeaderView::section:first { border-top-left-radius: 8px; }
        QHeaderView::section:last { border-top-right-radius: 8px; }
        QProgressBar {
            border: 1px solid #2A3835; background: #121A19; border-radius: 6px;
            height: 14px; text-align: center; color: #E8EEEC;
        }
        QProgressBar::chunk { background: #0D7565; border-radius: 6px; }
        QScrollArea { border: none; background: transparent; }
        QScrollBar:vertical {
            background: transparent; width: 8px; margin: 2px;
        }
        QScrollBar::handle:vertical { background: #3D4A47; border-radius: 4px; min-height: 24px; }
        QScrollBar::add-line:vertical, QScrollBar::sub-line:vertical { height: 0; }
        QMessageBox {
            background: #1A2422;
            min-width: 420px;
        }
        QMessageBox QLabel {
            min-width: 320px;
            font-size: 15px;
            color: #E8EEEC;
            padding: 8px 12px;
            qproperty-alignment: AlignHCenter;
        }
        QMessageBox QPushButton {
            min-width: 88px;
            max-height: 36px;
            min-height: 36px;
            font-size: 14px;
            padding: 6px 14px;
        }
        QStatusBar {
            background: #1A2422; color: #C5D0CD; border: none; border-top: 1px solid #2A3835;
        }
    )");
}

inline QString adminClientStyle()
{
    return userClientStyle() + QStringLiteral(R"(
        QLabel#kpiValue { font-size: 20px; font-weight: 600; color: #15201E; font-family: 'Consolas','Noto Sans Mono','monospace'; }
        QLabel#kpiTitle { color: #64716E; font-size: 12px; }
        QLabel#brandTitle { font-size: 14px; font-weight: 600; color: #F3F6F5; }
        QLabel#brandSub { color: #9AA8A4; font-size: 12px; }
        QWidget#sideBar { background: #20302D; }
        QListWidget#sideNav {
            background: #20302D; border: none; outline: none; padding: 0;
        }
        QListWidget#sideNav::item {
            padding: 9px 14px; margin: 0; border-radius: 0;
            color: #C5D0CD; background: transparent;
            border: none; border-left: 3px solid transparent;
        }
        QListWidget#sideNav::item:selected {
            background: #15201E; color: #F3F6F5; border: none;
            border-left: 3px solid #0D7565;
        }
        QListWidget#sideNav::item:hover { background: #263833; }
        QFrame#kpiCard {
            background: white; border: 1px solid #D8E0DE; border-radius: 4px;
        }
        QSpinBox, QDoubleSpinBox {
            padding: 6px 8px; border: 1px solid #D8E0DE; border-radius: 4px; background: white;
        }
        QChartView { background: white; border: 1px solid #D8E0DE; }
    )");
}

inline QString adminClientDarkStyle()
{
    return userClientDarkStyle() + QStringLiteral(R"(
        QLabel#kpiValue { font-size: 20px; font-weight: 600; color: #F3F6F5; font-family: 'Consolas','Noto Sans Mono','monospace'; }
        QLabel#kpiTitle { color: #8A9693; font-size: 12px; }
        QLabel#brandTitle { font-size: 14px; font-weight: 600; color: #F3F6F5; }
        QLabel#brandSub { color: #9AA8A4; font-size: 12px; }
        QWidget#sideBar { background: #15201E; }
        QListWidget#sideNav {
            background: #15201E; border: none; outline: none; padding: 0;
        }
        QListWidget#sideNav::item {
            padding: 9px 14px; margin: 0; border-radius: 0;
            color: #C5D0CD; background: transparent;
            border: none; border-left: 3px solid transparent;
        }
        QListWidget#sideNav::item:selected {
            background: #0F1716; color: #F3F6F5; border: none;
            border-left: 3px solid #3DDBB5;
        }
        QListWidget#sideNav::item:hover { background: #20302D; }
        QFrame#kpiCard {
            background: #1A2422; border: 1px solid #2A3835; border-radius: 4px;
        }
        QSpinBox, QDoubleSpinBox {
            padding: 6px 8px; border: 1px solid #2A3835; border-radius: 4px;
            background: #1A2422; color: #E8EEEC;
        }
        QChartView { background: #1A2422; border: 1px solid #2A3835; }
    )");
}

} // namespace StyleHelper
