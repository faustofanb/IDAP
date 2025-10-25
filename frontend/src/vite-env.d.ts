/// <reference types="vite/client" />

interface ImportMetaEnv {
    readonly VITE_API_BASE_URL: string
    readonly VITE_WS_URL: string
    readonly VITE_APP_TITLE: string
    readonly BASE_URL: string
}

interface ImportMeta {
    readonly env: ImportMetaEnv
    readonly url: string
}

declare module '*.vue' {
    import type { DefineComponent } from 'vue'
    const component: DefineComponent<{}, {}, any>
    export default component
}

declare module '*.css' {
    const content: any
    export default content
}
