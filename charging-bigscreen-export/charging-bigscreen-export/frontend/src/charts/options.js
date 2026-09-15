/**
 * 大屏各面板 ECharts 配置构造器：数据来自后端 /api/screen/bundle
 * 图表类型覆盖：柱状、折线、面积、双轴混合、雷达、热力、玫瑰饼、漏斗、堆叠、散点等
 */
import {
  areaGradient,
  barGradient,
  baseGrid,
  categoryAxis,
  hexToRgba,
  palette,
  splitLineColor,
  subTextColor,
  textColor,
  tooltipStyle,
  valueAxis
} from '../utils/echartsTheme'

const PERIOD_COLOR = { 谷: '#22e6a4', 平: '#3b82f6', 峰: '#ff7a59' }
const num = (v) => (Number.isFinite(Number(v)) ? Number(v) : 0)
const monthLabel = (v) => String(v || '').replace(/^\d{2}/, '')
const hourLabel = (h) => `${h}时`
const shortStation = (name) => {
  const text = String(name || '')
  const idx = text.indexOf('·')
  return idx >= 0 ? text.slice(idx + 1).slice(0, 10) : text.slice(0, 10)
}

/* ----------------------------- 1. 月度充电量趋势 ----------------------------- */
export function monthlyTrendOption(monthly = []) {
  const rows = monthly.slice(-12)
  return {
    grid: { left: 44, right: 42, top: 30, bottom: 30 },
    legend: {
      right: 4,
      top: 0,
      itemWidth: 9,
      itemHeight: 7,
      textStyle: { color: subTextColor, fontSize: 10 },
      data: ['充电量(kWh)', '订单数(单)']
    },
    tooltip: tooltipStyle(),
    xAxis: categoryAxis(rows.map((r) => monthLabel(r.stat_month_str)), {
      axisLabel: { color: textColor, fontSize: 9, interval: 0, rotate: 38 }
    }),
    yAxis: [
      valueAxis({ axisLabel: { color: textColor, fontSize: 10 } }),
      valueAxis({ splitLine: { show: false }, axisLabel: { color: textColor, fontSize: 10 } })
    ],
    series: [
      {
        name: '充电量(kWh)',
        type: 'bar',
        barWidth: '46%',
        data: rows.map((r) => num(r.kwh)),
        itemStyle: { borderRadius: [4, 4, 0, 0], color: barGradient('#00e4ff') }
      },
      {
        name: '订单数(单)',
        type: 'line',
        yAxisIndex: 1,
        smooth: true,
        symbol: 'circle',
        symbolSize: 6,
        data: rows.map((r) => num(r.sessions)),
        lineStyle: { width: 2, color: '#ffd166' },
        itemStyle: { color: '#ffd166' },
        areaStyle: { color: areaGradient('#ffd166', 0.25, 0.02) }
      }
    ]
  }
}

/* ----------------------------- 2. 24 小时负荷分布 ----------------------------- */
export function hourLoadOption(hourLoad = []) {
  const rows = [...hourLoad].sort((a, b) => num(a.start_hour) - num(b.start_hour))
  return {
    grid: { left: 40, right: 40, top: 28, bottom: 26 },
    legend: {
      right: 4,
      top: 0,
      itemWidth: 9,
      itemHeight: 7,
      textStyle: { color: subTextColor, fontSize: 10 },
      data: ['充电订单', '平均功率(kW)']
    },
    tooltip: tooltipStyle(),
    xAxis: categoryAxis(rows.map((r) => hourLabel(r.start_hour)), {
      axisLabel: { color: textColor, fontSize: 9, interval: 2, formatter: (v) => String(v).replace('时', '') }
    }),
    yAxis: [
      valueAxis({ axisLabel: { color: textColor, fontSize: 10 } }),
      valueAxis({ splitLine: { show: false }, axisLabel: { color: textColor, fontSize: 10 } })
    ],
    series: [
      {
        name: '充电订单',
        type: 'bar',
        barWidth: '52%',
        data: rows.map((r) => ({
          value: num(r.sessions),
          itemStyle: {
            borderRadius: [3, 3, 0, 0],
            color: barGradient(PERIOD_COLOR[r.time_period] || '#00e4ff')
          }
        })),
        markPoint: {
          symbolSize: 40,
          label: { fontSize: 10, color: '#04121f' },
          itemStyle: { color: 'rgba(255, 209, 102, 0.9)' },
          data: [{ type: 'max', name: '峰值' }]
        }
      },
      {
        name: '平均功率(kW)',
        type: 'line',
        yAxisIndex: 1,
        smooth: true,
        symbol: 'none',
        data: rows.map((r) => num(r.avg_power)),
        lineStyle: { width: 2, color: '#22e6a4' },
        areaStyle: { color: areaGradient('#22e6a4', 0.22, 0.01) }
      }
    ]
  }
}

/* ----------------------------- 3. 站点类型对比（雷达） ----------------------------- */
export function facilityRadarOption(facility = []) {
  const rows = facility.filter((r) => r.facility_type_cn && r.facility_type_cn !== '未知')
  const indicators = [
    { key: 'sessions', name: '订单量' },
    { key: 'kwh', name: '充电量' },
    { key: 'avg_power', name: '平均功率' },
    { key: 'avg_kwh', name: '单次电量' },
    { key: 'orders_per_device', name: '桩均订单' },
    { key: 'avg_hours', name: '平均时长' }
  ]
  const maxOf = (key) => Math.max(...rows.map((r) => num(r[key])), 1)
  const maxMap = Object.fromEntries(indicators.map((i) => [i.key, maxOf(i.key)]))
  return {
    tooltip: { trigger: 'item', backgroundColor: 'rgba(6, 30, 58, 0.92)', borderColor: 'rgba(0,228,255,0.45)', textStyle: { color: '#dff3ff', fontSize: 12 } },
    legend: {
      bottom: 0,
      itemWidth: 10,
      itemHeight: 8,
      textStyle: { color: subTextColor, fontSize: 11 }
    },
    radar: {
      center: ['50%', '46%'],
      radius: '62%',
      splitNumber: 4,
      indicator: indicators.map((i) => ({ name: i.name, max: 100 })),
      axisName: { color: textColor, fontSize: 11 },
      axisLine: { lineStyle: { color: 'rgba(120, 200, 255, 0.25)' } },
      splitLine: { lineStyle: { color: 'rgba(120, 200, 255, 0.18)' } },
      splitArea: { areaStyle: { color: ['rgba(0, 120, 200, 0.04)', 'rgba(0, 120, 200, 0.10)'] } }
    },
    series: [
      {
        type: 'radar',
        symbolSize: 4,
        areaStyle: { opacity: 0.18 },
        data: rows.map((row, idx) => ({
          name: row.facility_type_cn,
          value: indicators.map((i) => Number(((num(row[i.key]) / maxMap[i.key]) * 100).toFixed(1))),
          lineStyle: { width: 2, color: palette[idx % palette.length] },
          itemStyle: { color: palette[idx % palette.length] },
          areaStyle: { color: hexToRgba(palette[idx % palette.length], 0.22) }
        }))
      }
    ]
  }
}

/* ----------------------------- 4. 充电时长分布（玫瑰图） ----------------------------- */
export function durationRoseOption(duration = []) {
  return {
    tooltip: {
      trigger: 'item',
      backgroundColor: 'rgba(6, 30, 58, 0.92)',
      borderColor: 'rgba(0,228,255,0.45)',
      textStyle: { color: '#dff3ff', fontSize: 12 },
      formatter: '{b}小时<br/>订单 {c} 单（{d}%）'
    },
    legend: {
      orient: 'vertical',
      right: 2,
      top: 'middle',
      itemWidth: 8,
      itemHeight: 7,
      itemGap: 6,
      textStyle: { color: subTextColor, fontSize: 10 }
    },
    series: [
      {
        type: 'pie',
        center: ['35%', '54%'],
        radius: ['24%', '66%'],
        roseType: 'radius',
        itemStyle: { borderColor: 'rgba(4, 18, 36, 0.9)', borderWidth: 2 },
        label: { color: textColor, fontSize: 10, formatter: '{d}%' },
        labelLine: { length: 4, length2: 4, lineStyle: { color: 'rgba(120, 200, 255, 0.5)' } },
        data: duration.map((r, i) => ({
          name: `${r.bin_label}`,
          value: num(r.sessions),
          itemStyle: { color: palette[i % palette.length] }
        }))
      }
    ]
  }
}

/* ----------------------------- 5. 日充电量 / 订单趋势（主图） ----------------------------- */
export function dailyTrendOption(daily = [], days = 90) {
  const rows = daily.slice(-days)
  return {
    grid: { left: 56, right: 54, top: 46, bottom: 34 },
    legend: {
      right: 10,
      top: 6,
      itemWidth: 12,
      itemHeight: 8,
      textStyle: { color: subTextColor, fontSize: 12 },
      data: ['日充电量(kWh)', '日订单数(单)', '活跃用户(人)']
    },
    tooltip: tooltipStyle({ axisPointer: { type: 'line', lineStyle: { color: 'rgba(0,228,255,0.45)' } } }),
    xAxis: categoryAxis(rows.map((r) => String(r.stat_date).slice(5)), {
      boundaryGap: true,
      axisLabel: { color: textColor, fontSize: 11, interval: Math.max(0, Math.floor(rows.length / 12)) }
    }),
    yAxis: [
      valueAxis({ name: 'kWh / 单', nameTextStyle: { color: subTextColor, fontSize: 11 } }),
      valueAxis({ splitLine: { show: false }, name: '人', nameTextStyle: { color: subTextColor, fontSize: 11 } })
    ],
    series: [
      {
        name: '日充电量(kWh)',
        type: 'line',
        smooth: true,
        symbol: 'none',
        data: rows.map((r) => num(r.kwh)),
        lineStyle: { width: 2.5, color: '#00e4ff' },
        areaStyle: { color: areaGradient('#00e4ff', 0.5, 0.02) },
        markPoint: {
          symbolSize: 46,
          label: { fontSize: 10, color: '#04121f' },
          itemStyle: { color: 'rgba(255, 209, 102, 0.92)' },
          data: [{ type: 'max', name: '峰值' }]
        }
      },
      {
        name: '日订单数(单)',
        type: 'bar',
        barWidth: '38%',
        data: rows.map((r) => num(r.sessions)),
        itemStyle: { borderRadius: [3, 3, 0, 0], color: barGradient('#3b82f6') }
      },
      {
        name: '活跃用户(人)',
        type: 'line',
        yAxisIndex: 1,
        smooth: true,
        symbol: 'none',
        data: rows.map((r) => num(r.users)),
        lineStyle: { width: 2, color: '#ffd166', type: 'dashed' }
      }
    ]
  }
}

/* ----------------------------- 6. 星期 × 小时充电热度 ----------------------------- */
export function weekdayHeatOption(heat = []) {
  const daysCn = ['周一', '周二', '周三', '周四', '周五', '周六', '周日']
  const dayIndex = { 2: 0, 3: 1, 4: 2, 5: 3, 6: 4, 7: 5, 1: 6 }
  const data = heat
    .filter((r) => dayIndex[num(r.weekday_num)] !== undefined)
    .map((r) => [num(r.start_hour), dayIndex[num(r.weekday_num)], num(r.sessions)])
  const max = Math.max(...data.map((d) => d[2]), 1)
  return {
    grid: { left: 46, right: 18, top: 16, bottom: 46 },
    tooltip: {
      backgroundColor: 'rgba(6, 30, 58, 0.92)',
      borderColor: 'rgba(0,228,255,0.45)',
      textStyle: { color: '#dff3ff', fontSize: 12 },
      formatter: (p) => `${daysCn[p.value[1]]} ${p.value[0]}:00<br/>订单 ${p.value[2]} 单`
    },
    xAxis: categoryAxis(Array.from({ length: 24 }, (_, i) => `${i}`), {
      splitArea: { show: false },
      axisLabel: { color: textColor, fontSize: 10 }
    }),
    yAxis: categoryAxis(daysCn, { splitArea: { show: false } }),
    visualMap: {
      min: 0,
      max,
      calculable: false,
      orient: 'horizontal',
      left: 'center',
      bottom: 2,
      itemWidth: 10,
      itemHeight: 70,
      textStyle: { color: subTextColor, fontSize: 10 },
      inRange: { color: ['#0b2f5c', '#1b6fc4', '#00e4ff', '#ffd166'] }
    },
    series: [
      {
        type: 'heatmap',
        data,
        label: { show: false },
        emphasis: { itemStyle: { borderColor: '#ffffff', borderWidth: 1 } },
        itemStyle: { borderColor: 'rgba(4, 18, 36, 0.6)', borderWidth: 1 }
      }
    ]
  }
}

/* ----------------------------- 7. 站点充电量 TOP10 ----------------------------- */
export function stationTopOption(list = []) {
  const rows = [...list].sort((a, b) => num(a.kwh) - num(b.kwh))
  return {
    grid: { left: 96, right: 56, top: 14, bottom: 12 },
    tooltip: tooltipStyle({
      formatter: (params) => {
        const row = rows[params[0].dataIndex]
        return `${row.station_name}<br/>充电量 ${num(row.kwh)} kWh<br/>订单 ${num(row.sessions)} 单<br/>收入 ${num(row.revenue)} 元<br/>桩均订单 ${num(row.orders_per_device)} 单/台`
      }
    }),
    xAxis: valueAxis({ splitLine: { show: true } }),
    yAxis: categoryAxis(rows.map((r) => shortStation(r.station_name)), {
      axisLabel: { color: textColor, fontSize: 11 }
    }),
    series: [
      {
        type: 'bar',
        barWidth: '58%',
        data: rows.map((r) => num(r.kwh)),
        itemStyle: { borderRadius: [0, 4, 4, 0], color: barGradient('#00e4ff', false) },
        label: { show: true, position: 'right', color: '#bfe9ff', fontSize: 11, formatter: '{c}' }
      }
    ]
  }
}

/* ----------------------------- 8. 工作日 vs 周末对比 ----------------------------- */
export function weekendOption(weekend = []) {
  const order = { 工作日: 0, 周末: 1 }
  const rows = [...weekend].sort((a, b) => (order[a.day_type] ?? 9) - (order[b.day_type] ?? 9))
  return {
    grid: { ...baseGrid, top: 42, bottom: 24 },
    legend: {
      right: 6,
      top: 2,
      itemWidth: 10,
      itemHeight: 8,
      textStyle: { color: subTextColor, fontSize: 11 },
      data: ['日均订单(单)', '日均电量(kWh)', '平均单次电量(kWh)']
    },
    tooltip: tooltipStyle(),
    xAxis: categoryAxis(rows.map((r) => r.day_type), { axisLabel: { color: textColor, fontSize: 12 } }),
    yAxis: [
      valueAxis({ name: '日均', nameTextStyle: { color: subTextColor, fontSize: 10 } }),
      valueAxis({ splitLine: { show: false }, name: 'kWh', nameTextStyle: { color: subTextColor, fontSize: 10 } })
    ],
    series: [
      {
        name: '日均订单(单)',
        type: 'bar',
        barWidth: '26%',
        data: rows.map((r) => num(r.sessions_per_day)),
        itemStyle: { borderRadius: [4, 4, 0, 0], color: barGradient('#00e4ff') }
      },
      {
        name: '日均电量(kWh)',
        type: 'bar',
        yAxisIndex: 1,
        barWidth: '26%',
        data: rows.map((r) => num(r.kwh_per_day)),
        itemStyle: { borderRadius: [4, 4, 0, 0], color: barGradient('#7c5cff') }
      },
      {
        name: '平均单次电量(kWh)',
        type: 'line',
        yAxisIndex: 1,
        smooth: true,
        symbolSize: 7,
        data: rows.map((r) => num(r.avg_kwh)),
        lineStyle: { color: '#ffd166', width: 2 },
        itemStyle: { color: '#ffd166' }
      }
    ]
  }
}

/* ----------------------------- 9. 用户平台 / 用户类型对比 ----------------------------- */
export function platformOption(platform = []) {
  const rows = [...platform].sort((a, b) => num(b.sessions) - num(a.sessions))
  return {
    grid: { ...baseGrid, top: 42, bottom: 24 },
    legend: {
      right: 6,
      top: 2,
      itemWidth: 10,
      itemHeight: 8,
      textStyle: { color: subTextColor, fontSize: 11 },
      data: ['订单数(单)', '平均单次电量(kWh)']
    },
    tooltip: tooltipStyle(),
    xAxis: categoryAxis(rows.map((r) => String(r.platform).toUpperCase()), {
      axisLabel: { color: textColor, fontSize: 12 }
    }),
    yAxis: [
      valueAxis({ name: '单', nameTextStyle: { color: subTextColor, fontSize: 10 } }),
      valueAxis({ splitLine: { show: false }, name: 'kWh', nameTextStyle: { color: subTextColor, fontSize: 10 } })
    ],
    series: [
      {
        name: '订单数(单)',
        type: 'bar',
        barWidth: '34%',
        data: rows.map((r) => num(r.sessions)),
        itemStyle: { borderRadius: [4, 4, 0, 0], color: barGradient('#22e6a4') },
        label: { show: true, position: 'top', color: '#9ff5d4', fontSize: 11, formatter: (p) => `${p.value}` }
      },
      {
        name: '平均单次电量(kWh)',
        type: 'line',
        yAxisIndex: 1,
        smooth: true,
        symbolSize: 7,
        data: rows.map((r) => num(r.avg_kwh)),
        lineStyle: { color: '#ff9f68', width: 2 },
        itemStyle: { color: '#ff9f68' }
      }
    ]
  }
}

/* ----------------------------- 10. 用户价值分层（环形） ----------------------------- */
export function userSegmentOption(segment = []) {
  const rows = [...segment].sort((a, b) => num(b.user_cnt) - num(a.user_cnt))
  const total = rows.reduce((sum, r) => sum + num(r.user_cnt), 0)
  const colors = ['#00e4ff', '#22e6a4', '#ffd166', '#ff7a59', '#7c5cff']
  return {
    tooltip: {
      trigger: 'item',
      backgroundColor: 'rgba(6, 30, 58, 0.92)',
      borderColor: 'rgba(0,228,255,0.45)',
      textStyle: { color: '#dff3ff', fontSize: 12 },
      formatter: (p) => {
        const row = rows[p.dataIndex] || {}
        return `${p.name}<br/>用户 ${num(row.user_cnt)} 人（${p.percent}%）<br/>电量 ${num(row.kwh)} kWh<br/>订单 ${num(row.sessions)} 单`
      }
    },
    legend: {
      orient: 'vertical',
      right: 6,
      top: 'center',
      itemWidth: 10,
      itemHeight: 8,
      textStyle: { color: subTextColor, fontSize: 11 }
    },
    title: {
      text: `${total}`,
      subtext: '累计用户(人)',
      left: '30%',
      top: '42%',
      textAlign: 'center',
      textStyle: { color: '#00e4ff', fontSize: 22, fontWeight: 'bold' },
      subtextStyle: { color: subTextColor, fontSize: 11 }
    },
    series: [
      {
        type: 'pie',
        center: ['32%', '50%'],
        radius: ['48%', '70%'],
        itemStyle: { borderColor: 'rgba(4, 18, 36, 0.9)', borderWidth: 2 },
        label: { show: false },
        labelLine: { show: false },
        data: rows.map((r, i) => ({
          name: r.segment,
          value: num(r.user_cnt),
          itemStyle: { color: colors[i % colors.length] }
        }))
      }
    ]
  }
}

/* ----------------------------- 11. 电池健康（SOC 维度） ----------------------------- */
export function batteryHealthOption(health = []) {
  const rows = [...health].sort(
    (a, b) => parseInt(String(a.soc_bin).split('-')[0], 10) - parseInt(String(b.soc_bin).split('-')[0], 10)
  )
  return {
    grid: { ...baseGrid, top: 42, bottom: 24 },
    legend: {
      right: 6,
      top: 2,
      itemWidth: 10,
      itemHeight: 8,
      textStyle: { color: subTextColor, fontSize: 11 },
      data: ['充电功率(kW)', '单体压差(mV)', '温升(℃)']
    },
    tooltip: tooltipStyle(),
    xAxis: categoryAxis(rows.map((r) => `${r.soc_bin}%`), { axisLabel: { color: textColor, fontSize: 11 } }),
    yAxis: [
      valueAxis({ name: 'kW / mV', nameTextStyle: { color: subTextColor, fontSize: 10 } }),
      valueAxis({ splitLine: { show: false }, name: '℃', nameTextStyle: { color: subTextColor, fontSize: 10 } })
    ],
    series: [
      {
        name: '充电功率(kW)',
        type: 'bar',
        barWidth: '34%',
        data: rows.map((r) => num(r.avg_power)),
        itemStyle: { borderRadius: [3, 3, 0, 0], color: barGradient('#00e4ff') }
      },
      {
        name: '单体压差(mV)',
        type: 'line',
        smooth: true,
        symbolSize: 6,
        data: rows.map((r) => num(r.avg_cell_diff_mv)),
        lineStyle: { color: '#ffd166', width: 2 },
        itemStyle: { color: '#ffd166' }
      },
      {
        name: '温升(℃)',
        type: 'line',
        yAxisIndex: 1,
        smooth: true,
        symbolSize: 6,
        data: rows.map((r) => num(r.avg_temp_rise)),
        lineStyle: { color: '#ff7a59', width: 2, type: 'dashed' },
        itemStyle: { color: '#ff7a59' }
      }
    ]
  }
}

/* ----------------------------- 12. 峰平谷时段对比（漏斗） ----------------------------- */
export function timePeriodFunnelOption(period = []) {
  const order = { 峰: 0, 平: 1, 谷: 2 }
  const rows = [...period].sort((a, b) => (order[a.time_period] ?? 9) - (order[b.time_period] ?? 9))
  const colors = { 峰: '#ff7a59', 平: '#3b82f6', 谷: '#22e6a4' }
  return {
    tooltip: {
      trigger: 'item',
      backgroundColor: 'rgba(6, 30, 58, 0.92)',
      borderColor: 'rgba(0,228,255,0.45)',
      textStyle: { color: '#dff3ff', fontSize: 12 },
      formatter: (p) => {
        const row = rows[p.dataIndex] || {}
        return `${p.name}时段<br/>充电量 ${num(row.kwh)} kWh<br/>订单 ${num(row.sessions)} 单（${num(row.sessions_pct)}%）<br/>收入 ${num(row.revenue)} 元`
      }
    },
    series: [
      {
        type: 'funnel',
        left: '6%',
        right: '6%',
        top: 10,
        bottom: 6,
        minSize: '32%',
        sort: 'descending',
        gap: 4,
        label: { color: '#e8f6ff', fontSize: 11, formatter: (p) => `${p.name} ${(p.value ?? 0).toFixed(0)}kWh` },
        labelLine: { length: 8, lineStyle: { color: 'rgba(120, 200, 255, 0.4)' } },
        itemStyle: { borderWidth: 0, opacity: 0.92 },
        data: rows.map((r) => ({
          name: `${r.time_period}时段`,
          value: num(r.kwh),
          itemStyle: { color: hexToRgba(colors[r.time_period] || '#00e4ff', 0.85) }
        }))
      }
    ]
  }
}

/* ----------------------------- 13. 单次充电量分布 ----------------------------- */
export function energyDistOption(energy = []) {
  const rows = [...energy].sort((a, b) => num(a.bin_order) - num(b.bin_order))
  return {
    grid: { ...baseGrid, top: 40, bottom: 24 },
    legend: {
      right: 6,
      top: 2,
      itemWidth: 10,
      itemHeight: 8,
      textStyle: { color: subTextColor, fontSize: 11 },
      data: ['订单数(单)', '占比(%)']
    },
    tooltip: tooltipStyle(),
    xAxis: categoryAxis(rows.map((r) => `${r.bin_label}`), { axisLabel: { color: textColor, fontSize: 10, interval: 0 } }),
    yAxis: [
      valueAxis({ name: '单', nameTextStyle: { color: subTextColor, fontSize: 10 } }),
      valueAxis({ splitLine: { show: false }, name: '%', max: 100, nameTextStyle: { color: subTextColor, fontSize: 10 } })
    ],
    series: [
      {
        name: '订单数(单)',
        type: 'bar',
        barWidth: '46%',
        data: rows.map((r) => num(r.sessions)),
        itemStyle: { borderRadius: [3, 3, 0, 0], color: barGradient('#7c5cff') }
      },
      {
        name: '占比(%)',
        type: 'line',
        yAxisIndex: 1,
        smooth: true,
        symbolSize: 6,
        data: rows.map((r) => num(r.pct)),
        lineStyle: { color: '#00e4ff', width: 2 },
        itemStyle: { color: '#00e4ff' }
      }
    ]
  }
}

/* ----------------------------- 14. 收入结构与付费率（堆叠 + 折线） ----------------------------- */
export function revenueStructOption(revenue = [], dimType = '站点类型') {
  const rows = revenue.filter((r) => r.dim_type === dimType).sort((a, b) => num(b.revenue) - num(a.revenue))
  return {
    grid: { ...baseGrid, top: 40, bottom: 34 },
    legend: {
      right: 6,
      top: 2,
      itemWidth: 10,
      itemHeight: 8,
      textStyle: { color: subTextColor, fontSize: 11 },
      data: ['收入(元)', '付费率(%)']
    },
    tooltip: tooltipStyle(),
    xAxis: categoryAxis(rows.map((r) => r.dim_name), {
      axisLabel: { color: textColor, fontSize: 9, interval: 0, rotate: rows.length > 3 ? 26 : 0 }
    }),
    yAxis: [
      valueAxis({ name: '元', nameTextStyle: { color: subTextColor, fontSize: 10 } }),
      valueAxis({ splitLine: { show: false }, name: '%', max: 100, nameTextStyle: { color: subTextColor, fontSize: 10 } })
    ],
    series: [
      {
        name: '收入(元)',
        type: 'bar',
        barWidth: '38%',
        stack: 'revenue',
        data: rows.map((r) => num(r.revenue)),
        itemStyle: { borderRadius: [3, 3, 0, 0], color: barGradient('#ffd166') }
      },
      {
        name: '付费率(%)',
        type: 'line',
        yAxisIndex: 1,
        smooth: true,
        symbolSize: 6,
        data: rows.map((r) => num(r.paid_rate)),
        lineStyle: { color: '#22e6a4', width: 2 },
        itemStyle: { color: '#22e6a4' }
      }
    ]
  }
}

/* ----------------------------- 15. 行政区分布（DataV 锥形柱图配置） ----------------------------- */
export function districtConicalConfig(district = []) {
  const rows = [...district].sort((a, b) => num(b.kwh) - num(a.kwh)).slice(0, 6)
  return {
    data: rows.map((r) => ({
      name: String(r.district || '').replace('新区', '').replace('区', ''),
      value: num(r.kwh)
    })),
    showValue: true,
    fontSize: 11,
    color: ['#00e4ff', '#3b82f6', '#7c5cff', '#22e6a4'],
    unit: 'kWh'
  }
}

/* ----------------------------- 16. 充电功率分布（时序散点，用于电池面板辅图） ----------------------------- */
export function powerDistOption(power = []) {
  const rows = [...power].sort((a, b) => num(a.bin_order) - num(b.bin_order))
  return {
    grid: { ...baseGrid, top: 30, bottom: 20 },
    tooltip: tooltipStyle(),
    xAxis: categoryAxis(rows.map((r) => `${r.bin_label}`), { axisLabel: { color: textColor, fontSize: 10 } }),
    yAxis: valueAxis(),
    series: [
      {
        type: 'bar',
        barWidth: '44%',
        data: rows.map((r) => num(r.samples)),
        itemStyle: { borderRadius: [3, 3, 0, 0], color: barGradient('#22e6a4') },
        markLine: { silent: true, symbol: 'none', data: [], lineStyle: { color: splitLineColor } }
      }
    ]
  }
}
