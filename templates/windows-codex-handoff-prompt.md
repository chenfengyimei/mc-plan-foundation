# Windows Codex 接收提示词（2026-10-20 快照）

以下整段可以复制到 Windows Codex。旧的绝对路径不适用于新机器；先以实际根目录为准。

```text
请接手 MC Plan 的 Mac → Windows 迁移，并在接收验收后续接原有未完成工作。

项目所有者已明确授权：把当前 MC 工作区、已有成果、资料和提示词迁移到 Windows Codex，可进行必要的 Git 提交和 GitHub 推送。我授权你按本次迁移交接接收已有 MCP-F4-CORE-002 的所有权，须在 Foundation 记录真实接收会话、原 Owner、提交和未完成项后才能续写。不得将此授权扩大为生产部署、付费模型调用、密钥公开或替我决定尚未决定的产品/供应商/法律/价格事项。

先发现实际环境。现有 Foundation 短事务工具不支持原生 Windows，开发采用 Windows Codex 的 WSL2 agent。仅切换终端不够；如果仍在 Windows native，先按官方设置切到 WSL 并重启，然后在 WSL 的 ~/src/MC 工作。不要绕过锁工具。

GitHub 迁移入口：
https://github.com/chenfengyimei/mc-plan-foundation/tree/docs/MCP-F2-FOUNDATION-008-windows-migration

若未克隆，在 WSL 创建 ~/src/MC，克隆 Foundation 的 docs/MCP-F2-FOUNDATION-008-windows-migration 分支。完整阅读：
1. mc-plan-foundation/docs/windows-migration.md
2. mc-plan-foundation/memory/handoffs/2026-10-20-windows.md
3. mc-plan-foundation/migration/windows-20261020.json
4. mc-plan-foundation/.codex/skills/mc-plan-orchestrator/SKILL.md
5. mc-plan-foundation/.codex/skills/mc-plan-development/SKILL.md

用 scripts/restore-workspace.ps1 -WorkspaceRoot <实际MC根> -InstallSkills 恢复六仓和 Skill。已有目录冲突时保留现场，先审查，禁止 reset/clean/覆盖本地工作。Foundation 必须在迁移分支，Core/Ops 必须在现有活动分支。检查 Node >=24.15.0、仓库声明 pnpm@11.19.0、PowerShell 7、Git/gh、Docker Linux server 及 Playwright；私有仓库需要所有者登录，无法访问时准确报告，不伪造成功。按 frozen-lockfile 安装依赖，不借迁移升级依赖。

完整启动检查：宪法/系统架构、memory/current/direction.json、repositories.json、portfolio.md、全部 active 工作流；读取 Core/Ops 的完整 AGENTS、STATUS、development-plan、相关 ADR 与 alpha.10 契约；检查六仓 branch/HEAD/status/origin 和 Skill installer -Check。当前快照仍是 F2/Community，F4 管理台有界先行。

待接收工作流 MCP-F4-CORE-002，状态 handoff_required，当前保管 Owner Codex/windows-migration-20261020，原 Owner Codely/master-20261016-sdk-closeout。唯一主仓 mc-plan-core；唯一可写辅助 mc-plan-ops；Contracts/Foundation 是只读参考（仅该工作流协调记录按短事务协议更新）。Core 分支 feat/MCP-F4-CORE-002-admin-credit-adjustments，检查点 e7e83ca；Ops 分支 feat/MCP-F4-CORE-002-admin-write-realm，仍为 ef00a72；Contracts main b50f62a，Core 内容锁 alpha.10/a610464。以 manifest 的完整 SHA 和当前 Git 再核对。不得重复分配 ID 或自动释放 Core/Ops 锁。

已知 Core 有 5 文件未完实现被完整保存。类型检查、31 项契约测试和提交前 diff --check 已过；format:check 失败于 admin.controller.ts。新写面测试、Ops admin:write realm、两轮真实管理员验收和全量门禁尚未完成。迁移检查点不等于验收合格，不直接合 main。

若有同名私有传输包，先核 SHA256，再阅读 PRIVATE-README.md/inventory.json；保留 MC 输出中的历史证据、Skin data 和本地配置。包内 .env、Mac config、Codely 原始历史只在本地处理，不输出密钥、不进 Git。不要覆盖新机器 Codex 认证/会话数据库，不把历史路径当作执行目录。不把 Git bundle 当数据库备份。

先报告真实接收结果。环境可用且状态一致后，立即通过 Foundation 的短事务入口追加 from_owner/to_owner/at/reason、仓库检查点和剩余工作，记录你的实际会话 Owner，运行 Continue 预检，再续接既有 CORE-002。迁移授权已经给出，不要重复索要同样许可。遇到新进展、锁冲突或凭证缺失，保留现场并准确说明。

后续只完成既有 CORE-002 范围：审查和完善管理员积分调整/退款/幂等/三重授权/错误映射；修复格式，补新写面 HTTP 与真实 PostgreSQL 测试；Ops realm/admin:write 与 validate-dev-admin.ps1 真实正负例至少两轮；按 Core AGENTS 和 Ops 开发计划运行所有必需检查、真实容器与镜像验收。公共契约新增需求另走 Contracts-first，不临时发明；后续 SDK 暴露单独切片。最后记录真实结果、提交和关闭条件，遵守 main 审查规则，不绕过失败检查。

返回：实际工作区与执行环境、六仓分支/SHA、两个 Skill 检查、CORE-002 Owner/锁与交接记录、私有资料/运行时数据恢复范围、实际通过/失败/未运行命令、提交/推送状态、剩余阻塞和下一步。完整 F2/F3/F4/V1 未完成，不把迁移完成表述为项目完工。
```
