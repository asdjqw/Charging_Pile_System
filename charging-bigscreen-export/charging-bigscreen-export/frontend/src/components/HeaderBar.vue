<template>
  <div class="header">
    <dv-decoration-8 class="header__deco-left" :color="['#00e4ff', '#3b82f6']" />
    <dv-decoration-8 class="header__deco-right" :color="['#00e4ff', '#3b82f6']" :reverse="true" />
    <div class="header__center">
      <div class="header__title">北京市充电桩运营数据可视化大屏</div>
      <div class="header__subtitle">Charging Pile Operation Analysis · {{ rangeText }}</div>
    </div>
    <div class="header__left">
      <span class="chip chip--blue">数据源 {{ dataSource.toUpperCase() }}</span>
      <span class="chip chip--green">清洗记录 {{ qualityText }}</span>
    </div>
    <div class="header__right">
      <span class="clock">{{ now }}</span>
      <span class="chip chip--blue">更新 {{ updatedAt || '--' }}</span>
      <span v-if="pipeline.engine" class="chip chip--gold">计算 {{ pipeline.engine }}</span>
      <span v-if="pipeline.storage" class="chip chip--gold">存储 {{ pipeline.storage }}</span>
    </div>
  </div>
</template>

<script setup>
import { computed, onBeforeUnmount, onMounted, ref } from 'vue'

const props = defineProps({
  overview: { type: Object, default: () => ({}) },
  quality: { type: Array, default: () => [] },
  pipeline: { type: Object, default: () => ({}) },
  updatedAt: { type: String, default: '' },
  dataSource: { type: String, default: 'mysql' }
})

const now = ref('')
let timer = null
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
  justify-content: center;
}

.header__deco-left,
.header__deco-right {
  position: absolute;
  top: 8px;
  width: 320px;
  height: 46px;
}

.header__deco-left {
  left: 8px;
}

.header__deco-right {
  right: 8px;
}

.header__center {
  text-align: center;
}

.header__title {
  font-size: 32px;
  font-weight: 700;
  letter-spacing: 6px;
  background: linear-gradient(180deg, #ffffff 10%, #7ce9ff 55%, #2aa7ff 100%);
  -webkit-background-clip: text;
  background-clip: text;
  color: transparent;
  text-shadow: 0 0 26px rgba(0, 180, 255, 0.45);
}

.header__subtitle {
  margin-top: 2px;
  font-size: 12px;
  letter-spacing: 2px;
  color: rgba(150, 205, 245, 0.85);
}

.header__left,
.header__right {
  position: absolute;
  top: 26px;
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 12px;
}

.header__left {
  left: 24px;
}

.header__right {
  right: 24px;
  flex-direction: row-reverse;
}

.chip {
  padding: 3px 10px;
  border-radius: 12px;
  border: 1px solid rgba(0, 228, 255, 0.35);
  color: #bfe9ff;
  background: rgba(6, 40, 74, 0.6);
  white-space: nowrap;
}

.chip--green {
  border-color: rgba(34, 230, 164, 0.45);
  color: #9ff5d4;
}

.chip--gold {
  border-color: rgba(255, 209, 102, 0.5);
  color: #ffe1a3;
}

.clock {
  color: #d7f2ff;
  letter-spacing: 1px;
}
</style>
