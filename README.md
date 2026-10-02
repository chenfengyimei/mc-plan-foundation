# MC Plan Foundation

MC Plan（MC 计划）的治理与架构真相仓库。这里保存跨项目长期有效的愿景、边界、标准、决策、项目状态、模板和 Codex 协作 Skill，不包含业务实现代码。

## 仓库地图

- `docs/`：项目宪法、系统架构、产品策略、数据流、隐私和路线图。
- `standards/`：所有仓库共同遵守的工程标准。
- `decisions/`：不可覆盖的架构决策记录（ADR）；被替代时新增 ADR。
- `memory/`：跨仓当前状态、活动计划、交接、风险和待决事项。
- `memory/current/*.json`：项目注册表与当前全局方向。
- `memory/workstreams/`：活动/完成工作流、仓库锁、提交和验证证据。
- `templates/`：新仓库、计划、ADR、交接和发布检查模板。
- `templates/session-start-prompt.md`：供 Codex、GPT Work、Codely/GLM 等新会话使用的跨工具开局提示词。
- `templates/orchestration-brief.md`：只需目标、工具/模型和限制的主会话简报模板。
- `templates/f1-architecture-review-checklist.md`：关闭 F1 人工架构评审门槛时必须逐项引用证据的检查表。
- `docs/f1-architecture-review.md`：最近一次 F1 评审的十项证据、契约判断和门槛结论。
- `docs/f1-core-first-slice.md`：门槛关闭后第一个 Core 工程切片的运行、测试与回退边界。
- `.codex/skills/mc-plan-development/`：MC Plan 多仓开发协作 Skill 的权威版本。
- `.codex/skills/mc-plan-orchestrator/`：读取实时状态、生成派工提示词、统筹会话、恢复未完成工作和规划后续路线的主会话 Skill 权威版本。

## 真相层级

1. 公共接口与数据契约以 `mc-plan-contracts` 的已发布版本为准。
2. 跨项目原则、边界和决策以本仓库文档与 ADR 为准。
3. 单仓实现细节、验收命令和局部状态以对应仓库为准。
4. 具体任务、讨论和审查以 GitHub Issue/PR 为准，不复制到多份 Markdown。

## 当前阶段

Foundation v1.0 文档与多仓治理基线已完成并保存在本地 Git；尚未创建远程仓库。`MCP-F1-FOUNDATION-003` 已完成项目所有者授权的十项架构评审，当前全局方向为活动的 `F1 / mc-plan-core`。`MCP-F1-CORE-001` 的第一可运行工程切片已经实现并验证，但协调记录仍待原工作流完成关闭和本地集成；`MCP-F1-SKIN-008` 正在 ADR-0009 的受限范围内改进 Standalone 逐像素生成质量与可旋转 3D 预览。`MCP-F1-FOUNDATION-005` 增加了主会话统筹 Skill，使后续派工先核对实时锁、提交和完成层级。当前组合状态见 [项目组合状态](memory/current/portfolio.md)，后续顺序见 [路线图](docs/roadmap.md)。

所有写任务必须先按 [多仓协调模型](docs/coordination.md) 声明唯一主仓库和仓库锁；各项目固定开发顺序见对应 `docs/development-plan.md`。

## 验证

在工作区根目录运行：

```powershell
pwsh -File .\mc-plan-foundation\scripts\validate-workspace.ps1
pwsh -File .\mc-plan-foundation\scripts\test-coordination.ps1
```

该命令检查六仓必需文件、状态页、本地 Markdown 链接、JSON 解析、Schema ID、本地契约引用和 Skill 基线。

## 许可

除另有注明外，本仓库文档采用 [CC BY 4.0](LICENSE) 许可。
