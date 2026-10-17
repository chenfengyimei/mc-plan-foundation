# 项目组合状态

核对：2026-10-16（MCP-F2-FOUNDATION-007）。全局仍为[F2/Community](direction.json)；F4 管理端有界先行只读面（ADR-0018）已连同其 Core/Contracts/Ops 交付关闭；Core/Community/Skin 三条 SDK 线均已暴露 producer 已验证操作。详细逐模块源码/证据与执行顺序见[模块收尾核查](../../docs/module-completion-review.md)。F1 工程已交付，Skin 概念桥接 SKIN-009 也已工程关闭；F1 正式收官仍等受控概念管线基准及所有者视觉验收。完整 F2/F3/F4/V1 未完成。

| 仓库 | 当前已证事实 | 剩余门槛 |
|---|---|---|
| Foundation | ADR0014~0018 全部落档（资源入口/人工审核/官方OAuth前置/管理台授权模型）；注册表 2026-10-16 实测 70 completed / 1 active（本治理切片）；六仓 main=origin 全同步 | 依据真实门槛逐模块推进；不代填价格/法律/厂商/生产值 |
| Core | main 06de705=origin：alpha.8 官方委托 + alpha.9 管理只读面（MCP-F4-CORE-001 关闭，全量门禁 + 镜像 mcp-f4-core-001-29939a0 + Ops 真实管理员栈验收 + apps/admin 浏览器 e2e） | 正式realm/门户角色管理与安全上线；年龄/权利扩展、Q-003/Q-013、管理写操作逐项决策 |
| Contracts | main 601c0f3=origin：core alpha.9（23 操作 SDK，MCP-F4-CONTRACTS-001）、community alpha.4（12 方法 SDK）、skin alpha.1（8 操作 SDK，MCP-F1-CONTRACTS-007）三包全部 producer 锚定并各以两轮真实 HTTP smoke 验收 | 稳定发行与未来 F3/F4 契约；管理写操作契约待所有者逐项决策 |
| Community | main 3e887c1=origin（10-13 三切片终态已按 2026-10-16 授权补推）：alpha.4 十二操作生产者、封存预览、人工审核、门户消费者、自部署恢复、隔离组合、70 项验证、镜像 mcp-f2-community-004-8811b69 | 目标S3/离机持续journal/Q-005；F4 全社交/Web 管理面批次（门槛后） |
| Skin | main 14a8fe3=origin：SKIN-008/009 工程关闭，v4/3D 工作台、厂商中立概念图→视觉→v4、真实DB同链；Standalone 8 操作经 @mc-plan/skin-sdk 暴露 | Q-001 受控真实基准/所有者视觉验收/厂商新 ADR；Q-011/Q-012/Q-013、F3 Official 与 Community 发布 |
| Ops | main ef00a72=origin：OPS-001..004 + alpha.8 官方链 + admin realm/validate-dev-admin.ps1 真实验收（MCP-F4-CORE-001 Ops 侧） | Community 官方组合/离机调度、生产地域邮件监控采购和正式 RPO/RTO |

Core 镜像基线：mc-plan-core:mcp-f4-core-001-29939a0（ac3bbdd2bf46）；Community 镜像 mcp-f2-community-004-8811b69。证据/终态 SHA 以各[完成记录](../workstreams/completed/)为准。2026-10-16 本轮：MCP-F4-CONTRACTS-001 + MCP-F1-CONTRACTS-007 两 SDK 切片按全量门禁 + 固定镜像/生产者树两轮真实 HTTP smoke 关闭并推送；community 终态存量（70e55a1..3e887c1）按所有者 2026-10-16 完成指令 ff-only 补推。所有活动锁以 active 记录为准；本轮收官后执行队列已清空，剩余全部为所有者门槛项（见 delivery-plan 2026-10-16 段）。
