#pragma once

#include "Models.h"

#include <QMainWindow>

class QLabel;
class QListWidget;
class QStackedWidget;
class QTableWidget;
class QLineEdit;
class QComboBox;
class QChartView;

class MainWindow : public QMainWindow
{
    Q_OBJECT
public:
    explicit MainWindow(const Admin &admin, QWidget *parent = nullptr);

private slots:
    void onNavChanged(int row);
    void refreshDashboard();
    void refreshPileStatus();
    void refreshStations();
    void refreshPiles();
    void refreshUsers();
    void onAddStation();
    void onEditStation();
    void onDeleteStation();
    void onAddPile();
    void onEditPile();
    void onDeletePile();
    void onSetPileStatus();
    void onDeleteUser();
    void onRechargeUser();

private:
    void buildUi();
    QWidget *buildDashboardPage();
    QWidget *buildPileStatusPage();
    QWidget *buildStationPage();
    QWidget *buildPilePage();
    QWidget *buildUserPage();
    QFrame *makeKpiCard(const QString &title, QLabel **valueLabel);

    Admin m_admin;
    QListWidget *m_nav = nullptr;
    QStackedWidget *m_stack = nullptr;

    // dashboard
    QLabel *m_kpiTodayAmount = nullptr;
    QLabel *m_kpiMonthAmount = nullptr;
    QLabel *m_kpiTotalOrders = nullptr;
    QLabel *m_kpiUsers = nullptr;
    QLabel *m_kpiIdle = nullptr;
    QLabel *m_kpiCharging = nullptr;
    QLabel *m_kpiFault = nullptr;
    QLabel *m_kpiOffline = nullptr;
    QChartView *m_salesChart = nullptr;
    QTableWidget *m_recentOrders = nullptr;

    // pile status
    QComboBox *m_statusFilter = nullptr;
    QTableWidget *m_statusTable = nullptr;

    // stations
    QTableWidget *m_stationTable = nullptr;
    QLineEdit *m_stationKeyword = nullptr;

    // piles
    QTableWidget *m_pileTable = nullptr;
    QComboBox *m_pileStationFilter = nullptr;

    // users
    QTableWidget *m_userTable = nullptr;
    QLineEdit *m_userKeyword = nullptr;
};
