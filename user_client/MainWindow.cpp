#include "MainWindow.h"
#include "ServerApiClient.h"
#include "LocationProvider.h"
#include "StyleHelper.h"
#include "ui_MainWindow.h"

#include <QAbstractItemView>
#include <QApplication>
#include <QBrush>
#include <QCheckBox>
#include <QCloseEvent>
#include <QColor>
#include <QComboBox>
#include <QDateTime>
#include <QDesktopServices>
#include <QDialog>
#include <QDialogButtonBox>
#include <QEvent>
#include <QFileDialog>
#include <QFormLayout>
#include <QFrame>
#include <QGridLayout>
#include <QHBoxLayout>
#include <QHeaderView>
#include <QLabel>
#include <QLineEdit>
#include <QListWidget>
#include <QListWidgetItem>
#include <QMap>
#include <QMessageBox>
#include <QMouseEvent>
#include <QPainter>
#include <QPainterPath>
#include <QPen>
#include <QProgressBar>
#include <QPixmap>
#include <QPushButton>
#include <QStyledItemDelegate>
#include <QScrollArea>
#include <QSet>
#include <QSettings>
#include <QSize>
#include <QSizePolicy>
#include <QStackedWidget>
#include <QStatusBar>
#include <QStyle>
#include <QTableWidget>
#include <QTextEdit>
#include <QTimer>
#include <QUrl>
#include <QUrlQuery>
#include <QVBoxLayout>
#include <QVector>

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

constexpr int kFavoriteRole = Qt::UserRole + 20;

class FavoriteCardDelegate : public QStyledItemDelegate
{
public:
    explicit FavoriteCardDelegate(QObject *parent = nullptr)
        : QStyledItemDelegate(parent)
    {
    }

    void paint(QPainter *painter, const QStyleOptionViewItem &option,
               const QModelIndex &index) const override
    {
        const bool dark = option.widget && option.widget->property("darkMode").toBool();
        const bool fav = index.data(kFavoriteRole).toBool();
        const bool selected = option.state & QStyle::State_Selected;
        const bool enabled = option.state & QStyle::State_Enabled;

        QRect r = option.rect.adjusted(2, 3, -2, -3);
        QPainterPath path;
        path.addRoundedRect(r, 8, 8);

        QColor bg = dark ? QColor(QStringLiteral("#1A2422")) : QColor(Qt::white);
        QColor border = dark ? QColor(QStringLiteral("#2A3835")) : QColor(QStringLiteral("#D8E0DE"));
        QColor fg = dark ? QColor(QStringLiteral("#E8EEEC")) : QColor(QStringLiteral("#15201E"));
        if (fav) {
            bg = StyleHelper::favoriteBackground(dark);
            fg = StyleHelper::favoriteForeground(dark);
        }
        if (selected) {
            border = dark ? QColor(QStringLiteral("#3DDBB5")) : QColor(QStringLiteral("#0D7565"));
            if (!fav)
                bg = dark ? QColor(QStringLiteral("#20302D")) : QColor(QStringLiteral("#E7F2EF"));
        }
        if (!enabled)
            fg.setAlpha(140);

        painter->save();
        painter->setRenderHint(QPainter::Antialiasing, true);
        painter->fillPath(path, bg);
        painter->setPen(QPen(border, selected ? 1.6 : 1.0));
        painter->drawPath(path);
        painter->setPen(fg);
        QFont font = option.font;
        painter->setFont(font);
        painter->drawText(r.adjusted(12, 8, -12, -8),
                          Qt::AlignLeft | Qt::AlignVCenter | Qt::TextWordWrap,
                          index.data(Qt::DisplayRole).toString());
        painter->restore();
    }
};

void prepareCardList(QListWidget *list, bool favoriteHighlight = false)
{
    list->setSpacing(favoriteHighlight ? 2 : 6);
    list->setWordWrap(true);
    list->setUniformItemSizes(false);
    list->setHorizontalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
    list->setVerticalScrollMode(QAbstractItemView::ScrollPerPixel);
    list->setFrameShape(QFrame::NoFrame);
    if (favoriteHighlight)
        list->setItemDelegate(new FavoriteCardDelegate(list));
}

int cardItemHeight(const QListWidget *list, int lines)
{
    return qMax(84, lines * list->fontMetrics().lineSpacing() + 36);
}

QString starsText(double avg, int maxStars = 5)
{
    const int filled = qBound(0, int(qRound(avg)), maxStars);
    QString out;
    for (int i = 1; i <= maxStars; ++i)
        out += (i <= filled) ? QStringLiteral("★") : QStringLiteral("☆");
    return out;
}

QString ratingSummary(double avg, int count)
{
    if (count <= 0)
        return QStringLiteral("暂无评分");
    return QStringLiteral("%1  %2（%3评）")
        .arg(starsText(avg))
        .arg(avg, 0, 'f', 1)
        .arg(count);
}

void showLargeMessage(QWidget *parent, QMessageBox::Icon icon, const QString &title,
                      const QString &text)
{
    QDialog dlg(parent);
    dlg.setWindowTitle(title);
    dlg.setModal(true);
    if (parent)
        dlg.setStyleSheet(parent->styleSheet());

    auto *layout = new QVBoxLayout(&dlg);
    layout->setContentsMargins(20, 18, 20, 16);
    layout->setSpacing(16);

    auto *row = new QWidget(&dlg);
    auto *rowLayout = new QHBoxLayout(row);
    rowLayout->setContentsMargins(0, 0, 0, 0);
    rowLayout->setSpacing(12);

    auto *iconLabel = new QLabel(row);
    const QStyle::StandardPixmap sp =
        icon == QMessageBox::Warning ? QStyle::SP_MessageBoxWarning
        : icon == QMessageBox::Critical ? QStyle::SP_MessageBoxCritical
                                        : QStyle::SP_MessageBoxInformation;
    iconLabel->setPixmap(dlg.style()->standardIcon(sp).pixmap(32, 32));
    iconLabel->setFixedSize(32, 32);
    iconLabel->setAlignment(Qt::AlignCenter);

    auto *textLabel = new QLabel(text, row);
    textLabel->setWordWrap(true);
    textLabel->setAlignment(Qt::AlignLeft | Qt::AlignVCenter);
    textLabel->setTextInteractionFlags(Qt::TextSelectableByMouse);
    textLabel->setMinimumWidth(260);
    textLabel->setMaximumWidth(400);

    rowLayout->addWidget(iconLabel, 0, Qt::AlignTop);
    rowLayout->addWidget(textLabel, 1);
    layout->addWidget(row);

    auto *ok = new QPushButton(QStringLiteral("确定"), &dlg);
    ok->setDefault(true);
    ok->setMinimumWidth(88);
    auto *btnRow = new QHBoxLayout;
    btnRow->addStretch();
    btnRow->addWidget(ok);
    layout->addLayout(btnRow);
    QObject::connect(ok, &QPushButton::clicked, &dlg, &QDialog::accept);

    dlg.adjustSize();
    dlg.exec();
}

void applyStarVisual(QPushButton *btn, bool lit)
{
    btn->setText(lit ? QStringLiteral("★") : QStringLiteral("☆"));
    btn->setProperty("lit", lit ? QStringLiteral("true") : QStringLiteral("false"));
    btn->style()->unpolish(btn);
    btn->style()->polish(btn);
    btn->update();
}

} // namespace

MainWindow::MainWindow(const User &user, QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
    , m_user(user)
{
    m_locationProvider = new LocationProvider(this);
    connect(m_locationProvider, &LocationProvider::locationUpdated,
            this, &MainWindow::onRealLocationUpdated);
    connect(m_locationProvider, &LocationProvider::locationFailed,
            this, &MainWindow::onRealLocationFailed);

    QSettings settings;
    m_darkMode = settings.value(QStringLiteral("ui/darkMode"), false).toBool();
    applyTheme(m_darkMode);

    buildUi();
    setWindowTitle(QStringLiteral("充电用户端 - %1").arg(m_user.username));
    // 手机端默认窗口：540×960，比原先 400×700 / 448×784 更大，便于课堂演示
    resize(540, 960);
    setMinimumSize(480, 840);
    setMaximumWidth(620);
    statusBar()->setSizeGripEnabled(false);
    statusBar()->showMessage(QStringLiteral("正在加载…"));

    m_reservationTimer = new QTimer(this);
    m_reservationTimer->setInterval(1000);
    connect(m_reservationTimer, &QTimer::timeout, this, &MainWindow::onReservationTick);
    m_reservationTimer->start();

    // 先画出窗口再拉数据，避免登录按钮按下后界面卡住数秒。
    QTimer::singleShot(0, this, &MainWindow::loadInitialData);
    QTimer::singleShot(400, this, &MainWindow::requestRealLocation);
}

MainWindow::~MainWindow()
{
    delete ui;
}

void MainWindow::bindUiWidgets()
{
    m_tabStack = ui->tabStack;
    m_bottomNav = ui->bottomNav;
    m_navStations = ui->navStations;
    m_navCharge = ui->navCharge;
    m_navProfile = ui->navProfile;
    m_chargeBanner = ui->chargeBanner;
    m_regionCombo = ui->regionCombo;
    m_addressEdit = ui->addressEdit;
    m_locateBtn = ui->locateBtn;
    m_stationKeyword = ui->stationKeyword;
    m_locationLabel = ui->locationLabel;
    m_countLabel = ui->countLabel;
    m_stationList = ui->stationList;
    m_loadMoreBtn = ui->loadMoreBtn;
    m_favBtn = ui->favBtn;
    m_favOnlyCheck = ui->favOnlyCheck;
    m_navInfo = ui->navInfo;
    m_subNavReserve = ui->subNavReserve;
    m_subNavMyReserve = ui->subNavMyReserve;
    m_subNavCharge = ui->subNavCharge;
    m_chargeSubStack = ui->chargeSubStack;
    m_stationCombo = ui->stationCombo;
    m_speedFilter = ui->speedFilter;
    m_connectorFilter = ui->connectorFilter;
    m_pileList = ui->pileList;
    m_pileFavOnlyCheck = ui->pileFavOnlyCheck;
    m_pileFavBtn = ui->pileFavBtn;
    m_chargeInfo = ui->chargeInfo;
    m_reservationInfo = ui->reservationInfo;
    m_chargeProgress = ui->chargeProgress;
    m_phoneEdit = ui->phoneEdit;
    m_nicknameEdit = ui->nicknameEdit;
    m_carEdit = ui->carEdit;
    m_plateEdit = ui->plateEdit;
    m_rechargeEdit = ui->rechargeEdit;
    m_balanceLabel = ui->balanceLabel;
    m_avatarLabel = ui->avatarLabel;
    m_dbInfoLabel = ui->dbInfoLabel;
    m_orderTable = ui->orderTable;
    m_darkModeBtn = ui->darkModeBtn;
}

void MainWindow::applyStyleObjectNames()
{
    ui->centralRoot->setObjectName(QStringLiteral("centralRoot"));
    ui->chargeBanner->setObjectName(QStringLiteral("chargeBanner"));
    ui->bottomNav->setObjectName(QStringLiteral("bottomNav"));
    ui->navStations->setObjectName(QStringLiteral("navBtn"));
    ui->navCharge->setObjectName(QStringLiteral("navBtn"));
    ui->navProfile->setObjectName(QStringLiteral("navBtn"));
    ui->stationsHeader->setObjectName(QStringLiteral("pageTitle"));
    ui->countLabel->setObjectName(QStringLiteral("muted"));
    ui->locateBtn->setObjectName(QStringLiteral("secondaryBtn"));
    ui->locationLabel->setObjectName(QStringLiteral("muted"));
    ui->loadMoreBtn->setObjectName(QStringLiteral("secondaryBtn"));
    ui->favBtn->setObjectName(QStringLiteral("secondaryBtn"));
    ui->navInfo->setObjectName(QStringLiteral("muted"));
    ui->chargeSubNav->setObjectName(QStringLiteral("bottomNav"));
    ui->subNavReserve->setObjectName(QStringLiteral("navBtn"));
    ui->subNavMyReserve->setObjectName(QStringLiteral("navBtn"));
    ui->subNavCharge->setObjectName(QStringLiteral("navBtn"));
    ui->reserveContent->setObjectName(QStringLiteral("centralRoot"));
    ui->reserveTitle->setObjectName(QStringLiteral("pageTitle"));
    ui->pileFavBtn->setObjectName(QStringLiteral("secondaryBtn"));
    ui->myContent->setObjectName(QStringLiteral("centralRoot"));
    ui->myTitle->setObjectName(QStringLiteral("pageTitle"));
    ui->detailCard->setObjectName(QStringLiteral("card"));
    ui->reservationInfo->setObjectName(QStringLiteral("countdownLabel"));
    ui->cancelReservationBtn->setObjectName(QStringLiteral("secondaryBtn"));
    ui->myHint->setObjectName(QStringLiteral("muted"));
    ui->chargeContent->setObjectName(QStringLiteral("centralRoot"));
    ui->chargeTitle->setObjectName(QStringLiteral("pageTitle"));
    ui->stopBtn->setObjectName(QStringLiteral("dangerBtn"));
    ui->chargeHint->setObjectName(QStringLiteral("muted"));
    ui->profileContent->setObjectName(QStringLiteral("centralRoot"));
    ui->profileHeader->setObjectName(QStringLiteral("pageTitle"));
    ui->profileCard->setObjectName(QStringLiteral("card"));
    ui->balanceLabel->setObjectName(QStringLiteral("countdownLabel"));
    ui->avatarBtn->setObjectName(QStringLiteral("secondaryBtn"));
    ui->darkModeBtn->setObjectName(QStringLiteral("secondaryBtn"));
    ui->walletCard->setObjectName(QStringLiteral("card"));
    ui->rechargeBtn->setObjectName(QStringLiteral("successBtn"));
    ui->quick50Btn->setObjectName(QStringLiteral("secondaryBtn"));
    ui->quick100Btn->setObjectName(QStringLiteral("secondaryBtn"));
    ui->quick200Btn->setObjectName(QStringLiteral("secondaryBtn"));
    ui->quick500Btn->setObjectName(QStringLiteral("secondaryBtn"));
    ui->ordersTitle->setObjectName(QStringLiteral("pageTitle"));
    ui->refreshOrdersBtn->setObjectName(QStringLiteral("secondaryBtn"));
    ui->dbInfoLabel->setObjectName(QStringLiteral("muted"));
    ui->logoutBtn->setObjectName(QStringLiteral("dangerBtn"));
}

void MainWindow::buildUi()
{
    ui->setupUi(this);
    bindUiWidgets();
    applyStyleObjectNames();

    m_avatarLabel->setStyleSheet(QStringLiteral("background:#EEF2F1; border-radius:4px;"));
    m_darkModeBtn->setChecked(m_darkMode);
    m_darkModeBtn->setText(m_darkMode ? QStringLiteral("深色模式：开")
                                     : QStringLiteral("深色模式：关"));

    for (const QString &d : ServerApiClient::instance().districts())
        m_regionCombo->addItem(d);

    m_speedFilter->addItem(QStringLiteral("全部速度"), QString());
    m_speedFilter->addItem(QStringLiteral("慢充"), QStringLiteral("slow"));
    m_speedFilter->addItem(QStringLiteral("常规"), QStringLiteral("standard"));
    m_speedFilter->addItem(QStringLiteral("快充"), QStringLiteral("fast"));
    m_speedFilter->addItem(QStringLiteral("超充"), QStringLiteral("ultra"));
    m_connectorFilter->addItem(QStringLiteral("全部接口"), QString());
    m_connectorFilter->addItem(QStringLiteral("国标交流"), QStringLiteral("GB_T_AC"));
    m_connectorFilter->addItem(QStringLiteral("国标直流"), QStringLiteral("GB_T_DC"));
    m_connectorFilter->addItem(QStringLiteral("CCS2"), QStringLiteral("CCS2"));
    m_connectorFilter->addItem(QStringLiteral("CHAdeMO"), QStringLiteral("CHAdeMO"));
    m_connectorFilter->addItem(QStringLiteral("特斯拉NACS"), QStringLiteral("TeslaNACS"));

    prepareCardList(m_stationList, true);
    prepareCardList(m_pileList, true);
    m_stationList->setObjectName(QStringLiteral("stationList"));
    if (m_pileList)
        m_pileList->setObjectName(QStringLiteral("pileList"));
    m_stationList->setCursor(Qt::PointingHandCursor);
    if (m_countLabel)
        m_countLabel->setWordWrap(true);
    if (m_locationLabel)
        m_locationLabel->setWordWrap(true);

    // 详情浮层：不拆原布局，避免整页点击失效
    buildStationDetailPage();
    ui->stationsPage->installEventFilter(this);

    m_orderTable->setColumnCount(5);
    m_orderTable->setHorizontalHeaderLabels({
        QStringLiteral("订单号"), QStringLiteral("站点"), QStringLiteral("电量"),
        QStringLiteral("金额"), QStringLiteral("状态")
    });
    m_orderTable->horizontalHeader()->setStretchLastSection(true);
    m_orderTable->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);
    m_orderTable->verticalHeader()->setVisible(false);
    m_orderTable->verticalHeader()->setDefaultSectionSize(36);
    m_orderTable->setEditTriggers(QAbstractItemView::NoEditTriggers);
    m_orderTable->setSelectionBehavior(QAbstractItemView::SelectRows);

    updateNavActive(0);
    updateChargeSubNavActive(0);

    m_chargeTimer = new QTimer(this);
    m_chargeTimer->setInterval(1000);
    connect(m_chargeTimer, &QTimer::timeout, this, &MainWindow::onChargeTick);

    connect(m_locateBtn, &QPushButton::clicked, this, &MainWindow::onLocate);
    connect(m_addressEdit, &QLineEdit::returnPressed, this, &MainWindow::onLocate);
    connect(ui->searchBtn, &QPushButton::clicked, this, &MainWindow::refreshStations);
    connect(m_stationKeyword, &QLineEdit::returnPressed, this, &MainWindow::refreshStations);
    connect(m_regionCombo, &QComboBox::currentTextChanged, this, &MainWindow::onRegionChanged);
    connect(m_loadMoreBtn, &QPushButton::clicked, this, &MainWindow::loadMoreStations);
    connect(ui->navigateBtn, &QPushButton::clicked, this, &MainWindow::onNavigate);
    connect(m_favBtn, &QPushButton::clicked, this, &MainWindow::onToggleFavorite);
    connect(m_favOnlyCheck, &QCheckBox::toggled, this, &MainWindow::onFavoriteFilterToggled);
    connect(m_stationCombo, QOverload<int>::of(&QComboBox::currentIndexChanged),
            this, &MainWindow::refreshPilesForCharge);
    connect(m_speedFilter, QOverload<int>::of(&QComboBox::currentIndexChanged),
            this, &MainWindow::refreshPilesForCharge);
    connect(m_connectorFilter, QOverload<int>::of(&QComboBox::currentIndexChanged),
            this, &MainWindow::refreshPilesForCharge);
    connect(ui->startBtn, &QPushButton::clicked, this, &MainWindow::onStartCharge);
    connect(ui->reserveBtn, &QPushButton::clicked, this, &MainWindow::onReservePile);
    connect(ui->cancelReservationBtn, &QPushButton::clicked, this, &MainWindow::onCancelReservation);
    connect(ui->stopBtn, &QPushButton::clicked, this, &MainWindow::onStopCharge);
    connect(m_pileFavBtn, &QPushButton::clicked, this, &MainWindow::onTogglePileFavorite);
    connect(m_pileFavOnlyCheck, &QCheckBox::toggled, this, &MainWindow::onPileFavoriteFilterToggled);
    connect(m_subNavReserve, &QPushButton::clicked, this, [this]() { onChargeSubNav(0); });
    connect(m_subNavMyReserve, &QPushButton::clicked, this, [this]() { onChargeSubNav(1); });
    connect(m_subNavCharge, &QPushButton::clicked, this, [this]() { onChargeSubNav(2); });
    connect(m_navStations, &QPushButton::clicked, this, [this]() { onBottomNav(0); });
    connect(m_navCharge, &QPushButton::clicked, this, [this]() { onBottomNav(1); });
    connect(m_navProfile, &QPushButton::clicked, this, [this]() { onBottomNav(2); });
    connect(ui->saveBtn, &QPushButton::clicked, this, &MainWindow::onSaveProfile);
    connect(ui->avatarBtn, &QPushButton::clicked, this, &MainWindow::onChooseAvatar);
    connect(ui->rechargeBtn, &QPushButton::clicked, this, &MainWindow::onRecharge);
    connect(m_darkModeBtn, &QPushButton::toggled, this, &MainWindow::onToggleDarkMode);
    connect(ui->refreshOrdersBtn, &QPushButton::clicked, this, &MainWindow::refreshOrders);
    connect(ui->logoutBtn, &QPushButton::clicked, this, &MainWindow::onLogout);
    connect(ui->quick50Btn, &QPushButton::clicked, this, [this]() { m_rechargeEdit->setText(QStringLiteral("50")); });
    connect(ui->quick100Btn, &QPushButton::clicked, this, [this]() { m_rechargeEdit->setText(QStringLiteral("100")); });
    connect(ui->quick200Btn, &QPushButton::clicked, this, [this]() { m_rechargeEdit->setText(QStringLiteral("200")); });
    connect(ui->quick500Btn, &QPushButton::clicked, this, [this]() { m_rechargeEdit->setText(QStringLiteral("500")); });
    connect(m_stationList, &QListWidget::itemClicked, this, &MainWindow::onStationItemClicked);
    applyTheme(m_darkMode);
}

void MainWindow::buildStationDetailPage()
{
    // 盖在 stationsPage 上的浮层；默认隐藏，不拦截列表页点击
    m_stationDetailPage = new QWidget(ui->stationsPage);
    m_stationDetailPage->setObjectName(QStringLiteral("centralRoot"));
    m_stationDetailPage->setAttribute(Qt::WA_StyledBackground, true);
    m_stationDetailPage->setGeometry(0, 0, 0, 0);
    m_stationDetailPage->hide();
    m_stationDetailPage->setVisible(false);

    auto *root = new QVBoxLayout(m_stationDetailPage);
    root->setContentsMargins(14, 12, 14, 8);
    root->setSpacing(10);

    auto *top = new QHBoxLayout;
    m_detailBackBtn = new QPushButton(QStringLiteral("← 返回"));
    m_detailBackBtn->setObjectName(QStringLiteral("secondaryBtn"));
    m_detailBackBtn->setFixedWidth(96);
    top->addWidget(m_detailBackBtn);
    top->addStretch();
    root->addLayout(top);

    m_detailTitle = new QLabel;
    m_detailTitle->setObjectName(QStringLiteral("pageTitle"));
    m_detailTitle->setWordWrap(true);
    root->addWidget(m_detailTitle);

    m_detailStars = new QLabel;
    m_detailStars->setObjectName(QStringLiteral("starLabel"));
    m_detailStars->setWordWrap(true);
    root->addWidget(m_detailStars);

    m_detailAddress = new QLabel;
    m_detailAddress->setObjectName(QStringLiteral("muted"));
    m_detailAddress->setWordWrap(true);
    root->addWidget(m_detailAddress);

    m_detailMeta = new QLabel;
    m_detailMeta->setObjectName(QStringLiteral("muted"));
    m_detailMeta->setWordWrap(true);
    root->addWidget(m_detailMeta);

    auto *actions = new QHBoxLayout;
    m_detailNavBtn = new QPushButton(QStringLiteral("导航"));
    m_detailFavBtn = new QPushButton(QStringLiteral("收藏"));
    m_detailFavBtn->setObjectName(QStringLiteral("secondaryBtn"));
    m_detailChargeBtn = new QPushButton(QStringLiteral("去充电"));
    actions->addWidget(m_detailNavBtn);
    actions->addWidget(m_detailFavBtn);
    actions->addWidget(m_detailChargeBtn);
    root->addLayout(actions);

    auto *reviewTitle = new QLabel(QStringLiteral("用户评价"));
    reviewTitle->setObjectName(QStringLiteral("pageTitle"));
    root->addWidget(reviewTitle);

    m_detailReviewList = new QListWidget;
    prepareCardList(m_detailReviewList);
    root->addWidget(m_detailReviewList, 1);

    connect(m_detailBackBtn, &QPushButton::clicked, this, &MainWindow::onStationDetailBack);
    connect(m_detailFavBtn, &QPushButton::clicked, this, &MainWindow::onStationDetailFavorite);
    connect(m_detailNavBtn, &QPushButton::clicked, this, &MainWindow::onStationDetailNavigate);
    connect(m_detailChargeBtn, &QPushButton::clicked, this, &MainWindow::onStationDetailGoCharge);
    connect(m_detailReviewList, &QListWidget::itemClicked,
            this, &MainWindow::onReviewItemClicked);
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
    if (index == 0) {
        if (m_stationDetailPage)
            m_stationDetailPage->hide();
        refreshStations();
    }
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

void MainWindow::updateChargeSubNavActive(int index)
{
    auto setActive = [](QPushButton *btn, bool on) {
        if (!btn)
            return;
        btn->setProperty("active", on);
        btn->style()->unpolish(btn);
        btn->style()->polish(btn);
        btn->update();
    };
    setActive(m_subNavReserve, index == 0);
    setActive(m_subNavMyReserve, index == 1);
    setActive(m_subNavCharge, index == 2);
}

void MainWindow::onChargeSubNav(int index)
{
    if (!m_chargeSubStack)
        return;
    m_chargeSubStack->setCurrentIndex(index);
    updateChargeSubNavActive(index);
    if (index == 0)
        refreshPilesForCharge();
    if (index == 1)
        updateReservationCountdown();
    if (index == 2)
        refreshOngoingBanner();
}

void MainWindow::applyUserLocation(const QString &regionOrAddress)
{
    const QString text = regionOrAddress.trimmed();
    const auto coords = realDistrictCoords(text.isEmpty() ? QStringLiteral("天安门") : text);
    m_userLat = coords.first;
    m_userLng = coords.second;
    if (text.isEmpty())
        m_userAddress = QStringLiteral("北京市东城区天安门");
    else if (text.contains(QStringLiteral("北京")))
        m_userAddress = text;
    else
        m_userAddress = QStringLiteral("北京市%1").arg(text);
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
    if (!m_locationProvider)
        return;
    if (m_locationProvider->isBusy()) {
        showLargeMessage(this, QMessageBox::Information, QStringLiteral("定位中"),
                         QStringLiteral("正在获取位置，请稍候…"));
        return;
    }
    if (m_locateBtn) {
        m_locateBtn->setEnabled(false);
        m_locateBtn->setText(QStringLiteral("定位中…"));
    }
    m_locationLabel->setText(QStringLiteral("正在检测真实当前位置…"));
    m_locationProvider->requestCurrentLocation();
}

void MainWindow::onRealLocationUpdated(double lat, double lng, const QString &label, const QString &source)
{
    const bool inBeijing = (lat >= 39.4 && lat <= 41.1 && lng >= 115.4 && lng <= 117.6);
    if (!inBeijing && source == QLatin1String("IP")) {
        applyUserLocation(QStringLiteral("天安门"));
        m_locationSource = QStringLiteral("fallback");
        m_userAddress = QStringLiteral("公网定位不在北京，已使用演示坐标（天安门）");
        if (m_locateBtn) {
            m_locateBtn->setEnabled(true);
            m_locateBtn->setText(QStringLiteral("定位"));
        }
        refreshStations();
        showLargeMessage(this, QMessageBox::Warning, QStringLiteral("定位提示"),
                         QStringLiteral("检测到公网出口不在北京，已自动切回演示坐标。\n"
                                        "也可手动输入「朝阳区」「国贸」等后点定位。"));
        return;
    }

    m_userLat = lat;
    m_userLng = lng;
    m_userAddress = label;
    m_locationSource = source;
    if (m_locateBtn) {
        m_locateBtn->setEnabled(true);
        m_locateBtn->setText(QStringLiteral("定位"));
    }
    if (m_addressEdit && !label.isEmpty())
        m_addressEdit->setText(label);
    refreshStations();
}

void MainWindow::onRealLocationFailed(const QString &reason)
{
    if (m_locateBtn) {
        m_locateBtn->setEnabled(true);
        m_locateBtn->setText(QStringLiteral("定位"));
    }
    m_locationLabel->setText(QStringLiteral("%1（可手动输入地址后回车）").arg(reason));
    if (m_locationSource == QLatin1String("pending")
        || m_locationSource == QLatin1String("fallback")) {
        applyUserLocation(QStringLiteral("天安门"));
        m_locationSource = QStringLiteral("fallback");
        refreshStations();
    }
    showLargeMessage(this, QMessageBox::Warning, QStringLiteral("定位失败"),
                     reason + QStringLiteral("\n\n可在输入框填写「海淀区」「望京」等后再次定位。"));
}

void MainWindow::onLocate()
{
    const QString address = m_addressEdit ? m_addressEdit->text().trimmed() : QString();
    if (!address.isEmpty()) {
        applyUserLocation(address);
        m_locationSource = QStringLiteral("manual");
        refreshStations();
        statusBar()->showMessage(QStringLiteral("已按手动地址定位"), 2500);
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
    if (m_detailStation.id > 0)
        syncChargeStationSelection(m_detailStation.id);
    else if (!m_cachedStations.isEmpty())
        syncChargeStationSelection(m_cachedStations.first().id);
    else
        refreshPilesForCharge();
}

void MainWindow::appendStationItem(const Station &s)
{
    const bool fav = isFavorite(s.id);
    const QString text = QStringLiteral("%1\n%2\n%3 · %4\n距离 %5 km · 空闲 %6/%7 · %8")
                             .arg(s.name, ratingSummary(s.avgRating, s.reviewCount))
                             .arg(s.regionCode, s.address)
                             .arg(s.distanceKm, 0, 'f', 2)
                             .arg(s.idlePiles)
                             .arg(s.totalPiles)
                             .arg(statusTextStation(s.status));
    auto *item = new QListWidgetItem(text, m_stationList);
    item->setSizeHint(QSize(0, cardItemHeight(m_stationList, 4)));
    item->setData(Qt::UserRole, s.id);
    item->setData(Qt::UserRole + 1, s.latitude);
    item->setData(Qt::UserRole + 2, s.longitude);
    item->setData(Qt::UserRole + 3, s.name);
    item->setData(Qt::UserRole + 4, s.address);
    item->setData(Qt::UserRole + 5, s.avgRating);
    item->setData(Qt::UserRole + 6, s.reviewCount);
    item->setData(Qt::UserRole + 7, s.distanceKm);
    item->setData(Qt::UserRole + 8, s.idlePiles);
    item->setData(Qt::UserRole + 9, s.totalPiles);
    item->setData(Qt::UserRole + 10, s.status);
    item->setData(Qt::UserRole + 11, s.regionCode);
    item->setData(Qt::UserRole + 12, s.openHours);
    item->setData(kFavoriteRole, fav);
}

bool MainWindow::eventFilter(QObject *watched, QEvent *event)
{
    if (watched == ui->stationsPage && event->type() == QEvent::Resize)
        syncStationDetailGeometry();
    return QMainWindow::eventFilter(watched, event);
}

void MainWindow::syncStationDetailGeometry()
{
    if (!m_stationDetailPage || !ui->stationsPage)
        return;
    m_stationDetailPage->setGeometry(ui->stationsPage->rect());
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
        showLargeMessage(this, QMessageBox::Information, QStringLiteral("提示"),
                         QStringLiteral("请先选择一个充电站"));
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

Station MainWindow::stationFromListItem(QListWidgetItem *item) const
{
    Station s;
    if (!item)
        return s;
    s.id = item->data(Qt::UserRole).toInt();
    s.latitude = item->data(Qt::UserRole + 1).toDouble();
    s.longitude = item->data(Qt::UserRole + 2).toDouble();
    s.name = item->data(Qt::UserRole + 3).toString();
    s.address = item->data(Qt::UserRole + 4).toString();
    s.avgRating = item->data(Qt::UserRole + 5).toDouble();
    s.reviewCount = item->data(Qt::UserRole + 6).toInt();
    s.distanceKm = item->data(Qt::UserRole + 7).toDouble();
    s.idlePiles = item->data(Qt::UserRole + 8).toInt();
    s.totalPiles = item->data(Qt::UserRole + 9).toInt();
    s.status = item->data(Qt::UserRole + 10).toString();
    s.regionCode = item->data(Qt::UserRole + 11).toString();
    s.openHours = item->data(Qt::UserRole + 12).toString();
    for (const Station &cached : m_cachedStations) {
        if (cached.id == s.id)
            return cached;
    }
    return s;
}

void MainWindow::syncChargeStationSelection(int stationId)
{
    if (!m_stationCombo || stationId <= 0)
        return;
    const int idx = m_stationCombo->findData(stationId);
    if (idx < 0)
        return;
    m_stationCombo->blockSignals(true);
    m_stationCombo->setCurrentIndex(idx);
    m_stationCombo->blockSignals(false);
    refreshPilesForCharge();
}

void MainWindow::onStationItemClicked(QListWidgetItem *item)
{
    const Station s = stationFromListItem(item);
    if (s.id <= 0)
        return;
    syncChargeStationSelection(s.id);
    showStationDetail(s);
}

void MainWindow::showStationDetail(const Station &station)
{
    m_detailStation = station;
    if (m_detailTitle)
        m_detailTitle->setText(station.name);
    if (m_detailStars) {
        m_detailStars->setText(ratingSummary(station.avgRating, station.reviewCount));
        m_detailStars->setStyleSheet(QStringLiteral(
            "color:#F5A623;font-size:22px;font-weight:600;"));
    }
    if (m_detailAddress)
        m_detailAddress->setText(QStringLiteral("%1 · %2").arg(station.regionCode, station.address));
    if (m_detailMeta) {
        m_detailMeta->setText(
            QStringLiteral("距离 %1 km · 空闲 %2/%3 · %4 · 营业 %5")
                .arg(station.distanceKm, 0, 'f', 2)
                .arg(station.idlePiles)
                .arg(station.totalPiles)
                .arg(statusTextStation(station.status))
                .arg(station.openHours.isEmpty() ? QStringLiteral("—") : station.openHours));
    }
    if (m_detailFavBtn)
        m_detailFavBtn->setText(isFavorite(station.id) ? QStringLiteral("取消收藏")
                                                       : QStringLiteral("收藏"));

    if (m_detailReviewList) {
        m_detailReviewList->clear();
        const auto reviews = ServerApiClient::instance().listStationReviews(station.id, 40);
        if (reviews.isEmpty()) {
            auto *empty = new QListWidgetItem(QStringLiteral("暂无评价，充电完成后可以留下第一条点评。"),
                                              m_detailReviewList);
            empty->setFlags(empty->flags() & ~Qt::ItemIsSelectable);
        } else {
            for (const StationReview &r : reviews) {
                const QString who = r.nickname.isEmpty()
                                        ? QStringLiteral("匿名用户")
                                        : r.nickname;
                const QString text = QStringLiteral("%1  %2\n%3\n%4")
                                        .arg(starsText(r.rating), who, r.comment,
                                             r.createdAt);
                auto *it = new QListWidgetItem(text, m_detailReviewList);
                it->setData(Qt::UserRole + 1, r.rating);
                it->setData(Qt::UserRole + 2, who);
                it->setData(Qt::UserRole + 3, r.comment);
                it->setData(Qt::UserRole + 4, r.createdAt);
                it->setToolTip(QStringLiteral("点击查看完整评价"));
                it->setSizeHint(QSize(200, cardItemHeight(m_detailReviewList, 3)));
            }
        }
    }

    syncStationDetailGeometry();
    m_stationDetailPage->raise();
    m_stationDetailPage->show();
    m_stationDetailPage->setFocus();
}

void MainWindow::onReviewItemClicked(QListWidgetItem *item)
{
    if (!item || !item->data(Qt::UserRole + 3).isValid())
        return;

    QDialog dialog(this);
    dialog.setWindowTitle(QStringLiteral("评价详情"));
    dialog.setMinimumSize(440, 320);
    dialog.setStyleSheet(styleSheet());
    auto *layout = new QVBoxLayout(&dialog);
    layout->setContentsMargins(22, 18, 22, 16);
    layout->setSpacing(10);

    auto *title = new QLabel(QStringLiteral("%1  %2")
                                 .arg(starsText(item->data(Qt::UserRole + 1).toInt()),
                                      item->data(Qt::UserRole + 2).toString()),
                             &dialog);
    title->setObjectName(QStringLiteral("pageTitle"));
    auto *time = new QLabel(item->data(Qt::UserRole + 4).toString(), &dialog);
    time->setObjectName(QStringLiteral("muted"));
    auto *content = new QTextEdit(&dialog);
    content->setReadOnly(true);
    content->setPlainText(item->data(Qt::UserRole + 3).toString());
    content->setMinimumHeight(150);
    content->setObjectName(QStringLiteral("reviewContent"));
    auto *buttons = new QDialogButtonBox(QDialogButtonBox::Close, &dialog);
    connect(buttons, &QDialogButtonBox::rejected, &dialog, &QDialog::reject);

    layout->addWidget(title);
    layout->addWidget(time);
    layout->addWidget(content, 1);
    layout->addWidget(buttons);
    dialog.exec();
}

void MainWindow::onStationDetailBack()
{
    if (!m_stationDetailPage)
        return;
    m_stationDetailPage->hide();
    m_stationDetailPage->setGeometry(0, 0, 0, 0);
}

void MainWindow::onStationDetailFavorite()
{
    if (m_detailStation.id <= 0)
        return;
    setFavorite(m_detailStation.id, !isFavorite(m_detailStation.id));
    if (m_detailFavBtn)
        m_detailFavBtn->setText(isFavorite(m_detailStation.id) ? QStringLiteral("取消收藏")
                                                               : QStringLiteral("收藏"));
    statusBar()->showMessage(isFavorite(m_detailStation.id) ? QStringLiteral("已加入收藏")
                                                            : QStringLiteral("已取消收藏"),
                             2500);
    const Station keep = m_detailStation;
    refreshStations();
    showStationDetail(keep);
}

void MainWindow::onStationDetailNavigate()
{
    if (m_detailStation.id <= 0)
        return;
    m_navInfo->setText(QStringLiteral("导航目标：%1\n%2\n坐标：（%3, %4）")
                           .arg(m_detailStation.name, m_detailStation.address)
                           .arg(m_detailStation.latitude, 0, 'f', 6)
                           .arg(m_detailStation.longitude, 0, 'f', 6));
    QUrl url(QStringLiteral("https://apis.map.qq.com/uri/v1/routeplan"));
    QUrlQuery query;
    query.addQueryItem(QStringLiteral("type"), QStringLiteral("drive"));
    query.addQueryItem(QStringLiteral("from"), m_userAddress);
    query.addQueryItem(QStringLiteral("fromcoord"),
                       QStringLiteral("%1,%2").arg(m_userLat, 0, 'f', 6).arg(m_userLng, 0, 'f', 6));
    query.addQueryItem(QStringLiteral("to"), m_detailStation.name);
    query.addQueryItem(QStringLiteral("tocoord"),
                       QStringLiteral("%1,%2")
                           .arg(m_detailStation.latitude, 0, 'f', 6)
                           .arg(m_detailStation.longitude, 0, 'f', 6));
    query.addQueryItem(QStringLiteral("policy"), QStringLiteral("0"));
    query.addQueryItem(QStringLiteral("referer"), QStringLiteral("ChargePileLab"));
    url.setQuery(query);
    QDesktopServices::openUrl(url);
}

void MainWindow::onStationDetailGoCharge()
{
    if (m_detailStation.id <= 0)
        return;
    syncChargeStationSelection(m_detailStation.id);
    onBottomNav(1);
    onChargeSubNav(0);
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
        if (m_pileFavOnlyCheck && m_pileFavOnlyCheck->isChecked() && !p.favorite && !isPileFavorite(p.id))
            continue;
        const bool fav = p.favorite || isPileFavorite(p.id);
        const QString text = QStringLiteral("%1%2\n%3\n%4 kW · ¥%5/kWh · %6")
                                 .arg(fav ? QStringLiteral("★ ") : QString(), p.pileCode)
                                 .arg(pileCategoryText(p))
                                 .arg(p.powerKw, 0, 'f', 1)
                                 .arg(p.pricePerKwh, 0, 'f', 2)
                                 .arg(statusTextPile(p.status));
        auto *item = new QListWidgetItem(text, m_pileList);
        item->setSizeHint(QSize(qMax(m_pileList->viewport()->width(), 240),
                                cardItemHeight(m_pileList, 3)));
        item->setData(Qt::UserRole, p.id);
        item->setData(Qt::UserRole + 1, p.pricePerKwh);
        item->setData(Qt::UserRole + 2, p.powerKw);
        item->setData(Qt::UserRole + 3, p.status);
        item->setData(Qt::UserRole + 4, p.stationId);
        item->setData(kFavoriteRole, fav);
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
        showLargeMessage(this, QMessageBox::Information, QStringLiteral("提示"),
                         QStringLiteral("请先选择一个空闲充电桩"));
        return;
    }
    ChargingReservation reservation;
    if (!ServerApiClient::instance().createReservation(pileId, reservation)) {
        showLargeMessage(this, QMessageBox::Warning, QStringLiteral("预约失败"),
                         ServerApiClient::instance().lastError());
        return;
    }
    m_reservation = reservation;
    refreshPilesForCharge();
    updateReservationCountdown();
    onChargeSubNav(1);
    showLargeMessage(this, QMessageBox::Information, QStringLiteral("预约成功"),
                     QStringLiteral("电桩已为您保留至 %1\n可在「我的预约」查看详情。")
                         .arg(reservation.expiresAt));
}

void MainWindow::onCancelReservation()
{
    if (m_reservation.id <= 0) {
        showLargeMessage(this, QMessageBox::Information, QStringLiteral("提示"),
                         QStringLiteral("当前没有有效预约"));
        return;
    }
    if (!ServerApiClient::instance().cancelReservation(m_reservation.id)) {
        showLargeMessage(this, QMessageBox::Warning, QStringLiteral("取消失败"),
                         ServerApiClient::instance().lastError());
        return;
    }
    m_reservation = ChargingReservation{};
    updateReservationCountdown();
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
        if (m_chargeBanner) {
            m_chargeBanner->setText(QStringLiteral("正在充电：%1 / %2 · 已充 %3 kWh · 预估 ¥%4")
                                        .arg(order.stationName, order.pileCode)
                                        .arg(m_simulatedEnergy, 0, 'f', 2)
                                        .arg(m_simulatedEnergy * m_currentPrice, 0, 'f', 2));
            m_chargeBanner->show();
        }
    } else {
        m_ongoing = ChargingOrder{};
        m_chargeTimer->stop();
        m_simulatedEnergy = 0;
        m_chargeProgress->setValue(0);
        m_chargeInfo->setText(QStringLiteral("当前无进行中的充电，可按分类筛选空闲桩后开始"));
        if (m_chargeBanner)
            m_chargeBanner->hide();
    }
}

void MainWindow::onStartCharge()
{
    const int pileId = selectedPileId();
    if (pileId <= 0) {
        showLargeMessage(this, QMessageBox::Information, QStringLiteral("提示"),
                         QStringLiteral("请选择一个空闲充电桩"));
        return;
    }

    ServerApiClient::instance().getUserById(m_user.id, m_user);
    if (m_user.balance < 10.0) {
        showLargeMessage(this, QMessageBox::Warning, QStringLiteral("余额不足"),
                         QStringLiteral("当前余额 ¥%1，至少需要保留 10 元才能开始充电，请先充值。")
                             .arg(m_user.balance, 0, 'f', 2));
        return;
    }

    ChargingOrder order;
    if (!ServerApiClient::instance().startCharging(m_user.id, pileId, order)) {
        showLargeMessage(this, QMessageBox::Warning, QStringLiteral("无法开始充电"),
                         ServerApiClient::instance().lastError());
        return;
    }

    auto *item = m_pileList->currentItem();
    m_currentPrice = item ? item->data(Qt::UserRole + 1).toDouble() : 1.2;
    m_currentPowerKw = item ? item->data(Qt::UserRole + 2).toDouble() : 7.0;
    m_lastFinishedStationId = item ? item->data(Qt::UserRole + 4).toInt() : 0;
    m_ongoing = order;
    m_reservation = ChargingReservation{};
    m_simulatedEnergy = 0;
    m_progressTick = 0;
    m_balanceWarned = false;
    m_chargeTimer->start();
    refreshPilesForCharge();
    refreshOngoingBanner();
    showLargeMessage(this, QMessageBox::Information, QStringLiteral("已开始充电"),
                     QStringLiteral("订单号：%1\n当前余额 ¥%2，请留意费用。")
                         .arg(order.orderNo)
                         .arg(m_user.balance, 0, 'f', 2));
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
            showLargeMessage(this, QMessageBox::Warning, QStringLiteral("服务连接异常"),
                             ServerApiClient::instance().lastError());
            return;
        }
    }
    const double fee = m_simulatedEnergy * m_currentPrice;
    m_chargeInfo->setText(QStringLiteral("充电中：%1 / %2\n订单 %3\n已充电 %4 kWh，预估 ¥%5\n账户余额 ¥%6")
                              .arg(m_ongoing.stationName, m_ongoing.pileCode, m_ongoing.orderNo)
                              .arg(m_simulatedEnergy, 0, 'f', 3)
                              .arg(fee, 0, 'f', 2)
                              .arg(m_user.balance, 0, 'f', 2));
    m_chargeProgress->setValue(qMin(100, int(m_simulatedEnergy * 3)));
    if (m_chargeBanner && m_chargeBanner->isVisible()) {
        m_chargeBanner->setText(QStringLiteral("正在充电：%1 / %2 · 已充 %3 kWh · 预估 ¥%4")
                                    .arg(m_ongoing.stationName, m_ongoing.pileCode)
                                    .arg(m_simulatedEnergy, 0, 'f', 2)
                                    .arg(fee, 0, 'f', 2));
    }

    // 余额预警：费用接近余额时提示；达到余额自动结束
    if (!m_balanceWarned && fee >= qMax(0.0, m_user.balance - 5.0) && fee < m_user.balance) {
        m_balanceWarned = true;
        showLargeMessage(this, QMessageBox::Warning, QStringLiteral("余额预警"),
                         QStringLiteral("预估费用已接近账户余额（余额 ¥%1 / 预估 ¥%2）。\n"
                                        "请尽快结束充电或充值，避免扣款失败。")
                             .arg(m_user.balance, 0, 'f', 2)
                             .arg(fee, 0, 'f', 2));
    }
    if (fee >= m_user.balance && m_user.balance > 0) {
        m_chargeTimer->stop();
        showLargeMessage(this, QMessageBox::Warning, QStringLiteral("余额不足"),
                         QStringLiteral("预估费用已达到当前余额，系统将自动结束充电。"));
        onStopCharge();
    }
}

void MainWindow::onStopCharge()
{
    if (m_ongoing.id <= 0) {
        showLargeMessage(this, QMessageBox::Information, QStringLiteral("提示"),
                         QStringLiteral("当前没有进行中的充电"));
        return;
    }

    const QString stationName = m_ongoing.stationName;
    const int orderId = m_ongoing.id;
    int stationId = m_lastFinishedStationId;
    if (stationId <= 0) {
        Pile pile;
        if (ServerApiClient::instance().getPile(m_ongoing.pileId, pile))
            stationId = pile.stationId;
    }

    const double energy = qMax(0.5, m_simulatedEnergy);
    ChargingOrder finished;
    if (!ServerApiClient::instance().stopCharging(m_ongoing.id, energy, finished)) {
        showLargeMessage(this, QMessageBox::Warning, QStringLiteral("结束失败"),
                         ServerApiClient::instance().lastError());
        return;
    }

    if (stationId <= 0 && finished.pileId > 0) {
        Pile pile;
        if (ServerApiClient::instance().getPile(finished.pileId, pile))
            stationId = pile.stationId;
    }

    m_chargeTimer->stop();
    m_ongoing = ChargingOrder{};
    m_balanceWarned = false;
    ServerApiClient::instance().getUserById(m_user.id, m_user);
    refreshPilesForCharge();
    refreshOngoingBanner();
    refreshProfile();
    refreshOrders();

    showLargeMessage(this, QMessageBox::Information, QStringLiteral("充电完成"),
                     QStringLiteral("订单 %1 已结算\n电量 %2 kWh\n费用 ¥%3\n余额 ¥%4")
                         .arg(finished.orderNo)
                         .arg(finished.energyKwh, 0, 'f', 2)
                         .arg(finished.amount, 0, 'f', 2)
                         .arg(m_user.balance, 0, 'f', 2));

    promptStationReview(stationId, orderId,
                        stationName.isEmpty() ? QStringLiteral("本次充电电站") : stationName);
}

void MainWindow::promptStationReview(int stationId, int orderId, const QString &stationName)
{
    QDialog dlg(this);
    dlg.setWindowTitle(QStringLiteral("评价充电站"));
    dlg.setMinimumWidth(400);
    dlg.setStyleSheet(styleSheet());
    auto *layout = new QVBoxLayout(&dlg);
    layout->setContentsMargins(20, 18, 20, 16);
    layout->setSpacing(12);
    auto *title = new QLabel(QStringLiteral("为「%1」评星并留下评价").arg(stationName), &dlg);
    title->setObjectName(QStringLiteral("pageTitle"));
    title->setWordWrap(true);
    auto *starHint = new QLabel(QStringLiteral("点击星星选择 5 星"), &dlg);
    starHint->setObjectName(QStringLiteral("muted"));

    auto *starsWrap = new QWidget(&dlg);
    auto *starsLayout = new QHBoxLayout(starsWrap);
    starsLayout->setContentsMargins(0, 4, 0, 4);
    starsLayout->setSpacing(6);
    QVector<QPushButton *> starBtns;
    int currentRating = 5;
    auto refreshStars = [&]() {
        starHint->setText(QStringLiteral("已选择 %1 星，点击星星可修改").arg(currentRating));
        for (int i = 0; i < starBtns.size(); ++i)
            applyStarVisual(starBtns.at(i), i < currentRating);
    };
    for (int i = 1; i <= 5; ++i) {
        auto *btn = new QPushButton(starsWrap);
        btn->setObjectName(QStringLiteral("starBtn"));
        btn->setCursor(Qt::PointingHandCursor);
        btn->setFlat(true);
        btn->setFocusPolicy(Qt::NoFocus);
        btn->setFixedSize(40, 40);
        const int star = i;
        QObject::connect(btn, &QPushButton::clicked, &dlg, [&currentRating, star, refreshStars]() {
            currentRating = star;
            refreshStars();
        });
        starBtns.push_back(btn);
        starsLayout->addWidget(btn);
    }
    starsLayout->addStretch();
    refreshStars();

    auto *comment = new QTextEdit(&dlg);
    comment->setPlaceholderText(QStringLiteral("可选：写出你的充电体验…"));
    comment->setMinimumHeight(120);
    auto *buttons = new QDialogButtonBox(QDialogButtonBox::Ok | QDialogButtonBox::Cancel, &dlg);
    buttons->button(QDialogButtonBox::Ok)->setText(QStringLiteral("提交评价"));
    buttons->button(QDialogButtonBox::Cancel)->setText(QStringLiteral("跳过"));
    layout->addWidget(title);
    layout->addWidget(starHint);
    layout->addWidget(starsWrap);
    layout->addWidget(comment, 1);
    layout->addWidget(buttons);
    connect(buttons, &QDialogButtonBox::accepted, &dlg, &QDialog::accept);
    connect(buttons, &QDialogButtonBox::rejected, &dlg, &QDialog::reject);
    if (dlg.exec() != QDialog::Accepted)
        return;

    StationReview review;
    if (!ServerApiClient::instance().submitStationReview(
            stationId, orderId, currentRating, comment->toPlainText().trimmed(), review)) {
        showLargeMessage(this, QMessageBox::Warning, QStringLiteral("评价失败"),
                         ServerApiClient::instance().lastError());
        return;
    }
    showLargeMessage(this, QMessageBox::Information, QStringLiteral("感谢评价"),
                     QStringLiteral("已提交 %1 星评价，其他用户可看到该站平均星级。")
                         .arg(currentRating));
    refreshStations();
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
        showLargeMessage(this, QMessageBox::Warning, QStringLiteral("保存失败"),
                         ServerApiClient::instance().lastError());
        return;
    }
    showLargeMessage(this, QMessageBox::Information, QStringLiteral("成功"),
                     QStringLiteral("个人信息已更新"));
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
        showLargeMessage(this, QMessageBox::Warning, QStringLiteral("头像无效"),
                         QStringLiteral("无法读取所选图片"));
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
        showLargeMessage(this, QMessageBox::Warning, QStringLiteral("提示"),
                         QStringLiteral("请输入有效的充值金额"));
        return;
    }
    if (!ServerApiClient::instance().rechargeUser(m_user.id, amount)) {
        showLargeMessage(this, QMessageBox::Warning, QStringLiteral("充值失败"),
                         ServerApiClient::instance().lastError());
        return;
    }
    m_rechargeEdit->clear();
    refreshProfile();
    showLargeMessage(this, QMessageBox::Information, QStringLiteral("充值成功"),
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
    QVector<int> stations;
    QVector<int> piles;
    if (ServerApiClient::instance().listFavorites(stations, piles)) {
        m_favoriteIds = QSet<int>(stations.begin(), stations.end());
        m_favoritePileIds = QSet<int>(piles.begin(), piles.end());
        return;
    }
    QSettings settings;
    const QVariantList list = settings.value(
        QStringLiteral("favorites/%1").arg(m_user.id)).toList();
    m_favoriteIds.clear();
    for (const QVariant &v : list)
        m_favoriteIds.insert(v.toInt());
}

void MainWindow::saveFavorites()
{
}

bool MainWindow::isFavorite(int stationId) const
{
    return m_favoriteIds.contains(stationId);
}

bool MainWindow::isPileFavorite(int pileId) const
{
    return m_favoritePileIds.contains(pileId);
}

void MainWindow::setFavorite(int stationId, bool)
{
    bool nowFav = false;
    if (!ServerApiClient::instance().toggleFavorite(QStringLiteral("station"), stationId, nowFav)) {
        showLargeMessage(this, QMessageBox::Warning, QStringLiteral("收藏失败"),
                         ServerApiClient::instance().lastError());
        return;
    }
    if (nowFav)
        m_favoriteIds.insert(stationId);
    else
        m_favoriteIds.remove(stationId);
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
        showLargeMessage(this, QMessageBox::Information, QStringLiteral("提示"),
                         QStringLiteral("请先选中一个充电站"));
        return;
    }
    setFavorite(id, !isFavorite(id));
    syncChargeStationSelection(id);
    statusBar()->showMessage(isFavorite(id) ? QStringLiteral("已加入收藏")
                                            : QStringLiteral("已取消收藏"), 2500);
    refreshStations();
}

void MainWindow::onTogglePileFavorite()
{
    const int pileId = selectedPileId();
    if (pileId <= 0) {
        showLargeMessage(this, QMessageBox::Information, QStringLiteral("提示"),
                         QStringLiteral("请先选中一个充电桩"));
        return;
    }
    bool nowFav = false;
    if (!ServerApiClient::instance().toggleFavorite(QStringLiteral("pile"), pileId, nowFav)) {
        showLargeMessage(this, QMessageBox::Warning, QStringLiteral("收藏失败"),
                         ServerApiClient::instance().lastError());
        return;
    }
    if (nowFav)
        m_favoritePileIds.insert(pileId);
    else
        m_favoritePileIds.remove(pileId);
    statusBar()->showMessage(nowFav ? QStringLiteral("已收藏该电桩")
                                    : QStringLiteral("已取消电桩收藏"), 2500);
    refreshPilesForCharge();
}

void MainWindow::onFavoriteFilterToggled(bool)
{
    refreshStations();
}

void MainWindow::onPileFavoriteFilterToggled(bool)
{
    refreshPilesForCharge();
}

void MainWindow::onLogout()
{
    m_loggingOut = true;
    emit logoutRequested();
}

void MainWindow::closeEvent(QCloseEvent *event)
{
    event->accept();
    if (!m_loggingOut)
        QApplication::quit();
}

void MainWindow::updateReservationCountdown()
{
    if (!m_reservationInfo)
        return;
    if (m_reservation.id <= 0) {
        m_reservationInfo->setText(
            QStringLiteral("当前无有效预约\n\n请在「预约」页选择空闲电桩进行预约。"));
        return;
    }

    const QDateTime expires = QDateTime::fromString(m_reservation.expiresAt,
                                                    QStringLiteral("yyyy-MM-dd HH:mm:ss"));
    if (!expires.isValid()) {
        m_reservationInfo->setText(
            QStringLiteral("站点：%1\n电桩：%2\n预约号：%3\n到期时间：%4")
                .arg(m_reservation.stationName, m_reservation.pileCode,
                     m_reservation.reservationNo, m_reservation.expiresAt));
        return;
    }

    const qint64 secs = QDateTime::currentDateTime().secsTo(expires);
    if (secs <= 0) {
        m_reservationInfo->setText(QStringLiteral("预约已到期，正在刷新…"));
        m_reservation = ChargingReservation{};
        QTimer::singleShot(300, this, &MainWindow::refreshPilesForCharge);
        return;
    }

    const int mm = int(secs / 60);
    const int ss = int(secs % 60);
    m_reservationInfo->setText(
        QStringLiteral("站点：%1\n电桩：%2\n预约号：%3\n剩余时间：%4:%5\n到期时间：%6")
            .arg(m_reservation.stationName, m_reservation.pileCode, m_reservation.reservationNo)
            .arg(mm, 2, 10, QChar('0'))
            .arg(ss, 2, 10, QChar('0'))
            .arg(m_reservation.expiresAt));
}

void MainWindow::onReservationTick()
{
    updateReservationCountdown();
}

void MainWindow::loadInitialData()
{
    loadFavorites();
    refreshStations();
    refreshProfile();
    refreshOrders();
    refreshOngoingBanner();
    restoreSession();
}

void MainWindow::restoreSession()
{
    if (m_sessionRestored)
        return;
    m_sessionRestored = true;

    QStringList recovered;
    if (m_ongoing.id > 0) {
        recovered << QStringLiteral("进行中订单 %1（%2 / %3，已充 %4 kWh）")
                         .arg(m_ongoing.orderNo, m_ongoing.stationName, m_ongoing.pileCode)
                         .arg(m_ongoing.energyKwh, 0, 'f', 2);
        onBottomNav(1);
        onChargeSubNav(2);
    }

    if (m_reservation.id > 0) {
        recovered << QStringLiteral("有效预约 %1（%2 / %3，到期 %4）")
                         .arg(m_reservation.reservationNo, m_reservation.stationName,
                              m_reservation.pileCode, m_reservation.expiresAt);
        updateReservationCountdown();
        if (m_ongoing.id <= 0) {
            onBottomNav(1);
            onChargeSubNav(1);
        }
    }

    if (!recovered.isEmpty()) {
        statusBar()->showMessage(QStringLiteral("已恢复会话"), 4000);
        showLargeMessage(this, QMessageBox::Information, QStringLiteral("会话恢复"),
                         QStringLiteral("检测到未完成业务，已为您恢复：\n\n- ")
                             + recovered.join(QStringLiteral("\n- ")));
    } else {
        statusBar()->showMessage(QStringLiteral("已登录"), 2500);
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
    const auto markList = [dark](QListWidget *list) {
        if (!list)
            return;
        list->setProperty("darkMode", dark);
        list->viewport()->update();
    };
    markList(m_stationList);
    markList(m_pileList);
    markList(m_detailReviewList);
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
