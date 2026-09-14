<template>
  <div class="kpi-bar">
    <div v-for="item in cards" :key="item.label" class="kpi-card">
      <div class="kpi-card__label">
        <i class="dot" :style="{ background: item.color }"></i>{{ item.label }}
      </div>
      <div class="kpi-card__value">
        <CountUp
          :value="item.value"
          :decimals="item.decimals"
          :color="item.color"
          :font-size="item.value >= 10000 ? 26 : 30"
        />
      </div>
      <div class="kpi-card__unit">{{ item.unit }}</div>
    </div>

    <div class="kpi-card kpi-card--ring">
      <div class="kpi-card__label"><i class="dot" :style="{ background: theme.warn }"></i>站点类型订单占比</div>
      <dv-active-ring-chart
        v-if="facilityRingData.length"
        :config="{
          data: facilityRingData,
          lineWidth: 9,
          radius: '70%',
          activeRadius: '78%',
          color: theme.palette,
          digitalFlopStyle: { fontSize: 11, fill: theme.accent },
          textColor: theme.labelText,
          digitalFlopUnit: '%',
          animationFrame: 20
        }"
        :style="{ width: '160px', height: '82px', margin: '0 auto' }"
      />
    </div>

    <div class="kpi-card kpi-card--pond">
      <div class="kpi-card__label"><i class="dot" :style="{ background: theme.accent }"></i>高价值用户电量占比</div>
      <dv-percent-pond
        :config="pondConfig"
        :style="{ width: '150px', height: '62px', margin: '0 auto' }"
      />
      <div class="kpi-card__note">高价值用户 {{ topSegmentText }}</div>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import CountUp from './CountUp.vue'
import { theme } from '../utils/echartsTheme'

const props = defineProps({
  overview: { type: Object, default: () => ({}) },
  facility: { type: Array, default: () => [] },
  segment: { type: Array, default: () => [] }
})

const num = (value) => {
  const n = Number(value)
  return Number.isFinite(n) ? n : 0
}

const cards = computed(() => {
  const o = props.overview
  return [
    { label: '累计充电量', value: num(o.total_kwh), unit: 'kWh', color: theme.accent, decimals: 0 },
    { label: '累计充电订单', value: num(o.total_sessions), unit: '单', color: theme.accent2, decimals: 0 },
    { label: '充电站数量', value: num(o.station_cnt), unit: '座', color: theme.purple, decimals: 0 },
    { label: '充电桩数量', value: num(o.device_cnt), unit: '台', color: theme.success, decimals: 0 },
    { label: '活跃充电用户', value: num(o.user_cnt), unit: '人', color: theme.warn, decimals: 0 },
    { label: '累计充电收入', value: num(o.total_revenue), unit: '元', color: theme.danger, decimals: 0 },
    { label: '平均单次充电量', value: num(o.avg_kwh), unit: 'kWh/次', color: theme.palette[6], decimals: 2 },
    { label: '平均充电时长', value: num(o.avg_hours), unit: '小时/次', color: theme.palette[7], decimals: 2 },
    { label: '付费订单占比', value: num(o.paid_rate), unit: '%', color: theme.orange, decimals: 2 }
  ]
})

const facilityRingData = computed(() =>
  props.facility
    .filter((item) => item.facility_type_cn && item.facility_type_cn !== '未知')
    .map((item) => ({
      name: String(item.facility_type_cn).replace('充电站', ''),
      value: num(item.sessions)
    }))
)

const facilityRingNote = computed(() => {
  const hit = props.facility.find((item) => item.facility_type_cn === '交直流充电站')
  return hit ? num(hit.sessions) : 0
})

// 水球图展示"高价值用户电量占比"（用户分层 RFM 结果），比设备利用率更能反映运营价值
const topSegment = computed(() => {
  const hit = props.segment.find((item) => item.segment === '高价值用户')
  if (!hit) return { kwhPct: 0, userCnt: 0, userPct: 0 }
  return { kwhPct: num(hit.kwh_pct), userCnt: num(hit.user_cnt), userPct: num(hit.user_pct) }
})

const pondConfig = computed(() => {
  return {
    value: Number(topSegment.value.kwhPct.toFixed(1)),
    lineDash: [8, 4],
    textColor: theme.accent,
    borderColor: theme.pondBorder,
    borderRadius: 6,
    fontSize: 16
  }
})

const topSegmentText = computed(
  () => `${topSegment.value.userCnt} 人（占 ${topSegment.value.userPct.toFixed(1)}%）`
)

</script>

<style scoped>
.kpi-bar {
  height: 116px;
  display: grid;
  grid-template-columns: repeat(9, 1fr) 178px 188px;
  gap: 8px;
  padding: 0 4px;
  box-sizing: border-box;
}

.kpi-card {
  position: relative;
  border: 1px solid var(--kpi-border);
  border-radius: 6px;
  background: var(--kpi-bg);
  box-shadow: var(--kpi-shadow);
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  overflow: hidden;
}

.kpi-card::after {
  content: '';
  position: absolute;
  left: 0;
  right: 0;
  bottom: 0;
  height: 2px;
  background: var(--kpi-underline);
}

.kpi-card__label {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 12px;
  color: var(--kpi-label);
  letter-spacing: 0.5px;
}

.dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  box-shadow: 0 0 8px currentColor;
}

.kpi-card__value {
  width: 100%;
  height: 38px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.kpi-card__unit {
  font-size: 11px;
  color: var(--kpi-unit);
  margin-top: -2px;
}

.kpi-card--ring,
.kpi-card--pond {
  justify-content: flex-start;
  padding-top: 6px;
}

.kpi-card--ring .kpi-card__label,
.kpi-card--pond .kpi-card__label {
  margin-bottom: 2px;
}

.kpi-card__note {
  position: absolute;
  bottom: 6px;
  left: 0;
  right: 0;
  text-align: center;
  font-size: 11px;
  color: var(--kpi-note);
}
</style>
