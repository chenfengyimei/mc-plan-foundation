# 状态

阶段：F0/GOV 已完成；F1 Core 活动

实现：文档、契约与协作工具；无业务代码

状态：治理基线与 F1 架构评审门槛已完成；当前 main 已推送 GitHub

治理增强：`MCP-GOV-FOUNDATION-001` 已建立主方向、工作流锁、动态项目注册表、六仓开发计划、校验器和开发 Skill；`MCP-F1-FOUNDATION-005` 已增加 `mc-plan-orchestrator` v1.0 主会话统筹 Skill、跨工具派工协议、进度恢复规则和行为评测。

已完成：六仓职责、系统与数据流、产品边界、工程标准、核心 ADR、组合状态、风险、待决事项、模板、`mc-plan-development` 和 `mc-plan-orchestrator`。后者用于实时进度核对、派工提示词、异常恢复和后续路线编排，不替代单工作流开发规则。

F1 评审：`MCP-F1-FOUNDATION-003` 按十项检查表补齐身份生命周期 ADR、Core 事务/运行边界、第一可运行切片、测试回退、风险和待决门槛；Foundation、协调与只读契约验证通过。

当前方向：`F1 / mc-plan-core`，状态为活动。`MCP-F1-CORE-001` 至 `MCP-F1-CORE-004` 均已完成、关闭并合并 `main`；Core `8ba869a` 与 Contracts `72bac53` 已 ff-only 合并、推送 GitHub 并清理短期分支。Contracts `0.1.0-alpha.3` 锁定每日权益/服务消费表面，Core 每日三个 Skin creation_session 按 Asia/Shanghai 重置、不累计；十二路并发（含跨策略切换）、历史快照、幂等、OIDC/PAT 读取、服务 scope 和事务审计/INTERNAL outbox 验收通过。单元 55、HTTP E2E 52、PostgreSQL 集成 17、契约 7、最终 runtime 镜像及隔离镜像运行验证、Continue/Finish/工作区与 14 项协调测试均有实际证据，见 [CORE-004 完成记录](../memory/workstreams/completed/MCP-F1-CORE-004.json)。

F1 整体尚未完成：下一阶段为开发计划第 6 步不可变积分账本，完整审计/outbox 发布、SDK/消费者与恢复演练仍待实现。Q-007 的 PAT 默认最长 30 天保持原决策。当前唯一活动工作流 `MCP-F1-SKIN-008` 仍为 blocked，原 owner、分支、检查点和 Skin 锁均未修改；解锁仍等待 Q-001 Provider 基准、预算/凭据决策或所有者明确选择，禁止无界抽卡，不开启 F3。Core/Contracts 当前锁已释放，未创建新工作流。

待决事项统一记录在 `memory/open-questions.md`，具体工作以后由 GitHub Issue/PR 跟踪。
