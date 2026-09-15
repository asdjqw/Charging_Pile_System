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
  itemTooltipStyle,
  theme,
  tooltipStyle,
  valueAxis
} from '../utils/echartsTheme'

const PERIOD_COLOR = { 谷: theme.success, 平: theme.accent2, 峰: theme.danger }
const PERIOD_COLOR_LIGHT = { 谷: '#2fa36b', 平: '#1f6fd0', 峰: '#e2703a' }
const periodColor = (period) => (theme.mode === 'light' ? PERIOD_COLOR_LIGHT : PERIOD_COLOR)[period] || theme.palette[0]
const num = (v) => (Number.isFinite(Number(v)) ? Number(v) : 0)
const monthLabel = (v) => String(v || '').replace(/^\d{2}/, '')
const hourLabel = (h) => `${h}时`
const shortStation = (name) => {
  // 站点名格式为 "区县·站点名"，这里取站点名部分并去掉括号补充说明，避免坐标轴过长
  const text = String(name || '').replace(/[（(][^）)]*[）)]/g, '')
  const idx = text.indexOf('·')
  const body = idx >= 0 ? text.slice(idx + 1) : text
  return body.length > 11 ? `${body.slice(0, 11)}…` : body
}

/* ----------------------------- 1. 月度充电量趋势 ----------------------------- */
export function monthlyTrendOption(monthly = []) {
  const rows = monthly.slice(-12)
  return {
    grid: { left: 46, right: 46, top: 36, bottom: 34 },
    legend: {
      left: 'center',
      top: 2,
      itemWidth: 9,
      itemHeight: 7,
      itemGap: 10,
      textStyle: { color: theme.subTextColor, fontSize: 10 },
      data: ['充电量(kWh)', '订单数(单)']
    },
    tooltip: tooltipStyle(),
    xAxis: categoryAxis(rows.map((r) => monthLabel(r.stat_month_str)), {
      axisLabel: { color: theme.textColor, fontSize: 9, interval: 0, rotate: 38 }
    }),
    yAxis: [
      valueAxis({ axisLabel: { color: theme.textColor, fontSize: 10 } }),
      valueAxis({ splitLine: { show: false }, axisLabel: { color: theme.textColor, fontSize: 10 } })
    ],
    series: [
      {
        name: '充电量(kWh)',
        type: 'bar',
        barWidth: '46%',
        data: rows.map((r) => num(r.kwh)),
        itemStyle: { borderRadius: [4, 4, 0, 0], color: barGradient(theme.accent) }
      },
      {
        name: '订单数(单)',
        type: 'line',
        yAxisIndex: 1,
        smooth: true,
        symbol: 'circle',
        symbolSize: 6,
        data: rows.map((r) => num(r.sessions)),
        lineStyle: { width: 2, color: theme.warn },
        itemStyle: { color: theme.warn },
        areaStyle: { color: areaGradient(theme.warn, 0.25, 0.02) }
      }
    ]
  }
}

/* ----------------------------- 2. 24 小时负荷分布 ----------------------------- */
export function hourLoadOption(hourLoad = []) {
  const rows = [...hourLoad].sort((a, b) => num(a.start_hour) - num(b.start_hour))
  return {
    grid: { left: 40, right: 40, top: 34, bottom: 28 },
    legend: {
      left: 'center',
      top: 2,
      itemWidth: 9,
      itemHeight: 7,
      itemGap: 10,
      textStyle: { color: theme.subTextColor, fontSize: 10 },
      data: ['充电订单', '平均功率(kW)']
    },
    tooltip: tooltipStyle(),
    xAxis: categoryAxis(rows.map((r) => hourLabel(r.start_hour)), {
      axisLabel: { color: theme.textColor, fontSize: 9, interval: 2, formatter: (v) => String(v).replace('时', '') }
    }),
    yAxis: [
      valueAxis({ axisLabel: { color: theme.textColor, fontSize: 10 } }),
      valueAxis({ splitLine: { show: false }, axisLabel: { color: theme.textColor, fontSize: 10 } })
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
            color: barGradient(periodColor(r.time_period))
          }
        })),
        markPoint: {
          symbolSize: 32,
          label: { fontSize: 9, color: theme.markPointText },
          itemStyle: { color: theme.markPointColor },
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
        lineStyle: { width: 2, color: theme.success },
        areaStyle: { color: areaGradient(theme.success, 0.22, 0.01) }
      }
    ]
  }
}

/* ----------------------------- 3. 站点类型对比（雷达） ----------------------------- */
export function facilityRadarOption(facility = []) {
  const rows = facility.filter((r) => r.facility_type_cn && r.facility_type_cn !== '未知')
  const indicators = [
    { key: 'sessions', name: '订单' },
    { key: 'kwh', name: '电量' },
    { key: 'avg_power', name: '功率' },
    { key: 'avg_kwh', name: '单次' },
    { key: 'orders_per_device', name: '桩均' },
    { key: 'avg_hours', name: '时长' }
  ]
  const maxOf = (key) => Math.max(...rows.map((r) => num(r[key])), 1)
  const maxMap = Object.fromEntries(indicators.map((i) => [i.key, maxOf(i.key)]))
  return {
    tooltip: { trigger: 'item', backgroundColor: theme.tooltipBg, borderColor: theme.tooltipBorder, textStyle: { color: theme.tooltipText, fontSize: 12 } },
    legend: {
      bottom: 2,
      left: 'center',
      itemWidth: 9,
      itemHeight: 7,
      itemGap: 8,
      textStyle: { color: theme.subTextColor, fontSize: 10 }
    },
    radar: {
      center: ['50%', '43%'],
      radius: '56%',
      splitNumber: 4,
      indicator: indicators.map((i) => ({ name: i.name, max: 100 })),
      axisName: { color: theme.textColor, fontSize: 10, padding: [0, 1] },
      axisLine: { lineStyle: { color: theme.radarLine } },
      splitLine: { lineStyle: { color: theme.radarLine } },
      splitArea: { areaStyle: { color: theme.radarSplitArea } }
    },
    series: [
      {
        type: 'radar',
        symbolSize: 4,
        areaStyle: { opacity: 0.18 },
        data: rows.map((row, idx) => ({
          name: row.facility_type_cn,
          value: indicators.map((i) => Number(((num(row[i.key]) / maxMap[i.key]) * 100).toFixed(1))),
          lineStyle: { width: 2, color: theme.palette[idx % theme.palette.length] },
          itemStyle: { color: theme.palette[idx % theme.palette.length] },
          areaStyle: { color: hexToRgba(theme.palette[idx % theme.palette.length], 0.22) }
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
      backgroundColor: theme.tooltipBg,
      borderColor: theme.tooltipBorder,
      textStyle: { color: theme.tooltipText, fontSize: 12 },
      formatter: '{b}小时<br/>订单 {c} 单（{d}%）'
    },
    legend: {
      orient: 'vertical',
      right: 2,
      top: 'middle',
      itemWidth: 7,
      itemHeight: 6,
      itemGap: 5,
      textStyle: { color: theme.subTextColor, fontSize: 9 }
    },
    series: [
      {
        type: 'pie',
        center: ['36%', '54%'],
        radius: ['22%', '58%'],
        roseType: 'radius',
        itemStyle: { borderColor: theme.pieBorder, borderWidth: 2 },
        // 小卡里不显示引导线标签（会互相压字），用图例 + 悬浮提示；详情页再显示
        label: { show: false },
        labelLine: { show: false },
        emphasis: { label: { show: true, fontSize: 11, color: theme.textColor, formatter: '{b}\n{d}%' } },
        data: duration.map((r, i) => ({
          name: `${r.bin_label}`,
          value: num(r.sessions),
          itemStyle: { color: theme.palette[i % theme.palette.length] }
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
      textStyle: { color: theme.subTextColor, fontSize: 12 },
      data: ['日充电量(kWh)', '日订单数(单)', '活跃用户(人)']
    },
    tooltip: tooltipStyle({ axisPointer: { type: 'line', lineStyle: { color: theme.tooltipBorder } } }),
    xAxis: categoryAxis(rows.map((r) => String(r.stat_date).slice(5)), {
      boundaryGap: true,
      axisLabel: { color: theme.textColor, fontSize: 11, interval: Math.max(0, Math.floor(rows.length / 12)) }
    }),
    yAxis: [
      valueAxis({ name: 'kWh / 单', nameTextStyle: { color: theme.subTextColor, fontSize: 11 } }),
      valueAxis({ splitLine: { show: false }, name: '人', nameTextStyle: { color: theme.subTextColor, fontSize: 11 } })
    ],
    series: [
      {
        name: '日充电量(kWh)',
        type: 'line',
        smooth: true,
        symbol: 'none',
        data: rows.map((r) => num(r.kwh)),
        lineStyle: { width: 2.5, color: theme.accent },
        areaStyle: { color: areaGradient(theme.accent, 0.5, 0.02) },
        markPoint: {
          symbolSize: 46,
          label: { fontSize: 10, color: theme.markPointText },
          itemStyle: { color: theme.markPointColor },
          data: [{ type: 'max', name: '峰值' }]
        }
      },
      {
        name: '日订单数(单)',
        type: 'bar',
        barWidth: '38%',
        data: rows.map((r) => num(r.sessions)),
        itemStyle: { borderRadius: [3, 3, 0, 0], color: barGradient(theme.accent2) }
      },
      {
        name: '活跃用户(人)',
        type: 'line',
        yAxisIndex: 1,
        smooth: true,
        symbol: 'none',
        data: rows.map((r) => num(r.users)),
        lineStyle: { width: 2, color: theme.warn, type: 'dashed' }
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
      backgroundColor: theme.tooltipBg,
      borderColor: theme.tooltipBorder,
      textStyle: { color: theme.tooltipText, fontSize: 12 },
      formatter: (p) => `${daysCn[p.value[1]]} ${p.value[0]}:00<br/>订单 ${p.value[2]} 单`
    },
    xAxis: categoryAxis(Array.from({ length: 24 }, (_, i) => `${i}`), {
      splitArea: { show: false },
      axisLabel: { color: theme.textColor, fontSize: 10 }
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
      textStyle: { color: theme.subTextColor, fontSize: 10 },
      inRange: { color: theme.heatRange }
    },
    series: [
      {
        type: 'heatmap',
        data,
        label: { show: false },
        emphasis: { itemStyle: { borderColor: '#ffffff', borderWidth: 1 } },
        itemStyle: { borderColor: theme.heatBorder, borderWidth: 1 }
      }
    ]
  }
}

/* ----------------------------- 7. 站点充电量 TOP10 ----------------------------- */
export function stationTopOption(list = []) {
  const rows = [...list].sort((a, b) => num(a.kwh) - num(b.kwh))
  return {
    grid: { left: 104, right: 78, top: 16, bottom: 14 },
    tooltip: tooltipStyle({
      formatter: (params) => {
        const row = rows[params[0].dataIndex]
        return `${row.station_name}<br/>充电量 ${num(row.kwh)} kWh<br/>订单 ${num(row.sessions)} 单<br/>收入 ${num(row.revenue)} 元<br/>桩均订单 ${num(row.orders_per_device)} 单/台`
      }
    }),
    xAxis: valueAxis({ splitLine: { show: true } }),
    yAxis: categoryAxis(rows.map((r) => shortStation(r.station_name)), {
      axisLabel: { color: theme.textColor, fontSize: 11 }
    }),
    series: [
      {
        type: 'bar',
        barWidth: '58%',
        data: rows.map((r) => num(r.kwh)),
        itemStyle: { borderRadius: [0, 4, 4, 0], color: barGradient(theme.accent, false) },
        label: {
          show: true,
          position: 'right',
          color: theme.labelText,
          fontSize: 10,
          formatter: (p) => (p.value >= 1000 ? `${(p.value / 1000).toFixed(2)}k` : `${p.value}`)
        }
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
      left: 'center',
      top: 2,
      itemWidth: 9,
      itemHeight: 7,
      itemGap: 8,
      textStyle: { color: theme.subTextColor, fontSize: 10 },
      data: ['日均订单(单)', '日均电量(kWh)', '平均单次电量(kWh)']
    },
    tooltip: tooltipStyle(),
    xAxis: categoryAxis(rows.map((r) => r.day_type), { axisLabel: { color: theme.textColor, fontSize: 11 } }),
    yAxis: [
      valueAxis({ axisLabel: { color: theme.textColor, fontSize: 10 } }),
      valueAxis({ splitLine: { show: false }, axisLabel: { color: theme.textColor, fontSize: 10 } })
    ],
    series: [
      {
        name: '日均订单(单)',
        type: 'bar',
        barWidth: '26%',
        data: rows.map((r) => num(r.sessions_per_day)),
        itemStyle: { borderRadius: [4, 4, 0, 0], color: barGradient(theme.accent) }
      },
      {
        name: '日均电量(kWh)',
        type: 'bar',
        yAxisIndex: 1,
        barWidth: '26%',
        data: rows.map((r) => num(r.kwh_per_day)),
        itemStyle: { borderRadius: [4, 4, 0, 0], color: barGradient(theme.purple) }
      },
      {
        name: '平均单次电量(kWh)',
        type: 'line',
        yAxisIndex: 1,
        smooth: true,
        symbolSize: 7,
        data: rows.map((r) => num(r.avg_kwh)),
        lineStyle: { color: theme.warn, width: 2 },
        itemStyle: { color: theme.warn }
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
      left: 'center',
      top: 2,
      itemWidth: 9,
      itemHeight: 7,
      itemGap: 8,
      textStyle: { color: theme.subTextColor, fontSize: 10 },
      data: ['订单数(单)', '平均单次电量(kWh)']
    },
    tooltip: tooltipStyle(),
    xAxis: categoryAxis(rows.map((r) => String(r.platform).toUpperCase()), {
      axisLabel: { color: theme.textColor, fontSize: 11 }
    }),
    yAxis: [
      valueAxis({ axisLabel: { color: theme.textColor, fontSize: 10 } }),
      valueAxis({ splitLine: { show: false }, axisLabel: { color: theme.textColor, fontSize: 10 } })
    ],
    series: [
      {
        name: '订单数(单)',
        type: 'bar',
        barWidth: '34%',
        data: rows.map((r) => num(r.sessions)),
        itemStyle: { borderRadius: [4, 4, 0, 0], color: barGradient(theme.success) },
        label: { show: true, position: 'top', color: theme.labelText2, fontSize: 10, formatter: (p) => `${p.value}` }
      },
      {
        name: '平均单次电量(kWh)',
        type: 'line',
        yAxisIndex: 1,
        smooth: true,
        symbolSize: 7,
        data: rows.map((r) => num(r.avg_kwh)),
        lineStyle: { color: theme.orange, width: 2 },
        itemStyle: { color: theme.orange }
      }
    ]
  }
}

/* ----------------------------- 10. 用户价值分层（环形） ----------------------------- */
export function userSegmentOption(segment = []) {
  const rows = [...segment].sort((a, b) => num(b.user_cnt) - num(a.user_cnt))
  const total = rows.reduce((sum, r) => sum + num(r.user_cnt), 0)
  const colors = theme.palette
  return {
    tooltip: {
      trigger: 'item',
      backgroundColor: theme.tooltipBg,
      borderColor: theme.tooltipBorder,
      textStyle: { color: theme.tooltipText, fontSize: 12 },
      formatter: (p) => {
        const row = rows[p.dataIndex] || {}
        return `${p.name}<br/>用户 ${num(row.user_cnt)} 人（${p.percent}%）<br/>电量 ${num(row.kwh)} kWh<br/>订单 ${num(row.sessions)} 单`
      }
    },
    legend: {
      // 图例放到下方并限制宽度（自动换行），避免与圆环一起挤出面板边框
      left: 'center',
      bottom: 0,
      width: '96%',
      itemWidth: 8,
      itemHeight: 7,
      itemGap: 4,
      textStyle: { color: theme.subTextColor, fontSize: 9 }
    },
    title: {
      text: `${total}`,
      subtext: '累计用户(人)',
      left: '50%',
      top: '36%',
      textAlign: 'center',
      textStyle: { color: theme.accent, fontSize: 20, fontWeight: 'bold' },
      subtextStyle: { color: theme.subTextColor, fontSize: 10 }
    },
    series: [
      {
        type: 'pie',
        center: ['50%', '44%'],
        radius: ['34%', '58%'],
        itemStyle: { borderColor: theme.pieBorder, borderWidth: 2 },
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
    grid: { ...baseGrid, top: 34, bottom: 30 },
    legend: {
      left: 'center',
      top: 2,
      itemWidth: 9,
      itemHeight: 7,
      itemGap: 8,
      textStyle: { color: theme.subTextColor, fontSize: 10 },
      data: ['充电功率(kW)', '单体压差(mV)', '温升(℃)']
    },
    tooltip: tooltipStyle(),
    xAxis: categoryAxis(rows.map((r) => String(r.soc_bin)), {
      axisLabel: { color: theme.textColor, fontSize: 9, interval: 0, formatter: (v) => String(v).split('-')[0] }
    }),
    yAxis: [
      valueAxis({ axisLabel: { color: theme.textColor, fontSize: 10 } }),
      valueAxis({ splitLine: { show: false }, axisLabel: { color: theme.textColor, fontSize: 10 } })
    ],
    series: [
      {
        name: '充电功率(kW)',
        type: 'bar',
        barWidth: '34%',
        data: rows.map((r) => num(r.avg_power)),
        itemStyle: { borderRadius: [3, 3, 0, 0], color: barGradient(theme.accent) }
      },
      {
        name: '单体压差(mV)',
        type: 'line',
        smooth: true,
        symbolSize: 6,
        data: rows.map((r) => num(r.avg_cell_diff_mv)),
        lineStyle: { color: theme.warn, width: 2 },
        itemStyle: { color: theme.warn }
      },
      {
        name: '温升(℃)',
        type: 'line',
        yAxisIndex: 1,
        smooth: true,
        symbolSize: 6,
        data: rows.map((r) => num(r.avg_temp_rise)),
        lineStyle: { color: theme.danger, width: 2, type: 'dashed' },
        itemStyle: { color: theme.danger }
      }
    ]
  }
}

/* ----------------------------- 12. 峰平谷时段对比（漏斗） ----------------------------- */
export function timePeriodFunnelOption(period = []) {
  const order = { 峰: 0, 平: 1, 谷: 2 }
  const rows = [...period].sort((a, b) => (order[a.time_period] ?? 9) - (order[b.time_period] ?? 9))
  const colors = { 峰: theme.danger, 平: theme.accent2, 谷: theme.success }
  return {
    tooltip: {
      trigger: 'item',
      backgroundColor: theme.tooltipBg,
      borderColor: theme.tooltipBorder,
      textStyle: { color: theme.tooltipText, fontSize: 12 },
      formatter: (p) => {
        const row = rows[p.dataIndex] || {}
        return `${p.name}时段<br/>充电量 ${num(row.kwh)} kWh<br/>订单 ${num(row.sessions)} 单（${num(row.sessions_pct)}%）<br/>收入 ${num(row.revenue)} 元`
      }
    },
    series: [
      {
        type: 'funnel',
        left: '8%',
        right: '8%',
        top: 8,
        bottom: 4,
        minSize: '38%',
        sort: 'descending',
        gap: 3,
        // 标签放在漏斗内部并压缩字数，避免与色块/边缘重叠
        label: { position: 'inside', color: '#ffffff', fontSize: 11, formatter: (p) => `${p.name} ${p.data.pct}%` },
        labelLine: { show: false },
        itemStyle: { borderWidth: 0, opacity: 0.92 },
        data: rows.map((r) => ({
          name: `${r.time_period}时段`,
          value: num(r.kwh),
          pct: Number(num(r.kwh_pct).toFixed(1)),
          itemStyle: { color: hexToRgba(periodColor(r.time_period), 0.85) }
        }))
      }
    ]
  }
}

/* ----------------------------- 13. 单次充电量分布 ----------------------------- */
export function energyDistOption(energy = []) {
  const rows = [...energy].sort((a, b) => num(a.bin_order) - num(b.bin_order))
  return {
    grid: { ...baseGrid, top: 30, bottom: 26 },
    legend: {
      left: 'center',
      top: 2,
      itemWidth: 9,
      itemHeight: 7,
      itemGap: 10,
      textStyle: { color: theme.subTextColor, fontSize: 10 },
      data: ['订单数(单)', '占比(%)']
    },
    tooltip: tooltipStyle(),
    xAxis: categoryAxis(rows.map((r) => `${r.bin_label}`), { axisLabel: { color: theme.textColor, fontSize: 10, interval: 0 } }),
    yAxis: [
      valueAxis({ axisLabel: { color: theme.textColor, fontSize: 10 } }),
      valueAxis({ splitLine: { show: false }, max: 100, axisLabel: { color: theme.textColor, fontSize: 10 } })
    ],
    series: [
      {
        name: '订单数(单)',
        type: 'bar',
        barWidth: '46%',
        data: rows.map((r) => num(r.sessions)),
        itemStyle: { borderRadius: [3, 3, 0, 0], color: barGradient(theme.purple) }
      },
      {
        name: '占比(%)',
        type: 'line',
        yAxisIndex: 1,
        smooth: true,
        symbolSize: 6,
        data: rows.map((r) => num(r.pct)),
        lineStyle: { color: theme.accent, width: 2 },
        itemStyle: { color: theme.accent }
      }
    ]
  }
}

/* ----------------------------- 14. 收入结构与付费率（堆叠 + 折线） ----------------------------- */
export function revenueStructOption(revenue = [], dimType = '站点类型') {
  const rows = revenue.filter((r) => r.dim_type === dimType).sort((a, b) => num(b.revenue) - num(a.revenue))
  return {
    grid: { ...baseGrid, top: 30, bottom: 30 },
    legend: {
      left: 'center',
      top: 2,
      itemWidth: 9,
      itemHeight: 7,
      itemGap: 10,
      textStyle: { color: theme.subTextColor, fontSize: 10 },
      data: ['收入(元)', '付费率(%)']
    },
    tooltip: tooltipStyle(),
    xAxis: categoryAxis(rows.map((r) => String(r.dim_name).replace('充电站', '')), {
      axisLabel: { color: theme.textColor, fontSize: 10, interval: 0, rotate: rows.length > 4 ? 18 : 0 }
    }),
    yAxis: [
      valueAxis({ axisLabel: { color: theme.textColor, fontSize: 10 } }),
      valueAxis({ splitLine: { show: false }, max: 100, axisLabel: { color: theme.textColor, fontSize: 10 } })
    ],
    series: [
      {
        name: '收入(元)',
        type: 'bar',
        barWidth: '38%',
        stack: 'revenue',
        data: rows.map((r) => num(r.revenue)),
        itemStyle: { borderRadius: [3, 3, 0, 0], color: barGradient(theme.warn) }
      },
      {
        name: '付费率(%)',
        type: 'line',
        yAxisIndex: 1,
        smooth: true,
        symbolSize: 6,
        data: rows.map((r) => num(r.paid_rate)),
        lineStyle: { color: theme.success, width: 2 },
        itemStyle: { color: theme.success }
      }
    ]
  }
}

/* -------------------- 15. 行政区分布（横向条形，按区县对比） -------------------- */
export function districtBarOption(district = []) {
  const rows = [...district].sort((a, b) => num(a.kwh) - num(b.kwh)).slice(-6)
  return {
    grid: { left: 74, right: 76, top: 12, bottom: 10 },
    tooltip: tooltipStyle({
      formatter: (params) => {
        const row = rows[params[0].dataIndex]
        return `${row.district}<br/>充电量 ${num(row.kwh)} kWh（占比 ${num(row.kwh_pct)}%）<br/>订单 ${num(row.sessions)} 单<br/>站点 ${num(row.station_cnt)} 座 · 桩 ${num(row.device_cnt)} 台`
      }
    }),
    xAxis: valueAxis({ splitLine: { show: true } }),
    yAxis: categoryAxis(rows.map((r) => String(r.district || '').replace('新区', '')), {
      axisLabel: { color: theme.textColor, fontSize: 11 }
    }),
    series: [
      {
        type: 'bar',
        barWidth: '56%',
        data: rows.map((r) => num(r.kwh)),
        itemStyle: { borderRadius: [0, 4, 4, 0], color: barGradient(theme.accent, false) },
        label: {
          show: true,
          position: 'right',
          color: theme.labelText,
          fontSize: 10,
          formatter: (p) => `${p.value} kWh`
        }
      }
    ]
  }
}

/* ----------------------------- 16. 充电功率分布（时序散点，用于电池面板辅图） ----------------------------- */
export function powerDistOption(power = []) {
  const rows = [...power].sort((a, b) => num(a.bin_order) - num(b.bin_order))
  return {
    grid: { ...baseGrid, top: 30, bottom: 20 },
    tooltip: tooltipStyle(),
    xAxis: categoryAxis(rows.map((r) => `${r.bin_label}`), { axisLabel: { color: theme.textColor, fontSize: 10 } }),
    yAxis: valueAxis(),
    series: [
      {
        type: 'bar',
        barWidth: '44%',
        data: rows.map((r) => num(r.samples)),
        itemStyle: { borderRadius: [3, 3, 0, 0], color: barGradient(theme.success) },
        markLine: { silent: true, symbol: 'none', data: [], lineStyle: { color: theme.splitLineColor } }
      }
    ]
  }
}
