#pragma once

#include "Models.h"

#include <QMainWindow>
#include <QSet>
#include <QVector>

class QCheckBox;
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
class QCloseEvent;
class LocationProvider;

class MainWindow : public QMainWindow
{
    Q_OBJECT
public:
    explicit MainWindow(const User &user, QWidget *parent = nullptr);

signals:
    void logoutRequested();

private slots:
    void onBottomNav(int index);
    void refreshStations();
    void loadMoreStations();
    void onLocate();
    void onRegionChanged();
    void onNavigate();
    void onToggleFavorite();
    void onTogglePileFavorite();
    void onFavoriteFilterToggled(bool checked);
    void onPileFavoriteFilterToggled(bool checked);
    void onRealLocationUpdated(double lat, double lng, const QString &label, const QString &source);
    void onRealLocationFailed(const QString &reason);
    void refreshPilesForCharge();
    void onReservePile();
    void onCancelReservation();
    void onStartCharge();
    void onStopCharge();
    void onChargeTick();
    void onReservationTick();
    void onChargeSubNav(int index);
    void refreshProfile();
    void onSaveProfile();
    void onChooseAvatar();
    void onRecharge();
    void refreshOrders();
    void onToggleDarkMode(bool dark);
    void restoreSession();
    void onLogout();

private:
    void buildUi();
    QWidget *buildStationsPage();
    QWidget *buildChargePage();
    QWidget *buildProfilePage();
    QWidget *buildBottomNav();
    void refreshOngoingBanner();
    void updateReservationCountdown();
    void updateChargeSubNavActive(int index);
    void applyUserLocation(const QString &regionOrAddress);
    void requestRealLocation();
    void loadFavorites();
    void saveFavorites();
    bool isFavorite(int stationId) const;
    bool isPileFavorite(int pileId) const;
    void setFavorite(int stationId, bool on);
    void applyTheme(bool dark);
    void updateNavActive(int index);
    void appendStationItem(const Station &s);
    int selectedStationId() const;
    int selectedPileId() const;
    int selectedListStationId() const;
    void closeEvent(QCloseEvent *event) override;

    User m_user;
    LocationProvider *m_locationProvider = nullptr;
    double m_userLat = 39.9042;
    double m_userLng = 116.4074;
    QString m_userAddress = QStringLiteral("正在检测当前位置…");
    QString m_locationSource = QStringLiteral("pending");
    QPushButton *m_locateBtn = nullptr;
    int m_visibleCount = 20;
    QVector<Station> m_cachedStations;
    QSet<int> m_favoriteIds;
    QSet<int> m_favoritePileIds;
    bool m_darkMode = false;
    bool m_sessionRestored = false;
    bool m_loggingOut = false;

    QStackedWidget *m_tabStack = nullptr;
    QWidget *m_bottomNav = nullptr;
    QPushButton *m_navStations = nullptr;
    QPushButton *m_navCharge = nullptr;
    QPushButton *m_navProfile = nullptr;
    QLabel *m_chargeBanner = nullptr;

    // 附近电站
    QComboBox *m_regionCombo = nullptr;
    QLineEdit *m_addressEdit = nullptr;
    QLineEdit *m_stationKeyword = nullptr;
    QLabel *m_locationLabel = nullptr;
    QLabel *m_countLabel = nullptr;
    QListWidget *m_stationList = nullptr;
    QPushButton *m_loadMoreBtn = nullptr;
    QPushButton *m_favBtn = nullptr;
    QCheckBox *m_favOnlyCheck = nullptr;
    QLabel *m_navInfo = nullptr;

    // 充电 / 预约子页
    QPushButton *m_subNavReserve = nullptr;
    QPushButton *m_subNavMyReserve = nullptr;
    QPushButton *m_subNavCharge = nullptr;
    QStackedWidget *m_chargeSubStack = nullptr;
    QComboBox *m_stationCombo = nullptr;
    QComboBox *m_speedFilter = nullptr;
    QComboBox *m_connectorFilter = nullptr;
    QListWidget *m_pileList = nullptr;
    QCheckBox *m_pileFavOnlyCheck = nullptr;
    QPushButton *m_pileFavBtn = nullptr;
    QLabel *m_chargeInfo = nullptr;
    QLabel *m_reservationInfo = nullptr;
    QProgressBar *m_chargeProgress = nullptr;
    QTimer *m_chargeTimer = nullptr;
    QTimer *m_reservationTimer = nullptr;
    ChargingOrder m_ongoing;
    ChargingReservation m_reservation;
    double m_simulatedEnergy = 0.0;
    int m_progressTick = 0;
    double m_currentPrice = 1.2;
    double m_currentPowerKw = 7.0;

    // 用户信息
    QLineEdit *m_phoneEdit = nullptr;
    QLineEdit *m_nicknameEdit = nullptr;
    QLineEdit *m_carEdit = nullptr;
    QLineEdit *m_plateEdit = nullptr;
    QLineEdit *m_rechargeEdit = nullptr;
    QLabel *m_balanceLabel = nullptr;
    QLabel *m_avatarLabel = nullptr;
    QLabel *m_dbInfoLabel = nullptr;
    QTableWidget *m_orderTable = nullptr;
    QPushButton *m_darkModeBtn = nullptr;
};
