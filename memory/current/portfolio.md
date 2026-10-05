# 项目组合状态

更新时间：2026-10-05

| 仓库 | 阶段 | 当前目标 | 下一决策门槛 |
|---|---|---|---|
| Foundation | F0/GOV 完成；F1 评审门槛通过 | v1.0 基线、工作流治理、开发 Skill 与 `mc-plan-orchestrator` v1.0 已归档；`MCP-F1-FOUNDATION-008` 修复 Git 项目文件扫描并建立经隔离验收的同 Mac 协调短事务协议（ADR-0010） | 持续核对方向、锁和组合状态；不承载业务代码；所有 Foundation 协调写入使用短锁入口 |
| Contracts | F0/GOV 完成；alpha.4 与 SDK 切片已归档 | CORE-005 的 alpha.4 只读余额契约与 CONTRACTS-001 SDK 已有 completed 记录，最终提交 main `e434d93` 已于 2026-10-05 获所有者授权推送 origin。原每日权益消费仍仅 daily_entitlement | 公共积分消费/回退及消费者须按后续工作流推进，遵守契约 → SDK → 消费者顺序 |
| Core | F1 活动；权益/积分账本/outbox 发布器切片已归档 | CORE-001 至 CORE-006 均已关闭；CORE-005 最终提交 `5508d60`（alpha.4 只读余额表面与内部积分账本）与 CORE-006 最终提交 `63745d6`（第 7 步事务 outbox 发布器与事件恢复，无传输绑定）均在已推送 main 上；本治理会话核实提交和 Finish，不复写业务验收结果 | 真实事件投递（须先有传输 ADR 与 Contracts 投递语义锁定）、消费者、备份恢复演练与公共积分消费回退仍待后续工作；F1 尚未完成 |
| Community | F2/F4 计划中；实现未开始 | 资源发布闭环与社区功能顺序已固化 | F2 开始前批准资源状态机与上传契约 |
| Skin | F3 计划中；F1 受限 Standalone 持续改进（ADR-0009） | 工程骨架、Standalone 最小链路、逐像素蓝图协议、无第三方运行时的可旋转 3D 预览与真实 Provider 流程已完成；唯一活动工作流 `MCP-F1-SKIN-008` 已正式标记为 blocked：当前 GLM flash-low 与 v4 协议组合未达到所有者视觉验收，受控候选技术校验全过但视觉约 1/10；工作流已按所有者授权正式交接至 `Codely/8b150da7-6a4c-4e53-a769-422c79c12963`，分支领先本地 `main` 9 个提交（离线工作台完成度检查点 `85b35ff`，未推送） | 解锁等待 Q-001 Provider 基准（模型/预算/凭据决策）或所有者明确选择；在此之前禁止无界抽卡；Skin 契约缺口须按契约先行顺序另开 Contracts 主工作流补全；F3 前仍须模型提供商基准 ADR，Official 集成不得越过 Core/Community 门槛 |
| Ops | F1 辅助活动；本地开发/联调组合已验证 | 真实输入优先的开发、预发布、恢复和扩容路线已固化；`MCP-F1-CORE-002` 已建立固定版本 Keycloak、隔离 Core/Keycloak PostgreSQL、本地 Mailpit 与无真实秘密的本地开发组合；`MCP-F1-OPS-001` 已以真实 Keycloak 用户/服务令牌完成固定 alpha.3 权益消费联调验收（最小 scope 服务客户端、标注负例客户端、隔离验收项目与 validate-dev-entitlements.ps1；Ops main `6813b52` 已推送） | 获得服务器、域名、地域与运维产品决策后另建预发布工作流，不得把本地占位凭证提升为生产配置 |

记录现状（2026-10-05 23:55 核对；活动清单以 `memory/workstreams` 机器记录为准）：30 个 completed；活动工作流 2 个：`MCP-F1-FOUNDATION-010`（本切片，Foundation 主，治理叙述余项同步）与 `MCP-F1-SKIN-008`（blocked，仅锁 Skin）。`MCP-F1-CORE-005`（Core main `5508d60`，已推送）、`MCP-F1-OPS-001`（Ops main `6813b52`，已推送）、`MCP-F1-CONTRACTS-001`（Contracts main `e434d93`，已获所有者授权推送）、`MCP-F1-FOUNDATION-008/009` 与 `MCP-F1-CORE-006`（Core main `63745d6`，已推送）均已关闭且 Finish 通过；详情以各自 completed 记录为准，此处不复制其业务测试结果。当前活动业务锁为 `MCP-F1-FOUNDATION-010`（Foundation）与 `MCP-F1-SKIN-008`（blocked，Skin）；后者由所有者授权正式交接至 `Codely/8b150da7-6a4c-4e53-a769-422c79c12963`，本治理任务不修改该记录。Skin 尚未合并 main、未释放锁，仍等待视觉验收/Provider 决策，禁止无界抽卡。ADR-0009 不改变 Core 主方向，F1 整体仍未完成。

A/B/C 三项均已注册并关闭：A=`MCP-F1-CORE-005`、B=`MCP-F1-OPS-001`、C=`MCP-F1-CONTRACTS-001`，已有 completed 记录不能重复登记。Core 第 7 步 outbox 发布器与事件恢复已由 `MCP-F1-CORE-006` 关闭（本切片无传输绑定，生产不绑定任何 sink）；真实事件投递（须传输 ADR 与 Contracts 投递语义锁定）、消费者集成、备份恢复演练与公共积分消费回退仍待后续工作流；公共契约需求按优先级串行冻结，不开多个 Contracts 写会话。具体实施任务以后由 GitHub Issues/PR 跟踪；本文件只记录跨仓里程碑状态。
