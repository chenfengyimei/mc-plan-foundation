# 六仓逐模块收尾核查

核对：2026-10-13，MCP-F2-FOUNDATION-003。用户要求临时人工审核并逐模块理解、开发与收尾；本表依据当前源码、已关闭记录与 Git，而非计划中的功能。已完成技术切片不等于完整产品、生产部署或视觉质量通过。当前执行方向 F2 / Community。

## Core：已实现模块及剩余范围

| 模块/源码归属 | 已验证能力 | 下一门槛 |
|---|---|---|
| identity-link | 固定 OIDC issuer/audience/JWKS/有效期/已验证邮箱，issuer+sub 幂等映射业务 ID | IdP 迁移/重绑/恢复、MFA 和生产事故流程不能由首次登录实现替代 |
| profile | 活动账号私有/公开资料、仅 display_name 编辑、业务账号注销与审计 | 年龄声明写入及其他权利表面按已有延期决定后置；注销不等于 IdP 删除 |
| authorization | 主体/业务角色/scope/凭证隔离；服务与用户认证分离 | 当前 Developer App/PAT 共用六 scope 白名单，不支持 Community 官方登记 |
| developer-app | 真实 Keycloak public/confidential 客户端、S256/精确回调、一次性机密、scope 收窄/撤销/补偿/核对 | 官方 Community scope 与条件 audience 接线；不能把审核权限加到普通登记白名单 |
| token-metadata | PAT 哈希/前缀/最长30天/撤销/过期/最后使用与审计 | 与 Developer App scope 目录拆分，PAT 不因官方接入变更获得 Community/审核或 profile:write 权限 |
| entitlement | 上海日界每天3次，不累计，快照/并发/幂等消费 | Official Skin 消费者、失败策略与实际跨服务体验 |
| credits | 不可变 grant/consume/refund/adjustment，非负余额、退款封顶、只读余额、核对 | Q-003 奖励值、Q-013 会话价格；公共计费/奖励接入不能填猜测值 |
| outbox / events | 租约、重试、发布取位至提交串行化，拉取/确认、消费者幂等去重 | Community 发布事件传输与真实奖励消费者另立契约/工作流；不能直接改余额 |
| platform | 非root镜像、显式8迁移、严格配置、结构化日志、健康/本地 OTel 指标 | 生产观测、安全/容量、正式恢复目标、告警与升级演练 |

Core main 9303cc6，CORE-012 实证302测试及最终镜像。此次只读核查；Core SDK37项及真实HTTP/Keycloak回归再次通过。源目录为 mc-plan-core/src 的对应模块，完整证据在 CORE-012 记录。

## Community：已实现模块及剩余范围

| 模块/源码归属 | 已验证能力 | 下一门槛 |
|---|---|---|
| platform/identity | 双 audience 用户令牌 + 每次 Core 活动身份解析、scope/速率/错误白名单 | 官方 Developer App 接入与部署级全局限流 |
| upload / storage | 私有短期 PUT、真实大小/SHA/CRC/64×64/有界解压/UV/第二层验证、封存不可覆盖 | 实际目标 S3 私有桶/CORS/签名/权限/版本清理验收 |
| resource | 归属、容器、不可变版本/文件/许可、规范化幂等、事务审计 | 正式许可 Q-002、完整权利与保留 Q-005 |
| catalog | 公开资源/作者分页、受控 download/inline preview，同一封存字节、下架即时404 | 正式消费者/门户，搜索标签/其他发现功能后置 F4 |
| manual-review | 指定 realm 审核员 scope、确切候选 approve/reject、审计业务 ID/哈希/原因；批准原子发布/outbox | 私有待审队列、申诉与细分权限属于 Q-010/F4，当前人工按作者提供文件和ID审核 |
| worker | 持久作业、租约 fencing/恢复/重试、过期上传与7天原文件清理、下架终态 | 对象版本/备份最长30天淘汰及恢复前删除重放；清理积压观测 |
| discovery / interaction / comment / social-graph | 未实施 | 标签搜索最新 → 点赞收藏 → 评论 → 关注流，逐批契约与真实验收 |
| recommendation / notification / governance | 未实施 | Q-008 权重、规则反作弊；通知；Q-010 举报处置申诉与管理面 |

Community main24f0364，runtime代码c1cdab0；alpha.4共12操作，13单元+3契约+40集成=56项。manual/disabled镜像验收均过：私有待审、普通作者403、授权决定、原始哈希预览、下架、依赖失效；无新增迁移。详情：[人工审核手册](../../mc-plan-community/docs/manual-review.md)。角色回收不追溯修改离线JWT，权限撤销窗口需短token生命周期；Core业务停用仍逐请求拒绝。

## Contracts、Skin、Ops、Foundation

| 仓库/模块 | 已验证 | 未交付/门槛 |
|---|---|---|
| Contracts / API-Schema-event | Core alpha.7、Community alpha.4、Skin alpha.1，生成/哈希漂移校验；Core/Skin表面本次未变 | 官方 OAuth 委托目录变化先冻结新预发布；稳定发行需真实消费者 |
| Contracts / SDK | Core17操作37测试；Community12操作40测试；干净pack、真实HTTP/Keycloak组合证据 | Skin SDK、官方产品消费者；SDK验收不等于产品已集成 |
| Skin / API-db-worker | Standalone八操作、幂等/三次渲染、队列重试、30天会话/24小时候选、删除防复活 | Official身份/年龄/权益/计费及Community发布未实现 |
| Skin / skin-core-validator-provider-sdk | v4确定性UV、Steve/Alex双层；fake/llm/image同链；概念图→视觉→v4厂商中立桥接 | SKIN-009已工程关闭，付费真实概念管线基准与所有者视觉验收未完成，Q-001仍未绑定厂商 |
| Skin / Web-preview | Pixel Foundry工作台、桌面/移动链、第一方动态3D/键盘交互、Provider标识 | Official完整体验与生产无障碍/性能验收；不能以离线fixture证明生成质量 |
| Ops / identity-mail-client-events-metrics | 隔离Core/Keycloak DB、真实PKCE、Mailpit、客户端生命周期、事件/指标验收，收官镜像统一 | Community运行组合、目标S3、TLS/限流/正式邮件/生产采购 |
| Ops / backup-restore | 本地Core+Keycloak备份/破坏/恢复、撤销重放、30天清理演示与实测RPO/RTO | Community DB+对象/版本恢复不复活；正式RPO/RTO Q-016未定 |
| Foundation / governance-coordination | 六仓归属/版本/锁/短事务/链接扫描与标准、真实记录关闭 | 实际门槛通过才推进里程碑，历史段不能替代当前表；本文件不决定法律或生产值 |

Skin main14a8fe3，实现检查点0462b20的历史门禁：128单元、API15/worker12真实DB集成、Playwright fake2/image1、fixture6。此次核查关闭记录与main可达性，不声称重跑其全部门禁或视觉验收。Ops maina0e78d7保持只读。

## 后续执行顺序与停止条件

1. Community + Ops：私有 S3 兼容目标、容器/浏览器端点、实际 CORS 和最小权限；完整原文件/对象版本/备份淘汰与恢复删除重放。优先本地隔离真实服务演练，不需要生产采购才能完善工程。
2. Core + Contracts + Ops：仅 F2 必需的已锁 Community resource/upload scopes 与条件 audience；用户委托目录/PAT分离、核对/撤销/故障后收敛；由新的真实注册客户端 OAuth 走完整资源链。方向入口见 ADR-0017。
3. 产品消费者/门户：使用已验收 SDK/preview，完成 PKCE、上传、待审状态、资源/作者浏览、许可和下架体验；管理队列权限仍按 Q-010，不提前构造。
4. Skin：受控概念管线真实基准需要新的预算/有效凭据授权与所有者视觉判定，再按已决定条件进入 F3 Official 与 Community发布。不能替其Owner发消息、付费调用或追认fixture质量。
5. F2可运行且F3可集成后，按表列顺序逐批F4，之后F5/F6/V1：升级/自部署、权利/正式保留/许可、生产恢复目标/容量/监控/法律与发布。

可以独立开发的工程继续推进；Q-001/002/003/005/008/010/013与生产决策不从“做到完美”推断具体值。当前无新增付费调用、远端push或生产部署；本次Community/Contracts提交已本地main整合，详细命令与最终SHA以各完成记录为准。
