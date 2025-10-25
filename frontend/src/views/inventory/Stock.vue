<script setup lang="ts">
import { getStockList, getStockLogs } from '@/api/stock'
import type { components } from '@/types/api'
import { Refresh, Search } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'
import { onMounted, ref } from 'vue'

type StockVO = components['schemas']['StockVO']
type StockLogVO = components['schemas']['StockLogVO']

// Tab 活动标签
const activeTab = ref('list')

// 库存列表数据
const loading = ref(false)
const tableData = ref<StockVO[]>([])
const total = ref(0)

// 搜索条件
const searchForm = ref({
  productName: '',
  warehouseId: undefined as number | undefined,
  page: 1,
  size: 20
})

// 库存日志数据
const logLoading = ref(false)
const logTableData = ref<StockLogVO[]>([])
const logTotal = ref(0)

// 日志搜索条件
const logSearchForm = ref({
  productId: undefined as number | undefined,
  warehouseId: undefined as number | undefined,
  changeType: undefined as string | undefined,
  page: 1,
  size: 20
})

// 加载库存列表
const loadData = async () => {
  loading.value = true
  try {
    const res = await getStockList(searchForm.value)
    tableData.value = (res.data as any)?.items || []
    total.value = (res.data as any)?.total || 0
  } catch (error) {
    ElMessage.error('加载库存列表失败')
  } finally {
    loading.value = false
  }
}

// 加载库存日志
const loadLogData = async () => {
  logLoading.value = true
  try {
    const res = await getStockLogs(logSearchForm.value)
    logTableData.value = (res.data as any)?.items || []
    logTotal.value = (res.data as any)?.total || 0
  } catch (error) {
    ElMessage.error('加载库存日志失败')
  } finally {
    logLoading.value = false
  }
}

// 搜索
const handleSearch = () => {
  searchForm.value.page = 1
  loadData()
}

// 重置搜索
const handleReset = () => {
  searchForm.value = {
    productName: '',
    warehouseId: undefined,
    page: 1,
    size: 20
  }
  loadData()
}

// 分页
const handlePageChange = (page: number) => {
  searchForm.value.page = page
  loadData()
}

const handleSizeChange = (size: number) => {
  searchForm.value.size = size
  searchForm.value.page = 1
  loadData()
}

// 日志搜索
const handleLogSearch = () => {
  logSearchForm.value.page = 1
  loadLogData()
}

// 日志重置搜索
const handleLogReset = () => {
  logSearchForm.value = {
    productId: undefined,
    warehouseId: undefined,
    changeType: undefined,
    page: 1,
    size: 20
  }
  loadLogData()
}

// 日志分页
const handleLogPageChange = (page: number) => {
  logSearchForm.value.page = page
  loadLogData()
}

const handleLogSizeChange = (size: number) => {
  logSearchForm.value.size = size
  logSearchForm.value.page = 1
  loadLogData()
}

// Tab 切换
const handleTabChange = (name: string) => {
  if (name === 'list') {
    loadData()
  } else if (name === 'log') {
    loadLogData()
  }
}

// 库存状态标签
const getStockStatus = (stock: StockVO) => {
  const quantity = stock.availableQuantity || 0

  if (quantity <= 0) {
    return { text: '缺货', type: 'danger' }
  } else if (quantity < 10) {
    return { text: '库存不足', type: 'warning' }
  }
  return { text: '正常', type: 'success' }
}

// 变动类型标签
const getChangeType = (type?: string) => {
  const map: Record<string, { text: string; type: any }> = {
    IN: { text: '入库', type: 'success' },
    OUT: { text: '出库', type: 'danger' },
    TRANSFER: { text: '调拨', type: 'warning' },
    ADJUST: { text: '调整', type: 'info' }
  }
  return map[type || ''] || { text: type, type: 'info' }
}

onMounted(() => {
  loadData()
})
</script>

<template>
  <div class="page-container">
    <el-tabs v-model="activeTab" @tab-change="handleTabChange">
      <!-- 库存列表 -->
      <el-tab-pane label="库存列表" name="list">
        <!-- 搜索栏 -->
        <el-card class="search-card">
          <el-form :model="searchForm" inline>
            <el-form-item label="产品名称">
              <el-input v-model="searchForm.productName" placeholder="请输入产品名称" clearable @keyup.enter="handleSearch" />
            </el-form-item>
            <el-form-item label="仓库ID">
              <el-input-number v-model="searchForm.warehouseId" :min="1" placeholder="请输入仓库ID" clearable />
            </el-form-item>
            <el-form-item>
              <el-button type="primary" :icon="Search" @click="handleSearch">搜索</el-button>
              <el-button :icon="Refresh" @click="handleReset">重置</el-button>
            </el-form-item>
          </el-form>
        </el-card>

        <!-- 数据表格 -->
        <el-card class="table-card">
          <el-table :data="tableData" v-loading="loading" border stripe>
            <el-table-column prop="id" label="ID" width="80" />
            <el-table-column prop="warehouseName" label="仓库" width="120" />
            <el-table-column prop="productName" label="产品名称" min-width="200" />
            <el-table-column prop="productSku" label="SKU" width="150" />
            <el-table-column prop="totalQuantity" label="总库存" width="100" align="right" />
            <el-table-column prop="availableQuantity" label="可用库存" width="100" align="right" />
            <el-table-column prop="lockedQuantity" label="锁定库存" width="100" align="right" />
            <el-table-column label="库存状态" width="120">
              <template #default="{ row }">
                <el-tag :type="getStockStatus(row).type">
                  {{ getStockStatus(row).text }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="updatedAt" label="更新时间" width="180" />
          </el-table>

          <!-- 分页 -->
          <div class="pagination">
            <el-pagination v-model:current-page="searchForm.page" v-model:page-size="searchForm.size"
              :page-sizes="[10, 20, 50, 100]" :total="total" layout="total, sizes, prev, pager, next, jumper"
              @size-change="handleSizeChange" @current-change="handlePageChange" />
          </div>
        </el-card>
      </el-tab-pane>

      <!-- 库存日志 -->
      <el-tab-pane label="库存日志" name="log">
        <!-- 搜索栏 -->
        <el-card class="search-card">
          <el-form :model="logSearchForm" inline>
            <el-form-item label="产品ID">
              <el-input-number v-model="logSearchForm.productId" :min="1" placeholder="请输入产品ID" clearable />
            </el-form-item>
            <el-form-item label="仓库ID">
              <el-input-number v-model="logSearchForm.warehouseId" :min="1" placeholder="请输入仓库ID" clearable />
            </el-form-item>
            <el-form-item label="变动类型">
              <el-select v-model="logSearchForm.changeType" placeholder="请选择类型" clearable>
                <el-option label="入库" value="IN" />
                <el-option label="出库" value="OUT" />
                <el-option label="调拨" value="TRANSFER" />
                <el-option label="调整" value="ADJUST" />
              </el-select>
            </el-form-item>
            <el-form-item>
              <el-button type="primary" :icon="Search" @click="handleLogSearch">搜索</el-button>
              <el-button :icon="Refresh" @click="handleLogReset">重置</el-button>
            </el-form-item>
          </el-form>
        </el-card>

        <!-- 数据表格 -->
        <el-card class="table-card">
          <el-table :data="logTableData" v-loading="logLoading" border stripe>
            <el-table-column prop="id" label="ID" width="80" />
            <el-table-column prop="changeType" label="变动类型" width="100">
              <template #default="{ row }">
                <el-tag :type="getChangeType(row.changeType).type">
                  {{ getChangeType(row.changeType).text }}
                </el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="warehouseName" label="仓库" width="120" />
            <el-table-column prop="productName" label="产品名称" min-width="180" />
            <el-table-column prop="productSku" label="SKU" width="130" />
            <el-table-column prop="changeQuantity" label="变动数量" width="100" align="right">
              <template #default="{ row }">
                <span :style="{ color: row.changeQuantity > 0 ? 'green' : 'red' }">
                  {{ row.changeQuantity > 0 ? '+' : '' }}{{ row.changeQuantity }}
                </span>
              </template>
            </el-table-column>
            <el-table-column prop="beforeQuantity" label="变动前" width="100" align="right" />
            <el-table-column prop="afterQuantity" label="变动后" width="100" align="right" />
            <el-table-column prop="bizType" label="业务类型" width="100" />
            <el-table-column prop="bizNo" label="业务单号" width="150" />
            <el-table-column prop="createdAt" label="变动时间" width="180" />
            <el-table-column prop="remark" label="备注" min-width="150" show-overflow-tooltip />
          </el-table>

          <!-- 分页 -->
          <div class="pagination">
            <el-pagination v-model:current-page="logSearchForm.page" v-model:page-size="logSearchForm.size"
              :page-sizes="[10, 20, 50, 100]" :total="logTotal" layout="total, sizes, prev, pager, next, jumper"
              @size-change="handleLogSizeChange" @current-change="handleLogPageChange" />
          </div>
        </el-card>
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<style scoped>
.page-container {
  padding: 20px;
}

.search-card,
.table-card {
  margin-bottom: 20px;
}

.pagination {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}
</style>
