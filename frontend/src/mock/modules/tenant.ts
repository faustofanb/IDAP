/**
 * 租户管理 Mock
 */
import Mock from 'mockjs'

// 生成租户列表数据
const generateTenants = (count: number) => {
    const tenants = []
    const types = ['ENTERPRISE', 'PERSONAL']
    const statuses = ['ACTIVE', 'SUSPENDED', 'EXPIRED']

    for (let i = 1; i <= count; i++) {
        tenants.push({
            id: i,
            tenantCode: `tenant${i}`,
            tenantName: Mock.Random.ctitle(5, 10) + '公司',
            tenantType: Mock.Random.pick(types),
            status: Mock.Random.pick(statuses),
            contactName: Mock.Random.cname(),
            contactPhone: /^1[3-9]\d{9}$/,
            contactEmail: Mock.Random.email(),
            expiredAt: Mock.Random.datetime('yyyy-MM-dd HH:mm:ss'),
            maxUsers: Mock.Random.integer(10, 1000),
            maxStorage: Mock.Random.integer(1073741824, 107374182400), // 1GB - 100GB
            createdAt: Mock.Random.datetime(),
            updatedAt: Mock.Random.datetime()
        })
    }

    return tenants
}

let tenantList = generateTenants(50)

// 查询租户列表
Mock.mock(/\/api\/tenants\?.*/, 'get', (options: any) => {
    const url = new URL('http://localhost' + options.url)
    const page = parseInt(url.searchParams.get('page') || '1')
    const size = parseInt(url.searchParams.get('size') || '20')
    const tenantName = url.searchParams.get('tenantName') || ''
    const status = url.searchParams.get('status') || ''

    // 过滤
    let filteredList = tenantList.filter((tenant: any) => {
        if (tenantName && !tenant.tenantName.includes(tenantName)) return false
        if (status && tenant.status !== status) return false
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

// 创建租户
Mock.mock(/\/api\/tenants$/, 'post', (options: any) => {
    const body = JSON.parse(options.body)
    const newTenant = {
        id: tenantList.length + 1,
        ...body,
        status: 'ACTIVE',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
    }

    tenantList.push(newTenant)

    return {
        code: 200,
        message: '创建成功',
        data: newTenant,
        timestamp: Date.now()
    }
})

// 获取租户详情
Mock.mock(/\/api\/tenants\/(\d+)$/, 'get', (options: any) => {
    const id = parseInt(options.url.match(/\/api\/tenants\/(\d+)$/)?.[1] || '0')
    const tenant = tenantList.find((t: any) => t.id === id)

    return {
        code: 200,
        message: '成功',
        data: tenant || null,
        timestamp: Date.now()
    }
})

// 更新租户
Mock.mock(/\/api\/tenants\/(\d+)$/, 'put', (options: any) => {
    const id = parseInt(options.url.match(/\/api\/tenants\/(\d+)$/)?.[1] || '0')
    const body = JSON.parse(options.body)
    const index = tenantList.findIndex((t: any) => t.id === id)

    if (index !== -1) {
        tenantList[index] = {
            ...tenantList[index],
            ...body,
            updatedAt: new Date().toISOString()
        }

        return {
            code: 200,
            message: '更新成功',
            data: tenantList[index],
            timestamp: Date.now()
        }
    }

    return {
        code: 404,
        message: '租户不存在',
        data: null,
        timestamp: Date.now()
    }
})

// 删除租户
Mock.mock(/\/api\/tenants\/(\d+)$/, 'delete', (options: any) => {
    const id = parseInt(options.url.match(/\/api\/tenants\/(\d+)$/)?.[1] || '0')
    const index = tenantList.findIndex((t: any) => t.id === id)

    if (index !== -1) {
        tenantList.splice(index, 1)

        return {
            code: 200,
            message: '删除成功',
            data: null,
            timestamp: Date.now()
        }
    }

    return {
        code: 404,
        message: '租户不存在',
        data: null,
        timestamp: Date.now()
    }
})
