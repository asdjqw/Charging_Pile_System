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
        QLineEdit, QComboBox {
            padding: 7px 10px; border: 1px solid #D8E0DE; border-radius: 4px;
            background: white; selection-background-color: #D7E8E4;
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
        QFrame#card {
            background: white; border: 1px solid #D8E0DE; border-radius: 4px;
        }
        QListWidget { background: transparent; border: none; outline: none; }
        QListWidget::item {
            background: white; border: 1px solid #D8E0DE; border-radius: 4px;
            margin: 4px 0; padding: 8px 10px;
        }
        QListWidget::item:selected { border: 1px solid #0D7565; background: #E7F2EF; }
        QTableWidget {
            background: white; border: 1px solid #D8E0DE; gridline-color: #E8EEEC;
            alternate-background-color: #F7F9F8;
        }
        QHeaderView::section {
            background: #EEF2F1; color: #3D4A47; padding: 6px 8px;
            border: none; border-bottom: 1px solid #D8E0DE; font-weight: 600;
        }
        QProgressBar {
            border: 1px solid #D8E0DE; background: #EEF2F1; border-radius: 2px;
            height: 14px; text-align: center;
        }
        QProgressBar::chunk { background: #0D7565; }
        QScrollArea { border: none; background: transparent; }
        QMessageBox { background: #F3F6F5; }
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

} // namespace StyleHelper
