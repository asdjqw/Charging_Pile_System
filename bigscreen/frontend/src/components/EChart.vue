<template>
  <div ref="container" class="echart-container"></div>
</template>

<script setup>
import { onBeforeUnmount, onMounted, ref, watch } from 'vue'
import * as echarts from 'echarts'

const props = defineProps({
  option: { type: Object, required: true },
  notMerge: { type: Boolean, default: true }
})

const container = ref(null)
let chart = null
let observer = null

function render() {
  if (!chart) return
  chart.setOption(props.option, props.notMerge)
}

onMounted(() => {
  chart = echarts.init(container.value, null, { renderer: 'canvas' })
  render()
  observer = new ResizeObserver(() => chart && chart.resize())
  observer.observe(container.value)
})

watch(() => props.option, render, { deep: true })

onBeforeUnmount(() => {
  observer && observer.disconnect()
  chart && chart.dispose()
  chart = null
})
</script>

<style scoped>
.echart-container {
  width: 100%;
  height: 100%;
}
</style>
