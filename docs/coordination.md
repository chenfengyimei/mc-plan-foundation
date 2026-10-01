# 多仓协调模型

状态：Accepted

适用范围：MC Plan 工作区、开发会话和新项目准入

## 真相分层

| 记录 | 真相内容 | 不记录 |
|---|---|---|
| `memory/current/repositories.json` | 已知项目、路径、类型、可见性和生命周期 | 任务进展、接口字段 |
| `memory/current/direction.json` | 当前全局里程碑、主要项目、入口和退出门槛 | 单次任务细节 |
| `memory/workstreams/` | 会话主方向、锁、提交、验证、阻塞和交接 | 长期产品决策 |
| `memory/current/portfolio.md` | 跨仓里程碑摘要 | 每次提交和审查讨论 |
| 各仓 `docs/STATUS.md` | 单仓里程碑状态 | 其他仓实现状态 |

公共接口仍以 Contracts 为准，长期跨仓决策仍以 ADR 为准。

无法自动发现仓库 Skill 的开发工具，必须使用 `templates/session-start-prompt.md` 启动会话，并直接读取 Foundation 中的权威 Skill。开局提示词可以保存项目所有者对“创建下一个合法工作流、完成架构门槛后顺序进入主方向”的明确授权，但不能覆盖机器可读的当前方向、活动锁或仓库边界。

## 目录和状态

- `memory/workstreams/active/`：`planned`、`active`、`blocked` 或 `handoff_required`。
- `memory/workstreams/completed/`：`completed` 或 `cancelled`。
- 文件名必须等于 `<tracking_id>.json`，结构版本为 v1。

协调器不提供自动超时解锁。`initial_owner` 不可改写；当前 `owner` 与其不同时，最后一条交接历史必须说明来源、接收者、时间和原因。失去原会话时，新会话先读取记录和 Git 状态，再完成显式接管。

## 校验命令

从工作区根目录执行：

```powershell
pwsh -File .\mc-plan-foundation\scripts\validate-coordination.ps1 `
  -TrackingId MCP-F1-CORE-001 `
  -Phase Start
```

`Start` 与 `Continue` 要求记录位于 active 且当前分支、基线和锁有效；`Finish` 要求记录已经进入 completed、最终提交存在、仓库干净且验收证据完整。

## 新项目

新项目先以 `proposed` 登记，不要求目录存在。ADR 接受后进入 `approved` 并创建独立仓库；README、AGENTS、LICENSE、状态页、开发计划和验收命令全部存在后才能改为 `active` 并成为工作流主仓库。
