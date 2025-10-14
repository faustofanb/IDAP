# Frontend

IDAP 前端 - Vue 3 + Element Plus

## 技术栈

- **Vue** 3.4+
- **Element Plus** 2.5+
- **Pinia** 2.1+
- **Vue Router** 4.2+
- **Vite** 5.0+
- **ECharts** 5.5+
- **Axios** 1.6+

## 项目结构

```
frontend/
├── src/
│   ├── main.js                # 入口文件
│   ├── App.vue                # 根组件
│   ├── router/                # 路由配置
│   │   └── index.js
│   ├── stores/                # Pinia 状态管理
│   │   ├── user.js
│   │   └── chat.js
│   ├── views/                 # 页面组件
│   │   ├── HomePage.vue
│   │   ├── LoginPage.vue
│   │   ├── ChatPage.vue
│   │   └── HistoryPage.vue
│   ├── components/            # 通用组件
│   │   ├── ChatInput.vue
│   │   ├── ChatMessage.vue
│   │   └── ChartViewer.vue
│   ├── api/                   # API 封装
│   │   ├── index.js
│   │   ├── auth.js
│   │   └── query.js
│   └── assets/
│       └── styles/
│           └── main.scss
├── index.html
├── vite.config.js
└── package.json
```

## 快速开始

### 1. 安装依赖

```bash
# 使用 pnpm
pnpm install

# 使用 npm
npm install

# 使用 Bun
bun install
```

### 2. 启动开发服务器

```bash
# 使用 pnpm
pnpm dev

# 使用 Bun
bun run dev:bun
```

访问: http://localhost:3000

### 3. 构建生产版本

```bash
pnpm build
```

## 路由说明

- `/` - 首页
- `/login` - 登录页
- `/chat` - 对话页（需认证）
- `/history` - 历史记录（需认证）

## API 代理

开发环境下，所有 `/api/*` 请求会被代理到 `http://localhost:8080`

## 组件说明

### ChatInput

消息输入组件，支持 Cmd/Ctrl + Enter 快捷发送

### ChatMessage

消息展示组件，支持 Markdown 渲染、SQL 高亮、图表展示

### ChartViewer

图表查看器，基于 ECharts

## 开发指南

### 状态管理

使用 Pinia 管理全局状态，主要包括：

- `useUserStore` - 用户状态
- `useChatStore` - 对话状态

### API 调用

所有 API 调用统一使用 `src/api/` 中的封装方法

### 样式

使用 SCSS，全局样式定义在 `src/assets/styles/main.scss`
