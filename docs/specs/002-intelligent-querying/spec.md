# 002-智能问数：规格（Spec）

## 用例

- U1 提问：用户输入中文问题，系统逐步返回表格/图表/洞察。
- U2 追问：在同会话上下文中追加过滤或更换维度。
- U3 导出/订阅：对稳定报表进行导出或订阅（异步）。

## 时序（文本化）

1. FE -> WS: user_message
2. AI: 解析 →RequestEnvelope（含 tenantId/actor/filters/timeRange/metrics/dimensions）
3. BE: 校验 JWT/RBAC/数据权限；路由到执行器（模板/引擎）
4. BE -> FE: 流式返回 Table/Chart/Insight/Telemetry

## 交互接口

- WebSocket 路径：/ws/chat
  - 入站：{ type: "user", text: string, correlationId?: string }
  - 出站：
    - { type: "table", payload: TableDescriptor }
    - { type: "chart", payload: ChartDescriptor }
    - { type: "insight", payload: InsightText }
    - { type: "telemetry", payload: Telemetry }
- HTTP：
  - GET /reports/history?tenantId=... （列表）
  - POST /reports/export （触发导出，异步）

## 契约（摘要）

- RequestEnvelope：见 docs/03-AI-能力与约束
- TableDescriptor：{ columns: Column[], rows: any[][], pagination?: { page: number; pageSize: number; total: number } }
- ChartDescriptor：{ type: "line"|"bar"|"pie"|..., data: any, options?: any }
- InsightText：{ title: string, bullets: string[] }
- Telemetry：{ requestTs: number, traceId: string, latencyMs?: number }

## 错误与降级

- 400：参数非法（空时间/维度冲突/未知指标）→ 返回纠错提示。
- 401：未授权/过期 → 引导登录。
- 403：越权访问 → 中断并审计。
- 超时：降级为“稍后生成报告”，保留会话记录。

## 安全

- 所有请求必须携带 tenantId 且通过数据权限策略。
- AI 输出仅结构化请求，禁止携带 SQL。
