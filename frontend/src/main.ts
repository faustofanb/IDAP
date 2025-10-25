/**
 * 主应用入口
 * - Vue 应用初始化
 * - 全局组件与插件注册
 * - Element Plus 引入
 */
import * as ElementPlusIconsVue from '@element-plus/icons-vue'
import ElementPlus from 'element-plus'
import 'element-plus/dist/index.css'
import 'element-plus/theme-chalk/dark/css-vars.css'
import { createPinia } from 'pinia'
import { createApp } from 'vue'
import './assets/styles/index.css'

// 开发环境启用 Mock 数据
if (import.meta.env.DEV) {
    import('./mock')
}

import App from './App.vue'
import router from './router'
import { useUserStore } from './stores/user'

// 创建应用实例
const app = createApp(App)

// 使用 Pinia
const pinia = createPinia()
app.use(pinia)

// 恢复用户状态
const userStore = useUserStore()
userStore.restoreFromStorage()

// 使用路由
app.use(router)

// 使用 Element Plus
app.use(ElementPlus)

// 注册所有 Element Plus 图标
for (const [key, component] of Object.entries(ElementPlusIconsVue)) {
    app.component(key, component)
}

// 挂载应用
app.mount('#app')
