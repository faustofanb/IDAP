# Specify 元数据目录

本目录由 Specify CLI 使用，是规格、计划、任务与契约的唯一事实来源。`docs/` 目录仅保留全局规约、架构与流程说明。

- `memory/constitution.md`：规格驱动开发的核心原则速记，与 `docs/constitution.md` 同步。
- `specs/<feature>/spec.md`：功能规格正文。
- `specs/<feature>/plan.md`：实施计划正文。
- `specs/<feature>/tasks.md`：任务清单。
- `specs/<feature>/contracts/`、`specs/shared/`：契约、Schema 与示例。

运行 `specify init --here --ai copilot` 可刷新此目录并获取最新模板、脚本与 slash 命令支持。
