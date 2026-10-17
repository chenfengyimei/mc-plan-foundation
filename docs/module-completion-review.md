# 六仓逐模块收尾核查

核对：2026-10-16，MCP-F2-FOUNDATION-007（SDK 收官同步；保留 006/005 事实）。用户要求临时人工审核并逐模块理解、开发与收尾；本表依据当前源码、已关闭记录与 Git。已完成技术切片不等于完整产品、生产部署或视觉质量通过。当前执行方向 F2 / Community；ADR0018只读管理台例外已连同其 SDK 关闭。

## Core：已实现模块及剩余范围

| 模块/源码归属 | 已验证能力 | 下一门槛 |
|---|---|---|
| identity-link | 固定 OIDC issuer/audience/JWKS/有效期/已验证邮箱，issuer+sub 幂等映射业务 ID | IdP 迁移/重绑/恢复、MFA 和生产事故流程不能由首次登录实现替代 |
| profile | 活动账号私有/公开资料、仅 display_name 编辑、业务账号注销与审计 | 年龄声明写入及其他权利表面按已有延期决定后置；注销不等于 IdP 删除 |
| authorization | 主体/业务角色/scope/凭证隔离；服务与用户认证分离 | Developer App与PAT目录已分离，既有Community三scope委托与条件audience已完成；生产realm/角色管理仍后续 |
| developer-app | 真实 Keycloak public/confidential 客户端、S256/精确回调、一次性机密、scope 收窄/撤销/补偿/核对 | Community委托/真实资源链与独立门户已验收；生产realm硬化与角色管理入口仍后续 |
| token-metadata | PAT 哈希/前缀/最长30天/撤销/过期/最后使用与审计 | 目录拆分已完成，PAT仍不能获得Community/审核/service/profile:write；正式安全与生命周期扩展另行验收 |
| entitlement | 上海日界每天3次，不累计，快照/并发/幂等消费 | Official Skin 消费者、失败策略与实际跨服务体验 |
| credits | 不可变 grant/consume/refund/adjustment，非负余额、退款封顶、只读余额、核对 | Q-003 奖励值、Q-013 会话价格；公共计费/奖励接入不能填猜测值 |
| outbox / events | 租约、重试、发布取位至提交串行化，拉取/确认、消费者幂等去重 | Community 发布事件传输与真实奖励消费者另立契约/工作流；不能直接改余额 |
| platform | 非root镜像、显式8迁移、严格配置、结构化日志、健康/本地 OTel 指标 | 生产观测、安全/容量、正式恢复目标、告警与升级演练 |

Core main690193a，API代码fb1bc07；CORE-012实证302基础已由F2-CORE-001增量扩至306项。CoreSDKalpha.8仍17操作，37项/pack及新固定镜像真实HTTP/Keycloak回归通过。源目录为 mc-plan-core/src 的对应模块，基础证据在CORE-012，增量在MCP-F2-CORE-001完成记录。

管理台 MCP-F4-CORE-001 已关闭（Core 06de705=origin：alpha.9 六管理只读操作 + apps/admin web + Ops ef00a72 真实管理员栈验收 + 浏览器 e2e；Contracts b90a3b0=origin：alpha.9 锁+SDK 重生成）。其 SDK 暴露已由 MCP-F4-CONTRACTS-001 关闭（见文末补记）。

## Community：已实现模块及剩余范围

| 模块/源码归属 | 已验证能力 | 下一门槛 |
|---|---|---|
| platform/identity | 双 audience用户令牌、每次Core活动身份、scope/速率/错误白名单、实际门户PKCE | 官方realm/全局限流/TLS与容量验收 |
| upload / storage | 私有签名PUT、大小/SHA/CRC/64×64/有界解压/UV/第二层、不可覆盖封存；真实版本S3/CORS/桶权限隔离、容器/浏览器端点 | 生产COS/地域/细粒度IAM与正式容量验收 |
| resource | 归属、容器、不可变版本/文件/许可、规范化幂等、事务审计 | 正式许可 Q-002、完整权利与保留 Q-005 |
| catalog / portal | 官方打包SDK消费：最新/作者/详情、纹理预览/字节下载、显式许可、上传/待审/作者下架；真实桌面/手机浏览器 | 搜索标签/互动等F4；当前无私有作品列表或审核队列，不虚构权限 |
| manual-review | 指定 realm 审核员 scope、确切候选 approve/reject、审计业务 ID/哈希/原因；批准原子发布/outbox | 私有待审队列、申诉与细分权限属于 Q-010/F4，当前人工按作者提供文件和ID审核 |
| worker / selfdeploy-recovery | 持久作业/租约/重试/7天清理；下架及过期上传的30天历史版本扫除、加密归档轮换；认证删除重放后空环境恢复 | 持续独立删除journal/PITR、离机调度/告警、正式元数据最小化Q005；无证明保持下线 |
| discovery / interaction / comment / social-graph | 未实施 | 标签搜索最新 → 点赞收藏 → 评论 → 关注流，逐批契约与真实验收 |
| recommendation / notification / governance | 未实施 | Q-008 权重、规则反作弊；通知；Q-010 举报处置申诉与管理面 |

Community main3e887c1，最新实现8811b69；alpha.4十二操作与Corealpha.8保持不变，20单元+3契约+47集成=70项，全量通过。固定镜像mcp-f2-community-004-8811b69，image ID sha256:2b24e90a992d92ed08c96e1a8a062fbba2121dff9a8e7b76655c07bceb101f84，manual/disabled真实runtime与公共Compose/编译后恢复CLI均通过。两轮真实Keycloak/PG/版本S3先备份后HTTP下架、销毁全部源DB/S3、空环境恢复保持404、保留字节不变；VALIDATED未绑定上传也可恢复后绑定。30天使用模拟时钟而实际删除历史版本与加密文件，非等待30个自然日。没有新增迁移，详细范围/命令/限制见 [自部署手册](../../mc-plan-community/docs/self-deployment.md) 与 completed记录。权限撤销窗口需短JWT；Core业务停用逐请求拒绝。

## Contracts、Skin、Ops、Foundation

| 仓库/模块 | 已验证 | 未交付/门槛 |
|---|---|---|
| Contracts / API-Schema-event | Corealpha.8、Communityalpha.4、Skinalpha.1已闭环；Community生成固定Git来源，避免活动树漂移 | Corealpha.9管理面属于active切片；稳定发行与未来F3/F4契约仍后续 |
| Contracts / SDK | Core 23 操作/47 测试（六管理只读已暴露，MCP-F4-CONTRACTS-001）、Community 12 方法/40 测试、Skin 8 操作/29 测试（MCP-F1-CONTRACTS-007），三包干净 pack/真实 HTTP 两轮；Community门户已实际消费锁哈希打包工件 | Official完整链与稳定发行；管理写操作契约待逐项所有者决策；不将SDK测试等同全部产品 |
| Skin / API-db-worker | Standalone八操作、幂等/三次渲染、队列重试、30天会话/24小时候选、删除防复活 | Official身份/年龄/权益/计费及Community发布未实现 |
| Skin / skin-core-validator-provider-sdk | v4确定性UV、Steve/Alex双层；fake/llm/image同链；概念图→视觉→v4厂商中立桥接 | SKIN-009已工程关闭，付费真实概念管线基准与所有者视觉验收未完成，Q-001仍未绑定厂商 |
| Skin / Web-preview | Pixel Foundry工作台、桌面/移动链、第一方动态3D/键盘交互、Provider标识 | Official完整体验与生产无障碍/性能验收；不能以离线fixture证明生成质量 |
| Ops / identity-mail-client-events-metrics | 隔离Core/Keycloak、PKCE、Mailpit、客户端/事件/指标；Community已有自己可运行自部署组合 | 官方组合与TLS/全局限流/正式邮件/生产采购；当前Ops锁在管理台切片 |
| Ops / backup-restore | Core/Keycloak恢复、撤销重放、轮换实测；Community独立DB/对象恢复已由应用自部署真实验收 | 官方离机持续恢复/独立删除journal、Q-005最小化与Q-016正式目标未完成 |
| Foundation / governance-coordination | 六仓归属/版本/锁/短事务/链接扫描与标准、真实记录关闭 | 实际门槛通过才推进里程碑，历史段不能替代当前表；本文件不决定法律或生产值 |

Skin main14a8fe3，实现检查点0462b20的历史门禁：128单元、API15/worker12真实DB、Playwright fake2/image1、fixture6；本轮未改Skin源码，不能把历史门禁冒充重跑或视觉验收。所有者提供GLM-5.3-Flash凭据后，仅运行时连通探测成功HTTP200，15输入+32思考输出=47tokens，未产生皮肤；不保存key或模型内容。完整概念图/视觉/v4基准预算问题待答，所有者视觉判定仍必需；Q001未绑定正式厂商。

## 后续执行顺序与停止条件

1. Community004已完成本地私有/版本S3、端点/CORS/桶隔离、历史对象/归档淘汰、认证恢复与门户；官方Ops组合、离机调度/持续journal与Q005仍接续。过期下架数据不得靠新备份续期，现阶段超期元数据存在时备份失败关闭。
2. 已完成：Core+Contracts+Ops按ADR0017完成官方Community委托/PAT隔离、条件audience/核对/真实登记PKCE资源链；Community003随后完成Corealpha.8来源锁与SDK/双模式新镜像消费闭环。正式realm/门户角色管理与上线硬化继续后续。
3. 门户消费者已完成上述F2链与浏览器实测；审核队列、申诉及其他管理写入口继续按Q010决策，不提前构造。
4. Skin：有效凭据连通已确认；等待当前明确预算答复后，做两条路线的受控对照及所有者视觉判定，再按既定条件进入F3 Official/Community发布。只读诊断不等于完整生成，也不追认fixture质量；不向另一会话发消息。
5. F2可运行且F3可集成后，按表列顺序逐批F4，之后F5/F6/V1：升级/自部署、权利/正式保留/许可、生产恢复目标/容量/监控/法律与发布。

可以独立开发的工程继续推进；Q001/002/003/005/008/010/013与生产决策不从“做到完美”推断值。本轮只增加已授权凭据的极小连通探测，完整皮肤生成预算待答；没有远端push/生产部署。Community004本地main已整合且锁已释放；Core/Contracts/Ops仍由另一活动管理台工作流持有。详细命令、SHA与限制以正确仓库及completed记录为准，F2与V1不提前完成。

## 协调工具收尾

FOUNDATION004修复本轮真实复现的零活动目录问题：Git省略空active目录后，旧短事务入口Get-ChildItem在调用登记action前失败；新入口在取得本人短锁后重建父目录。旧入口baseline复现失败，新登记回归与全部原锁/index/branch隔离测试验证。没有修改Skill或授权规则。

## 2026-10-16 SDK 收官补记（MCP-F2-FOUNDATION-007）

MCP-F4-CONTRACTS-001 与 MCP-F1-CONTRACTS-007 均已关闭：Core SDK 17→23（admin:read 六只读操作，producer 锚 Core 06de705，固定镜像 mcp-f4-core-001-29939a0 两轮真实 HTTP smoke，`SUPPORTED_CONTRACT_FILES` 诚实化为 23 项）；Skin SDK 首包 @mc-plan/skin-sdk 0.1.0-alpha.1（8 操作，producer 锚 skin 14a8fe3，生产者树+确定性 Fake Provider 两轮真实 HTTP smoke，匿名窗口无凭据头+64x64 PNG 先验+SKIN_* 错误码类型化）。community 终态存量 70e55a1..3e887c1 按所有者 2026-10-16 完成指令 ff-only 补推。六仓 main=origin；注册表 70 completed / 1 active（本治理切片）。执行队列已清空，剩余全部为所有者门槛项（Q-001 视觉验收/F3、管理写操作逐项、Q-003/Q-013、F2 残余、Q-010 余项、F4 批次、V1 门槛），详见 delivery-plan 2026-10-16 段的模块关系架构基线与队列。
