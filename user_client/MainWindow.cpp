#include "MainWindow.h"
#include "DatabaseManager.h"
#include "LocationProvider.h"

#include <QAbstractItemView>
#include <QComboBox>
#include <QDesktopServices>
#include <QFormLayout>
#include <QFrame>
#include <QHBoxLayout>
#include <QHeaderView>
#include <QLabel>
#include <QLineEdit>
#include <QListWidget>
#include <QMap>
#include <QMessageBox>
#include <QProgressBar>
#include <QPushButton>
#include <QStackedWidget>
#include <QTableWidget>
#include <QTimer>
#include <QUrl>
#include <QVBoxLayout>

namespace {

QPair<double, double> realDistrictCoords(const QString &region)
{
    // 北京市各区政府/中心点真实大致坐标（WGS84/GCJ02 近似）
    static const QMap<QString, QPair<double, double>> kMap = {
        {QStringLiteral("东城区"), {39.9289, 116.4164}},
        {QStringLiteral("西城区"), {39.9123, 116.3668}},
        {QStringLiteral("朝阳区"), {39.9219, 116.4436}},
        {QStringLiteral("海淀区"), {39.9593, 116.2983}},
        {QStringLiteral("丰台区"), {39.8585, 116.2869}},
        {QStringLiteral("石景山区"), {39.9066, 116.2230}},
        {QStringLiteral("通州区"), {39.9097, 116.6564}},
        {QStringLiteral("大兴区"), {39.7269, 116.3414}},
        {QStringLiteral("昌平区"), {40.2207, 116.2312}},
        {QStringLiteral("顺义区"), {40.1289, 116.6547}},
        {QStringLiteral("房山区"), {39.7355, 116.1392}},
        {QStringLiteral("门头沟区"), {39.9375, 116.1023}},
        {QStringLiteral("怀柔区"), {40.3160, 116.6371}},
        {QStringLiteral("平谷区"), {40.1440, 117.1123}},
        {QStringLiteral("密云区"), {40.3771, 116.8433}},
        {QStringLiteral("延庆区"), {40.4569, 115.9850}},
        {QStringLiteral("天安门"), {39.9042, 116.4074}},
        {QStringLiteral("国贸"), {39.9087, 116.4595}},
        {QStringLiteral("望京"), {39.9965, 116.4803}},
        {QStringLiteral("中关村"), {39.9836, 116.3164}},
        {QStringLiteral("三里屯"), {39.9339, 116.4551}},
    };
    for (auto it = kMap.constBegin(); it != kMap.constEnd(); ++it) {
        if (region.contains(it.key()))
            return it.value();
    }
    return {39.9042, 116.4074};
}

} // namespace

MainWindow::MainWindow(const User &user, QWidget *parent)
    : QMainWindow(parent)
    , m_user(user)
{
    setWindowTitle(QStringLiteral("电动汽车充电 - %1").arg(m_user.username));
    resize(420, 780);
    setMinimumSize(380, 640);
    setMaximumWidth(480);

    m_locationProvider = new LocationProvider(this);
    connect(m_locationProvider, &LocationProvider::locationUpdated,
            this, &MainWindow::onRealLocationUpdated);
    connect(m_locationProvider, &LocationProvider::locationFailed,
            this, &MainWindow::onRealLocationFailed);

    buildUi();
    refreshStations();
    refreshPilesForCharge();
    refreshProfile();
    refreshOrders();
    refreshOngoingBanner();
    // 启动后自动检测真实当前位置
    QTimer::singleShot(300, this, &MainWindow::requestRealLocation);
}

void MainWindow::buildUi()
{
    auto *central = new QWidget(this);
    central->setObjectName(QStringLiteral("centralRoot"));
    setCentralWidget(central);
    auto *root = new QVBoxLayout(central);
    root->setContentsMargins(0, 0, 0, 0);
    root->setSpacing(0);

    m_tabStack = new QStackedWidget(central);
    m_tabStack->addWidget(buildStationsPage());
    m_tabStack->addWidget(buildChargePage());
    m_tabStack->addWidget(buildProfilePage());
    root->addWidget(m_tabStack, 1);
    root->addWidget(buildBottomNav());
}

QWidget *MainWindow::buildBottomNav()
{
    auto *bar = new QWidget(this);
    bar->setFixedHeight(58);
    bar->setStyleSheet(QStringLiteral("background:white; border-top:1px solid #BAE6FD;"));
    auto *layout = new QHBoxLayout(bar);
    layout->setContentsMargins(0, 0, 0, 0);
    layout->setSpacing(0);

    m_navStations = new QPushButton(QStringLiteral("充电站"), bar);
    m_navCharge = new QPushButton(QStringLiteral("充电"), bar);
    m_navProfile = new QPushButton(QStringLiteral("我的"), bar);
    for (auto *btn : {m_navStations, m_navCharge, m_navProfile}) {
        btn->setFlat(true);
        btn->setMinimumHeight(58);
        btn->setStyleSheet(QStringLiteral("border:none; background:white; color:#64748B; font-size:14px;"));
        layout->addWidget(btn, 1);
    }
    m_navStations->setStyleSheet(QStringLiteral("border:none; background:white; color:#0284C7; font-weight:700; font-size:14px;"));

    connect(m_navStations, &QPushButton::clicked, this, [this]() { onBottomNav(0); });
    connect(m_navCharge, &QPushButton::clicked, this, [this]() { onBottomNav(1); });
    connect(m_navProfile, &QPushButton::clicked, this, [this]() { onBottomNav(2); });
    return bar;
}

void MainWindow::onBottomNav(int index)
{
    m_tabStack->setCurrentIndex(index);
    auto style = [](bool on) {
        return on ? QStringLiteral("border:none; background:white; color:#0284C7; font-weight:700; font-size:14px;")
                  : QStringLiteral("border:none; background:white; color:#64748B; font-size:14px;");
    };
    m_navStations->setStyleSheet(style(index == 0));
    m_navCharge->setStyleSheet(style(index == 1));
    m_navProfile->setStyleSheet(style(index == 2));
    if (index == 0) refreshStations();
    if (index == 1) {
        refreshPilesForCharge();
        refreshOngoingBanner();
    }
    if (index == 2) {
        refreshProfile();
        refreshOrders();
    }
}

QWidget *MainWindow::buildStationsPage()
{
    auto *page = new QWidget(this);
    auto *layout = new QVBoxLayout(page);
    layout->setContentsMargins(16, 20, 16, 8);
    layout->setSpacing(10);

    auto *header = new QLabel(QStringLiteral("附近充电站"), page);
    header->setObjectName(QStringLiteral("pageTitle"));
    m_countLabel = new QLabel(QStringLiteral("正在加载…"), page);
    m_countLabel->setObjectName(QStringLiteral("muted"));

    m_regionCombo = new QComboBox(page);
    m_regionCombo->addItem(QStringLiteral("全部区域"));
    for (const QString &d : DatabaseManager::instance().districts())
        m_regionCombo->addItem(d);

    m_addressEdit = new QLineEdit(page);
    m_addressEdit->setPlaceholderText(QStringLiteral("也可手动输入地址，如：国贸 / 中关村"));
    m_locateBtn = new QPushButton(QStringLiteral("检测当前位置"), page);
    m_locateBtn->setObjectName(QStringLiteral("secondaryBtn"));

    auto *filterRow = new QHBoxLayout;
    filterRow->addWidget(m_regionCombo, 1);
    filterRow->addWidget(m_addressEdit, 2);
    filterRow->addWidget(m_locateBtn);

    m_stationKeyword = new QLineEdit(page);
    m_stationKeyword->setPlaceholderText(QStringLiteral("搜索站点名称/地址"));
    auto *searchBtn = new QPushButton(QStringLiteral("查询"), page);

    auto *searchRow = new QHBoxLayout;
    searchRow->addWidget(m_stationKeyword, 1);
    searchRow->addWidget(searchBtn);

    m_locationLabel = new QLabel(page);
    m_locationLabel->setObjectName(QStringLiteral("muted"));
    m_locationLabel->setWordWrap(true);

    m_stationList = new QListWidget(page);
    m_loadMoreBtn = new QPushButton(QStringLiteral("加载更多附近站点"), page);
    m_loadMoreBtn->setObjectName(QStringLiteral("secondaryBtn"));
    m_loadMoreBtn->hide();

    auto *navBtn = new QPushButton(QStringLiteral("高德地图导航"), page);
    m_navInfo = new QLabel(QStringLiteral("选择站点后可发起导航"), page);
    m_navInfo->setObjectName(QStringLiteral("muted"));
    m_navInfo->setWordWrap(true);

    layout->addWidget(header);
    layout->addWidget(m_countLabel);
    layout->addLayout(filterRow);
    layout->addLayout(searchRow);
    layout->addWidget(m_locationLabel);
    layout->addWidget(m_stationList, 1);
    layout->addWidget(m_loadMoreBtn);
    layout->addWidget(navBtn);
    layout->addWidget(m_navInfo);

    connect(m_locateBtn, &QPushButton::clicked, this, &MainWindow::onLocate);
    connect(m_addressEdit, &QLineEdit::returnPressed, this, &MainWindow::onLocate);
    connect(searchBtn, &QPushButton::clicked, this, &MainWindow::refreshStations);
    connect(m_stationKeyword, &QLineEdit::returnPressed, this, &MainWindow::refreshStations);
    connect(m_regionCombo, &QComboBox::currentTextChanged, this, &MainWindow::onRegionChanged);
    connect(m_loadMoreBtn, &QPushButton::clicked, this, &MainWindow::loadMoreStations);
    connect(navBtn, &QPushButton::clicked, this, &MainWindow::onNavigate);
    return page;
}

QWidget *MainWindow::buildChargePage()
{
    auto *page = new QWidget(this);
    auto *layout = new QVBoxLayout(page);
    layout->setContentsMargins(16, 20, 16, 8);
    layout->setSpacing(10);

    auto *header = new QLabel(QStringLiteral("汽车充电"), page);
    header->setObjectName(QStringLiteral("pageTitle"));

    m_stationCombo = new QComboBox(page);
    m_speedFilter = new QComboBox(page);
    m_speedFilter->addItem(QStringLiteral("全部速度"), QString());
    m_speedFilter->addItem(QStringLiteral("慢充"), QStringLiteral("slow"));
    m_speedFilter->addItem(QStringLiteral("常规"), QStringLiteral("standard"));
    m_speedFilter->addItem(QStringLiteral("快充"), QStringLiteral("fast"));
    m_speedFilter->addItem(QStringLiteral("超充"), QStringLiteral("ultra"));

    m_connectorFilter = new QComboBox(page);
    m_connectorFilter->addItem(QStringLiteral("全部接口"), QString());
    m_connectorFilter->addItem(QStringLiteral("国标交流"), QStringLiteral("GB_T_AC"));
    m_connectorFilter->addItem(QStringLiteral("国标直流"), QStringLiteral("GB_T_DC"));
    m_connectorFilter->addItem(QStringLiteral("CCS2"), QStringLiteral("CCS2"));
    m_connectorFilter->addItem(QStringLiteral("CHAdeMO"), QStringLiteral("CHAdeMO"));
    m_connectorFilter->addItem(QStringLiteral("特斯拉NACS"), QStringLiteral("TeslaNACS"));

    auto *filterRow = new QHBoxLayout;
    filterRow->addWidget(m_speedFilter, 1);
    filterRow->addWidget(m_connectorFilter, 1);

    m_pileList = new QListWidget(page);
    m_chargeInfo = new QLabel(QStringLiteral("当前无进行中的充电"), page);
    m_chargeInfo->setWordWrap(true);
    m_chargeProgress = new QProgressBar(page);
    m_chargeProgress->setRange(0, 100);
    m_chargeProgress->setValue(0);

    auto *chargeBtnRow = new QHBoxLayout;
    auto *startBtn = new QPushButton(QStringLiteral("开始充电"), page);
    auto *stopBtn = new QPushButton(QStringLiteral("结束充电"), page);
    stopBtn->setObjectName(QStringLiteral("dangerBtn"));
    chargeBtnRow->addWidget(startBtn);
    chargeBtnRow->addWidget(stopBtn);

    layout->addWidget(header);
    layout->addWidget(new QLabel(QStringLiteral("选择充电站"), page));
    layout->addWidget(m_stationCombo);
    layout->addWidget(new QLabel(QStringLiteral("按分类筛选电桩"), page));
    layout->addLayout(filterRow);
    layout->addWidget(m_pileList, 1);
    layout->addWidget(m_chargeInfo);
    layout->addWidget(m_chargeProgress);
    layout->addLayout(chargeBtnRow);

    m_chargeTimer = new QTimer(this);
    m_chargeTimer->setInterval(1000);
    connect(m_chargeTimer, &QTimer::timeout, this, &MainWindow::onChargeTick);
    connect(m_stationCombo, QOverload<int>::of(&QComboBox::currentIndexChanged),
            this, &MainWindow::refreshPilesForCharge);
    connect(m_speedFilter, QOverload<int>::of(&QComboBox::currentIndexChanged),
            this, &MainWindow::refreshPilesForCharge);
    connect(m_connectorFilter, QOverload<int>::of(&QComboBox::currentIndexChanged),
            this, &MainWindow::refreshPilesForCharge);
    connect(startBtn, &QPushButton::clicked, this, &MainWindow::onStartCharge);
    connect(stopBtn, &QPushButton::clicked, this, &MainWindow::onStopCharge);
    return page;
}

QWidget *MainWindow::buildProfilePage()
{
    auto *page = new QWidget(this);
    auto *layout = new QVBoxLayout(page);
    layout->setContentsMargins(16, 20, 16, 8);
    layout->setSpacing(12);

    auto *header = new QLabel(QStringLiteral("我的"), page);
    header->setObjectName(QStringLiteral("pageTitle"));

    auto *card = new QFrame(page);
    card->setObjectName(QStringLiteral("card"));
    auto *form = new QFormLayout(card);
    form->setContentsMargins(14, 14, 14, 14);
    m_balanceLabel = new QLabel(page);
    m_balanceLabel->setStyleSheet(QStringLiteral("color:#F97316; font-size:16px; font-weight:700;"));
    m_phoneEdit = new QLineEdit(page);
    m_carEdit = new QLineEdit(page);
    m_plateEdit = new QLineEdit(page);
    m_pwdEdit = new QLineEdit(page);
    m_pwdEdit->setEchoMode(QLineEdit::Password);
    form->addRow(QStringLiteral("账户余额"), m_balanceLabel);
    form->addRow(QStringLiteral("手机号"), m_phoneEdit);
    form->addRow(QStringLiteral("车型"), m_carEdit);
    form->addRow(QStringLiteral("车牌号"), m_plateEdit);
    form->addRow(QStringLiteral("登录密码"), m_pwdEdit);

    auto *saveBtn = new QPushButton(QStringLiteral("保存信息"), page);

    auto *walletCard = new QFrame(page);
    walletCard->setObjectName(QStringLiteral("card"));
    auto *walletLayout = new QVBoxLayout(walletCard);
    walletLayout->setContentsMargins(14, 14, 14, 14);
    walletLayout->addWidget(new QLabel(QStringLiteral("钱包充值"), walletCard));
    m_rechargeEdit = new QLineEdit(walletCard);
    m_rechargeEdit->setPlaceholderText(QStringLiteral("输入充值金额（元），如 100"));
    auto *rechargeBtn = new QPushButton(QStringLiteral("充值（模拟支付）"), walletCard);
    rechargeBtn->setObjectName(QStringLiteral("successBtn"));
    auto *quickRow = new QHBoxLayout;
    for (int amt : {50, 100, 200, 500}) {
        auto *qbtn = new QPushButton(QStringLiteral("+%1").arg(amt), walletCard);
        qbtn->setObjectName(QStringLiteral("secondaryBtn"));
        connect(qbtn, &QPushButton::clicked, this, [this, amt]() {
            m_rechargeEdit->setText(QString::number(amt));
        });
        quickRow->addWidget(qbtn);
    }
    walletLayout->addWidget(m_rechargeEdit);
    walletLayout->addLayout(quickRow);
    walletLayout->addWidget(rechargeBtn);

    m_orderTable = new QTableWidget(page);
    m_orderTable->setColumnCount(5);
    m_orderTable->setHorizontalHeaderLabels({
        QStringLiteral("订单号"), QStringLiteral("站点"), QStringLiteral("电量"),
        QStringLiteral("金额"), QStringLiteral("状态")
    });
    m_orderTable->horizontalHeader()->setStretchLastSection(true);
    m_orderTable->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);
    m_orderTable->setEditTriggers(QAbstractItemView::NoEditTriggers);
    m_orderTable->setSelectionBehavior(QAbstractItemView::SelectRows);

    m_dbInfoLabel = new QLabel(page);
    m_dbInfoLabel->setObjectName(QStringLiteral("muted"));
    m_dbInfoLabel->setWordWrap(true);

    layout->addWidget(header);
    layout->addWidget(card);
    layout->addWidget(saveBtn);
    layout->addWidget(walletCard);
    layout->addWidget(new QLabel(QStringLiteral("我的充电记录"), page));
    layout->addWidget(m_orderTable, 1);
    layout->addWidget(m_dbInfoLabel);

    connect(saveBtn, &QPushButton::clicked, this, &MainWindow::onSaveProfile);
    connect(rechargeBtn, &QPushButton::clicked, this, &MainWindow::onRecharge);
    return page;
}

void MainWindow::applyUserLocation(const QString &regionOrAddress)
{
    const auto coords = realDistrictCoords(regionOrAddress);
    m_userLat = coords.first;
    m_userLng = coords.second;
    if (regionOrAddress.trimmed().isEmpty())
        m_userAddress = QStringLiteral("北京市东城区天安门");
    else if (regionOrAddress.startsWith(QStringLiteral("北京")))
        m_userAddress = regionOrAddress;
    else
        m_userAddress = QStringLiteral("北京市%1").arg(regionOrAddress);
}

void MainWindow::onRegionChanged()
{
    const QString region = m_regionCombo->currentText();
    if (region != QStringLiteral("全部区域"))
        applyUserLocation(region);
    refreshStations();
}

void MainWindow::requestRealLocation()
{
    if (m_locateBtn) {
        m_locateBtn->setEnabled(false);
        m_locateBtn->setText(QStringLiteral("定位中…"));
    }
    m_locationLabel->setText(QStringLiteral("正在检测真实当前位置…"));
    m_locationProvider->requestCurrentLocation();
}

void MainWindow::onRealLocationUpdated(double lat, double lng, const QString &label, const QString &source)
{
    m_userLat = lat;
    m_userLng = lng;
    m_userAddress = label;
    m_locationSource = source;
    if (m_locateBtn) {
        m_locateBtn->setEnabled(true);
        m_locateBtn->setText(QStringLiteral("检测当前位置"));
    }
    refreshStations();
}

void MainWindow::onRealLocationFailed(const QString &reason)
{
    if (m_locateBtn) {
        m_locateBtn->setEnabled(true);
        m_locateBtn->setText(QStringLiteral("检测当前位置"));
    }
    // 失败时保留上次坐标，并提示可手动输入
    m_locationLabel->setText(QStringLiteral("%1（可手动输入地址后回车）").arg(reason));
    if (m_locationSource == QLatin1String("pending")) {
        applyUserLocation(QStringLiteral("天安门"));
        m_locationSource = QStringLiteral("fallback");
        refreshStations();
    }
}

void MainWindow::onLocate()
{
    const QString address = m_addressEdit->text().trimmed();
    if (!address.isEmpty()) {
        // 有手动地址时按地址/地标解析；否则检测真实当前位置
        applyUserLocation(address);
        m_locationSource = QStringLiteral("manual");
        refreshStations();
        return;
    }
    requestRealLocation();
}

void MainWindow::refreshStations()
{
    const QString sourceText = (m_locationSource == QLatin1String("GeoClue"))
                                   ? QStringLiteral("系统定位")
                                   : (m_locationSource == QLatin1String("IP"))
                                         ? QStringLiteral("IP定位")
                                         : (m_locationSource == QLatin1String("manual"))
                                               ? QStringLiteral("手动")
                                               : QStringLiteral("默认");
    m_locationLabel->setText(QStringLiteral("当前位置[%1]：%2（%3, %4）")
                                 .arg(sourceText, m_userAddress)
                                 .arg(m_userLat, 0, 'f', 5)
                                 .arg(m_userLng, 0, 'f', 5));

    const QString region = m_regionCombo->currentText();
    const QString district = (region == QStringLiteral("全部区域")) ? QString() : region;

    m_cachedStations = DatabaseManager::instance().listStations(
        m_userLat, m_userLng, m_stationKeyword->text(), district, 120);
    m_visibleCount = qMin(20, m_cachedStations.size());

    m_stationList->clear();
    m_stationCombo->blockSignals(true);
    m_stationCombo->clear();
    for (int i = 0; i < m_cachedStations.size(); ++i) {
        const Station &s = m_cachedStations[i];
        m_stationCombo->addItem(
            QStringLiteral("%1（空闲%2/%3）").arg(s.name).arg(s.idlePiles).arg(s.totalPiles), s.id);
        if (i >= m_visibleCount)
            continue;
        const QString text = QStringLiteral("%1\n%2 · %3\n距离 %4 km · 空闲 %5/%6 · %7")
                                 .arg(s.name, s.regionCode, s.address)
                                 .arg(s.distanceKm, 0, 'f', 2)
                                 .arg(s.idlePiles)
                                 .arg(s.totalPiles)
                                 .arg(statusTextStation(s.status));
        auto *item = new QListWidgetItem(text, m_stationList);
        item->setData(Qt::UserRole, s.id);
        item->setData(Qt::UserRole + 1, s.latitude);
        item->setData(Qt::UserRole + 2, s.longitude);
        item->setData(Qt::UserRole + 3, s.name);
        item->setData(Qt::UserRole + 4, s.address);
    }
    m_stationCombo->blockSignals(false);

    const int total = DatabaseManager::instance().stationCount();
    const int piles = DatabaseManager::instance().pileCount();
    m_countLabel->setText(QStringLiteral("显示附近 %1 / 本批 %2 站（库内 %3 站 · %4 桩）")
                              .arg(m_visibleCount)
                              .arg(m_cachedStations.size())
                              .arg(total)
                              .arg(piles));
    m_loadMoreBtn->setVisible(m_visibleCount < m_cachedStations.size());
    refreshPilesForCharge();
}

void MainWindow::loadMoreStations()
{
    const int old = m_visibleCount;
    m_visibleCount = qMin(m_visibleCount + 20, m_cachedStations.size());
    for (int i = old; i < m_visibleCount; ++i) {
        const Station &s = m_cachedStations[i];
        const QString text = QStringLiteral("%1\n%2 · %3\n距离 %4 km · 空闲 %5/%6 · %7")
                                 .arg(s.name, s.regionCode, s.address)
                                 .arg(s.distanceKm, 0, 'f', 2)
                                 .arg(s.idlePiles)
                                 .arg(s.totalPiles)
                                 .arg(statusTextStation(s.status));
        auto *item = new QListWidgetItem(text, m_stationList);
        item->setData(Qt::UserRole, s.id);
        item->setData(Qt::UserRole + 1, s.latitude);
        item->setData(Qt::UserRole + 2, s.longitude);
        item->setData(Qt::UserRole + 3, s.name);
        item->setData(Qt::UserRole + 4, s.address);
    }
    m_countLabel->setText(QStringLiteral("显示附近 %1 / 本批 %2 站（库内 %3 站 · %4 桩）")
                              .arg(m_visibleCount)
                              .arg(m_cachedStations.size())
                              .arg(DatabaseManager::instance().stationCount())
                              .arg(DatabaseManager::instance().pileCount()));
    m_loadMoreBtn->setVisible(m_visibleCount < m_cachedStations.size());
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

    m_navInfo->setText(QStringLiteral("导航目标：%1\n%2\n坐标：（%3, %4）")
                           .arg(name, address)
                           .arg(lat, 0, 'f', 6)
                           .arg(lng, 0, 'f', 6));

    const QUrl url(QStringLiteral(
                       "https://uri.amap.com/navigation?from=%1,%2,%3&to=%4,%5,%6"
                       "&mode=car&policy=1&src=charging-app&coordinate=gaode&callnative=0")
                       .arg(QString::number(m_userLng, 'f', 6),
                            QString::number(m_userLat, 'f', 6),
                            QUrl::toPercentEncoding(m_userAddress),
                            QString::number(lng, 'f', 6),
                            QString::number(lat, 'f', 6),
                            QUrl::toPercentEncoding(name)));
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

    const QString speed = m_speedFilter->currentData().toString();
    const QString connector = m_connectorFilter->currentData().toString();
    const auto piles = DatabaseManager::instance().listPiles(stationId, QString(), speed, connector);
    for (const Pile &p : piles) {
        const QString text = QStringLiteral("%1\n%2\n%3 kW · ¥%4/kWh · %5")
                                 .arg(p.pileCode, pileCategoryText(p))
                                 .arg(p.powerKw, 0, 'f', 1)
                                 .arg(p.pricePerKwh, 0, 'f', 2)
                                 .arg(statusTextPile(p.status));
        auto *item = new QListWidgetItem(text, m_pileList);
        item->setData(Qt::UserRole, p.id);
        item->setData(Qt::UserRole + 1, p.pricePerKwh);
        item->setData(Qt::UserRole + 2, p.powerKw);
        item->setData(Qt::UserRole + 3, p.status);
        if (p.status != QLatin1String("idle"))
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
        m_chargeInfo->setText(QStringLiteral("充电中：%1 / %2\n订单 %3\n已充电 %4 kWh，预估 ¥%5")
                                  .arg(order.stationName, order.pileCode, order.orderNo)
                                  .arg(m_simulatedEnergy, 0, 'f', 2)
                                  .arg(m_simulatedEnergy * m_currentPrice, 0, 'f', 2));
        m_chargeProgress->setValue(qMin(100, int(m_simulatedEnergy * 2)));
    } else {
        m_ongoing = ChargingOrder{};
        m_chargeTimer->stop();
        m_simulatedEnergy = 0;
        m_chargeProgress->setValue(0);
        m_chargeInfo->setText(QStringLiteral("当前无进行中的充电，可按分类筛选空闲桩后开始"));
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
                             QStringLiteral("订单号：%1").arg(order.orderNo));
}

void MainWindow::onChargeTick()
{
    if (m_ongoing.id <= 0)
        return;
    m_simulatedEnergy += m_currentPowerKw / 3600.0;
    const double fee = m_simulatedEnergy * m_currentPrice;
    m_chargeInfo->setText(QStringLiteral("充电中：%1 / %2\n订单 %3\n已充电 %4 kWh，预估 ¥%5")
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
                             QStringLiteral("订单 %1 已结算\n电量 %2 kWh\n费用 ¥%3\n余额 ¥%4")
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
    m_dbInfoLabel->setText(QStringLiteral("本地库 %1 站 / %2 桩\n%3")
                               .arg(DatabaseManager::instance().stationCount())
                               .arg(DatabaseManager::instance().pileCount())
                               .arg(DatabaseManager::instance().databasePath()));
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
    bool ok = false;
    const double amount = m_rechargeEdit->text().trimmed().toDouble(&ok);
    if (!ok || amount <= 0) {
        QMessageBox::warning(this, QStringLiteral("提示"), QStringLiteral("请输入有效的充值金额"));
        return;
    }
    if (!DatabaseManager::instance().rechargeUser(m_user.id, amount)) {
        QMessageBox::warning(this, QStringLiteral("充值失败"),
                             DatabaseManager::instance().lastError());
        return;
    }
    m_rechargeEdit->clear();
    refreshProfile();
    QMessageBox::information(this, QStringLiteral("充值成功"),
                             QStringLiteral("已充值 ¥%1").arg(amount, 0, 'f', 2));
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
