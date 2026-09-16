<template>
  <div class="viewport">
    <div class="stage" :data-theme="theme.mode" :style="stageStyle">
      <div class="stage-grid"></div>

      <!-- 标题栏 -->
      <div class="fc-head">
        <a class="fc-back" href="#/">← 返回分析大屏</a>
        <div class="fc-titles">
          <div class="fc-title">充电负荷智能预测</div>
          <div class="fc-subtitle">
            六个冻结模型（H1 / H6 / H24 × 负荷率 / 占用率）· 本站点预测值，不是 24 点曲线
          </div>
        </div>
        <div class="fc-head__right">
          <span class="fc-clock">{{ now }}</span>
          <button class="fc-btn" type="button" @click="toggle()">
            <span>{{ isLight ? '🌙' : '☀' }}</span>{{ isLight ? '暗色主题' : '亮色主题' }}
          </button>
          <button class="fc-btn" type="button" :disabled="loading" @click="load(true)">
            {{ loading ? '刷新中…' : '刷新数据' }}
          </button>
        </div>
      </div>

      <!-- 批次信息 -->
      <div class="fc-meta">
        <span class="chip" :class="sourceKind === 'SIMULATED' ? 'chip--gold' : 'chip--green'">
          {{ sourceKind === 'SIMULATED' ? '模拟批次 SIMULATED' : '实测批次 MEASURED' }}
        </span>
        <span class="chip">数据截止 {{ fmtTime(meta.data_cutoff_time) }}</span>
        <span class="chip" :class="ageClass">距现在 {{ ageText }}</span>
        <span class="chip">质量 {{ meta.quality_status || '--' }}</span>
        <span class="chip" :title="`模型冻结：${meta.model_freeze_id || '--'}`">
          模型冻结 {{ freezeShort }}
        </span>
        <span class="chip chip--gold" :title="`负荷模型：${modelText('load')}`">
          负荷 {{ compactModels('load') }}
        </span>
        <span class="chip chip--gold" :title="`占用模型：${modelText('occupancy')}`">
          占用 {{ compactModels('occupancy') }}
        </span>
        <span class="chip" :title="`数据版本：${meta.data_version || '--'}`">
          版本 {{ versionShort }}
        </span>
        <span class="chip" :title="`批次：${meta.run_id || '--'}｜生成于 ${fmtTime(meta.generated_at)}`">
          批次 {{ runShort }}
        </span>
      </div>

      <!-- KPI -->
      <div class="fc-kpis">
        <div v-for="card in kpis" :key="card.label" class="fc-kpi">
          <div class="fc-kpi__label"><i class="fc-dot" :style="{ background: card.color }"></i>{{ card.label }}</div>
          <div class="fc-kpi__value" :style="{ color: card.color }">{{ card.value }}</div>
          <div class="fc-kpi__note">{{ card.note }}</div>
        </div>
      </div>

      <!-- 图表 -->
      <div class="fc-charts">
        <PanelBox title="站点预测负荷 TOP10" subtitle="三窗口分组 · 单位 kW">
          <EChart v-if="hasData" :option="topOption" />
          <div v-else class="fc-empty">暂无批次数据</div>
        </PanelBox>
        <PanelBox title="目标小时整体水平" subtitle="全部站点平均负荷率 / 占用率">
          <EChart v-if="hasData" :option="avgOption" />
          <div v-else class="fc-empty">暂无批次数据</div>
        </PanelBox>
      </div>

      <!-- 预测明细表 -->
      <div class="fc-table-row">
        <PanelBox class="fc-table-card" title="站点预测明细" :subtitle="tableSubtitle">
          <div class="fc-panel-body">
            <div class="fc-tools">
              <input v-model="search" class="fc-input" type="search" placeholder="搜索站点名称 / 编号" />
              <div class="fc-seg">
                <button
                  v-for="opt in congestionOptions"
                  :key="opt.value"
                  type="button"
                  :class="{ 'is-active': congestion === opt.value }"
                  @click="congestion = opt.value"
                >
                  {{ opt.label }}
                </button>
              </div>
              <div class="fc-seg">
                <button
                  v-for="opt in horizonOptions"
                  :key="opt.value"
                  type="button"
                  :class="{ 'is-active': horizon === opt.value }"
                  @click="horizon = opt.value"
                >
                  {{ opt.label }}
                </button>
              </div>
              <span class="fc-tools__spacer"></span>
              <button class="fc-btn fc-btn--small" type="button" :disabled="!rows.length" @click="exportCsv">
                导出 CSV
              </button>
            </div>
            <div class="fc-table-scroll">
              <table class="fc-table">
                <thead>
                  <tr>
                    <th class="fc-th-sort" @click="sortBy('name')">站点{{ sortMark('name') }}</th>
                    <th class="fc-th-sort fc-num" @click="sortBy('piles')">桩数{{ sortMark('piles') }}</th>
                    <th class="fc-th-sort fc-num" @click="sortBy('capacity')">装机 kW{{ sortMark('capacity') }}</th>
                    <template v-if="horizon === 'all'">
                      <template v-for="h in HORIZONS" :key="h">
                        <th class="fc-th-sort fc-num" @click="sortBy(metricKey(h, 'load_kw'))">
                          {{ h.toUpperCase() }} 负荷{{ sortMark(metricKey(h, 'load_kw')) }}
                        </th>
                        <th class="fc-th-sort fc-num" @click="sortBy(metricKey(h, 'load_ratio'))">
                          负荷率{{ sortMark(metricKey(h, 'load_ratio')) }}
                        </th>
                        <th class="fc-th-sort fc-num" @click="sortBy(metricKey(h, 'occupancy_ratio'))">
                          占用率{{ sortMark(metricKey(h, 'occupancy_ratio')) }}
                        </th>
                      </template>
                    </template>
                    <template v-else>
                      <th class="fc-num">目标时段</th>
                      <th class="fc-th-sort fc-num" @click="sortBy(metricKey(horizon, 'load_kw'))">
                        预测负荷{{ sortMark(metricKey(horizon, 'load_kw')) }}
                      </th>
                      <th class="fc-th-sort fc-num" @click="sortBy(metricKey(horizon, 'load_ratio'))">
                        负荷率{{ sortMark(metricKey(horizon, 'load_ratio')) }}
                      </th>
                      <th class="fc-th-sort fc-num" @click="sortBy(metricKey(horizon, 'occupancy_ratio'))">
                        占用率{{ sortMark(metricKey(horizon, 'occupancy_ratio')) }}
                      </th>
                      <th class="fc-num">等效占用桩</th>
                      <th class="fc-num">等效空闲桩</th>
                      <th class="fc-num">模型版本</th>
                    </template>
                    <th class="fc-th-sort fc-num" @click="sortBy('congestion')">拥堵{{ sortMark('congestion') }}</th>
                    <th class="fc-num">状态</th>
                  </tr>
                </thead>
                <tbody>
                  <tr
                    v-for="row in visibleRows"
                    :key="row.id"
                    :class="{ 'is-selected': row.id === selectedId }"
                    @click="selectedId = row.id === selectedId ? null : row.id"
                  >
                    <td class="fc-td-name">
                      <span class="fc-name">{{ row.name }}</span>
                      <span class="fc-id">{{ row.id }}</span>
                    </td>
                    <td class="fc-num">{{ row.piles }}</td>
                    <td class="fc-num">{{ fmtNum(row.capacity, 0) }}</td>
                    <template v-if="horizon === 'all'">
                      <template v-for="h in HORIZONS" :key="h">
                        <td class="fc-num fc-strong">{{ fmtNum(row.m[h].load_kw, 1) }}</td>
                        <td class="fc-num">
                          <span class="fc-bar-cell">
                            <span class="fc-loadbar" :style="{ width: barWidth(row.m[h].load_ratio), background: barColor(row.m[h].load_ratio) }"></span>
                            {{ fmtPct(row.m[h].load_ratio) }}
                          </span>
                        </td>
                        <td class="fc-num">{{ fmtPct(row.m[h].occupancy_ratio) }}</td>
                      </template>
                    </template>
                    <template v-else>
                      <td class="fc-num fc-time">{{ fmtRange(row.m[horizon].target_start, row.m[horizon].target_end) }}</td>
                      <td class="fc-num fc-strong">{{ fmtNum(row.m[horizon].load_kw, 1) }}</td>
                      <td class="fc-num">
                        <span class="fc-bar-cell">
                          <span class="fc-loadbar" :style="{ width: barWidth(row.m[horizon].load_ratio), background: barColor(row.m[horizon].load_ratio) }"></span>
                          {{ fmtPct(row.m[horizon].load_ratio) }}
                        </span>
                      </td>
                      <td class="fc-num">{{ fmtPct(row.m[horizon].occupancy_ratio) }}</td>
                      <td class="fc-num">{{ fmtNum(row.m[horizon].equivalent_occupied_piles, 0) }}</td>
                      <td class="fc-num">{{ fmtNum(row.m[horizon].equivalent_idle_piles, 0) }}</td>
                      <td class="fc-num">{{ modelText('load', horizon) }}</td>
                    </template>
                    <td class="fc-num">
                      <span class="fc-badge" :class="`fc-badge--${row.congestion}`">{{ congestionText(row.congestion) }}</span>
                    </td>
                    <td class="fc-num">
                      <span class="fc-status" :class="row.status === 'ok' ? 'is-ok' : 'is-bad'">
                        {{ row.status === 'ok' ? '正常' : '异常' }}
                      </span>
                    </td>
                  </tr>
                  <tr v-if="!visibleRows.length">
                    <td class="fc-none" :colspan="columnCount">没有符合条件的站点</td>
                  </tr>
                </tbody>
              </table>
            </div>
            <div class="fc-pager">
              <span class="fc-pager__info">
                共 {{ sortedRows.length }} 条 · 第 {{ pageRangeText }} 条 · 第 {{ page }} / {{ pageCount }} 页
              </span>
              <span class="fc-tools__spacer"></span>
              <button class="fc-btn fc-btn--small" type="button" :disabled="page <= 1" @click="goPage(1)">首页</button>
              <button class="fc-btn fc-btn--small" type="button" :disabled="page <= 1" @click="goPage(page - 1)">上一页</button>
              <button class="fc-btn fc-btn--small" type="button" :disabled="page >= pageCount" @click="goPage(page + 1)">下一页</button>
              <button class="fc-btn fc-btn--small" type="button" :disabled="page >= pageCount" @click="goPage(pageCount)">末页</button>
            </div>
          </div>
        </PanelBox>

        <aside v-if="selected" class="fc-detail">
          <div class="fc-detail__head">
            <div>
              <div class="fc-detail__name">{{ selected.name }}</div>
              <div class="fc-detail__id">站点编号 {{ selected.id }}</div>
            </div>
            <button class="fc-close" type="button" @click="selectedId = null">✕</button>
          </div>
          <div class="fc-detail__facts">
            <span>充电桩 {{ selected.piles }} 台</span>
            <span>装机容量 {{ fmtNum(selected.capacity, 1) }} kW</span>
            <span>拥堵 {{ congestionText(selected.congestion) }}</span>
            <span>预警 {{ warningText(selected.warning) }}</span>
          </div>
          <div v-for="h in HORIZONS" :key="h" class="fc-detail__block">
            <div class="fc-detail__block-head">
              <span class="fc-detail__horizon">{{ h.toUpperCase() }}</span>
              <span class="fc-detail__window">{{ fmtRange(selected.m[h].target_start, selected.m[h].target_end) }}</span>
            </div>
            <div class="fc-detail__grid">
              <div><em>预测负荷</em><b>{{ fmtNum(selected.m[h].load_kw, 1) }} kW</b></div>
              <div><em>负荷率</em><b>{{ fmtPct(selected.m[h].load_ratio) }}</b></div>
              <div><em>占用率</em><b>{{ fmtPct(selected.m[h].occupancy_ratio) }}</b></div>
              <div><em>等效占用桩</em><b>{{ fmtNum(selected.m[h].equivalent_occupied_piles, 0) }}</b></div>
              <div><em>等效空闲桩</em><b>{{ fmtNum(selected.m[h].equivalent_idle_piles, 0) }}</b></div>
              <div><em>模型版本</em><b>{{ modelText('load', h) }}</b></div>
            </div>
          </div>
          <div class="fc-detail__foot">
            负荷率 = 电量 /（装机容量 × 1h）；占用率按充电时长口径统计，等效桩数不是实时空闲桩。
          </div>
        </aside>
      </div>

      <div v-if="loading && !hasData" class="loading-mask">预测数据加载中…</div>
      <div v-if="errorMessage" class="error-mask">{{ errorMessage }}</div>
    </div>
  </div>
</template>

<script setup>
import { computed, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import EChart from '../components/EChart.vue'
import PanelBox from '../components/PanelBox.vue'
import { fetchForecast } from '../api'
import {
  baseGrid,
  barGradient,
  categoryAxis,
  initTheme,
  persistTheme,
  theme,
  toggleTheme,
  tooltipStyle,
  valueAxis
} from '../utils/echartsTheme'

const DESIGN_WIDTH = 1920
const DESIGN_HEIGHT = 1080
const HORIZONS = ['1h', '6h', '24h']

initTheme()

watch(
  () => theme.mode,
  (mode) => {
    document.documentElement.dataset.theme = mode
  },
  { immediate: true }
)

const payload = ref(null)
const loading = ref(true)
const errorMessage = ref('')
const now = ref('')
const viewport = ref({ width: DESIGN_WIDTH, height: DESIGN_HEIGHT })
const search = ref('')
const congestion = ref('all')
const horizon = ref('all')
const sortKey = ref('1h.load_kw')
const sortDir = ref('desc')
const selectedId = ref(null)
const page = ref(1)
const pageSize = ref(50)
const peakHorizon = ref('1h')

let clockTimer = null
let refreshTimer = null
let resizeHandler = null

const isLight = computed(() => theme.mode === 'light')
const hasData = computed(() => Boolean(payload.value && (payload.value.stations || []).length))
const meta = computed(() => payload.value || {})
const sourceKind = computed(() => String(meta.value.source_kind || '').toUpperCase())

const congestionOptions = [
  { value: 'all', label: '全部站点' },
  { value: 'busy', label: '偏忙以上' },
  { value: 'high', label: '仅拥堵' }
]

const horizonOptions = [
  { value: 'all', label: '三窗口总览' },
  { value: '1h', label: 'H1' },
  { value: '6h', label: 'H6' },
  { value: '24h', label: 'H24' }
]

const congestionWeight = { low: 0, medium: 1, high: 2 }

function num(value) {
  const parsed = Number(value)
  return Number.isFinite(parsed) ? parsed : 0
}

function fmtNum(value, digits = 1) {
  if (value === null || value === undefined || value === '') return '--'
  const parsed = Number(value)
  if (!Number.isFinite(parsed)) return '--'
  return parsed.toFixed(digits)
}

function fmtPct(ratio) {
  if (ratio === null || ratio === undefined || ratio === '') return '--'
  const parsed = Number(ratio)
  if (!Number.isFinite(parsed)) return '--'
  return `${(parsed * 100).toFixed(1)}%`
}

function fmtTime(value) {
  if (!value) return '--'
  return String(value).replace('T', ' ').slice(0, 16)
}

function fmtRange(start, end) {
  if (!start || !end) return '--'
  const short = (value) => String(value).slice(11, 16)
  const day = String(start).slice(5, 10)
  return `${day} ${short(start)}–${short(end)}`
}

function congestionText(level) {
  return { low: '空闲', medium: '偏忙', high: '拥堵' }[level] || '--'
}

function warningText(level) {
  return { normal: '正常', watch: '关注', warning: '预警', urgent: '紧急' }[level] || level || '--'
}

function modelText(target, key) {
  const models = meta.value.models || {}
  const group = models[target] || {}
  if (key) return group[key] || '--'
  return HORIZONS.map((h) => `${h.toUpperCase()} ${group[h] || '--'}`).join(' / ')
}

/** 小徽标里只放版本号主干（如 v1.1_plus_v1.4_deadband -> v1.1），完整值放在 title 与明细卡里。 */
function compactVersion(value) {
  const text = String(value || '--')
  return text.split('_')[0] || text
}

function compactModels(target) {
  const group = (meta.value.models || {})[target] || {}
  return HORIZONS.map((h) => `${h.toUpperCase()} ${compactVersion(group[h])}`).join(' · ')
}

const freezeShort = computed(() => {
  const id = String(meta.value.model_freeze_id || '')
  if (!id) return '--'
  const date = id.match(/\d{8}/)
  return date ? date[0] : id.length > 14 ? `${id.slice(0, 14)}…` : id
})

const versionShort = computed(() =>
  String(meta.value.data_version || '--').replace(/^charging-(screen-)?/, '')
)

const runShort = computed(() => {
  const id = String(meta.value.run_id || '--')
  return id.length > 18 ? `${id.slice(0, 18)}…` : id
})

const ageSeconds = computed(() => {
  const value = meta.value.age_seconds
  if (Number.isFinite(Number(value))) return Number(value)
  const cutoff = meta.value.data_cutoff_time
  if (!cutoff) return null
  const parsed = Date.parse(String(cutoff).replace(' ', 'T'))
  if (Number.isNaN(parsed)) return null
  return Math.max(0, Math.round((Date.now() - parsed) / 1000))
})

const ageText = computed(() => {
  if (ageSeconds.value === null) return '--'
  const minutes = Math.round(ageSeconds.value / 60)
  if (minutes < 60) return `${minutes} 分钟`
  const hours = Math.floor(minutes / 60)
  return `${hours} 小时 ${minutes % 60} 分`
})

const ageClass = computed(() => {
  if (meta.value.stale) return 'chip--danger'
  return ageSeconds.value !== null && ageSeconds.value > 3600 ? 'chip--gold' : 'chip--green'
})

const rows = computed(() =>
  (meta.value.stations || []).map((station) => {
    const metrics = {}
    HORIZONS.forEach((h) => {
      metrics[h] = (station.forecast || {})[h] || {}
    })
    return {
      id: station.station_id,
      name: station.station_name || `站点${station.station_id}`,
      status: station.status || 'ok',
      piles: num((station.capacity || {}).total_piles),
      capacity: num((station.capacity || {}).station_capacity_kw),
      congestion: ((station.business_status || {}).congestion_level || 'low'),
      warning: ((station.business_status || {}).warning_level || 'normal'),
      m: metrics
    }
  })
)

const filteredRows = computed(() => {
  const keyword = search.value.trim().toLowerCase()
  return rows.value.filter((row) => {
    if (keyword && !`${row.name} ${row.id}`.toLowerCase().includes(keyword)) return false
    if (congestion.value === 'busy' && congestionWeight[row.congestion] < 1) return false
    if (congestion.value === 'high' && row.congestion !== 'high') return false
    return true
  })
})

function valueOf(row, key) {
  if (key === 'name') return row.name
  if (key === 'piles') return row.piles
  if (key === 'capacity') return row.capacity
  if (key === 'congestion') return congestionWeight[row.congestion] ?? 0
  const [h, field] = key.split('.')
  return num((row.m[h] || {})[field])
}

const sortedRows = computed(() => {
  const list = [...filteredRows.value]
  const dir = sortDir.value === 'asc' ? 1 : -1
  list.sort((a, b) => {
    const left = valueOf(a, sortKey.value)
    const right = valueOf(b, sortKey.value)
    if (typeof left === 'string' || typeof right === 'string') {
      return String(left).localeCompare(String(right), 'zh-CN') * dir
    }
    if (left === right) return a.id - b.id
    return (left - right) * dir
  })
  return list
})

const pageCount = computed(() => Math.max(1, Math.ceil(sortedRows.value.length / pageSize.value)))
const pageStart = computed(() => (page.value - 1) * pageSize.value)
const pageEnd = computed(() => Math.min(sortedRows.value.length, pageStart.value + pageSize.value))
const pageRangeText = computed(() =>
  sortedRows.value.length ? `${pageStart.value + 1}-${pageEnd.value}` : '0'
)
const visibleRows = computed(() => sortedRows.value.slice(pageStart.value, pageEnd.value))
const columnCount = computed(() => (horizon.value === 'all' ? 14 : 12))
const selected = computed(() => rows.value.find((row) => row.id === selectedId.value) || null)

const tableSubtitle = computed(
  () => `${sortedRows.value.length} / ${rows.value.length} 个站点 · 点击行查看三窗口明细`
)

// 翻页 / 改筛选后回到第一页，避免停留在空白页
watch([search, congestion, horizon, sortKey, sortDir, pageSize], () => {
  page.value = 1
})

function goPage(target) {
  page.value = Math.min(Math.max(1, target), pageCount.value)
}

function metricKey(h, field) {
  return `${h}.${field}`
}

function sortBy(key) {
  if (sortKey.value === key) {
    sortDir.value = sortDir.value === 'desc' ? 'asc' : 'desc'
    return
  }
  sortKey.value = key
  sortDir.value = key === 'name' ? 'asc' : 'desc'
}

function sortMark(key) {
  if (sortKey.value !== key) return ''
  return sortDir.value === 'desc' ? ' ▼' : ' ▲'
}

function barWidth(ratio) {
  return `${Math.min(100, Math.max(0, num(ratio) * 100))}%`
}

function barColor(ratio) {
  const value = num(ratio)
  if (value >= 0.8) return theme.danger
  if (value >= 0.5) return theme.warn
  return theme.accent
}

const averages = computed(() => {
  const result = {}
  HORIZONS.forEach((h) => {
    const list = rows.value
    const mean = (field) =>
      list.length ? list.reduce((sum, row) => sum + num((row.m[h] || {})[field]), 0) / list.length : 0
    result[h] = { load_ratio: mean('load_ratio'), occupancy_ratio: mean('occupancy_ratio') }
  })
  return result
})

const kpis = computed(() => {
  const list = rows.value
  const busy = list.filter((row) => congestionWeight[row.congestion] >= 1).length
  const high = list.filter((row) => row.congestion === 'high').length
  const total = (h, field) => list.reduce((sum, row) => sum + num((row.m[h] || {})[field]), 0)
  const window = (h) => fmtRange((list[0]?.m[h] || {}).target_start, (list[0]?.m[h] || {}).target_end)
  const peak = peakHorizon.value
  return [
    { label: '批次站点数', value: String(list.length), note: `桩 ${list.reduce((s, r) => s + r.piles, 0)} 台`, color: theme.accent },
    { label: `${peak.toUpperCase()} 平均负荷率`, value: fmtPct(averages.value[peak].load_ratio), note: `负荷最高窗口 ${window(peak)}`, color: theme.purple },
    { label: `${peak.toUpperCase()} 合计预测负荷`, value: `${fmtNum(total(peak, 'load_kw'), 1)} kW`, note: `等效占用桩 ${fmtNum(total(peak, 'equivalent_occupied_piles'), 0)} 台`, color: theme.accent2 },
    { label: `${peak.toUpperCase()} 平均占用率`, value: fmtPct(averages.value[peak].occupancy_ratio), note: '充电时长口径', color: theme.success },
    ...HORIZONS.map((h, index) => ({
      label: `${h.toUpperCase()} 合计负荷`,
      value: `${fmtNum(total(h, 'load_kw'), 1)} kW`,
      note: window(h),
      color: [theme.warn, theme.orange, theme.danger][index]
    })),
    { label: '偏忙以上站点', value: String(busy), note: `其中拥堵 ${high} 个`, color: busy ? theme.danger : theme.success }
  ]
})

const topOption = computed(() => {
  const ranked = [...rows.value].sort((a, b) => num(a.m['1h'].load_kw) - num(b.m['1h'].load_kw)).slice(-10)
  const names = ranked.map((row) => {
    const text = String(row.name)
    return text.length > 11 ? `${text.slice(0, 11)}…` : text
  })
  return {
    grid: { left: 112, right: 26, top: 34, bottom: 18 },
    tooltip: tooltipStyle({ axisPointer: { type: 'shadow' } }),
    legend: {
      top: 2,
      left: 'center',
      itemWidth: 9,
      itemHeight: 7,
      itemGap: 12,
      textStyle: { color: theme.subTextColor, fontSize: 10 },
      data: HORIZONS.map((h) => `${h.toUpperCase()} 负荷`)
    },
    xAxis: valueAxis({ axisLabel: { color: theme.textColor, fontSize: 10 } }),
    yAxis: {
      type: 'category',
      data: names,
      axisLine: { lineStyle: { color: theme.axisLineColor } },
      axisTick: { show: false },
      axisLabel: { color: theme.textColor, fontSize: 10 }
    },
    series: HORIZONS.map((h, index) => ({
      name: `${h.toUpperCase()} 负荷`,
      type: 'bar',
      barWidth: 6,
      itemStyle: { borderRadius: [0, 3, 3, 0], color: barGradient(theme.palette[index], false) },
      data: ranked.map((row) => Number(num(row.m[h].load_kw).toFixed(2)))
    }))
  }
})

const avgOption = computed(() => {
  const sample = rows.value[0] || { m: {} }
  const categories = HORIZONS.map((h) => `${h.toUpperCase()} ${fmtRange((sample.m[h] || {}).target_start, (sample.m[h] || {}).target_end)}`)
  return {
    grid: { ...baseGrid, left: 42, right: 26, top: 36, bottom: 26 },
    tooltip: tooltipStyle({ valueFormatter: (value) => `${value}%` }),
    legend: {
      top: 2,
      left: 'center',
      itemWidth: 9,
      itemHeight: 7,
      itemGap: 12,
      textStyle: { color: theme.subTextColor, fontSize: 10 },
      data: ['平均负荷率', '平均占用率']
    },
    xAxis: categoryAxis(categories, { axisLabel: { color: theme.textColor, fontSize: 10 } }),
    yAxis: valueAxis({ max: 100, axisLabel: { color: theme.textColor, fontSize: 10, formatter: '{value}%' } }),
    series: [
      {
        name: '平均负荷率',
        type: 'bar',
        barWidth: '26%',
        itemStyle: { borderRadius: [4, 4, 0, 0], color: barGradient(theme.accent) },
        data: HORIZONS.map((h) => Number((averages.value[h].load_ratio * 100).toFixed(1)))
      },
      {
        name: '平均占用率',
        type: 'bar',
        barWidth: '26%',
        itemStyle: { borderRadius: [4, 4, 0, 0], color: barGradient(theme.accent2) },
        data: HORIZONS.map((h) => Number((averages.value[h].occupancy_ratio * 100).toFixed(1)))
      }
    ]
  }
})

const stageStyle = computed(() => {
  const scale = Math.min(viewport.value.width / DESIGN_WIDTH, viewport.value.height / DESIGN_HEIGHT)
  return {
    transform: `scale(${scale})`,
    left: `${(viewport.value.width - DESIGN_WIDTH * scale) / 2}px`,
    top: `${(viewport.value.height - DESIGN_HEIGHT * scale) / 2}px`
  }
})

function tick() {
  const d = new Date()
  const pad = (n) => String(n).padStart(2, '0')
  now.value = `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())} ${pad(d.getHours())}:${pad(d.getMinutes())}:${pad(d.getSeconds())}`
}

function toggle() {
  persistTheme(toggleTheme())
}

async function load(manual = false) {
  loading.value = true
  try {
    payload.value = await fetchForecast()
    pickupDefaultSort(payload.value.stations || [])
    errorMessage.value = ''
  } catch (err) {
    errorMessage.value = manual
      ? `预测接口异常：${err.message}`
      : `未取到预测批次：${err.message}（请确认后端已挂载 ml 预测蓝图，或 ml/fixtures 下存在批次 JSON）`
  } finally {
    loading.value = false
  }
}

/**
 * 批次里不同目标小时的信号强度差别很大（例如凌晨/上午的 H1 可能整批为 0），
 * 所以默认按"合计负荷最高"的那个窗口排序，避免一进页面全是 0 的观感。
 */
function pickupDefaultSort(stations) {
  const totals = {}
  HORIZONS.forEach((h) => {
    totals[h] = stations.reduce((sum, station) => sum + num(((station.forecast || {})[h] || {}).load_kw), 0)
  })
  const best = HORIZONS.reduce((a, b) => (totals[b] > totals[a] ? b : a), HORIZONS[0])
  if (totals[best] > 0) {
    peakHorizon.value = best
    sortKey.value = metricKey(best, 'load_kw')
    sortDir.value = 'desc'
  }
}

function exportCsv() {
  const header = ['站点编号', '站点名称', '桩数', '装机容量kW', 'H1时段', 'H1负荷kW', 'H1负荷率', 'H1占用率', 'H6时段', 'H6负荷kW', 'H6负荷率', 'H6占用率', 'H24时段', 'H24负荷kW', 'H24负荷率', 'H24占用率', '拥堵等级', '状态']
  const lines = [header]
  visibleRows.value.forEach((row) => {
    const line = [row.id, row.name, row.piles, row.capacity]
    HORIZONS.forEach((h) => {
      const item = row.m[h] || {}
      line.push(fmtRange(item.target_start, item.target_end), num(item.load_kw).toFixed(2), fmtPct(item.load_ratio), fmtPct(item.occupancy_ratio))
    })
    line.push(congestionText(row.congestion), row.status)
    lines.push(line)
  })
  const csv = lines.map((line) => line.map((cell) => `"${String(cell).replace(/"/g, '""')}"`).join(',')).join('\r\n')
  const blob = new Blob([`\uFEFF${csv}`], { type: 'text/csv;charset=utf-8' })
  const url = URL.createObjectURL(blob)
  const link = document.createElement('a')
  link.href = url
  link.download = `充电负荷预测_${String(meta.value.data_cutoff_time || '').replace(/[-:T]/g, '')}.csv`
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)
  URL.revokeObjectURL(url)
}

onMounted(async () => {
  tick()
  clockTimer = setInterval(tick, 1000)
  await load()
  refreshTimer = setInterval(() => load(), 60000)
  resizeHandler = () => {
    viewport.value = { width: window.innerWidth, height: window.innerHeight }
  }
  resizeHandler()
  window.addEventListener('resize', resizeHandler)
})

onBeforeUnmount(() => {
  clearInterval(clockTimer)
  clearInterval(refreshTimer)
  window.removeEventListener('resize', resizeHandler)
})
</script>

<style scoped>
.viewport {
  width: 100vw;
  height: 100vh;
  overflow: hidden;
  position: relative;
}

.stage {
  position: absolute;
  width: 1920px;
  height: 1080px;
  padding: 12px 18px 14px;
  box-sizing: border-box;
  transform-origin: left top;
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.stage-grid {
  position: absolute;
  inset: 0;
  background-image: linear-gradient(rgba(0, 160, 255, 0.045) 1px, transparent 1px),
    linear-gradient(90deg, rgba(0, 160, 255, 0.045) 1px, transparent 1px);
  background-size: 48px 48px;
  pointer-events: none;
}

/* 标题栏 */
.fc-head {
  position: relative;
  height: 52px;
  display: flex;
  align-items: center;
  gap: 16px;
  flex: none;
}

.fc-back {
  padding: 5px 14px;
  border-radius: 12px;
  border: 1px solid var(--toggle-border);
  background: var(--toggle-bg);
  color: var(--toggle-text);
  font-size: 12px;
  text-decoration: none;
  white-space: nowrap;
  transition: all 0.2s ease;
}

.fc-back:hover {
  border-color: var(--toggle-hover-border);
  transform: translateY(-1px);
}

.fc-titles {
  flex: 1;
  min-width: 0;
}

.fc-title {
  font-size: 26px;
  font-weight: 700;
  letter-spacing: 4px;
  background: var(--title-gradient);
  -webkit-background-clip: text;
  background-clip: text;
  color: transparent;
  text-shadow: var(--title-shadow);
  white-space: nowrap;
}

.fc-subtitle {
  margin-top: 2px;
  font-size: 12px;
  letter-spacing: 1px;
  color: var(--panel-sub);
  white-space: nowrap;
}

.fc-head__right {
  display: flex;
  align-items: center;
  gap: 10px;
  flex: none;
}

.fc-clock {
  font-size: 12px;
  letter-spacing: 1px;
  color: var(--clock-text);
  white-space: nowrap;
}

.fc-btn {
  display: inline-flex;
  align-items: center;
  gap: 5px;
  padding: 5px 14px;
  border-radius: 12px;
  border: 1px solid var(--toggle-border);
  background: var(--toggle-bg);
  color: var(--toggle-text);
  font-size: 12px;
  font-family: inherit;
  cursor: pointer;
  white-space: nowrap;
  transition: all 0.2s ease;
}

.fc-btn:hover:not(:disabled) {
  border-color: var(--toggle-hover-border);
  transform: translateY(-1px);
}

.fc-btn:disabled {
  opacity: 0.6;
  cursor: default;
}

.fc-btn--small {
  padding: 3px 10px;
}

/* 批次信息 */
.fc-meta {
  display: flex;
  align-items: center;
  gap: 8px;
  flex: none;
  height: 26px;
  overflow: hidden;
}

.chip {
  padding: 3px 10px;
  border-radius: 12px;
  border: 1px solid var(--chip-border);
  color: var(--chip-text);
  background: var(--chip-bg);
  font-size: 12px;
  white-space: nowrap;
}

.chip--green {
  border-color: var(--chip-green-border);
  color: var(--chip-green-text);
}

.chip--gold {
  border-color: var(--chip-gold-border);
  color: var(--chip-gold-text);
}

.chip--danger {
  border-color: rgba(255, 122, 89, 0.65);
  color: #ffb2a0;
}

/* KPI */
.fc-kpis {
  display: grid;
  grid-template-columns: repeat(8, 1fr);
  gap: 8px;
  height: 92px;
  flex: none;
}

.fc-kpi {
  border: 1px solid var(--kpi-border);
  border-radius: 6px;
  background: var(--kpi-bg);
  box-shadow: var(--kpi-shadow);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 2px;
  position: relative;
  overflow: hidden;
}

.fc-kpi::after {
  content: '';
  position: absolute;
  left: 0;
  right: 0;
  bottom: 0;
  height: 2px;
  background: var(--kpi-underline);
}

.fc-kpi__label {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 12px;
  color: var(--kpi-label);
}

.fc-dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
}

.fc-kpi__value {
  font-size: 21px;
  font-weight: 700;
  letter-spacing: 1px;
  text-shadow: var(--title-shadow);
}

.fc-kpi__note {
  font-size: 11px;
  color: var(--kpi-note);
}

/* 图表 */
.fc-charts {
  display: grid;
  grid-template-columns: 1.25fr 1fr;
  gap: 10px;
  height: 258px;
  flex: none;
}

/* 明细表 */
.fc-table-row {
  flex: 1;
  min-height: 0;
  display: flex;
  gap: 10px;
}

.fc-table-card {
  flex: 1;
  min-width: 0;
}

.fc-panel-body {
  height: 100%;
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.fc-tools {
  display: flex;
  align-items: center;
  gap: 8px;
  flex: none;
}

.fc-tools__spacer {
  flex: 1;
}

.fc-input {
  width: 190px;
  padding: 3px 10px;
  border-radius: 12px;
  border: 1px solid var(--chip-border);
  background: var(--chip-bg);
  color: var(--panel-text);
  font-size: 12px;
  font-family: inherit;
  outline: none;
}

.fc-input::placeholder {
  color: var(--panel-sub);
}

.fc-seg {
  display: inline-flex;
  border-radius: 12px;
  border: 1px solid var(--chip-border);
  overflow: hidden;
}

.fc-seg button {
  padding: 3px 10px;
  border: none;
  background: transparent;
  color: var(--panel-sub);
  font-size: 12px;
  font-family: inherit;
  cursor: pointer;
  white-space: nowrap;
}

.fc-seg button + button {
  border-left: 1px solid var(--chip-border);
}

.fc-seg button.is-active {
  background: var(--chip-border);
  color: var(--panel-title);
}

.fc-table-scroll {
  flex: 1;
  min-height: 0;
  overflow-y: auto;
}

.fc-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 12px;
}

.fc-table thead th {
  position: sticky;
  top: 0;
  z-index: 1;
  padding: 5px 6px;
  background: var(--table-head-bg);
  color: var(--panel-title);
  font-weight: 600;
  text-align: left;
  white-space: nowrap;
  border-bottom: 1px solid var(--chip-border);
}

.fc-th-sort {
  cursor: pointer;
  user-select: none;
}

.fc-table tbody td {
  padding: 4px 6px;
  border-bottom: 1px solid var(--table-line);
  color: var(--panel-text);
  white-space: nowrap;
}

.fc-table tbody tr {
  cursor: pointer;
}

.fc-table tbody tr:nth-child(even) {
  background: var(--table-row-alt);
}

.fc-table tbody tr:hover {
  background: var(--table-row-hover);
}

.fc-table tbody tr.is-selected {
  background: var(--table-row-active);
}

.fc-num {
  text-align: right;
}

.fc-strong {
  color: var(--panel-title);
  font-weight: 600;
}

.fc-time {
  color: var(--kpi-note);
}

.fc-td-name {
  max-width: 200px;
}

.fc-name {
  color: var(--panel-title);
}

.fc-id {
  margin-left: 6px;
  font-size: 11px;
  color: var(--panel-sub);
}

.fc-bar-cell {
  display: inline-flex;
  align-items: center;
  justify-content: flex-end;
  gap: 6px;
}

.fc-loadbar {
  display: inline-block;
  height: 6px;
  min-width: 2px;
  border-radius: 3px;
  opacity: 0.85;
}

.fc-badge {
  padding: 1px 8px;
  border-radius: 10px;
  font-size: 11px;
  border: 1px solid var(--chip-border);
  color: var(--chip-text);
}

.fc-badge--low {
  border-color: var(--chip-green-border);
  color: var(--chip-green-text);
}

.fc-badge--medium {
  border-color: var(--chip-gold-border);
  color: var(--chip-gold-text);
}

.fc-badge--high {
  border-color: rgba(255, 122, 89, 0.65);
  color: #ffb2a0;
}

.fc-status.is-ok {
  color: var(--chip-green-text);
}

.fc-status.is-bad {
  color: #ffb2a0;
}

.fc-none {
  padding: 18px;
  text-align: center;
  color: var(--panel-sub);
}

.fc-pager {
  display: flex;
  align-items: center;
  gap: 6px;
  flex: none;
  font-size: 12px;
}

.fc-pager__info {
  color: var(--panel-sub);
}

/* 站点明细 */
.fc-detail {
  width: 372px;
  flex: none;
  border: 1px solid var(--chip-border);
  border-radius: 8px;
  background: var(--kpi-bg);
  box-shadow: var(--kpi-shadow);
  padding: 10px 12px;
  box-sizing: border-box;
  display: flex;
  flex-direction: column;
  gap: 8px;
  overflow-y: auto;
}

.fc-detail__head {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 8px;
}

.fc-detail__name {
  font-size: 16px;
  font-weight: 700;
  color: var(--panel-title);
}

.fc-detail__id {
  margin-top: 2px;
  font-size: 11px;
  color: var(--panel-sub);
}

.fc-close {
  width: 26px;
  height: 26px;
  border-radius: 50%;
  border: 1px solid var(--toggle-border);
  background: var(--toggle-bg);
  color: var(--toggle-text);
  font-size: 13px;
  cursor: pointer;
}

.fc-detail__facts {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 4px 8px;
  font-size: 12px;
  color: var(--kpi-note);
}

.fc-detail__block {
  border: 1px solid var(--kpi-border);
  border-radius: 6px;
  padding: 6px 8px;
  background: rgba(0, 228, 255, 0.05);
}

.fc-detail__block-head {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  margin-bottom: 4px;
}

.fc-detail__horizon {
  font-size: 14px;
  font-weight: 700;
  color: var(--kpi-label);
}

.fc-detail__window {
  font-size: 11px;
  color: var(--panel-sub);
}

.fc-detail__grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 3px 8px;
  font-size: 12px;
}

.fc-detail__grid em {
  font-style: normal;
  color: var(--panel-sub);
}

.fc-detail__grid b {
  margin-left: 5px;
  color: var(--panel-title);
}

.fc-detail__foot {
  margin-top: auto;
  font-size: 11px;
  line-height: 1.5;
  color: var(--panel-sub);
}

.fc-empty {
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--panel-sub);
  font-size: 13px;
}

.loading-mask,
.error-mask {
  position: absolute;
  left: 50%;
  top: 50%;
  transform: translate(-50%, -50%);
  padding: 10px 22px;
  border-radius: 6px;
  border: 1px solid rgba(0, 228, 255, 0.45);
  background: rgba(4, 20, 40, 0.85);
  color: #cfe9ff;
  font-size: 14px;
  letter-spacing: 1px;
}

.error-mask {
  top: auto;
  bottom: 24px;
  transform: translateX(-50%);
  border-color: rgba(255, 122, 89, 0.6);
  color: #ffb2a0;
}
</style>
