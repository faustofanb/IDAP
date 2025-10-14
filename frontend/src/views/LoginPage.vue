<template>
  <div class="login-page">
    <el-card class="login-card">
      <h2>登录</h2>
      <el-form>
        <el-form-item>
          <el-input placeholder="用户名" />
        </el-form-item>
        <el-form-item>
          <el-input type="password" placeholder="密码" />
        </el-form-item>
        <el-button type="primary">登录</el-button>
      </el-form>
    </el-card>
    <!-- TODO: 实现登录逻辑 -->
  </div>
</template>

<script setup>
// TODO: 添加登录逻辑
</script>

<style lang="scss" scoped>
.login-page {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 100vh;
  background: #f5f7fa;
}

.login-card {
  width: 400px;
}
</style>
