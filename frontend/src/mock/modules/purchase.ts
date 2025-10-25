/**
 * 采购管理 Mock
 */
import Mock from 'mockjs'

// 生成采购订单列表数据
const generatePurchaseOrders = (count: number) => {
    const orders = []
    const statuses = ['DRAFT', 'PENDING', 'APPROVED', 'IN_TRANSIT', 'COMPLETED', 'CANCELLED']

    for (let i = 1; i <= count; i++) {
        const itemCount = Mock.Random.integer(1, 10)
        const items = []
        let totalAmount = 0

        for (let j = 0; j < itemCount; j++) {
            const quantity = Mock.Random.integer(10, 100)
            const price = Mock.Random.float(10, 1000, 2, 2)
            const taxRate = 0.13
            const amount = quantity * price
            const taxAmount = amount * taxRate

            items.push({
                id: j + 1,
                productId: Mock.Random.integer(1, 200),
                productCode: `P${String(Mock.Random.integer(1, 200)).padStart(6, '0')}`,
                productName: Mock.Random.ctitle(5, 15),
                quantity,
                receivedQuantity: Mock.Random.integer(0, quantity),
                price,
                amount,
                taxRate,
                taxAmount
            })

            totalAmount += amount
        }

        const discountAmount = totalAmount * Mock.Random.float(0, 0.1, 2, 2)
        const actualAmount = totalAmount - discountAmount

        orders.push({
            id: i,
            orderNo: `PO${new Date().getFullYear()}${String(i).padStart(8, '0')}`,
            supplierId: Mock.Random.integer(1, 50),
            supplierName: Mock.Random.ctitle(5, 10) + '供应商',
            warehouseId: Mock.Random.integer(1, 10),
            warehouseName: `仓库${Mock.Random.integer(1, 10)}号`,
            orderDate: Mock.Random.date(),
            expectedDate: Mock.Random.date(),
            totalAmount,
            discountAmount,
            actualAmount,
            paidAmount: Mock.Random.float(0, actualAmount, 2, 2),
            status: Mock.Random.pick(statuses),
            items,
            createdBy: Mock.Random.cname(),
            createdAt: Mock.Random.datetime(),
            updatedAt: Mock.Random.datetime()
        })
    }

    return orders
}

let purchaseOrderList = generatePurchaseOrders(100)

// 查询采购订单列表
Mock.mock(/\/api\/purchase\/orders\?.*/, 'get', (options: any) => {
    const url = new URL('http://localhost' + options.url)
    const page = parseInt(url.searchParams.get('page') || '1')
    const size = parseInt(url.searchParams.get('size') || '20')
    const orderNo = url.searchParams.get('orderNo') || ''
    const supplierId = url.searchParams.get('supplierId')
    const status = url.searchParams.get('status') || ''

    // 过滤
    let filteredList = purchaseOrderList.filter((order: any) => {
        if (orderNo && !order.orderNo.includes(orderNo)) return false
        if (supplierId && order.supplierId !== parseInt(supplierId)) return false
        if (status && order.status !== status) return false
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

// 创建采购订单
Mock.mock(/\/api\/purchase\/orders$/, 'post', (options: any) => {
    const body = JSON.parse(options.body)

    const totalAmount = body.items.reduce((sum: number, item: any) => {
        return sum + (item.quantity * item.price)
    }, 0)

    const actualAmount = totalAmount - (body.discountAmount || 0)

    const newOrder = {
        id: purchaseOrderList.length + 1,
        orderNo: `PO${new Date().getFullYear()}${String(purchaseOrderList.length + 1).padStart(8, '0')}`,
        ...body,
        totalAmount,
        actualAmount,
        paidAmount: 0,
        status: 'DRAFT',
        createdBy: '管理员',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
    }

    purchaseOrderList.push(newOrder)

    return {
        code: 200,
        message: '创建成功',
        data: newOrder,
        timestamp: Date.now()
    }
})

// 获取采购订单详情
Mock.mock(/\/api\/purchase\/orders\/(\d+)$/, 'get', (options: any) => {
    const id = parseInt(options.url.match(/\/api\/purchase\/orders\/(\d+)$/)?.[1] || '0')
    const order = purchaseOrderList.find((o: any) => o.id === id)

    return {
        code: 200,
        message: '成功',
        data: order || null,
        timestamp: Date.now()
    }
})

// 删除采购订单
Mock.mock(/\/api\/purchase\/orders\/(\d+)$/, 'delete', (options: any) => {
    const id = parseInt(options.url.match(/\/api\/purchase\/orders\/(\d+)$/)?.[1] || '0')
    const index = purchaseOrderList.findIndex((o: any) => o.id === id)

    if (index !== -1) {
        const order = purchaseOrderList[index]

        // 只能删除草稿状态的订单
        if (order && order.status !== 'DRAFT') {
            return {
                code: 400,
                message: '只能删除草稿状态的订单',
                data: null,
                timestamp: Date.now()
            }
        }

        purchaseOrderList.splice(index, 1)

        return {
            code: 200,
            message: '删除成功',
            data: null,
            timestamp: Date.now()
        }
    }

    return {
        code: 404,
        message: '订单不存在',
        data: null,
        timestamp: Date.now()
    }
})

// 提交采购订单审核
Mock.mock(/\/api\/purchase\/orders\/(\d+)\/submit$/, 'post', (options: any) => {
    const id = parseInt(options.url.match(/\/api\/purchase\/orders\/(\d+)\/submit$/)?.[1] || '0')
    const order = purchaseOrderList.find((o: any) => o.id === id)

    if (order) {
        order.status = 'PENDING'
        order.updatedAt = new Date().toISOString()

        return {
            code: 200,
            message: '提交成功',
            data: order,
            timestamp: Date.now()
        }
    }

    return {
        code: 404,
        message: '订单不存在',
        data: null,
        timestamp: Date.now()
    }
})

// 审核通过采购订单
Mock.mock(/\/api\/purchase\/orders\/(\d+)\/approve$/, 'post', (options: any) => {
    const id = parseInt(options.url.match(/\/api\/purchase\/orders\/(\d+)\/approve$/)?.[1] || '0')
    const order = purchaseOrderList.find((o: any) => o.id === id)

    if (order) {
        order.status = 'APPROVED'
        order.updatedAt = new Date().toISOString()

        return {
            code: 200,
            message: '审核通过',
            data: order,
            timestamp: Date.now()
        }
    }

    return {
        code: 404,
        message: '订单不存在',
        data: null,
        timestamp: Date.now()
    }
})

// 驳回采购订单
Mock.mock(/\/api\/purchase\/orders\/(\d+)\/reject$/, 'post', (options: any) => {
    const id = parseInt(options.url.match(/\/api\/purchase\/orders\/(\d+)\/reject$/)?.[1] || '0')
    const order = purchaseOrderList.find((o: any) => o.id === id)

    if (order) {
        order.status = 'DRAFT'
        order.updatedAt = new Date().toISOString()

        return {
            code: 200,
            message: '已驳回',
            data: order,
            timestamp: Date.now()
        }
    }

    return {
        code: 404,
        message: '订单不存在',
        data: null,
        timestamp: Date.now()
    }
})
