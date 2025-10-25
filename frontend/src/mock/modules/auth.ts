/**
 * 认证相关 Mock
 */
import Mock from 'mockjs'

// 登录
Mock.mock(/\/api\/auth\/login/, 'post', (options: any) => {
    const body = JSON.parse(options.body)

    // 模拟登录验证
    if (body.username === 'admin' && body.password === '123456') {
        return {
            code: 200,
            message: '登录成功',
            data: {
                token: Mock.Random.guid(),
                refreshToken: Mock.Random.guid(),
                expiresIn: 7200,
                userInfo: {
                    id: 1,
                    username: 'admin',
                    realName: '超级管理员',
                    email: 'admin@example.com',
                    phone: '13800138000',
                    avatar: 'https://cube.elemecdn.com/0/88/03b0d39583f48206768a7534e55bcpng.png',
                    tenantId: 1,
                    tenantName: '默认租户',
                    roles: ['admin', 'super_admin'],
                    permissions: ['*:*:*']
                }
            },
            timestamp: Date.now()
        }
    } else {
        return {
            code: 401,
            message: '用户名或密码错误',
            data: null,
            timestamp: Date.now()
        }
    }
})

// 登出
Mock.mock(/\/api\/auth\/logout/, 'post', {
    code: 200,
    message: '登出成功',
    data: null,
    timestamp: Date.now()
})

// 刷新令牌
Mock.mock(/\/api\/auth\/refresh/, 'post', {
    code: 200,
    message: '刷新成功',
    data: {
        token: Mock.Random.guid(),
        expiresIn: 7200
    },
    timestamp: Date.now()
})

// 获取当前用户信息
Mock.mock(/\/api\/auth\/userinfo/, 'get', {
    code: 200,
    message: '成功',
    data: {
        id: 1,
        username: 'admin',
        realName: '超级管理员',
        email: 'admin@example.com',
        phone: '13800138000',
        avatar: 'https://cube.elemecdn.com/0/88/03b0d39583f48206768a7534e55bcpng.png',
        tenantId: 1,
        tenantName: '默认租户',
        roles: ['admin', 'super_admin'],
        permissions: ['*:*:*']
    },
    timestamp: Date.now()
})
