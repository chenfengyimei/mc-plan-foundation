# MC Plan 跨工具开发会话开局提示词

用途：在 Codex、ChatGPT Work、Tuanjie Codely（包括 GLM-5.3）或其他具备本地文件与 Git 能力的开发代理中启动新的 MC Plan 会话。将下方“可复制提示词”完整发送给新会话，再补充本次具体目标；不要只发送某个子仓库的需求。

## 可复制提示词

你正在参与 **MC Plan** 多仓项目。工作区根目录是 `D:\xm\MC`。本次总原则是：优先完善可运行、可验证、可独立部署的底层框架与项目骨架；按当前全局方向一次只完成一个有明确边界的工作流，不在一个会话里同时铺开所有项目，也不以大量占位文件冒充完成。

在进行任何写操作前，必须完成以下只读启动流程，并向我简要报告读取结果：

1. 完整读取权威协作 Skill：`D:\xm\MC\mc-plan-foundation\.codex\skills\mc-plan-development\SKILL.md`，以及该文件要求的相关 `references/`。这是跨工具的权威规则；即使当前工具不能自动加载 Skill，也必须把它作为操作协议执行。
2. 如当前环境支持用户级 Codex Skill，再检查 `C:\Users\cy\.codex\skills\mc-plan-development\SKILL.md` 是否存在且与权威版本一致；权威版本永远以 Foundation 中的副本为准。非 Codex 工具不得因为没有用户级副本而跳过第 1 步。
3. 读取：
   - `mc-plan-foundation/memory/current/repositories.json`
   - `mc-plan-foundation/memory/current/direction.json`
   - `mc-plan-foundation/memory/current/portfolio.md`
   - `mc-plan-foundation/memory/workstreams/active/` 下全部记录
   - `mc-plan-foundation/AGENTS.md`
   - 拟写入仓库的完整 `AGENTS.md`、`docs/STATUS.md` 和 `docs/development-plan.md`
4. 检查六个独立 Git 仓库的当前分支、工作树、最近提交和远程地址。保留已有用户修改，不得清理、覆盖或把工作区根目录变成父级 Git 仓库。

写操作的强制限制：

- 必须有 Tracking ID、Foundation 中已提交的活动工作流记录、唯一主仓库和包含 Tracking ID 的短期分支；最多两个可写辅助仓库。只读参考仓库不限数量。
- 不得与其他活动工作流共享任何可写仓库。锁不自动过期；接管必须有用户明确授权并记录完整交接历史。
- 每次以唯一主仓库为重心。超过两个辅助仓库，或任务已变成另一个主要目标时，拆成有依赖关系的后续工作流，一个完成并关闭后再开始下一个。
- 开始、继续和完成前分别运行：

```powershell
pwsh -File .\mc-plan-foundation\scripts\validate-coordination.ps1 `
  -TrackingId <ID> -Phase Start|Continue|Finish
```

- 公共 API、Schema、事件、权限作用域或 SDK 变化必须先改 `mc-plan-contracts` 并验证，再按“契约 → 生产者 → SDK → 消费者 → Ops”顺序推进。仓库之间不得导入源码、查询对方数据库或复制公共类型。
- 当前阶段优先建立底层工程骨架、模块边界、配置与依赖约束、健康检查、测试骨架、契约验证和最小纵向闭环。不要提前堆叠完整业务功能，也不要生成无法运行或缺少真实接口依据的伪配置。
- 所有工作只保存在各仓库本地 Git 提交；不得创建远程仓库、推送、提交密钥或生产值，除非我另行明确授权。
- 小步提交。每个可提交切片都要更新工作流检查点；结束时必须把实际提交、验证结果、阻塞或交接写回 Foundation，不能只在聊天中说明。
- 所有结论以仓库当前文件为准，不依赖模型聊天记忆。发现 Skill 版本滞后、方向不符、范围膨胀、未知仓库、错误分支、未声明改动或验证失败时，立即停止写操作并报告。

本次默认目标：根据 `memory/current/direction.json` 的主方向，完善对应项目的底层框架与骨架，并形成一个可验证的小型纵向切片。先判断是继续现有活动工作流、需要正式接管，还是创建新的单主仓库工作流；不要自行假定。

启动报告必须明确列出：当前里程碑、全局主项目、入口门槛、活动工作流与仓库锁、本会话建议的 Tracking ID、唯一主仓库、可写辅助仓库、只读参考仓库、本次范围/排除项、契约影响、预期验收命令。若入口门槛未满足，只完善获准的文档/评审材料，不开始业务实现。

完成一个工作流后先提交、验证、关闭记录并释放分支，再等待我确认或按已批准的依赖顺序进入下一个工作流。不要把多个项目的开发合并成一次模糊的“大改”。

## 使用说明

- 新会话仍需附加一句清晰的本次目标，例如“本次只做 Core 的工程骨架和 Keycloak 最小集成设计”。
- 如果机器路径不同，只替换工作区根目录；仓库内相对路径和治理规则不得省略。
- 非 Codex 工具应把本提示词和权威 Skill 当作同等强制的仓库操作协议，但不能声称已经执行自身不支持的能力。
- 本提示词不取代活动工作流记录。Foundation 中的机器可读状态始终优先于粘贴文本。
