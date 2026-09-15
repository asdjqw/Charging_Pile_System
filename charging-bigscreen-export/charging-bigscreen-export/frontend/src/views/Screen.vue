<template>
  <div class="viewport">
    <div class="stage" :style="stageStyle">
      <div class="stage-grid"></div>

      <HeaderBar
        :overview="overview"
        :quality="quality"
        :pipeline="pipeline"
        :updated-at="updatedAt"
        :data-source="dataSource"
      />

      <KpiBar :overview="overview" :facility="facility" />

      <div class="main">
        <div class="col col--side">
          <PanelBox title="月度充电量趋势" subtitle="柱:电量 线:订单">
            <EChart :option="monthlyOption" />
          </PanelBox>
          <PanelBox title="24小时充电负荷" subtitle="峰/平/谷">
            <EChart :option="hourOption" />
          </PanelBox>
          <PanelBox title="站点类型对比" subtitle="多指标对比">
            <EChart :option="facilityOption" />
          </PanelBox>
          <PanelBox title="充电时长分布" subtitle="玫瑰图">
            <EChart :option="durationOption" />
          </PanelBox>
        </div>

        <div class="col col--center">
          <PanelBox title="日充电量与订单趋势" subtitle="近90天 · 双轴">
            <EChart :option="dailyOption" />
          </PanelBox>
          <div class="center-row">
            <PanelBox title="星期 × 小时充电热度" subtitle="订单分布热力图">
              <EChart :option="heatOption" />
            </PanelBox>
            <PanelBox title="站点充电量TOP10" subtitle="单位 kWh">
              <EChart :option="stationOption" />
            </PanelBox>
          </div>
        </div>

        <div class="col col--side">
          <PanelBox title="工作日 vs 周末" subtitle="日均维度">
            <EChart :option="weekendOption" />
          </PanelBox>
          <PanelBox title="充电平台对比" subtitle="iOS/安卓/Web">
            <EChart :option="platformOption" />
          </PanelBox>
          <PanelBox title="用户价值分层" subtitle="RFM 模型">
            <EChart :option="segmentOption" />
          </PanelBox>
          <PanelBox title="电池健康画像" subtitle="SOC/压差/温升">
            <EChart :option="batteryOption" />
          </PanelBox>
        </div>
      </div>

      <div class="bottom">
        <PanelBox title="峰平谷时段对比" subtitle="充电量漏斗" :color="['#0f5f9c', '#ffb45c']">
          <EChart :option="periodOption" />
        </PanelBox>
        <PanelBox title="单次充电量分布" subtitle="订单数 / 占比" :color="['#3f2c8f', '#a48bff']">
          <EChart :option="energyOption" />
        </PanelBox>
        <PanelBox title="行政区充电量分布" subtitle="TOP6 行政区" :color="['#0d6b55', '#3ff0b0']">
          <dv-conical-column-chart
            v-if="conicalConfig.data.length"
            :config="conicalConfig"
            :style="{ width: '100%', height: '100%' }"
          />
        </PanelBox>
        <PanelBox title="收入结构与付费率" subtitle="按站点类型" :color="['#7a4a12', '#ffc857']">
          <EChart :option="revenueOption" />
        </PanelBox>
        <PanelBox title="实时充电订单流水" subtitle="最新订单滚动播放" :color="['#0b4a6f', '#37d0ff']">
          <RealtimeBoard :sessions="realtime" />
        </PanelBox>
      </div>

      <div v-if="loading" class="loading-mask">数据加载中…</div>
      <div v-if="errorMessage" class="error-mask">{{ errorMessage }}</div>
    </div>
  </div>
</template>

<script setup>
import { computed, onBeforeUnmount, onMounted, ref } from 'vue'
import EChart from '../components/EChart.vue'
import HeaderBar from '../components/HeaderBar.vue'
import KpiBar from '../components/KpiBar.vue'
import PanelBox from '../components/PanelBox.vue'
import RealtimeBoard from '../components/RealtimeBoard.vue'
import { fetchHealth, fetchScreenBundle } from '../api'
import {
  batteryHealthOption,
  dailyTrendOption,
  districtConicalConfig,
  durationRoseOption,
  energyDistOption,
  facilityRadarOption,
  hourLoadOption,
  monthlyTrendOption,
  platformOption as buildPlatformOption,
  revenueStructOption,
  stationTopOption,
  timePeriodFunnelOption,
  userSegmentOption,
  weekdayHeatOption,
  weekendOption as buildWeekendOption
} from '../charts/options'

const DESIGN_WIDTH = 1920
const DESIGN_HEIGHT = 1080

const bundle = ref({})
const updatedAt = ref('')
const loading = ref(true)
const errorMessage = ref('')
const dataSource = ref('mysql')
const viewport = ref({ width: DESIGN_WIDTH, height: DESIGN_HEIGHT })

let refreshTimer = null
let resizeHandler = null

const overview = computed(() => bundle.value.overview || {})
const quality = computed(() => bundle.value.quality || [])
const facility = computed(() => bundle.value.facility || [])
const realtime = computed(() => bundle.value.realtime || [])
const pipeline = computed(() => bundle.value.pipeline || {})

const monthlyOption = computed(() => monthlyTrendOption(bundle.value.monthlyTrend || []))
const hourOption = computed(() => hourLoadOption(bundle.value.hourLoad || []))
const facilityOption = computed(() => facilityRadarOption(facility.value))
const durationOption = computed(() => durationRoseOption(bundle.value.durationDist || []))
const dailyOption = computed(() => dailyTrendOption(bundle.value.dailyTrend || [], 90))
const heatOption = computed(() => weekdayHeatOption(bundle.value.weekdayHeat || []))
const stationOption = computed(() => stationTopOption(bundle.value.stationTop || []))
const weekendOption = computed(() => buildWeekendOption(bundle.value.weekend || []))
const platformOption = computed(() => buildPlatformOption(bundle.value.platform || []))
const segmentOption = computed(() => userSegmentOption(bundle.value.userSegment || []))
const batteryOption = computed(() => batteryHealthOption(bundle.value.batteryHealth || []))
const periodOption = computed(() => timePeriodFunnelOption(bundle.value.timePeriod || []))
const energyOption = computed(() => energyDistOption(bundle.value.energyDist || []))
const revenueOption = computed(() => revenueStructOption(bundle.value.revenueStruct || [], '站点类型'))
const conicalConfig = computed(() => districtConicalConfig(bundle.value.district || []))

const stageStyle = computed(() => {
  const scale = Math.min(viewport.value.width / DESIGN_WIDTH, viewport.value.height / DESIGN_HEIGHT)
  return {
    transform: `scale(${scale})`,
    left: `${(viewport.value.width - DESIGN_WIDTH * scale) / 2}px`,
    top: `${(viewport.value.height - DESIGN_HEIGHT * scale) / 2}px`
  }
})

async function load() {
  try {
    const { payload, updatedAt: time } = await fetchScreenBundle()
    bundle.value = payload || {}
    updatedAt.value = time || ''
    errorMessage.value = ''
  } catch (err) {
    errorMessage.value = `数据接口异常：${err.message}`
  } finally {
    loading.value = false
  }
}

onMounted(async () => {
  load()
  refreshTimer = setInterval(load, 60000)
  resizeHandler = () => {
    viewport.value = { width: window.innerWidth, height: window.innerHeight }
  }
  resizeHandler()
  window.addEventListener('resize', resizeHandler)
  try {
    const health = await fetchHealth()
    dataSource.value = health.data_source || 'mysql'
  } catch (err) {
    dataSource.value = 'csv'
  }
})

onBeforeUnmount(() => {
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
  padding: 6px 15px 8px;
  box-sizing: border-box;
  transform-origin: left top;
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.stage-grid {
  position: absolute;
  inset: 0;
  background-image: linear-gradient(rgba(0, 160, 255, 0.045) 1px, transparent 1px),
    linear-gradient(90deg, rgba(0, 160, 255, 0.045) 1px, transparent 1px);
  background-size: 48px 48px;
  pointer-events: none;
}

.main {
  flex: 1;
  display: flex;
  gap: 10px;
  min-height: 0;
}

.col {
  display: flex;
  gap: 8px;
  min-height: 0;
}

.col--side {
  width: 468px;
  flex-direction: row;
  flex-wrap: wrap;
  align-content: stretch;
}

.col--side > :deep(.panel) {
  width: 230px;
  height: calc(50% - 4px);
}

.col--center {
  flex: 1;
  flex-direction: column;
}

.col--center > :deep(.panel:first-child) {
  height: 420px;
}

.center-row {
  display: flex;
  gap: 8px;
  height: 262px;
}

.center-row > :deep(.panel:first-child) {
  width: 555px;
}

.center-row > :deep(.panel:last-child) {
  flex: 1;
}

.bottom {
  height: 168px;
  display: flex;
  gap: 10px;
}

.bottom > :deep(.panel) {
  flex: 1 1 0;
}

.bottom > :deep(.panel:nth-child(4)) {
  flex: 1.35 1 0;
}

.bottom > :deep(.panel:nth-child(5)) {
  flex: 1.95 1 0;
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
