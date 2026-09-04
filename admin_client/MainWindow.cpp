#include "MainWindow.h"
#include "AdminApiClient.h"
#include "StyleHelper.h"

#include <QAbstractItemView>
#include <QApplication>
#include <QBrush>
#include <QCheckBox>
#include <QCloseEvent>
#include <QColor>
#include <QComboBox>
#include <QDialog>
#include <QDoubleSpinBox>
#include <QFormLayout>
#include <QFrame>
#include <QGridLayout>
#include <QHBoxLayout>
#include <QHeaderView>
#include <QJsonArray>
#include <QLabel>
#include <QLineEdit>
#include <QListWidget>
#include <QMargins>
#include <QMessageBox>
#include <QPainter>
#include <QPen>
#include <QPushButton>
#include <QScrollArea>
#include <QSettings>
#include <QSpinBox>
#include <QStackedWidget>
#include <QTableWidget>
#include <QTimer>
#include <QVBoxLayout>

#include <QtCharts/QCategoryAxis>
#include <QtCharts/QChart>
#include <QtCharts/QChartView>
#include <QtCharts/QLineSeries>
#include <QtCharts/QPieSeries>
#include <QtCharts/QPieSlice>
#include <QtCharts/QValueAxis>

#ifdef QT_CHARTS_USE_NAMESPACE
QT_CHARTS_USE_NAMESPACE
#endif

namespace {

QTableWidgetItem *textItem(const QString &text, int id = 0)
{
    auto *item = new QTableWidgetItem(text);
    item->setFlags(item->flags() & ~Qt::ItemIsEditable);
    if (id > 0)
        item->setData(Qt::UserRole, id);
    return item;
}

void setupTable(QTableWidget *table, const QStringList &headers)
{
    table->setColumnCount(headers.size());
    table->setHorizontalHeaderLabels(headers);
    table->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);
    table->setSelectionBehavior(QAbstractItemView::SelectRows);
    table->setSelectionMode(QAbstractItemView::SingleSelection);
    table->setEditTriggers(QAbstractItemView::NoEditTriggers);
    table->setAlternatingRowColors(true);
    table->verticalHeader()->setVisible(false);
    table->verticalHeader()->setDefaultSectionSize(28);
    table->setShowGrid(false);
}

} // namespace

MainWindow::MainWindow(const Admin &admin, QWidget *parent)
    : QMainWindow(parent)
    , m_admin(admin)
{
    setWindowTitle(QStringLiteral("充电桩管理 - %1").arg(m_admin.realName.isEmpty()
                                                        ? m_admin.username
                                                        : m_admin.realName));
    resize(1180, 740);
    setMinimumSize(980, 640);
    QSettings settings;
    m_darkMode = settings.value(QStringLiteral("ui/darkMode"), false).toBool();
    buildUi();
    applyTheme(m_darkMode);
    refreshDashboard();
    refreshPileStatus();
    refreshStations();
    refreshPiles();
    refreshUsers();
}

QFrame *MainWindow::makeKpiCard(const QString &title, QLabel **valueLabel)
{
    auto *card = new QFrame(this);
    card->setObjectName(QStringLiteral("kpiCard"));
    auto *layout = new QVBoxLayout(card);
    layout->setContentsMargins(12, 10, 12, 10);
    auto *t = new QLabel(title, card);
    t->setObjectName(QStringLiteral("kpiTitle"));
    *valueLabel = new QLabel(QStringLiteral("-"), card);
    (*valueLabel)->setObjectName(QStringLiteral("kpiValue"));
    layout->addWidget(t);
    layout->addWidget(*valueLabel);
    return card;
}

void MainWindow::buildUi()
{
    auto *central = new QWidget(this);
    central->setObjectName(QStringLiteral("centralRoot"));
    setCentralWidget(central);
    auto *root = new QHBoxLayout(central);
    root->setContentsMargins(0, 0, 0, 0);
    root->setSpacing(0);

    auto *side = new QWidget(central);
    side->setObjectName(QStringLiteral("sideBar"));
    side->setFixedWidth(188);
    auto *sideLayout = new QVBoxLayout(side);
    sideLayout->setContentsMargins(0, 16, 0, 12);
    sideLayout->setSpacing(4);

    auto *brand = new QLabel(QStringLiteral("充电桩管理"), side);
    brand->setObjectName(QStringLiteral("brandTitle"));
    brand->setContentsMargins(14, 0, 14, 0);
    auto *who = new QLabel(QStringLiteral("%1  %2")
                               .arg(m_admin.realName.isEmpty() ? m_admin.username : m_admin.realName,
                                    m_admin.role),
                           side);
    who->setObjectName(QStringLiteral("brandSub"));
    who->setContentsMargins(14, 0, 14, 8);
    who->setWordWrap(true);

    m_nav = new QListWidget(side);
    m_nav->setObjectName(QStringLiteral("sideNav"));
    m_nav->setSpacing(0);
    m_nav->setFrameShape(QFrame::NoFrame);
    m_nav->setFocusPolicy(Qt::NoFocus);
    m_nav->addItems({
        QStringLiteral("销售业绩"),
        QStringLiteral("电桩状态"),
        QStringLiteral("充电桩管理"),
        QStringLiteral("充电站管理"),
        QStringLiteral("用户管理"),
        QStringLiteral("预约管理"),
        QStringLiteral("权限管理")
    });
    m_nav->setCurrentRow(0);

    sideLayout->addWidget(brand);
    sideLayout->addWidget(who);
    sideLayout->addWidget(m_nav, 1);

    m_darkModeBtn = new QPushButton(side);
    m_darkModeBtn->setObjectName(QStringLiteral("secondaryBtn"));
    m_darkModeBtn->setCheckable(true);
    m_darkModeBtn->setChecked(m_darkMode);
    m_darkModeBtn->setText(m_darkMode ? QStringLiteral("夜间模式：开")
                                      : QStringLiteral("夜间模式：关"));
    m_darkModeBtn->setContentsMargins(10, 0, 10, 0);
    sideLayout->addWidget(m_darkModeBtn);
    connect(m_darkModeBtn, &QPushButton::toggled, this, &MainWindow::onToggleDarkMode);

    auto *logoutBtn = new QPushButton(QStringLiteral("退出登录"), side);
    logoutBtn->setObjectName(QStringLiteral("dangerBtn"));
    sideLayout->addWidget(logoutBtn);
    connect(logoutBtn, &QPushButton::clicked, this, &MainWindow::onLogout);

    auto *right = new QWidget(central);
    auto *rightLayout = new QVBoxLayout(right);
    rightLayout->setContentsMargins(16, 12, 16, 12);
    rightLayout->setSpacing(8);

    m_stack = new QStackedWidget(right);
    m_stack->addWidget(buildDashboardPage());
    m_stack->addWidget(buildPileStatusPage());
    m_stack->addWidget(buildPilePage());
    m_stack->addWidget(buildStationPage());
    m_stack->addWidget(buildUserPage());
    m_stack->addWidget(buildReservationPage());
    m_stack->addWidget(buildPermissionPage());
    rightLayout->addWidget(m_stack, 1);

    root->addWidget(side);
    root->addWidget(right, 1);
    connect(m_nav, &QListWidget::currentRowChanged, this, &MainWindow::onNavChanged);
}

void MainWindow::onNavChanged(int row)
{
    m_stack->setCurrentIndex(row);
    switch (row) {
    case 0: refreshDashboard(); break;
    case 1: refreshPileStatus(); break;
    case 2: refreshPiles(); break;
    case 3: refreshStations(); break;
    case 4: refreshUsers(); break;
    case 5: refreshReservations(); break;
    case 6: refreshPermissions(); break;
    default: break;
    }
}

QWidget *MainWindow::buildDashboardPage()
{
    auto *page = new QWidget(this);
    auto *pageLayout = new QVBoxLayout(page);
    pageLayout->setContentsMargins(0, 0, 0, 0);
    pageLayout->setSpacing(0);
    auto *scroll = new QScrollArea(page);
    scroll->setWidgetResizable(true);
    scroll->setFrameShape(QFrame::NoFrame);
    auto *inner = new QWidget(scroll);
    auto *layout = new QVBoxLayout(inner);
    layout->setSpacing(10);
    layout->setContentsMargins(0, 0, 4, 0);

    auto *grid = new QGridLayout;
    grid->addWidget(makeKpiCard(QStringLiteral("今日营收（元）"), &m_kpiTodayAmount), 0, 0);
    grid->addWidget(makeKpiCard(QStringLiteral("本月营收（元）"), &m_kpiMonthAmount), 0, 1);
    grid->addWidget(makeKpiCard(QStringLiteral("总营收（元）"), &m_kpiTotalAmount), 0, 2);
    layout->addLayout(grid);

    auto *chartHeader = new QHBoxLayout;
    auto *chartTitle = new QLabel(QStringLiteral("营收趋势"), page);
    chartTitle->setObjectName(QStringLiteral("pageTitle"));
    m_salesDays = new QComboBox(page);
    m_salesDays->addItem(QStringLiteral("近 7 日"), 7);
    m_salesDays->addItem(QStringLiteral("近 30 日"), 30);
    auto *refreshBtn = new QPushButton(QStringLiteral("刷新"), page);
    chartHeader->addWidget(chartTitle);
    chartHeader->addStretch();
    chartHeader->addWidget(m_salesDays);
    chartHeader->addWidget(refreshBtn);
    layout->addLayout(chartHeader);

    m_salesChartView = new QChartView(page);
    m_salesChartView->setMinimumHeight(240);
    m_salesChartView->setRenderHint(QPainter::Antialiasing);
    layout->addWidget(m_salesChartView, 2);

    m_recentOrders = new QTableWidget(page);
    setupTable(m_recentOrders, {
        QStringLiteral("订单号"), QStringLiteral("用户"), QStringLiteral("站点"),
        QStringLiteral("电量(kWh)"), QStringLiteral("金额(元)"), QStringLiteral("状态")
    });
    layout->addWidget(m_recentOrders, 1);

    connect(refreshBtn, &QPushButton::clicked, this, &MainWindow::refreshDashboard);
    connect(m_salesDays, QOverload<int>::of(&QComboBox::currentIndexChanged),
            this, &MainWindow::refreshDashboard);
    m_recentOrders->setMinimumHeight(180);
    scroll->setWidget(inner);
    pageLayout->addWidget(scroll);
    return page;
}

QWidget *MainWindow::buildPileStatusPage()
{
    auto *page = new QWidget(this);
    auto *layout = new QVBoxLayout(page);
    auto *title = new QLabel(QStringLiteral("电桩状态"), page);
    title->setObjectName(QStringLiteral("pageTitle"));
    m_statusSummary = new QLabel(page);
    m_statusSummary->setObjectName(QStringLiteral("muted"));
    m_statusSummary->setWordWrap(true);

    auto *mid = new QHBoxLayout;
    m_statusChartView = new QChartView(page);
    m_statusChartView->setMinimumWidth(380);
    m_statusChartView->setRenderHint(QPainter::Antialiasing);
    m_statusDistTable = new QTableWidget(page);
    setupTable(m_statusDistTable, {
        QStringLiteral("运行状态"), QStringLiteral("数量"), QStringLiteral("占比")
    });
    mid->addWidget(m_statusChartView, 2);
    mid->addWidget(m_statusDistTable, 3);

    auto *queryRow = new QHBoxLayout;
    m_statusKeyword = new QLineEdit(page);
    m_statusKeyword->setPlaceholderText(QStringLiteral("按电桩编号/电站/地址查询"));
    auto *queryBtn = new QPushButton(QStringLiteral("查询明细"), page);
    queryRow->addWidget(m_statusKeyword, 1);
    queryRow->addWidget(queryBtn);

    m_statusPileTable = new QTableWidget(page);
    setupTable(m_statusPileTable, {
        QStringLiteral("电桩编号"), QStringLiteral("所属电站"), QStringLiteral("具体位置"),
        QStringLiteral("剩余电量(kWh)"), QStringLiteral("功率(kW)"),
        QStringLiteral("使用状态"), QStringLiteral("是否故障")
    });

    auto *refreshBtn = new QPushButton(QStringLiteral("刷新"), page);
    layout->addWidget(title);
    layout->addWidget(m_statusSummary);
    layout->addLayout(mid, 1);
    layout->addLayout(queryRow);
    layout->addWidget(m_statusPileTable, 2);
    layout->addWidget(refreshBtn, 0, Qt::AlignRight);
    connect(refreshBtn, &QPushButton::clicked, this, &MainWindow::refreshPileStatus);
    connect(queryBtn, &QPushButton::clicked, this, &MainWindow::refreshPileStatus);
    connect(m_statusKeyword, &QLineEdit::returnPressed, this, &MainWindow::refreshPileStatus);
    return page;
}

QWidget *MainWindow::buildPilePage()
{
    auto *page = new QWidget(this);
    auto *layout = new QVBoxLayout(page);

    auto *titleRow = new QHBoxLayout;
    auto *title = new QLabel(QStringLiteral("充电桩管理"), page);
    title->setObjectName(QStringLiteral("pageTitle"));
    auto *refreshBtn = new QPushButton(QStringLiteral("刷新"), page);
    auto *addPileBtn = new QPushButton(QStringLiteral("新增电桩"), page);
    auto *editPileBtn = new QPushButton(QStringLiteral("修改"), page);
    editPileBtn->setObjectName(QStringLiteral("secondaryBtn"));
    auto *delPileBtn = new QPushButton(QStringLiteral("删除"), page);
    delPileBtn->setObjectName(QStringLiteral("dangerBtn"));
    m_pileRestartBtn = new QPushButton(QStringLiteral("模拟维修（远程重启）"), page);
    m_pileRestartBtn->setObjectName(QStringLiteral("secondaryBtn"));
    m_pileRestartBtn->setVisible(false);
    titleRow->addWidget(title);
    titleRow->addStretch();
    titleRow->addWidget(addPileBtn);
    titleRow->addWidget(editPileBtn);
    titleRow->addWidget(delPileBtn);
    titleRow->addWidget(m_pileRestartBtn);
    titleRow->addWidget(refreshBtn);

    auto *filterRow = new QHBoxLayout;
    m_pileDistrictFilter = new QComboBox(page);
    m_pileStationFilter = new QComboBox(page);
    m_pileStatusFilter = new QComboBox(page);
    m_pileStatusFilter->addItem(QStringLiteral("全部状态"), QString());
    m_pileStatusFilter->addItem(QStringLiteral("空闲"), QStringLiteral("idle"));
    m_pileStatusFilter->addItem(QStringLiteral("已预约"), QStringLiteral("reserved"));
    m_pileStatusFilter->addItem(QStringLiteral("充电中"), QStringLiteral("charging"));
    m_pileStatusFilter->addItem(QStringLiteral("故障"), QStringLiteral("fault"));
    m_pileStatusFilter->addItem(QStringLiteral("离线"), QStringLiteral("offline"));
    m_pileStatusFilter->addItem(QStringLiteral("维修中"), QStringLiteral("restarting"));
    filterRow->addWidget(new QLabel(QStringLiteral("城区"), page));
    filterRow->addWidget(m_pileDistrictFilter, 1);
    filterRow->addWidget(new QLabel(QStringLiteral("站点"), page));
    filterRow->addWidget(m_pileStationFilter, 2);
    filterRow->addWidget(new QLabel(QStringLiteral("电桩状态"), page));
    filterRow->addWidget(m_pileStatusFilter, 1);

    auto *hint = new QLabel(
        QStringLiteral("筛选路径：城区 → 站点 → 状态。「模拟维修」仅在选中故障电桩时出现。"), page);
    hint->setObjectName(QStringLiteral("muted"));
    hint->setWordWrap(true);

    m_pileTable = new QTableWidget(page);
    setupTable(m_pileTable, {
        QStringLiteral("电桩ID"), QStringLiteral("电桩编号"), QStringLiteral("所属电站"),
        QStringLiteral("类型"), QStringLiteral("功率(kW)"), QStringLiteral("剩余电量"),
        QStringLiteral("当前状态"), QStringLiteral("是否故障"), QStringLiteral("具体位置")
    });

    layout->addLayout(titleRow);
    layout->addLayout(filterRow);
    layout->addWidget(hint);
    layout->addWidget(m_pileTable, 1);
    connect(refreshBtn, &QPushButton::clicked, this, &MainWindow::refreshPiles);
    connect(m_pileDistrictFilter, QOverload<int>::of(&QComboBox::currentIndexChanged),
            this, &MainWindow::onPileDistrictChanged);
    connect(m_pileStationFilter, QOverload<int>::of(&QComboBox::currentIndexChanged),
            this, &MainWindow::refreshPiles);
    connect(m_pileStatusFilter, QOverload<int>::of(&QComboBox::currentIndexChanged),
            this, &MainWindow::refreshPiles);
    connect(m_pileRestartBtn, &QPushButton::clicked, this, &MainWindow::onRestartPile);
    connect(m_pileTable, &QTableWidget::itemSelectionChanged,
            this, &MainWindow::onPileSelectionChanged);
    connect(addPileBtn, &QPushButton::clicked, this, &MainWindow::onAddPile);
    connect(editPileBtn, &QPushButton::clicked, this, &MainWindow::onEditPile);
    connect(delPileBtn, &QPushButton::clicked, this, &MainWindow::onDeletePile);
    return page;
}

QWidget *MainWindow::buildStationPage()
{
    auto *page = new QWidget(this);
    auto *layout = new QVBoxLayout(page);

    auto *row = new QHBoxLayout;
    auto *title = new QLabel(QStringLiteral("充电站管理"), page);
    title->setObjectName(QStringLiteral("pageTitle"));
    m_stationKeyword = new QLineEdit(page);
    m_stationKeyword->setPlaceholderText(QStringLiteral("按站名或地址搜索"));
    auto *searchBtn = new QPushButton(QStringLiteral("查询"), page);
    auto *addBtn = new QPushButton(QStringLiteral("新增电站"), page);
    auto *editBtn = new QPushButton(QStringLiteral("修改电站"), page);
    editBtn->setObjectName(QStringLiteral("secondaryBtn"));
    auto *delBtn = new QPushButton(QStringLiteral("删除电站"), page);
    delBtn->setObjectName(QStringLiteral("dangerBtn"));
    row->addWidget(title);
    row->addWidget(m_stationKeyword, 1);
    row->addWidget(searchBtn);
    row->addWidget(addBtn);
    row->addWidget(editBtn);
    row->addWidget(delBtn);

    m_stationTable = new QTableWidget(page);
    setupTable(m_stationTable, {
        QStringLiteral("充电站ID"), QStringLiteral("站名"), QStringLiteral("详细地址"),
        QStringLiteral("经纬度"), QStringLiteral("总电桩数"), QStringLiteral("当前在线率")
    });

    m_stationDetailTitle = new QLabel(QStringLiteral("点击上方电站行，查看站内电桩实时状态"), page);
    m_stationDetailTitle->setObjectName(QStringLiteral("muted"));
    m_stationPileTable = new QTableWidget(page);
    setupTable(m_stationPileTable, {
        QStringLiteral("电桩编号"), QStringLiteral("类型"), QStringLiteral("功率(kW)"),
        QStringLiteral("状态"), QStringLiteral("累计次数")
    });
    m_stationPileTable->setMaximumHeight(240);

    layout->addLayout(row);
    layout->addWidget(m_stationTable, 3);
    layout->addWidget(m_stationDetailTitle);
    layout->addWidget(m_stationPileTable, 2);

    connect(searchBtn, &QPushButton::clicked, this, &MainWindow::refreshStations);
    connect(m_stationKeyword, &QLineEdit::returnPressed, this, &MainWindow::refreshStations);
    connect(addBtn, &QPushButton::clicked, this, &MainWindow::onAddStation);
    connect(editBtn, &QPushButton::clicked, this, &MainWindow::onEditStation);
    connect(delBtn, &QPushButton::clicked, this, &MainWindow::onDeleteStation);
    connect(m_stationTable, &QTableWidget::cellClicked, this, &MainWindow::onStationRowClicked);
    return page;
}

QWidget *MainWindow::buildUserPage()
{
    auto *page = new QWidget(this);
    auto *layout = new QVBoxLayout(page);

    auto *row = new QHBoxLayout;
    auto *title = new QLabel(QStringLiteral("用户管理"), page);
    title->setObjectName(QStringLiteral("pageTitle"));
    m_userKeyword = new QLineEdit(page);
    m_userKeyword->setPlaceholderText(QStringLiteral("按手机号模糊搜索"));
    auto *searchBtn = new QPushButton(QStringLiteral("查询"), page);
    auto *statusBtn = new QPushButton(QStringLiteral("冻结 / 解冻"), page);
    statusBtn->setObjectName(QStringLiteral("secondaryBtn"));
    auto *ordersBtn = new QPushButton(QStringLiteral("充电记录"), page);
    row->addWidget(title);
    row->addWidget(m_userKeyword, 1);
    row->addWidget(searchBtn);
    row->addWidget(ordersBtn);
    row->addWidget(statusBtn);

    m_userTable = new QTableWidget(page);
    setupTable(m_userTable, {
        QStringLiteral("用户ID"), QStringLiteral("手机号"), QStringLiteral("昵称"),
        QStringLiteral("钱包余额"), QStringLiteral("注册时间"), QStringLiteral("状态")
    });

    layout->addLayout(row);
    layout->addWidget(m_userTable, 1);
    connect(searchBtn, &QPushButton::clicked, this, &MainWindow::refreshUsers);
    connect(m_userKeyword, &QLineEdit::returnPressed, this, &MainWindow::refreshUsers);
    connect(statusBtn, &QPushButton::clicked, this, &MainWindow::onToggleUserStatus);
    connect(ordersBtn, &QPushButton::clicked, this, &MainWindow::onViewUserOrders);
    return page;
}

QWidget *MainWindow::buildReservationPage()
{
    auto *page = new QWidget(this);
    auto *layout = new QVBoxLayout(page);
    auto *row = new QHBoxLayout;
    auto *title = new QLabel(QStringLiteral("预约管理"), page);
    title->setObjectName(QStringLiteral("pageTitle"));
    auto *refreshBtn = new QPushButton(QStringLiteral("刷新"), page);
    auto *cancelBtn = new QPushButton(QStringLiteral("解除预约"), page);
    cancelBtn->setObjectName(QStringLiteral("dangerBtn"));
    row->addWidget(title);
    row->addStretch();
    row->addWidget(cancelBtn);
    row->addWidget(refreshBtn);
    m_reservationTable = new QTableWidget(page);
    setupTable(m_reservationTable, {
        QStringLiteral("预约号"), QStringLiteral("用户"), QStringLiteral("手机号"),
        QStringLiteral("电站"), QStringLiteral("电桩"), QStringLiteral("到期时间")
    });
    layout->addLayout(row);
    layout->addWidget(m_reservationTable, 1);
    connect(refreshBtn, &QPushButton::clicked, this, &MainWindow::refreshReservations);
    connect(cancelBtn, &QPushButton::clicked, this, &MainWindow::onCancelReservation);
    return page;
}

QWidget *MainWindow::buildPermissionPage()
{
    auto *page = new QWidget(this);
    auto *layout = new QVBoxLayout(page);

    auto *inviteTitle = new QLabel(QStringLiteral("邀请码"), page);
    inviteTitle->setObjectName(QStringLiteral("pageTitle"));
    auto *inviteRow = new QHBoxLayout;
    auto *roleCombo = new QComboBox(page);
    roleCombo->addItem(QStringLiteral("运维 operator"), QStringLiteral("operator"));
    roleCombo->addItem(QStringLiteral("审计 auditor"), QStringLiteral("auditor"));
    auto *createBtn = new QPushButton(QStringLiteral("生成邀请码"), page);
    auto *inviteRefresh = new QPushButton(QStringLiteral("刷新"), page);
    inviteRefresh->setObjectName(QStringLiteral("secondaryBtn"));
    inviteRow->addWidget(new QLabel(QStringLiteral("授予角色"), page));
    inviteRow->addWidget(roleCombo);
    inviteRow->addWidget(createBtn);
    inviteRow->addStretch();
    inviteRow->addWidget(inviteRefresh);
    m_inviteTable = new QTableWidget(page);
    setupTable(m_inviteTable, {
        QStringLiteral("邀请码"), QStringLiteral("角色"), QStringLiteral("创建时间"),
        QStringLiteral("使用人"), QStringLiteral("使用时间")
    });
    m_inviteTable->setMaximumHeight(220);

    auto *permTitle = new QLabel(QStringLiteral("角色权限"), page);
    permTitle->setObjectName(QStringLiteral("pageTitle"));
    auto *permRow = new QHBoxLayout;
    m_permRoleCombo = new QComboBox(page);
    m_permRoleCombo->addItem(QStringLiteral("运维 operator"), QStringLiteral("operator"));
    m_permRoleCombo->addItem(QStringLiteral("审计 auditor"), QStringLiteral("auditor"));
    auto *permSave = new QPushButton(QStringLiteral("保存当前勾选"), page);
    permRow->addWidget(new QLabel(QStringLiteral("角色"), page));
    permRow->addWidget(m_permRoleCombo);
    permRow->addStretch();
    permRow->addWidget(permSave);
    m_permTable = new QTableWidget(page);
    setupTable(m_permTable, {QStringLiteral("权限"), QStringLiteral("允许")});

    layout->addWidget(inviteTitle);
    layout->addLayout(inviteRow);
    layout->addWidget(m_inviteTable);
    layout->addWidget(permTitle);
    layout->addLayout(permRow);
    layout->addWidget(m_permTable, 1);

    connect(createBtn, &QPushButton::clicked, this, [this, roleCombo]() {
        QString code;
        if (!AdminApiClient::instance().createInviteCode(roleCombo->currentData().toString(), code)) {
            showApiError(QStringLiteral("生成邀请码失败"));
            return;
        }
        QMessageBox::information(this, QStringLiteral("邀请码已生成"), code);
        refreshPermissions();
    });
    connect(inviteRefresh, &QPushButton::clicked, this, &MainWindow::refreshPermissions);
    connect(m_permRoleCombo, QOverload<int>::of(&QComboBox::currentIndexChanged),
            this, &MainWindow::refreshPermissions);
    connect(permSave, &QPushButton::clicked, this, &MainWindow::onTogglePermission);
    return page;
}

void MainWindow::showApiError(const QString &title)
{
    QMessageBox::warning(this, title, AdminApiClient::instance().lastError());
}

void MainWindow::applySalesChart(const QJsonObject &payload)
{
    const QJsonArray daily = payload.value("dailySales").toArray();
    auto *series = new QLineSeries();
    series->setName(QStringLiteral("营收"));
    QPen pen(QColor(QStringLiteral("#0D7565")));
    pen.setWidth(2);
    series->setPen(pen);
    series->setPointsVisible(true);

    auto *axisX = new QCategoryAxis();
    axisX->setLabelsPosition(QCategoryAxis::AxisLabelsPositionOnValue);
    double maxY = 1.0;
    for (int i = 0; i < daily.size(); ++i) {
        const QJsonObject row = daily.at(i).toObject();
        const double amount = row.value("amount").toDouble();
        series->append(i, amount);
        maxY = qMax(maxY, amount);
        if (daily.size() <= 8 || i == 0 || i == daily.size() / 2 || i == daily.size() - 1)
            axisX->append(row.value("date").toString().mid(5), i);
    }
    if (daily.isEmpty()) {
        series->append(0, 0);
        axisX->append(QStringLiteral("暂无"), 0);
    }

    auto *chart = new QChart();
    chart->addSeries(series);
    chart->legend()->hide();
    chart->setTitle(QString());
    chart->setBackgroundBrush(QBrush(m_darkMode ? QColor(QStringLiteral("#1A2422")) : Qt::white));
    chart->setAnimationOptions(QChart::NoAnimation);
    chart->setMargins(QMargins(8, 8, 8, 8));

    auto *axisY = new QValueAxis();
    axisY->setRange(0, maxY * 1.2);
    axisY->setLabelFormat(QStringLiteral("%.0f"));
    axisY->setTitleText(QStringLiteral("营收（元）"));
    const QColor axisColor = m_darkMode ? QColor(QStringLiteral("#C5D0CD"))
                                        : QColor(QStringLiteral("#15201E"));
    axisX->setLabelsColor(axisColor);
    axisY->setLabelsColor(axisColor);
    axisY->setTitleBrush(QBrush(axisColor));
    chart->addAxis(axisX, Qt::AlignBottom);
    chart->addAxis(axisY, Qt::AlignLeft);
    series->attachAxis(axisX);
    series->attachAxis(axisY);
    m_salesChartView->setChart(chart);
}

void MainWindow::applyStatusChart(const QJsonObject &stats)
{
    const int idle = stats.value("idlePiles").toInt();
    const int inUse = stats.value("inUsePiles").toInt();
    const int fault = stats.value("faultPiles").toInt();
    auto *series = new QPieSeries();
    auto addSlice = [&](const QString &label, int value, const QString &color) {
        if (value <= 0)
            return;
        QPieSlice *slice = series->append(label, value);
        slice->setColor(QColor(color));
        slice->setLabelVisible(true);
    };
    addSlice(QStringLiteral("闲置"), idle, QStringLiteral("#2563A8"));
    addSlice(QStringLiteral("在用"), inUse, QStringLiteral("#188568"));
    addSlice(QStringLiteral("故障"), fault, QStringLiteral("#C34444"));
    if (series->slices().isEmpty())
        series->append(QStringLiteral("暂无数据"), 1)->setColor(QColor(QStringLiteral("#D8E0DE")));

    auto *chart = new QChart();
    chart->addSeries(series);
    chart->setTitle(QString());
    chart->setBackgroundBrush(QBrush(m_darkMode ? QColor(QStringLiteral("#1A2422")) : Qt::white));
    chart->setAnimationOptions(QChart::NoAnimation);
    chart->legend()->setAlignment(Qt::AlignBottom);
    chart->legend()->setLabelColor(m_darkMode ? QColor(QStringLiteral("#C5D0CD"))
                                              : QColor(QStringLiteral("#15201E")));
    m_statusChartView->setChart(chart);
}

void MainWindow::refreshDashboard()
{
    const int days = m_salesDays ? m_salesDays->currentData().toInt() : 7;
    const QJsonObject payload = AdminApiClient::instance().dashboard(days);
    if (payload.isEmpty()) {
        showApiError(QStringLiteral("加载销售业绩失败"));
        return;
    }
    const QJsonObject stats = payload.value("stats").toObject();
    m_kpiTodayAmount->setText(QString::number(stats.value("todayAmount").toDouble(), 'f', 2));
    m_kpiMonthAmount->setText(QString::number(stats.value("monthAmount").toDouble(), 'f', 2));
    m_kpiTotalAmount->setText(QString::number(stats.value("totalAmount").toDouble(), 'f', 2));
    applySalesChart(payload);

    const QJsonArray orders = payload.value("recentOrders").toArray();
    m_recentOrders->setRowCount(orders.size());
    for (int i = 0; i < orders.size(); ++i) {
        const QJsonObject o = orders.at(i).toObject();
        m_recentOrders->setItem(i, 0, textItem(o.value("orderNo").toString()));
        m_recentOrders->setItem(i, 1, textItem(o.value("username").toString()));
        m_recentOrders->setItem(i, 2, textItem(o.value("stationName").toString()));
        m_recentOrders->setItem(i, 3, textItem(QString::number(o.value("energyKwh").toDouble(), 'f', 2)));
        m_recentOrders->setItem(i, 4, textItem(QString::number(o.value("amount").toDouble(), 'f', 2)));
        m_recentOrders->setItem(i, 5, textItem(statusTextOrder(o.value("status").toString())));
    }
}

void MainWindow::refreshPileStatus()
{
    const QJsonObject stats = AdminApiClient::instance().pileStats();
    if (stats.isEmpty()) {
        showApiError(QStringLiteral("加载电桩状态失败"));
        return;
    }
    const int total = qMax(1, stats.value("totalPiles").toInt());
    const int idle = stats.value("idlePiles").toInt();
    const int inUse = stats.value("inUsePiles").toInt();
    const int fault = stats.value("faultPiles").toInt();
    const int offline = stats.value("offlinePiles").toInt();
    m_statusSummary->setText(
        QStringLiteral("共 %1 台，闲置 %2，在用 %3，故障 %4，离线 %5")
            .arg(stats.value("totalPiles").toInt()).arg(idle).arg(inUse).arg(fault).arg(offline));

    struct Row { QString name; int count; };
    const Row rows[] = {
        {QStringLiteral("闲置"), idle},
        {QStringLiteral("在用"), inUse},
        {QStringLiteral("故障"), fault},
    };
    m_statusDistTable->setRowCount(3);
    for (int i = 0; i < 3; ++i) {
        m_statusDistTable->setItem(i, 0, textItem(rows[i].name));
        m_statusDistTable->setItem(i, 1, textItem(QString::number(rows[i].count)));
        m_statusDistTable->setItem(i, 2, textItem(QStringLiteral("%1%")
                                                      .arg(rows[i].count * 100.0 / total, 0, 'f', 1)));
    }
    applyStatusChart(stats);

    const auto piles = AdminApiClient::instance().listPiles(-1);
    const QString keyword = m_statusKeyword ? m_statusKeyword->text().trimmed() : QString();
    QVector<Pile> filtered;
    for (const Pile &p : piles) {
        if (keyword.isEmpty()
            || p.pileCode.contains(keyword, Qt::CaseInsensitive)
            || p.stationName.contains(keyword, Qt::CaseInsensitive)
            || p.stationAddress.contains(keyword, Qt::CaseInsensitive))
            filtered.append(p);
    }
    m_statusPileTable->setRowCount(filtered.size());
    for (int i = 0; i < filtered.size(); ++i) {
        const Pile &p = filtered[i];
        m_statusPileTable->setItem(i, 0, textItem(p.pileCode, p.id));
        m_statusPileTable->setItem(i, 1, textItem(p.stationName));
        m_statusPileTable->setItem(i, 2, textItem(p.stationAddress));
        m_statusPileTable->setItem(i, 3, textItem(QString::number(p.remainingKwh, 'f', 1)));
        m_statusPileTable->setItem(i, 4, textItem(QString::number(p.powerKw, 'f', 1)));
        m_statusPileTable->setItem(i, 5, textItem(statusTextPile(p.status)));
        m_statusPileTable->setItem(i, 6, textItem(p.status == QLatin1String("fault")
                                                     ? QStringLiteral("是")
                                                     : QStringLiteral("否")));
    }
}

void MainWindow::rebuildPileStationFilter(bool keepSelection)
{
    const int currentStation = m_pileStationFilter->currentData().toInt();
    const QString district = m_pileDistrictFilter->currentData().toString();
    const auto stations = AdminApiClient::instance().listStations(QString(), district);

    m_pileStationFilter->blockSignals(true);
    m_pileStationFilter->clear();
    m_pileStationFilter->addItem(
        district.isEmpty() ? QStringLiteral("全部站点（最多 500 条）")
                           : QStringLiteral("该城区全部站点"),
        -1);
    for (const Station &station : stations)
        m_pileStationFilter->addItem(station.name, station.id);
    if (keepSelection) {
        const int idx = m_pileStationFilter->findData(currentStation);
        m_pileStationFilter->setCurrentIndex(idx >= 0 ? idx : 0);
    } else {
        m_pileStationFilter->setCurrentIndex(0);
    }
    m_pileStationFilter->blockSignals(false);
}

void MainWindow::updateRestartButtonVisibility()
{
    if (!m_pileRestartBtn || !m_pileTable)
        return;
    const int row = m_pileTable->currentRow();
    bool show = false;
    if (row >= 0 && m_pileTable->item(row, 0)) {
        const QString status = m_pileTable->item(row, 0)->data(Qt::UserRole + 1).toString();
        show = (status == QLatin1String("fault"));
    }
    m_pileRestartBtn->setVisible(show);
}

void MainWindow::onPileDistrictChanged()
{
    rebuildPileStationFilter(false);
    refreshPiles();
}

void MainWindow::onPileSelectionChanged()
{
    updateRestartButtonVisibility();
}

void MainWindow::refreshPiles()
{
    const QString currentDistrict = m_pileDistrictFilter->currentData().toString();
    const QString currentStatus = m_pileStatusFilter->currentData().toString();
    const bool hadDistrict = m_pileDistrictFilter->count() > 0;

    m_pileDistrictFilter->blockSignals(true);
    m_pileDistrictFilter->clear();
    m_pileDistrictFilter->addItem(QStringLiteral("全部城区"), QString());
    for (const QString &district : AdminApiClient::instance().districts())
        m_pileDistrictFilter->addItem(district, district);
    if (hadDistrict) {
        const int idx = m_pileDistrictFilter->findData(currentDistrict);
        m_pileDistrictFilter->setCurrentIndex(idx >= 0 ? idx : 0);
    }
    m_pileDistrictFilter->blockSignals(false);

    m_pileStatusFilter->blockSignals(true);
    const int statusIdx = m_pileStatusFilter->findData(currentStatus);
    if (statusIdx >= 0)
        m_pileStatusFilter->setCurrentIndex(statusIdx);
    m_pileStatusFilter->blockSignals(false);

    rebuildPileStationFilter(true);

    const QString district = m_pileDistrictFilter->currentData().toString();
    const int stationId = m_pileStationFilter->currentData().toInt();
    const QString status = m_pileStatusFilter->currentData().toString();
    const auto piles = AdminApiClient::instance().listPiles(stationId, status, district);
    m_pileTable->setRowCount(piles.size());
    for (int i = 0; i < piles.size(); ++i) {
        const Pile &p = piles[i];
        auto *idItem = textItem(QString::number(p.id), p.id);
        idItem->setData(Qt::UserRole + 1, p.status);
        m_pileTable->setItem(i, 0, idItem);
        m_pileTable->setItem(i, 1, textItem(p.pileCode, p.id));
        m_pileTable->setItem(i, 2, textItem(p.stationName));
        m_pileTable->setItem(i, 3, textItem(chargeKindText(p)));
        m_pileTable->setItem(i, 4, textItem(QString::number(p.powerKw, 'f', 1)));
        m_pileTable->setItem(i, 5, textItem(QString::number(p.remainingKwh, 'f', 1)));
        m_pileTable->setItem(i, 6, textItem(statusTextPile(p.status)));
        m_pileTable->setItem(i, 7, textItem(p.status == QLatin1String("fault")
                                               ? QStringLiteral("是") : QStringLiteral("否")));
        m_pileTable->setItem(i, 8, textItem(p.stationAddress));
    }
    updateRestartButtonVisibility();
}

void MainWindow::refreshStations()
{
    const auto stations = AdminApiClient::instance().listStations(m_stationKeyword->text());
    m_stationTable->setRowCount(stations.size());
    for (int i = 0; i < stations.size(); ++i) {
        const Station &s = stations[i];
        m_stationTable->setItem(i, 0, textItem(QString::number(s.id), s.id));
        m_stationTable->setItem(i, 1, textItem(s.name));
        m_stationTable->setItem(i, 2, textItem(s.address));
        m_stationTable->setItem(i, 3, textItem(QStringLiteral("%1, %2")
                                                   .arg(s.longitude, 0, 'f', 4)
                                                   .arg(s.latitude, 0, 'f', 4)));
        m_stationTable->setItem(i, 4, textItem(QString::number(s.totalPiles)));
        m_stationTable->setItem(i, 5, textItem(QStringLiteral("%1%").arg(s.onlineRate, 0, 'f', 1)));
    }
}

void MainWindow::refreshUsers()
{
    const auto users = AdminApiClient::instance().listUsers(m_userKeyword->text());
    m_userTable->setRowCount(users.size());
    for (int i = 0; i < users.size(); ++i) {
        const User &u = users[i];
        m_userTable->setItem(i, 0, textItem(QString::number(u.id), u.id));
        m_userTable->setItem(i, 1, textItem(u.phone));
        m_userTable->setItem(i, 2, textItem(u.nickname));
        m_userTable->setItem(i, 3, textItem(QString::number(u.balance, 'f', 2)));
        m_userTable->setItem(i, 4, textItem(u.createdAt));
        m_userTable->setItem(i, 5, textItem(statusTextUser(u.status)));
    }
}

void MainWindow::onRestartPile()
{
    const int row = m_pileTable->currentRow();
    if (row < 0) {
        QMessageBox::information(this, QStringLiteral("提示"), QStringLiteral("请先选中故障电桩"));
        return;
    }
    const int pileId = m_pileTable->item(row, 0)->data(Qt::UserRole).toInt();
    const QString code = m_pileTable->item(row, 1)->text();
    const QString status = m_pileTable->item(row, 0)->data(Qt::UserRole + 1).toString();
    if (status != QLatin1String("fault")) {
        QMessageBox::information(this, QStringLiteral("提示"),
                                 QStringLiteral("仅故障电桩可执行模拟维修（远程重启）。"));
        return;
    }
    if (QMessageBox::question(this, QStringLiteral("模拟维修"),
                              QStringLiteral("确认对故障电桩 %1 执行模拟维修？\n"
                                             "状态将变为「维修中」，约 1.5 秒后恢复空闲。")
                                  .arg(code))
        != QMessageBox::Yes)
        return;
    if (!AdminApiClient::instance().restartPile(pileId)) {
        showApiError(QStringLiteral("模拟维修失败"));
        return;
    }
    QMessageBox::information(this, QStringLiteral("已下发"),
                             QStringLiteral("模拟维修已开始，电桩进入维修中，稍后恢复空闲。"));
    refreshPiles();
    QTimer::singleShot(1800, this, [this]() {
        refreshPiles();
        refreshPileStatus();
    });
}

void MainWindow::onAddStation()
{
    QDialog dlg(this);
    dlg.setWindowTitle(QStringLiteral("新增电站"));
    dlg.setStyleSheet(styleSheet());
    auto *form = new QFormLayout(&dlg);
    auto *name = new QLineEdit(&dlg);
    auto *addr = new QLineEdit(&dlg);
    auto *lat = new QLineEdit(QStringLiteral("39.9042"), &dlg);
    auto *lng = new QLineEdit(QStringLiteral("116.4074"), &dlg);
    auto *count = new QSpinBox(&dlg);
    count->setRange(1, 40);
    count->setValue(4);
    form->addRow(QStringLiteral("站名"), name);
    form->addRow(QStringLiteral("详细地址"), addr);
    form->addRow(QStringLiteral("纬度"), lat);
    form->addRow(QStringLiteral("经度"), lng);
    form->addRow(QStringLiteral("电桩数量"), count);
    auto *ok = new QPushButton(QStringLiteral("完成新增"), &dlg);
    form->addRow(ok);
    connect(ok, &QPushButton::clicked, &dlg, &QDialog::accept);
    if (dlg.exec() != QDialog::Accepted)
        return;

    Station station;
    station.name = name->text().trimmed();
    station.address = addr->text().trimmed();
    station.latitude = lat->text().toDouble();
    station.longitude = lng->text().toDouble();
    station.openHours = QStringLiteral("00:00-24:00");
    station.status = QStringLiteral("open");
    if (station.name.isEmpty() || station.address.isEmpty()) {
        QMessageBox::warning(this, QStringLiteral("提示"), QStringLiteral("请填写站名和地址"));
        return;
    }
    if (!AdminApiClient::instance().saveStation(station, count->value())) {
        showApiError(QStringLiteral("新增电站失败"));
        return;
    }
    QMessageBox::information(this, QStringLiteral("成功"),
                             QStringLiteral("已新增电站，并生成配套电桩。"));
    refreshStations();
    refreshPiles();
    refreshPileStatus();
}

void MainWindow::onStationRowClicked(int row, int)
{
    if (row < 0)
        return;
    const int stationId = m_stationTable->item(row, 0)->data(Qt::UserRole).toInt();
    Station station;
    const auto piles = AdminApiClient::instance().listStationPiles(stationId, &station);
    m_stationDetailTitle->setText(QStringLiteral("站内明细：%1（%2 个电桩）")
                                      .arg(m_stationTable->item(row, 1)->text())
                                      .arg(piles.size()));
    m_stationPileTable->setRowCount(piles.size());
    for (int i = 0; i < piles.size(); ++i) {
        const Pile &p = piles[i];
        m_stationPileTable->setItem(i, 0, textItem(p.pileCode));
        m_stationPileTable->setItem(i, 1, textItem(chargeKindText(p)));
        m_stationPileTable->setItem(i, 2, textItem(QString::number(p.powerKw, 'f', 1)));
        m_stationPileTable->setItem(i, 3, textItem(statusTextPile(p.status)));
        m_stationPileTable->setItem(i, 4, textItem(QString::number(p.totalChargeCount)));
    }
}

void MainWindow::onToggleUserStatus()
{
    const int row = m_userTable->currentRow();
    if (row < 0) {
        QMessageBox::information(this, QStringLiteral("提示"), QStringLiteral("请先选择用户"));
        return;
    }
    const int userId = m_userTable->item(row, 0)->data(Qt::UserRole).toInt();
    const QString current = m_userTable->item(row, 5)->text();
    const QString next = current == QStringLiteral("冻结") ? QStringLiteral("normal")
                                                             : QStringLiteral("frozen");
    const QString action = next == QLatin1String("frozen") ? QStringLiteral("冻结") : QStringLiteral("解冻");
    if (QMessageBox::question(this, QStringLiteral("风控操作"),
                              QStringLiteral("确认%1该用户账号？").arg(action))
        != QMessageBox::Yes)
        return;
    if (!AdminApiClient::instance().setUserStatus(userId, next)) {
        showApiError(QStringLiteral("操作失败"));
        return;
    }
    refreshUsers();
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

bool MainWindow::confirmForce(const QString &title)
{
    return QMessageBox::question(this, title,
                                 AdminApiClient::instance().lastError()
                                     + QStringLiteral("\n\n选择“是”将强制删除。"))
           == QMessageBox::Yes;
}

bool MainWindow::editPileDialog(Pile &pile, bool isNew)
{
    QDialog dlg(this);
    dlg.setWindowTitle(isNew ? QStringLiteral("新增电桩") : QStringLiteral("修改电桩"));
    dlg.setStyleSheet(styleSheet());
    auto *form = new QFormLayout(&dlg);
    auto *idEdit = new QLineEdit(pile.id > 0 ? QString::number(pile.id) : QStringLiteral("自动生成"), &dlg);
    idEdit->setReadOnly(true);
    auto *code = new QLineEdit(pile.pileCode, &dlg);
    auto *stationId = new QSpinBox(&dlg);
    stationId->setRange(1, 999999);
    stationId->setValue(pile.stationId > 0 ? pile.stationId : m_pileStationFilter->currentData().toInt());
    auto *type = new QComboBox(&dlg);
    type->addItems({QStringLiteral("AC"), QStringLiteral("DC")});
    type->setCurrentText(pile.pileType.isEmpty() ? QStringLiteral("AC") : pile.pileType);
    auto *speed = new QComboBox(&dlg);
    speed->addItem(QStringLiteral("慢充"), QStringLiteral("slow"));
    speed->addItem(QStringLiteral("常规"), QStringLiteral("standard"));
    speed->addItem(QStringLiteral("快充"), QStringLiteral("fast"));
    speed->addItem(QStringLiteral("超充"), QStringLiteral("ultra"));
    const int speedIdx = speed->findData(pile.speedClass);
    speed->setCurrentIndex(speedIdx >= 0 ? speedIdx : 0);
    auto *connector = new QComboBox(&dlg);
    connector->addItem(QStringLiteral("国标交流"), QStringLiteral("GB_T_AC"));
    connector->addItem(QStringLiteral("国标直流"), QStringLiteral("GB_T_DC"));
    connector->addItem(QStringLiteral("CCS2"), QStringLiteral("CCS2"));
    connector->addItem(QStringLiteral("CHAdeMO"), QStringLiteral("CHAdeMO"));
    connector->addItem(QStringLiteral("特斯拉NACS"), QStringLiteral("TeslaNACS"));
    const int connIdx = connector->findData(pile.connectorStandard);
    connector->setCurrentIndex(connIdx >= 0 ? connIdx : 0);
    auto *power = new QDoubleSpinBox(&dlg);
    power->setRange(1, 400);
    power->setValue(pile.powerKw > 0 ? pile.powerKw : 7.0);
    auto *price = new QDoubleSpinBox(&dlg);
    price->setRange(0, 20);
    price->setDecimals(2);
    price->setValue(pile.pricePerKwh > 0 ? pile.pricePerKwh : 1.2);
    auto *remain = new QDoubleSpinBox(&dlg);
    remain->setRange(0, 500);
    remain->setValue(pile.remainingKwh > 0 ? pile.remainingKwh : 100.0);
    auto *status = new QComboBox(&dlg);
    status->addItems({QStringLiteral("idle"), QStringLiteral("fault"), QStringLiteral("offline")});
    status->setCurrentText(pile.status.isEmpty() ? QStringLiteral("idle") : pile.status);
    form->addRow(QStringLiteral("电桩ID（不可改）"), idEdit);
    form->addRow(QStringLiteral("电桩编号"), code);
    form->addRow(QStringLiteral("所属电站ID"), stationId);
    form->addRow(QStringLiteral("类型"), type);
    form->addRow(QStringLiteral("充电速度"), speed);
    form->addRow(QStringLiteral("接口标准"), connector);
    form->addRow(QStringLiteral("功率(kW)"), power);
    form->addRow(QStringLiteral("电价(元/kWh)"), price);
    form->addRow(QStringLiteral("剩余电量(kWh)"), remain);
    form->addRow(QStringLiteral("状态"), status);
    auto *ok = new QPushButton(QStringLiteral("保存"), &dlg);
    form->addRow(ok);
    connect(ok, &QPushButton::clicked, &dlg, &QDialog::accept);
    if (dlg.exec() != QDialog::Accepted)
        return false;
    pile.pileCode = code->text().trimmed();
    pile.stationId = stationId->value();
    pile.pileType = type->currentText();
    pile.speedClass = speed->currentData().toString();
    pile.connectorStandard = connector->currentData().toString();
    pile.powerKw = power->value();
    pile.pricePerKwh = price->value();
    pile.remainingKwh = remain->value();
    pile.status = status->currentText();
    pile.categoryLabel.clear();
    if (pile.pileCode.isEmpty()) {
        QMessageBox::warning(this, QStringLiteral("提示"), QStringLiteral("请填写电桩编号"));
        return false;
    }
    return true;
}

bool MainWindow::editStationDialog(Station &station, int *pileCount, bool isNew)
{
    QDialog dlg(this);
    dlg.setWindowTitle(isNew ? QStringLiteral("新增电站") : QStringLiteral("修改电站"));
    dlg.setStyleSheet(styleSheet());
    auto *form = new QFormLayout(&dlg);
    auto *idEdit = new QLineEdit(station.id > 0 ? QString::number(station.id) : QStringLiteral("自动生成"), &dlg);
    idEdit->setReadOnly(true);
    auto *name = new QLineEdit(station.name, &dlg);
    auto *addr = new QLineEdit(station.address, &dlg);
    auto *lat = new QLineEdit(station.latitude != 0 ? QString::number(station.latitude, 'f', 6)
                                                    : QStringLiteral("39.9042"), &dlg);
    auto *lng = new QLineEdit(station.longitude != 0 ? QString::number(station.longitude, 'f', 6)
                                                     : QStringLiteral("116.4074"), &dlg);
    form->addRow(QStringLiteral("电站ID（不可改）"), idEdit);
    form->addRow(QStringLiteral("站名"), name);
    form->addRow(QStringLiteral("详细地址"), addr);
    form->addRow(QStringLiteral("纬度"), lat);
    form->addRow(QStringLiteral("经度"), lng);
    QSpinBox *count = nullptr;
    if (isNew && pileCount) {
        count = new QSpinBox(&dlg);
        count->setRange(1, 40);
        count->setValue(*pileCount > 0 ? *pileCount : 4);
        form->addRow(QStringLiteral("电桩数量"), count);
    }
    auto *ok = new QPushButton(QStringLiteral("保存"), &dlg);
    form->addRow(ok);
    connect(ok, &QPushButton::clicked, &dlg, &QDialog::accept);
    if (dlg.exec() != QDialog::Accepted)
        return false;
    station.name = name->text().trimmed();
    station.address = addr->text().trimmed();
    station.latitude = lat->text().toDouble();
    station.longitude = lng->text().toDouble();
    station.openHours = station.openHours.isEmpty() ? QStringLiteral("00:00-24:00") : station.openHours;
    station.status = station.status.isEmpty() ? QStringLiteral("open") : station.status;
    if (count && pileCount)
        *pileCount = count->value();
    if (station.name.isEmpty() || station.address.isEmpty()) {
        QMessageBox::warning(this, QStringLiteral("提示"), QStringLiteral("请填写站名和地址"));
        return false;
    }
    return true;
}

void MainWindow::onAddPile()
{
    Pile pile;
    pile.stationId = m_pileStationFilter->currentData().toInt();
    if (pile.stationId <= 0) {
        QMessageBox::information(this, QStringLiteral("提示"),
                                 QStringLiteral("请先在筛选中选择一个具体电站"));
        return;
    }
    if (!editPileDialog(pile, true))
        return;
    if (!AdminApiClient::instance().savePile(pile)) {
        showApiError(QStringLiteral("新增电桩失败"));
        return;
    }
    refreshPiles();
    refreshPileStatus();
    refreshStations();
}

void MainWindow::onEditPile()
{
    const int row = m_pileTable->currentRow();
    if (row < 0) {
        QMessageBox::information(this, QStringLiteral("提示"), QStringLiteral("请先选中电桩"));
        return;
    }
    const int pileId = m_pileTable->item(row, 0)->data(Qt::UserRole).toInt();
    const auto piles = AdminApiClient::instance().listPiles(m_pileStationFilter->currentData().toInt());
    Pile pile;
    for (const Pile &p : piles) {
        if (p.id == pileId) {
            pile = p;
            break;
        }
    }
    if (pile.id <= 0) {
        showApiError(QStringLiteral("未找到电桩"));
        return;
    }
    if (!editPileDialog(pile, false))
        return;
    if (!AdminApiClient::instance().savePile(pile)) {
        showApiError(QStringLiteral("修改电桩失败"));
        return;
    }
    refreshPiles();
    refreshPileStatus();
    refreshStations();
}

void MainWindow::onDeletePile()
{
    const int row = m_pileTable->currentRow();
    if (row < 0) {
        QMessageBox::information(this, QStringLiteral("提示"), QStringLiteral("请先选中电桩"));
        return;
    }
    const int pileId = m_pileTable->item(row, 0)->data(Qt::UserRole).toInt();
    const QString code = m_pileTable->item(row, 1)->text();
    if (QMessageBox::question(this, QStringLiteral("删除电桩"),
                              QStringLiteral("确认删除电桩 %1？").arg(code))
        != QMessageBox::Yes)
        return;
    if (!AdminApiClient::instance().deletePile(pileId, false)) {
        if (AdminApiClient::instance().needsForce() && confirmForce(QStringLiteral("强制删除电桩"))) {
            if (!AdminApiClient::instance().deletePile(pileId, true)) {
                showApiError(QStringLiteral("删除电桩失败"));
                return;
            }
        } else {
            showApiError(QStringLiteral("删除电桩失败"));
            return;
        }
    }
    refreshPiles();
    refreshPileStatus();
    refreshStations();
}

void MainWindow::onEditStation()
{
    const int row = m_stationTable->currentRow();
    if (row < 0) {
        QMessageBox::information(this, QStringLiteral("提示"), QStringLiteral("请先选中电站"));
        return;
    }
    Station station;
    station.id = m_stationTable->item(row, 0)->data(Qt::UserRole).toInt();
    station.name = m_stationTable->item(row, 1)->text();
    station.address = m_stationTable->item(row, 2)->text();
    const auto stations = AdminApiClient::instance().listStations();
    for (const Station &s : stations) {
        if (s.id == station.id) {
            station = s;
            break;
        }
    }
    if (!editStationDialog(station, nullptr, false))
        return;
    if (!AdminApiClient::instance().saveStation(station, 0)) {
        showApiError(QStringLiteral("修改电站失败"));
        return;
    }
    refreshStations();
    refreshPiles();
}

void MainWindow::onDeleteStation()
{
    const int row = m_stationTable->currentRow();
    if (row < 0) {
        QMessageBox::information(this, QStringLiteral("提示"), QStringLiteral("请先选中电站"));
        return;
    }
    const int stationId = m_stationTable->item(row, 0)->data(Qt::UserRole).toInt();
    const QString name = m_stationTable->item(row, 1)->text();
    if (QMessageBox::question(this, QStringLiteral("删除电站"),
                              QStringLiteral("确认删除电站「%1」及其全部电桩？").arg(name))
        != QMessageBox::Yes)
        return;
    if (!AdminApiClient::instance().deleteStation(stationId, false)) {
        if (AdminApiClient::instance().needsForce() && confirmForce(QStringLiteral("强制删除电站"))) {
            if (!AdminApiClient::instance().deleteStation(stationId, true)) {
                showApiError(QStringLiteral("删除电站失败"));
                return;
            }
        } else {
            showApiError(QStringLiteral("删除电站失败"));
            return;
        }
    }
    refreshStations();
    refreshPiles();
    refreshPileStatus();
}

void MainWindow::onViewUserOrders()
{
    const int row = m_userTable->currentRow();
    if (row < 0) {
        QMessageBox::information(this, QStringLiteral("提示"), QStringLiteral("请先选择用户"));
        return;
    }
    const int userId = m_userTable->item(row, 0)->data(Qt::UserRole).toInt();
    const QString phone = m_userTable->item(row, 1)->text();
    QDialog dlg(this);
    dlg.setWindowTitle(QStringLiteral("充电记录 - %1").arg(phone));
    dlg.resize(720, 420);
    dlg.setStyleSheet(styleSheet());
    auto *layout = new QVBoxLayout(&dlg);
    auto *table = new QTableWidget(&dlg);
    setupTable(table, {
        QStringLiteral("订单号"), QStringLiteral("站点"), QStringLiteral("电量"),
        QStringLiteral("金额"), QStringLiteral("状态")
    });
    auto fill = [this, table, userId]() {
        const auto orders = AdminApiClient::instance().listUserOrders(userId);
        table->setRowCount(orders.size());
        for (int i = 0; i < orders.size(); ++i) {
            const ChargingOrder &o = orders[i];
            table->setItem(i, 0, textItem(o.orderNo, o.id));
            table->setItem(i, 1, textItem(o.stationName));
            table->setItem(i, 2, textItem(QString::number(o.energyKwh, 'f', 2)));
            table->setItem(i, 3, textItem(QString::number(o.amount, 'f', 2)));
            table->setItem(i, 4, textItem(statusTextOrder(o.status)));
        }
    };
    auto *delBtn = new QPushButton(QStringLiteral("删除选中记录"), &dlg);
    delBtn->setObjectName(QStringLiteral("dangerBtn"));
    layout->addWidget(table, 1);
    layout->addWidget(delBtn);
    connect(delBtn, &QPushButton::clicked, &dlg, [this, table, fill]() {
        const int r = table->currentRow();
        if (r < 0)
            return;
        const int orderId = table->item(r, 0)->data(Qt::UserRole).toInt();
        if (QMessageBox::question(this, QStringLiteral("删除订单"), QStringLiteral("确认删除该充电记录？"))
            != QMessageBox::Yes)
            return;
        if (!AdminApiClient::instance().deleteOrder(orderId)) {
            showApiError(QStringLiteral("删除订单失败"));
            return;
        }
        fill();
    });
    fill();
    dlg.exec();
}

void MainWindow::refreshReservations()
{
    const auto rows = AdminApiClient::instance().listReservations();
    m_reservationTable->setRowCount(rows.size());
    for (int i = 0; i < rows.size(); ++i) {
        const ChargingReservation &r = rows[i];
        m_reservationTable->setItem(i, 0, textItem(r.reservationNo, r.id));
        m_reservationTable->setItem(i, 1, textItem(r.username));
        m_reservationTable->setItem(i, 2, textItem(r.phone));
        m_reservationTable->setItem(i, 3, textItem(r.stationName));
        m_reservationTable->setItem(i, 4, textItem(r.pileCode));
        m_reservationTable->setItem(i, 5, textItem(r.expiresAt));
    }
}

void MainWindow::onCancelReservation()
{
    const int row = m_reservationTable->currentRow();
    if (row < 0) {
        QMessageBox::information(this, QStringLiteral("提示"), QStringLiteral("请先选择预约"));
        return;
    }
    const int reservationId = m_reservationTable->item(row, 0)->data(Qt::UserRole).toInt();
    if (QMessageBox::question(this, QStringLiteral("解除预约"),
                              QStringLiteral("确认解除该用户正在进行的预约？"))
        != QMessageBox::Yes)
        return;
    if (!AdminApiClient::instance().cancelReservation(reservationId)) {
        showApiError(QStringLiteral("解除预约失败"));
        return;
    }
    refreshReservations();
    refreshPiles();
    refreshPileStatus();
}

void MainWindow::refreshPermissions()
{
    const auto invites = AdminApiClient::instance().listInviteCodes();
    m_inviteTable->setRowCount(invites.size());
    for (int i = 0; i < invites.size(); ++i) {
        const InviteCode &c = invites[i];
        m_inviteTable->setItem(i, 0, textItem(c.code, c.id));
        m_inviteTable->setItem(i, 1, textItem(c.role));
        m_inviteTable->setItem(i, 2, textItem(c.createdAt));
        m_inviteTable->setItem(i, 3, textItem(c.usedBy > 0 ? c.usedUsername : QStringLiteral("未使用")));
        m_inviteTable->setItem(i, 4, textItem(c.usedAt));
    }
    const QString role = m_permRoleCombo->currentData().toString();
    const auto perms = AdminApiClient::instance().listPermissions(role);
    m_permTable->setRowCount(perms.size());
    for (int i = 0; i < perms.size(); ++i) {
        m_permTable->setItem(i, 0, textItem(perms[i].first));
        auto *item = new QTableWidgetItem(perms[i].second ? QStringLiteral("是") : QStringLiteral("否"));
        item->setFlags(item->flags() | Qt::ItemIsUserCheckable);
        item->setCheckState(perms[i].second ? Qt::Checked : Qt::Unchecked);
        item->setData(Qt::UserRole, perms[i].first);
        m_permTable->setItem(i, 1, item);
    }
}

void MainWindow::onCreateInvite()
{
    refreshPermissions();
}

void MainWindow::onTogglePermission()
{
    const QString role = m_permRoleCombo->currentData().toString();
    for (int i = 0; i < m_permTable->rowCount(); ++i) {
        QTableWidgetItem *item = m_permTable->item(i, 1);
        if (!item)
            continue;
        const QString permission = item->data(Qt::UserRole).toString();
        const bool allowed = item->checkState() == Qt::Checked;
        if (!AdminApiClient::instance().setPermission(role, permission, allowed)) {
            showApiError(QStringLiteral("保存权限失败"));
            return;
        }
    }
    QMessageBox::information(this, QStringLiteral("成功"), QStringLiteral("角色权限已更新"));
    refreshPermissions();
}

void MainWindow::applyTheme(bool dark)
{
    m_darkMode = dark;
    qApp->setStyleSheet(dark ? StyleHelper::adminClientDarkStyle()
                             : StyleHelper::adminClientStyle());
    if (m_darkModeBtn) {
        m_darkModeBtn->blockSignals(true);
        m_darkModeBtn->setChecked(dark);
        m_darkModeBtn->setText(dark ? QStringLiteral("夜间模式：开")
                                    : QStringLiteral("夜间模式：关"));
        m_darkModeBtn->blockSignals(false);
    }
}

void MainWindow::onToggleDarkMode(bool dark)
{
    applyTheme(dark);
    QSettings settings;
    settings.setValue(QStringLiteral("ui/darkMode"), dark);
    if (m_salesChartView && m_salesDays)
        refreshDashboard();
    if (m_statusChartView)
        refreshPileStatus();
}
