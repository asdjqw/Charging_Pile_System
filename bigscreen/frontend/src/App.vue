<template>
  <ForecastView v-if="route === 'forecast'" />
  <Screen v-else />
</template>

<script setup>
import { onBeforeUnmount, onMounted, ref } from 'vue'
import ForecastView from './views/ForecastView.vue'
import Screen from './views/Screen.vue'

/**
 * 极简 hash 路由：#/forecast 打开「充电负荷智能预测」页，其它情况都是分析大屏。
 * 用 hash 而不是 vue-router，是为了不打乱大屏原有的 ?theme= / ?detail= 查询参数。
 */
function currentRoute() {
  return window.location.hash.replace(/^#\/?/, '').trim().toLowerCase()
}

const route = ref(currentRoute())

function onHashChange() {
  route.value = currentRoute()
}

onMounted(() => window.addEventListener('hashchange', onHashChange))
onBeforeUnmount(() => window.removeEventListener('hashchange', onHashChange))
</script>
