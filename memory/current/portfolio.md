# 项目组合状态

更新时间：2026-10-01

| 仓库 | 阶段 | 当前目标 | 下一决策门槛 |
|---|---|---|---|
| Foundation | F0/GOV 完成；F1 评审门槛通过 | v1.0 基线、工作流治理和 `MCP-F1-FOUNDATION-003` 十项评审证据已本地归档 | 维护跨仓方向与标准；不承载业务代码 |
| Contracts | F0/GOV 完成；F1 辅助就绪 | `0.1.0-draft` 契约骨架内容验证通过；Redocly 启动命令需在下一工作流兼容新版多 binary 包 | Core 首个公共业务接口前锁定预发布契约；不得提前发明 PAT/奖励字段 |
| Core | F1 活动；工程尚未开始 | 唯一全局主方向；按第一切片建立配置、数据库、健康、OIDC 边界和可观测性 | 创建并执行 `MCP-F1-CORE-001`，首切片不实现公共业务 API |
| Community | F2/F4 计划中；实现未开始 | 资源发布闭环与社区功能顺序已固化 | F2 开始前批准资源状态机与上传契约 |
| Skin | F3 计划中；F1 受限 Standalone 准备方向已批准（ADR-0009） | 在不依赖私有服务的前提下提前建立工程骨架与 Standalone 最小纵向链路（Fake Provider、2D 预览） | F3 开始前完成模型提供商基准 ADR；契约缺口先经 Contracts 工作流补全 |
| Ops | F1 辅助就绪；环境未建立 | 真实输入优先的开发、预发布、恢复和扩容路线已固化 | Core 提供真实镜像与运行接口后建立环境 |

`MCP-F1-FOUNDATION-003` 关闭并释放 Foundation 锁后，按已批准顺序启动 `MCP-F1-CORE-001`。`MCP-F1-FOUNDATION-004` 依据 ADR-0009 登记 Skin Standalone 受限准备方向，不改变 Core 主方向。具体实施任务以后由 GitHub Issues/PR 跟踪；本文件只记录跨仓里程碑状态。
