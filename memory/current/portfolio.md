# 项目组合状态

核对日期：2026-10-12。全局仍为 [F2 / Community](direction.json)。本次 Core 与 Community 的本地工程交付均已通过验证、关闭工作流并合入本地 main；完整 F2/F4/V1 尚未完成。Owner/锁/检查点以工作流与 Git 为准。

| 仓库 | 当前已证事实 | 未完成门槛 |
| --- | --- | --- |
| Foundation | ADR-0014 F2 工程入口与上传威胁模型；本次治理同步真实验收与后续边界 | 依据真实证据逐阶段关闭门槛，不用文档替代实现 |
| Core | main 9303cc6；CORE-012 修复提交反序漏送；118 单元/86 HTTP/25 契约/73 PostgreSQL+Keycloak 集成，共302项；canonical非root镜像/指标/DB失效 smoke 通过 | Q-003/Q-013 奖励与公开积分回退/价格；年龄/权利扩展、官方开发者应用 Community scope/audience 接线按对应决策推进 |
| Contracts | main 63592a2；Core alpha.7/SDK17操作，Community alpha.2/10操作，Skin alpha.1；Python/Redocly和Core SDK全部门禁与真实smoke通过 | Community SDK、官方消费者与稳定发布；不以本地合成审核证明正式审核 |
| Community | main 70e55a1，代码树779803e；45测试（13单元/2契约/30集成）；10API、Core活动身份、S3签名/封存、PNG有界解压、不可变版本许可、分页下载、终态下架/七天清理、租约恢复与fencing；真实PKCE和runtime完整上传待审/故障smoke通过 | Q-009审核方案未决，runtime disabled保持待审；目标S3/备份恢复、正式保留/许可、官方接入/SDK、F4全部社交与Web仍未完成 |
| Skin | SKIN-008分支cf386b6，原未提交provider修改已由现Owner独立提交；记录checkpoint同cf386b6 | 仍blocked、视觉验收未通过；原Owner锁保留，本任务未写Skin或接管 |
| Ops | main3021123；Core真实身份/本地邮件/备份破坏恢复已有关闭记录 | Community目标对象存储、备份最长30天淘汰、恢复前删除重放/限流/容量/审核故障；生产采购与正式RPO/RTO仍待决 |

镜像：Core mc-plan-core:mcp-f1-core-012-closeout（sha256:9f48bad577be79339e8870a92c62a13a49ac121ab58dffe5806287190a7996ea）；Community mc-plan-community:mcp-f2-community-001-779803e（sha256:a4654b59fb4807c492e096535e7fb8898bf269709dce6ed7df3ecbfbee6b047d）。证据目录：/Users/chenfeng/.codex/outputs/mc-closeout-20261012/。测试S3为磁盘S3rver协议服务，审核allow/reject为SYNTHETIC-MODERATION；两个限定均不省略。

本次只作本地交付，未推送/部署；GitHub远端刷新曾失败，新鲜度未确认。下一步依 [交付路线](../../docs/delivery-plan.md)；全项目剩余门槛见该文件，不给无依据完成百分比。
