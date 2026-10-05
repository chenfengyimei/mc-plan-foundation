# 状态

阶段：F0/GOV 已完成；F1 Core 活动

实现：文档、契约与协作工具；无业务代码

状态：治理基线与 F1 架构评审门槛已完成；当前 main 已推送 GitHub

治理增强：`MCP-GOV-FOUNDATION-001` 已建立主方向、工作流锁、动态项目注册表、六仓开发计划、校验器和开发 Skill；`MCP-F1-FOUNDATION-005` 已增加 `mc-plan-orchestrator` v1.0 主会话统筹 Skill、跨工具派工协议、进度恢复规则和行为评测。

`MCP-F1-FOUNDATION-008` 修复依赖/临时产物被当作项目契约扫描的问题：注册 active 仓库的 Git 跟踪文件和非忽略未跟踪文件共用筛选，保留真实 JSON/$id/$ref/Markdown 门槛。新增同 Mac Foundation 短事务入口、精确记录提交 helper、独占获取/持有者释放/共享 index 拒绝检查及 ADR-0010，使用隔离扫描和双进程验收；[协调文档](coordination.md) 给出完整用法与注册顺序。两个 Skill 的内容/版本不变。

已完成：六仓职责、系统与数据流、产品边界、工程标准、核心 ADR、组合状态、风险、待决事项、模板、`mc-plan-development` 和 `mc-plan-orchestrator`。后者用于实时进度核对、派工提示词、异常恢复和后续路线编排，不替代单工作流开发规则。

F1 评审：`MCP-F1-FOUNDATION-003` 按十项检查表补齐身份生命周期 ADR、Core 事务/运行边界、第一可运行切片、测试回退、风险和待决门槛；Foundation、协调与只读契约验证通过。

当前方向：`F1 / mc-plan-core`，状态为活动。`MCP-F1-CORE-001` 至 `MCP-F1-CORE-005` 均已完成、关闭并合并 `main`；Core `5508d60` 已推送 GitHub。Contracts `0.1.0-alpha.3` 锁定每日权益/服务消费表面（每日三个 Skin creation_session 按 Asia/Shanghai 重置、不累计；十二路并发/历史快照/幂等/OIDC/PAT/服务 scope 验收见 [CORE-004 完成记录](../memory/workstreams/completed/MCP-F1-CORE-004.json)）；`0.1.0-alpha.4` 新增只读积分余额表面（`getCreditBalance`），不可变积分账本为内部实现不经公共接口暴露；单元 74、HTTP E2E 57、隔离 PostgreSQL 集成 31、契约 11 与最终 runtime 镜像冒烟见 [CORE-005 完成记录](../memory/workstreams/completed/MCP-F1-CORE-005.json)。

记录现状：`MCP-F1-CORE-005`（Core main `5508d60`）、`MCP-F1-CONTRACTS-001`（Contracts 本地 main `e434d93`，SDK 远端推送待授权、不视为已推送）与 `MCP-F1-OPS-001`（Ops main `6813b52` 已推送；真实 Keycloak 用户/服务令牌的固定 alpha.3 权益消费联调验收通过）均已关闭且 Finish 通过，详见各自 completed 记录；本治理任务不替任何会话推送。完整审计/outbox 发布、消费者、恢复演练与公共积分消费回退仍待后续工作，F1 整体尚未完成，Q-007 的 PAT 默认最长 30 天保持原决策。

`MCP-F1-SKIN-008` 仍为 blocked；其他会话按所有者授权交接至 `Codely/8b150da7-6a4c-4e53-a769-422c79c12963`，本治理任务未修改其记录、分支、检查点或锁，禁止无界抽卡，不开启 F3。A/B/C 三项均已注册并关闭（A=`MCP-F1-CORE-005`、B=`MCP-F1-OPS-001`、C=`MCP-F1-CONTRACTS-001`），已有 completed 记录不能重复启动；公共契约需求按优先级串行冻结。

待决事项统一记录在 `memory/open-questions.md`，具体工作以后由 GitHub Issue/PR 跟踪。
