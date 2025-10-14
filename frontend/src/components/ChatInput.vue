<template>
  <div class="chat-input">
    <el-input
      type="textarea"
      v-model="text"
      placeholder="输入您的问题..."
      :rows="3"
      @keydown.meta.enter="handleSend"
      @keydown.ctrl.enter="handleSend"
    />
    <el-button
      type="primary"
      @click="handleSend"
      :disabled="!text.trim()"
    >
      发送
    </el-button>
  </div>
</template>

<script setup>
import { ref } from 'vue'

const emit = defineEmits(['send'])
const text = ref('')

function handleSend() {
  // TODO: 发送消息逻辑
  if (text.value.trim()) {
    emit('send', text.value)
    text.value = ''
  }
}
</script>

<style lang="scss" scoped>
.chat-input {
  display: flex;
  gap: 10px;
}
</style>
