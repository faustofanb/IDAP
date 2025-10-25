# IDAP 前端项目

智能数据询问平台 (IDAP) - 进销存多租户 B2B 后台管理系统前端

## 技术栈

- Vue 3 + TypeScript + Vite
- Element Plus + ECharts
- Pinia + Vue Router + Axios
- ESLint + Prettier + Vitest

## 快速开始

```bash
# 安装依赖
bun install

# 启动开发服务器
bun run dev

# 构建生产版本
bun run build
```

默认登录信息：

- 租户代码: `default`
- 用户名: `admin`
- 密码: `123456`

## 项目结构

```
src/
├── api/              # API 请求封装
├── assets/           # 静态资源
├── components/       # 组件
│   ├── common/       # 通用组件
│   └── layout/       # 布局组件
├── router/           # 路由配置
├── stores/           # Pinia 状态管理
├── views/            # 页面视图
│   ├── auth/         # 认证页面
│   ├── tenant/       # 租户管理
│   ├── user/         # 用户管理
│   └── inventory/    # 进销存管理
└── main.ts           # 应用入口
```

详细文档请参考项目根目录的 README。
