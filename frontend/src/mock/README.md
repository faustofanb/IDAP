# Mock 数据服务

## 概述

本目录包含前端开发使用的 Mock 数据服务，使用 [Mock.js](http://mockjs.com/) 实现。

## 功能特性

- 🚀 **自动拦截** - 自动拦截 `/api/*` 请求，无需修改业务代码
- 📦 **丰富数据** - 预置 1000+ 条测试数据
- ⚡ **网络延迟** - 模拟真实网络延迟（200-600ms）
- 🎯 **完整 CRUD** - 支持增删改查操作
- 🔄 **状态管理** - Mock 数据在内存中持久化

## 模块列表

### 1. 认证模块 (`modules/auth.ts`)
- `POST /api/auth/login` - 用户登录
- `POST /api/auth/logout` - 退出登录
- `POST /api/auth/refresh` - 刷新令牌
- `GET /api/auth/userinfo` - 获取当前用户信息

**测试账号：**
- 用户名: `admin`
- 密码: `123456`
- 租户代码: `default`

### 2. 用户管理 (`modules/user.ts`)
- `GET /api/users` - 查询用户列表（100条数据）
- `POST /api/users` - 创建用户
- `GET /api/users/:id` - 获取用户详情
- `PUT /api/users/:id` - 更新用户
- `DELETE /api/users/:id` - 删除用户
- `POST /api/users/:id/reset-password` - 重置密码

### 3. 租户管理 (`modules/tenant.ts`)
- `GET /api/tenants` - 查询租户列表（50条数据）
- `POST /api/tenants` - 创建租户
- `GET /api/tenants/:id` - 获取租户详情
- `PUT /api/tenants/:id` - 更新租户
- `DELETE /api/tenants/:id` - 删除租户

### 4. 数据字典 (`modules/dictionary.ts`)
- `GET /api/dict/types` - 查询字典类型列表
- `GET /api/dict/data/:dictCode` - 获取字典数据
- `GET /api/dict/label/:dictCode/:dictValue` - 获取字典标签

**预置字典：**
- `user_status` - 用户状态（正常/锁定/禁用）
- `user_gender` - 用户性别（男/女/未知）
- `product_status` - 产品状态（在售/下架/缺货）
- `stock_change_type` - 库存变动类型（入库/出库/调拨/调整）
- `order_status` - 订单状态（草稿/待审核/已审核/运输中/已完成/已取消）

### 5. 产品管理 (`modules/product.ts`)
- `GET /api/products` - 查询产品列表（200条数据）
- `POST /api/products` - 创建产品
- `GET /api/products/:id` - 获取产品详情
- `PUT /api/products/:id` - 更新产品
- `DELETE /api/products/:id` - 删除产品

### 6. 库存管理 (`modules/stock.ts`)
- `GET /api/stocks` - 查询库存列表（200条数据）
- `GET /api/stocks/logs` - 查询库存日志（500条数据）

### 7. 采购管理 (`modules/purchase.ts`)
- `GET /api/purchase/orders` - 查询采购订单列表（100条数据）
- `POST /api/purchase/orders` - 创建采购订单
- `GET /api/purchase/orders/:id` - 获取订单详情
- `DELETE /api/purchase/orders/:id` - 删除订单（仅草稿状态）
- `POST /api/purchase/orders/:id/submit` - 提交审核
- `POST /api/purchase/orders/:id/approve` - 审核通过
- `POST /api/purchase/orders/:id/reject` - 审核驳回

## 使用方式

### 自动启用（开发环境）

Mock 服务在开发环境下自动启用，无需手动配置。

```typescript
// main.ts
if (import.meta.env.DEV) {
  import('./mock') // 自动启用 Mock
}
```

### 禁用 Mock

如果需要连接真实后端，修改 `.env.development`：

```bash
# 注释掉或修改为后端地址
VITE_API_BASE_URL=http://localhost:8080/api
```

然后在 `main.ts` 中注释掉 Mock 导入：

```typescript
// if (import.meta.env.DEV) {
//   import('./mock')
// }
```

## 数据特点

### 1. 分页支持
所有列表接口都支持分页参数：
- `page` - 页码（从1开始）
- `size` - 每页大小（默认20）

### 2. 搜索过滤
支持多条件搜索过滤，例如：
- 用户列表：`username`、`realName`、`status`
- 产品列表：`productName`、`categoryId`、`status`
- 库存日志：`productId`、`warehouseId`、`changeType`

### 3. 数据真实性
使用 Mock.js 随机函数生成：
- 中文姓名：`Mock.Random.cname()`
- 手机号：`/^1[3-9]\d{9}$/`
- 邮箱：`Mock.Random.email()`
- 日期时间：`Mock.Random.datetime()`
- 价格金额：`Mock.Random.float(10, 1000, 2, 2)`

## 扩展 Mock

### 添加新接口

1. 在对应模块文件中添加：

```typescript
// modules/your-module.ts
Mock.mock(/\/api\/your-endpoint/, 'get', {
  code: 200,
  message: '成功',
  data: {
    // 你的数据
  },
  timestamp: Date.now()
})
```

2. 在 `index.ts` 中导入：

```typescript
import './modules/your-module'
```

### 自定义数据生成

```typescript
import Mock from 'mockjs'

const data = Mock.mock({
  'list|10': [{
    'id|+1': 1,
    'name': '@cname',
    'email': '@email',
    'age|18-60': 1,
    'createTime': '@datetime'
  }]
})
```

## 注意事项

⚠️ **Mock 数据仅用于开发和测试**
- Mock 数据存储在内存中，刷新页面会重置
- 不要在生产环境中使用 Mock 服务
- Mock 数据不会持久化到后端

⚠️ **URL 匹配规则**
- Mock.js 使用正则表达式匹配 URL
- 注意 URL 参数和路径参数的处理

⚠️ **响应延迟**
- 当前配置延迟 200-600ms 模拟真实网络
- 可在 `index.ts` 中调整 `timeout` 配置

## 调试技巧

### 1. 查看 Mock 日志

在浏览器控制台可以看到 "Mock 数据服务已启动" 消息。

### 2. 检查请求拦截

打开浏览器开发者工具 Network 面板，查看请求是否被拦截（响应来自 Mock）。

### 3. 修改 Mock 数据

直接修改对应模块文件，保存后会热更新。

## 参考资源

- [Mock.js 官方文档](http://mockjs.com/)
- [Mock.js 示例](http://mockjs.com/examples.html)
