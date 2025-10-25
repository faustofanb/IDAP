# Contracts（JSON Schema）

## 位置与命名

- 目录：docs/specs/002-intelligent-querying/contracts/
- 文件命名：以功能域为前缀，kebab-case，如 request-envelope.schema.json、insight-payload.schema.json。

## 版本与兼容

- 使用 $id 与 $schema 标明版本；破坏性变更需 bump 主版本并提供迁移说明。

## 代码生成

- 目标：TypeScript / Java / Python
- 方式：CI 中执行代码生成脚本，生成到各子项目的类型/DTO 包。

## 约束

- 禁止在 Schema 中定义具体 SQL；仅定义业务语义字段（intent/filters/metrics/dimensions 等）。
- 与 docs/03-AI-能力与约束 保持一致，以该文为法源。
