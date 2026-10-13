# MC Plan 完整交付路线

状态：待逐项执行；核对日期：2026-10-13（F1 收官落档段新增）。目标：完成现有六仓的 F1–F6/V1 范围，包括完整社区、Skin 双模式、自部署和上线验收。本文安排跨仓交付依赖；接口以 Contracts、详细单仓顺序以各仓 development-plan、执行权以活动工作流为准。

## 2026-10-13 F1 收官落档（MCP-F1-FOUNDATION-016）

F1 里程碑按项目所有者 2026-10-13 ask_user 实答落档：**工程面完成，正式收官待 MCP-F1-SKIN-009 视觉验收通过**。证据矩阵已逐条核验（每项的记录位于 `memory/workstreams/completed/`，终态提交经 `git merge-base --is-ancestor` 验证在对应仓 main 可达）：

- **Core（9 项全关，main 9303cc6=origin）**：CORE-004 日额度、CORE-005 不可变积分账本/余额、CORE-006 outbox 发布器、CORE-007 dev-app Keycloak 生命周期、CORE-008 消费者拉取投递+首个真实消费者、CORE-009 公开资料、CORE-010 注销、CORE-011 本地有界指标面、CORE-012 发布位序串行化修复；302 项自动化 + 镜像 smoke。
- **Contracts（6 项全关，main e4d6de1=origin）**：core `0.1.0-alpha.7`（PAT/权益/事件/公开资料/注销全链）+ Core SDK 17 操作、skin `0.1.0-alpha.1`（ADR-0012 匿名窗口八操作）、community `0.1.0-alpha.2` + Community SDK alpha.2 十操作（F2-CONTRACTS-002）。
- **Ops（4 项全关，main a0e78d7=origin）**：OPS-001 真实 Keycloak 令牌、OPS-002 真实邮件流（Mailpit，非生产邮件）、OPS-003 备份-破坏-恢复演练（实测 RPO 5.0/5.2 秒、RTO 12.8 秒，只作本地证据不升格，Q-016 未决）、OPS-004 镜像统一 mcp-f1-core-012-closeout + OTEL_METRICS_PORT 指标接线 + validate-dev-metrics.ps1 真实验收。
- **Skin（001..008 全关，main 8932395=origin）**：SKIN-008 按所有者 2026-10-12 权威决策以**工程范围**收官——离线 Pixel Foundry 工作台、skin alpha.1 生产者四端点、v4 逐像素蓝图协议第 1-6 轮与确定性渲染器全部完成并经全量门禁；**视觉验收未由任何候选通过**（flash 证伪 1.5/2/4/1、旗舰 glm-5.3 两把交付 key 均无配额未获测试窗口），连同两路线可比指标口径移交 MCP-F1-SKIN-009；Q-001 路线决策落 [ADR-0015](../decisions/0015-skin-visual-acceptance-route-concept-bridge.md)，**正式厂商绑定保持未决**。
- **治理**：ADR-0011（消费者拉取）、ADR-0012（匿名窗口）、ADR-0013（预发布基线=本地记录：本地运行基线 + Q-015 已决 + Q-004/Q-006/Q-014/Q-016 顺延 V1 + 实测值不升格）、ADR-0014（F2 工程入口）、ADR-0015（Q-001 路线）。
- **F1 出口证据**：身份/PAT/权益/积分/审计/outbox/事件投递完整闭环（真实容器与真实令牌）、恢复演练实测、本地指标面、canonical 非 root 镜像、六仓 main=origin 推送完成——均按 ADR-0013 本地记录形态成立。

**F2 进行中基线**：F2-CONTRACTS-001（community alpha.2）、F2-COMMUNITY-001（生产者 main 70e55a1 + 镜像）、F2-CONTRACTS-002（Community SDK）、F2-FOUNDATION-001（全仓对账）已关；**MCP-F2-CONTRACTS-003 仓内契约与 SDK 已交付推送（community alpha.3 匿名内联 preview 锁 + SDK alpha.3，contracts main f723c94=origin；记录归档待本切片释放 Foundation 锁后补办）；MCP-F1-SKIN-009（概念桥接）实施中**；Q-009 审核方案、Q-003/Q-013 及 V1 门槛维持未决。F1 正式收官的唯一待条件=SKIN-009 视觉验收通过（含其后的 Q-001 厂商绑定新 ADR）；F2 完整出口（目标 S3/备份恢复/审核放行）与 F4/F5/F6/V1 顺序不变。

下一节（2026-10-12 F2-FOUNDATION-001 对账）结论保留为历史基线；其中"Skin 仍 blocked/cf386b6、记录仍 blocked"等行已被本节与 2026-10-12 深夜关闭事实取代（SKIN-008 已按所有者决策工程范围收官）。

## 2026-10-12 本轮实际交付与下一停止条件

Core收尾 main9303cc6：302项自动化验证与真实runtime/DB故障smoke全过；Community main70e55a1（代码779803e）：alpha.2十操作、45项验证、真实Keycloak PKCE/独立Core活动身份、S3实际字节封存、PNG有界解压与stale-lease隔离、终态下架/七天清理、非root镜像及外部签名PUT→封存→版本→待审/故障smoke全过。Contracts main63592a2锁alpha.2，Core SDK门禁与真实smoke保持通过；工作流均关闭并本地整合。

本次没有完成整个项目：runtime审核disabled，Q-009答复未到，不能放行正式资源；完整F2对象/备份/恢复和F4全部社交/Web均仍在出口之外。下一顺序：

1. 所有者决定Q-009（已提出本地人工审核放行/指定机器提供商两种方案）；据决定先审定权限/语义，再契约、审核adapter与真实故障验收。Elapsed time不是批准。
2. Community + Ops真实目标S3/私有桶CORS/容器外部端点、七天对象清理、三十天备份淘汰/恢复删除重放、限流/容量；只有真实演练后关闭完整F2。
3. Core + Contracts + Ops按依赖补官方DeveloperApp的Community scope/audience及SDK/真实第三方接入；公开计费等Q-003/Q-013裁决，年龄/其他权利表面仍按既有决定先契约。
4. Skin仍归原Owner，cf386b6代码推进不等于视觉验收通过；Q-001视觉/配额条件满足后才可关闭，不自动接管其锁。F3官方权益/发布链需该Owner依赖配合。
5. F2可运行、F3可集成后严格逐批交付F4：标签搜索最新、互动、评论、关注、热门排行推荐（Q-008）、通知、举报处置申诉（Q-010）；完整Web/无障碍/反作弊/性能仍需实测。
6. F5/F6/V1仍需独立自部署升级/SDK、法律隐私/正式许可/保留、生产采购/监控/恢复目标、容量及发布授权。

仅本地提交；没有远端推送或部署。S3测试是磁盘S3rver协议服务，审核是明确标识的测试port；不冒充MinIO/COS/生产供应商。历史段保留，但当前事实以direction/portfolio/记录/Git为准。

## 2026-10-12 执行更新（本轮入口历史）

所有者要求完成全项目并优先 Core 与社区。CORE-012 已完成全量与运行镜像复验，并用真实受控 AFTER UPDATE 反例修复 CORE-008 未覆盖的提交反序漏洞：数据库短事务咨询锁串行化取位至 COMMIT，sink/认领在锁外。F2 本地资源工程由 ADR-0014 批准，方向与社区 AGENTS 已同步；第 7 项入口治理已落实，第 8 项契约先行。旧统计与顺序描述保留为历史，以当前 direction/portfolio/工作流及 Git 为准。Q-009 未决时不放行发布；Q-003/Q-013、F4 与 V1 门槛仍明确未完成；Skin 锁与脏修改保留。

## 当前执行边界（2026-10-09 历史快照）

注册表核对 2026-10-09：46 completed / 1 active。下表第 1–4 项已全部交付并关闭（CORE-008、CONTRACTS-004、OPS-003、CORE-009/010+CONTRACTS-005/006）；CORE-011（本地有界指标）与 ADR-0013（本地预发布基线）已落地。唯一活动业务工作流为 SKIN-008（blocked，等 Q-001 付费 key 注入后的视觉验收）；第 5 项仍等 Q-003/Q-013 所有者决策。

后续每个实现工作流只有一名写入 Owner，一个主仓库、至多两个辅助仓库。表中角色是责任分配，不代表已创建会话或预留锁；新 Tracking ID 必须在启动事务里分配。不得同时启动两个 Contracts 写入者。

## 已消除的交付风险（2026-10-07 静态核查发现，2026-10-09 核对关闭）

1. **Core 事件丢投（P1）——已修复并验收**。`MCP-F1-CORE-008` 关闭前重构为发布时赋位：`markPublished` 在翻转 PENDING→PUBLISHED 的同一自动提交 UPDATE 内 `nextval` 赋 `delivery_position`，发布顺序即位置顺序；真实 PostgreSQL 回归 T1 退避后发布、T2 迟提交业务事务、T3 双实例收敛、T4 双发布器真并发全部通过。
2. **Ops 事件验收不完整——已修复并验收**。`scripts/validate-dev-events.ps1` 已提交（Ops main `3021123`），种子为锁定合法 CreditLedgerEntry（先验后插）、双真实服务消费者 A/B 隔离与跨消费者游标拒绝，两轮独立真实验收全绿（关闭记录见 `MCP-F1-CORE-008`）。
3. **实现、验收、关闭叙述混淆——已消除**。CORE-008 已关闭（Core main `48f2f03` 祖先链内）；Skin gitignored demo-preview 已在 `MCP-F1-SKIN-008` alpha.1 扩展中由正式公共详情/预览/下载/删除端点替代；Community 仍无业务源码（如实保留）。
4. **Skin 删除与确认恢复缺陷——已在 `MCP-F1-SKIN-008` alpha.1 生产者扩展修复**。对象清理失败入队可重试任务携带失败键（行级数据先行移除、重试依据保留），24h/30d 可控时钟边界测试与 chmod 故障注入（含删除防复活）通过；工作流仍 blocked 等 Q-001 视觉验收，未合并 main。

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

## 2026-10-13 当前执行更新（优先于上文历史快照）

MCP-F2-COMMUNITY-002已关闭：alpha.4人工审核和alpha.3预览producer + 十二方法SDK + 真实权限/故障/双模式runtime证据。Q009不再是待决或adapter未落地的门槛。Skin009已关闭为厂商中立工程能力，受控真实基准与视觉判定仍待Owner条件；没有active Skin实现锁。当前逐模块现状和剩余工程见module-completion-review.md，ADR0017允许Core官方OAuth前置而不改变F2主方向。下一顺序为Community/Ops对象与恢复、Core/Contracts/Ops官方接入、消费者门户，再满足F3后逐批F4。历史“Q009未决/Community无源码/Skin009实施中”的文字仅是当时快照，不作为当前事实。
