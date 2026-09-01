#include "MainWindow.h"
#include "DatabaseManager.h"

#include <QAbstractItemView>
#include <QComboBox>
#include <QDialog>
#include <QFormLayout>
#include <QFrame>
#include <QGridLayout>
#include <QHBoxLayout>
#include <QHeaderView>
#include <QInputDialog>
#include <QLabel>
#include <QLineEdit>
#include <QListWidget>
#include <QMessageBox>
#include <QPainter>
#include <QPainterPath>
#include <QPushButton>
#include <QStackedWidget>
#include <QTableWidget>
#include <QTimer>
#include <QVBoxLayout>

class SalesTrendWidget : public QWidget
{
public:
    explicit SalesTrendWidget(QWidget *parent = nullptr)
        : QWidget(parent)
    {
        setMinimumHeight(180);
    }

    void setValues(const QVector<QPair<QString, double>> &values)
    {
        m_values = values;
        update();
    }

protected:
    void paintEvent(QPaintEvent *) override
    {
        QPainter painter(this);
        painter.setRenderHint(QPainter::Antialiasing);
        const QRectF plot = rect().adjusted(52, 14, -18, -30);
        painter.setPen(QColor(QStringLiteral("#DCE3EA")));
        for (int i = 0; i <= 4; ++i) {
            const qreal y = plot.top() + plot.height() * i / 4.0;
            painter.drawLine(QPointF(plot.left(), y), QPointF(plot.right(), y));
        }
        if (m_values.isEmpty()) {
            painter.setPen(QColor(QStringLiteral("#7B8797")));
            painter.drawText(plot, Qt::AlignCenter, QStringLiteral("暂无营收数据"));
            return;
        }

        double maximum = 1.0;
        for (const auto &entry : m_values)
            maximum = qMax(maximum, entry.second);
        QPainterPath path;
        QVector<QPointF> points;
        for (int i = 0; i < m_values.size(); ++i) {
            const qreal x = m_values.size() == 1
                                ? plot.center().x()
                                : plot.left() + plot.width() * i / (m_values.size() - 1.0);
            const qreal y = plot.bottom() - plot.height() * m_values[i].second / maximum;
            points.push_back({x, y});
            i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
        }
        painter.setPen(QPen(QColor(QStringLiteral("#168C7C")), 2.5));
        painter.drawPath(path);
        painter.setBrush(QColor(QStringLiteral("#168C7C")));
        for (const QPointF &point : points)
            painter.drawEllipse(point, 3.5, 3.5);

        painter.setPen(QColor(QStringLiteral("#667383")));
        painter.drawText(QRectF(0, plot.top() - 8, 46, 20), Qt::AlignRight,
                         QString::number(maximum, 'f', 2));
        const int valueCount = int(m_values.size());
        const int labelIndexes[] = {0, valueCount / 2, valueCount - 1};
        for (int index : labelIndexes) {
            const qreal x = points[index].x();
            painter.drawText(QRectF(x - 38, plot.bottom() + 7, 76, 20), Qt::AlignCenter,
                             m_values[index].first.mid(5));
        }
    }

private:
    QVector<QPair<QString, double>> m_values;
};

MainWindow::MainWindow(const Admin &admin, QWidget *parent)
    : QMainWindow(parent)
    , m_admin(admin)
{
    setWindowTitle(QStringLiteral("PC 服务器端 - 运营管理后台"));
    resize(1280, 800);
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
    card->setObjectName(QStringLiteral("card"));
    auto *layout = new QVBoxLayout(card);
    auto *t = new QLabel(title, card);
    t->setObjectName(QStringLiteral("kpiTitle"));
    *valueLabel = new QLabel(QStringLiteral("-"), card);
    (*valueLabel)->setObjectName(QStringLiteral("kpiValue"));
    layout->addWidget(t);
    layout->addWidget(*valueLabel);
    layout->addStretch();
    return card;
}

void MainWindow::buildUi()
{
    auto *central = new QWidget(this);
    setCentralWidget(central);
    auto *root = new QHBoxLayout(central);
    root->setContentsMargins(0, 0, 0, 0);
    root->setSpacing(0);

    m_nav = new QListWidget(central);
    m_nav->setFixedWidth(220);
    m_nav->addItems({
        QStringLiteral("销售业绩"),
        QStringLiteral("电桩状态"),
        QStringLiteral("充电站管理"),
        QStringLiteral("充电桩管理"),
        QStringLiteral("用户管理")
    });
    m_nav->setCurrentRow(0);

    auto *right = new QWidget(central);
    auto *rightLayout = new QVBoxLayout(right);
    rightLayout->setContentsMargins(20, 20, 20, 20);

    auto *header = new QLabel(
        QStringLiteral("欢迎，%1（%2）").arg(m_admin.realName, m_admin.role), right);
    header->setObjectName(QStringLiteral("titleLabel"));
    rightLayout->addWidget(header);

    m_stack = new QStackedWidget(right);
    m_stack->addWidget(buildDashboardPage());
    m_stack->addWidget(buildPileStatusPage());
    m_stack->addWidget(buildStationPage());
    m_stack->addWidget(buildPilePage());
    m_stack->addWidget(buildUserPage());
    rightLayout->addWidget(m_stack, 1);

    root->addWidget(m_nav);
    root->addWidget(right, 1);

    connect(m_nav, &QListWidget::currentRowChanged, this, &MainWindow::onNavChanged);
}

void MainWindow::onNavChanged(int row)
{
    m_stack->setCurrentIndex(row);
    switch (row) {
    case 0: refreshDashboard(); break;
    case 1: refreshPileStatus(); break;
    case 2: refreshStations(); break;
    case 3: refreshPiles(); break;
    case 4: refreshUsers(); break;
    default: break;
    }
}

QWidget *MainWindow::buildDashboardPage()
{
    auto *page = new QWidget(this);
    auto *layout = new QVBoxLayout(page);

    auto *grid = new QGridLayout;
    grid->addWidget(makeKpiCard(QStringLiteral("今日营收 (元)"), &m_kpiTodayAmount), 0, 0);
    grid->addWidget(makeKpiCard(QStringLiteral("本月营收 (元)"), &m_kpiMonthAmount), 0, 1);
    grid->addWidget(makeKpiCard(QStringLiteral("累计营收 (元)"), &m_kpiTotalAmount), 0, 2);
    grid->addWidget(makeKpiCard(QStringLiteral("累计完成订单"), &m_kpiTotalOrders), 0, 3);
    grid->addWidget(makeKpiCard(QStringLiteral("注册用户数"), &m_kpiUsers), 0, 4);
    grid->addWidget(makeKpiCard(QStringLiteral("空闲桩"), &m_kpiIdle), 1, 0);
    grid->addWidget(makeKpiCard(QStringLiteral("充电中"), &m_kpiCharging), 1, 1);
    grid->addWidget(makeKpiCard(QStringLiteral("故障桩"), &m_kpiFault), 1, 2);
    grid->addWidget(makeKpiCard(QStringLiteral("离线桩"), &m_kpiOffline), 1, 3);
    layout->addLayout(grid);

    auto *mid = new QHBoxLayout;
    auto *salesPanel = new QWidget(page);
    auto *salesLayout = new QVBoxLayout(salesPanel);
    auto *salesHeader = new QHBoxLayout;
    salesHeader->addWidget(new QLabel(QStringLiteral("营收趋势"), salesPanel));
    m_salesDays = new QComboBox(salesPanel);
    m_salesDays->addItem(QStringLiteral("近 7 日"), 7);
    m_salesDays->addItem(QStringLiteral("近 30 日"), 30);
    salesHeader->addStretch();
    salesHeader->addWidget(m_salesDays);
    salesLayout->addLayout(salesHeader);
    m_salesTrend = new SalesTrendWidget(salesPanel);
    salesLayout->addWidget(m_salesTrend);
    m_salesTable = new QTableWidget(salesPanel);
    m_salesTable->setColumnCount(2);
    m_salesTable->setHorizontalHeaderLabels({
        QStringLiteral("日期"), QStringLiteral("营收(元)")
    });
    m_salesTable->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);
    m_salesTable->setEditTriggers(QAbstractItemView::NoEditTriggers);
    m_salesTable->setAlternatingRowColors(true);
    m_salesTable->setMinimumHeight(110);
    salesLayout->addWidget(m_salesTable);

    m_recentOrders = new QTableWidget(page);
    m_recentOrders->setColumnCount(6);
    m_recentOrders->setHorizontalHeaderLabels({
        QStringLiteral("订单号"), QStringLiteral("用户"), QStringLiteral("站点"),
        QStringLiteral("电量"), QStringLiteral("金额"), QStringLiteral("状态")
    });
    m_recentOrders->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);
    m_recentOrders->setEditTriggers(QAbstractItemView::NoEditTriggers);
    m_recentOrders->setAlternatingRowColors(true);

    mid->addWidget(salesPanel, 2);
    mid->addWidget(m_recentOrders, 3);
    layout->addLayout(mid, 1);

    auto *refreshBtn = new QPushButton(QStringLiteral("刷新业绩数据"), page);
    layout->addWidget(refreshBtn, 0, Qt::AlignRight);
    connect(refreshBtn, &QPushButton::clicked, this, &MainWindow::refreshDashboard);
    connect(m_salesDays, QOverload<int>::of(&QComboBox::currentIndexChanged),
            this, &MainWindow::refreshDashboard);
    return page;
}

QWidget *MainWindow::buildPileStatusPage()
{
    auto *page = new QWidget(this);
    auto *layout = new QVBoxLayout(page);

    auto *row = new QHBoxLayout;
    m_statusFilter = new QComboBox(page);
    m_statusFilter->addItem(QStringLiteral("全部状态"), QString());
    m_statusFilter->addItem(QStringLiteral("空闲"), QStringLiteral("idle"));
    m_statusFilter->addItem(QStringLiteral("充电中"), QStringLiteral("charging"));
    m_statusFilter->addItem(QStringLiteral("故障"), QStringLiteral("fault"));
    m_statusFilter->addItem(QStringLiteral("离线"), QStringLiteral("offline"));
    auto *refreshBtn = new QPushButton(QStringLiteral("刷新"), page);
    auto *setBtn = new QPushButton(QStringLiteral("修改选中桩状态"), page);
    setBtn->setObjectName(QStringLiteral("secondaryBtn"));
    row->addWidget(new QLabel(QStringLiteral("状态筛选"), page));
    row->addWidget(m_statusFilter);
    row->addStretch();
    row->addWidget(setBtn);
    row->addWidget(refreshBtn);

    m_statusSummary = new QLabel(page);
    m_statusSummary->setWordWrap(true);
    m_statusSummary->setObjectName(QStringLiteral("muted"));

    m_statusTable = new QTableWidget(page);
    m_statusTable->setColumnCount(7);
    m_statusTable->setHorizontalHeaderLabels({
        QStringLiteral("ID"), QStringLiteral("桩编号"), QStringLiteral("所属站点"),
        QStringLiteral("类型"), QStringLiteral("功率(kW)"), QStringLiteral("单价"), QStringLiteral("状态")
    });
    m_statusTable->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);
    m_statusTable->setSelectionBehavior(QAbstractItemView::SelectRows);
    m_statusTable->setEditTriggers(QAbstractItemView::NoEditTriggers);
    m_statusTable->setAlternatingRowColors(true);

    layout->addLayout(row);
    layout->addWidget(m_statusSummary);
    layout->addWidget(m_statusTable, 1);

    connect(refreshBtn, &QPushButton::clicked, this, &MainWindow::refreshPileStatus);
    connect(m_statusFilter, QOverload<int>::of(&QComboBox::currentIndexChanged),
            this, &MainWindow::refreshPileStatus);
    connect(setBtn, &QPushButton::clicked, this, &MainWindow::onSetPileStatus);
    return page;
}

QWidget *MainWindow::buildStationPage()
{
    auto *page = new QWidget(this);
    auto *layout = new QVBoxLayout(page);

    auto *row = new QHBoxLayout;
    m_stationKeyword = new QLineEdit(page);
    m_stationKeyword->setPlaceholderText(QStringLiteral("搜索充电站"));
    auto *searchBtn = new QPushButton(QStringLiteral("查询"), page);
    auto *addBtn = new QPushButton(QStringLiteral("新增"), page);
    auto *editBtn = new QPushButton(QStringLiteral("编辑"), page);
    editBtn->setObjectName(QStringLiteral("secondaryBtn"));
    auto *delBtn = new QPushButton(QStringLiteral("删除"), page);
    delBtn->setObjectName(QStringLiteral("dangerBtn"));
    row->addWidget(m_stationKeyword, 1);
    row->addWidget(searchBtn);
    row->addWidget(addBtn);
    row->addWidget(editBtn);
    row->addWidget(delBtn);

    m_stationTable = new QTableWidget(page);
    m_stationTable->setColumnCount(9);
    m_stationTable->setHorizontalHeaderLabels({
        QStringLiteral("ID"), QStringLiteral("名称"), QStringLiteral("地址"),
        QStringLiteral("纬度"), QStringLiteral("经度"), QStringLiteral("电桩数"),
        QStringLiteral("在线率"), QStringLiteral("营业时间"), QStringLiteral("状态")
    });
    m_stationTable->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);
    m_stationTable->setSelectionBehavior(QAbstractItemView::SelectRows);
    m_stationTable->setEditTriggers(QAbstractItemView::NoEditTriggers);
    m_stationTable->setAlternatingRowColors(true);

    layout->addLayout(row);
    layout->addWidget(m_stationTable, 1);

    connect(searchBtn, &QPushButton::clicked, this, &MainWindow::refreshStations);
    connect(addBtn, &QPushButton::clicked, this, &MainWindow::onAddStation);
    connect(editBtn, &QPushButton::clicked, this, &MainWindow::onEditStation);
    connect(delBtn, &QPushButton::clicked, this, &MainWindow::onDeleteStation);
    return page;
}

QWidget *MainWindow::buildPilePage()
{
    auto *page = new QWidget(this);
    auto *layout = new QVBoxLayout(page);

    auto *row = new QHBoxLayout;
    m_pileStationFilter = new QComboBox(page);
    auto *refreshBtn = new QPushButton(QStringLiteral("刷新"), page);
    auto *addBtn = new QPushButton(QStringLiteral("新增"), page);
    auto *editBtn = new QPushButton(QStringLiteral("编辑"), page);
    editBtn->setObjectName(QStringLiteral("secondaryBtn"));
    auto *restartBtn = new QPushButton(QStringLiteral("远程重启"), page);
    restartBtn->setObjectName(QStringLiteral("secondaryBtn"));
    auto *delBtn = new QPushButton(QStringLiteral("删除"), page);
    delBtn->setObjectName(QStringLiteral("dangerBtn"));
    row->addWidget(new QLabel(QStringLiteral("所属站点"), page));
    row->addWidget(m_pileStationFilter, 1);
    row->addWidget(refreshBtn);
    row->addWidget(addBtn);
    row->addWidget(editBtn);
    row->addWidget(restartBtn);
    row->addWidget(delBtn);

    m_pileTable = new QTableWidget(page);
    m_pileTable->setColumnCount(9);
    m_pileTable->setHorizontalHeaderLabels({
        QStringLiteral("ID"), QStringLiteral("桩编号"), QStringLiteral("站点"),
        QStringLiteral("类型"), QStringLiteral("功率"), QStringLiteral("单价"), QStringLiteral("状态"),
        QStringLiteral("累计次数"), QStringLiteral("累计时长")
    });
    m_pileTable->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);
    m_pileTable->setSelectionBehavior(QAbstractItemView::SelectRows);
    m_pileTable->setEditTriggers(QAbstractItemView::NoEditTriggers);
    m_pileTable->setAlternatingRowColors(true);

    layout->addLayout(row);
    layout->addWidget(m_pileTable, 1);

    connect(refreshBtn, &QPushButton::clicked, this, &MainWindow::refreshPiles);
    connect(m_pileStationFilter, QOverload<int>::of(&QComboBox::currentIndexChanged),
            this, &MainWindow::refreshPiles);
    connect(addBtn, &QPushButton::clicked, this, &MainWindow::onAddPile);
    connect(editBtn, &QPushButton::clicked, this, &MainWindow::onEditPile);
    connect(restartBtn, &QPushButton::clicked, this, &MainWindow::onRestartPile);
    connect(delBtn, &QPushButton::clicked, this, &MainWindow::onDeletePile);
    return page;
}

QWidget *MainWindow::buildUserPage()
{
    auto *page = new QWidget(this);
    auto *layout = new QVBoxLayout(page);

    auto *row = new QHBoxLayout;
    m_userKeyword = new QLineEdit(page);
    m_userKeyword->setPlaceholderText(QStringLiteral("搜索用户名/手机/车牌"));
    auto *searchBtn = new QPushButton(QStringLiteral("查询"), page);
    auto *rechargeBtn = new QPushButton(QStringLiteral("给选中用户充值"), page);
    rechargeBtn->setObjectName(QStringLiteral("secondaryBtn"));
    auto *statusBtn = new QPushButton(QStringLiteral("冻结/解冻"), page);
    statusBtn->setObjectName(QStringLiteral("secondaryBtn"));
    auto *delBtn = new QPushButton(QStringLiteral("删除用户"), page);
    delBtn->setObjectName(QStringLiteral("dangerBtn"));
    row->addWidget(m_userKeyword, 1);
    row->addWidget(searchBtn);
    row->addWidget(rechargeBtn);
    row->addWidget(statusBtn);
    row->addWidget(delBtn);

    m_userTable = new QTableWidget(page);
    m_userTable->setColumnCount(9);
    m_userTable->setHorizontalHeaderLabels({
        QStringLiteral("ID"), QStringLiteral("手机号"), QStringLiteral("昵称"),
        QStringLiteral("余额"), QStringLiteral("车型"), QStringLiteral("车牌"),
        QStringLiteral("注册时间"), QStringLiteral("状态"), QStringLiteral("内部账号")
    });
    m_userTable->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);
    m_userTable->setSelectionBehavior(QAbstractItemView::SelectRows);
    m_userTable->setEditTriggers(QAbstractItemView::NoEditTriggers);
    m_userTable->setAlternatingRowColors(true);

    layout->addLayout(row);
    layout->addWidget(m_userTable, 1);

    connect(searchBtn, &QPushButton::clicked, this, &MainWindow::refreshUsers);
    connect(rechargeBtn, &QPushButton::clicked, this, &MainWindow::onRechargeUser);
    connect(statusBtn, &QPushButton::clicked, this, &MainWindow::onToggleUserStatus);
    connect(delBtn, &QPushButton::clicked, this, &MainWindow::onDeleteUser);
    return page;
}

void MainWindow::refreshDashboard()
{
    const auto stats = DatabaseManager::instance().salesStats();
    m_kpiTodayAmount->setText(QString::number(stats.todayAmount, 'f', 2));
    m_kpiMonthAmount->setText(QString::number(stats.monthAmount, 'f', 2));
    m_kpiTotalAmount->setText(QString::number(stats.totalAmount, 'f', 2));
    m_kpiTotalOrders->setText(QString::number(stats.totalOrders));
    m_kpiUsers->setText(QString::number(stats.totalUsers));
    m_kpiIdle->setText(QString::number(stats.idlePiles));
    m_kpiCharging->setText(QString::number(stats.chargingPiles));
    m_kpiFault->setText(QString::number(stats.faultPiles));
    m_kpiOffline->setText(QString::number(stats.offlinePiles));

    const int days = m_salesDays ? m_salesDays->currentData().toInt() : 7;
    const auto daily = DatabaseManager::instance().dailySales(days);
    m_salesTrend->setValues(daily);
    m_salesTable->setRowCount(daily.isEmpty() ? 1 : daily.size());
    if (daily.isEmpty()) {
        m_salesTable->setItem(0, 0, new QTableWidgetItem(QStringLiteral("暂无数据")));
        m_salesTable->setItem(0, 1, new QTableWidgetItem(QStringLiteral("0.00")));
    } else {
        for (int i = 0; i < daily.size(); ++i) {
            m_salesTable->setItem(i, 0, new QTableWidgetItem(daily[i].first));
            m_salesTable->setItem(i, 1, new QTableWidgetItem(QString::number(daily[i].second, 'f', 2)));
        }
    }

    const auto orders = DatabaseManager::instance().listOrders();
    const int rows = qMin(12, orders.size());
    m_recentOrders->setRowCount(rows);
    for (int i = 0; i < rows; ++i) {
        const auto &o = orders[i];
        m_recentOrders->setItem(i, 0, new QTableWidgetItem(o.orderNo));
        m_recentOrders->setItem(i, 1, new QTableWidgetItem(o.username));
        m_recentOrders->setItem(i, 2, new QTableWidgetItem(o.stationName));
        m_recentOrders->setItem(i, 3, new QTableWidgetItem(QString::number(o.energyKwh, 'f', 2)));
        m_recentOrders->setItem(i, 4, new QTableWidgetItem(QString::number(o.amount, 'f', 2)));
        m_recentOrders->setItem(i, 5, new QTableWidgetItem(statusTextOrder(o.status)));
    }
}

void MainWindow::refreshPileStatus()
{
    const auto stats = DatabaseManager::instance().salesStats();
    const int total = qMax(1, stats.totalPiles);
    m_statusSummary->setText(
        QStringLiteral("设备总数 %1 · 空闲 %2 (%3%) · 充电中 %4 (%5%) · 已预约 %6 (%7%) · 故障 %8 (%9%) · 离线 %10 (%11%)")
            .arg(stats.totalPiles).arg(stats.idlePiles)
            .arg(stats.idlePiles * 100.0 / total, 0, 'f', 1)
            .arg(stats.chargingPiles).arg(stats.chargingPiles * 100.0 / total, 0, 'f', 1)
            .arg(stats.reservedPiles).arg(stats.reservedPiles * 100.0 / total, 0, 'f', 1)
            .arg(stats.faultPiles).arg(stats.faultPiles * 100.0 / total, 0, 'f', 1)
            .arg(stats.offlinePiles).arg(stats.offlinePiles * 100.0 / total, 0, 'f', 1));
    const QString status = m_statusFilter->currentData().toString();
    const auto piles = DatabaseManager::instance().listPiles(-1, status);
    m_statusTable->setRowCount(piles.size());
    for (int i = 0; i < piles.size(); ++i) {
        const auto &p = piles[i];
        m_statusTable->setItem(i, 0, new QTableWidgetItem(QString::number(p.id)));
        m_statusTable->setItem(i, 1, new QTableWidgetItem(p.pileCode));
        m_statusTable->setItem(i, 2, new QTableWidgetItem(p.stationName));
        m_statusTable->setItem(i, 3, new QTableWidgetItem(pileCategoryText(p)));
        m_statusTable->setItem(i, 4, new QTableWidgetItem(QString::number(p.powerKw, 'f', 1)));
        m_statusTable->setItem(i, 5, new QTableWidgetItem(QString::number(p.pricePerKwh, 'f', 2)));
        m_statusTable->setItem(i, 6, new QTableWidgetItem(statusTextPile(p.status)));
    }
}

void MainWindow::refreshStations()
{
    const auto stations = DatabaseManager::instance().listStations(39.96, 116.36, m_stationKeyword->text());
    m_stationTable->setRowCount(stations.size());
    for (int i = 0; i < stations.size(); ++i) {
        const auto &s = stations[i];
        m_stationTable->setItem(i, 0, new QTableWidgetItem(QString::number(s.id)));
        m_stationTable->setItem(i, 1, new QTableWidgetItem(s.name));
        m_stationTable->setItem(i, 2, new QTableWidgetItem(s.address));
        m_stationTable->setItem(i, 3, new QTableWidgetItem(QString::number(s.latitude, 'f', 4)));
        m_stationTable->setItem(i, 4, new QTableWidgetItem(QString::number(s.longitude, 'f', 4)));
        m_stationTable->setItem(i, 5, new QTableWidgetItem(QString::number(s.totalPiles)));
        m_stationTable->setItem(i, 6, new QTableWidgetItem(QStringLiteral("%1%").arg(s.onlineRate, 0, 'f', 1)));
        m_stationTable->setItem(i, 7, new QTableWidgetItem(s.openHours));
        m_stationTable->setItem(i, 8, new QTableWidgetItem(statusTextStation(s.status)));
    }

    // 同步桩管理页的站点筛选
    const int current = m_pileStationFilter->currentData().toInt();
    m_pileStationFilter->blockSignals(true);
    m_pileStationFilter->clear();
    m_pileStationFilter->addItem(QStringLiteral("全部站点"), -1);
    for (const auto &s : stations)
        m_pileStationFilter->addItem(s.name, s.id);
    const int idx = m_pileStationFilter->findData(current);
    m_pileStationFilter->setCurrentIndex(idx >= 0 ? idx : 0);
    m_pileStationFilter->blockSignals(false);
}

void MainWindow::refreshPiles()
{
    const int stationId = m_pileStationFilter->currentData().toInt();
    const auto piles = DatabaseManager::instance().listPiles(stationId);
    m_pileTable->setRowCount(piles.size());
    for (int i = 0; i < piles.size(); ++i) {
        const auto &p = piles[i];
        m_pileTable->setItem(i, 0, new QTableWidgetItem(QString::number(p.id)));
        m_pileTable->setItem(i, 1, new QTableWidgetItem(p.pileCode));
        m_pileTable->setItem(i, 2, new QTableWidgetItem(p.stationName));
        m_pileTable->setItem(i, 3, new QTableWidgetItem(pileCategoryText(p)));
        m_pileTable->setItem(i, 4, new QTableWidgetItem(QString::number(p.powerKw, 'f', 1)));
        m_pileTable->setItem(i, 5, new QTableWidgetItem(QString::number(p.pricePerKwh, 'f', 2)));
        m_pileTable->setItem(i, 6, new QTableWidgetItem(statusTextPile(p.status)));
        m_pileTable->setItem(i, 7, new QTableWidgetItem(QString::number(p.totalChargeCount)));
        m_pileTable->setItem(i, 8, new QTableWidgetItem(
            QStringLiteral("%1 分钟").arg(p.totalChargeSeconds / 60)));
    }
}

void MainWindow::refreshUsers()
{
    const auto users = DatabaseManager::instance().listUsers(m_userKeyword->text());
    m_userTable->setRowCount(users.size());
    for (int i = 0; i < users.size(); ++i) {
        const auto &u = users[i];
        m_userTable->setItem(i, 0, new QTableWidgetItem(QString::number(u.id)));
        m_userTable->setItem(i, 1, new QTableWidgetItem(u.phone));
        m_userTable->setItem(i, 2, new QTableWidgetItem(u.nickname));
        m_userTable->setItem(i, 3, new QTableWidgetItem(QString::number(u.balance, 'f', 2)));
        m_userTable->setItem(i, 4, new QTableWidgetItem(u.carModel));
        m_userTable->setItem(i, 5, new QTableWidgetItem(u.plateNumber));
        m_userTable->setItem(i, 6, new QTableWidgetItem(u.createdAt));
        m_userTable->setItem(i, 7, new QTableWidgetItem(statusTextUser(u.status)));
        m_userTable->setItem(i, 8, new QTableWidgetItem(u.username));
    }
}

static bool stationDialog(QWidget *parent, Station &station, bool isEdit)
{
    QDialog dlg(parent);
    dlg.setWindowTitle(isEdit ? QStringLiteral("编辑充电站") : QStringLiteral("新增充电站"));
    auto *form = new QFormLayout(&dlg);
    auto *name = new QLineEdit(station.name, &dlg);
    auto *addr = new QLineEdit(station.address, &dlg);
    auto *lat = new QLineEdit(QString::number(station.latitude), &dlg);
    auto *lng = new QLineEdit(QString::number(station.longitude), &dlg);
    auto *hours = new QLineEdit(station.openHours.isEmpty() ? QStringLiteral("00:00-24:00") : station.openHours, &dlg);
    auto *status = new QComboBox(&dlg);
    status->addItems({QStringLiteral("open"), QStringLiteral("closed"), QStringLiteral("maintenance")});
    status->setCurrentText(station.status.isEmpty() ? QStringLiteral("open") : station.status);
    form->addRow(QStringLiteral("名称"), name);
    form->addRow(QStringLiteral("地址"), addr);
    form->addRow(QStringLiteral("纬度"), lat);
    form->addRow(QStringLiteral("经度"), lng);
    form->addRow(QStringLiteral("营业时间"), hours);
    form->addRow(QStringLiteral("状态"), status);
    auto *ok = new QPushButton(QStringLiteral("保存"), &dlg);
    form->addRow(ok);
    QObject::connect(ok, &QPushButton::clicked, &dlg, &QDialog::accept);
    if (dlg.exec() != QDialog::Accepted)
        return false;
    station.name = name->text().trimmed();
    station.address = addr->text().trimmed();
    station.latitude = lat->text().toDouble();
    station.longitude = lng->text().toDouble();
    station.openHours = hours->text().trimmed();
    station.status = status->currentText();
    return !station.name.isEmpty() && !station.address.isEmpty();
}

void MainWindow::onAddStation()
{
    Station s;
    if (!stationDialog(this, s, false))
        return;
    if (!DatabaseManager::instance().saveStation(s)) {
        QMessageBox::warning(this, QStringLiteral("失败"), DatabaseManager::instance().lastError());
        return;
    }
    refreshStations();
    refreshPiles();
}

void MainWindow::onEditStation()
{
    const int row = m_stationTable->currentRow();
    if (row < 0) {
        QMessageBox::information(this, QStringLiteral("提示"), QStringLiteral("请先选择一行"));
        return;
    }
    Station s;
    s.id = m_stationTable->item(row, 0)->text().toInt();
    if (!DatabaseManager::instance().getStation(s.id, s)) {
        QMessageBox::warning(this, QStringLiteral("失败"), DatabaseManager::instance().lastError());
        return;
    }
    if (!stationDialog(this, s, true))
        return;
    if (!DatabaseManager::instance().saveStation(s)) {
        QMessageBox::warning(this, QStringLiteral("失败"), DatabaseManager::instance().lastError());
        return;
    }
    refreshStations();
}

void MainWindow::onDeleteStation()
{
    const int row = m_stationTable->currentRow();
    if (row < 0)
        return;
    const int id = m_stationTable->item(row, 0)->text().toInt();
    if (QMessageBox::question(this, QStringLiteral("确认"),
                              QStringLiteral("删除站点会级联删除其下充电桩，确认吗？"))
        != QMessageBox::Yes)
        return;
    if (!DatabaseManager::instance().deleteStation(id)) {
        QMessageBox::warning(this, QStringLiteral("失败"), DatabaseManager::instance().lastError());
        return;
    }
    refreshStations();
    refreshPiles();
    refreshPileStatus();
}

static bool pileDialog(QWidget *parent, Pile &pile, const QVector<Station> &stations, bool isEdit)
{
    if (stations.isEmpty())
        return false;
    QDialog dlg(parent);
    dlg.setWindowTitle(isEdit ? QStringLiteral("编辑充电桩") : QStringLiteral("新增充电桩"));
    auto *form = new QFormLayout(&dlg);
    auto *stationCombo = new QComboBox(&dlg);
    for (const auto &s : stations)
        stationCombo->addItem(s.name, s.id);
    if (pile.stationId > 0)
        stationCombo->setCurrentIndex(stationCombo->findData(pile.stationId));
    auto *code = new QLineEdit(pile.pileCode, &dlg);
    auto *type = new QComboBox(&dlg);
    type->addItems({QStringLiteral("AC"), QStringLiteral("DC")});
    type->setCurrentText(pile.pileType.isEmpty() ? QStringLiteral("AC") : pile.pileType);
    auto *power = new QLineEdit(pile.powerKw > 0 ? QString::number(pile.powerKw) : QStringLiteral("7"), &dlg);
    auto *price = new QLineEdit(pile.pricePerKwh > 0 ? QString::number(pile.pricePerKwh) : QStringLiteral("1.2"), &dlg);
    auto *status = new QComboBox(&dlg);
    status->addItems({QStringLiteral("idle"), QStringLiteral("charging"),
                      QStringLiteral("fault"), QStringLiteral("offline")});
    status->setCurrentText(pile.status.isEmpty() ? QStringLiteral("idle") : pile.status);
    form->addRow(QStringLiteral("所属站点"), stationCombo);
    form->addRow(QStringLiteral("桩编号"), code);
    form->addRow(QStringLiteral("类型"), type);
    form->addRow(QStringLiteral("功率(kW)"), power);
    form->addRow(QStringLiteral("单价(元/kWh)"), price);
    form->addRow(QStringLiteral("状态"), status);
    auto *ok = new QPushButton(QStringLiteral("保存"), &dlg);
    form->addRow(ok);
    QObject::connect(ok, &QPushButton::clicked, &dlg, &QDialog::accept);
    if (dlg.exec() != QDialog::Accepted)
        return false;
    pile.stationId = stationCombo->currentData().toInt();
    pile.pileCode = code->text().trimmed();
    pile.pileType = type->currentText();
    pile.powerKw = power->text().toDouble();
    pile.pricePerKwh = price->text().toDouble();
    pile.status = status->currentText();
    return !pile.pileCode.isEmpty();
}

void MainWindow::onAddPile()
{
    const auto stations = DatabaseManager::instance().listStations();
    Pile p;
    if (!pileDialog(this, p, stations, false))
        return;
    if (!DatabaseManager::instance().savePile(p)) {
        QMessageBox::warning(this, QStringLiteral("失败"), DatabaseManager::instance().lastError());
        return;
    }
    refreshPiles();
    refreshPileStatus();
    refreshDashboard();
}

void MainWindow::onEditPile()
{
    const int row = m_pileTable->currentRow();
    if (row < 0) {
        QMessageBox::information(this, QStringLiteral("提示"), QStringLiteral("请先选择一行"));
        return;
    }
    Pile p;
    if (!DatabaseManager::instance().getPile(m_pileTable->item(row, 0)->text().toInt(), p)) {
        QMessageBox::warning(this, QStringLiteral("失败"), DatabaseManager::instance().lastError());
        return;
    }
    const auto stations = DatabaseManager::instance().listStations();
    if (!pileDialog(this, p, stations, true))
        return;
    if (!DatabaseManager::instance().savePile(p)) {
        QMessageBox::warning(this, QStringLiteral("失败"), DatabaseManager::instance().lastError());
        return;
    }
    refreshPiles();
    refreshPileStatus();
}

void MainWindow::onDeletePile()
{
    const int row = m_pileTable->currentRow();
    if (row < 0)
        return;
    const int id = m_pileTable->item(row, 0)->text().toInt();
    if (QMessageBox::question(this, QStringLiteral("确认"), QStringLiteral("确认删除该充电桩？"))
        != QMessageBox::Yes)
        return;
    if (!DatabaseManager::instance().deletePile(id)) {
        QMessageBox::warning(this, QStringLiteral("失败"), DatabaseManager::instance().lastError());
        return;
    }
    refreshPiles();
    refreshPileStatus();
}

void MainWindow::onSetPileStatus()
{
    const int row = m_statusTable->currentRow();
    if (row < 0) {
        QMessageBox::information(this, QStringLiteral("提示"), QStringLiteral("请先选择充电桩"));
        return;
    }
    const int id = m_statusTable->item(row, 0)->text().toInt();
    const QStringList statuses = {
        QStringLiteral("idle"), QStringLiteral("charging"),
        QStringLiteral("fault"), QStringLiteral("offline")
    };
    bool ok = false;
    const QString status = QInputDialog::getItem(
        this, QStringLiteral("修改状态"), QStringLiteral("选择新状态"),
        statuses, 0, false, &ok);
    if (!ok)
        return;
    if (!DatabaseManager::instance().updatePileStatus(
            id, status, QStringLiteral("admin"), QStringLiteral("管理员手动修改"))) {
        QMessageBox::warning(this, QStringLiteral("失败"), DatabaseManager::instance().lastError());
        return;
    }
    refreshPileStatus();
    refreshPiles();
    refreshDashboard();
}

void MainWindow::onRestartPile()
{
    const int row = m_pileTable->currentRow();
    if (row < 0) {
        QMessageBox::information(this, QStringLiteral("提示"), QStringLiteral("请先选择充电桩"));
        return;
    }
    const int id = m_pileTable->item(row, 0)->text().toInt();
    if (!DatabaseManager::instance().restartPile(id, m_admin.id)) {
        QMessageBox::warning(this, QStringLiteral("重启失败"), DatabaseManager::instance().lastError());
        return;
    }
    refreshPiles();
    refreshPileStatus();
    QTimer::singleShot(1500, this, [this, id]() {
        DatabaseManager::instance().updatePileStatus(
            id, QStringLiteral("idle"), QStringLiteral("pile"), QStringLiteral("模拟重启完成"));
        refreshPiles();
        refreshPileStatus();
        refreshDashboard();
    });
}

void MainWindow::onToggleUserStatus()
{
    const int row = m_userTable->currentRow();
    if (row < 0) {
        QMessageBox::information(this, QStringLiteral("提示"), QStringLiteral("请先选择用户"));
        return;
    }
    const int id = m_userTable->item(row, 0)->text().toInt();
    const QString current = m_userTable->item(row, 7)->text();
    const QString next = current == QStringLiteral("冻结")
                             ? QStringLiteral("normal") : QStringLiteral("frozen");
    const QString action = next == QLatin1String("frozen") ? QStringLiteral("冻结") : QStringLiteral("解冻");
    if (QMessageBox::question(this, QStringLiteral("确认操作"),
                              QStringLiteral("确认%1该用户？").arg(action)) != QMessageBox::Yes)
        return;
    if (!DatabaseManager::instance().setUserStatus(id, next, m_admin.id)) {
        QMessageBox::warning(this, QStringLiteral("操作失败"), DatabaseManager::instance().lastError());
        return;
    }
    refreshUsers();
}

void MainWindow::onDeleteUser()
{
    const int row = m_userTable->currentRow();
    if (row < 0)
        return;
    const int id = m_userTable->item(row, 0)->text().toInt();
    if (QMessageBox::question(this, QStringLiteral("确认"), QStringLiteral("确认删除该用户？"))
        != QMessageBox::Yes)
        return;
    if (!DatabaseManager::instance().deleteUser(id)) {
        QMessageBox::warning(this, QStringLiteral("失败"), DatabaseManager::instance().lastError());
        return;
    }
    refreshUsers();
    refreshDashboard();
}

void MainWindow::onRechargeUser()
{
    const int row = m_userTable->currentRow();
    if (row < 0) {
        QMessageBox::information(this, QStringLiteral("提示"), QStringLiteral("请先选择用户"));
        return;
    }
    const int id = m_userTable->item(row, 0)->text().toInt();
    bool ok = false;
    const double amount = QInputDialog::getDouble(
        this, QStringLiteral("用户充值"), QStringLiteral("充值金额（元）"),
        50.0, 1.0, 10000.0, 2, &ok);
    if (!ok)
        return;
    if (!DatabaseManager::instance().rechargeUser(id, amount)) {
        QMessageBox::warning(this, QStringLiteral("失败"), DatabaseManager::instance().lastError());
        return;
    }
    refreshUsers();
}
