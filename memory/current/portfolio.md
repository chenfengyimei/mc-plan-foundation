# 项目组合状态

核对日期：2026-10-12。全局进入 [F2 / Community 本地资源工程](direction.json)，依据 [ADR-0014](../../decisions/0014-community-local-resource-engineering.md)。F1 本地技术基线经复验，产品计费、正式采购与上线验收仍独立保留门槛。Owner/锁/检查点以工作流及 Git 为准。

| 仓库 | 当前已证事实 | 下一门槛 |
| --- | --- | --- |
| Foundation | 六仓治理与本地基线；本切片批准 F2 工程入口与上传威胁模型 | 依据真实工程证据更新组合，不提前宣布 F2/F4/V1 完成 |
| Core | 本地 main 9303cc6；CORE-012 真实延迟提交反例与咨询锁修复；118 单元/86 HTTP/25 契约/73 真实集成、canonical runtime 镜像与故障 smoke 全通过 | Q-003/Q-013 决策后公共积分回退与产品奖励；真实跨服务消费者 |
| Contracts | main f6a7927；Core alpha.7/SDK 17 操作，Skin alpha.1；Community 仍 draft | Community 预发布契约先行，producer 后 SDK/consumer；不声称稳定 |
| Community | 本切片从 F0 进入获授权的 F2 工程；业务源码尚未创建，上传威胁模型已批准 | 上传/验证/版本/许可/查询/下载/删除；Q-009 审核方案待所有者决定；F4 全部批次仍未实现 |
| Skin | SKIN-008 分支 7ec11b5，alpha.1 匿名窗口 producer 已实现；provider-sdk 有未提交修改 | 记录仍 blocked，付费 flash 基准未达视觉验收；现 Owner 的锁和修改保留，不接管 |
| Ops | main 3021123；真实 Keycloak/本地邮件/双项目备份破坏恢复、本地指标基线已有关闭记录 | Community 镜像出现后 S3/审核/清理/备份与 OAuth 联调；V1 生产输入仍待决 |

本次本地交付不推送、不部署。GitHub 刷新连接失败，远端新鲜度未确认；不得把本地 ahead 误写成已发布。后续按 [完整交付路线](../../docs/delivery-plan.md) 执行，审核、许可、推荐/管理权限和生产上线门槛保持明确。
