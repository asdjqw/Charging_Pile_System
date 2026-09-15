<template>
  <dv-scroll-board
    v-if="rows.length"
    class="realtime-board"
    :config="config"
    :style="{ width: '100%', height: '100%' }"
  />
  <div v-else class="realtime-empty">实时订单数据加载中…</div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  sessions: { type: Array, default: () => [] }
})

const rows = computed(() =>
  props.sessions.map((item) => [
    (item.created_time || '').slice(5, 16),
    item.station_name || '--',
    item.facility_type_cn || '--',
    `${Number(item.kwh_total || 0).toFixed(2)}`,
    `${Number(item.charging_fees || 0).toFixed(2)}`,
    item.time_period || '--'
  ])
)

const config = computed(() => ({
  header: ['充电时间', '充电站', '站点类型', '电量(kWh)', '金额(元)', '时段'],
  data: rows.value,
  index: true,
  columnWidth: [92, 210, 100, 76, 74, 46],
  align: ['center', 'left', 'center', 'right', 'right', 'center'],
  headerBGC: 'rgba(0, 120, 200, 0.35)',
  headerHeight: 30,
  oddRowBGC: 'rgba(6, 40, 74, 0.45)',
  evenRowBGC: 'rgba(4, 24, 48, 0.35)',
  rowNum: 4,
  waitTime: 2500,
  carousel: 'single',
  hoverPause: true
}))
</script>

<style scoped>
.realtime-board {
  font-size: 12px;
}

.realtime-empty {
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: rgba(150, 200, 240, 0.8);
  font-size: 13px;
}
</style>
