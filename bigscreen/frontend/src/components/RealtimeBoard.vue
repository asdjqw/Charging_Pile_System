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
import { theme } from '../utils/echartsTheme'

const props = defineProps({
  sessions: { type: Array, default: () => [] }
})

/** 站点名形如 "房山区·星充电汽车充电站(房山良乡店)"：去掉括号补充说明，太长再截断 */
function shortStation(name) {
  const text = String(name || '').replace(/[（(][^）)]*[）)]/g, '')
  const idx = text.indexOf('·')
  const body = idx >= 0 ? text.slice(idx + 1) : text
  return body.length > 9 ? `${body.slice(0, 9)}…` : body
}

const rows = computed(() =>
  props.sessions.map((item) => [
    (item.created_time || '').slice(5, 16),
    shortStation(item.station_name) || '--',
    String(item.facility_type_cn || '--').replace('充电站', ''),
    `${Number(item.kwh_total || 0).toFixed(2)}`,
    `${Number(item.charging_fees || 0).toFixed(2)}`,
    item.time_period || '--'
  ])
)

const config = computed(() => ({
  header: ['充电时间', '充电站', '类型', '电量', '金额', '时段'],
  data: rows.value,
  index: true,
  // 注意：DataV 滚动榜的 columnWidth 第一项对应"序号"列，后面依次是各数据列
  columnWidth: [52, 100, 132, 66, 62, 62, 56],
  align: ['center', 'center', 'left', 'center', 'right', 'right', 'center'],
  headerBGC: theme.scrollHeaderBg,
  headerHeight: 30,
  oddRowBGC: theme.scrollOddBg,
  evenRowBGC: theme.scrollEvenBg,
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
  color: var(--panel-sub);
  font-size: 13px;
}
</style>
