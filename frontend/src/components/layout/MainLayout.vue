<script setup lang="ts">
import { useUserStore } from '@/stores/user'
import { ElMessage } from 'element-plus'
import { ref } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()
const userStore = useUserStore()

// 侧边栏折叠状态
const isCollapse = ref(false)

// 退出登录
const handleLogout = () => {
    ElMessage.success('退出登录成功')
    userStore.logout()
    router.push('/login')
}

// 菜单项（后续可从后端动态获取）
const menuItems = [
    { path: '/dashboard', title: '控制台', icon: 'HomeFilled' },
    { path: '/tenant', title: '租户管理', icon: 'OfficeBuilding' },
    { path: '/user', title: '用户管理', icon: 'User' },
    { path: '/role', title: '角色管理', icon: 'UserFilled' },
    { path: '/menu', title: '菜单管理', icon: 'Menu' },
    { path: '/permission', title: '权限管理', icon: 'Lock' },
    { path: '/report', title: '报表中心', icon: 'DataAnalysis' },
    {
        path: '/inventory',
        title: '进销存管理',
        icon: 'Box',
        children: [
            { path: '/inventory/purchase', title: '采购管理' },
            { path: '/inventory/sales', title: '销售管理' },
            { path: '/inventory/stock', title: '库存管理' }
        ]
    }
]
</script>

<template>
    <el-container class="main-layout">
        <!-- 顶部导航栏 -->
        <el-header class="header">
            <div class="header-left">
                <el-icon class="menu-toggle" @click="isCollapse = !isCollapse">
                    <Fold v-if="!isCollapse" />
                    <Expand v-else />
                </el-icon>
                <h1 class="logo">IDAP 管理系统</h1>
            </div>

            <div class="header-right">
                <el-tag type="info" class="tenant-tag">
                    {{ userStore.userInfo?.tenantName || '未知租户' }}
                </el-tag>

                <el-dropdown @command="handleLogout">
                    <span class="user-info">
                        <el-avatar :size="32" :src="userStore.userInfo?.avatar">
                            {{ userStore.realName?.charAt(0) || 'U' }}
                        </el-avatar>
                        <span class="username">{{ userStore.realName || userStore.username }}</span>
                    </span>
                    <template #dropdown>
                        <el-dropdown-menu>
                            <el-dropdown-item disabled>个人中心</el-dropdown-item>
                            <el-dropdown-item divided command="logout">退出登录</el-dropdown-item>
                        </el-dropdown-menu>
                    </template>
                </el-dropdown>
            </div>
        </el-header>

        <el-container class="main-container">
            <!-- 侧边栏菜单 -->
            <el-aside :width="isCollapse ? '64px' : '200px'" class="sidebar">
                <el-menu :default-active="$route.path" :collapse="isCollapse" router unique-opened>
                    <template v-for="item in menuItems" :key="item.path">
                        <!-- 有子菜单 -->
                        <el-sub-menu v-if="item.children" :index="item.path">
                            <template #title>
                                <el-icon>
                                    <component :is="item.icon" />
                                </el-icon>
                                <span>{{ item.title }}</span>
                            </template>
                            <el-menu-item
                                v-for="child in item.children"
                                :key="child.path"
                                :index="child.path"
                            >
                                {{ child.title }}
                            </el-menu-item>
                        </el-sub-menu>

                        <!-- 无子菜单 -->
                        <el-menu-item v-else :index="item.path">
                            <el-icon>
                                <component :is="item.icon" />
                            </el-icon>
                            <template #title>{{ item.title }}</template>
                        </el-menu-item>
                    </template>
                </el-menu>
            </el-aside>

            <!-- 主内容区 -->
            <el-main class="content">
                <router-view />
            </el-main>
        </el-container>
    </el-container>
</template>

<style scoped>
.main-layout {
    height: 100vh;
}

.header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    background-color: #fff;
    border-bottom: 1px solid #e6e6e6;
    padding: 0 20px;
}

.header-left {
    display: flex;
    align-items: center;
    gap: 16px;
}

.menu-toggle {
    font-size: 20px;
    cursor: pointer;
    transition: color 0.3s;
}

.menu-toggle:hover {
    color: #409eff;
}

.logo {
    font-size: 20px;
    font-weight: bold;
    margin: 0;
    color: #409eff;
}

.header-right {
    display: flex;
    align-items: center;
    gap: 16px;
}

.tenant-tag {
    margin-right: 8px;
}

.user-info {
    display: flex;
    align-items: center;
    gap: 8px;
    cursor: pointer;
    padding: 4px 8px;
    border-radius: 4px;
    transition: background-color 0.3s;
}

.user-info:hover {
    background-color: #f5f5f5;
}

.username {
    font-size: 14px;
    color: #333;
}

.main-container {
    height: calc(100vh - 60px);
}

.sidebar {
    background-color: #fff;
    border-right: 1px solid #e6e6e6;
    transition: width 0.3s;
    overflow-x: hidden;
}

.content {
    background-color: #f5f5f5;
    padding: 20px;
    overflow-y: auto;
}
</style>
