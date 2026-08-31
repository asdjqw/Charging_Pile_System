#include "MainWindow.h"
#include "DatabaseManager.h"

#include <QAbstractItemView>
#include <QComboBox>
#include <QDesktopServices>
#include <QDoubleSpinBox>
#include <QFormLayout>
#include <QFrame>
#include <QHBoxLayout>
#include <QHeaderView>
#include <QLabel>
#include <QLineEdit>
#include <QListWidget>
#include <QMessageBox>
#include <QProgressBar>
#include <QPushButton>
#include <QTabWidget>
#include <QTableWidget>
#include <QTimer>
#include <QUrl>
#include <QVBoxLayout>

MainWindow::MainWindow(const User &user, QWidget *parent)
    : QMainWindow(parent)
    , m_user(user)
{
    setWindowTitle(QStringLiteral("充电用户端 - %1").arg(m_user.username));
    resize(480, 820); // 模拟手机竖屏比例
    buildUi();
    refreshStations();
    refreshPilesForCharge();
    refreshProfile();
    refreshOrders();
    refreshOngoingBanner();
}

void MainWindow::buildUi()
{
    auto *central = new QWidget(this);
    setCentralWidget(central);
    auto *root = new QVBoxLayout(central);
    root->setContentsMargins(16, 16, 16, 16);

    auto *header = new QLabel(QStringLiteral("你好，%1").arg(m_user.username), this);
    header->setObjectName(QStringLiteral("titleLabel"));
    auto *sub = new QLabel(QStringLiteral("附近充电站 · 一键导航 · 在线充电 · 个人信息"), this);
    sub->setObjectName(QStringLiteral("subtitleLabel"));
    root->addWidget(header);
    root->addWidget(sub);

    auto *tabs = new QTabWidget(this);
    root->addWidget(tabs, 1);

    // -------- 附近电站 --------
    auto *stationPage = new QWidget(tabs);
    auto *sLayout = new QVBoxLayout(stationPage);
    auto *filterRow = new QHBoxLayout;
    m_stationKeyword = new QLineEdit(stationPage);
    m_stationKeyword->setPlaceholderText(QStringLiteral("搜索站点名称/地址"));
    auto *searchBtn = new QPushButton(QStringLiteral("查询"), stationPage);
    filterRow->addWidget(m_stationKeyword, 1);
    filterRow->addWidget(searchBtn);

    auto *locRow = new QHBoxLayout;
    m_latSpin = new QDoubleSpinBox(stationPage);
    m_lngSpin = new QDoubleSpinBox(stationPage);
    m_latSpin->setRange(-90, 90);
    m_lngSpin->setRange(-180, 180);
    m_latSpin->setDecimals(4);
    m_lngSpin->setDecimals(4);
    m_latSpin->setValue(39.9600);
    m_lngSpin->setValue(116.3600);
    locRow->addWidget(new QLabel(QStringLiteral("我的纬度"), stationPage));
    locRow->addWidget(m_latSpin);
    locRow->addWidget(new QLabel(QStringLiteral("经度"), stationPage));
    locRow->addWidget(m_lngSpin);

    m_stationList = new QListWidget(stationPage);
    auto *navBtn = new QPushButton(QStringLiteral("📍 一键导航"), stationPage);
    m_navInfo = new QLabel(QStringLiteral("选择站点后可发起导航"), stationPage);
    m_navInfo->setWordWrap(true);
    m_navInfo->setObjectName(QStringLiteral("subtitleLabel"));

    sLayout->addLayout(filterRow);
    sLayout->addLayout(locRow);
    sLayout->addWidget(m_stationList, 1);
    sLayout->addWidget(navBtn);
    sLayout->addWidget(m_navInfo);
    tabs->addTab(stationPage, QStringLiteral("附近电站"));

    connect(searchBtn, &QPushButton::clicked, this, &MainWindow::refreshStations);
    connect(navBtn, &QPushButton::clicked, this, &MainWindow::onNavigate);

    // -------- 电动汽车充电 --------
    auto *chargePage = new QWidget(tabs);
    auto *cLayout = new QVBoxLayout(chargePage);
    m_stationCombo = new QComboBox(chargePage);
    m_pileList = new QListWidget(chargePage);
    m_chargeInfo = new QLabel(QStringLiteral("当前无进行中的充电"), chargePage);
    m_chargeInfo->setWordWrap(true);
    m_chargeProgress = new QProgressBar(chargePage);
    m_chargeProgress->setRange(0, 100);
    m_chargeProgress->setValue(0);

    auto *chargeBtnRow = new QHBoxLayout;
    auto *startBtn = new QPushButton(QStringLiteral("开始充电"), chargePage);
    auto *stopBtn = new QPushButton(QStringLiteral("结束充电"), chargePage);
    stopBtn->setObjectName(QStringLiteral("dangerBtn"));
    chargeBtnRow->addWidget(startBtn);
    chargeBtnRow->addWidget(stopBtn);

    cLayout->addWidget(new QLabel(QStringLiteral("选择充电站"), chargePage));
    cLayout->addWidget(m_stationCombo);
    cLayout->addWidget(new QLabel(QStringLiteral("可用充电桩"), chargePage));
    cLayout->addWidget(m_pileList, 1);
    cLayout->addWidget(m_chargeInfo);
    cLayout->addWidget(m_chargeProgress);
    cLayout->addLayout(chargeBtnRow);
    tabs->addTab(chargePage, QStringLiteral("汽车充电"));

    m_chargeTimer = new QTimer(this);
    m_chargeTimer->setInterval(1000);
    connect(m_chargeTimer, &QTimer::timeout, this, &MainWindow::onChargeTick);
    connect(m_stationCombo, QOverload<int>::of(&QComboBox::currentIndexChanged),
            this, &MainWindow::refreshPilesForCharge);
    connect(startBtn, &QPushButton::clicked, this, &MainWindow::onStartCharge);
    connect(stopBtn, &QPushButton::clicked, this, &MainWindow::onStopCharge);

    // -------- 用户信息 --------
    auto *profilePage = new QWidget(tabs);
    auto *pLayout = new QVBoxLayout(profilePage);
    auto *card = new QFrame(profilePage);
    card->setObjectName(QStringLiteral("card"));
    auto *form = new QFormLayout(card);
    m_balanceLabel = new QLabel(profilePage);
    m_phoneEdit = new QLineEdit(profilePage);
    m_carEdit = new QLineEdit(profilePage);
    m_plateEdit = new QLineEdit(profilePage);
    m_pwdEdit = new QLineEdit(profilePage);
    m_pwdEdit->setEchoMode(QLineEdit::Password);
    form->addRow(QStringLiteral("账户余额"), m_balanceLabel);
    form->addRow(QStringLiteral("手机号"), m_phoneEdit);
    form->addRow(QStringLiteral("车型"), m_carEdit);
    form->addRow(QStringLiteral("车牌号"), m_plateEdit);
    form->addRow(QStringLiteral("登录密码"), m_pwdEdit);

    auto *profileBtnRow = new QHBoxLayout;
    auto *saveBtn = new QPushButton(QStringLiteral("保存信息"), profilePage);
    auto *rechargeBtn = new QPushButton(QStringLiteral("余额充值 +50"), profilePage);
    rechargeBtn->setObjectName(QStringLiteral("secondaryBtn"));
    profileBtnRow->addWidget(saveBtn);
    profileBtnRow->addWidget(rechargeBtn);

    m_orderTable = new QTableWidget(profilePage);
    m_orderTable->setColumnCount(5);
    m_orderTable->setHorizontalHeaderLabels({
        QStringLiteral("订单号"), QStringLiteral("站点"), QStringLiteral("电量(kWh)"),
        QStringLiteral("金额"), QStringLiteral("状态")
    });
    m_orderTable->horizontalHeader()->setStretchLastSection(true);
    m_orderTable->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);
    m_orderTable->setEditTriggers(QAbstractItemView::NoEditTriggers);
    m_orderTable->setSelectionBehavior(QAbstractItemView::SelectRows);

    pLayout->addWidget(card);
    pLayout->addLayout(profileBtnRow);
    pLayout->addWidget(new QLabel(QStringLiteral("我的充电记录"), profilePage));
    pLayout->addWidget(m_orderTable, 1);
    tabs->addTab(profilePage, QStringLiteral("个人信息"));

    connect(saveBtn, &QPushButton::clicked, this, &MainWindow::onSaveProfile);
    connect(rechargeBtn, &QPushButton::clicked, this, &MainWindow::onRecharge);
}

void MainWindow::refreshStations()
{
    m_stationList->clear();
    const auto stations = DatabaseManager::instance().listStations(
        m_latSpin->value(), m_lngSpin->value(), m_stationKeyword->text());

    m_stationCombo->blockSignals(true);
    m_stationCombo->clear();
    for (const Station &s : stations) {
        const QString text = QStringLiteral("%1\n%2\n距离约 %3 km · 空闲 %4/%5 · %6 · %7")
                                 .arg(s.name, s.address)
                                 .arg(s.distanceKm, 0, 'f', 2)
                                 .arg(s.idlePiles)
                                 .arg(s.totalPiles)
                                 .arg(statusTextStation(s.status), s.openHours);
        auto *item = new QListWidgetItem(text, m_stationList);
        item->setData(Qt::UserRole, s.id);
        item->setData(Qt::UserRole + 1, s.latitude);
        item->setData(Qt::UserRole + 2, s.longitude);
        item->setData(Qt::UserRole + 3, s.name);
        item->setData(Qt::UserRole + 4, s.address);

        m_stationCombo->addItem(QStringLiteral("%1（空闲%2）").arg(s.name).arg(s.idlePiles), s.id);
    }
    m_stationCombo->blockSignals(false);
}

void MainWindow::onNavigate()
{
    auto *item = m_stationList->currentItem();
    if (!item) {
        QMessageBox::information(this, QStringLiteral("提示"), QStringLiteral("请先选择一个充电站"));
        return;
    }
    const double lat = item->data(Qt::UserRole + 1).toDouble();
    const double lng = item->data(Qt::UserRole + 2).toDouble();
    const QString name = item->data(Qt::UserRole + 3).toString();
    const QString address = item->data(Qt::UserRole + 4).toString();

    m_navInfo->setText(QStringLiteral("导航目标：%1\n地址：%2\n坐标：(%3, %4)\n已生成导航链接（可在浏览器打开地图）。")
                           .arg(name, address)
                           .arg(lat, 0, 'f', 4)
                           .arg(lng, 0, 'f', 4));

    // 使用 OpenStreetMap 目标点（无需商业地图 Key）
    const QUrl url(QStringLiteral("https://www.openstreetmap.org/?mlat=%1&mlon=%2#map=16/%1/%2")
                       .arg(lat, 0, 'f', 6)
                       .arg(lng, 0, 'f', 6));
    QDesktopServices::openUrl(url);
}

int MainWindow::selectedStationId() const
{
    return m_stationCombo->currentData().toInt();
}

int MainWindow::selectedPileId() const
{
    auto *item = m_pileList->currentItem();
    return item ? item->data(Qt::UserRole).toInt() : 0;
}

void MainWindow::refreshPilesForCharge()
{
    m_pileList->clear();
    const int stationId = selectedStationId();
    if (stationId <= 0)
        return;

    const auto piles = DatabaseManager::instance().listPiles(stationId);
    for (const Pile &p : piles) {
        const QString text = QStringLiteral("%1  |  %2  |  %3 kW  |  ¥%4/kWh  |  %5")
                                 .arg(p.pileCode, pileTypeText(p.pileType))
                                 .arg(p.powerKw, 0, 'f', 1)
                                 .arg(p.pricePerKwh, 0, 'f', 2)
                                 .arg(statusTextPile(p.status));
        auto *item = new QListWidgetItem(text, m_pileList);
        item->setData(Qt::UserRole, p.id);
        item->setData(Qt::UserRole + 1, p.pricePerKwh);
        item->setData(Qt::UserRole + 2, p.powerKw);
        item->setData(Qt::UserRole + 3, p.status);
        if (p.status != "idle")
            item->setFlags(item->flags() & ~Qt::ItemIsEnabled);
    }
}

void MainWindow::refreshOngoingBanner()
{
    ChargingOrder order;
    if (DatabaseManager::instance().getOngoingOrderByUser(m_user.id, order)) {
        m_ongoing = order;
        Pile pile;
        if (DatabaseManager::instance().getPile(order.pileId, pile)) {
            m_currentPrice = pile.pricePerKwh;
            m_currentPowerKw = pile.powerKw;
        }
        if (!m_chargeTimer->isActive()) {
            m_simulatedEnergy = order.energyKwh;
            m_chargeTimer->start();
        }
        m_chargeInfo->setText(QStringLiteral("充电中：%1 / %2\n订单 %3\n已充电 %4 kWh，预估费用 ¥%5")
                                  .arg(order.stationName, order.pileCode, order.orderNo)
                                  .arg(m_simulatedEnergy, 0, 'f', 2)
                                  .arg(m_simulatedEnergy * m_currentPrice, 0, 'f', 2));
        m_chargeProgress->setValue(qMin(100, int(m_simulatedEnergy * 2)));
    } else {
        m_ongoing = ChargingOrder{};
        m_chargeTimer->stop();
        m_simulatedEnergy = 0;
        m_chargeProgress->setValue(0);
        m_chargeInfo->setText(QStringLiteral("当前无进行中的充电，选择空闲桩后点击“开始充电”"));
    }
}

void MainWindow::onStartCharge()
{
    const int pileId = selectedPileId();
    if (pileId <= 0) {
        QMessageBox::information(this, QStringLiteral("提示"), QStringLiteral("请选择一个空闲充电桩"));
        return;
    }

    ChargingOrder order;
    if (!DatabaseManager::instance().startCharging(m_user.id, pileId, order)) {
        QMessageBox::warning(this, QStringLiteral("无法开始充电"),
                             DatabaseManager::instance().lastError());
        return;
    }

    auto *item = m_pileList->currentItem();
    m_currentPrice = item ? item->data(Qt::UserRole + 1).toDouble() : 1.2;
    m_currentPowerKw = item ? item->data(Qt::UserRole + 2).toDouble() : 7.0;
    m_ongoing = order;
    m_simulatedEnergy = 0;
    m_chargeTimer->start();
    refreshPilesForCharge();
    refreshOngoingBanner();
    QMessageBox::information(this, QStringLiteral("已开始充电"),
                             QStringLiteral("订单号：%1\n请保持车辆连接，结束后点击“结束充电”。")
                                 .arg(order.orderNo));
}

void MainWindow::onChargeTick()
{
    if (m_ongoing.id <= 0)
        return;
    // 按功率粗略模拟：每秒增加 powerKw / 3600 kWh
    m_simulatedEnergy += m_currentPowerKw / 3600.0;
    const double fee = m_simulatedEnergy * m_currentPrice;
    m_chargeInfo->setText(QStringLiteral("充电中：%1 / %2\n订单 %3\n已充电 %4 kWh，预估费用 ¥%5")
                              .arg(m_ongoing.stationName, m_ongoing.pileCode, m_ongoing.orderNo)
                              .arg(m_simulatedEnergy, 0, 'f', 3)
                              .arg(fee, 0, 'f', 2));
    m_chargeProgress->setValue(qMin(100, int(m_simulatedEnergy * 3)));
}

void MainWindow::onStopCharge()
{
    if (m_ongoing.id <= 0) {
        QMessageBox::information(this, QStringLiteral("提示"), QStringLiteral("当前没有进行中的充电"));
        return;
    }

    // 演示友好：至少记 0.5 kWh，避免刚开始就结束时金额为 0
    const double energy = qMax(0.5, m_simulatedEnergy);
    ChargingOrder finished;
    if (!DatabaseManager::instance().stopCharging(m_ongoing.id, energy, finished)) {
        QMessageBox::warning(this, QStringLiteral("结束失败"),
                             DatabaseManager::instance().lastError());
        return;
    }

    m_chargeTimer->stop();
    m_ongoing = ChargingOrder{};
    DatabaseManager::instance().getUserById(m_user.id, m_user);
    refreshPilesForCharge();
    refreshOngoingBanner();
    refreshProfile();
    refreshOrders();

    QMessageBox::information(this, QStringLiteral("充电完成"),
                             QStringLiteral("订单 %1 已结算\n电量 %2 kWh\n费用 ¥%3\n当前余额 ¥%4")
                                 .arg(finished.orderNo)
                                 .arg(finished.energyKwh, 0, 'f', 2)
                                 .arg(finished.amount, 0, 'f', 2)
                                 .arg(m_user.balance, 0, 'f', 2));
}

void MainWindow::refreshProfile()
{
    DatabaseManager::instance().getUserById(m_user.id, m_user);
    m_balanceLabel->setText(QStringLiteral("¥ %1").arg(m_user.balance, 0, 'f', 2));
    m_phoneEdit->setText(m_user.phone);
    m_carEdit->setText(m_user.carModel);
    m_plateEdit->setText(m_user.plateNumber);
    m_pwdEdit->setText(m_user.password);
}

void MainWindow::onSaveProfile()
{
    m_user.phone = m_phoneEdit->text().trimmed();
    m_user.carModel = m_carEdit->text().trimmed();
    m_user.plateNumber = m_plateEdit->text().trimmed();
    m_user.password = m_pwdEdit->text();
    if (!DatabaseManager::instance().updateUser(m_user)) {
        QMessageBox::warning(this, QStringLiteral("保存失败"),
                             DatabaseManager::instance().lastError());
        return;
    }
    QMessageBox::information(this, QStringLiteral("成功"), QStringLiteral("个人信息已更新"));
}

void MainWindow::onRecharge()
{
    if (!DatabaseManager::instance().rechargeUser(m_user.id, 50.0)) {
        QMessageBox::warning(this, QStringLiteral("充值失败"),
                             DatabaseManager::instance().lastError());
        return;
    }
    refreshProfile();
    QMessageBox::information(this, QStringLiteral("充值成功"), QStringLiteral("已充值 ¥50"));
}

void MainWindow::refreshOrders()
{
    const auto orders = DatabaseManager::instance().listOrders(m_user.id);
    m_orderTable->setRowCount(orders.size());
    for (int i = 0; i < orders.size(); ++i) {
        const auto &o = orders[i];
        m_orderTable->setItem(i, 0, new QTableWidgetItem(o.orderNo));
        m_orderTable->setItem(i, 1, new QTableWidgetItem(o.stationName));
        m_orderTable->setItem(i, 2, new QTableWidgetItem(QString::number(o.energyKwh, 'f', 2)));
        m_orderTable->setItem(i, 3, new QTableWidgetItem(QString::number(o.amount, 'f', 2)));
        m_orderTable->setItem(i, 4, new QTableWidgetItem(statusTextOrder(o.status)));
    }
}
