<script setup lang="ts">
import { useUserStore } from '@/stores/user'
import type { FormInstance, FormRules } from 'element-plus'
import { ElMessage } from 'element-plus'
import { reactive, ref } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()
const userStore = useUserStore()

// 登录表单
const loginFormRef = ref<FormInstance>()
const loginForm = reactive({
    username: 'admin',
    password: '123456',
    tenantCode: 'default'
})

// 表单验证规则
const rules: FormRules = {
    username: [
        { required: true, message: '请输入用户名', trigger: 'blur' },
        { min: 3, max: 20, message: '用户名长度在 3 到 20 个字符', trigger: 'blur' }
    ],
    password: [
        { required: true, message: '请输入密码', trigger: 'blur' },
        { min: 6, max: 20, message: '密码长度在 6 到 20 个字符', trigger: 'blur' }
    ],
    tenantCode: [
        { required: true, message: '请输入租户代码', trigger: 'blur' }
    ]
}

// 加载状态
const loading = ref(false)

// 登录处理
const handleLogin = async () => {
    if (!loginFormRef.value) return

    await loginFormRef.value.validate(async (valid) => {
        if (!valid) return

        loading.value = true

        try {
            // TODO: 调用登录 API
            // const response = await loginApi(loginForm)

            // 模拟登录成功
            await new Promise(resolve => setTimeout(resolve, 1000))

            // 设置 Token 和用户信息
            userStore.setToken('mock-jwt-token', 'mock-refresh-token')
            userStore.setUserInfo({
                id: '1',
                username: loginForm.username,
                realName: '管理员',
                email: 'admin@example.com',
                phone: '13800138000',
                avatar: '',
                tenantId: '1',
                tenantName: '默认租户',
                roles: ['admin'],
                permissions: ['*:*:*']
            })

            ElMessage.success('登录成功')

            // 跳转到首页
            const redirect = router.currentRoute.value.query.redirect as string
            router.push(redirect || '/dashboard')
        } catch (error) {
            ElMessage.error('登录失败，请检查用户名和密码')
        } finally {
            loading.value = false
        }
    })
}
</script>

<template>
    <div class="login-container">
        <div class="login-box">
            <div class="login-header">
                <h1 class="title">IDAP 管理系统</h1>
                <p class="subtitle">智能数据询问平台 - 进销存管理</p>
            </div>

            <el-form ref="loginFormRef" :model="loginForm" :rules="rules" class="login-form" @keyup.enter="handleLogin">
                <el-form-item prop="tenantCode">
                    <el-input v-model="loginForm.tenantCode" placeholder="租户代码" size="large"
                        prefix-icon="OfficeBuilding" />
                </el-form-item>

                <el-form-item prop="username">
                    <el-input v-model="loginForm.username" placeholder="用户名" size="large" prefix-icon="User" />
                </el-form-item>

                <el-form-item prop="password">
                    <el-input v-model="loginForm.password" type="password" placeholder="密码" size="large"
                        prefix-icon="Lock" show-password />
                </el-form-item>

                <el-form-item>
                    <el-button type="primary" size="large" :loading="loading" class="login-button" @click="handleLogin">
                        登 录
                    </el-button>
                </el-form-item>
            </el-form>

            <div class="login-footer">
                <el-divider>多租户 B2B 后台管理系统</el-divider>
                <p class="copyright">© 2025 IDAP. All rights reserved.</p>
            </div>
        </div>
    </div>
</template>

<style scoped>
.login-container {
    display: flex;
    justify-content: center;
    align-items: center;
    min-height: 100vh;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.login-box {
    width: 400px;
    padding: 40px;
    background-color: #fff;
    border-radius: 10px;
    box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
}

.login-header {
    text-align: center;
    margin-bottom: 30px;
}

.title {
    font-size: 28px;
    font-weight: bold;
    color: #333;
    margin: 0 0 10px 0;
}

.subtitle {
    font-size: 14px;
    color: #666;
    margin: 0;
}

.login-form {
    margin-top: 30px;
}

.login-button {
    width: 100%;
}

.login-footer {
    margin-top: 20px;
    text-align: center;
}

.copyright {
    font-size: 12px;
    color: #999;
    margin-top: 10px;
}
</style>
