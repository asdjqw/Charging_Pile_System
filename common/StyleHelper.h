#pragma once

#include <QString>

namespace StyleHelper {

inline QString userClientStyle()
{
    return QStringLiteral(R"(
        QWidget { font-family: 'Noto Sans CJK SC','Microsoft YaHei',sans-serif; color: #15201E; font-size: 13px; }
        QMainWindow, QDialog, QWidget#centralRoot { background: #F3F6F5; }
        QLabel#pageTitle, QLabel#titleLabel { font-size: 16px; font-weight: 600; color: #15201E; }
        QLabel#muted, QLabel#subtitleLabel { color: #64716E; font-size: 12px; }
        QLabel#countdownLabel { color: #0D7565; font-size: 13px; font-weight: 600; }
        QLineEdit, QComboBox {
            padding: 7px 10px; border: 1px solid #D8E0DE; border-radius: 4px;
            background: white; selection-background-color: #D7E8E4; color: #15201E;
        }
        QLineEdit:focus, QComboBox:focus { border-color: #0D7565; }
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
            border: none; background: transparent; color: #64716E; font-size: 13px;
        }
        QPushButton#navBtn[active="true"] {
            color: #0D7565; font-weight: 600;
        }
        QCheckBox { color: #15201E; spacing: 6px; }
        QFrame#card {
            background: white; border: 1px solid #D8E0DE; border-radius: 4px;
        }
        QWidget#bottomNav {
            background: #FFFFFF; border-top: 1px solid #D8E0DE;
        }
        QListWidget { background: transparent; border: none; outline: none; }
        QListWidget::item {
            background: white; border: 1px solid #D8E0DE; border-radius: 4px;
            margin: 4px 0; padding: 8px 10px; color: #15201E;
        }
        QListWidget::item:selected { border: 1px solid #0D7565; background: #E7F2EF; }
        QTableWidget {
            background: white; border: 1px solid #D8E0DE; gridline-color: #E8EEEC;
            alternate-background-color: #F7F9F8; color: #15201E;
        }
        QHeaderView::section {
            background: #EEF2F1; color: #3D4A47; padding: 6px 8px;
            border: none; border-bottom: 1px solid #D8E0DE; font-weight: 600;
        }
        QProgressBar {
            border: 1px solid #D8E0DE; background: #EEF2F1; border-radius: 2px;
            height: 14px; text-align: center; color: #15201E;
        }
        QProgressBar::chunk { background: #0D7565; }
        QScrollArea { border: none; background: transparent; }
        QScrollBar:vertical {
            background: transparent; width: 8px; margin: 2px;
        }
        QScrollBar::handle:vertical { background: #C5D0CD; border-radius: 4px; min-height: 24px; }
        QScrollBar::add-line:vertical, QScrollBar::sub-line:vertical { height: 0; }
        QMessageBox { background: #F3F6F5; }
        QStatusBar { background: #EEF2F1; color: #3D4A47; }
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
        QLineEdit, QComboBox {
            padding: 7px 10px; border: 1px solid #2A3835; border-radius: 4px;
            background: #1A2422; selection-background-color: #0D7565; color: #E8EEEC;
        }
        QComboBox QAbstractItemView {
            background: #1A2422; color: #E8EEEC; border: 1px solid #2A3835;
            selection-background-color: #0D7565;
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
            border: none; background: transparent; color: #8A9693; font-size: 13px;
        }
        QPushButton#navBtn[active="true"] {
            color: #3DDBB5; font-weight: 600;
        }
        QCheckBox { color: #E8EEEC; spacing: 6px; }
        QFrame#card {
            background: #1A2422; border: 1px solid #2A3835; border-radius: 4px;
        }
        QWidget#bottomNav {
            background: #1A2422; border-top: 1px solid #2A3835;
        }
        QListWidget { background: transparent; border: none; outline: none; }
        QListWidget::item {
            background: #1A2422; border: 1px solid #2A3835; border-radius: 4px;
            margin: 4px 0; padding: 8px 10px; color: #E8EEEC;
        }
        QListWidget::item:selected { border: 1px solid #3DDBB5; background: #20302D; }
        QTableWidget {
            background: #1A2422; border: 1px solid #2A3835; gridline-color: #2A3835;
            alternate-background-color: #15201E; color: #E8EEEC;
        }
        QHeaderView::section {
            background: #20302D; color: #C5D0CD; padding: 6px 8px;
            border: none; border-bottom: 1px solid #2A3835; font-weight: 600;
        }
        QProgressBar {
            border: 1px solid #2A3835; background: #121A19; border-radius: 2px;
            height: 14px; text-align: center; color: #E8EEEC;
        }
        QProgressBar::chunk { background: #0D7565; }
        QScrollArea { border: none; background: transparent; }
        QScrollBar:vertical {
            background: transparent; width: 8px; margin: 2px;
        }
        QScrollBar::handle:vertical { background: #3D4A47; border-radius: 4px; min-height: 24px; }
        QScrollBar::add-line:vertical, QScrollBar::sub-line:vertical { height: 0; }
        QMessageBox { background: #1A2422; }
        QStatusBar { background: #15201E; color: #C5D0CD; }
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
