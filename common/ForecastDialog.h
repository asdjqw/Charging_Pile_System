#pragma once

#include <QDialog>
#include <QJsonObject>

class QLabel;
class QChartView;
class QTableWidget;

class ForecastDialog : public QDialog
{
    Q_OBJECT
public:
    ForecastDialog(int stationId, const QString &stationName, const QJsonObject &payload,
                   bool darkMode, QWidget *parent = nullptr);

private:
    void buildUi();
    void applyCharts();
    QJsonObject horizon(const QJsonObject &forecast, const char *key) const;
    QString congestionText(const QString &level) const;
    QString warningText(const QString &level) const;

    int m_stationId = 0;
    QString m_stationName;
    QJsonObject m_payload;
    bool m_darkMode = false;
    QLabel *m_title = nullptr;
    QLabel *m_subtitle = nullptr;
    QLabel *m_note = nullptr;
    QLabel *m_meta = nullptr;
    QLabel *m_kpiLoad = nullptr;
    QLabel *m_kpiOcc = nullptr;
    QLabel *m_kpiCongestion = nullptr;
    QLabel *m_kpiWarning = nullptr;
    QChartView *m_loadChart = nullptr;
    QChartView *m_occChart = nullptr;
    QTableWidget *m_table = nullptr;
};
