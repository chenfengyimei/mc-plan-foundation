# 项目组合状态

更新时间：2026-10-05

| 仓库 | 阶段 | 当前目标 | 下一决策门槛 |
|---|---|---|---|
| Foundation | F0/GOV 完成；F1 评审门槛通过 | v1.0 基线、工作流治理、开发 Skill 与 `mc-plan-orchestrator` v1.0 已本地归档 | 持续核对方向、锁和组合状态；不承载业务代码 |
| Contracts | F0/GOV 完成；F1 每日权益契约已验证 | Core `0.1.0-alpha.3` 已锁定 OIDC/PAT 权益读取、服务 OAuth 消费、持久化幂等与稳定错误语义（仅 daily_entitlement）；`MCP-F1-CORE-004` 的已验证组合已写入兼容矩阵，`main` 为 `72bac53` 并已推送 GitHub | 后续积分账本与 credits 来源消费须先锁定契约；SDK/消费者另开工作流，遵守契约 → SDK → 消费者顺序 |
| Core | F1 活动；每日权益切片已完成 | `MCP-F1-CORE-001` 至 `MCP-F1-CORE-004` 均已关闭；当前 `main` 为 `8ba869a`，已 ff-only 合并并推送。alpha.3 每日三个 Skin creation_session 按上海自然日恢复、不累计，已验证跨策略并发/历史快照、幂等、服务 scope 与事务审计/INTERNAL outbox；单元 55、HTTP E2E 52、PostgreSQL 集成 17、契约 7、最终 runtime 重建及镜像迁移/非 root 健康探针通过 | 下一阶段为固定顺序第 6 步不可变积分账本；F1 整体尚未完成，完整审计/outbox 发布、SDK/消费者与恢复演练仍待实现，公共接口先在 Contracts 锁定 |
| Community | F2/F4 计划中；实现未开始 | 资源发布闭环与社区功能顺序已固化 | F2 开始前批准资源状态机与上传契约 |
| Skin | F3 计划中；F1 受限 Standalone 持续改进（ADR-0009） | 工程骨架、Standalone 最小链路、逐像素蓝图协议、无第三方运行时的可旋转 3D 预览与真实 Provider 流程已完成；唯一活动工作流 `MCP-F1-SKIN-008` 已正式标记为 blocked：当前 GLM flash-low 与 v4 协议组合未达到所有者视觉验收，受控候选技术校验全过但视觉约 1/10，分支领先本地 `main` 8 个提交 | 解锁等待 Q-001 Provider 基准（模型/预算/凭据决策）或所有者明确选择；在此之前禁止无界抽卡；Skin 契约缺口须按契约先行顺序另开 Contracts 主工作流补全；F3 前仍须模型提供商基准 ADR，Official 集成不得越过 Core/Community 门槛 |
| Ops | F1 辅助活动；非生产开发组合已建立 | 真实输入优先的开发、预发布、恢复和扩容路线已固化；`MCP-F1-CORE-002` 已建立固定版本 Keycloak、隔离 Core/Keycloak PostgreSQL、本地 Mailpit 与无真实秘密的本地开发组合 | 获得服务器、域名、地域与运维产品决策后另建预发布工作流，不得把本地占位凭证提升为生产配置 |

当前唯一活动工作流是 `MCP-F1-SKIN-008`（状态 blocked），只占用 Skin：当前 GLM flash-low 与 v4 协议组合未达到所有者视觉验收，解锁等待 Q-001 Provider 基准、预算/凭据决策或所有者的明确选择，在此之前禁止无界抽卡；其 owner、分支、检查点与锁保持不变，未合并 main、未释放锁。`MCP-F1-CORE-004` 已完成并释放 Core/Contracts 锁，短期分支已在本地与远程清理；当前没有新的 Core 活动工作流。下一阶段为第 6 步不可变积分账本，与 Skin 锁不重叠，但须按新切片范围和契约门槛启动。F1 整体尚未完成：积分账本、完整审计/outbox 发布、SDK/消费者与恢复演练仍待实现。ADR-0009 的 Skin 准备方向不改变 Core 主方向。具体实施任务以后由 GitHub Issues/PR 跟踪；本文件只记录跨仓里程碑状态。
