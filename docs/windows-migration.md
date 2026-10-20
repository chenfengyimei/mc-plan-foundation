# MC Plan：迁移到 Windows Codex

整理日期：2026-10-20（Asia/Shanghai）。迁移工作流：`MCP-F2-FOUNDATION-008`。

迁移入口是本文件、[机器可读快照](../migration/windows-20261020.json)、[具体交接](../memory/handoffs/2026-10-20-windows.md)和[可复制提示词](../templates/windows-codex-handoff-prompt.md)。这些文件替代对旧聊天上下文的依赖；每次接手仍须核对实时 Git 和活动记录。

## 1. 选择 Windows + WSL2

当前 `scripts/invoke-foundation-write.ps1` 在 `$IsWindows` 为真时直接拒绝运行，使用 `/bin/mkdir` 做原子短锁。Skin 的 `test:e2e:image` 也使用 POSIX 环境变量语法。因此本次采用 **Windows 桌面 Codex，代理执行环境为 WSL2**；仓库放在 Linux 文件系统，例如 `~/src/MC`，保留 Linux 的文件权限、符号链接和脚本行为。此次没有修改锁协议或宣称支持原生 Windows 写工作流。

OpenAI 官方说明：在应用设置中将 agent environment 从 Windows native 切到 WSL，然后重启应用；集成终端独立配置为 WSL。仅切换终端不改变代理环境。通过 `\\wsl$\` 选择发行版中的项目目录。见[Windows/WSL 官方说明](https://learn.chatgpt.com/docs/windows/windows-app)。

Windows 原生只用于安装基础软件、登录和打开应用；业务命令、`git`、`pnpm`、`pwsh`、Skill 版本检查以及 Foundation 事务统一在 WSL 执行。Windows 和 WSL 的工具安装与登录状态分别核对。

## 2. 新机器准备

1. 已有 Codex 可直接登录原账号。Windows PowerShell 中运行 `wsl --status`，没有 WSL2 时安装，例如 `wsl --install -d Ubuntu`，按系统要求重启；这一步可能需要管理员权限。
2. Docker Desktop 使用 Linux containers，开启目标 WSL2 发行版集成。保留 Mac 上的卷，不运行 `down -v` 或卷清理。
3. 在 WSL 中安装 Git、GitHub CLI、Python 3、ripgrep、PowerShell 7、Node.js 和 pnpm。按各工具官方安装说明操作，先查看现有版本，不重复覆盖已有配置。
4. 项目 `package.json` 的 Node 要求是 `>=24.15.0`，`packageManager` 锁定 `pnpm@11.19.0`。Mac 实际观察为 Node `24.22.0`、外层 pnpm `12.9.1`、PowerShell `7.6.6`、Docker `29.8.1`；重建优先遵循仓库声明，外层工具版本不代替锁文件要求。
5. WSL 运行 `gh auth login`，采用浏览器登录；再运行 `gh auth setup-git`。确认账号可读 Core/Community/Ops 私有仓库。Git 作者信息使用所有者自己的名称和邮箱。
6. 运行 `node --version`、`pnpm --version`、`pwsh -NoProfile -Command '$PSVersionTable.PSVersion'`、`git --version`、`gh auth status`、`docker version`。Docker 必须能访问 server，不能仅有 client。

本次不复制 Mac 的 Homebrew 路径、Darwin 二进制、node_modules、Prisma 生成物、浏览器缓存和容器运行状态。

## 3. 从 GitHub 恢复

在 WSL 的 Bash 中执行：

```bash
mkdir -p ~/src/MC
cd ~/src/MC
git clone --branch docs/MCP-F2-FOUNDATION-008-windows-migration https://github.com/chenfengyimei/mc-plan-foundation.git
pwsh -NoProfile -File ./mc-plan-foundation/scripts/restore-workspace.ps1 -WorkspaceRoot "$PWD" -InstallSkills
```

Foundation **必须先克隆上述迁移分支**，迁移资料与尚未进入远端 main 的协调提交在该分支。Core 和 Ops 也恢复活动分支，不把 Core 的未完成实现合入 main。脚本从快照读取六仓 URL、分支和检查点，已有目录发生远端/分支/提交/脏树冲突时停止并保留现场；不执行 reset、clean、stash、覆盖或自动切换已有工作树。Foundation 允许迁移分支包含登记检查点之后的文档提交，其余仓库要求提交精确一致。远端后续有新工作时，差异必须由接手者先审查。

`-InstallSkills` 用权威安装器安装两个 MC Skill，并保留旧版备份。Linux 下还创建 `~/.agents/skills` 指向实际安装目录的符号链接，兼容当前官方发现路径；已有不同内容时不覆盖。官方发现规则见[Build skills](https://learn.chatgpt.com/docs/build-skills)。安装器尊重 `CODEX_HOME`；不得为了迁移随意改写该变量。重启 Codex 或新建会话后检查 Skill 可见性；即使未自动发现，也能直接阅读 Foundation 中的两个权威 `SKILL.md`。

## 4. 依赖与基础验证

先按各仓 README、AGENTS、开发计划检查环境示例，使用已锁定的 pnpm 安装，不更新依赖或锁文件：

```bash
cd ~/src/MC/mc-plan-core && pnpm install --frozen-lockfile
cd ~/src/MC/mc-plan-core/apps/admin && pnpm exec playwright install chromium
cd ~/src/MC/mc-plan-community && pnpm install --frozen-lockfile
cd ~/src/MC/mc-plan-community && pnpm exec playwright install chromium
cd ~/src/MC/mc-plan-skin && pnpm install --frozen-lockfile
cd ~/src/MC/mc-plan-skin && pnpm exec playwright install chromium
cd ~/src/MC/mc-plan-contracts/sdk/typescript && pnpm install --frozen-lockfile
cd ~/src/MC/mc-plan-contracts/sdk/community && pnpm install --frozen-lockfile
cd ~/src/MC/mc-plan-contracts/sdk/skin && pnpm install --frozen-lockfile
cd ~/src/MC
pwsh -NoProfile -File ./mc-plan-foundation/scripts/validate-coordination.ps1
pwsh -NoProfile -File ./mc-plan-foundation/scripts/validate-workspace.ps1
```

Playwright Linux 运行库不足时依官方提示安装目标系统依赖。Contracts Python 验证依赖以该仓 README/requirements 为准。依赖安装不意味着任何产品里程碑完成。

必须在接手后的正式工作流内重新执行当前仓声明的全套门禁。Core 迁移检查点已知格式检查失败，不能要求快照全绿才允许保存。还需真实 PostgreSQL/Keycloak、Ops 两轮管理员验收和相应镜像验证；具体见交接记录。

## 5. Git 以外的资料

本次在 Mac 工作区同级制作本地私有传输包 `MC-private-transfer-20261020.tar.gz`，旁边放 SHA256 校验文件。该包含可能敏感的本地配置及历史，只能用可信的私有渠道搬运，不能上传公开仓库。包内 `PRIVATE-README.md` 和 `inventory.json` 列出范围与恢复步骤。

| 内容 | 迁移方式 | 接收后处理 |
|---|---|---|
| 六仓提交、分支、文档、权威 MC Skills | GitHub；另附六个 Git bundle | 先核对清单；无网时 bundle 可克隆 |
| MC 相关 `.codex/outputs/mc*`（旧提示词、证据、草稿） | 私有传输包 `codex-outputs/` | 参考资料，旧提示词不直接当最新派工 |
| MC Codex 原始 JSONL 会话（5 文件，34.3 MiB 快照） | 私有包 `codex-sessions/` | 仅供查阅，不保证可导入新客户端 |
| 工作区 `CODELY.md`、`.codely-cli` | 私有传输包 `workspace-local/` | 原始历史仅供查阅，不覆盖当前规则 |
| Skin `data/`、worker `.env`，被忽略的局部代理说明 | 私有传输包 `repository-local/` | 人工核对后复制到对应仓；密钥不进 Git、不显示 |
| Mac Codex `config.toml` | 私有包 `codex-reference/config.mac.toml` | 仅作人工参考，不能整份覆盖 Windows/WSL 配置 |
| Codex auth、SQLite、浏览器登录、SSH 私钥 | 不打包 | 新机器重新登录，服务密钥通过原私有渠道配置 |
| node_modules、dist、`.next`、生成物、Playwright 浏览器 | 不打包 | 在 WSL 按锁文件重建 |
| Core/Keycloak 开发库及旧 mc-c010 测试库（3 个停止容器的卷） | 私有包 `docker/`：冷快照和逻辑 SQL dump | 逻辑导出从独立副本运行，三份均已在全新隔离数据库验证恢复；原卷未启动/修改 |
| Docker 镜像、其余无归属匿名卷、外部 S3 | 不在文件包中，镜像清单在包内 | 按各仓 Dockerfile/runbook 重建；Mac 原件保留到接收验收 |

Git bundle 包含本地 refs 的快照。额外保存的三份数据库备份均完成本机全新隔离集群恢复（`psql -X -v ON_ERROR_STOP=1`），清单见私有包 `docker/database-inventory.json`。未复制 Docker VM 原始磁盘，未验证 Windows/x64 上的恢复；跨机器优先使用逻辑 SQL，而不是直接装载冷卷。全部原始数据库容器保持停止，临时验证容器/卷已清理。

旧验证日志中有 `/Users/...` 历史路径。它们是证据出处，不是新机器执行路径；新会话必须发现自己的根目录。重建索引、任务侧栏和聊天记录不是 Git 的作用，本次用可追溯文件和提示词交接工作状态。

Windows 桌面与 WSL CLI 默认使用不同的 Codex home；官方[说明](https://learn.chatgpt.com/docs/windows/windows-app)提供 `CODEX_HOME` 共享方案。本次建议先让新机器自行登录，核对实际 home 后安装 Skill，不共享 Mac 的认证文件。配置层级见[Config basics](https://learn.chatgpt.com/docs/config-file/config-basic)。

## 6. 验收后再切换主工作机

- 六仓分支、SHA、origin 与清单一致或有经审查的新进展；私有包 SHA256 一致且所需本地文件已恢复。
- 代理实际运行在 WSL2，两个 MC Skill 版本检查通过，协调和工作区验证通过。
- Windows 接收会话按 Foundation 短事务协议追加 `MCP-F4-CORE-002` 的 Owner 交接记录，保留 Core/Ops 锁；迁移记录关闭不关闭产品工作流。
- 新机器完成所需 Docker/DB/Keycloak/浏览器基础验证，记录通过、失败和未运行项。
- 在确认运行时数据不再需要前，保留 Mac 工作区、Docker 卷和私有包。继续开发顺序见[交接](../memory/handoffs/2026-10-20-windows.md)。
