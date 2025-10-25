<script setup lang="ts">
import { createProduct, deleteProduct, getProductList, updateProduct } from '@/api/product'
import type { components } from '@/types/api'
import { Delete, Edit, Plus, Refresh, Search } from '@element-plus/icons-vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { onMounted, ref } from 'vue'

type ProductVO = components['schemas']['ProductVO']
type ProductCreateRequest = components['schemas']['ProductCreateRequest']

// 列表数据
const loading = ref(false)
const tableData = ref<ProductVO[]>([])
const total = ref(0)

// 搜索条件
const searchForm = ref({
    name: '',
    sku: '',
    categoryId: undefined as number | undefined,
    page: 1,
    size: 20
})

// 对话框
const dialogVisible = ref(false)
const dialogTitle = ref('新增产品')
const formRef = ref()
const isEdit = ref(false)
const editId = ref(0)
const formData = ref<ProductCreateRequest>({
    productCode: '',
    productName: '',
    categoryId: 0,
    unit: '',
    spec: '',
    brand: '',
    barcode: ''
})

// 表单验证规则
const rules = {
    productCode: [{ required: true, message: '请输入产品编码', trigger: 'blur' }],
    productName: [{ required: true, message: '请输入产品名称', trigger: 'blur' }],
    categoryId: [{ required: true, message: '请选择产品分类', trigger: 'change' }],
    sku: [{ required: true, message: '请输入SKU编码', trigger: 'blur' }],
    unit: [{ required: true, message: '请输入单位', trigger: 'blur' }]
}

// 加载列表数据
const loadData = async () => {
    loading.value = true
    try {
        const res = await getProductList(searchForm.value)
        // 响应拦截器已经返回了 data，所以 res 直接就是数据对象
        const data = res as any
        tableData.value = data?.records || []
        total.value = data?.total || 0
    } catch (error) {
        console.error('加载产品列表失败:', error)
        ElMessage.error('加载产品列表失败')
    } finally {
        loading.value = false
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
        name: '',
        sku: '',
        categoryId: undefined,
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

// 新增
const handleAdd = () => {
    dialogTitle.value = '新增产品'
    isEdit.value = false
    editId.value = 0
    formData.value = {
        productCode: '',
        productName: '',
        categoryId: 0,
        unit: '',
        spec: '',
        brand: '',
        barcode: ''
    }
    dialogVisible.value = true
}

// 编辑
const handleEdit = (row: ProductVO) => {
    dialogTitle.value = '编辑产品'
    isEdit.value = true
    editId.value = row.id!
    formData.value = {
        productCode: row.productCode || '',
        productName: row.productName || '',
        categoryId: row.categoryId!,
        unit: row.unit || '',
        spec: row.spec,
        brand: row.brand,
        barcode: row.barcode,
        purchasePrice: row.purchasePrice,
        salePrice: row.salePrice,
        minStock: row.minStock
    }
    dialogVisible.value = true
}

// 删除
const handleDelete = async (row: ProductVO) => {
    try {
        await ElMessageBox.confirm('确定要删除该产品吗？', '提示', {
            confirmButtonText: '确定',
            cancelButtonText: '取消',
            type: 'warning'
        })
        await deleteProduct(row.id!)
        ElMessage.success('删除成功')
        loadData()
    } catch (error: any) {
        if (error !== 'cancel') {
            ElMessage.error('删除失败')
        }
    }
}

// 提交表单
const submitForm = async () => {
    await formRef.value?.validate()
    try {
        if (isEdit.value) {
            await updateProduct(editId.value, formData.value)
            ElMessage.success('更新成功')
        } else {
            await createProduct(formData.value)
            ElMessage.success('创建成功')
        }
        dialogVisible.value = false
        loadData()
    } catch (error) {
        ElMessage.error(isEdit.value ? '更新失败' : '创建失败')
    }
}

// 状态标签类型
const getStatusType = (status?: string) => {
    const map: Record<string, any> = {
        ON_SALE: 'success',
        OFF_SALE: 'info',
        OUT_OF_STOCK: 'warning'
    }
    return map[status || ''] || 'info'
}

onMounted(() => {
    loadData()
})
</script>

<template>
    <div class="page-container">
        <!-- 搜索栏 -->
        <el-card class="search-card">
            <el-form :model="searchForm" inline>
                <el-form-item label="产品名称">
                    <el-input v-model="searchForm.name" placeholder="请输入产品名称" clearable @keyup.enter="handleSearch" />
                </el-form-item>
                <el-form-item label="SKU编码">
                    <el-input v-model="searchForm.sku" placeholder="请输入SKU编码" clearable @keyup.enter="handleSearch" />
                </el-form-item>
                <el-form-item>
                    <el-button type="primary" :icon="Search" @click="handleSearch">搜索</el-button>
                    <el-button :icon="Refresh" @click="handleReset">重置</el-button>
                </el-form-item>
            </el-form>
        </el-card>

        <!-- 工具栏 -->
        <el-card class="toolbar-card">
            <el-button type="primary" :icon="Plus" @click="handleAdd">新增产品</el-button>
        </el-card>

        <!-- 数据表格 -->
        <el-card class="table-card">
            <el-table :data="tableData" v-loading="loading" border stripe>
                <el-table-column prop="id" label="ID" width="80" fixed />
                <el-table-column prop="productCode" label="产品编码" width="150" />
                <el-table-column prop="productName" label="产品名称" min-width="200" />
                <el-table-column prop="categoryName" label="分类" width="120" />
                <el-table-column prop="barcode" label="条形码" width="150" />
                <el-table-column prop="unit" label="单位" width="80" />
                <el-table-column prop="spec" label="规格" width="120" />
                <el-table-column prop="brand" label="品牌" width="120" />
                <el-table-column prop="purchasePrice" label="采购价" width="100">
                    <template #default="{ row }">
                        ¥{{ row.purchasePrice?.toFixed(2) || '0.00' }}
                    </template>
                </el-table-column>
                <el-table-column prop="salePrice" label="销售价" width="100">
                    <template #default="{ row }">
                        ¥{{ row.salePrice?.toFixed(2) || '0.00' }}
                    </template>
                </el-table-column>
                <el-table-column prop="status" label="状态" width="100">
                    <template #default="{ row }">
                        <el-tag :type="getStatusType(row.status)">
                            {{ row.status }}
                        </el-tag>
                    </template>
                </el-table-column>
                <el-table-column label="操作" fixed="right" width="180">
                    <template #default="{ row }">
                        <el-button link type="primary" :icon="Edit" @click="handleEdit(row)">
                            编辑
                        </el-button>
                        <el-button link type="danger" :icon="Delete" @click="handleDelete(row)">
                            删除
                        </el-button>
                    </template>
                </el-table-column>
            </el-table>

            <!-- 分页 -->
            <div class="pagination">
                <el-pagination v-model:current-page="searchForm.page" v-model:page-size="searchForm.size"
                    :page-sizes="[10, 20, 50, 100]" :total="total" layout="total, sizes, prev, pager, next, jumper"
                    @size-change="handleSizeChange" @current-change="handlePageChange" />
            </div>
        </el-card>

        <!-- 新增/编辑对话框 -->
        <el-dialog v-model="dialogVisible" :title="dialogTitle" width="700px" :close-on-click-modal="false">
            <el-form ref="formRef" :model="formData" :rules="rules" label-width="110px">
                <el-row :gutter="20">
                    <el-col :span="12">
                        <el-form-item label="产品分类" prop="categoryId">
                            <el-input-number v-model="formData.categoryId" :min="1" placeholder="请输入分类ID"
                                style="width: 100%" />
                        </el-form-item>
                    </el-col>
                    <el-col :span="12">
                        <el-form-item label="产品名称" prop="productName">
                            <el-input v-model="formData.productName" placeholder="请输入产品名称" />
                        </el-form-item>
                    </el-col>
                </el-row>

                <el-row :gutter="20">
                    <el-col :span="12">
                        <el-form-item label="产品编码" prop="productCode">
                            <el-input v-model="formData.productCode" placeholder="请输入产品编码" />
                        </el-form-item>
                    </el-col>
                    <el-col :span="12">
                        <el-form-item label="条形码" prop="barcode">
                            <el-input v-model="formData.barcode" placeholder="请输入条形码" />
                        </el-form-item>
                    </el-col>
                </el-row>

                <el-row :gutter="20">
                    <el-col :span="12">
                        <el-form-item label="单位" prop="unit">
                            <el-input v-model="formData.unit" placeholder="如：件、箱、个" />
                        </el-form-item>
                    </el-col>
                    <el-col :span="12">
                        <el-form-item label="规格" prop="spec">
                            <el-input v-model="formData.spec" placeholder="请输入规格" />
                        </el-form-item>
                    </el-col>
                </el-row>

                <el-row :gutter="20">
                    <el-col :span="12">
                        <el-form-item label="品牌" prop="brand">
                            <el-input v-model="formData.brand" placeholder="请输入品牌" />
                        </el-form-item>
                    </el-col>
                </el-row>

                <el-row :gutter="20">
                    <el-col :span="12">
                        <el-form-item label="采购价" prop="purchasePrice">
                            <el-input-number v-model="formData.purchasePrice" :min="0" :precision="2"
                                placeholder="请输入采购价" style="width: 100%" />
                        </el-form-item>
                    </el-col>
                    <el-col :span="12">
                        <el-form-item label="销售价" prop="salePrice">
                            <el-input-number v-model="formData.salePrice" :min="0" :precision="2" placeholder="请输入销售价"
                                style="width: 100%" />
                        </el-form-item>
                    </el-col>
                </el-row>

                <el-row :gutter="20">
                    <el-col :span="12">
                        <el-form-item label="最小库存" prop="minStock">
                            <el-input-number v-model="formData.minStock" :min="0" placeholder="请输入最小库存"
                                style="width: 100%" />
                        </el-form-item>
                    </el-col>
                </el-row>
            </el-form>
            <template #footer>
                <el-button @click="dialogVisible = false">取消</el-button>
                <el-button type="primary" @click="submitForm">确定</el-button>
            </template>
        </el-dialog>
    </div>
</template>

<style scoped>
/* 页面特定样式（如果需要） */
</style>
