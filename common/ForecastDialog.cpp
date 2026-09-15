#include "ForecastDialog.h"

#include <QAbstractItemView>
#include <QApplication>
#include <QBrush>
#include <QColor>
#include <QFrame>
#include <QHBoxLayout>
#include <QHeaderView>
#include <QJsonArray>
#include <QLabel>
#include <QList>
#include <QMargins>
#include <QPainter>
#include <QPushButton>
#include <QStringList>
#include <QTableWidget>
#include <QTableWidgetItem>
#include <QVBoxLayout>

#include <QtCharts/QBarCategoryAxis>
#include <QtCharts/QBarSeries>
#include <QtCharts/QBarSet>
#include <QtCharts/QChart>
#include <QtCharts/QChartView>
#include <QtCharts/QValueAxis>

#ifdef QT_CHARTS_USE_NAMESPACE
QT_CHARTS_USE_NAMESPACE
#endif

namespace {

QFrame *makeKpiCard(QLabel **valueOut, const QString &title)
{
    auto *card = new QFrame;
    card->setObjectName(QStringLiteral("kpiCard"));
    auto *box = new QVBoxLayout(card);
    box->setContentsMargins(12, 10, 12, 10);
    box->setSpacing(4);
    auto *titleLabel = new QLabel(title);
    titleLabel->setObjectName(QStringLiteral("kpiTitle"));
    auto *value = new QLabel(QStringLiteral("—"));
    value->setObjectName(QStringLiteral("kpiValue"));
    value->setWordWrap(true);
    box->addWidget(titleLabel);
    box->addWidget(value);
    *valueOut = value;
    return card;
}

} // namespace

ForecastDialog::ForecastDialog(int stationId, const QString &stationName, const QJsonObject &payload,
                               bool darkMode, QWidget *parent)
    : QDialog(parent)
    , m_stationId(stationId)
    , m_stationName(stationName)
    , m_payload(payload)
    , m_darkMode(darkMode)
{
    setWindowTitle(QStringLiteral("充电预测"));
    setMinimumSize(860, 620);
    resize(920, 680);
    if (qApp)
        setStyleSheet(qApp->styleSheet());
    buildUi();
    applyCharts();
}

QJsonObject ForecastDialog::horizon(const QJsonObject &forecast, const char *key) const
{
    return forecast.value(QLatin1String(key)).toObject();
}

QString ForecastDialog::congestionText(const QString &level) const
{
    if (level == QLatin1String("high"))
        return QStringLiteral("拥堵");
    if (level == QLatin1String("medium"))
        return QStringLiteral("较拥堵");
    if (level == QLatin1String("low"))
        return QStringLiteral("畅通");
    return level.isEmpty() ? QStringLiteral("—") : level;
}

QString ForecastDialog::warningText(const QString &level) const
{
    if (level == QLatin1String("critical"))
        return QStringLiteral("严重预警");
    if (level == QLatin1String("warning"))
        return QStringLiteral("预警");
    if (level == QLatin1String("normal"))
        return QStringLiteral("正常");
    return level.isEmpty() ? QStringLiteral("—") : level;
}

void ForecastDialog::buildUi()
{
    auto *page = new QWidget(this);
    page->setObjectName(QStringLiteral("centralRoot"));
    auto *shell = new QVBoxLayout(this);
    shell->setContentsMargins(0, 0, 0, 0);
    shell->addWidget(page);

    auto *root = new QVBoxLayout(page);
    root->setContentsMargins(18, 16, 18, 14);
    root->setSpacing(10);

    m_title = new QLabel(QStringLiteral("充电负荷预测"));
    m_title->setObjectName(QStringLiteral("pageTitle"));
    root->addWidget(m_title);

    m_subtitle = new QLabel;
    m_subtitle->setObjectName(QStringLiteral("muted"));
    m_subtitle->setWordWrap(true);
    root->addWidget(m_subtitle);

    m_note = new QLabel;
    m_note->setObjectName(QStringLiteral("muted"));
    m_note->setWordWrap(true);
    root->addWidget(m_note);

    m_meta = new QLabel;
    m_meta->setObjectName(QStringLiteral("muted"));
    m_meta->setWordWrap(true);
    root->addWidget(m_meta);

    auto *kpiRow = new QHBoxLayout;
    kpiRow->setSpacing(10);
    kpiRow->addWidget(makeKpiCard(&m_kpiLoad, QStringLiteral("1小时平均负荷")));
    kpiRow->addWidget(makeKpiCard(&m_kpiOcc, QStringLiteral("1小时占用率")));
    kpiRow->addWidget(makeKpiCard(&m_kpiCongestion, QStringLiteral("拥堵等级")));
    kpiRow->addWidget(makeKpiCard(&m_kpiWarning, QStringLiteral("负荷预警")));
    root->addLayout(kpiRow);

    auto *chartRow = new QHBoxLayout;
    chartRow->setSpacing(10);
    m_loadChart = new QChartView;
    m_loadChart->setRenderHint(QPainter::Antialiasing);
    m_loadChart->setMinimumHeight(240);
    m_occChart = new QChartView;
    m_occChart->setRenderHint(QPainter::Antialiasing);
    m_occChart->setMinimumHeight(240);
    chartRow->addWidget(m_loadChart, 1);
    chartRow->addWidget(m_occChart, 1);
    root->addLayout(chartRow, 1);

    m_table = new QTableWidget(3, 6);
    m_table->setHorizontalHeaderLabels({
        QStringLiteral("目标时段"), QStringLiteral("开始"), QStringLiteral("结束"),
        QStringLiteral("负荷(kW)"), QStringLiteral("占用率"), QStringLiteral("等效占用/空闲桩")
    });
    m_table->horizontalHeader()->setStretchLastSection(true);
    m_table->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);
    m_table->verticalHeader()->setVisible(false);
    m_table->setEditTriggers(QAbstractItemView::NoEditTriggers);
    m_table->setSelectionMode(QAbstractItemView::NoSelection);
    m_table->setFocusPolicy(Qt::NoFocus);
    m_table->setMaximumHeight(140);
    root->addWidget(m_table);

    auto *hint = new QLabel(QStringLiteral("说明：H1/H6/H24 是三个目标小时的点预测，不是未来连续 24 小时曲线。占用率为充电时长口径。"));
    hint->setObjectName(QStringLiteral("muted"));
    hint->setWordWrap(true);
    root->addWidget(hint);

    auto *closeBtn = new QPushButton(QStringLiteral("关闭"));
    closeBtn->setObjectName(QStringLiteral("secondaryBtn"));
    closeBtn->setFixedWidth(96);
    connect(closeBtn, &QPushButton::clicked, this, &QDialog::accept);
    auto *btnRow = new QHBoxLayout;
    btnRow->addStretch();
    btnRow->addWidget(closeBtn);
    root->addLayout(btnRow);
}

void ForecastDialog::applyCharts()
{
    const QJsonArray stations = m_payload.value(QStringLiteral("stations")).toArray();
    const QJsonObject station = stations.isEmpty() ? QJsonObject() : stations.at(0).toObject();
    const QJsonObject forecast = station.value(QStringLiteral("forecast")).toObject();
    const QJsonObject h1 = horizon(forecast, "1h");
    const QJsonObject h6 = horizon(forecast, "6h");
    const QJsonObject h24 = horizon(forecast, "24h");
    const QJsonObject business = station.value(QStringLiteral("business_status")).toObject();
    const bool matched = m_payload.value(QStringLiteral("matched")).toBool(true);

    m_subtitle->setText(QStringLiteral("%1  ·  电站ID %2")
                            .arg(m_stationName.isEmpty() ? QStringLiteral("未命名电站") : m_stationName)
                            .arg(m_stationId));

    if (matched) {
        m_note->setText(QStringLiteral("已匹配该站在最新预测批次中的结果。"));
    } else {
        m_note->setText(
            QStringLiteral("当前预测批次未包含本站 ID（模型侧站点 %1）。下面展示该批次的模型输出，便于联调；发布含本站小时快照后即可显示专属预测。")
                .arg(m_payload.value(QStringLiteral("sample_station_id")).toInt()));
    }

    const QString source = m_payload.value(QStringLiteral("simulation")).toBool()
                               ? QStringLiteral("模拟数据")
                               : QStringLiteral("实测数据");
    const QString stale = m_payload.value(QStringLiteral("stale")).toBool()
                              ? QStringLiteral("已过期")
                              : QStringLiteral("有效");
    const QJsonObject models = m_payload.value(QStringLiteral("models")).toObject();
    m_meta->setText(
        QStringLiteral("数据截止 %1  ·  生成 %2  ·  %3  ·  %4  ·  模型 %5 / %6")
            .arg(m_payload.value(QStringLiteral("data_cutoff_time")).toString(QStringLiteral("—")),
                 m_payload.value(QStringLiteral("generated_at")).toString(QStringLiteral("—")),
                 source, stale,
                 models.value(QStringLiteral("load")).toObject().value(QStringLiteral("1h")).toString(QStringLiteral("—")),
                 models.value(QStringLiteral("occupancy")).toObject().value(QStringLiteral("1h")).toString(QStringLiteral("—"))));

    const double loadKw = h1.value(QStringLiteral("load_kw")).toDouble();
    const double occ = h1.value(QStringLiteral("occupancy_ratio")).toDouble();
    m_kpiLoad->setText(QStringLiteral("%1 kW").arg(loadKw, 0, 'f', 2));
    m_kpiOcc->setText(QStringLiteral("%1%").arg(occ * 100.0, 0, 'f', 1));
    m_kpiCongestion->setText(congestionText(business.value(QStringLiteral("congestion_level")).toString()));
    m_kpiWarning->setText(warningText(business.value(QStringLiteral("warning_level")).toString()));

    const QStringList categories = {
        QStringLiteral("1小时"), QStringLiteral("6小时"), QStringLiteral("24小时")
    };
    const QList<QJsonObject> points = {h1, h6, h24};
    const QColor axisColor = m_darkMode ? QColor(QStringLiteral("#C5D0CD"))
                                        : QColor(QStringLiteral("#15201E"));
    const QColor bg = m_darkMode ? QColor(QStringLiteral("#1A2422")) : QColor(Qt::white);

    auto *loadSet = new QBarSet(QStringLiteral("平均负荷 kW"));
    loadSet->setColor(QColor(QStringLiteral("#0D7565")));
    auto *occSet = new QBarSet(QStringLiteral("占用率 %"));
    occSet->setColor(QColor(QStringLiteral("#2563A8")));
    double maxLoad = 1.0;
    for (const QJsonObject &row : points) {
        const double kw = row.value(QStringLiteral("load_kw")).toDouble();
        *loadSet << kw;
        *occSet << row.value(QStringLiteral("occupancy_ratio")).toDouble() * 100.0;
        maxLoad = qMax(maxLoad, kw);
    }

    auto makeBarChart = [&](QBarSet *set, const QString &title, double maxY, const QString &yTitle) {
        auto *series = new QBarSeries();
        series->append(set);
        auto *chart = new QChart();
        chart->addSeries(series);
        chart->setTitle(title);
        chart->setTitleBrush(QBrush(axisColor));
        chart->setBackgroundBrush(QBrush(bg));
        chart->setAnimationOptions(QChart::SeriesAnimations);
        chart->legend()->setVisible(false);
        chart->setMargins(QMargins(8, 12, 8, 8));
        auto *axisX = new QBarCategoryAxis();
        axisX->append(categories);
        axisX->setLabelsColor(axisColor);
        auto *axisY = new QValueAxis();
        axisY->setRange(0, maxY * 1.2);
        axisY->setLabelFormat(QStringLiteral("%.1f"));
        axisY->setTitleText(yTitle);
        axisY->setLabelsColor(axisColor);
        axisY->setTitleBrush(QBrush(axisColor));
        chart->addAxis(axisX, Qt::AlignBottom);
        chart->addAxis(axisY, Qt::AlignLeft);
        series->attachAxis(axisX);
        series->attachAxis(axisY);
        return chart;
    };

    m_loadChart->setChart(makeBarChart(loadSet, QStringLiteral("目标小时平均负荷"), maxLoad,
                                       QStringLiteral("kW")));
    m_occChart->setChart(makeBarChart(occSet, QStringLiteral("目标小时占用率"), 100.0,
                                      QStringLiteral("%")));

    const QStringList labels = {
        QStringLiteral("1小时目标"), QStringLiteral("6小时目标"), QStringLiteral("24小时目标")
    };
    for (int i = 0; i < 3; ++i) {
        const QJsonObject &row = points.at(i);
        auto text = [](const QString &s) {
            auto *item = new QTableWidgetItem(s);
            item->setTextAlignment(Qt::AlignCenter);
            return item;
        };
        m_table->setItem(i, 0, text(labels.at(i)));
        m_table->setItem(i, 1, text(row.value(QStringLiteral("target_start")).toString(QStringLiteral("—"))));
        m_table->setItem(i, 2, text(row.value(QStringLiteral("target_end")).toString(QStringLiteral("—"))));
        m_table->setItem(i, 3, text(QString::number(row.value(QStringLiteral("load_kw")).toDouble(), 'f', 2)));
        m_table->setItem(i, 4, text(QStringLiteral("%1%")
                                        .arg(row.value(QStringLiteral("occupancy_ratio")).toDouble() * 100.0, 0, 'f', 1)));
        m_table->setItem(i, 5, text(QStringLiteral("%1 / %2")
                                        .arg(row.value(QStringLiteral("equivalent_occupied_piles")).toInt())
                                        .arg(row.value(QStringLiteral("equivalent_idle_piles")).toInt())));
    }
}
