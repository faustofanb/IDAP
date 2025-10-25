/**
 * Vue Router 配置
 * 路由守卫、权限验证、租户上下文检查
 */
import { useUserStore } from '@/stores/user'
import { ElMessage } from 'element-plus'
import { createRouter, createWebHistory, type RouteRecordRaw } from 'vue-router'

/**
 * 路由配置
 */
const routes: RouteRecordRaw[] = [
    {
        path: '/login',
        name: 'Login',
        component: () => import('@/views/auth/Login.vue'),
        meta: { requiresAuth: false, title: '登录' }
    },
    {
        path: '/',
        name: 'Layout',
        component: () => import('@/components/layout/MainLayout.vue'),
        redirect: '/dashboard',
        meta: { requiresAuth: true },
        children: [
            {
                path: '/dashboard',
                name: 'Dashboard',
                component: () => import('@/views/Dashboard.vue'),
                meta: { title: '控制台', icon: 'HomeFilled' }
            },
            // 租户管理
            {
                path: '/tenant',
                name: 'Tenant',
                component: () => import('@/views/tenant/Index.vue'),
                meta: { title: '租户管理', icon: 'OfficeBuilding', permission: 'tenant:view' }
            },
            // 用户管理
            {
                path: '/user',
                name: 'User',
                component: () => import('@/views/user/Index.vue'),
                meta: { title: '用户管理', icon: 'User', permission: 'user:view' }
            },
            // 角色管理
            {
                path: '/role',
                name: 'Role',
                component: () => import('@/views/role/Index.vue'),
                meta: { title: '角色管理', icon: 'UserFilled', permission: 'role:view' }
            },
            // 菜单管理
            {
                path: '/menu',
                name: 'Menu',
                component: () => import('@/views/menu/Index.vue'),
                meta: { title: '菜单管理', icon: 'Menu', permission: 'menu:view' }
            },
            // 权限管理
            {
                path: '/permission',
                name: 'Permission',
                component: () => import('@/views/permission/Index.vue'),
                meta: { title: '权限管理', icon: 'Lock', permission: 'permission:view' }
            },
            // 报表展示
            {
                path: '/report',
                name: 'Report',
                component: () => import('@/views/report/Index.vue'),
                meta: { title: '报表中心', icon: 'DataAnalysis', permission: 'report:view' }
            },
            // 进销存管理
            {
                path: '/inventory',
                name: 'Inventory',
                redirect: '/inventory/purchase',
                meta: { title: '进销存管理', icon: 'Box' },
                children: [
                    {
                        path: '/inventory/purchase',
                        name: 'Purchase',
                        component: () => import('@/views/inventory/Purchase.vue'),
                        meta: { title: '采购管理', permission: 'inventory:purchase:view' }
                    },
                    {
                        path: '/inventory/sales',
                        name: 'Sales',
                        component: () => import('@/views/inventory/Sales.vue'),
                        meta: { title: '销售管理', permission: 'inventory:sales:view' }
                    },
                    {
                        path: '/inventory/stock',
                        name: 'Stock',
                        component: () => import('@/views/inventory/Stock.vue'),
                        meta: { title: '库存管理', permission: 'inventory:stock:view' }
                    },
                    {
                        path: '/inventory/product',
                        name: 'Product',
                        component: () => import('@/views/product/Index.vue'),
                        meta: { title: '产品管理', permission: 'inventory:product:view' }
                    }
                ]
            }
        ]
    },
    {
        path: '/:pathMatch(.*)*',
        name: 'NotFound',
        component: () => import('@/views/NotFound.vue'),
        meta: { title: '404' }
    }
]

/**
 * 创建路由实例
 */
const router = createRouter({
    history: createWebHistory(import.meta.env.BASE_URL),
    routes
})

/**
 * 全局前置守卫
 * - 认证检查
 * - 租户上下文验证
 * - 权限校验
 */
router.beforeEach((to, _from, next) => {
    const userStore = useUserStore()

    // 设置页面标题
    document.title = to.meta.title ? `${to.meta.title} - IDAP` : 'IDAP'

    // 如果不需要认证，直接放行
    if (!to.meta.requiresAuth) {
        next()
        return
    }

    // 检查是否已登录
    if (!userStore.isLoggedIn) {
        ElMessage.warning('请先登录')
        next({ name: 'Login', query: { redirect: to.fullPath } })
        return
    }

    // 检查租户上下文（多租户核心）
    if (!userStore.tenantId) {
        ElMessage.error('租户信息缺失，请重新登录')
        userStore.logout()
        next({ name: 'Login' })
        return
    }

    // 检查权限
    if (to.meta.permission) {
        if (!userStore.hasPermission(to.meta.permission as string)) {
            ElMessage.error('权限不足，无法访问此页面')
            next({ name: 'Dashboard' })
            return
        }
    }

    next()
})

/**
 * 全局后置钩子
 */
router.afterEach(() => {
    // 可以在此添加页面访问日志等
})

export default router
