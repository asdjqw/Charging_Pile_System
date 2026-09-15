/**
 * 详情页配置转换：把主屏的小图配置等比放大，用于全屏查看。
 * - 文字/图例/线宽等尺寸整体放大，避免大画布上显得过于稀疏；
 * - 饼图/玫瑰图在小卡里隐藏了标签，这里自动补回标签与引导线。
 */
const SIZE_KEYS = new Set([
  'fontSize',
  'itemWidth',
  'itemHeight',
  'itemGap',
  'symbolSize',
  'lineWidth',
  'borderWidth',
  'length',
  'length2',
  'gap'
])

function scaleValue(value, factor) {
  if (typeof value === 'number') return Math.round(value * factor)
  if (Array.isArray(value)) return value.map((item) => (typeof item === 'number' ? Math.round(item * factor) : item))
  return value
}

function walk(node, factor, key) {
  if (Array.isArray(node)) return node.map((item) => walk(item, factor))
  if (node && typeof node === 'object') {
    const out = {}
    for (const [k, v] of Object.entries(node)) {
      out[k] = SIZE_KEYS.has(k) ? scaleValue(v, factor) : walk(v, factor, k)
    }
    return out
  }
  return node
}

export function buildDetailOption(option, factor = 1.75) {
  if (!option) return option
  const scaled = walk(JSON.parse(JSON.stringify(option)), factor)
  const seriesList = Array.isArray(scaled.series) ? scaled.series : scaled.series ? [scaled.series] : []
  seriesList.forEach((series) => {
    // 详情页统一开启标签防重叠：放不下的标签自动隐藏，避免文字互相压字
    series.labelLayout = { hideOverlap: true, ...(series.labelLayout || {}) }
    if (series.type === 'pie') {
      series.label = {
        ...(series.label || {}),
        show: true,
        fontSize: Math.max(13, Math.round((series.label?.fontSize || 11) * factor * 0.75)),
        formatter: '{b}\n{d}%'
      }
      series.labelLine = { ...(series.labelLine || {}), show: true, length: 16, length2: 12 }
      // 大画布上把圆环放到中间并放大，避免偏在一角
      series.center = ['48%', '52%']
      series.radius = series.roseType ? ['30%', '66%'] : ['42%', '68%']
    }
    // 柱状图在大画布上补数值标签，但数据点太多时会互相压字，因此只在类别很少（≤12）时添加
    const pointCount = Array.isArray(series.data) ? series.data.length : 0
    if (series.type === 'bar' && !series.label?.show && pointCount > 0 && pointCount <= 12) {
      series.label = { show: true, position: 'top', fontSize: 12, ...(series.label || {}) }
    }
  })
  return scaled
}
