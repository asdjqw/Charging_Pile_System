<template>
  <div class="panel" :class="{ 'panel--clickable': clickable }" :title="clickable ? '点击查看大图详情' : ''" @click="onClick">
    <dv-border-box-12 :color="theme.panelBorder" :background-color="theme.panelBg">
      <div class="panel-inner">
        <div class="panel-head">
          <dv-decoration-2 class="panel-head__deco" :color="theme.panelBorder" />
          <span class="panel-head__title">{{ title }}</span>
          <span v-if="subtitle" class="panel-head__subtitle">{{ subtitle }}</span>
          <span v-if="clickable" class="panel-head__zoom">⤢</span>
        </div>
        <div class="panel-body">
          <slot />
        </div>
      </div>
    </dv-border-box-12>
  </div>
</template>

<script setup>
import { theme } from '../utils/echartsTheme'

const props = defineProps({
  title: { type: String, required: true },
  subtitle: { type: String, default: '' },
  clickable: { type: Boolean, default: false }
})

const emit = defineEmits(['open'])

function onClick() {
  if (props.clickable) emit('open')
}
</script>

<style scoped>
.panel {
  width: 100%;
  height: 100%;
}

.panel-inner {
  padding: 8px 12px 6px;
  height: 100%;
  box-sizing: border-box;
  display: flex;
  flex-direction: column;
}

.panel-head {
  display: flex;
  align-items: center;
  gap: 6px;
  height: 24px;
  flex: none;
  overflow: hidden;
  white-space: nowrap;
}

.panel-head__deco {
  width: 34px;
  height: 12px;
  flex: none;
}

.panel-head__title {
  font-size: 14px;
  font-weight: 600;
  letter-spacing: 0.5px;
  color: var(--panel-title);
  text-shadow: var(--title-shadow);
  flex: none;
}

.panel-head__subtitle {
  flex: 1;
  min-width: 0;
  font-size: 10px;
  color: var(--panel-sub);
  letter-spacing: 0.5px;
  overflow: hidden;
  text-overflow: ellipsis;
}

.panel-head__zoom {
  flex: none;
  font-size: 12px;
  color: var(--panel-sub);
  opacity: 0.75;
}

.panel--clickable {
  cursor: pointer;
  transition: transform 0.15s ease, filter 0.15s ease;
}

.panel--clickable:hover {
  transform: translateY(-2px);
  filter: drop-shadow(0 6px 18px rgba(0, 180, 255, 0.35));
}

.panel--clickable:hover .panel-head__zoom {
  opacity: 1;
  color: var(--panel-title);
}

.panel-body {
  flex: 1;
  min-height: 0;
  position: relative;
}
</style>
