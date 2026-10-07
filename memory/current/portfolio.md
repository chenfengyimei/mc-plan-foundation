# 项目组合状态

核对日期：2026-10-07。本文为里程碑摘要；实时 Owner、锁、检查点与关闭状态以 [工作流记录](../workstreams/active/) 和 Git 为准。全局方向仍为 [F1 / Core](direction.json)，没有通过 F1 退出门槛。

| 仓库 | 已有事实 | 当前缺口与下一门槛 |
|---|---|---|
| Foundation | F0/GOV 与 F1 架构评审完成；ADR-0010 短事务、ADR-0011 消费者拉取、ADR-0012 Skin 匿名窗口已落地 | 按 [完整交付路线](../../docs/delivery-plan.md) 收敛实现与证据；后续阶段逐门槛推进 |
| Contracts | main `3006402`；Core `0.1.0-alpha.5`、Skin `0.1.0-alpha.1` 已锁定；Core SDK 暴露 12 个已有 producer 证据的操作 | 事件 SDK 等待 Core 投递正确性及真实消费者验收；Community 仍为 draft；Skin alpha 契约不等于生产者已实现 |
| Core | main `ad6a5e0` 已含 CORE-001 至 CORE-007；CORE-008 分支检查点 `8f18ac5` 已实现事件拉取与确认 | CORE-008 仍 active，仅实现检查点；乱序发布存在丢投路径，Ops 验收尚不能关闭；备份恢复、指标追踪及其余 F1 条目仍待证据 |
| Community | main `69ac5e9`；仅治理与业务计划文档，无应用源码或测试 | F2 尚未启动：先审定资源上传/状态机与预发布契约，再实施资源闭环；F4 全部社区批次均未实现 |
| Skin | SKIN-008 分支检查点 `85b35ff`，本地比 origin 同名分支领先 1 个提交；已有 Standalone 工作台、第一方 3D 预览、刷新恢复、比较与本地下载 | 工作流仍 blocked，尚未合并 main；真实生成质量验收未通过；alpha.1 公共详情/删除/预览/下载尚未实现，当前本地预览依赖忽略文件 |
| Ops | main `2ece743`；已有本地 Keycloak/Core、Mailpit 邮件与密码恢复、权益、开发者应用验收 | CORE-008 占用 Ops，事件 compose/realm/验收脚本仍有未提交改动；事件验收、隔离备份恢复和预发布生产门槛未完成 |

## 活动业务工作流

- `MCP-F1-CORE-008`：Owner `Codely/session-4-contracts-sdk`，写集 Core + Ops，active。Core 检查点已提交；Ops 未提交；两个 final_commit 均为空。不得据 Core 开发计划中的“已完成”措辞认定工作流已关闭。
- `MCP-F1-SKIN-008`：Owner `Codely/8b150da7-6a4c-4e53-a769-422c79c12963`，仅锁 Skin，blocked。保留既有实现及视觉验收门槛；不得自动解锁或把 alpha.1 新 API 混入原先排除公共 API/迁移的范围。

2026-10-07 本轮核对开始时为 37 条 completed、2 条 active；这是历史快照，不作为之后的实时数量。当前数量以 `scripts/validate-coordination.ps1` 输出为准。此次没有推送远端，没有替其他 Owner 接管、关闭或提交业务改动。

## 决策与证据边界

Contracts-003 完成叙述提及 Q-001 的后续选择与凭据，但 [待决事项](../open-questions.md) 与 Skin active 记录尚未形成统一、已验收的 Provider 结论。该叙述仅为待核实线索，不能据此宣称生成质量合格或发起付费调用。其余供应商、定价、生产域名/地域、邮件、审核、权限、日志期限及 RPO/RTO 决策仍按各自 Owner 与最迟门槛处理。

完整社区、双模式 Skin、稳定 SDK、自部署与上线加固均属于 V1 范围。不能以文档齐全、Fake Provider 流程通过、某仓单测通过或工作流数量代替产品验收。
