<script setup lang="ts">
import { useUserStore } from '@/stores/user'
import { onMounted, ref } from 'vue'

const userStore = useUserStore()

// 统计数据
const stats = ref({
    totalUsers: 0,
    totalTenants: 0,
    todayOrders: 0,
    totalRevenue: 0
})

// 加载数据
onMounted(async () => {
    // TODO: 从后端加载实际数据
    stats.value = {
        totalUsers: 1234,
        totalTenants: 56,
        todayOrders: 89,
        totalRevenue: 123456.78
    }
})
</script>

<template>
    <div class="dashboard">
        <h2 class="page-title">控制台</h2>

        <el-alert title="欢迎使用 IDAP 管理系统" type="success" :closable="false" show-icon>
            <template #default>
                当前租户：<strong>{{ userStore.userInfo?.tenantName }}</strong> |
                登录用户：<strong>{{ userStore.realName }}</strong>
            </template>
        </el-alert>

        <div class="stats-grid">
            <el-card shadow="hover" class="stat-card">
                <div class="stat-content">
                    <el-icon class="stat-icon" color="#409eff">
                        <User />
                    </el-icon>
                    <div class="stat-info">
                        <div class="stat-value">{{ stats.totalUsers }}</div>
                        <div class="stat-label">总用户数</div>
                    </div>
                </div>
            </el-card>

            <el-card shadow="hover" class="stat-card">
                <div class="stat-content">
                    <el-icon class="stat-icon" color="#67c23a">
                        <OfficeBuilding />
                    </el-icon>
                    <div class="stat-info">
                        <div class="stat-value">{{ stats.totalTenants }}</div>
                        <div class="stat-label">租户数量</div>
                    </div>
                </div>
            </el-card>

            <el-card shadow="hover" class="stat-card">
                <div class="stat-content">
                    <el-icon class="stat-icon" color="#e6a23c">
                        <ShoppingCart />
                    </el-icon>
                    <div class="stat-info">
                        <div class="stat-value">{{ stats.todayOrders }}</div>
                        <div class="stat-label">今日订单</div>
                    </div>
                </div>
            </el-card>

            <el-card shadow="hover" class="stat-card">
                <div class="stat-content">
                    <el-icon class="stat-icon" color="#f56c6c">
                        <Money />
                    </el-icon>
                    <div class="stat-info">
                        <div class="stat-value">¥{{ stats.totalRevenue.toFixed(2) }}</div>
                        <div class="stat-label">总营收</div>
                    </div>
                </div>
            </el-card>
        </div>

        <el-row :gutter="20" class="charts-row">
            <el-col :span="12">
                <el-card shadow="hover">
                    <template #header>
                        <span>销售趋势</span>
                    </template>
                    <div class="chart-placeholder">
                        <el-empty description="图表开发中" />
                    </div>
                </el-card>
            </el-col>

            <el-col :span="12">
                <el-card shadow="hover">
                    <template #header>
                        <span>库存概况</span>
                    </template>
                    <div class="chart-placeholder">
                        <el-empty description="图表开发中" />
                    </div>
                </el-card>
            </el-col>
        </el-row>
    </div>
</template>

<style scoped>
.dashboard {
    padding: 20px;
}

.page-title {
    margin: 0 0 20px 0;
    font-size: 24px;
    font-weight: bold;
    color: #333;
}

.stats-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 20px;
    margin: 20px 0;
}

.stat-card {
    cursor: pointer;
    transition: transform 0.3s;
}

.stat-card:hover {
    transform: translateY(-5px);
}

.stat-content {
    display: flex;
    align-items: center;
    gap: 20px;
}

.stat-icon {
    font-size: 48px;
}

.stat-info {
    flex: 1;
}

.stat-value {
    font-size: 28px;
    font-weight: bold;
    color: #333;
    line-height: 1.2;
}

.stat-label {
    font-size: 14px;
    color: #666;
    margin-top: 5px;
}

.charts-row {
    margin-top: 20px;
}

.chart-placeholder {
    height: 300px;
    display: flex;
    align-items: center;
    justify-content: center;
}
</style>
