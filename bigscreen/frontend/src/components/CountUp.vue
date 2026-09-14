<template>
  <span class="count-up" :style="{ color, fontSize: `${fontSize}px` }">{{ display }}</span>
</template>

<script setup>
import { computed, onBeforeUnmount, ref, watch } from 'vue'

const props = defineProps({
  value: { type: Number, default: 0 },
  decimals: { type: Number, default: 0 },
  duration: { type: Number, default: 900 },
  fontSize: { type: Number, default: 30 },
  color: { type: String, default: '#00e4ff' },
  prefix: { type: String, default: '' }
})

const current = ref(0)
let rafId = null
let timeoutId = null

function format(value) {
  const fixed = Number(value).toFixed(props.decimals)
  return props.prefix + fixed.replace(/\B(?=(\d{3})+(?!\d))/g, ',')
}

const display = computed(() => format(current.value))

function stop() {
  if (rafId) cancelAnimationFrame(rafId)
  if (timeoutId) clearTimeout(timeoutId)
  rafId = null
  timeoutId = null
}

function animate(target) {
  stop()
  const from = current.value
  const startAt = performance.now()
  const tick = (now) => {
    const progress = Math.min(1, (now - startAt) / props.duration)
    const eased = 1 - Math.pow(1 - progress, 3)
    current.value = from + (target - from) * eased
    if (progress < 1) rafId = requestAnimationFrame(tick)
    else current.value = target
  }
  rafId = requestAnimationFrame(tick)
  // 兜底：无论动画帧是否被浏览器节流，最终都展示准确数值
  timeoutId = setTimeout(() => {
    stop()
    current.value = target
  }, props.duration + 120)
}

watch(
  () => props.value,
  (target) => animate(Number(target) || 0),
  { immediate: true }
)

onBeforeUnmount(stop)
</script>

<style scoped>
.count-up {
  font-weight: 700;
  letter-spacing: 1px;
  font-family: 'DIN Alternate', 'Microsoft YaHei', sans-serif;
  text-shadow: 0 0 14px rgba(0, 228, 255, 0.45);
}
</style>
