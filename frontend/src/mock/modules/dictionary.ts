/**
 * 数据字典 Mock
 */
import Mock from 'mockjs'

// 字典类型数据
const dictTypes = [
    {
        id: 1,
        dictCode: 'user_status',
        dictName: '用户状态',
        dictType: 'SYSTEM',
        description: '用户账号状态',
        status: 'ACTIVE',
        createdAt: '2025-01-01 00:00:00'
    },
    {
        id: 2,
        dictCode: 'user_gender',
        dictName: '用户性别',
        dictType: 'SYSTEM',
        description: '用户性别类型',
        status: 'ACTIVE',
        createdAt: '2025-01-01 00:00:00'
    },
    {
        id: 3,
        dictCode: 'product_status',
        dictName: '产品状态',
        dictType: 'SYSTEM',
        description: '产品上下架状态',
        status: 'ACTIVE',
        createdAt: '2025-01-01 00:00:00'
    },
    {
        id: 4,
        dictCode: 'stock_change_type',
        dictName: '库存变动类型',
        dictType: 'SYSTEM',
        description: '库存变动类型',
        status: 'ACTIVE',
        createdAt: '2025-01-01 00:00:00'
    },
    {
        id: 5,
        dictCode: 'order_status',
        dictName: '订单状态',
        dictType: 'SYSTEM',
        description: '采购/销售订单状态',
        status: 'ACTIVE',
        createdAt: '2025-01-01 00:00:00'
    }
]

// 字典数据
const dictData: Record<string, any[]> = {
    user_status: [
        { id: 1, dictTypeId: 1, dictLabel: '正常', dictValue: 'ACTIVE', dictSort: 1, tagType: 'success', isDefault: true, status: 'ACTIVE' },
        { id: 2, dictTypeId: 1, dictLabel: '锁定', dictValue: 'LOCKED', dictSort: 2, tagType: 'danger', isDefault: false, status: 'ACTIVE' },
        { id: 3, dictTypeId: 1, dictLabel: '禁用', dictValue: 'DISABLED', dictSort: 3, tagType: 'info', isDefault: false, status: 'ACTIVE' }
    ],
    user_gender: [
        { id: 4, dictTypeId: 2, dictLabel: '男', dictValue: 'MALE', dictSort: 1, tagType: 'primary', isDefault: false, status: 'ACTIVE' },
        { id: 5, dictTypeId: 2, dictLabel: '女', dictValue: 'FEMALE', dictSort: 2, tagType: 'danger', isDefault: false, status: 'ACTIVE' },
        { id: 6, dictTypeId: 2, dictLabel: '未知', dictValue: 'UNKNOWN', dictSort: 3, tagType: 'info', isDefault: true, status: 'ACTIVE' }
    ],
    product_status: [
        { id: 7, dictTypeId: 3, dictLabel: '在售', dictValue: 'ON_SALE', dictSort: 1, tagType: 'success', isDefault: true, status: 'ACTIVE' },
        { id: 8, dictTypeId: 3, dictLabel: '下架', dictValue: 'OFF_SALE', dictSort: 2, tagType: 'info', isDefault: false, status: 'ACTIVE' },
        { id: 9, dictTypeId: 3, dictLabel: '缺货', dictValue: 'OUT_OF_STOCK', dictSort: 3, tagType: 'warning', isDefault: false, status: 'ACTIVE' }
    ],
    stock_change_type: [
        { id: 10, dictTypeId: 4, dictLabel: '入库', dictValue: 'IN', dictSort: 1, tagType: 'success', isDefault: false, status: 'ACTIVE' },
        { id: 11, dictTypeId: 4, dictLabel: '出库', dictValue: 'OUT', dictSort: 2, tagType: 'danger', isDefault: false, status: 'ACTIVE' },
        { id: 12, dictTypeId: 4, dictLabel: '调拨', dictValue: 'TRANSFER', dictSort: 3, tagType: 'warning', isDefault: false, status: 'ACTIVE' },
        { id: 13, dictTypeId: 4, dictLabel: '调整', dictValue: 'ADJUST', dictSort: 4, tagType: 'info', isDefault: false, status: 'ACTIVE' }
    ],
    order_status: [
        { id: 14, dictTypeId: 5, dictLabel: '草稿', dictValue: 'DRAFT', dictSort: 1, tagType: 'info', isDefault: true, status: 'ACTIVE' },
        { id: 15, dictTypeId: 5, dictLabel: '待审核', dictValue: 'PENDING', dictSort: 2, tagType: 'warning', isDefault: false, status: 'ACTIVE' },
        { id: 16, dictTypeId: 5, dictLabel: '已审核', dictValue: 'APPROVED', dictSort: 3, tagType: 'success', isDefault: false, status: 'ACTIVE' },
        { id: 17, dictTypeId: 5, dictLabel: '运输中', dictValue: 'IN_TRANSIT', dictSort: 4, tagType: 'primary', isDefault: false, status: 'ACTIVE' },
        { id: 18, dictTypeId: 5, dictLabel: '已完成', dictValue: 'COMPLETED', dictSort: 5, tagType: 'success', isDefault: false, status: 'ACTIVE' },
        { id: 19, dictTypeId: 5, dictLabel: '已取消', dictValue: 'CANCELLED', dictSort: 6, tagType: 'danger', isDefault: false, status: 'ACTIVE' }
    ]
}

// 查询字典类型列表
Mock.mock(/\/api\/dict\/types\?.*/, 'get', (options: any) => {
    const url = new URL('http://localhost' + options.url)
    const page = parseInt(url.searchParams.get('page') || '1')
    const size = parseInt(url.searchParams.get('size') || '20')

    const total = dictTypes.length
    const start = (page - 1) * size
    const end = start + size
    const records = dictTypes.slice(start, end)

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

// 根据字典编码获取字典数据
Mock.mock(/\/api\/dict\/data\/([a-z_]+)$/, 'get', (options: any) => {
    const dictCode = options.url.match(/\/api\/dict\/data\/([a-z_]+)$/)?.[1] || ''
    const data = dictData[dictCode] || []

    return {
        code: 200,
        message: '成功',
        data,
        timestamp: Date.now()
    }
})

// 根据字典值获取标签
Mock.mock(/\/api\/dict\/label\/([a-z_]+)\/([A-Z_]+)$/, 'get', (options: any) => {
    const matches = options.url.match(/\/api\/dict\/label\/([a-z_]+)\/([A-Z_]+)$/)
    const dictCode = matches?.[1] || ''
    const dictValue = matches?.[2] || ''

    const data = dictData[dictCode] || []
    const item = data.find((d: any) => d.dictValue === dictValue)

    return {
        code: 200,
        message: '成功',
        data: {
            label: item?.dictLabel || dictValue,
            tagType: item?.tagType || 'info'
        },
        timestamp: Date.now()
    }
})
