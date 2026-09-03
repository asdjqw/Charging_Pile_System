#include "MainWindow.h"
#include "ServerApiClient.h"
#include "LocationProvider.h"
#include "StyleHelper.h"

#include <QAbstractItemView>
#include <QApplication>
#include <QCheckBox>
#include <QComboBox>
#include <QDateTime>
#include <QDesktopServices>
#include <QFileDialog>
#include <QFormLayout>
#include <QFrame>
#include <QGridLayout>
#include <QHBoxLayout>
#include <QHeaderView>
#include <QLabel>
#include <QLineEdit>
#include <QListWidget>
#include <QMap>
#include <QMessageBox>
#include <QProgressBar>
#include <QPixmap>
#include <QPushButton>
#include <QScrollArea>
#include <QSettings>
#include <QSizePolicy>
#include <QStackedWidget>
#include <QStatusBar>
#include <QStyle>
#include <QTableWidget>
#include <QTimer>
#include <QUrl>
#include <QUrlQuery>
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
    setWindowTitle(QStringLiteral("充电用户端 - %1").arg(m_user.username));
    resize(400, 700);
    setMinimumSize(360, 620);
    setMaximumWidth(440);

    m_locationProvider = new LocationProvider(this);
    connect(m_locationProvider, &LocationProvider::locationUpdated,
            this, &MainWindow::onRealLocationUpdated);
    connect(m_locationProvider, &LocationProvider::locationFailed,
            this, &MainWindow::onRealLocationFailed);

    QSettings settings;
    m_darkMode = settings.value(QStringLiteral("ui/darkMode"), false).toBool();
    applyTheme(m_darkMode);

    loadFavorites();
    buildUi();
    statusBar()->showMessage(QStringLiteral("已登录"));

    refreshStations();
    refreshPilesForCharge();
    refreshProfile();
    refreshOrders();
    refreshOngoingBanner();
    updateReservationCountdown();

    m_reservationTimer = new QTimer(this);
    m_reservationTimer->setInterval(1000);
    connect(m_reservationTimer, &QTimer::timeout, this, &MainWindow::onReservationTick);
    m_reservationTimer->start();

    // 启动后：恢复进行中订单/预约，并检测定位
    QTimer::singleShot(200, this, &MainWindow::restoreSession);
    QTimer::singleShot(400, this, &MainWindow::requestRealLocation);
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
    m_bottomNav = new QWidget(this);
    m_bottomNav->setObjectName(QStringLiteral("bottomNav"));
    m_bottomNav->setFixedHeight(48);
    auto *layout = new QHBoxLayout(m_bottomNav);
    layout->setContentsMargins(0, 0, 0, 0);
    layout->setSpacing(0);

    m_navStations = new QPushButton(QStringLiteral("充电站"), m_bottomNav);
    m_navCharge = new QPushButton(QStringLiteral("充电"), m_bottomNav);
    m_navProfile = new QPushButton(QStringLiteral("我的"), m_bottomNav);
    for (auto *btn : {m_navStations, m_navCharge, m_navProfile}) {
        btn->setFlat(true);
        btn->setObjectName(QStringLiteral("navBtn"));
        btn->setMinimumHeight(48);
        layout->addWidget(btn, 1);
    }
    updateNavActive(0);

    connect(m_navStations, &QPushButton::clicked, this, [this]() { onBottomNav(0); });
    connect(m_navCharge, &QPushButton::clicked, this, [this]() { onBottomNav(1); });
    connect(m_navProfile, &QPushButton::clicked, this, [this]() { onBottomNav(2); });
    return m_bottomNav;
}

void MainWindow::updateNavActive(int index)
{
    auto setActive = [](QPushButton *btn, bool on) {
        btn->setProperty("active", on);
        btn->style()->unpolish(btn);
        btn->style()->polish(btn);
        btn->update();
    };
    setActive(m_navStations, index == 0);
    setActive(m_navCharge, index == 1);
    setActive(m_navProfile, index == 2);
}

void MainWindow::onBottomNav(int index)
{
    m_tabStack->setCurrentIndex(index);
    updateNavActive(index);
    if (index == 0) refreshStations();
    if (index == 1) {
        refreshPilesForCharge();
        refreshOngoingBanner();
        updateReservationCountdown();
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
    layout->setContentsMargins(14, 12, 14, 8);
    layout->setSpacing(8);

    auto *header = new QLabel(QStringLiteral("附近充电站"), page);
    header->setObjectName(QStringLiteral("pageTitle"));
    m_countLabel = new QLabel(QStringLiteral("正在加载…"), page);
    m_countLabel->setObjectName(QStringLiteral("muted"));

    m_regionCombo = new QComboBox(page);
    m_regionCombo->addItem(QStringLiteral("全部区域"));
    for (const QString &d : ServerApiClient::instance().districts())
        m_regionCombo->addItem(d);

    m_addressEdit = new QLineEdit(page);
    m_addressEdit->setPlaceholderText(QStringLiteral("地址，如：国贸"));
    m_locateBtn = new QPushButton(QStringLiteral("定位"), page);
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
    m_loadMoreBtn = new QPushButton(QStringLiteral("加载更多"), page);
    m_loadMoreBtn->setObjectName(QStringLiteral("secondaryBtn"));
    m_loadMoreBtn->hide();

    auto *navBtn = new QPushButton(QStringLiteral("导航"), page);
    m_favBtn = new QPushButton(QStringLiteral("收藏/取消"), page);
    m_favBtn->setObjectName(QStringLiteral("secondaryBtn"));
    m_favOnlyCheck = new QCheckBox(QStringLiteral("仅看收藏"), page);
    m_navInfo = new QLabel(QStringLiteral("选中站点后可导航或收藏"), page);
    m_navInfo->setObjectName(QStringLiteral("muted"));
    m_navInfo->setWordWrap(true);

    auto *actionRow = new QHBoxLayout;
    actionRow->addWidget(navBtn, 1);
    actionRow->addWidget(m_favBtn, 1);
    actionRow->addWidget(m_favOnlyCheck);

    layout->addWidget(header);
    layout->addWidget(m_countLabel);
    layout->addLayout(filterRow);
    layout->addLayout(searchRow);
    layout->addWidget(m_locationLabel);
    layout->addWidget(m_stationList, 1);
    layout->addWidget(m_loadMoreBtn);
    layout->addLayout(actionRow);
    layout->addWidget(m_navInfo);

    connect(m_locateBtn, &QPushButton::clicked, this, &MainWindow::onLocate);
    connect(m_addressEdit, &QLineEdit::returnPressed, this, &MainWindow::onLocate);
    connect(searchBtn, &QPushButton::clicked, this, &MainWindow::refreshStations);
    connect(m_stationKeyword, &QLineEdit::returnPressed, this, &MainWindow::refreshStations);
    connect(m_regionCombo, &QComboBox::currentTextChanged, this, &MainWindow::onRegionChanged);
    connect(m_loadMoreBtn, &QPushButton::clicked, this, &MainWindow::loadMoreStations);
    connect(navBtn, &QPushButton::clicked, this, &MainWindow::onNavigate);
    connect(m_favBtn, &QPushButton::clicked, this, &MainWindow::onToggleFavorite);
    connect(m_favOnlyCheck, &QCheckBox::toggled, this, &MainWindow::onFavoriteFilterToggled);
    return page;
}

QWidget *MainWindow::buildChargePage()
{
    auto *page = new QWidget(this);
    auto *pageLayout = new QVBoxLayout(page);
    pageLayout->setContentsMargins(0, 0, 0, 0);
    pageLayout->setSpacing(0);
    auto *scroll = new QScrollArea(page);
    scroll->setWidgetResizable(true);
    scroll->setFrameShape(QFrame::NoFrame);
    scroll->setHorizontalScrollBarPolicy(Qt::ScrollBarAlwaysOff);

    auto *content = new QWidget(scroll);
    content->setObjectName(QStringLiteral("centralRoot"));
    auto *layout = new QVBoxLayout(content);
    layout->setContentsMargins(14, 12, 14, 8);
    layout->setSpacing(8);

    auto *header = new QLabel(QStringLiteral("充电"), page);
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

    m_pileList = new QListWidget(content);
    m_pileList->setMinimumHeight(180);
    m_reservationInfo = new QLabel(QStringLiteral("当前无有效预约"), page);
    m_reservationInfo->setObjectName(QStringLiteral("countdownLabel"));
    m_reservationInfo->setWordWrap(true);
    m_chargeInfo = new QLabel(QStringLiteral("当前无进行中的充电"), page);
    m_chargeInfo->setWordWrap(true);
    m_chargeProgress = new QProgressBar(page);
    m_chargeProgress->setRange(0, 100);
    m_chargeProgress->setValue(0);

    auto *chargeBtns = new QGridLayout;
    chargeBtns->setHorizontalSpacing(6);
    chargeBtns->setVerticalSpacing(6);
    auto *reserveBtn = new QPushButton(QStringLiteral("预约15分钟"), page);
    reserveBtn->setObjectName(QStringLiteral("secondaryBtn"));
    auto *cancelReservationBtn = new QPushButton(QStringLiteral("取消预约"), page);
    cancelReservationBtn->setObjectName(QStringLiteral("secondaryBtn"));
    auto *startBtn = new QPushButton(QStringLiteral("开始充电"), page);
    auto *stopBtn = new QPushButton(QStringLiteral("结束充电"), page);
    stopBtn->setObjectName(QStringLiteral("dangerBtn"));
    chargeBtns->addWidget(reserveBtn, 0, 0);
    chargeBtns->addWidget(cancelReservationBtn, 0, 1);
    chargeBtns->addWidget(startBtn, 1, 0);
    chargeBtns->addWidget(stopBtn, 1, 1);

    layout->addWidget(header);
    layout->addWidget(new QLabel(QStringLiteral("选择充电站"), page));
    layout->addWidget(m_stationCombo);
    layout->addWidget(new QLabel(QStringLiteral("筛选"), page));
    layout->addLayout(filterRow);
    layout->addWidget(m_pileList, 1);
    layout->addWidget(m_reservationInfo);
    layout->addWidget(m_chargeInfo);
    layout->addWidget(m_chargeProgress);
    layout->addLayout(chargeBtns);

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
    connect(reserveBtn, &QPushButton::clicked, this, &MainWindow::onReservePile);
    connect(cancelReservationBtn, &QPushButton::clicked, this, &MainWindow::onCancelReservation);
    connect(stopBtn, &QPushButton::clicked, this, &MainWindow::onStopCharge);
    scroll->setWidget(content);
    pageLayout->addWidget(scroll);
    return page;
}

QWidget *MainWindow::buildProfilePage()
{
    auto *page = new QWidget(this);
    auto *pageLayout = new QVBoxLayout(page);
    pageLayout->setContentsMargins(0, 0, 0, 0);
    pageLayout->setSpacing(0);

    auto *scroll = new QScrollArea(page);
    scroll->setWidgetResizable(true);
    scroll->setFrameShape(QFrame::NoFrame);
    scroll->setHorizontalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
    scroll->setVerticalScrollBarPolicy(Qt::ScrollBarAsNeeded);

    auto *content = new QWidget(scroll);
    content->setObjectName(QStringLiteral("centralRoot"));
    auto *layout = new QVBoxLayout(content);
    layout->setContentsMargins(14, 12, 14, 16);
    layout->setSpacing(12);

    auto *header = new QLabel(QStringLiteral("我的"), content);
    header->setObjectName(QStringLiteral("pageTitle"));

    auto *card = new QFrame(content);
    card->setObjectName(QStringLiteral("card"));
    auto *form = new QFormLayout(card);
    form->setContentsMargins(14, 14, 14, 14);
    form->setHorizontalSpacing(12);
    form->setVerticalSpacing(12);
    form->setFieldGrowthPolicy(QFormLayout::AllNonFixedFieldsGrow);
    form->setRowWrapPolicy(QFormLayout::DontWrapRows);

    m_balanceLabel = new QLabel(content);
    m_balanceLabel->setObjectName(QStringLiteral("countdownLabel"));
    m_balanceLabel->setMinimumHeight(28);

    m_avatarLabel = new QLabel(content);
    m_avatarLabel->setFixedSize(56, 56);
    m_avatarLabel->setAlignment(Qt::AlignCenter);
    m_avatarLabel->setStyleSheet(QStringLiteral("background:#EEF2F1; border-radius:4px;"));
    auto *avatarBtn = new QPushButton(QStringLiteral("选择头像"), content);
    avatarBtn->setObjectName(QStringLiteral("secondaryBtn"));
    avatarBtn->setMinimumHeight(36);
    auto *avatarRow = new QHBoxLayout;
    avatarRow->setSpacing(10);
    avatarRow->addWidget(m_avatarLabel);
    avatarRow->addWidget(avatarBtn);
    avatarRow->addStretch();

    m_phoneEdit = new QLineEdit(content);
    m_phoneEdit->setReadOnly(true);
    m_phoneEdit->setMinimumHeight(36);
    m_nicknameEdit = new QLineEdit(content);
    m_nicknameEdit->setMinimumHeight(36);
    m_carEdit = new QLineEdit(content);
    m_carEdit->setMinimumHeight(36);
    m_plateEdit = new QLineEdit(content);
    m_plateEdit->setMinimumHeight(36);

    form->addRow(QStringLiteral("头像"), avatarRow);
    form->addRow(QStringLiteral("账户余额"), m_balanceLabel);
    form->addRow(QStringLiteral("昵称"), m_nicknameEdit);
    form->addRow(QStringLiteral("手机号"), m_phoneEdit);
    form->addRow(QStringLiteral("车型"), m_carEdit);
    form->addRow(QStringLiteral("车牌号"), m_plateEdit);

    auto *saveBtn = new QPushButton(QStringLiteral("保存信息"), content);
    saveBtn->setMinimumHeight(40);

    m_darkModeBtn = new QPushButton(content);
    m_darkModeBtn->setObjectName(QStringLiteral("secondaryBtn"));
    m_darkModeBtn->setCheckable(true);
    m_darkModeBtn->setChecked(m_darkMode);
    m_darkModeBtn->setMinimumHeight(40);
    m_darkModeBtn->setText(m_darkMode ? QStringLiteral("深色模式：开")
                                     : QStringLiteral("深色模式：关"));

    auto *walletCard = new QFrame(content);
    walletCard->setObjectName(QStringLiteral("card"));
    auto *walletLayout = new QVBoxLayout(walletCard);
    walletLayout->setContentsMargins(14, 14, 14, 14);
    walletLayout->setSpacing(10);
    walletLayout->addWidget(new QLabel(QStringLiteral("钱包充值"), walletCard));
    m_rechargeEdit = new QLineEdit(walletCard);
    m_rechargeEdit->setMinimumHeight(36);
    m_rechargeEdit->setPlaceholderText(QStringLiteral("输入充值金额（元），如 100"));
    auto *rechargeBtn = new QPushButton(QStringLiteral("充值"), walletCard);
    rechargeBtn->setObjectName(QStringLiteral("successBtn"));
    rechargeBtn->setMinimumHeight(40);
    auto *quickRow = new QHBoxLayout;
    quickRow->setSpacing(8);
    for (int amt : {50, 100, 200, 500}) {
        auto *qbtn = new QPushButton(QStringLiteral("+%1").arg(amt), walletCard);
        qbtn->setObjectName(QStringLiteral("secondaryBtn"));
        qbtn->setMinimumHeight(36);
        connect(qbtn, &QPushButton::clicked, this, [this, amt]() {
            m_rechargeEdit->setText(QString::number(amt));
        });
        quickRow->addWidget(qbtn);
    }
    walletLayout->addWidget(m_rechargeEdit);
    walletLayout->addLayout(quickRow);
    walletLayout->addWidget(rechargeBtn);

    auto *ordersTitle = new QLabel(QStringLiteral("我的充电记录"), content);
    ordersTitle->setObjectName(QStringLiteral("pageTitle"));

    m_orderTable = new QTableWidget(content);
    m_orderTable->setColumnCount(5);
    m_orderTable->setHorizontalHeaderLabels({
        QStringLiteral("订单号"), QStringLiteral("站点"), QStringLiteral("电量"),
        QStringLiteral("金额"), QStringLiteral("状态")
    });
    m_orderTable->horizontalHeader()->setStretchLastSection(true);
    m_orderTable->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);
    m_orderTable->verticalHeader()->setVisible(false);
    m_orderTable->verticalHeader()->setDefaultSectionSize(36);
    m_orderTable->setMinimumHeight(220);
    m_orderTable->setEditTriggers(QAbstractItemView::NoEditTriggers);
    m_orderTable->setSelectionBehavior(QAbstractItemView::SelectRows);
    m_orderTable->setSizePolicy(QSizePolicy::Expanding, QSizePolicy::Fixed);

    m_dbInfoLabel = new QLabel(content);
    m_dbInfoLabel->setObjectName(QStringLiteral("muted"));
    m_dbInfoLabel->setWordWrap(true);
    m_dbInfoLabel->setMinimumHeight(40);

    layout->addWidget(header);
    layout->addWidget(card);
    layout->addWidget(saveBtn);
    layout->addWidget(m_darkModeBtn);
    layout->addWidget(walletCard);
    layout->addWidget(ordersTitle);
    layout->addWidget(m_orderTable);
    layout->addWidget(m_dbInfoLabel);
    layout->addStretch();

    scroll->setWidget(content);
    pageLayout->addWidget(scroll);

    connect(saveBtn, &QPushButton::clicked, this, &MainWindow::onSaveProfile);
    connect(avatarBtn, &QPushButton::clicked, this, &MainWindow::onChooseAvatar);
    connect(rechargeBtn, &QPushButton::clicked, this, &MainWindow::onRecharge);
    connect(m_darkModeBtn, &QPushButton::toggled, this, &MainWindow::onToggleDarkMode);
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
        m_locateBtn->setText(QStringLiteral("定位"));
    }
    refreshStations();
}

void MainWindow::onRealLocationFailed(const QString &reason)
{
    if (m_locateBtn) {
        m_locateBtn->setEnabled(true);
        m_locateBtn->setText(QStringLiteral("定位"));
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

    const QVector<Station> all = ServerApiClient::instance().listStations(
        m_userLat, m_userLng, m_stationKeyword->text(), district, 120);

    m_stationList->clear();
    m_stationCombo->blockSignals(true);
    m_stationCombo->clear();
    m_cachedStations.clear();
    for (const Station &s : all) {
        m_stationCombo->addItem(
            QStringLiteral("%1%2（空闲%3/%4）")
                .arg(isFavorite(s.id) ? QStringLiteral("★ ") : QString())
                .arg(s.name)
                .arg(s.idlePiles)
                .arg(s.totalPiles),
            s.id);
        if (m_favOnlyCheck && m_favOnlyCheck->isChecked() && !isFavorite(s.id))
            continue;
        m_cachedStations.append(s);
    }
    m_stationCombo->blockSignals(false);

    m_visibleCount = qMin(20, m_cachedStations.size());
    for (int i = 0; i < m_visibleCount; ++i)
        appendStationItem(m_cachedStations[i]);

    const int total = ServerApiClient::instance().stationCount();
    const int piles = ServerApiClient::instance().pileCount();
    m_countLabel->setText(QStringLiteral("显示 %1 / 筛选后 %2 站（库内 %3 站 · %4 桩 · 收藏 %5）")
                              .arg(m_visibleCount)
                              .arg(m_cachedStations.size())
                              .arg(total)
                              .arg(piles)
                              .arg(m_favoriteIds.size()));
    m_loadMoreBtn->setVisible(m_visibleCount < m_cachedStations.size());
    refreshPilesForCharge();
}

void MainWindow::appendStationItem(const Station &s)
{
    const QString star = isFavorite(s.id) ? QStringLiteral("★ ") : QString();
    const QString text = QStringLiteral("%1%2\n%3 · %4\n距离 %5 km · 空闲 %6/%7 · %8")
                             .arg(star, s.name, s.regionCode, s.address)
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

void MainWindow::loadMoreStations()
{
    const int old = m_visibleCount;
    m_visibleCount = qMin(m_visibleCount + 20, m_cachedStations.size());
    for (int i = old; i < m_visibleCount; ++i)
        appendStationItem(m_cachedStations[i]);
    m_countLabel->setText(QStringLiteral("显示 %1 / 筛选后 %2 站（库内 %3 站 · %4 桩 · 收藏 %5）")
                              .arg(m_visibleCount)
                              .arg(m_cachedStations.size())
                              .arg(ServerApiClient::instance().stationCount())
                              .arg(ServerApiClient::instance().pileCount())
                              .arg(m_favoriteIds.size()));
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

    QUrl url(QStringLiteral("https://apis.map.qq.com/uri/v1/routeplan"));
    QUrlQuery query;
    query.addQueryItem(QStringLiteral("type"), QStringLiteral("drive"));
    query.addQueryItem(QStringLiteral("from"), m_userAddress);
    query.addQueryItem(QStringLiteral("fromcoord"),
                       QStringLiteral("%1,%2").arg(m_userLat, 0, 'f', 6).arg(m_userLng, 0, 'f', 6));
    query.addQueryItem(QStringLiteral("to"), name);
    query.addQueryItem(QStringLiteral("tocoord"),
                       QStringLiteral("%1,%2").arg(lat, 0, 'f', 6).arg(lng, 0, 'f', 6));
    query.addQueryItem(QStringLiteral("policy"), QStringLiteral("0"));
    query.addQueryItem(QStringLiteral("referer"), QStringLiteral("ChargePileLab"));
    url.setQuery(query);
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
    ChargingReservation active;
    m_reservation = ServerApiClient::instance().getActiveReservation(active)
                        ? active : ChargingReservation{};
    updateReservationCountdown();
    if (m_reservation.id > 0) {
        Pile reservedPile;
        if (ServerApiClient::instance().getPile(m_reservation.pileId, reservedPile)
            && selectedStationId() != reservedPile.stationId) {
            const int index = m_stationCombo->findData(reservedPile.stationId);
            if (index >= 0) {
                m_stationCombo->blockSignals(true);
                m_stationCombo->setCurrentIndex(index);
                m_stationCombo->blockSignals(false);
            }
        }
    }
    const int stationId = selectedStationId();
    if (stationId <= 0)
        return;

    const QString speed = m_speedFilter->currentData().toString();
    const QString connector = m_connectorFilter->currentData().toString();
    const auto piles = ServerApiClient::instance().listPiles(stationId, QString(), speed, connector);
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
        const bool ownReservation = p.status == QLatin1String("reserved")
                                    && p.id == m_reservation.pileId;
        if (p.status != QLatin1String("idle") && !ownReservation)
            item->setFlags(item->flags() & ~Qt::ItemIsEnabled);
        if (ownReservation)
            m_pileList->setCurrentItem(item);
    }
}

void MainWindow::onReservePile()
{
    const int pileId = selectedPileId();
    if (pileId <= 0) {
        QMessageBox::information(this, QStringLiteral("提示"), QStringLiteral("请先选择一个空闲充电桩"));
        return;
    }
    ChargingReservation reservation;
    if (!ServerApiClient::instance().createReservation(pileId, reservation)) {
        QMessageBox::warning(this, QStringLiteral("预约失败"),
                             ServerApiClient::instance().lastError());
        return;
    }
    m_reservation = reservation;
    refreshPilesForCharge();
    QMessageBox::information(this, QStringLiteral("预约成功"),
                             QStringLiteral("电桩已为您保留至 %1").arg(reservation.expiresAt));
}

void MainWindow::onCancelReservation()
{
    if (m_reservation.id <= 0) {
        QMessageBox::information(this, QStringLiteral("提示"), QStringLiteral("当前没有有效预约"));
        return;
    }
    if (!ServerApiClient::instance().cancelReservation(m_reservation.id)) {
        QMessageBox::warning(this, QStringLiteral("取消失败"),
                             ServerApiClient::instance().lastError());
        return;
    }
    m_reservation = ChargingReservation{};
    refreshPilesForCharge();
}

void MainWindow::refreshOngoingBanner()
{
    ChargingOrder order;
    if (ServerApiClient::instance().getOngoingOrderByUser(m_user.id, order)) {
        m_ongoing = order;
        Pile pile;
        if (ServerApiClient::instance().getPile(order.pileId, pile)) {
            m_currentPrice = pile.pricePerKwh;
            m_currentPowerKw = pile.powerKw;
        }
        if (!m_chargeTimer->isActive()) {
            m_simulatedEnergy = order.energyKwh;
            m_progressTick = 0;
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
    if (!ServerApiClient::instance().startCharging(m_user.id, pileId, order)) {
        QMessageBox::warning(this, QStringLiteral("无法开始充电"),
                             ServerApiClient::instance().lastError());
        return;
    }

    auto *item = m_pileList->currentItem();
    m_currentPrice = item ? item->data(Qt::UserRole + 1).toDouble() : 1.2;
    m_currentPowerKw = item ? item->data(Qt::UserRole + 2).toDouble() : 7.0;
    m_ongoing = order;
    m_reservation = ChargingReservation{};
    m_simulatedEnergy = 0;
    m_progressTick = 0;
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
    if (++m_progressTick >= 5) {
        m_progressTick = 0;
        if (!ServerApiClient::instance().updateChargingProgress(
                m_user.id, m_ongoing.id, m_simulatedEnergy)) {
            m_chargeTimer->stop();
            QMessageBox::warning(this, QStringLiteral("服务连接异常"),
                                 ServerApiClient::instance().lastError());
            return;
        }
    }
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
    if (!ServerApiClient::instance().stopCharging(m_ongoing.id, energy, finished)) {
        QMessageBox::warning(this, QStringLiteral("结束失败"),
                             ServerApiClient::instance().lastError());
        return;
    }

    m_chargeTimer->stop();
    m_ongoing = ChargingOrder{};
    ServerApiClient::instance().getUserById(m_user.id, m_user);
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
    ServerApiClient::instance().getUserById(m_user.id, m_user);
    m_balanceLabel->setText(QStringLiteral("¥ %1").arg(m_user.balance, 0, 'f', 2));
    m_phoneEdit->setText(m_user.phone);
    m_nicknameEdit->setText(m_user.nickname);
    m_carEdit->setText(m_user.carModel);
    m_plateEdit->setText(m_user.plateNumber);
    if (!m_user.avatarPath.isEmpty()) {
        const QPixmap avatar(m_user.avatarPath);
        if (!avatar.isNull())
            m_avatarLabel->setPixmap(avatar.scaled(m_avatarLabel->size(), Qt::KeepAspectRatio,
                                                   Qt::SmoothTransformation));
        else
            m_avatarLabel->setText(QStringLiteral("头像"));
    } else {
        m_avatarLabel->setText(QStringLiteral("头像"));
    }
    m_dbInfoLabel->setText(QStringLiteral("服务端 %1 · %2 站 / %3 桩")
                               .arg(ServerApiClient::instance().serverDescription())
                               .arg(ServerApiClient::instance().stationCount())
                               .arg(ServerApiClient::instance().pileCount()));
}

void MainWindow::onSaveProfile()
{
    m_user.nickname = m_nicknameEdit->text().trimmed();
    m_user.carModel = m_carEdit->text().trimmed();
    m_user.plateNumber = m_plateEdit->text().trimmed();
    if (!ServerApiClient::instance().updateUser(m_user)) {
        QMessageBox::warning(this, QStringLiteral("保存失败"),
                             ServerApiClient::instance().lastError());
        return;
    }
    QMessageBox::information(this, QStringLiteral("成功"), QStringLiteral("个人信息已更新"));
}

void MainWindow::onChooseAvatar()
{
    const QString path = QFileDialog::getOpenFileName(
        this, QStringLiteral("选择头像"), QString(),
        QStringLiteral("图片文件 (*.png *.jpg *.jpeg *.bmp)"));
    if (path.isEmpty())
        return;
    const QPixmap avatar(path);
    if (avatar.isNull()) {
        QMessageBox::warning(this, QStringLiteral("头像无效"), QStringLiteral("无法读取所选图片"));
        return;
    }
    m_user.avatarPath = path;
    m_avatarLabel->setPixmap(avatar.scaled(m_avatarLabel->size(), Qt::KeepAspectRatio,
                                           Qt::SmoothTransformation));
}

void MainWindow::onRecharge()
{
    bool ok = false;
    const double amount = m_rechargeEdit->text().trimmed().toDouble(&ok);
    if (!ok || amount <= 0) {
        QMessageBox::warning(this, QStringLiteral("提示"), QStringLiteral("请输入有效的充值金额"));
        return;
    }
    if (!ServerApiClient::instance().rechargeUser(m_user.id, amount)) {
        QMessageBox::warning(this, QStringLiteral("充值失败"),
                             ServerApiClient::instance().lastError());
        return;
    }
    m_rechargeEdit->clear();
    refreshProfile();
    QMessageBox::information(this, QStringLiteral("充值成功"),
                             QStringLiteral("已充值 ¥%1").arg(amount, 0, 'f', 2));
}

void MainWindow::refreshOrders()
{
    const auto orders = ServerApiClient::instance().listOrders(m_user.id);
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

void MainWindow::loadFavorites()
{
    QSettings settings;
    const QVariantList list = settings.value(
        QStringLiteral("favorites/%1").arg(m_user.id)).toList();
    m_favoriteIds.clear();
    for (const QVariant &v : list)
        m_favoriteIds.insert(v.toInt());
}

void MainWindow::saveFavorites()
{
    QVariantList list;
    for (int id : m_favoriteIds)
        list.append(id);
    QSettings settings;
    settings.setValue(QStringLiteral("favorites/%1").arg(m_user.id), list);
}

bool MainWindow::isFavorite(int stationId) const
{
    return m_favoriteIds.contains(stationId);
}

void MainWindow::setFavorite(int stationId, bool on)
{
    if (on)
        m_favoriteIds.insert(stationId);
    else
        m_favoriteIds.remove(stationId);
    saveFavorites();
}

int MainWindow::selectedListStationId() const
{
    auto *item = m_stationList->currentItem();
    return item ? item->data(Qt::UserRole).toInt() : 0;
}

void MainWindow::onToggleFavorite()
{
    const int id = selectedListStationId();
    if (id <= 0) {
        QMessageBox::information(this, QStringLiteral("提示"), QStringLiteral("请先选中一个充电站"));
        return;
    }
    const bool nowFav = !isFavorite(id);
    setFavorite(id, nowFav);
    statusBar()->showMessage(nowFav ? QStringLiteral("已加入收藏")
                                    : QStringLiteral("已取消收藏"), 2500);
    refreshStations();
}

void MainWindow::onFavoriteFilterToggled(bool)
{
    refreshStations();
}

void MainWindow::updateReservationCountdown()
{
    if (!m_reservationInfo)
        return;
    if (m_reservation.id <= 0) {
        m_reservationInfo->setText(QStringLiteral("当前无有效预约"));
        return;
    }

    const QDateTime expires = QDateTime::fromString(m_reservation.expiresAt,
                                                    QStringLiteral("yyyy-MM-dd HH:mm:ss"));
    if (!expires.isValid()) {
        m_reservationInfo->setText(
            QStringLiteral("有效预约：%1 / %2\n预约号 %3\n到期 %4")
                .arg(m_reservation.stationName, m_reservation.pileCode,
                     m_reservation.reservationNo, m_reservation.expiresAt));
        return;
    }

    const qint64 secs = QDateTime::currentDateTime().secsTo(expires);
    if (secs <= 0) {
        m_reservationInfo->setText(QStringLiteral("预约已到期，正在刷新…"));
        m_reservation = ChargingReservation{};
        // 到期后刷新一次桩状态
        QTimer::singleShot(300, this, &MainWindow::refreshPilesForCharge);
        return;
    }

    const int mm = int(secs / 60);
    const int ss = int(secs % 60);
    m_reservationInfo->setText(
        QStringLiteral("有效预约：%1 / %2\n预约号 %3\n剩余 %4:%5（到期 %6）")
            .arg(m_reservation.stationName, m_reservation.pileCode, m_reservation.reservationNo)
            .arg(mm, 2, 10, QChar('0'))
            .arg(ss, 2, 10, QChar('0'))
            .arg(m_reservation.expiresAt));
}

void MainWindow::onReservationTick()
{
    updateReservationCountdown();
}

void MainWindow::restoreSession()
{
    if (m_sessionRestored)
        return;
    m_sessionRestored = true;

    QStringList recovered;
    ChargingOrder order;
    if (ServerApiClient::instance().getOngoingOrderByUser(m_user.id, order)) {
        recovered << QStringLiteral("进行中订单 %1（%2 / %3，已充 %4 kWh）")
                         .arg(order.orderNo, order.stationName, order.pileCode)
                         .arg(order.energyKwh, 0, 'f', 2);
        refreshOngoingBanner();
        onBottomNav(1);
    }

    ChargingReservation reservation;
    if (ServerApiClient::instance().getActiveReservation(reservation)) {
        m_reservation = reservation;
        recovered << QStringLiteral("有效预约 %1（%2 / %3，到期 %4）")
                         .arg(reservation.reservationNo, reservation.stationName,
                              reservation.pileCode, reservation.expiresAt);
        refreshPilesForCharge();
        updateReservationCountdown();
        if (m_tabStack->currentIndex() != 1)
            onBottomNav(1);
    }

    if (!recovered.isEmpty()) {
        statusBar()->showMessage(QStringLiteral("已恢复会话"), 4000);
        QMessageBox::information(this, QStringLiteral("会话恢复"),
                                 QStringLiteral("检测到未完成业务，已为您恢复：\n\n- ")
                                     + recovered.join(QStringLiteral("\n- ")));
    } else {
        statusBar()->showMessage(QStringLiteral("无进行中订单或预约"), 2500);
    }
}

void MainWindow::applyTheme(bool dark)
{
    m_darkMode = dark;
    qApp->setStyleSheet(dark ? StyleHelper::userClientDarkStyle()
                             : StyleHelper::userClientStyle());
    if (m_darkModeBtn) {
        m_darkModeBtn->blockSignals(true);
        m_darkModeBtn->setChecked(dark);
        m_darkModeBtn->setText(dark ? QStringLiteral("深色模式：开")
                                   : QStringLiteral("深色模式：关"));
        m_darkModeBtn->blockSignals(false);
    }
    if (m_tabStack)
        updateNavActive(m_tabStack->currentIndex());
}

void MainWindow::onToggleDarkMode(bool dark)
{
    applyTheme(dark);
    QSettings settings;
    settings.setValue(QStringLiteral("ui/darkMode"), dark);
    statusBar()->showMessage(dark ? QStringLiteral("已切换深色模式")
                                  : QStringLiteral("已切换浅色模式"), 2000);
}

