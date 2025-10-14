<template>
  <div class="chat-message" :class="message.role">
    <div class="content">
      {{ message.content }}
      <!-- TODO: 添加 Markdown 渲染 -->
      <!-- TODO: 添加 SQL 高亮 -->
      <!-- TODO: 添加图表展示 -->
    </div>
  </div>
</template>

<script setup>
defineProps({
  message: {
    type: Object,
    required: true
  }
})
</script>

<style lang="scss" scoped>
.chat-message {
  margin-bottom: 20px;

  &.user {
    text-align: right;
    .content {
      background: #409eff;
      color: white;
    }
  }

  &.assistant {
    text-align: left;
    .content {
      background: #f5f7fa;
    }
  }
}

.content {
  display: inline-block;
  padding: 10px 15px;
  border-radius: 8px;
  max-width: 70%;
}
</style>
