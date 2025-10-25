<script setup lang="ts">
import { getDictOptions } from '@/api/dictionary'
import { createUser, deleteUser, getUserList, resetPassword, updateUser } from '@/api/user'
import type { components } from '@/types/api'
import { Delete, Edit, Key, Plus, Refresh, Search } from '@element-plus/icons-vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { onMounted, ref } from 'vue'

type UserVO = components['schemas']['UserVO']
type UserCreateRequest = components['schemas']['UserCreateRequest']
type UserUpdateRequest = components['schemas']['UserUpdateRequest']

// 列表数据
const loading = ref(false)
const tableData = ref<UserVO[]>([])
const total = ref(0)

// 搜索条件
const searchForm = ref({
    username: '',
    realName: '',
    status: undefined as 'ACTIVE' | 'LOCKED' | 'DISABLED' | undefined,
    page: 1,
    size: 20
})

// 对话框
const dialogVisible = ref(false)
const dialogTitle = ref('新增用户')
const formRef = ref()
const isEdit = ref(false)
const editId = ref(0)
const formData = ref<UserCreateRequest & Partial<UserUpdateRequest>>({
    username: '',
    password: '',
    realName: '',
    email: '',
    phone: '',
    gender: 'UNKNOWN',
    roleIds: []
})

// 密码重置对话框
const resetPwdDialogVisible = ref(false)
const resetPwdForm = ref({
    id: 0,
    newPassword: ''
})

// 字典数据
const statusOptions = ref<any[]>([])

// 表单验证规则
const rules = {
    username: [
        { required: true, message: '请输入用户名', trigger: 'blur' },
        { min: 3, max: 20, message: '长度在 3 到 20 个字符', trigger: 'blur' }
    ],
    password: [
        { required: true, message: '请输入密码', trigger: 'blur' },
        { min: 6, max: 20, message: '长度在 6 到 20 个字符', trigger: 'blur' }
    ],
    realName: [{ required: true, message: '请输入真实姓名', trigger: 'blur' }],
    email: [{ type: 'email', message: '请输入正确的邮箱地址', trigger: 'blur' }]
}

// 加载字典数据
const loadDictData = async () => {
    try {
        statusOptions.value = await getDictOptions('user_status')
    } catch (error) {
        console.error('加载字典数据失败:', error)
    }
}

// 加载列表数据
const loadData = async () => {
    loading.value = true
    try {
        const res = await getUserList(searchForm.value)
        tableData.value = (res.data as any)?.items || []
        total.value = (res.data as any)?.total || 0
    } catch (error) {
        ElMessage.error('加载用户列表失败')
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
        username: '',
        realName: '',
        status: undefined,
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
    dialogTitle.value = '新增用户'
    isEdit.value = false
    editId.value = 0
    formData.value = {
        username: '',
        password: '',
        realName: '',
        email: '',
        phone: '',
        gender: 'UNKNOWN',
        roleIds: []
    }
    dialogVisible.value = true
}

// 编辑
const handleEdit = (row: UserVO) => {
    dialogTitle.value = '编辑用户'
    isEdit.value = true
    editId.value = row.id!
    formData.value = {
        username: row.username || '',
        password: '', // 编辑时不需要密码
        realName: row.realName || '',
        email: row.email,
        phone: row.phone,
        gender: row.gender || 'UNKNOWN',
        status: row.status,
        roleIds: []
    }
    dialogVisible.value = true
}

// 删除
const handleDelete = async (row: UserVO) => {
    try {
        await ElMessageBox.confirm('确定要删除该用户吗？', '提示', {
            confirmButtonText: '确定',
            cancelButtonText: '取消',
            type: 'warning'
        })
        await deleteUser(row.id!)
        ElMessage.success('删除成功')
        loadData()
    } catch (error: any) {
        if (error !== 'cancel') {
            ElMessage.error('删除失败')
        }
    }
}

// 重置密码
const handleResetPassword = (row: UserVO) => {
    resetPwdForm.value = {
        id: row.id!,
        newPassword: ''
    }
    resetPwdDialogVisible.value = true
}

// 提交重置密码
const submitResetPassword = async () => {
    try {
        await resetPassword(resetPwdForm.value.id, {
            newPassword: resetPwdForm.value.newPassword
        })
        ElMessage.success('密码重置成功')
        resetPwdDialogVisible.value = false
    } catch (error) {
        ElMessage.error('密码重置失败')
    }
}

// 提交表单
const submitForm = async () => {
    await formRef.value?.validate()
    try {
        if (isEdit.value) {
            // 编辑 - 使用 UserUpdateRequest
            const updateData: UserUpdateRequest = {
                realName: formData.value.realName,
                email: formData.value.email,
                phone: formData.value.phone,
                gender: formData.value.gender,
                status: formData.value.status
            }
            await updateUser(editId.value, updateData)
            ElMessage.success('更新成功')
        } else {
            // 新增 - 使用 UserCreateRequest
            const createData: UserCreateRequest = {
                username: formData.value.username,
                password: formData.value.password,
                realName: formData.value.realName,
                email: formData.value.email,
                phone: formData.value.phone,
                gender: formData.value.gender,
                roleIds: formData.value.roleIds
            }
            await createUser(createData)
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
        ACTIVE: 'success',
        LOCKED: 'danger',
        DISABLED: 'info'
    }
    return map[status || ''] || 'info'
}

onMounted(() => {
    loadDictData()
    loadData()
})
</script>

<template>
    <div class="page-container">
        <!-- 搜索栏 -->
        <el-card class="search-card">
            <el-form :model="searchForm" inline>
                <el-form-item label="用户名">
                    <el-input
                        v-model="searchForm.username"
                        placeholder="请输入用户名"
                        clearable
                        @keyup.enter="handleSearch"
                    />
                </el-form-item>
                <el-form-item label="姓名">
                    <el-input
                        v-model="searchForm.realName"
                        placeholder="请输入姓名"
                        clearable
                        @keyup.enter="handleSearch"
                    />
                </el-form-item>
                <el-form-item label="状态">
                    <el-select v-model="searchForm.status" placeholder="请选择状态" clearable>
                        <el-option
                            v-for="item in statusOptions"
                            :key="item.dictValue"
                            :label="item.dictLabel"
                            :value="item.dictValue"
                        />
                    </el-select>
                </el-form-item>
                <el-form-item>
                    <el-button type="primary" :icon="Search" @click="handleSearch">搜索</el-button>
                    <el-button :icon="Refresh" @click="handleReset">重置</el-button>
                </el-form-item>
            </el-form>
        </el-card>

        <!-- 工具栏 -->
        <el-card class="toolbar-card">
            <el-button type="primary" :icon="Plus" @click="handleAdd">新增用户</el-button>
        </el-card>

        <!-- 数据表格 -->
        <el-card class="table-card">
            <el-table :data="tableData" v-loading="loading" border stripe>
                <el-table-column prop="id" label="ID" width="80" />
                <el-table-column prop="username" label="用户名" width="150" />
                <el-table-column prop="realName" label="姓名" width="120" />
                <el-table-column prop="email" label="邮箱" width="200" />
                <el-table-column prop="phone" label="手机号" width="130" />
                <el-table-column prop="status" label="状态" width="100">
                    <template #default="{ row }">
                        <el-tag :type="getStatusType(row.status)">
                            {{ row.status }}
                        </el-tag>
                    </template>
                </el-table-column>
                <el-table-column prop="createdAt" label="创建时间" width="180" />
                <el-table-column label="操作" fixed="right" width="240">
                    <template #default="{ row }">
                        <el-button link type="primary" :icon="Edit" @click="handleEdit(row)">
                            编辑
                        </el-button>
                        <el-button
                            link
                            type="warning"
                            :icon="Key"
                            @click="handleResetPassword(row)"
                        >
                            重置密码
                        </el-button>
                        <el-button link type="danger" :icon="Delete" @click="handleDelete(row)">
                            删除
                        </el-button>
                    </template>
                </el-table-column>
            </el-table>

            <!-- 分页 -->
            <div class="pagination">
                <el-pagination
                    v-model:current-page="searchForm.page"
                    v-model:page-size="searchForm.size"
                    :page-sizes="[10, 20, 50, 100]"
                    :total="total"
                    layout="total, sizes, prev, pager, next, jumper"
                    @size-change="handleSizeChange"
                    @current-change="handlePageChange"
                />
            </div>
        </el-card>

        <!-- 新增/编辑对话框 -->
        <el-dialog
            v-model="dialogVisible"
            :title="dialogTitle"
            width="600px"
            :close-on-click-modal="false"
        >
            <el-form ref="formRef" :model="formData" :rules="rules" label-width="100px">
                <el-form-item label="用户名" prop="username">
                    <el-input v-model="formData.username" placeholder="请输入用户名" />
                </el-form-item>
                <el-form-item label="密码" prop="password" v-if="!isEdit">
                    <el-input
                        v-model="formData.password"
                        type="password"
                        placeholder="请输入密码"
                        show-password
                    />
                </el-form-item>
                <el-form-item label="真实姓名" prop="realName">
                    <el-input v-model="formData.realName" placeholder="请输入真实姓名" />
                </el-form-item>
                <el-form-item label="邮箱" prop="email">
                    <el-input v-model="formData.email" placeholder="请输入邮箱" />
                </el-form-item>
                <el-form-item label="手机号" prop="phone">
                    <el-input v-model="formData.phone" placeholder="请输入手机号" />
                </el-form-item>
                <el-form-item label="状态" prop="status">
                    <el-radio-group v-model="formData.status">
                        <el-radio
                            v-for="item in statusOptions"
                            :key="item.dictValue"
                            :value="item.dictValue"
                        >
                            {{ item.dictLabel }}
                        </el-radio>
                    </el-radio-group>
                </el-form-item>
            </el-form>
            <template #footer>
                <el-button @click="dialogVisible = false">取消</el-button>
                <el-button type="primary" @click="submitForm">确定</el-button>
            </template>
        </el-dialog>

        <!-- 重置密码对话框 -->
        <el-dialog
            v-model="resetPwdDialogVisible"
            title="重置密码"
            width="400px"
            :close-on-click-modal="false"
        >
            <el-form :model="resetPwdForm" label-width="100px">
                <el-form-item label="新密码" required>
                    <el-input
                        v-model="resetPwdForm.newPassword"
                        type="password"
                        placeholder="请输入新密码"
                        show-password
                    />
                </el-form-item>
            </el-form>
            <template #footer>
                <el-button @click="resetPwdDialogVisible = false">取消</el-button>
                <el-button type="primary" @click="submitResetPassword">确定</el-button>
            </template>
        </el-dialog>
    </div>
</template>

<style scoped>
.page-container {
    padding: 20px;
}

.search-card,
.toolbar-card,
.table-card {
    margin-bottom: 20px;
}

.pagination {
    margin-top: 20px;
    display: flex;
    justify-content: flex-end;
}
</style>
