# MC Plan 完整交付路线

状态：待逐项执行；核对日期：2026-10-07。目标：完成现有六仓的 F1–F6/V1 范围，包括完整社区、Skin 双模式、自部署和上线验收。本文安排跨仓交付依赖；接口以 Contracts、详细单仓顺序以各仓 development-plan、执行权以活动工作流为准。

## 当前执行边界

本轮已将 Core/Ops、Skin、Community/Contracts 分为三个只读核查任务，由主会话汇总治理。当前业务锁分别属于 Codely 的 CORE-008 和 SKIN-008；主会话已请求确认旧会话停止并授权保留改动接管，未收到回复前不写这些仓库。Foundation 的本轮治理与它们的业务写集不重叠，短事务期间其他会话须暂停 Foundation 协调写入。

后续每个实现工作流只有一名写入 Owner，一个主仓库、至多两个辅助仓库。表中角色是责任分配，不代表已创建会话或预留锁；新 Tracking ID 必须在启动事务里分配。不得同时启动两个 Contracts 写入者。

## 首先消除已发现的交付风险

下列为源码静态核查发现，尚未在本轮重跑业务集成测试，不冒充修复或通过证据。

1. **Core 事件丢投（P1）**。Core `prisma/migrations/20261007120000_event_pull_delivery/migration.sql` 在 INSERT 时通过 nextval 分配 delivery_position；`src/outbox/infrastructure/prisma-outbox.store.ts` 发布时只改 state/publishedAt；`src/events/infrastructure/prisma-event-delivery.store.ts` 只查询 PUBLISHED 且 position > 已确认位置。可复现时序为 A=1 延迟，B=2 先发布并被确认，A 后发布但永远不能再次被拉取。修复必须使可确认的发布进度不越过未来可见事件；仅把 nextval 移到发布方法仍不足以保证并发事务提交顺序。
2. **Ops 事件验收不完整**。未提交的 `scripts/validate-dev-events.ps1` 种子 data 只有 balance，不符合锁定 credit.changed.v1 的 CreditLedgerEntry；外层字段集合断言不能替代完整 Schema 校验。foreign cursor 场景使用伪造签名，尚未证明两个真实服务消费者隔离；用户 PKCE 令牌预期 401 与当前服务认证后 scope 检查路径可能返回 403 的行为不一致，须按锁定契约定准后实测。
3. **实现、验收、关闭叙述混淆**。CORE-008 active 且 Ops dirty，不能使用 Core 开发计划第 9 步的“已完成”作为关闭证据。Skin 仍从 gitignored demo-preview 读取候选，客户端 Blob 下载不能代替已锁定的公开字节接口。Community 仅 8 个文档/许可文件，不能算业务工程已初始化。

4. **Skin 删除与确认恢复缺陷**。`apps/worker/src/retention.processor.ts` 会话级对象删除异常后仍删除会话行，丢失未删对象的重试引用；`apps/api/src/conversations/conversation.service.ts` finalize 未检查实际 expiresAt，幂等指纹遗漏 description；`apps/worker/src/finalize.processor.ts` 候选缺失时只令任务 FAILED，可能留下 FINALIZING 会话。先用故障注入与可控时钟复现，再修复并发/恢复路径，无需外部 AI 调用。

## 交付分配与启动条件

| 顺序/责任角色 | 主仓库 → 可写辅助 | 交付结果与前置条件 | 必须返回的验收证据 |
|---|---|---|---|
| 1 Core 集成 Owner | Core → Ops | 接管现 CORE-008 或由原 Owner 继续；修复乱序发布丢投，完成真实双消费者、鉴权、确认与持久去重；保留当前 Ops 改动逐项审查 | PostgreSQL 延迟/逆序提交、失败重试、并发发布与穿插确认；真实 Keycloak 双消费者隔离及有效 foreign cursor；锁定 Schema；最终镜像与两轮隔离 Ops 验收；所有声明门禁、Finish |
| 2 SDK Owner | Contracts | 等待 1 的最终 producer；给 SDK 增加 listDeliveredEvents/acknowledgeEvents，现有 12 操作不能提前声称支持事件 | 生成零漂移、严格类型、Problem/超时/幂等重试、pack 干净消费、固定最终 producer 的真实 HTTP smoke；兼容矩阵只填真实组合 |
| 3 恢复 Owner | Ops → Core | 等待 Core/Ops 释放；提供本地隔离备份恢复，生产 RPO/RTO 未定不妨碍测量 | PostgreSQL + Keycloak 分离备份；恢复后身份映射、PAT 撤销、账本余额、outbox 与消费者进度一致；不发真实通知；报告实测恢复时间、数据损失窗口、失败回退 |
| 4 Core 资料 Owner | Core → Contracts（需要时） | 核实已有公开资料契约与身份/权利决策；实现作者公开资料、必要停用/删除生命周期；新语义先 ADR/契约，SDK 后置 | 隐私字段白名单、越权拒绝、停用与撤销、幂等及审计；公开 getPublicUser producer 通过后再让 SDK/Community 消费 |
| 5 权益 Owner | Core → Contracts | Q-003/Q-013 与失败补偿语义决定后，交付公开积分消费、免费额度耗尽回退、退款/调整可用入口 | 单事务只能选择一种来源；并发无双扣/负余额；同键重试、跨日重放、原额退款上限；禁止代填奖励和价格 |
| 6 F1 验收 Owner | Ops → Core | 汇总 1–5、已有邮件/身份流程和 F1 acceptance；补指标、追踪与预发布缺口 | 注册/验证/找回→PKCE→稳定身份、权限/权益/账本、审计/outbox、恢复；生产邮件和环境决策进入预发布前补齐；Foundation 据证据决定 F1 退出 |
| S1 Standalone 接口 Owner | Skin → 无 | 可与 Core 业务实现并行，但必须先正式交接 Skin 锁并重新界定工作流；Contracts alpha.1 已存在；不得用 008 原范围直接加入其明确排除的 API/迁移 | 详情及消息、候选预览、成品下载、会话级删除按已锁定契约落地；全新 clone 不依赖忽略路由；未知/过期/已删除返回契约错误；幂等、删除/worker 竞态、真实字节和移动端 E2E |
| S2 保留期 Owner | Skin → 无 | 接续 S1，独立完成候选 24 小时/会话 30 天清理和失败恢复；使用确定性 Fake Provider 即可验收 | 注入时钟、过期读取拒绝、文件与数据库一致性、删除级联、正在执行任务重试不复活资源；重启与并发 E2E |
| S3 模型质量 Owner | Skin → 无 | 单独核实 Q-001 授权、模型、预算、凭据及有限基准范围；保持 SKIN-008 质量门槛，未通过不关闭 | 多主题 Steve/Alex、双层、提示一致性、编辑一致性、延迟、成本、有效率及人工视觉验收；技术 PNG 校验与视觉结论分开；禁止无界抽卡 |
| 7 F2 前置 Owner | Foundation → 无 | F1 退出后按 roadmap 更新方向，批准上传/资源状态机/审核/许可威胁模型和必要 ADR；Community AGENTS 与当前阶段一致 | 数据所有权、状态/可见性、上传完成与受控下载、许可快照、失败降级/删除边界、Q-009 决策门槛；不宣称 draft 即稳定接口 |
| 8 Community 契约 Owner | Contracts → 无 | 等待 7；将 Community draft 升为可执行预发布契约，补缺少的作者查询/上传完成/下载及错误幂等语义 | OpenAPI/Schema/示例、权限与版本/兼容分类、机器门禁；SDK 保持 producer 先行 |
| 9 资源存储 Owner | Community → 无 | 等待 8；初始化独立 NestJS/Prisma/PostgreSQL、存储与任务适配器；短期上传、文件校验、资源不可变版本/许可快照 | 真实 PostgreSQL 与对象存储、空库/升级迁移、归属/大小/哈希/真实媒体类型、过期清理；跨仓零源码与跨库依赖 |
| 10 发布闭环 Owner | Community → Ops（真实镜像出现后） | 实现审核→发布→详情/作者页→受控下载，以及立即下架、七天清理、备份淘汰；Q-009 与许可决策按门槛补齐 | 用户 PKCE 与最小服务 scope、审核故障安全、重复发布幂等、版本/许可不可变、删除/恢复不复活文件、MinIO/S3 兼容集成 |
| 11 Official 权益 Owner | Skin → Core、Contracts（确需变化时） | 等待 Core/SDK、S1–S3，独立实现登录/验证状态/年龄门槛/每日权益/积分与失败退款 | 官方模式不可绕过；只扣一种来源；断线重试无双扣；相同构建的 Standalone 完全不依赖 Core/Keycloak |
| 12 Official 发布 Owner | Skin → Community、Contracts（确需变化时） | 等待 10、11；用户知情确认、代表用户授权上传、审核与自动公开、发布结果恢复 | 从注册到生成/预览/确认/发布/下载的真实端到端；幂等、权限、失败补偿及删除；不同时写 Core 形成四仓工作流 |
| 13 完整社区 Owner | Community → Contracts 或 Ops（按实际需要） | F2 可运行且 F3 可集成后，按下表逐批实现 F4；Q-008/Q-010 在相应门槛决定 | 每批分页稳定、权限、幂等/撤销、反作弊、审核、性能、回退与浏览器 E2E；全部通过才称完整社区 |
| 14 自部署/SDK Owner | 各应用或 Contracts 分别为主 → 必要的一仓 | F5：各应用独立镜像/示例/升级路径、PKCE 接入、TypeScript 稳定 SDK 与第三方示例；Python 只在真实需求出现时启动 | 全新环境安装、无私有源码依赖、迁移/升级/回退、consumer/provider 契约矩阵、OAuth 示例；稳定版须真实消费者通过 |
| 15 V1 发布 Owner | Ops → 当前受验应用；Foundation另开治理切片 | F6：安全评审、法律/隐私、容量、恢复、监控告警、事故预案、发布审查；生产供应商/域名/地域/预算等输入齐备 | 实际压测/恢复/告警/回退证据、法律文本审批、所有产品验收清单关闭；发布授权单列，不由本地测试代替 |

## F4 必须保留的完整范围

严格按 Community 开发计划分批，不因 MVP 而删减：

1. 标签、搜索、最新资源。
2. 点赞、收藏及撤销。
3. 评论及内容治理。
4. 关注与关注流。
5. 热门、排行、可解释规则推荐与反作弊。
6. 站内通知、已读与事件去重。
7. 举报、处置、申诉与管理权限审计。

## 并行与返回主会话的规则

Core + Ops 可以与仅 Skin 的实现并行；Contracts 修改必须串行并且先于相应 producer。SDK 不得与同仓契约修订同时写。Foundation 持有治理锁时所有协调写入服从短事务规则；本文没有开启新的业务方向、支付权限或远程发布权限。

每一批返回 Tracking ID、当前 Owner、各仓最终提交与可达性、实际运行的命令/结果、迁移/运行配置/回退、未解决门槛。主会话核对 Git 和记录后才移动到 completed、运行 Finish 并安排本地集成；远端发布与产品验收另记。发现同仓其他写入、未声明脏文件或契约缺口时先保存证据，不自动 stash/reset 或抢锁。

## V1 完成判据

六仓能独立构建/部署且跨仓契约兼容；真实用户完成注册、生成、发布、社区互动、删除与权利流程；Standalone 和 Official 均有端到端证据；完整 F4 范围、保留清理、备份恢复、安全/法律/运维门槛均通过。未达这些条件时必须报告仍未完成的批次和 Owner，不给无依据百分比。
