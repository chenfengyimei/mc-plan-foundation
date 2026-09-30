# MC Plan Foundation Agent Guide

本仓库只维护跨项目文档、标准、决策、状态、模板和协作 Skill。

工作前必须：

1. 使用 `$mc-plan-development`，读取当前方向、项目注册表和全部活动工作流。
2. 写入前创建活动记录并运行 `scripts/validate-coordination.ps1`；本仓库必须是主仓库或显式辅助仓库，协调记录本身除外。
3. 阅读 `docs/constitution.md`、`docs/system-architecture.md` 和相关 ADR。
4. 区分长期决策、单仓实现状态和 GitHub 任务，避免复制同一事实。
5. 公共接口变更先在 `mc-plan-contracts` 建立版本化契约，再更新说明。
6. 新决策使用 ADR；不得改写已接受 ADR 的历史结论。
7. 文档正文以中文为主，代码标识、API 名称、文件名和稳定术语使用英文。

不得在本仓库加入业务源码、生产密钥、真实用户数据或生产环境专有配置。

提交前检查协调记录、Markdown 链接、术语、仓库名称、状态与 ADR 是否一致，并运行本仓库开发计划声明的验收命令。
