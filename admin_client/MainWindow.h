#pragma once

#include "Models.h"

#include <QJsonObject>
#include <QMainWindow>
#include <QtCharts/QChartView>

class QComboBox;
class QCloseEvent;
class QFrame;
class QLabel;
class QLineEdit;
class QListWidget;
class QPushButton;
class QStackedWidget;
class QTableWidget;
class QCheckBox;

class MainWindow : public QMainWindow
{
    Q_OBJECT
public:
    explicit MainWindow(const Admin &admin, QWidget *parent = nullptr);

signals:
    void logoutRequested();

private slots:
    void onNavChanged(int row);
    void refreshDashboard();
    void refreshPileStatus();
    void refreshPiles();
    void refreshStations();
    void refreshUsers();
    void refreshReservations();
    void refreshPermissions();
    void onRestartPile();
    void onAddPile();
    void onEditPile();
    void onDeletePile();
    void onAddStation();
    void onEditStation();
    void onDeleteStation();
    void onStationRowClicked(int row, int column);
    void onToggleUserStatus();
    void onViewUserOrders();
    void onCancelReservation();
    void onCreateInvite();
    void onTogglePermission();
    void onToggleDarkMode(bool dark);
    void onPileDistrictChanged();
    void onPileSelectionChanged();
    void onLogout();

private:
    void buildUi();
    QWidget *buildDashboardPage();
    QWidget *buildPileStatusPage();
    QWidget *buildPilePage();
    QWidget *buildStationPage();
    QWidget *buildUserPage();
    QWidget *buildReservationPage();
    QWidget *buildPermissionPage();
    QFrame *makeKpiCard(const QString &title, QLabel **valueLabel);
    void applySalesChart(const QJsonObject &payload);
    void applyStatusChart(const QJsonObject &stats);
    void applyTheme(bool dark);
    void showApiError(const QString &title);
    void rebuildPileStationFilter(bool keepSelection);
    void updateRestartButtonVisibility();
    bool confirmForce(const QString &title);
    bool editPileDialog(Pile &pile, bool isNew);
    bool editStationDialog(Station &station, int *pileCount, bool isNew);
    void closeEvent(QCloseEvent *event) override;

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
    QLineEdit *m_statusKeyword = nullptr;
    QTableWidget *m_statusPileTable = nullptr;

    QComboBox *m_pileDistrictFilter = nullptr;
    QComboBox *m_pileStationFilter = nullptr;
    QComboBox *m_pileStatusFilter = nullptr;
    QPushButton *m_pileRestartBtn = nullptr;
    QTableWidget *m_pileTable = nullptr;

    QLineEdit *m_stationKeyword = nullptr;
    QTableWidget *m_stationTable = nullptr;
    QLabel *m_stationDetailTitle = nullptr;
    QTableWidget *m_stationPileTable = nullptr;

    QLineEdit *m_userKeyword = nullptr;
    QTableWidget *m_userTable = nullptr;

    QTableWidget *m_reservationTable = nullptr;
    QTableWidget *m_inviteTable = nullptr;
    QComboBox *m_permRoleCombo = nullptr;
    QTableWidget *m_permTable = nullptr;
    bool m_loggingOut = false;
};
