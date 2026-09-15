/**
 * 大屏统一视觉规范：配色、渐变、字体、坐标轴样式
 */
export const palette = ['#00e4ff', '#3b82f6', '#7c5cff', '#22e6a4', '#ffd166', '#ff7a59', '#ff4d8d', '#31d0f5']

export const axisLineColor = 'rgba(120, 200, 255, 0.35)'
export const splitLineColor = 'rgba(120, 200, 255, 0.12)'
export const textColor = '#cfe9ff'
export const subTextColor = 'rgba(160, 200, 235, 0.75)'

export function areaGradient(color, top = 0.55, bottom = 0.02) {
  return {
    type: 'linear',
    x: 0,
    y: 0,
    x2: 0,
    y2: 1,
    colorStops: [
      { offset: 0, color: hexToRgba(color, top) },
      { offset: 1, color: hexToRgba(color, bottom) }
    ]
  }
}

export function barGradient(color, vertical = true) {
  return {
    type: 'linear',
    x: 0,
    y: 0,
    x2: vertical ? 0 : 1,
    y2: vertical ? 1 : 0,
    colorStops: [
      { offset: 0, color: hexToRgba(color, 0.95) },
      { offset: 1, color: hexToRgba(color, 0.18) }
    ]
  }
}

export function hexToRgba(hex, alpha = 1) {
  const value = hex.replace('#', '')
  const r = parseInt(value.substring(0, 2), 16)
  const g = parseInt(value.substring(2, 4), 16)
  const b = parseInt(value.substring(4, 6), 16)
  return `rgba(${r}, ${g}, ${b}, ${alpha})`
}

export const baseGrid = { left: 42, right: 22, top: 34, bottom: 24 }

export function tooltipStyle(extra = {}) {
  return {
    trigger: 'axis',
    backgroundColor: 'rgba(6, 30, 58, 0.92)',
    borderColor: 'rgba(0, 228, 255, 0.45)',
    borderWidth: 1,
    textStyle: { color: '#dff3ff', fontSize: 12 },
    axisPointer: { type: 'shadow', shadowStyle: { color: 'rgba(0, 228, 255, 0.08)' } },
    ...extra
  }
}

export function categoryAxis(data, extra = {}) {
  return {
    type: 'category',
    data,
    axisLine: { lineStyle: { color: axisLineColor } },
    axisTick: { show: false },
    axisLabel: { color: textColor, fontSize: 11 },
    ...extra
  }
}

export function valueAxis(extra = {}) {
  return {
    type: 'value',
    axisLine: { show: false },
    axisTick: { show: false },
    axisLabel: { color: textColor, fontSize: 11 },
    splitLine: { lineStyle: { color: splitLineColor, type: 'dashed' } },
    ...extra
  }
}
