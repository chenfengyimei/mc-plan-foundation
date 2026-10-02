# 项目组合状态

更新时间：2026-10-02

| 仓库 | 阶段 | 当前目标 | 下一决策门槛 |
|---|---|---|---|
| Foundation | F0/GOV 完成；F1 评审门槛通过 | v1.0 基线、工作流治理、开发 Skill 与 `mc-plan-orchestrator` v1.0 已本地归档 | 持续核对方向、锁和组合状态；不承载业务代码 |
| Contracts | F0/GOV 完成；F1 辅助活动 | `0.1.0-draft` 骨架验证通过；`MCP-F1-CORE-001` 已在辅助分支修正 Redocly 多 binary 启动命令 | 随 Core 工作流完成协调关闭；首个公共业务接口前锁定预发布契约 |
| Core | F1 活动；首个工程切片已实现 | `MCP-F1-CORE-001` 已完成运行骨架、数据库 readiness、OIDC 边界、可观测性、容器和全套验收；记录仍为 blocked/open | 原工作流重新核对已经变化的 Skin 锁条件，完成 Continue/Finish 与本地集成；随后进入 IdentityLink 与 `/v1/me` 契约先行切片 |
| Community | F2/F4 计划中；实现未开始 | 资源发布闭环与社区功能顺序已固化 | F2 开始前批准资源状态机与上传契约 |
| Skin | F3 计划中；F1 受限 Standalone 持续改进（ADR-0009） | 工程骨架、Standalone 最小链路和多轮生成质量改进已完成；`MCP-F1-SKIN-008` 正在建设逐像素蓝图协议与无第三方运行时的可旋转 3D 预览 | 完成并关闭当前 Skin-only 工作流；真实 Provider 视觉基准仍受 HTTP 402 阻塞，F3 前仍须模型提供商基准 ADR，Official 集成不得越过 Core/Community 门槛 |
| Ops | F1 辅助就绪；环境未建立 | 真实输入优先的开发、预发布、恢复和扩容路线已固化 | Core 提供真实镜像与运行接口后建立环境 |

当前并行仅因锁集合互不重叠：`MCP-F1-CORE-001` 占用 Core + Contracts，`MCP-F1-SKIN-008` 只占用 Skin。Core 记录中关于“Skin 未登记活动锁”的阻塞描述已与当前事实不一致，应由原 Core 工作流所有者重新验证并关闭，而不是由新会话另建重复 Core 工作流。ADR-0009 的 Skin 准备方向不改变 Core 主方向。具体实施任务以后由 GitHub Issues/PR 跟踪；本文件只记录跨仓里程碑状态。
