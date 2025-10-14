<template>
  <div class="chat-page">
    <div class="chat-container">
      <div class="messages">
        <!-- TODO: 渲染消息列表 -->
      </div>
      <div class="input-area">
        <ChatInput @send="handleSend" />
      </div>
    </div>
  </div>
</template>

<script setup>
import ChatInput from '@/components/ChatInput.vue'

function handleSend(text) {
  // TODO: 发送消息
}
</script>

<style lang="scss" scoped>
.chat-page {
  display: flex;
  height: 100vh;
}

.chat-container {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.messages {
  flex: 1;
  overflow-y: auto;
  padding: 20px;
}

.input-area {
  padding: 20px;
  border-top: 1px solid #e0e0e0;
}
</style>
