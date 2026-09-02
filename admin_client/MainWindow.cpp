#include "MainWindow.h"
#include "AdminApiClient.h"

#include <QAbstractItemView>
#include <QBrush>
#include <QComboBox>
#include <QDialog>
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
    buildUi();
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
        QStringLiteral("用户管理")
    });
    m_nav->setCurrentRow(0);

    sideLayout->addWidget(brand);
    sideLayout->addWidget(who);
    sideLayout->addWidget(m_nav, 1);

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
    default: break;
    }
}

QWidget *MainWindow::buildDashboardPage()
{
    auto *page = new QWidget(this);
    auto *layout = new QVBoxLayout(page);
    layout->setSpacing(10);
    layout->setContentsMargins(0, 0, 0, 0);

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

    auto *refreshBtn = new QPushButton(QStringLiteral("刷新"), page);
    layout->addWidget(title);
    layout->addWidget(m_statusSummary);
    layout->addLayout(mid, 1);
    layout->addWidget(refreshBtn, 0, Qt::AlignRight);
    connect(refreshBtn, &QPushButton::clicked, this, &MainWindow::refreshPileStatus);
    return page;
}

QWidget *MainWindow::buildPilePage()
{
    auto *page = new QWidget(this);
    auto *layout = new QVBoxLayout(page);

    auto *row = new QHBoxLayout;
    auto *title = new QLabel(QStringLiteral("充电桩管理"), page);
    title->setObjectName(QStringLiteral("pageTitle"));
    m_pileStationFilter = new QComboBox(page);
    auto *refreshBtn = new QPushButton(QStringLiteral("刷新"), page);
    auto *restartBtn = new QPushButton(QStringLiteral("远程重启"), page);
    restartBtn->setObjectName(QStringLiteral("secondaryBtn"));
    row->addWidget(title);
    row->addStretch();
    row->addWidget(new QLabel(QStringLiteral("所属电站"), page));
    row->addWidget(m_pileStationFilter, 1);
    row->addWidget(restartBtn);
    row->addWidget(refreshBtn);

    m_pileTable = new QTableWidget(page);
    setupTable(m_pileTable, {
        QStringLiteral("电桩编号"), QStringLiteral("所属电站"), QStringLiteral("类型"),
        QStringLiteral("功率(kW)"), QStringLiteral("当前状态"),
        QStringLiteral("累计充电次数"), QStringLiteral("累计充电时长")
    });

    layout->addLayout(row);
    layout->addWidget(m_pileTable, 1);
    connect(refreshBtn, &QPushButton::clicked, this, &MainWindow::refreshPiles);
    connect(m_pileStationFilter, QOverload<int>::of(&QComboBox::currentIndexChanged),
            this, &MainWindow::refreshPiles);
    connect(restartBtn, &QPushButton::clicked, this, &MainWindow::onRestartPile);
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
    row->addWidget(title);
    row->addWidget(m_stationKeyword, 1);
    row->addWidget(searchBtn);
    row->addWidget(addBtn);

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
    row->addWidget(title);
    row->addWidget(m_userKeyword, 1);
    row->addWidget(searchBtn);
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
    chart->setBackgroundBrush(QBrush(Qt::white));
    chart->setAnimationOptions(QChart::NoAnimation);
    chart->setMargins(QMargins(8, 8, 8, 8));

    auto *axisY = new QValueAxis();
    axisY->setRange(0, maxY * 1.2);
    axisY->setLabelFormat(QStringLiteral("%.0f"));
    axisY->setTitleText(QStringLiteral("营收（元）"));
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
    chart->setBackgroundBrush(QBrush(Qt::white));
    chart->setAnimationOptions(QChart::NoAnimation);
    chart->legend()->setAlignment(Qt::AlignBottom);
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
}

void MainWindow::refreshPiles()
{
    const bool hadSelection = m_pileStationFilter->count() > 0;
    const int current = m_pileStationFilter->currentData().toInt();
    const auto stations = AdminApiClient::instance().listStations();
    m_pileStationFilter->blockSignals(true);
    m_pileStationFilter->clear();
    m_pileStationFilter->addItem(QStringLiteral("全部站点（最多 500 条）"), -1);
    for (const Station &station : stations)
        m_pileStationFilter->addItem(station.name, station.id);
    if (hadSelection) {
        const int idx = m_pileStationFilter->findData(current);
        m_pileStationFilter->setCurrentIndex(idx >= 0 ? idx : 0);
    } else if (m_pileStationFilter->count() > 1) {
        m_pileStationFilter->setCurrentIndex(1);
    }
    m_pileStationFilter->blockSignals(false);

    const int stationId = m_pileStationFilter->currentData().toInt();
    const auto piles = AdminApiClient::instance().listPiles(stationId);
    m_pileTable->setRowCount(piles.size());
    for (int i = 0; i < piles.size(); ++i) {
        const Pile &p = piles[i];
        m_pileTable->setItem(i, 0, textItem(p.pileCode, p.id));
        m_pileTable->setItem(i, 1, textItem(p.stationName));
        m_pileTable->setItem(i, 2, textItem(chargeKindText(p)));
        m_pileTable->setItem(i, 3, textItem(QString::number(p.powerKw, 'f', 1)));
        m_pileTable->setItem(i, 4, textItem(statusTextPile(p.status)));
        m_pileTable->setItem(i, 5, textItem(QString::number(p.totalChargeCount)));
        m_pileTable->setItem(i, 6, textItem(QStringLiteral("%1 分钟").arg(p.totalChargeSeconds / 60)));
    }
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
        QMessageBox::information(this, QStringLiteral("提示"), QStringLiteral("请先选中电桩"));
        return;
    }
    const int pileId = m_pileTable->item(row, 0)->data(Qt::UserRole).toInt();
    const QString code = m_pileTable->item(row, 0)->text();
    if (QMessageBox::question(this, QStringLiteral("远程重启"),
                              QStringLiteral("确认向电桩 %1 发送模拟重启指令？").arg(code))
        != QMessageBox::Yes)
        return;
    if (!AdminApiClient::instance().restartPile(pileId)) {
        showApiError(QStringLiteral("远程重启失败"));
        return;
    }
    QMessageBox::information(this, QStringLiteral("已下发"),
                             QStringLiteral("重启指令已发送，约 1.5 秒后桩将恢复空闲。"));
    refreshPiles();
    QTimer::singleShot(1800, this, [this]() {
        refreshPiles();
        refreshPileStatus();
    });
}

void MainWindow::onAddStation()
{
    QDialog dlg(this);
    dlg.setWindowTitle(QStringLiteral("新增电站（模拟）"));
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
                             QStringLiteral("已新增电站，并模拟生成电桩。"));
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
