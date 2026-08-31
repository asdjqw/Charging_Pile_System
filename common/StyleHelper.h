#pragma once

#include <QString>

namespace StyleHelper {

inline QString userClientStyle()
{
    return QStringLiteral(R"(
        QWidget { background: #F5F7FB; color: #1F2937; font-size: 14px; }
        QMainWindow { background: #F5F7FB; }
        QLabel#titleLabel { font-size: 22px; font-weight: 700; color: #0F172A; }
        QLabel#subtitleLabel { color: #64748B; }
        QPushButton {
            background: #2563EB; color: white; border: none; border-radius: 10px;
            padding: 10px 16px; font-weight: 600;
        }
        QPushButton:hover { background: #1D4ED8; }
        QPushButton:disabled { background: #93C5FD; }
        QPushButton#dangerBtn { background: #DC2626; }
        QPushButton#dangerBtn:hover { background: #B91C1C; }
        QPushButton#secondaryBtn { background: #E2E8F0; color: #0F172A; }
        QPushButton#secondaryBtn:hover { background: #CBD5E1; }
        QLineEdit, QComboBox, QDoubleSpinBox, QSpinBox, QTextEdit {
            background: white; border: 1px solid #CBD5E1; border-radius: 8px;
            padding: 8px 10px; selection-background-color: #2563EB;
        }
        QTableWidget {
            background: white; border: 1px solid #E2E8F0; border-radius: 12px;
            gridline-color: #F1F5F9;
        }
        QHeaderView::section {
            background: #EFF6FF; color: #1E3A8A; padding: 8px; border: none;
            font-weight: 600;
        }
        QFrame#card {
            background: white; border: 1px solid #E2E8F0; border-radius: 16px;
        }
        QListWidget {
            background: transparent; border: none;
        }
        QListWidget::item {
            background: white; border: 1px solid #E2E8F0; border-radius: 14px;
            margin: 6px 0; padding: 8px;
        }
        QListWidget::item:selected {
            border: 2px solid #2563EB; background: #EFF6FF;
        }
        QTabWidget::pane { border: none; }
        QTabBar::tab {
            background: #E2E8F0; color: #334155; padding: 10px 18px;
            border-top-left-radius: 10px; border-top-right-radius: 10px; margin-right: 4px;
        }
        QTabBar::tab:selected { background: #2563EB; color: white; }
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
        QListWidget {
            background: #0F172A; border: none;
        }
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
