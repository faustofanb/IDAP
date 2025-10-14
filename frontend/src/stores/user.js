import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export const useUserStore = defineStore('user', () => {
    const user = ref(null)
    const token = ref(localStorage.getItem('token') || '')

    const isAuthenticated = computed(() => !!token.value)
    const isAdmin = computed(() => user.value?.role === 'admin')

    async function login(username, password) {
        // TODO: 调用登录 API
    }

    function logout() {
        user.value = null
        token.value = ''
        localStorage.removeItem('token')
    }

    return {
        user,
        token,
        isAuthenticated,
        isAdmin,
        login,
        logout
    }
})
