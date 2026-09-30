# MC Plan Foundation Agent Guide

本仓库只维护跨项目文档、标准、决策、状态、模板和协作 Skill。

工作前必须：

1. 阅读 `docs/constitution.md`、`docs/system-architecture.md` 和相关 ADR。
2. 区分长期决策、单仓实现状态和 GitHub 任务，避免复制同一事实。
3. 公共接口变更先在 `mc-plan-contracts` 建立版本化契约，再更新说明。
4. 新决策使用 ADR；不得改写已接受 ADR 的历史结论。
5. 文档正文以中文为主，代码标识、API 名称、文件名和稳定术语使用英文。

不得在本仓库加入业务源码、生产密钥、真实用户数据或生产环境专有配置。

提交前检查 Markdown 链接、术语、仓库名称、状态与 ADR 是否一致。项目范围开发任务优先使用 `$mc-plan-development` Skill。
