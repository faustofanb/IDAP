/**
 * 用户管理 Mock
 */
import Mock from 'mockjs'

// 生成用户列表数据
const generateUsers = (count: number) => {
    const users = []
    const statuses = ['ACTIVE', 'LOCKED', 'DISABLED']
    const genders = ['MALE', 'FEMALE', 'UNKNOWN']

    for (let i = 1; i <= count; i++) {
        users.push({
            id: i,
            username: `user${i}`,
            realName: Mock.Random.cname(),
            email: Mock.Random.email(),
            phone: /^1[3-9]\d{9}$/,
            gender: Mock.Random.pick(genders),
            avatar: Mock.Random.image('100x100', Mock.Random.color(), '#FFF', 'Avatar'),
            orgId: Mock.Random.integer(1, 10),
            orgName: `部门${Mock.Random.integer(1, 10)}`,
            status: Mock.Random.pick(statuses),
            lastLoginAt: Mock.Random.datetime(),
            lastLoginIp: Mock.Random.ip(),
            roles: [
                {
                    id: Mock.Random.integer(1, 5),
                    roleCode: 'role_' + Mock.Random.integer(1, 5),
                    roleName: Mock.Random.pick(['管理员', '经理', '员工', '访客'])
                }
            ],
            createdAt: Mock.Random.datetime(),
            updatedAt: Mock.Random.datetime()
        })
    }

    return users
}

// 用户列表数据（生成100条）
let userList = generateUsers(100)

// 查询用户列表
Mock.mock(/\/api\/users\?.*/, 'get', (options: any) => {
    const url = new URL('http://localhost' + options.url)
    const page = parseInt(url.searchParams.get('page') || '1')
    const size = parseInt(url.searchParams.get('size') || '20')
    const username = url.searchParams.get('username') || ''
    const realName = url.searchParams.get('realName') || ''
    const status = url.searchParams.get('status') || ''

    // 过滤
    let filteredList = userList.filter((user: any) => {
        if (username && !user.username.includes(username)) return false
        if (realName && !user.realName.includes(realName)) return false
        if (status && user.status !== status) return false
        return true
    })

    // 分页
    const total = filteredList.length
    const start = (page - 1) * size
    const end = start + size
    const records = filteredList.slice(start, end)

    return {
        code: 200,
        message: '成功',
        data: {
            records,
            total,
            size,
            current: page,
            pages: Math.ceil(total / size)
        },
        timestamp: Date.now()
    }
})

// 创建用户
Mock.mock(/\/api\/users$/, 'post', (options: any) => {
    const body = JSON.parse(options.body)
    const newUser = {
        id: userList.length + 1,
        ...body,
        status: 'ACTIVE',
        lastLoginAt: null,
        lastLoginIp: null,
        roles: [],
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
    }

    userList.push(newUser)

    return {
        code: 200,
        message: '创建成功',
        data: newUser,
        timestamp: Date.now()
    }
})

// 获取用户详情
Mock.mock(/\/api\/users\/(\d+)$/, 'get', (options: any) => {
    const id = parseInt(options.url.match(/\/api\/users\/(\d+)$/)?.[1] || '0')
    const user = userList.find((u: any) => u.id === id)

    if (user) {
        return {
            code: 200,
            message: '成功',
            data: user,
            timestamp: Date.now()
        }
    } else {
        return {
            code: 404,
            message: '用户不存在',
            data: null,
            timestamp: Date.now()
        }
    }
})

// 更新用户
Mock.mock(/\/api\/users\/(\d+)$/, 'put', (options: any) => {
    const id = parseInt(options.url.match(/\/api\/users\/(\d+)$/)?.[1] || '0')
    const body = JSON.parse(options.body)
    const index = userList.findIndex((u: any) => u.id === id)

    if (index !== -1) {
        userList[index] = {
            ...userList[index],
            ...body,
            updatedAt: new Date().toISOString()
        }

        return {
            code: 200,
            message: '更新成功',
            data: userList[index],
            timestamp: Date.now()
        }
    } else {
        return {
            code: 404,
            message: '用户不存在',
            data: null,
            timestamp: Date.now()
        }
    }
})

// 删除用户
Mock.mock(/\/api\/users\/(\d+)$/, 'delete', (options: any) => {
    const id = parseInt(options.url.match(/\/api\/users\/(\d+)$/)?.[1] || '0')
    const index = userList.findIndex((u: any) => u.id === id)

    if (index !== -1) {
        userList.splice(index, 1)

        return {
            code: 200,
            message: '删除成功',
            data: null,
            timestamp: Date.now()
        }
    } else {
        return {
            code: 404,
            message: '用户不存在',
            data: null,
            timestamp: Date.now()
        }
    }
})

// 重置密码
Mock.mock(/\/api\/users\/(\d+)\/reset-password$/, 'post', {
    code: 200,
    message: '密码重置成功',
    data: null,
    timestamp: Date.now()
})
