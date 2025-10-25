/**
 * 产品管理 Mock
 */
import Mock from 'mockjs'

// 生成产品列表数据
const generateProducts = (count: number) => {
    const products = []
    const statuses = ['ON_SALE', 'OFF_SALE', 'OUT_OF_STOCK']
    const categories = [
        { id: 1, name: '电子产品' },
        { id: 2, name: '服装鞋帽' },
        { id: 3, name: '食品饮料' },
        { id: 4, name: '家居用品' },
        { id: 5, name: '图书音像' }
    ]
    const units = ['件', '个', '箱', '套', '台', '本', '盒']
    const brands = ['Apple', '华为', '小米', '三星', '索尼', 'Nike', 'Adidas', '可口可乐']

    for (let i = 1; i <= count; i++) {
        const category = Mock.Random.pick(categories)
        const purchasePrice = Mock.Random.float(10, 1000, 2, 2)
        const salePrice = purchasePrice * Mock.Random.float(1.2, 2, 2, 2)

        products.push({
            id: i,
            productCode: `P${String(i).padStart(6, '0')}`,
            productName: Mock.Random.ctitle(5, 15),
            categoryId: category.id,
            categoryName: category.name,
            unit: Mock.Random.pick(units),
            spec: Mock.Random.pick(['标准版', '豪华版', '旗舰版', '普通装', '500g', '1000ml']),
            brand: Mock.Random.pick(brands),
            barcode: Mock.Random.string('number', 13),
            imageUrl: Mock.Random.image('200x200', Mock.Random.color(), '#FFF', 'Product'),
            purchasePrice,
            salePrice,
            costPrice: purchasePrice * 0.95,
            minStock: Mock.Random.integer(10, 50),
            maxStock: Mock.Random.integer(100, 500),
            status: Mock.Random.pick(statuses),
            createdAt: Mock.Random.datetime(),
            updatedAt: Mock.Random.datetime()
        })
    }

    return products
}

let productList = generateProducts(200)

// 查询产品列表
Mock.mock(/\/api\/products\?.*/, 'get', (options: any) => {
    const url = new URL('http://localhost' + options.url)
    const page = parseInt(url.searchParams.get('page') || '1')
    const size = parseInt(url.searchParams.get('size') || '20')
    const productName = url.searchParams.get('productName') || ''
    const categoryId = url.searchParams.get('categoryId')
    const status = url.searchParams.get('status') || ''

    // 过滤
    let filteredList = productList.filter((product: any) => {
        if (productName && !product.productName.includes(productName)) return false
        if (categoryId && product.categoryId !== parseInt(categoryId)) return false
        if (status && product.status !== status) return false
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

// 创建产品
Mock.mock(/\/api\/products$/, 'post', (options: any) => {
    const body = JSON.parse(options.body)
    const newProduct = {
        id: productList.length + 1,
        productCode: `P${String(productList.length + 1).padStart(6, '0')}`,
        ...body,
        costPrice: body.purchasePrice * 0.95,
        imageUrl: Mock.Random.image('200x200', Mock.Random.color(), '#FFF', 'Product'),
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
    }

    productList.push(newProduct)

    return {
        code: 200,
        message: '创建成功',
        data: newProduct,
        timestamp: Date.now()
    }
})

// 获取产品详情
Mock.mock(/\/api\/products\/(\d+)$/, 'get', (options: any) => {
    const id = parseInt(options.url.match(/\/api\/products\/(\d+)$/)?.[1] || '0')
    const product = productList.find((p: any) => p.id === id)

    return {
        code: 200,
        message: '成功',
        data: product || null,
        timestamp: Date.now()
    }
})

// 更新产品
Mock.mock(/\/api\/products\/(\d+)$/, 'put', (options: any) => {
    const id = parseInt(options.url.match(/\/api\/products\/(\d+)$/)?.[1] || '0')
    const body = JSON.parse(options.body)
    const index = productList.findIndex((p: any) => p.id === id)

    if (index !== -1) {
        productList[index] = {
            ...productList[index],
            ...body,
            updatedAt: new Date().toISOString()
        }

        return {
            code: 200,
            message: '更新成功',
            data: productList[index],
            timestamp: Date.now()
        }
    }

    return {
        code: 404,
        message: '产品不存在',
        data: null,
        timestamp: Date.now()
    }
})

// 删除产品
Mock.mock(/\/api\/products\/(\d+)$/, 'delete', (options: any) => {
    const id = parseInt(options.url.match(/\/api\/products\/(\d+)$/)?.[1] || '0')
    const index = productList.findIndex((p: any) => p.id === id)

    if (index !== -1) {
        productList.splice(index, 1)

        return {
            code: 200,
            message: '删除成功',
            data: null,
            timestamp: Date.now()
        }
    }

    return {
        code: 404,
        message: '产品不存在',
        data: null,
        timestamp: Date.now()
    }
})
