# 项目组合状态

核对：2026-10-13（MCP-F2-FOUNDATION-005）。全局仍为[F2/Community](direction.json)；ADR-0018已开放F4管理端有界先行（只读admin:read面，方向例外注册）。详细逐模块源码/证据与执行顺序见[模块收尾核查](../../docs/module-completion-review.md)。F1工程已交付，Skin概念桥接SKIN-009也已工程关闭；F1正式收官仍等受控概念管线基准及所有者视觉验收。完整F2/F3/F4/V1未完成。

| 仓库 | 当前已证事实 | 剩余门槛 |
|---|---|---|
| Foundation | ADR0014资源入口、0016人工审核落地；0017开放有界Core官方OAuth前置；0018开放F4管理端有界先行（admin:read只读面）；当前证据重新对账 | 依据真实门槛逐模块推进；不代填价格/法律/厂商/生产值 |
| Core | main690193a，alpha.8代码fb1bc07，306项producer及新镜像/SDK37项/真实HTTP+Keycloak；官方Community委托与PAT隔离/条件audience完成 | 正式realm/门户角色管理与安全上线；年龄/权利扩展、Q003奖励/Q013价格 |
| Contracts | main8090d8f，Communityalpha.4锁f52859c；Corealpha.8锁ebb00a6，Skin alpha.1不变；CoreSDK17操作、CommunitySDK12操作40测试/pack/真实HTTP | 真实Ops登记PKCE消费者已过；门户/SkinSDK及稳定发行仍后续 |
| Community | main74d2bcc/Core来源代码d482331；12API、56项验证；realm指定审核员、原子决定/审计/outbox/幂等、匿名inline封存PNG；manual/disabled两种镜像smoke通过 | 目标S3/对象版本/三十天备份淘汰/恢复不复活、正式许可/保留、门户消费者、F4全社交/Web管理面（官方OAuth及来源闭环已完成） |
| Skin | main14a8fe3；SKIN008与009均工程关闭；v4/3D工作台、厂商中立概念图→视觉→v4、真实DB同链与离线Playwright证据 | Q001受控真实基准/所有者视觉验收/厂商新ADR；Q011/Q012/Q013、F3 Official与Community发布 |
| Ops | main415a108；OPS001..004基线，另增真实登记PKCE/Community资源链、指定reviewer/收窄/撤销/DB故障验收 | Community组合/目标S3/恢复删除重放/限流容量；生产地域邮件监控采购和正式RPO/RTO |

Community镜像mc-plan-community:mcp-f2-community-003-d482331，sha256:116a9003526d0fd758e2fae2bd14d2a338ee23c6207bec077854ff4482ee3e5f；Core镜像mc-plan-core:mcp-f2-core-001-fb1bc07。证据/终态SHA以[完成记录](../workstreams/completed/MCP-F2-COMMUNITY-003.json)为准；本次Community/Contracts已本地main整合，没有远端push或生产部署。Skin当前main=本地origin追踪引用；Core/Community/Contracts/Ops/Foundation本轮增量仅本地main；不把未fetch的追踪引用说成新的远端验收。所有活动锁以active记录为准，不自动接管已关闭Skin会话或执行付费基准。
