<template>
  <div class="chart-viewer">
    <div ref="chartRef" style="width: 100%; height: 400px;"></div>
    <!-- TODO: 集成 ECharts -->
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

defineProps({
  config: {
    type: Object,
    required: true
  }
})

const chartRef = ref(null)

onMounted(() => {
  // TODO: 初始化 ECharts
})
</script>

<style lang="scss" scoped>
.chart-viewer {
  width: 100%;
  margin: 20px 0;
}
</style>
