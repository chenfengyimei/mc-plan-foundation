# 状态

核对日期：2026-10-09。阶段：F0/GOV 已完成；F1 Core 以 ADR-0013 本地记录基线收敛证据。Foundation 维护治理文档和协作工具，不承载业务代码。

已完成：六仓边界、宪法、工程标准、F1 架构评审、注册表、仓库锁、开发与统筹 Skill；同 Mac 短事务与隔离扫描工具；ADR-0011 消费者拉取、ADR-0012 Skin Standalone 匿名窗口、ADR-0013 本地预发布基线。

注册表核对（2026-10-09）：Core-001 至 Core-011、Contracts-001 至 Contracts-006、Ops-001 至 Ops-003、Foundation-001 至 013 全部有完成记录（Foundation-014 本切片进行中）；唯一活动业务工作流为 SKIN-008（blocked，等 Q-001 付费 key 注入后的视觉验收）。Core 事件投递乱序发布缺陷已在 CORE-008 关闭前修复并验收；注销权利端点已由 Contracts α.7 + CORE-010 + CONTRACTS-006（SDK 17 操作、真实 Keycloak/PKCE smoke）闭环；本地有界指标面（Q-015 已决，OTEL_METRICS_PORT Prometheus 拉取）已由 CORE-011 交付；双专属 project 备份-破坏-恢复演练已由 OPS-003 交付（实测 RPO/RTO 只作本地证据）。Skin alpha.1 匿名窗口生产者已实现但工作流保持 blocked；Community 尚无业务源码。

[项目组合状态](../memory/current/portfolio.md) 保存核对后的里程碑摘要；[完整交付路线](delivery-plan.md) 给出从当前状态到 F6/V1 的依赖、职责、验收和停止条件。活动工作流仍是所有权和锁的唯一真相，路线中的未来任务不预占 Tracking ID。

预发布基线（ADR-0013）：F1 预发布以本地记录形态成立——单机 Docker 真实验收留证，不采购生产域名/邮件/托管数据层/监控产品；Q-004/Q-006/Q-014/Q-016 按待决事项原门槛顺延至 V1 真实部署前；Q-015 已决为本地有界指标；实测值不升格为正式目标；本地验收真实性标准不变。本治理切片只修正过时叙述并落 ADR-0013，不改变 F1/Core 全局方向，不修改其他 Owner 的记录或业务代码。开发、测试、协调关闭、本地集成、远端发布、产品完成分别记录。
