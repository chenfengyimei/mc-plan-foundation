# 项目组合状态

更新时间：2026-10-05

| 仓库 | 阶段 | 当前目标 | 下一决策门槛 |
|---|---|---|---|
| Foundation | F0/GOV 完成；F1 评审门槛通过 | v1.0 基线、工作流治理、开发 Skill 与 `mc-plan-orchestrator` v1.0 已归档；`MCP-F1-FOUNDATION-008` 修复 Git 项目文件扫描并建立经隔离验收的同 Mac 协调短事务协议（ADR-0010） | 持续核对方向、锁和组合状态；不承载业务代码；所有 Foundation 协调写入使用短锁入口 |
| Contracts | F0/GOV 完成；alpha.4 与 SDK 切片已归档 | CORE-005 的 alpha.4 只读余额契约与 CONTRACTS-001 SDK 已有 completed 记录，最终提交在本地 main `e434d93`；SDK 远端推送仍待授权。原每日权益消费仍仅 daily_entitlement | 公共积分消费/回退及消费者须按后续工作流推进，遵守契约 → SDK → 消费者顺序 |
| Core | F1 活动；每日权益与积分账本切片已归档 | CORE-001 至 CORE-005 均已关闭；CORE-005 最终提交 `5508d60` 在 main 上，记录锁定 alpha.4 的只读余额表面及内部积分账本；本治理会话核实提交和 Finish，不复写业务验收结果 | 完整审计/outbox 发布、消费者与恢复演练仍待后续工作；公共积分消费回退依赖相应契约/产品决策，F1 尚未完成 |
| Community | F2/F4 计划中；实现未开始 | 资源发布闭环与社区功能顺序已固化 | F2 开始前批准资源状态机与上传契约 |
| Skin | F3 计划中；F1 受限 Standalone 持续改进（ADR-0009） | 工程骨架、Standalone 最小链路、逐像素蓝图协议、无第三方运行时的可旋转 3D 预览与真实 Provider 流程已完成；唯一活动工作流 `MCP-F1-SKIN-008` 已正式标记为 blocked：当前 GLM flash-low 与 v4 协议组合未达到所有者视觉验收，受控候选技术校验全过但视觉约 1/10，分支领先本地 `main` 8 个提交 | 解锁等待 Q-001 Provider 基准（模型/预算/凭据决策）或所有者明确选择；在此之前禁止无界抽卡；Skin 契约缺口须按契约先行顺序另开 Contracts 主工作流补全；F3 前仍须模型提供商基准 ADR，Official 集成不得越过 Core/Community 门槛 |
| Ops | F1 辅助活动；非生产开发组合已建立 | 真实输入优先的开发、预发布、恢复和扩容路线已固化；`MCP-F1-CORE-002` 已建立固定版本 Keycloak、隔离 Core/Keycloak PostgreSQL、本地 Mailpit 与无真实秘密的本地开发组合 | 获得服务器、域名、地域与运维产品决策后另建预发布工作流，不得把本地占位凭证提升为生产配置 |

治理恢复时核实：其他会话已关闭 `MCP-F1-CORE-005` 与 `MCP-F1-CONTRACTS-001`，最终提交分别在 Core main `5508d60` 和 Contracts 本地 main `e434d93` 上，Finish 通过；SDK 记录明确远端推送待授权，不视为已推送。详情以二者 completed 记录为准，此处不复制其业务测试结果。当前活动业务锁是 `MCP-F1-SKIN-008`（blocked，仅锁 Skin）；其他会话按所有者授权正式交接至 `Codely/8b150da7-6a4c-4e53-a769-422c79c12963`，本治理任务不修改该记录。Skin 尚未合并 main、未释放锁，仍等待视觉验收/Provider 决策，禁止无界抽卡。ADR-0009 不改变 Core 主方向，F1 整体仍未完成。

治理完成后 A/B 可开始注册，C 等 A 关闭并释放 Contracts 锁后再注册；A/C 已由其他会话先行关闭，不能重复登记。B（Ops 固定 alpha.3 联调）仍待启动，不预留 ID。完整审计/outbox 发布、消费者与恢复演练仍待后续工作，这些规划不是本轮治理交付。具体实施任务以后由 GitHub Issues/PR 跟踪；本文件只记录跨仓里程碑状态。
