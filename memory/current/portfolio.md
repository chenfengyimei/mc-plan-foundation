# 项目组合状态

核对日期：2026-10-09。本文为里程碑摘要；实时 Owner、锁、检查点与关闭状态以 [工作流记录](../workstreams/active/) 和 Git 为准。全局方向仍为 [F1 / Core](direction.json)；F1 以 [ADR-0013](../../decisions/0013-f1-prerelease-local-record.md) 的本地记录基线收敛证据，生产采购决策顺延至 V1 门槛。

| 仓库 | 已有事实 | 当前缺口与下一门槛 |
|---|---|---|
| Foundation | F0/GOV 与 F1 架构评审完成；ADR-0010 短事务、ADR-0011 消费者拉取、ADR-0012 Skin 匿名窗口、ADR-0013 本地预发布基线已落地 | 按完整交付路线推进 F2/后续阶段；每阶段先过所有者门槛 |
| Contracts | main `f6a7927`；Core `0.1.0-alpha.7`（锁提交 `56bff96`，注销权利端点已锁）、Skin `0.1.0-alpha.1` 已锁定；Core SDK `@mc-plan/core-sdk@0.1.0-alpha.7` 暴露 **17 个** producer 已验证操作（CONTRACTS-006 注销暴露以真实 Keycloak/PKCE smoke 验收） | Skin/Community 真实消费者集成按契约→SDK→消费者顺序另开工作流；稳定契约需至少一个真实消费者 |
| Core | main `48f2f03` 已含 CORE-001 至 CORE-011 全部关闭：身份/Profile（公开读取+编辑+注销）、Developer App/scope/PAT、每日权益、不可变积分账本、事务 outbox、消费者拉取投递面、本地有界指标面（`OTEL_METRICS_PORT` Prometheus 拉取）；运行镜像 `mc-plan-core:mcp-f1-core-011-48f2f03` | 无 active Core 工作流；后续真实跨服务消费者与 F2 集成按派工另开 |
| Community | main `69ac5e9`；仅治理与业务计划文档，无应用源码或测试 | F2 尚未启动：先审定资源上传/状态机与预发布契约，再实施资源闭环；F4 全部社区批次均未实现 |
| Skin | feat 分支 `7ec11b5`（alpha.1 匿名窗口生产者已实现：详情/预览/下载/删除、保留与级联真实运行、Web 正式接线）；分支与 origin/feat 同步 | 工作流仍 blocked 等 Q-001：所有者注入付费模型 key（apps/worker/.env，gitignored）后才可跑受控视觉基准；main 未合并（本地领先 10 提交） |
| Ops | main `3021123`；OPS-001/002/003 全部关闭：真实 Keycloak 用户/服务令牌联调、Mailpit 邮件与密码恢复、开发者应用生命周期、事件验收、双专属 project 备份-破坏-恢复演练（实测 RPO 5.0/5.2s、RTO 12.8s，按 ADR-0013 只作本地证据） | 预发布生产门槛（域名/邮件/托管数据层/监控/正式 RPO-RTO）按 open-questions 顺延至 V1 |

## 活动业务工作流

- `MCP-F1-SKIN-008`：Owner `Codely/8b150da7-6a4c-4e53-a769-422c79c12963`，仅锁 Skin，blocked。技术生产者切片（工作台、3D 预览、alpha.1 公共面）已完成并推送；唯一剩余为 Q-001 模型视觉验收——所有者须注入付费 key（预算 ≤10 次受控生成）后方可执行。不得自动解锁或宣称视觉验收通过。

注册表当前为 **46 completed / 1 active**（以 `scripts/validate-coordination.ps1` 输出为准）。除 SKIN-008 外，F1 队列内没有已登记的未完成工作流。

## 决策与证据边界

预发布基线按 [ADR-0013](../../decisions/0013-f1-prerelease-local-record.md) 为**本地记录形态**：F1 以单机 Docker 真实验收留证；Q-004（域名/地域）、Q-006（生产邮件）、Q-014（托管数据层）、Q-016（正式 RPO/RTO）按 [待决事项](../open-questions.md) 原有门槛顺延到 V1 真实部署前；Q-015 已决为本地有界指标（ADR-0013 + `MCP-F1-CORE-011`）；OPS-003 实测恢复值不升格为正式目标。Q-001 付费基准仍缺所有者侧凭据注入；Q-003/Q-013（积分来源消费与价格）未决。

完整社区、双模式 Skin、稳定 SDK、自部署与上线加固均属于 V1 范围。不能以文档齐全、Fake Provider 流程通过、某仓单测通过或工作流数量代替产品验收。
