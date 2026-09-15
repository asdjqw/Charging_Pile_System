<template>
  <div class="detail-mask" @click.self="emit('close')">
    <div class="detail-panel" :data-theme="theme.mode">
      <div class="detail-head">
        <span class="detail-deco"></span>
        <div class="detail-titles">
          <span class="detail-title">{{ title }}</span>
          <span v-if="subtitle" class="detail-subtitle">{{ subtitle }}</span>
        </div>
        <div class="detail-actions">
          <span class="detail-hint">点击空白处或按 ESC 关闭</span>
          <button class="detail-close" type="button" @click="emit('close')">✕</button>
        </div>
      </div>
      <div class="detail-body">
        <RealtimeBoard v-if="board" :sessions="sessions" :row-num="12" />
        <EChart v-else-if="option" :option="detailOption" />
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, onBeforeUnmount, onMounted } from 'vue'
import EChart from './EChart.vue'
import RealtimeBoard from './RealtimeBoard.vue'
import { theme } from '../utils/echartsTheme'
import { buildDetailOption } from '../utils/detailOption'

const props = defineProps({
  title: { type: String, required: true },
  subtitle: { type: String, default: '' },
  option: { type: Object, default: null },
  board: { type: Boolean, default: false },
  sessions: { type: Array, default: () => [] }
})

const emit = defineEmits(['close'])

const detailOption = computed(() => buildDetailOption(props.option, 1.75))

function onKeydown(event) {
  if (event.key === 'Escape') emit('close')
}

onMounted(() => window.addEventListener('keydown', onKeydown))
onBeforeUnmount(() => window.removeEventListener('keydown', onKeydown))
</script>

<style scoped>
.detail-mask {
  /* 大屏整体是 1920×1080 的缩放舞台，这里用 absolute 覆盖舞台区域即可（fixed 会被 transform 影响） */
  position: absolute;
  inset: 0;
  z-index: 999;
  background: rgba(2, 10, 22, 0.72);
  backdrop-filter: blur(2px);
  display: flex;
  align-items: center;
  justify-content: center;
  animation: fade-in 0.18s ease;
}

@keyframes fade-in {
  from {
    opacity: 0;
  }
  to {
    opacity: 1;
  }
}

.detail-panel {
  width: 92%;
  height: 88%;
  border-radius: 10px;
  border: 1px solid var(--chip-border);
  background: var(--stage-bg);
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.55);
  display: flex;
  flex-direction: column;
  padding: 14px 18px 10px;
  box-sizing: border-box;
}

.detail-head {
  display: flex;
  align-items: center;
  gap: 10px;
  flex: none;
  height: 44px;
}

.detail-deco {
  width: 6px;
  height: 22px;
  border-radius: 3px;
  background: var(--kpi-underline);
}

.detail-titles {
  display: flex;
  align-items: baseline;
  gap: 10px;
  flex: 1;
}

.detail-title {
  font-size: 24px;
  font-weight: 700;
  letter-spacing: 2px;
  color: var(--panel-title);
}

.detail-subtitle {
  font-size: 13px;
  color: var(--panel-sub);
}

.detail-actions {
  display: flex;
  align-items: center;
  gap: 12px;
}

.detail-hint {
  font-size: 12px;
  color: var(--panel-sub);
}

.detail-close {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  border: 1px solid var(--toggle-border);
  background: var(--toggle-bg);
  color: var(--toggle-text);
  font-size: 15px;
  cursor: pointer;
  transition: all 0.2s ease;
}

.detail-close:hover {
  border-color: var(--toggle-hover-border);
  transform: rotate(90deg);
}

.detail-body {
  flex: 1;
  min-height: 0;
  padding-top: 6px;
}
</style>
