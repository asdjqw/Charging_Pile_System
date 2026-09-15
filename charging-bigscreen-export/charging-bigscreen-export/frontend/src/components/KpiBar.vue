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
      <div class="kpi-card__label"><i class="dot" style="background: #ffd166"></i>站点类型订单占比</div>
      <dv-active-ring-chart
        v-if="facilityRingData.length"
        :config="{
          data: facilityRingData,
          lineWidth: 9,
          radius: '70%',
          activeRadius: '78%',
          color: ['#00e4ff', '#3b82f6', '#22e6a4', '#7c5cff'],
          digitalFlopStyle: { fontSize: 11, fill: '#00e4ff' },
          textColor: '#bfe9ff',
          digitalFlopUnit: '%',
          animationFrame: 20
        }"
        :style="{ width: '160px', height: '82px', margin: '0 auto' }"
      />
    </div>

    <div class="kpi-card kpi-card--pond">
      <div class="kpi-card__label"><i class="dot" style="background: #00e4ff"></i>充电桩日均利用率</div>
      <dv-percent-pond
        :config="pondConfig"
        :style="{ width: '150px', height: '62px', margin: '0 auto' }"
      />
      <div class="kpi-card__note">桩均 {{ perDeviceText }} 单/台·天</div>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import CountUp from './CountUp.vue'

const props = defineProps({
  overview: { type: Object, default: () => ({}) },
  facility: { type: Array, default: () => [] }
})

const num = (value) => {
  const n = Number(value)
  return Number.isFinite(n) ? n : 0
}

const cards = computed(() => {
  const o = props.overview
  return [
    { label: '累计充电量', value: num(o.total_kwh), unit: 'kWh', color: '#00e4ff', decimals: 0 },
    { label: '累计充电订单', value: num(o.total_sessions), unit: '单', color: '#3b82f6', decimals: 0 },
    { label: '充电站数量', value: num(o.station_cnt), unit: '座', color: '#7c5cff', decimals: 0 },
    { label: '充电桩数量', value: num(o.device_cnt), unit: '台', color: '#22e6a4', decimals: 0 },
    { label: '活跃充电用户', value: num(o.user_cnt), unit: '人', color: '#ffd166', decimals: 0 },
    { label: '累计充电收入', value: num(o.total_revenue), unit: '元', color: '#ff7a59', decimals: 0 },
    { label: '平均单次充电量', value: num(o.avg_kwh), unit: 'kWh/次', color: '#ff4d8d', decimals: 2 },
    { label: '平均充电时长', value: num(o.avg_hours), unit: '小时/次', color: '#31d0f5', decimals: 2 },
    { label: '付费订单占比', value: num(o.paid_rate), unit: '%', color: '#ff9f68', decimals: 2 }
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

const pondConfig = computed(() => {
  const sessions = num(props.overview.total_sessions)
  const devices = num(props.overview.device_cnt) || 1
  const days = num(props.overview.active_days) || 1
  // 桩均日订单数（次/台/天），换算为相对 10 次/天的利用率百分比展示
  const perDevice = sessions / devices / days
  return {
    value: Number(Math.min(100, (perDevice / 10) * 100).toFixed(1)),
    lineDash: [8, 4],
    textColor: '#00e4ff',
    borderColor: 'rgba(0, 228, 255, 0.6)',
    borderRadius: 6,
    fontSize: 16
  }
})

const perDeviceText = computed(() => {
  const sessions = num(props.overview.total_sessions)
  const devices = num(props.overview.device_cnt) || 1
  const days = num(props.overview.active_days) || 1
  return (sessions / devices / days).toFixed(2)
})

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
  border: 1px solid rgba(0, 180, 255, 0.28);
  border-radius: 6px;
  background: linear-gradient(180deg, rgba(9, 42, 78, 0.85) 0%, rgba(5, 22, 44, 0.75) 100%);
  box-shadow: inset 0 0 24px rgba(0, 140, 255, 0.18);
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
  background: linear-gradient(90deg, transparent, rgba(0, 228, 255, 0.75), transparent);
}

.kpi-card__label {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 12px;
  color: rgba(168, 214, 250, 0.9);
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
  color: rgba(140, 190, 230, 0.8);
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
  color: rgba(150, 205, 245, 0.85);
}
</style>
