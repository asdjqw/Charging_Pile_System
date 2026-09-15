<template>
  <div class="panel">
    <dv-border-box-12 :color="color" background-color="rgba(8, 30, 58, 0.55)">
      <div class="panel-inner">
        <div class="panel-head">
          <dv-decoration-2 class="panel-head__deco" :color="color" />
          <span class="panel-head__title">{{ title }}</span>
          <span v-if="subtitle" class="panel-head__subtitle">{{ subtitle }}</span>
        </div>
        <div class="panel-body">
          <slot />
        </div>
      </div>
    </dv-border-box-12>
  </div>
</template>

<script setup>
defineProps({
  title: { type: String, required: true },
  subtitle: { type: String, default: '' },
  color: { type: Array, default: () => ['#0f5f9c', '#00e4ff'] }
})
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
  color: #e8f6ff;
  text-shadow: 0 0 12px rgba(0, 228, 255, 0.55);
  flex: none;
}

.panel-head__subtitle {
  font-size: 10px;
  color: rgba(140, 200, 245, 0.85);
  letter-spacing: 0.5px;
  overflow: hidden;
  text-overflow: ellipsis;
}

.panel-body {
  flex: 1;
  min-height: 0;
  position: relative;
}
</style>
