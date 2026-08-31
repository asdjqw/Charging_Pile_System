#pragma once

#include "Models.h"

#include <QMainWindow>

class QLabel;
class QLineEdit;
class QListWidget;
class QComboBox;
class QProgressBar;
class QTableWidget;
class QTimer;
class QDoubleSpinBox;

class MainWindow : public QMainWindow
{
    Q_OBJECT
public:
    explicit MainWindow(const User &user, QWidget *parent = nullptr);

private slots:
    void refreshStations();
    void onNavigate();
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
    void refreshOngoingBanner();
    int selectedStationId() const;
    int selectedPileId() const;

    User m_user;

    // 附近电站
    QLineEdit *m_stationKeyword = nullptr;
    QDoubleSpinBox *m_latSpin = nullptr;
    QDoubleSpinBox *m_lngSpin = nullptr;
    QListWidget *m_stationList = nullptr;
    QLabel *m_navInfo = nullptr;

    // 充电
    QComboBox *m_stationCombo = nullptr;
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
    QLabel *m_balanceLabel = nullptr;
    QTableWidget *m_orderTable = nullptr;
};
