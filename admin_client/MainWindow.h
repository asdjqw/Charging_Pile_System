#pragma once

#include "Models.h"

#include <QJsonObject>
#include <QMainWindow>
#include <QtCharts/QChartView>

class QComboBox;
class QFrame;
class QLabel;
class QLineEdit;
class QListWidget;
class QPushButton;
class QStackedWidget;
class QTableWidget;

class MainWindow : public QMainWindow
{
    Q_OBJECT
public:
    explicit MainWindow(const Admin &admin, QWidget *parent = nullptr);

private slots:
    void onNavChanged(int row);
    void refreshDashboard();
    void refreshPileStatus();
    void refreshPiles();
    void refreshStations();
    void refreshUsers();
    void onRestartPile();
    void onAddStation();
    void onStationRowClicked(int row, int column);
    void onToggleUserStatus();
    void onToggleDarkMode(bool dark);

private:
    void buildUi();
    QWidget *buildDashboardPage();
    QWidget *buildPileStatusPage();
    QWidget *buildPilePage();
    QWidget *buildStationPage();
    QWidget *buildUserPage();
    QFrame *makeKpiCard(const QString &title, QLabel **valueLabel);
    void applySalesChart(const QJsonObject &payload);
    void applyStatusChart(const QJsonObject &stats);
    void applyTheme(bool dark);
    void showApiError(const QString &title);

    Admin m_admin;
    bool m_darkMode = false;
    QPushButton *m_darkModeBtn = nullptr;
    QListWidget *m_nav = nullptr;
    QStackedWidget *m_stack = nullptr;

    QLabel *m_kpiTodayAmount = nullptr;
    QLabel *m_kpiMonthAmount = nullptr;
    QLabel *m_kpiTotalAmount = nullptr;
    QComboBox *m_salesDays = nullptr;
    QChartView *m_salesChartView = nullptr;
    QTableWidget *m_recentOrders = nullptr;

    QLabel *m_statusSummary = nullptr;
    QChartView *m_statusChartView = nullptr;
    QTableWidget *m_statusDistTable = nullptr;

    QComboBox *m_pileStationFilter = nullptr;
    QTableWidget *m_pileTable = nullptr;

    QLineEdit *m_stationKeyword = nullptr;
    QTableWidget *m_stationTable = nullptr;
    QLabel *m_stationDetailTitle = nullptr;
    QTableWidget *m_stationPileTable = nullptr;

    QLineEdit *m_userKeyword = nullptr;
    QTableWidget *m_userTable = nullptr;
};
