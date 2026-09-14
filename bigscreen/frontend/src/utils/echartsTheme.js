/**
 * 大屏主题：暗色（默认）与亮色两套配色，支持按钮一键切换
 * 通过响应式对象 theme 暴露给图表配置与组件，切换后所有图表自动重绘
 */
import { reactive } from 'vue'

const DARK = {
  mode: 'dark',
  palette: ['#00e4ff', '#3b82f6', '#7c5cff', '#22e6a4', '#ffd166', '#ff7a59', '#ff4d8d', '#31d0f5'],
  accent: '#00e4ff',
  accent2: '#3b82f6',
  accentLine: 'rgba(0,228,255,0.45)',
  success: '#22e6a4',
  warn: '#ffd166',
  danger: '#ff7a59',
  orange: '#ff9f68',
  purple: '#7c5cff',
  labelText: '#bfe9ff',
  labelText2: '#9ff5d4',
  radarLine: 'rgba(120, 200, 255, 0.32)',
  textColor: '#cfe9ff',
  subTextColor: 'rgba(160, 200, 235, 0.75)',
  axisLineColor: 'rgba(120, 200, 255, 0.35)',
  splitLineColor: 'rgba(120, 200, 255, 0.12)',
  tooltipBg: 'rgba(6, 30, 58, 0.92)',
  tooltipBorder: 'rgba(0, 228, 255, 0.45)',
  tooltipText: '#dff3ff',
  pieBorder: 'rgba(4, 18, 36, 0.9)',
  heatBorder: 'rgba(4, 18, 36, 0.6)',
  heatRange: ['#0b2f5c', '#1b6fc4', '#00e4ff', '#ffd166'],
  radarSplitArea: ['rgba(0, 120, 200, 0.04)', 'rgba(0, 120, 200, 0.10)'],
  markPointColor: 'rgba(255, 209, 102, 0.9)',
  markPointText: '#04121f',
  panelBorder: ['#0f5f9c', '#00e4ff'],
  panelBg: 'rgba(8, 30, 58, 0.55)',
  pondBorder: 'rgba(0, 228, 255, 0.6)',
  scrollHeaderBg: 'rgba(0, 120, 200, 0.35)',
  scrollOddBg: 'rgba(6, 40, 74, 0.45)',
  scrollEvenBg: 'rgba(4, 24, 48, 0.35)',
  ringTrack: 'rgba(120, 200, 255, 0.25)',
  funnelOpacity: 0.92
}

const LIGHT = {
  mode: 'light',
  palette: ['#1f6fd0', '#2fa36b', '#f0982a', '#d94f70', '#7a5cd6', '#12a5b8', '#e2703a', '#4a7fb5'],
  accent: '#1f6fd0',
  accent2: '#4a7fb5',
  accentLine: 'rgba(31,111,208,0.45)',
  success: '#2fa36b',
  warn: '#e0951f',
  danger: '#d9544d',
  orange: '#e2703a',
  purple: '#7a5cd6',
  labelText: '#2b4d72',
  labelText2: '#1f7a5c',
  radarLine: 'rgba(60, 110, 165, 0.35)',
  textColor: '#22405f',
  subTextColor: 'rgba(45, 78, 112, 0.85)',
  axisLineColor: 'rgba(60, 110, 165, 0.45)',
  splitLineColor: 'rgba(60, 110, 165, 0.18)',
  tooltipBg: 'rgba(255, 255, 255, 0.96)',
  tooltipBorder: 'rgba(31, 111, 208, 0.45)',
  tooltipText: '#1d3b5c',
  pieBorder: 'rgba(255, 255, 255, 0.95)',
  heatBorder: 'rgba(255, 255, 255, 0.9)',
  heatRange: ['#e8f1fb', '#9dc8ef', '#4f9be0', '#1f6fd0'],
  radarSplitArea: ['rgba(31, 111, 208, 0.04)', 'rgba(31, 111, 208, 0.12)'],
  markPointColor: 'rgba(240, 152, 42, 0.9)',
  markPointText: '#ffffff',
  panelBorder: ['#9dc4e8', '#2b7fd4'],
  panelBg: 'rgba(255, 255, 255, 0.9)',
  pondBorder: 'rgba(31, 111, 208, 0.55)',
  scrollHeaderBg: 'rgba(31, 111, 208, 0.16)',
  scrollOddBg: 'rgba(240, 246, 253, 0.95)',
  scrollEvenBg: 'rgba(255, 255, 255, 0.9)',
  ringTrack: 'rgba(120, 150, 190, 0.28)',
  funnelOpacity: 0.95
}

export const theme = reactive({ ...DARK })

export function applyTheme(mode) {
  Object.assign(theme, mode === 'light' ? LIGHT : DARK)
}

export function toggleTheme() {
  applyTheme(theme.mode === 'light' ? 'dark' : 'light')
  return theme.mode
}

export function initTheme() {
  // 优先 URL 参数（便于演示/截图指定主题），其次本地记录
  let fromUrl = null
  try {
    fromUrl = new URLSearchParams(window.location.search).get('theme')
  } catch (err) {
    fromUrl = null
  }
  let saved = null
  try {
    saved = window.localStorage.getItem('charging-screen-theme')
  } catch (err) {
    saved = null
  }
  applyTheme(fromUrl === 'light' || fromUrl === 'dark' ? fromUrl : saved === 'light' ? 'light' : 'dark')
}

export function persistTheme(mode) {
  try {
    window.localStorage.setItem('charging-screen-theme', mode)
  } catch (err) {
    /* 忽略隐私模式下的存储异常 */
  }
}

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
      { offset: 1, color: hexToRgba(color, theme.mode === 'light' ? 0.45 : 0.18) }
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
    backgroundColor: theme.tooltipBg,
    borderColor: theme.tooltipBorder,
    borderWidth: 1,
    textStyle: { color: theme.tooltipText, fontSize: 12 },
    axisPointer: { type: 'shadow', shadowStyle: { color: theme.mode === 'light' ? 'rgba(31,111,208,0.08)' : 'rgba(0, 228, 255, 0.08)' } },
    ...extra
  }
}

export function itemTooltipStyle(formatter) {
  return {
    trigger: 'item',
    backgroundColor: theme.tooltipBg,
    borderColor: theme.tooltipBorder,
    borderWidth: 1,
    textStyle: { color: theme.tooltipText, fontSize: 12 },
    ...(formatter ? { formatter } : {})
  }
}

export function categoryAxis(data, extra = {}) {
  return {
    type: 'category',
    data,
    axisLine: { lineStyle: { color: theme.axisLineColor } },
    axisTick: { show: false },
    axisLabel: { color: theme.textColor, fontSize: 11 },
    ...extra
  }
}

export function valueAxis(extra = {}) {
  return {
    type: 'value',
    axisLine: { show: false },
    axisTick: { show: false },
    axisLabel: { color: theme.textColor, fontSize: 11 },
    splitLine: { lineStyle: { color: theme.splitLineColor, type: 'dashed' } },
    ...extra
  }
}
