# 项目组合状态

更新时间：2026-10-03

| 仓库 | 阶段 | 当前目标 | 下一决策门槛 |
|---|---|---|---|
| Foundation | F0/GOV 完成；F1 评审门槛通过 | v1.0 基线、工作流治理、开发 Skill 与 `mc-plan-orchestrator` v1.0 已本地归档 | 持续核对方向、锁和组合状态；不承载业务代码 |
| Contracts | F0/GOV 完成；F1 辅助活动 | Core `0.1.0-alpha.2` 已锁定 Developer App、scope 与 PAT 预发布契约（`developer-apps:read/manage`、`pat:read/manage`、PAT 默认最长 30 天与创建响应 Schema 均有机器门禁）；`MCP-F1-CORE-003` 的 Core 生产者契约测试与全部新表面 Schema 验证已完成并合并本地 `main` | 尚未锁定的 Core F1 能力（每日权益、积分账本）须先补预发布契约；SDK 与消费者另开后续工作流并遵守契约 → SDK → 消费者顺序 |
| Core | F1 活动；授权与令牌切片已完成 | `MCP-F1-CORE-001`（运行骨架、OIDC 边界、可观测性、容器）、`MCP-F1-CORE-002`（Keycloak 开发环境、幂等 IdentityLink、最小 Profile、`GET /v1/me`）与 `MCP-F1-CORE-003`（业务角色、scope、Developer App、只保存哈希的 PAT 生命周期，默认最长 30 天，Q-007 已决）均已完成、关闭并合并本地 `main`；`0.1.0-alpha.2` 生产者已通过契约测试、全部新表面 Schema 验证与隔离 PostgreSQL 集成验收 | 下一阶段为开发计划固定顺序第 5 步 Asia/Shanghai 每日权益；F1 整体尚未完成，积分账本、完整审计/outbox 发布、SDK/消费者与恢复演练仍待实现；公共接口先在 Contracts 锁定预发布契约 |
| Community | F2/F4 计划中；实现未开始 | 资源发布闭环与社区功能顺序已固化 | F2 开始前批准资源状态机与上传契约 |
| Skin | F3 计划中；F1 受限 Standalone 持续改进（ADR-0009） | 工程骨架、Standalone 最小链路、逐像素蓝图协议、无第三方运行时的可旋转 3D 预览与真实 Provider 流程已完成；唯一活动工作流 `MCP-F1-SKIN-008` 已正式标记为 blocked：当前 GLM flash-low 与 v4 协议组合未达到所有者视觉验收，受控候选技术校验全过但视觉约 1/10，分支领先本地 `main` 8 个提交 | 解锁等待 Q-001 Provider 基准（模型/预算/凭据决策）或所有者明确选择；在此之前禁止无界抽卡；Skin 契约缺口须按契约先行顺序另开 Contracts 主工作流补全；F3 前仍须模型提供商基准 ADR，Official 集成不得越过 Core/Community 门槛 |
| Ops | F1 辅助活动；非生产开发组合已建立 | 真实输入优先的开发、预发布、恢复和扩容路线已固化；`MCP-F1-CORE-002` 已建立固定版本 Keycloak、隔离 Core/Keycloak PostgreSQL、本地 Mailpit 与无真实秘密的本地开发组合 | 获得服务器、域名、地域与运维产品决策后另建预发布工作流，不得把本地占位凭证提升为生产配置 |

当前唯一活动工作流是 `MCP-F1-SKIN-008`（状态 blocked），只占用 Skin：当前 GLM flash-low 与 v4 协议组合未达到所有者视觉验收，解锁等待 Q-001 Provider 基准、预算/凭据决策或所有者的明确选择，在此之前禁止无界抽卡；其 owner、分支、检查点与锁保持不变，未合并 main、未释放锁。Core 下一阶段第 5 步每日权益工作流与 Skin 锁不重叠，可在所有者授权后立即启动。F1 整体尚未完成：积分账本、完整审计/outbox 发布、SDK/消费者与恢复演练仍待实现。ADR-0009 的 Skin 准备方向不改变 Core 主方向。具体实施任务以后由 GitHub Issues/PR 跟踪；本文件只记录跨仓里程碑状态。
