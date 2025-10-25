# IDAP 前端开发规约

> 版本：v1.0  
> 更新时间：2025-10-25  
> 适用范围：IDAP 进销存管理系统前端项目

## 1. 技术栈

### 1.1 核心框架
- **Vue 3.5.22** - 渐进式前端框架，采用 Composition API
- **TypeScript 5.9** - 类型安全的 JavaScript 超集
- **Vite 7.1** - 下一代前端构建工具

### 1.2 UI 框架
- **Element Plus 2.11** - 基于 Vue 3 的组件库
- **@element-plus/icons-vue** - Element Plus 图标库

### 1.3 状态管理
- **Pinia 3.0** - Vue 官方推荐的状态管理库

### 1.4 路由管理
- **Vue Router 4.5** - Vue 官方路由管理器

### 1.5 开发工具
- **openapi-typescript** - 从 OpenAPI 规格自动生成 TypeScript 类型
- **axios 1.7** - HTTP 客户端
- **mockjs 1.1** - 生成随机测试数据

## 2. 项目架构

```
frontend/
├── public/                 # 静态资源
├── src/
│   ├── api/               # API 调用封装
│   │   ├── request.ts     # Axios 实例配置
│   │   ├── auth.ts        # 认证接口
│   │   ├── user.ts        # 用户管理接口
│   │   └── ...
│   ├── assets/            # 资源文件
│   │   └── styles/        # 样式文件
│   │       └── index.css  # 全局样式（含布局系统）
│   ├── components/        # 公共组件
│   │   └── layout/        # 布局组件
│   │       └── MainLayout.vue
│   ├── mock/              # Mock 数据服务
│   │   ├── index.ts       # Mock 服务入口
│   │   └── modules/       # 各模块 Mock 数据
│   ├── router/            # 路由配置
│   │   └── index.ts
│   ├── stores/            # Pinia 状态管理
│   │   └── user.ts        # 用户状态
│   ├── types/             # TypeScript 类型定义
│   │   └── api.d.ts       # 自动生成的 API 类型
│   ├── views/             # 页面组件
│   │   ├── login/         # 登录页
│   │   ├── dashboard/     # 控制台
│   │   ├── user/          # 用户管理
│   │   ├── product/       # 产品管理
│   │   └── inventory/     # 进销存管理
│   ├── App.vue            # 根组件
│   └── main.ts            # 应用入口
├── openapi.yaml           # OpenAPI 3.0 规格文件
├── package.json
├── tsconfig.json
└── vite.config.ts
```

## 3. 代码规范

### 3.1 命名规范

#### 文件命名
- **组件文件**：使用 PascalCase，如 `UserList.vue`、`MainLayout.vue`
- **工具/配置文件**：使用 kebab-case 或 camelCase，如 `request.ts`、`vite.config.ts`
- **类型定义文件**：使用 `.d.ts` 后缀，如 `api.d.ts`

#### 变量命名
- **普通变量**：camelCase，如 `userName`、`isLoading`
- **常量**：UPPER_SNAKE_CASE，如 `API_BASE_URL`、`MAX_RETRY_COUNT`
- **类型/接口**：PascalCase，如 `UserVO`、`ApiResponse`
- **私有变量**：前缀 `_`，如 `_internalState`

#### 函数命名
- **普通函数**：camelCase，动词开头，如 `loadData()`、`handleClick()`
- **事件处理函数**：`handle` 前缀，如 `handleSubmit()`、`handlePageChange()`
- **API 调用函数**：动词 + 名词，如 `getUserList()`、`createUser()`

### 3.2 TypeScript 使用

#### 类型导入
```typescript
// 从自动生成的类型文件导入
import type { components } from '@/types/api'
type UserVO = components['schemas']['UserVO']
type UserCreateRequest = components['schemas']['UserCreateRequest']
```

#### 函数类型声明
```typescript
// 使用明确的参数和返回值类型
const loadData = async (): Promise<void> => {
    // ...
}

const getUserById = (id: number): Promise<UserVO> => {
    return request.get<UserVO>(`/users/${id}`)
}
```

#### Ref 类型声明
```typescript
// 基础类型
const loading = ref<boolean>(false)
const count = ref<number>(0)
const username = ref<string>('')

// 对象类型
const formData = ref<UserCreateRequest>({
    username: '',
    password: '',
    realName: ''
})

// 数组类型
const tableData = ref<UserVO[]>([])
```

### 3.3 Vue 3 Composition API 规范

#### 组件结构顺序
```vue
<script setup lang="ts">
// 1. 类型导入
import type { components } from '@/types/api'

// 2. API 导入
import { getUserList, createUser } from '@/api/user'

// 3. 组件/工具导入
import { ElMessage } from 'element-plus'
import { Search, Refresh } from '@element-plus/icons-vue'

// 4. 生命周期导入
import { onMounted, ref } from 'vue'

// 5. 类型定义
type UserVO = components['schemas']['UserVO']

// 6. 响应式状态
const loading = ref(false)
const tableData = ref<UserVO[]>([])

// 7. 普通函数
const loadData = async () => {
    // ...
}

// 8. 事件处理函数
const handleSearch = () => {
    // ...
}

// 9. 生命周期钩子
onMounted(() => {
    loadData()
})
</script>

<template>
    <!-- 模板内容 -->
</template>

<style scoped>
/* 页面特定样式 */
</style>
```

## 4. 全局布局系统

### 4.1 布局结构

前端采用全局 CSS 布局系统（`assets/styles/index.css`），所有页面统一使用以下结构：

```vue
<template>
    <div class="page-container">
        <!-- 搜索栏（可选，固定不滚动） -->
        <el-card class="search-card">
            <el-form :model="searchForm" inline>
                <!-- 搜索表单项 -->
            </el-form>
        </el-card>

        <!-- 工具栏（可选，固定不滚动） -->
        <el-card class="toolbar-card">
            <el-button type="primary" @click="handleAdd">新增</el-button>
        </el-card>

        <!-- 数据表格（填充剩余空间，内部滚动） -->
        <el-card class="table-card">
            <el-table :data="tableData">
                <!-- 表格列 -->
            </el-table>

            <!-- 分页（固定在表格底部） -->
            <div class="pagination">
                <el-pagination 
                    v-model:current-page="searchForm.page"
                    v-model:page-size="searchForm.size"
                    :total="total"
                    layout="total, sizes, prev, pager, next, jumper"
                />
            </div>
        </el-card>
    </div>
</template>

<style scoped>
/* 页面特定样式（如果需要） */
</style>
```

### 4.2 Tabs 页面布局

对于使用 Tabs 的页面（如库存管理），需在 Tabs 内部使用相同的布局结构：

```vue
<template>
    <div class="page-container">
        <el-tabs v-model="activeTab">
            <el-tab-pane label="列表" name="list">
                <!-- 搜索栏 -->
                <el-card class="search-card">
                    <!-- ... -->
                </el-card>

                <!-- 数据表格 -->
                <el-card class="table-card">
                    <el-table :data="tableData">
                        <!-- ... -->
                    </el-table>

                    <div class="pagination">
                        <!-- ... -->
                    </div>
                </el-card>
            </el-tab-pane>
        </el-tabs>
    </div>
</template>
```

### 4.3 布局原理

全局布局使用 **Flexbox** 实现：

1. **`.page-container`**：
   - `display: flex; flex-direction: column;` - 垂直排列
   - `height: 100%; overflow: hidden` - 填满容器高度，隐藏外部滚动

2. **`.search-card`, `.toolbar-card`**：
   - `flex-shrink: 0` - 固定高度，不压缩

3. **`.table-card`**：
   - `flex: 1` - 占据剩余空间
   - `display: flex; flex-direction: column` - 内部垂直排列

4. **`.el-table`**：
   - `flex: 1` - 填充表格卡片剩余空间
   - 自动出现垂直滚动条

5. **`.pagination`**：
   - `flex-shrink: 0` - 固定在底部，不压缩

### 4.4 样式使用注意事项

- ✅ **推荐**：页面组件 `<style scoped>` 中只写页面特定样式
- ✅ **推荐**：使用全局布局类（`.page-container`、`.search-card` 等）
- ❌ **禁止**：在页面组件中重复定义布局相关的 CSS
- ❌ **禁止**：给 `el-table` 设置固定 `height` 属性（会破坏 flex 布局）

## 5. API 调用规范

### 5.1 API 封装

每个业务模块对应一个 API 文件（如 `api/user.ts`），使用统一的请求实例（`api/request.ts`）：

```typescript
// api/user.ts
import request from './request'
import type { components } from '@/types/api'

type UserVO = components['schemas']['UserVO']
type UserListParams = components['schemas']['UserListParams']

export const getUserList = (params: UserListParams) => {
    return request.get<PageResponse<UserVO>>('/users', { params })
}

export const createUser = (data: UserCreateRequest) => {
    return request.post('/users', data)
}

export const updateUser = (id: number, data: UserUpdateRequest) => {
    return request.put(`/users/${id}`, data)
}

export const deleteUser = (id: number) => {
    return request.delete(`/users/${id}`)
}
```

### 5.2 响应拦截器处理

响应拦截器已配置为自动解包 `response.data.data`，页面中直接使用：

```typescript
// ✅ 正确用法
const loadData = async () => {
    const res = await getUserList(searchForm.value)
    const data = res as any  // res 已经是 { records, total, size, current }
    tableData.value = data.records || []
    total.value = data.total || 0
}

// ❌ 错误用法
const loadData = async () => {
    const res = await getUserList(searchForm.value)
    const data = res.data  // ❌ 错误！响应拦截器已解包
    tableData.value = data.records || []
}
```

### 5.3 错误处理

在响应拦截器中统一处理错误，页面中使用 try-catch：

```typescript
const loadData = async () => {
    loading.value = true
    try {
        const res = await getUserList(searchForm.value)
        const data = res as any
        tableData.value = data.records || []
        total.value = data.total || 0
    } catch (error) {
        console.error('加载列表失败:', error)
        ElMessage.error('加载列表失败')
    } finally {
        loading.value = false
    }
}
```

## 6. Mock 数据服务

### 6.1 Mock 服务架构

- **入口文件**：`mock/index.ts` - 配置 Mock.setup()，导入所有模块
- **模块文件**：`mock/modules/*.ts` - 各业务模块的 Mock 数据和拦截规则

### 6.2 Mock 服务加载

在 `main.ts` 中使用 **async/await** 确保 Mock 服务在应用启动前加载：

```typescript
// main.ts
async function startApp() {
    if (import.meta.env.DEV) {
        await import('./mock')  // ✅ 必须 await
        console.log('Mock 服务加载完成')
    }

    const app = createApp(App)
    // ...
    app.mount('#app')
}

startApp()
```

### 6.3 编写 Mock 模块

```typescript
// mock/modules/user.ts
import Mock from 'mockjs'

// 生成测试数据
const generateUsers = (count: number) => {
    const users = []
    for (let i = 1; i <= count; i++) {
        users.push({
            id: i,
            username: `user${i}`,
            realName: Mock.Random.cname(),
            email: Mock.Random.email(),
            phone: `1${Mock.Random.integer(3, 9)}${Mock.Random.string('number', 9)}`
        })
    }
    return users
}

let userList = generateUsers(100)

// 拦截列表查询
Mock.mock(/\/api\/users(\?.*)?$/, 'get', (options: any) => {
    const url = new URL('http://localhost' + options.url)
    const page = parseInt(url.searchParams.get('page') || '1')
    const size = parseInt(url.searchParams.get('size') || '20')

    const total = userList.length
    const start = (page - 1) * size
    const records = userList.slice(start, start + size)

    return {
        code: 200,
        message: '成功',
        data: { records, total, size, current: page },
        timestamp: Date.now()
    }
})

// 拦截创建/更新/删除操作
Mock.mock(/\/api\/users$/, 'post', (options: any) => {
    const body = JSON.parse(options.body)
    const newUser = { id: userList.length + 1, ...body }
    userList.push(newUser)
    return { code: 200, message: '创建成功', data: newUser }
})
```

### 6.4 Mock 正则匹配注意事项

- 使用 `(\?.*)?$` 匹配带查询参数的 URL：`/\/api\/users(\?.*)?$/`
- 使用 `\/(\d+)$` 匹配带 ID 的 URL：`/\/api\/users\/(\d+)$/`
- 添加 `console.log` 调试拦截情况：`console.log('[Mock User] 拦截到请求:', options.url)`

## 7. 权限系统

### 7.1 权限码格式

权限码采用三段式：`模块:资源:操作`，如 `user:list:view`、`product:edit:update`

### 7.2 通配符支持

- **超级管理员**：`*:*:*` - 匹配所有权限
- **模块级权限**：`user:*:*` - 匹配 user 模块的所有权限
- **资源级权限**：`user:list:*` - 匹配 user:list 的所有操作

### 7.3 权限校验

在 `stores/user.ts` 中使用 `hasPermission()` 方法：

```typescript
// stores/user.ts
hasPermission(permission: string): boolean {
    if (!this.isLogin || !this.userInfo?.permissions) {
        return false
    }

    // 超级管理员拥有所有权限
    if (this.userInfo.permissions.includes('*:*:*')) {
        return true
    }

    // 分段匹配通配符
    const requiredParts = permission.split(':')
    
    return this.userInfo.permissions.some(p => {
        if (p === permission) return true  // 完全匹配
        
        const permParts = p.split(':')
        if (permParts.length !== requiredParts.length) return false
        
        // 逐段比较，支持通配符 *
        return permParts.every((part, i) => 
            part === '*' || part === requiredParts[i]
        )
    })
}
```

### 7.4 路由守卫

在 `router/index.ts` 中配置路由守卫：

```typescript
router.beforeEach((to, from, next) => {
    const userStore = useUserStore()
    
    if (to.meta.requiresAuth && !userStore.isLogin) {
        next('/login')
    } else if (to.meta.permission && !userStore.hasPermission(to.meta.permission)) {
        ElMessage.error('无权限访问')
        next(false)
    } else {
        next()
    }
})
```

## 8. 国际化配置

### 8.1 Element Plus 中文化

在 `main.ts` 中配置中文语言包：

```typescript
import ElementPlus from 'element-plus'
import zhCn from 'element-plus/es/locale/lang/zh-cn'

app.use(ElementPlus, {
    locale: zhCn,  // 配置中文
})
```

### 8.2 影响范围

- 分页组件：`共 200 条` 代替 `Total 200`
- 日期选择器：中文月份和星期
- 表单验证：中文错误提示
- 对话框按钮：`确定`/`取消` 代替 `OK`/`Cancel`

## 9. 常见问题与最佳实践

### 9.1 表格不滚动问题

**问题**：表格数据很多时，整个页面滚动而不是表格内部滚动

**解决**：
1. 不要给 `el-table` 设置 `height` 属性
2. 使用全局布局系统（`.page-container` + `.table-card`）
3. 表格会自动 `flex: 1` 填充剩余空间

### 9.2 Tabs 布局问题

**问题**：使用 `el-tabs` 时，内容区域无法滚动

**解决**：全局 CSS 已经使用 `!important` 覆盖 Element Plus 样式：

```css
.page-container .el-tabs {
    flex: 1;
    display: flex !important;
    flex-direction: column !important;
}

.page-container .el-tabs__content {
    flex: 1 !important;
    overflow: hidden !important;
}
```

### 9.3 Mock 数据不生效

**问题**：Mock 服务定义了拦截规则，但 API 请求返回 404

**原因**：
1. Mock 服务未在应用启动前加载（未使用 `await`）
2. 正则表达式不匹配实际请求 URL

**解决**：
1. 在 `main.ts` 中使用 `await import('./mock')`
2. 在 Mock 模块中添加 `console.log` 调试拦截情况
3. 检查正则表达式是否匹配查询参数（使用 `(\?.*)?$`）

### 9.4 字段名不匹配

**问题**：后端返回 `productName`，前端使用 `name` 导致数据不显示

**解决**：
1. 统一使用 OpenAPI 规格中定义的字段名
2. 使用自动生成的 TypeScript 类型（`components['schemas']['XXX']`）
3. TypeScript 会在编译时提示字段名错误

### 9.5 响应数据解析错误

**问题**：使用 `res.data.records` 获取不到数据

**原因**：响应拦截器已经返回 `response.data.data`

**解决**：直接使用 `res as any`，不要再访问 `.data` 属性：

```typescript
// ✅ 正确
const res = await getUserList(params)
const data = res as any
tableData.value = data.records

// ❌ 错误
const res = await getUserList(params)
const data = res.data  // ❌ 响应拦截器已解包
```

## 10. 类型生成与更新

### 10.1 生成 TypeScript 类型

从 OpenAPI 规格生成类型定义：

```bash
npm run generate:types
```

生成的类型文件位于 `src/types/api.d.ts`。

### 10.2 更新流程

1. 修改 `openapi.yaml` 规格文件
2. 运行 `npm run generate:types` 重新生成类型
3. TypeScript 会自动提示哪些地方需要更新代码

## 11. 开发流程

### 11.1 新增业务模块

1. **更新 OpenAPI 规格**：在 `openapi.yaml` 中定义接口
2. **生成类型**：运行 `npm run generate:types`
3. **创建 API 封装**：在 `src/api/` 下创建模块文件
4. **创建 Mock 数据**：在 `src/mock/modules/` 下创建 Mock 模块
5. **创建页面组件**：在 `src/views/` 下创建页面
6. **配置路由**：在 `router/index.ts` 中添加路由
7. **添加菜单**：在 `MainLayout.vue` 中添加菜单项

### 11.2 Git 提交规范

提交信息格式：

```
<类型>: <简短描述>

- <详细说明1>
- <详细说明2>
- <详细说明3>
```

类型：
- `feat`: 新功能
- `fix`: Bug 修复
- `refactor`: 重构
- `style`: 样式调整
- `docs`: 文档更新
- `test`: 测试相关
- `chore`: 构建/工具链相关

示例：

```
feat: 完善前端Mock数据服务、全局布局系统和中文国际化配置

- Mock服务实现：7个模块，生成1000+测试数据
- 全局布局系统：统一页面布局，支持Tabs结构
- Element Plus中文化：zh-cn语言包
- 权限系统增强：通配符匹配支持
```

## 12. 性能优化

### 12.1 按需导入

Element Plus 组件使用自动导入（Vite 插件配置），无需手动导入。

### 12.2 图标优化

使用 Element Plus 图标库：

```vue
<script setup>
import { Search, Edit, Delete } from '@element-plus/icons-vue'
</script>

<template>
    <el-button :icon="Search">搜索</el-button>
    <el-icon><Edit /></el-icon>
</template>
```

### 12.3 路由懒加载

使用动态导入实现路由懒加载：

```typescript
const routes = [
    {
        path: '/user',
        component: () => import('@/views/user/Index.vue')  // ✅ 懒加载
    }
]
```

## 13. 总结

本规约文档涵盖了 IDAP 前端项目的：

1. ✅ 技术栈与项目架构
2. ✅ 代码规范与命名约定
3. ✅ 全局布局系统使用指南
4. ✅ API 调用与 Mock 数据开发
5. ✅ 权限系统与路由守卫
6. ✅ 国际化配置
7. ✅ 常见问题解决方案
8. ✅ 开发流程与提交规范

遵循本规约可以确保：
- 代码风格统一，可维护性高
- 类型安全，减少运行时错误
- 布局一致，用户体验好
- 开发效率高，易于协作

---

**维护者**：前端开发团队  
**最后更新**：2025-10-25
