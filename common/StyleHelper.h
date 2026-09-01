#pragma once

#include <QString>

namespace StyleHelper {

inline QString userClientStyle()
{
    // 与 charging-user-client 天蓝色手机端风格对齐
    return QStringLiteral(R"(
        QWidget { font-family: 'Noto Sans CJK SC','Microsoft YaHei',sans-serif; color: #0F172A; font-size: 14px; }
        QMainWindow, QDialog, QWidget#centralRoot { background: #F0F9FF; }
        QLabel#pageTitle { font-size: 22px; font-weight: 700; color: #0284C7; }
        QLabel#titleLabel { font-size: 22px; font-weight: 700; color: #0284C7; }
        QLabel#muted, QLabel#subtitleLabel { color: #64748B; font-size: 12px; }
        QLineEdit, QComboBox {
            padding: 10px 12px; border: 1px solid #BAE6FD; border-radius: 10px;
            background: white; selection-background-color: #7DD3FC;
        }
        QLineEdit:focus, QComboBox:focus { border-color: #0EA5E9; }
        QPushButton {
            background: #0EA5E9; color: white; border: none; border-radius: 10px;
            padding: 10px 16px; font-size: 14px; font-weight: 600;
        }
        QPushButton:hover { background: #0284C7; }
        QPushButton:disabled { background: #CBD5E1; color: #94A3B8; }
        QPushButton#secondaryBtn {
            background: white; color: #0284C7; border: 1px solid #7DD3FC;
        }
        QPushButton#secondaryBtn:hover { background: #E0F2FE; }
        QPushButton#successBtn { background: #22C55E; }
        QPushButton#successBtn:hover { background: #16A34A; }
        QPushButton#dangerBtn { background: #F43F5E; }
        QPushButton#dangerBtn:hover { background: #E11D48; }
        QFrame#card {
            background: white; border: 1px solid #E0F2FE; border-radius: 14px;
        }
        QListWidget {
            background: transparent; border: none; outline: none;
        }
        QListWidget::item {
            background: white; border: 1px solid #E0F2FE; border-radius: 14px;
            margin: 6px 0; padding: 12px;
        }
        QListWidget::item:selected {
            border: 2px solid #38BDF8; background: #E0F2FE;
        }
        QTableWidget {
            background: white; border: 1px solid #E0F2FE; border-radius: 12px;
            gridline-color: #E0F2FE;
        }
        QHeaderView::section {
            background: #E0F2FE; color: #0284C7; padding: 8px; border: none; font-weight: 600;
        }
        QProgressBar {
            border: none; background: #E0F2FE; border-radius: 8px; height: 12px; text-align: center;
        }
        QProgressBar::chunk { background: #0EA5E9; border-radius: 8px; }
        QScrollArea { border: none; background: transparent; }
    )");
}

inline QString adminServerStyle()
{
    return QStringLiteral(R"(
        QWidget { background: #0B1220; color: #E5E7EB; font-size: 14px; }
        QMainWindow { background: #0B1220; }
        QLabel#titleLabel { font-size: 24px; font-weight: 700; color: #F8FAFC; }
        QLabel#kpiValue { font-size: 28px; font-weight: 700; color: #38BDF8; }
        QLabel#kpiTitle { color: #94A3B8; }
        QPushButton {
            background: #2563EB; color: white; border: none; border-radius: 8px;
            padding: 8px 14px; font-weight: 600;
        }
        QPushButton:hover { background: #1D4ED8; }
        QPushButton#dangerBtn { background: #DC2626; }
        QPushButton#secondaryBtn { background: #1E293B; border: 1px solid #334155; }
        QLineEdit, QComboBox, QDoubleSpinBox, QSpinBox, QTextEdit {
            background: #111827; border: 1px solid #334155; border-radius: 8px;
            padding: 8px 10px; color: #F8FAFC;
        }
        QTableWidget {
            background: #111827; border: 1px solid #1F2937; gridline-color: #1F2937;
            alternate-background-color: #0F172A;
        }
        QHeaderView::section {
            background: #1E293B; color: #93C5FD; padding: 8px; border: none; font-weight: 600;
        }
        QFrame#card {
            background: #111827; border: 1px solid #1F2937; border-radius: 14px;
        }
        QListWidget { background: #0F172A; border: none; }
        QListWidget::item {
            padding: 14px 18px; border-left: 3px solid transparent; color: #CBD5E1;
        }
        QListWidget::item:selected {
            background: #1E293B; border-left: 3px solid #38BDF8; color: white;
        }
        QGroupBox {
            border: 1px solid #1F2937; border-radius: 12px; margin-top: 12px; padding-top: 16px;
        }
        QGroupBox::title { subcontrol-origin: margin; left: 12px; color: #93C5FD; }
    )");
}

} // namespace StyleHelper
