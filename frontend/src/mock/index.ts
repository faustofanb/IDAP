/**
 * Mock 数据服务入口
 * 用于前端独立开发和测试
 */
import Mock from 'mockjs'

// 配置 Mock
Mock.setup({
    timeout: '200-600' // 模拟网络延迟 200-600ms
})

// 导入所有 Mock 模块
import './modules/auth'
import './modules/dictionary'
import './modules/product'
import './modules/purchase'
import './modules/stock'
import './modules/tenant'
import './modules/user'

console.log('Mock 数据服务已启动')

export default Mock
