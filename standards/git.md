# Git 与协作标准

## 分支

- `main` 始终可发布并受保护，禁止直接推送。
- 使用短期 `feat/<topic>`、`fix/<topic>`、`docs/<topic>`、`chore/<topic>` 分支。
- 不保留长期 `develop`；发布使用语义版本标签和可追溯发布记录。

## 提交与 PR

- 使用 Conventional Commits，例如 `feat(credits): define idempotent consumption contract`。
- 提交保持单一目的和可审查性，不以任意文件数量作为限制。
- PR 说明目标、影响仓库、公共契约、测试、数据迁移、风险、回退和关联 Issue。
- 跨仓工作使用同一追踪 ID，在每个 PR 中链接其他仓库的变更；各仓独立合并与回退。

## 合并要求

- 必需检查通过、至少一名授权审查者批准、无未解决高优先级意见。
- 契约变更先合并并发布预发布版本，再更新实现；稳定实现验证后发布正式契约/SDK 版本。
- 禁止重写共享分支历史、提交密钥或绕过失败检查。
