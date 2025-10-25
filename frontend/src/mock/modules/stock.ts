/**
 * 库存管理 Mock
 */
import Mock from 'mockjs'

// 生成库存列表数据
const generateStocks = (count: number) => {
    const stocks = []

    for (let i = 1; i <= count; i++) {
        const totalQuantity = Mock.Random.integer(0, 1000)
        const lockedQuantity = Mock.Random.integer(0, Math.floor(totalQuantity * 0.3))
        const availableQuantity = totalQuantity - lockedQuantity

        stocks.push({
            id: i,
            warehouseId: Mock.Random.integer(1, 10),
            warehouseName: `仓库${Mock.Random.integer(1, 10)}号`,
            productId: i,
            productCode: `P${String(i).padStart(6, '0')}`,
            productName: Mock.Random.ctitle(5, 15),
            productSku: `SKU${String(i).padStart(8, '0')}`,
            quantity: totalQuantity,
            totalQuantity,
            lockedQuantity,
            availableQuantity,
            costPrice: Mock.Random.float(10, 1000, 2, 2),
            lastInAt: Mock.Random.datetime(),
            lastOutAt: Mock.Random.datetime(),
            updatedAt: Mock.Random.datetime()
        })
    }

    return stocks
}

// 生成库存日志数据
const generateStockLogs = (count: number) => {
    const logs = []
    const changeTypes = ['IN', 'OUT', 'TRANSFER', 'ADJUST']
    const bizTypes = ['采购入库', '销售出库', '仓库调拨', '库存盘点']

    for (let i = 1; i <= count; i++) {
        const changeType = Mock.Random.pick(changeTypes)
        const changeQuantity = changeType === 'IN' || changeType === 'ADJUST'
            ? Mock.Random.integer(10, 200)
            : -Mock.Random.integer(10, 200)
        const beforeQuantity = Mock.Random.integer(100, 1000)
        const afterQuantity = beforeQuantity + changeQuantity

        logs.push({
            id: i,
            warehouseId: Mock.Random.integer(1, 10),
            warehouseName: `仓库${Mock.Random.integer(1, 10)}号`,
            productId: Mock.Random.integer(1, 200),
            productCode: `P${String(Mock.Random.integer(1, 200)).padStart(6, '0')}`,
            productName: Mock.Random.ctitle(5, 15),
            productSku: `SKU${String(Mock.Random.integer(1, 200)).padStart(8, '0')}`,
            logType: changeType,
            changeType,
            quantity: Math.abs(changeQuantity),
            changeQuantity,
            beforeQuantity,
            afterQuantity,
            bizType: Mock.Random.pick(bizTypes),
            billType: Mock.Random.pick(bizTypes),
            bizNo: `BIZ${Mock.Random.string('number', 10)}`,
            billNo: `BIZ${Mock.Random.string('number', 10)}`,
            operatorName: Mock.Random.cname(),
            operatedAt: Mock.Random.datetime(),
            createdAt: Mock.Random.datetime(),
            remark: Mock.Random.pick(['', '正常入库', '正常出库', '库存调整', '定期盘点'])
        })
    }

    return logs
}

let stockList = generateStocks(200)
let stockLogList = generateStockLogs(500)

// 查询库存列表
Mock.mock(/\/api\/stocks\?.*/, 'get', (options: any) => {
    const url = new URL('http://localhost' + options.url)
    const page = parseInt(url.searchParams.get('page') || '1')
    const size = parseInt(url.searchParams.get('size') || '20')
    const productName = url.searchParams.get('productName') || ''
    const warehouseId = url.searchParams.get('warehouseId')

    // 过滤
    let filteredList = stockList.filter((stock: any) => {
        if (productName && !stock.productName.includes(productName)) return false
        if (warehouseId && stock.warehouseId !== parseInt(warehouseId)) return false
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

// 查询库存日志
Mock.mock(/\/api\/stocks\/logs\?.*/, 'get', (options: any) => {
    const url = new URL('http://localhost' + options.url)
    const page = parseInt(url.searchParams.get('page') || '1')
    const size = parseInt(url.searchParams.get('size') || '20')
    const productId = url.searchParams.get('productId')
    const warehouseId = url.searchParams.get('warehouseId')
    const changeType = url.searchParams.get('changeType') || ''

    // 过滤
    let filteredList = stockLogList.filter((log: any) => {
        if (productId && log.productId !== parseInt(productId)) return false
        if (warehouseId && log.warehouseId !== parseInt(warehouseId)) return false
        if (changeType && log.changeType !== changeType) return false
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
