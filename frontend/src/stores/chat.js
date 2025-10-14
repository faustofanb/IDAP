import { defineStore } from 'pinia'
import { ref } from 'vue'

export const useChatStore = defineStore('chat', () => {
    const sessions = ref([])
    const currentSessionId = ref(null)
    const messages = ref([])
    const isLoading = ref(false)

    async function createSession(title = '新对话') {
        // TODO: 调用创建会话 API
    }

    async function sendMessage(question) {
        // TODO: 调用查询 API
    }

    return {
        sessions,
        currentSessionId,
        messages,
        isLoading,
        createSession,
        sendMessage
    }
})
