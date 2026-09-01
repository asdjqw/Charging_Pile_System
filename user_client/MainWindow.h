#pragma once

#include "Models.h"

#include <QMainWindow>
#include <QVector>

class QLabel;
class QLineEdit;
class QListWidget;
class QComboBox;
class QProgressBar;
class QTableWidget;
class QTimer;
class QPushButton;
class QStackedWidget;
class QWidget;
class LocationProvider;

class MainWindow : public QMainWindow
{
    Q_OBJECT
public:
    explicit MainWindow(const User &user, QWidget *parent = nullptr);

private slots:
    void onBottomNav(int index);
    void refreshStations();
    void loadMoreStations();
    void onLocate();
    void onRegionChanged();
    void onNavigate();
    void onRealLocationUpdated(double lat, double lng, const QString &label, const QString &source);
    void onRealLocationFailed(const QString &reason);
    void refreshPilesForCharge();
    void onStartCharge();
    void onStopCharge();
    void onChargeTick();
    void refreshProfile();
    void onSaveProfile();
    void onRecharge();
    void refreshOrders();

private:
    void buildUi();
    QWidget *buildStationsPage();
    QWidget *buildChargePage();
    QWidget *buildProfilePage();
    QWidget *buildBottomNav();
    void refreshOngoingBanner();
    void applyUserLocation(const QString &regionOrAddress);
    void requestRealLocation();
    int selectedStationId() const;
    int selectedPileId() const;

    User m_user;
    LocationProvider *m_locationProvider = nullptr;
    double m_userLat = 39.9042;
    double m_userLng = 116.4074;
    QString m_userAddress = QStringLiteral("正在检测当前位置…");
    QString m_locationSource = QStringLiteral("pending");
    QPushButton *m_locateBtn = nullptr;
    int m_visibleCount = 20;
    QVector<Station> m_cachedStations;

    QStackedWidget *m_tabStack = nullptr;
    QPushButton *m_navStations = nullptr;
    QPushButton *m_navCharge = nullptr;
    QPushButton *m_navProfile = nullptr;

    // 附近电站
    QComboBox *m_regionCombo = nullptr;
    QLineEdit *m_addressEdit = nullptr;
    QLineEdit *m_stationKeyword = nullptr;
    QLabel *m_locationLabel = nullptr;
    QLabel *m_countLabel = nullptr;
    QListWidget *m_stationList = nullptr;
    QPushButton *m_loadMoreBtn = nullptr;
    QLabel *m_navInfo = nullptr;

    // 充电
    QComboBox *m_stationCombo = nullptr;
    QComboBox *m_speedFilter = nullptr;
    QComboBox *m_connectorFilter = nullptr;
    QListWidget *m_pileList = nullptr;
    QLabel *m_chargeInfo = nullptr;
    QProgressBar *m_chargeProgress = nullptr;
    QTimer *m_chargeTimer = nullptr;
    ChargingOrder m_ongoing;
    double m_simulatedEnergy = 0.0;
    double m_currentPrice = 1.2;
    double m_currentPowerKw = 7.0;

    // 用户信息
    QLineEdit *m_phoneEdit = nullptr;
    QLineEdit *m_carEdit = nullptr;
    QLineEdit *m_plateEdit = nullptr;
    QLineEdit *m_pwdEdit = nullptr;
    QLineEdit *m_rechargeEdit = nullptr;
    QLabel *m_balanceLabel = nullptr;
    QLabel *m_dbInfoLabel = nullptr;
    QTableWidget *m_orderTable = nullptr;
};
