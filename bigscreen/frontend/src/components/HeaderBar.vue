<template>
  <div class="header">
    <dv-decoration-8 class="header__deco-left" :color="theme.panelBorder" />
    <dv-decoration-8 class="header__deco-right" :color="theme.panelBorder" :reverse="true" />
    <div class="header__left">
      <span class="chip chip--blue">数据源 {{ dataSource.toUpperCase() }}</span>
      <span class="chip chip--green">清洗记录 {{ qualityText }}</span>
      <a class="nav-link" href="#/forecast" title="打开充电负荷智能预测页">📈 负荷预测</a>
    </div>
    <div class="header__center">
      <div class="header__title">北京市充电桩运营数据可视化大屏</div>
      <div class="header__subtitle">Charging Pile Operation Analysis · {{ rangeText }}</div>
    </div>
    <div class="header__right">
      <button class="theme-toggle" type="button" @click="onToggleTheme">
        <span class="theme-toggle__icon">{{ isLight ? '🌙' : '☀' }}</span>
        <span>{{ isLight ? '暗色主题' : '亮色主题' }}</span>
      </button>
      <span class="clock">{{ now }}</span>
      <span class="chip chip--blue">更新 {{ updatedAt || '--' }}</span>
      <span v-if="pipeline.engine" class="chip chip--gold">计算 {{ engineText }}</span>
      <span v-if="pipeline.storage" class="chip chip--gold">存储 {{ storageText }}</span>
    </div>
  </div>
</template>

<script setup>
import { computed, onBeforeUnmount, onMounted, ref } from 'vue'
import { persistTheme, theme, toggleTheme } from '../utils/echartsTheme'

const props = defineProps({
  overview: { type: Object, default: () => ({}) },
  quality: { type: Array, default: () => [] },
  pipeline: { type: Object, default: () => ({}) },
  updatedAt: { type: String, default: '' },
  dataSource: { type: String, default: 'mysql' }
})

const now = ref('')
let timer = null

const isLight = computed(() => theme.mode === 'light')

// 顶部右侧空间有限，这里把引擎/存储描述压短，避免与标题挤在一起
const engineText = computed(() => String(props.pipeline.engine || '').replace('Spark on ', '').replace('Spark ', '') || '--')
const storageText = computed(() => String(props.pipeline.storage || '').split(' ')[0] || '--')

function onToggleTheme() {
  persistTheme(toggleTheme())
}

function tick() {
  const d = new Date()
  const pad = (n) => String(n).padStart(2, '0')
  const week = ['日', '一', '二', '三', '四', '五', '六'][d.getDay()]
  now.value = `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())} 星期${week} ${pad(d.getHours())}:${pad(d.getMinutes())}:${pad(d.getSeconds())}`
}

onMounted(() => {
  tick()
  timer = setInterval(tick, 1000)
})
onBeforeUnmount(() => clearInterval(timer))

const rangeText = computed(() =>
  props.overview.start_date ? `${props.overview.start_date} ~ ${props.overview.end_date}` : '数据统计区间加载中'
)

const qualityText = computed(() => {
  const raw = props.quality.find((q) => q.stage === '原始订单记录')
  const valid = props.quality.find((q) => q.stage === '有效订单记录')
  if (!raw || !valid) return '--'
  return `${raw.cnt} → ${valid.cnt}`
})
</script>

<style scoped>
.header {
  position: relative;
  height: 76px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  padding: 0 12px;
  box-sizing: border-box;
}

/*
 * 左右装饰线只占标题栏顶部的一条窄带：
 * dv-decoration-8 的横线画在容器高度的一半处，之前 40px 高会把横线落在两侧
 * 小字（数据源 / 清洗记录 / 更新 / 主题按钮）正中，视觉上"被蓝线挡住"。
 * 这里把高度压到 18px 并钉在顶部，横线整体落在小字上方。
 */
.header__deco-left,
.header__deco-right {
  position: absolute;
  top: 0;
  width: 168px;
  height: 18px;
  opacity: 0.7;
  pointer-events: none;
  z-index: 0;
}

.header__deco-left {
  left: 0;
}

.header__deco-right {
  right: 0;
}

.header__center {
  position: relative;
  z-index: 1;
  text-align: center;
  flex: none;
  max-width: 46%;
}

.header__title {
  font-size: 27px;
  font-weight: 700;
  letter-spacing: 4px;
  white-space: nowrap;
  background: var(--title-gradient);
  -webkit-background-clip: text;
  background-clip: text;
  color: transparent;
  text-shadow: var(--title-shadow);
}

.header__subtitle {
  white-space: nowrap;
  margin-top: 2px;
  font-size: 12px;
  letter-spacing: 2px;
  color: var(--panel-sub);
}

.header__left,
.header__right {
  position: relative;
  z-index: 1;
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 12px;
  flex: 1 1 0;
  min-width: 0;
  flex-wrap: nowrap;
  overflow: hidden;
}

.header__left {
  justify-content: flex-start;
  padding-right: 6px;
}

.header__right {
  justify-content: flex-end;
  padding-left: 6px;
  flex-direction: row-reverse;
}

.chip {
  padding: 3px 10px;
  border-radius: 12px;
  border: 1px solid var(--chip-border);
  color: var(--chip-text);
  background: var(--chip-bg);
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

.theme-toggle {
  display: inline-flex;
  align-items: center;
  gap: 5px;
  padding: 4px 12px;
  border-radius: 12px;
  border: 1px solid var(--toggle-border);
  background: var(--toggle-bg);
  color: var(--toggle-text);
  font-size: 12px;
  font-family: inherit;
  cursor: pointer;
  transition: all 0.2s ease;
  white-space: nowrap;
}

/* 大屏与预测页之间的跳转按钮（详情见 views/ForecastView.vue） */
.nav-link {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  padding: 4px 12px;
  border-radius: 12px;
  border: 1px solid var(--chip-gold-border);
  background: var(--chip-bg);
  color: var(--chip-gold-text);
  font-size: 12px;
  text-decoration: none;
  white-space: nowrap;
  transition: all 0.2s ease;
}

.nav-link:hover {
  border-color: var(--toggle-hover-border);
  transform: translateY(-1px);
}

.theme-toggle:hover {
  border-color: var(--toggle-hover-border);
  transform: translateY(-1px);
}

.theme-toggle__icon {
  font-size: 13px;
  line-height: 1;
}

.clock {
  color: var(--clock-text);
  letter-spacing: 1px;
  white-space: nowrap;
}
</style>
