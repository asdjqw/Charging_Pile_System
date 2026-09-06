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

#include "ui_MainWindow.h"
#include "ui_EditPileDialog.h"
#include "ui_EditStationDialog.h"
#include "ui_UserOrdersDialog.h"

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
    , ui(new Ui::MainWindow)
    , m_admin(admin)
{
    QSettings settings;
    m_darkMode = settings.value(QStringLiteral("ui/darkMode"), false).toBool();
    buildUi();
    setWindowTitle(QStringLiteral("充电桩管理 - %1").arg(m_admin.realName.isEmpty()
                                                        ? m_admin.username
                                                        : m_admin.realName));
    resize(1180, 740);
    setMinimumSize(980, 640);
    applyTheme(m_darkMode);
    refreshDashboard();
    refreshPileStatus();
    refreshStations();
    refreshPiles();
    refreshUsers();
}

MainWindow::~MainWindow()
{
    delete ui;
}

void MainWindow::bindUiWidgets()
{
    m_darkModeBtn = ui->darkModeBtn;
    m_nav = ui->sideNav;
    m_stack = ui->stack;
    m_kpiTodayAmount = ui->kpiTodayAmount;
    m_kpiMonthAmount = ui->kpiMonthAmount;
    m_kpiTotalAmount = ui->kpiTotalAmount;
    m_salesDays = ui->salesDays;
    m_salesChartView = ui->salesChartView;
    m_recentOrders = ui->recentOrders;
    m_statusSummary = ui->statusSummary;
    m_statusChartView = ui->statusChartView;
    m_statusDistTable = ui->statusDistTable;
    m_statusKeyword = ui->statusKeyword;
    m_statusPileTable = ui->statusPileTable;
    m_pileDistrictFilter = ui->pileDistrictFilter;
    m_pileStationFilter = ui->pileStationFilter;
    m_pileStatusFilter = ui->pileStatusFilter;
    m_pileRestartBtn = ui->pileRestartBtn;
    m_pileTable = ui->pileTable;
    m_stationKeyword = ui->stationKeyword;
    m_stationTable = ui->stationTable;
    m_stationDetailTitle = ui->stationDetailTitle;
    m_stationPileTable = ui->stationPileTable;
    m_userKeyword = ui->userKeyword;
    m_userTable = ui->userTable;
    m_reservationTable = ui->reservationTable;
    m_inviteTable = ui->inviteTable;
    m_inviteRoleCombo = ui->inviteRoleCombo;
    m_permRoleCombo = ui->permRoleCombo;
    m_permTable = ui->permTable;
}

void MainWindow::applyStyleObjectNames()
{
    ui->centralRoot->setObjectName(QStringLiteral("centralRoot"));
    ui->sideBar->setObjectName(QStringLiteral("sideBar"));
    ui->brandTitle->setObjectName(QStringLiteral("brandTitle"));
    ui->brandSub->setObjectName(QStringLiteral("brandSub"));
    ui->sideNav->setObjectName(QStringLiteral("sideNav"));
    ui->darkModeBtn->setObjectName(QStringLiteral("secondaryBtn"));
    ui->logoutBtn->setObjectName(QStringLiteral("dangerBtn"));
    ui->kpiTodayCard->setObjectName(QStringLiteral("kpiCard"));
    ui->kpiMonthCard->setObjectName(QStringLiteral("kpiCard"));
    ui->kpiTotalCard->setObjectName(QStringLiteral("kpiCard"));
    ui->kpiTodayTitle->setObjectName(QStringLiteral("kpiTitle"));
    ui->kpiMonthTitle->setObjectName(QStringLiteral("kpiTitle"));
    ui->kpiTotalTitle->setObjectName(QStringLiteral("kpiTitle"));
    ui->kpiTodayAmount->setObjectName(QStringLiteral("kpiValue"));
    ui->kpiMonthAmount->setObjectName(QStringLiteral("kpiValue"));
    ui->kpiTotalAmount->setObjectName(QStringLiteral("kpiValue"));
    ui->salesChartTitle->setObjectName(QStringLiteral("pageTitle"));
    ui->statusTitle->setObjectName(QStringLiteral("pageTitle"));
    ui->statusSummary->setObjectName(QStringLiteral("muted"));
    ui->pileTitle->setObjectName(QStringLiteral("pageTitle"));
    ui->editPileBtn->setObjectName(QStringLiteral("secondaryBtn"));
    ui->delPileBtn->setObjectName(QStringLiteral("dangerBtn"));
    ui->pileRestartBtn->setObjectName(QStringLiteral("secondaryBtn"));
    ui->pileHint->setObjectName(QStringLiteral("muted"));
    ui->stationTitle->setObjectName(QStringLiteral("pageTitle"));
    ui->editStationBtn->setObjectName(QStringLiteral("secondaryBtn"));
    ui->delStationBtn->setObjectName(QStringLiteral("dangerBtn"));
    ui->stationDetailTitle->setObjectName(QStringLiteral("muted"));
    ui->userTitle->setObjectName(QStringLiteral("pageTitle"));
    ui->userStatusBtn->setObjectName(QStringLiteral("secondaryBtn"));
    ui->reservationTitle->setObjectName(QStringLiteral("pageTitle"));
    ui->cancelReservationBtn->setObjectName(QStringLiteral("dangerBtn"));
    ui->inviteTitle->setObjectName(QStringLiteral("pageTitle"));
    ui->inviteRefreshBtn->setObjectName(QStringLiteral("secondaryBtn"));
    ui->permTitle->setObjectName(QStringLiteral("pageTitle"));
}

void MainWindow::buildUi()
{
    ui->setupUi(this);
    bindUiWidgets();
    applyStyleObjectNames();

    ui->brandTitle->setContentsMargins(14, 0, 14, 0);
    ui->brandSub->setContentsMargins(14, 0, 14, 8);
    ui->darkModeBtn->setContentsMargins(10, 0, 10, 0);
    ui->brandSub->setText(QStringLiteral("%1  %2")
                              .arg(m_admin.realName.isEmpty() ? m_admin.username : m_admin.realName,
                                   m_admin.role));
    m_nav->setCurrentRow(0);
    m_darkModeBtn->setChecked(m_darkMode);
    m_darkModeBtn->setText(m_darkMode ? QStringLiteral("夜间模式：开")
                                      : QStringLiteral("夜间模式：关"));

    m_salesDays->addItem(QStringLiteral("近 7 日"), 7);
    m_salesDays->addItem(QStringLiteral("近 30 日"), 30);
    m_salesChartView->setRenderHint(QPainter::Antialiasing);
    m_statusChartView->setRenderHint(QPainter::Antialiasing);

    m_pileStatusFilter->addItem(QStringLiteral("全部状态"), QString());
    m_pileStatusFilter->addItem(QStringLiteral("空闲"), QStringLiteral("idle"));
    m_pileStatusFilter->addItem(QStringLiteral("已预约"), QStringLiteral("reserved"));
    m_pileStatusFilter->addItem(QStringLiteral("充电中"), QStringLiteral("charging"));
    m_pileStatusFilter->addItem(QStringLiteral("故障"), QStringLiteral("fault"));
    m_pileStatusFilter->addItem(QStringLiteral("离线"), QStringLiteral("offline"));
    m_pileStatusFilter->addItem(QStringLiteral("维修中"), QStringLiteral("restarting"));

    m_inviteRoleCombo->addItem(QStringLiteral("运维 operator"), QStringLiteral("operator"));
    m_inviteRoleCombo->addItem(QStringLiteral("审计 auditor"), QStringLiteral("auditor"));
    m_permRoleCombo->addItem(QStringLiteral("运维 operator"), QStringLiteral("operator"));
    m_permRoleCombo->addItem(QStringLiteral("审计 auditor"), QStringLiteral("auditor"));

    setupTable(m_recentOrders, {
        QStringLiteral("订单号"), QStringLiteral("用户"), QStringLiteral("站点"),
        QStringLiteral("电量(kWh)"), QStringLiteral("金额(元)"), QStringLiteral("状态")
    });
    setupTable(m_statusDistTable, {
        QStringLiteral("运行状态"), QStringLiteral("数量"), QStringLiteral("占比")
    });
    setupTable(m_statusPileTable, {
        QStringLiteral("电桩编号"), QStringLiteral("所属电站"), QStringLiteral("具体位置"),
        QStringLiteral("剩余电量(kWh)"), QStringLiteral("功率(kW)"),
        QStringLiteral("使用状态"), QStringLiteral("是否故障")
    });
    setupTable(m_pileTable, {
        QStringLiteral("电桩ID"), QStringLiteral("电桩编号"), QStringLiteral("所属电站"),
        QStringLiteral("类型"), QStringLiteral("功率(kW)"), QStringLiteral("剩余电量"),
        QStringLiteral("当前状态"), QStringLiteral("是否故障"), QStringLiteral("具体位置")
    });
    setupTable(m_stationTable, {
        QStringLiteral("充电站ID"), QStringLiteral("站名"), QStringLiteral("详细地址"),
        QStringLiteral("经纬度"), QStringLiteral("总电桩数"), QStringLiteral("当前在线率")
    });
    setupTable(m_stationPileTable, {
        QStringLiteral("电桩编号"), QStringLiteral("类型"), QStringLiteral("功率(kW)"),
        QStringLiteral("状态"), QStringLiteral("累计次数")
    });
    setupTable(m_userTable, {
        QStringLiteral("用户ID"), QStringLiteral("手机号"), QStringLiteral("昵称"),
        QStringLiteral("钱包余额"), QStringLiteral("注册时间"), QStringLiteral("状态")
    });
    setupTable(m_reservationTable, {
        QStringLiteral("预约号"), QStringLiteral("用户"), QStringLiteral("手机号"),
        QStringLiteral("电站"), QStringLiteral("电桩"), QStringLiteral("到期时间")
    });
    setupTable(m_inviteTable, {
        QStringLiteral("邀请码"), QStringLiteral("角色"), QStringLiteral("创建时间"),
        QStringLiteral("使用人"), QStringLiteral("使用时间")
    });
    setupTable(m_permTable, {QStringLiteral("权限"), QStringLiteral("允许")});

    connect(m_darkModeBtn, &QPushButton::toggled, this, &MainWindow::onToggleDarkMode);
    connect(ui->logoutBtn, &QPushButton::clicked, this, &MainWindow::onLogout);
    connect(m_nav, &QListWidget::currentRowChanged, this, &MainWindow::onNavChanged);
    connect(ui->dashboardRefreshBtn, &QPushButton::clicked, this, &MainWindow::refreshDashboard);
    connect(m_salesDays, QOverload<int>::of(&QComboBox::currentIndexChanged),
            this, &MainWindow::refreshDashboard);
    connect(ui->pileStatusRefreshBtn, &QPushButton::clicked, this, &MainWindow::refreshPileStatus);
    connect(ui->statusQueryBtn, &QPushButton::clicked, this, &MainWindow::refreshPileStatus);
    connect(m_statusKeyword, &QLineEdit::returnPressed, this, &MainWindow::refreshPileStatus);
    connect(ui->pileRefreshBtn, &QPushButton::clicked, this, &MainWindow::refreshPiles);
    connect(m_pileDistrictFilter, QOverload<int>::of(&QComboBox::currentIndexChanged),
            this, &MainWindow::onPileDistrictChanged);
    connect(m_pileStationFilter, QOverload<int>::of(&QComboBox::currentIndexChanged),
            this, &MainWindow::refreshPiles);
    connect(m_pileStatusFilter, QOverload<int>::of(&QComboBox::currentIndexChanged),
            this, &MainWindow::refreshPiles);
    connect(m_pileRestartBtn, &QPushButton::clicked, this, &MainWindow::onRestartPile);
    connect(m_pileTable, &QTableWidget::itemSelectionChanged,
            this, &MainWindow::onPileSelectionChanged);
    connect(ui->addPileBtn, &QPushButton::clicked, this, &MainWindow::onAddPile);
    connect(ui->editPileBtn, &QPushButton::clicked, this, &MainWindow::onEditPile);
    connect(ui->delPileBtn, &QPushButton::clicked, this, &MainWindow::onDeletePile);
    connect(ui->stationSearchBtn, &QPushButton::clicked, this, &MainWindow::refreshStations);
    connect(m_stationKeyword, &QLineEdit::returnPressed, this, &MainWindow::refreshStations);
    connect(ui->addStationBtn, &QPushButton::clicked, this, &MainWindow::onAddStation);
    connect(ui->editStationBtn, &QPushButton::clicked, this, &MainWindow::onEditStation);
    connect(ui->delStationBtn, &QPushButton::clicked, this, &MainWindow::onDeleteStation);
    connect(m_stationTable, &QTableWidget::cellClicked, this, &MainWindow::onStationRowClicked);
    connect(ui->userSearchBtn, &QPushButton::clicked, this, &MainWindow::refreshUsers);
    connect(m_userKeyword, &QLineEdit::returnPressed, this, &MainWindow::refreshUsers);
    connect(ui->userStatusBtn, &QPushButton::clicked, this, &MainWindow::onToggleUserStatus);
    connect(ui->userOrdersBtn, &QPushButton::clicked, this, &MainWindow::onViewUserOrders);
    connect(ui->reservationRefreshBtn, &QPushButton::clicked, this, &MainWindow::refreshReservations);
    connect(ui->cancelReservationBtn, &QPushButton::clicked, this, &MainWindow::onCancelReservation);
    connect(ui->createInviteBtn, &QPushButton::clicked, this, [this]() {
        QString code;
        if (!AdminApiClient::instance().createInviteCode(m_inviteRoleCombo->currentData().toString(), code)) {
            showApiError(QStringLiteral("生成邀请码失败"));
            return;
        }
        QMessageBox::information(this, QStringLiteral("邀请码已生成"), code);
        refreshPermissions();
    });
    connect(ui->inviteRefreshBtn, &QPushButton::clicked, this, &MainWindow::refreshPermissions);
    connect(m_permRoleCombo, QOverload<int>::of(&QComboBox::currentIndexChanged),
            this, &MainWindow::refreshPermissions);
    connect(ui->permSaveBtn, &QPushButton::clicked, this, &MainWindow::onTogglePermission);
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
    Station station;
    int count = 4;
    if (!editStationDialog(station, &count, true))
        return;
    if (!AdminApiClient::instance().saveStation(station, count)) {
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
    Ui::EditPileDialog form;
    form.setupUi(&dlg);
    dlg.setWindowTitle(isNew ? QStringLiteral("新增电桩") : QStringLiteral("修改电桩"));
    dlg.setStyleSheet(styleSheet());
    form.idEdit->setText(pile.id > 0 ? QString::number(pile.id) : QStringLiteral("自动生成"));
    form.codeEdit->setText(pile.pileCode);
    form.stationIdSpin->setValue(pile.stationId > 0 ? pile.stationId : m_pileStationFilter->currentData().toInt());
    form.typeCombo->addItems({QStringLiteral("AC"), QStringLiteral("DC")});
    form.typeCombo->setCurrentText(pile.pileType.isEmpty() ? QStringLiteral("AC") : pile.pileType);
    form.speedCombo->addItem(QStringLiteral("慢充"), QStringLiteral("slow"));
    form.speedCombo->addItem(QStringLiteral("常规"), QStringLiteral("standard"));
    form.speedCombo->addItem(QStringLiteral("快充"), QStringLiteral("fast"));
    form.speedCombo->addItem(QStringLiteral("超充"), QStringLiteral("ultra"));
    const int speedIdx = form.speedCombo->findData(pile.speedClass);
    form.speedCombo->setCurrentIndex(speedIdx >= 0 ? speedIdx : 0);
    form.connectorCombo->addItem(QStringLiteral("国标交流"), QStringLiteral("GB_T_AC"));
    form.connectorCombo->addItem(QStringLiteral("国标直流"), QStringLiteral("GB_T_DC"));
    form.connectorCombo->addItem(QStringLiteral("CCS2"), QStringLiteral("CCS2"));
    form.connectorCombo->addItem(QStringLiteral("CHAdeMO"), QStringLiteral("CHAdeMO"));
    form.connectorCombo->addItem(QStringLiteral("特斯拉NACS"), QStringLiteral("TeslaNACS"));
    const int connIdx = form.connectorCombo->findData(pile.connectorStandard);
    form.connectorCombo->setCurrentIndex(connIdx >= 0 ? connIdx : 0);
    form.powerSpin->setValue(pile.powerKw > 0 ? pile.powerKw : 7.0);
    form.priceSpin->setValue(pile.pricePerKwh > 0 ? pile.pricePerKwh : 1.2);
    form.remainSpin->setValue(pile.remainingKwh > 0 ? pile.remainingKwh : 100.0);
    form.statusCombo->addItems({QStringLiteral("idle"), QStringLiteral("fault"), QStringLiteral("offline")});
    form.statusCombo->setCurrentText(pile.status.isEmpty() ? QStringLiteral("idle") : pile.status);
    connect(form.saveBtn, &QPushButton::clicked, &dlg, &QDialog::accept);
    if (dlg.exec() != QDialog::Accepted)
        return false;
    pile.pileCode = form.codeEdit->text().trimmed();
    pile.stationId = form.stationIdSpin->value();
    pile.pileType = form.typeCombo->currentText();
    pile.speedClass = form.speedCombo->currentData().toString();
    pile.connectorStandard = form.connectorCombo->currentData().toString();
    pile.powerKw = form.powerSpin->value();
    pile.pricePerKwh = form.priceSpin->value();
    pile.remainingKwh = form.remainSpin->value();
    pile.status = form.statusCombo->currentText();
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
    Ui::EditStationDialog form;
    form.setupUi(&dlg);
    dlg.setWindowTitle(isNew ? QStringLiteral("新增电站") : QStringLiteral("修改电站"));
    dlg.setStyleSheet(styleSheet());
    form.idEdit->setText(station.id > 0 ? QString::number(station.id) : QStringLiteral("自动生成"));
    form.nameEdit->setText(station.name);
    form.addrEdit->setText(station.address);
    form.latEdit->setText(station.latitude != 0 ? QString::number(station.latitude, 'f', 6)
                                                : QStringLiteral("39.9042"));
    form.lngEdit->setText(station.longitude != 0 ? QString::number(station.longitude, 'f', 6)
                                                 : QStringLiteral("116.4074"));
    if (isNew && pileCount) {
        form.pileCountSpin->setValue(*pileCount > 0 ? *pileCount : 4);
        form.saveBtn->setText(QStringLiteral("完成新增"));
    } else {
        form.pileCountLabel->hide();
        form.pileCountSpin->hide();
    }
    connect(form.saveBtn, &QPushButton::clicked, &dlg, &QDialog::accept);
    if (dlg.exec() != QDialog::Accepted)
        return false;
    station.name = form.nameEdit->text().trimmed();
    station.address = form.addrEdit->text().trimmed();
    station.latitude = form.latEdit->text().toDouble();
    station.longitude = form.lngEdit->text().toDouble();
    station.openHours = station.openHours.isEmpty() ? QStringLiteral("00:00-24:00") : station.openHours;
    station.status = station.status.isEmpty() ? QStringLiteral("open") : station.status;
    if (isNew && pileCount)
        *pileCount = form.pileCountSpin->value();
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
    Ui::UserOrdersDialog form;
    form.setupUi(&dlg);
    dlg.setWindowTitle(QStringLiteral("充电记录 - %1").arg(phone));
    dlg.resize(720, 420);
    dlg.setStyleSheet(styleSheet());
    form.deleteBtn->setObjectName(QStringLiteral("dangerBtn"));
    setupTable(form.orderTable, {
        QStringLiteral("订单号"), QStringLiteral("站点"), QStringLiteral("电量"),
        QStringLiteral("金额"), QStringLiteral("状态")
    });
    auto fill = [this, table = form.orderTable, userId]() {
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
    connect(form.deleteBtn, &QPushButton::clicked, &dlg, [this, table = form.orderTable, fill]() {
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
