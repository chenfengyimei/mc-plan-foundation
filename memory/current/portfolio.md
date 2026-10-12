# 项目组合状态

核对日期：2026-10-13（凌晨，MCP-F1-FOUNDATION-016 F1 收官治理切片）。全局仍为 [F2 / Community](direction.json)。F1 里程碑按项目所有者 2026-10-13 ask_user 实答落档：**工程面完成，正式收官待 MCP-F1-SKIN-009 视觉验收通过**（34 项已关工作流证据矩阵逐条核验，见 [交付路线](../../docs/delivery-plan.md) F1 收官段；Q-001 路线决策见 [ADR-0015](../../decisions/0015-skin-visual-acceptance-route-concept-bridge.md)）。F2 进行中；完整 F2/F4/V1 尚未完成。Owner/锁/检查点以工作流与 Git 为准。

| 仓库 | 当前已证事实 | 未完成门槛 |
| --- | --- | --- |
| Foundation | ADR-0011/0012/0013/0014 已采纳；ADR-0015 落档 Q-001 路线改选概念图管线（正式厂商绑定保持未决）；本切片完成 F1 收官治理（证据矩阵核验 + 里程碑落档）；F2-FOUNDATION-001 全仓对账结论保留为历史基线 | 依据真实证据逐阶段关闭门槛，不用文档替代实现 |
| Core | main 9303cc6=origin；CORE-001..012 全关：日额度、不可变账本/余额、outbox 发布器、dev-app Keycloak 生命周期、消费者拉取投递+真实消费者、发布位序串行化修复、公开资料、注销、本地指标面；302 项自动化 + canonical 非 root 镜像 smoke 全绿 | Q-003/Q-013 奖励与公开积分回退/价格；年龄/权利扩展、官方开发者应用 Community scope/audience 接线按对应决策推进 |
| Contracts | main f723c94=origin；core alpha.7 + Core SDK 17 操作、skin alpha.1、community alpha.3（F2-CONTRACTS-003 仓内已交付：匿名内联 preview 契约锁 664fb9d）+ Community SDK alpha.3（previewResourceVersion 无 producer 证据显式排除，保持 10 操作）、community alpha.2 生产者基线 + Community SDK alpha.2 十操作（F2-CONTRACTS-002 已关）；CONTRACTS-001..006 全关，全部门禁与真实 smoke 通过 | 官方消费者与稳定发布；F2-CONTRACTS-003 记录归档待本切片释放 Foundation 锁后补办 complete+Finish；不以本地合成审核证明正式审核 |
| Community | main 70e55a1=origin，代码树 779803e；45 测试（13 单元/2 契约/30 集成）；10 API、Core 活动身份、S3 签名/封存、PNG 有界解压、不可变版本许可、分页下载、终态下架/七天清理、租约恢复与 fencing；真实 PKCE 和 runtime 完整上传待审/故障 smoke 通过 | Q-009 审核方案未决，runtime disabled 保持待审；目标 S3/备份恢复、正式保留/许可、官方接入、F4 全部社交与 Web 仍未完成；官网门户（P3）待 F2-CONTRACTS-003 preview 契约后实施 |
| Skin | SKIN-008 已按所有者 2026-10-12 权威决策以工程范围收官：main 8932395=origin 已推送（15 个工作流提交 ff 合入 + 收官 docs），远端 feat 分支已删除；视觉验收未由任何候选通过（flash 档证伪 1.5/2/4/1 高方差、旗舰 glm-5.3 两把交付 key 均 1113 无配额未获测试窗口），连同两路线可比指标口径移交 MCP-F1-SKIN-009（ADR-0015）；SKIN-009 active：概念图→视觉 LLM→v4 管线厂商中立实施中（基准 ADR 前不绑定任何厂商、生产拒绝非基准适配器） | Q-001 厂商绑定未决（待概念管线受控基准后新 ADR）；Q-011/Q-012；SKIN-009 实施与其后基准；Official 权益/发布链后续 |
| Ops | main a0e78d7=origin；OPS-001..004 全关：真实 Keycloak 令牌、Mailpit 邮件流、备份-破坏-恢复演练（实测 RPO 5.0/5.2 秒、RTO 12.8 秒，只作本地证据不升格）、镜像统一 mcp-f1-core-012-closeout + OTEL_METRICS_PORT 指标接线 + validate-dev-metrics.ps1 真实验收 | Community 目标对象存储、备份最长 30 天淘汰、恢复前删除重放/限流/容量/审核故障；生产采购与正式 RPO/RTO 仍待决（Q-004/Q-006/Q-014/Q-016） |

镜像：Core mc-plan-core:mcp-f1-core-012-closeout（sha256:9f48bad577be79339e8870a92c62a13a49ac121ab58dffe5806287190a7996ea）；Community mc-plan-community:mcp-f2-community-001-779803e（sha256:a4654b59fb4807c492e096535e7fb4898bf269709dce6ed7df3ecbfbee6b047d）。证据目录：/Users/chenfeng/.codex/outputs/mc-closeout-20261012/（CORE-012/F2 批次）、mc-skin008-benchmark-20261010/ 与 mc-skin008-flagship-20261012/（Q-001 受控基准证据，ADR-0015 事实出处）。测试 S3 为磁盘 S3rver 协议服务，审核 allow/reject 为 SYNTHETIC-MODERATION；两个限定均不省略。

推送状态（2026-10-13 凌晨 fetch 实测）：core/contracts/community/ops/skin 五产品仓 main 均已=origin/main 推送完成；Foundation main 由本切片收官推送（含此前 27 个未推记录提交——均为已关工作流终态；总控存量推送未及执行，按派工"已推存量则只推增量"规则由本切片一并 ff-only 推送）。注册表实况（本切片提交时点）：55 completed + 3 active（MCP-F1-SKIN-009、MCP-F2-CONTRACTS-003、本切片收官流程中）。下一步依 [交付路线](../../docs/delivery-plan.md)；全项目剩余门槛见该文件，不给无依据完成百分比。
