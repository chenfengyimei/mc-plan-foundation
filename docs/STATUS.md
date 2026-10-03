# 状态

阶段：F0/GOV 已完成；F1 Core 活动

实现：文档、契约与协作工具；无业务代码

状态：治理基线与 F1 架构评审门槛已完成（仅本地；尚未发布远程）

治理增强：`MCP-GOV-FOUNDATION-001` 已建立主方向、工作流锁、动态项目注册表、六仓开发计划、校验器和开发 Skill；`MCP-F1-FOUNDATION-005` 已增加 `mc-plan-orchestrator` v1.0 主会话统筹 Skill、跨工具派工协议、进度恢复规则和行为评测。

已完成：六仓职责、系统与数据流、产品边界、工程标准、核心 ADR、组合状态、风险、待决事项、模板、`mc-plan-development` 和 `mc-plan-orchestrator`。后者用于实时进度核对、派工提示词、异常恢复和后续路线编排，不替代单工作流开发规则。

F1 评审：`MCP-F1-FOUNDATION-003` 按十项检查表补齐身份生命周期 ADR、Core 事务/运行边界、第一可运行切片、测试回退、风险和待决门槛；Foundation、协调与只读契约验证通过。

当前方向：`F1 / mc-plan-core`，状态为活动。`MCP-F1-CORE-001`、`MCP-F1-CORE-002` 与 `MCP-F1-CORE-003` 均已完成、关闭并合并本地 `main`；Contracts `0.1.0-alpha.2` 已锁定 Developer App、scope 与 PAT 契约，Q-007 已决为 PAT 默认最长 30 天，Core 已实现业务角色、scope、Developer App 与 PAT 生命周期。这不等于 F1 Core 产品里程碑完成：下一阶段为开发计划第 5 步 Asia/Shanghai 每日权益，积分账本、完整审计/outbox 发布、SDK/消费者与恢复演练仍待实现。当前唯一活动工作流 `MCP-F1-SKIN-008` 已正式标记为 blocked：当前 GLM flash-low 与 v4 协议组合未达到所有者视觉验收，解锁等待 Q-001 Provider 基准、预算/凭据决策或所有者明确选择，禁止无界抽卡；其仍在 ADR-0009 的 F1 受限 Standalone 范围内，不开启 F3。

待决事项统一记录在 `memory/open-questions.md`，具体工作以后由 GitHub Issue/PR 跟踪。
