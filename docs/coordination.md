# 多仓协调模型

状态：Accepted

适用范围：MC Plan 工作区、开发会话和新项目准入

## 真相分层

| 记录 | 真相内容 | 不记录 |
|---|---|---|
| `memory/current/repositories.json` | 已知项目、路径、类型、可见性和生命周期 | 任务进展、接口字段 |
| `memory/current/direction.json` | 当前全局里程碑、主要项目、入口和退出门槛、受限准备项目 | 单次任务细节 |
| `memory/workstreams/` | 会话主方向、锁、提交、验证、阻塞和交接 | 长期产品决策 |
| `memory/current/portfolio.md` | 跨仓里程碑摘要 | 每次提交和审查讨论 |
| 各仓 `docs/STATUS.md` | 单仓里程碑状态 | 其他仓实现状态 |

公共接口仍以 Contracts 为准，长期跨仓决策仍以 ADR 为准。

`mc-plan-orchestrator` 负责在主会话中读取实时状态、生成派工提示词、核对完成报告、安排不冲突的会话和规划后续工作；`mc-plan-development` 负责单个写工作流内部的开始、实施、验证、交接和关闭。前者默认只读，不能因为“主会话”身份自动接管、解锁或修改仓库；后者不能脱离已声明的主方向和仓库锁。

无法自动发现仓库 Skill 的开发工具，必须读取 Foundation 中这两个 Skill 的权威 `SKILL.md`，并把它们作为本地操作协议。优先让主会话根据实时状态生成提示词；`templates/session-start-prompt.md` 只作为通用后备模板。开局提示词可以保存项目所有者明确给出的授权，但不能覆盖机器可读的当前方向、活动锁或仓库边界。

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

## 同一 Mac 的 Foundation 短事务

[ADR-0010](../decisions/0010-foundation-write-transactions.md) 补充 ADR-0007 的共享工作树/index 约束，不改变业务仓库锁、方向或所有权。协议适用于同一工作区的所有 Foundation 写入者，入口为 [invoke-foundation-write.ps1](../scripts/invoke-foundation-write.ps1)。它支持本机 Mac/Unix PowerShell 7；不是跨机器锁，也不保证绕过入口的命令安全。

必须在同一个短临界区内完成 Foundation 的记录创建、ID 分配、更新/移到 completed、`git add/commit`、`fetch`/ff-only 同步和正常 `push`。业务实现、依赖安装、构建、长测试和业务仓库 Git 操作不持有此锁。普通会话只写自己的 `memory/workstreams/active/<ID>.json` 与 `completed/<ID>.json`；不能顺手改 portfolio、direction、STATUS 或其他记录，也不能把 Foundation 切到自己的业务分支。

### 获取、持有与释放

1. 入口用 `/bin/mkdir -m 700` 原子获取工作区根 `.mc-plan-foundation-write.lock`。锁在六仓之外，不提交 Git。`.NET Directory.CreateDirectory` 会复用已有目录，不能代替独占获取。
2. `holder.json` 以 CreateNew 写入并刷盘，包含 session、tracking_id（未分配时可用任务名）、acquired_at、transaction、随机 token 和仅供诊断的 pid。获取失败立即报告已有持有者并结束本次尝试，不进入回调、不释放他人锁、不轮询重试；证据尚未写好也视为被占用。
3. 进入后重新检查 Foundation 分支/index/工作树和活动锁。普通事务必须从干净 `main` 开始且没有 Foundation 业务锁。随后在回调内同步 origin，重新读取 active/completed/方向/注册表，核对重复任务和业务锁后才分配 ID。预检快照不能替代事务内检查。
4. 只有成功获取并且 finally 时 token 仍一致的持有者才释放锁。异常/native command 非零退出也会执行 finally。缺失/损坏证据、token 改变或出现额外文件时保留锁和证据并失败；不递归删除，不按时间或 PID 推断归属。强杀进程可能跳过 finally：原持有者核实会话、令牌、Git 状态和事务后显式恢复，其他会话交回协调，入口无解锁/抢占参数。
5. `Submit-FoundationRecord` 检查所有未提交与已 staged 路径只属于本 ID，检查记录 ID/owner 匹配 Session，才精确 stage 并 commit。出现他人修改或 index 内容就保留并返回；禁止 `git add -A`、自动 stash/reset、代替他人提交。回调成功结束还必须保持干净；原生 Git 失败会中止，不会继续推送。

Git push 冲突时保留自己的提交和错误/持有者证据，正常 finally 释放自己持有的锁。后续重试是一项新的协调事务：先核实远端，再仅在可以 ff-only 前进时继续。禁止 force push、覆盖记录、破坏性 reset 或改写他人提交。

### 完整调用用法

事务脚本保存在本会话专属临时目录，接收 `param($Context)`。Session 使用协调记录中的真实 owner；新会话宜以工具和唯一会话标识组成 Owner。以下例子更新已启动会话自己的时间和协调证据，ID 必须替换为实际分配值；更新范围/检查点/完成状态也在这个脚本内执行。不要把业务实现或长验收放入此脚本。

```powershell
# /private/tmp/<本会话目录>/update-record.ps1
param($Context)
$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true
$f = $Context.FoundationPath
git -C $f fetch origin
git -C $f merge --ff-only origin/main
# 同步后重新读取全部 active/completed、direction 与 repositories，
# 确认自己的 Owner、锁和目标；初次注册在这里检查重复任务并分配下一个未用 ID。
& (Join-Path $f 'scripts/validate-coordination.ps1') -WorkspaceRoot $Context.WorkspaceRoot
$path = Join-Path $f $Context.ActiveRecordPath
$record = Get-Content -LiteralPath $path -Raw | ConvertFrom-Json -Depth 100
if ($record.owner -cne $Context.Session) { throw 'Owner mismatch; return to coordination.' }
$record.updated_at = [DateTimeOffset]::UtcNow.ToString('o')
$record | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $path -Encoding utf8NoBOM
& (Join-Path $f 'scripts/validate-coordination.ps1') `
  -WorkspaceRoot $Context.WorkspaceRoot -TrackingId $Context.TrackingId -Phase Continue
Submit-FoundationRecord -Context $Context -Message "docs(coordination): update $($Context.TrackingId)"
git -C $f push origin main
```

```powershell
pwsh -NoProfile -File /Users/chenfeng/xm/MC/mc-plan-foundation/scripts/invoke-foundation-write.ps1 `
  -WorkspaceRoot /Users/chenfeng/xm/MC `
  -Session '<记录中的 Owner/唯一会话标识>' `
  -TrackingId '<已分配 ID；初次注册可先写任务名>' `
  -Transaction '同步、核对并更新本会话协调记录、提交和推送' `
  -TransactionScript '/private/tmp/<本会话目录>/update-record.ps1'
```

入口也支持同一 PowerShell 进程中的 `-Action { param($Context) ... }`，与 `-TransactionScript` 二选一。Context 包含 WorkspaceRoot、FoundationPath、Session、TrackingId、ActiveRecordPath 和 CompletedRecordPath。初次注册可在回调中分配 ID，再调用 `Submit-FoundationRecord -Context $Context -TrackingId $allocatedId -Message ...`；不要在锁外预占 ID。Start 先提交记录，再创建声明的业务分支并验证；工作检查点用 Continue；结束先写 final_commit/真实验证并移到 completed、精确提交，再运行 Finish。

Foundation 自身的主/辅助工作流仍持有独占业务锁。其持有者可加 `-GovernanceBranch '<记录声明的 Foundation 分支>' -GovernancePaths @('<本会话精确修改路径>', ...)`，只允许与当前 Owner/Tracking ID/分支匹配的单一 Foundation 持有者。它用精确 `git add -- <paths>` 提交自己的治理修改；任何未声明脏路径都会拒绝。普通会话不得使用此例外。治理关闭前，其他会话暂停 Foundation 写入；关闭、Finish、main ff-only 合并和 origin 推送后，普通入口才可使用。

### 本包注册顺序

00 治理先串行完成。之后 A（Core+Contracts 积分账本）与 B（Ops 固定 alpha.3 联调）可开始注册；建议 A 成功注册后 B 再注册。它们的协调事务必须串行，业务锁不重叠时实现可以并行。C（Contracts SDK）必须等 A 关闭并释放 Contracts 锁后再注册。每次都检查最新活动记录，已有同目标记录时由原 Owner 继续，不能再分配重复 ID；不预留 A/B/C ID。

本次执行期间其他会话提前注册并关闭了 A（`MCP-F1-CORE-005`）与 C（`MCP-F1-CONTRACTS-001`）；治理恢复时已核实二者 completed 记录、最终提交在各自 main 上及 Finish 通过。保留这些协调提交，不重复注册，也不据此允许绕过 00 的 Foundation 独占门槛。B 仍待启动。Skin 的 `MCP-F1-SKIN-008` 已由其他会话按所有者授权正式交接至 `Codely/8b150da7-6a4c-4e53-a769-422c79c12963`；本治理任务不修改该记录，blocked 状态、分支、检查点与锁保持当前记录，仍等待明确的视觉验收/Provider 决策。

## 工作区项目文件扫描

[工作区验收](../scripts/validate-workspace.ps1) 的三个扫描面共用 [Git 文件库存](../scripts/get-project-files.ps1)：只读取注册为 active 的项目；取 `git ls-files -z --cached` 加 `--others --exclude-standard`，保留路径含空格、受版本控制但被忽略的 `.codex` 指南、真实契约/协调 JSON 和未忽略的待提交源码。已删除的文件不作当前输入，Git 读取失败不能降级为无过滤递归。

`.git`、`node_modules`、`.validation` 永远排除。未跟踪的 `dist`、`coverage`、`.next`、`.turbo`、`.pnpm-store`、`.cache`、`__pycache__`、`.pytest_cache`、`.venv` 也排除；这些常见输出目录下已跟踪的源文件仍检查，其余安装/编译缓存遵循仓库 Git 忽略规则。新缓存应声明在所属仓库的 ignore 规则中，不通过放宽 JSON/$id/$ref/链接校验处理。

Markdown 检查覆盖所有 active 仓库，JSON 解析/$id 检查继续覆盖 Foundation 与 Contracts，契约本地引用继续覆盖 Contracts JSON/YAML。工作区根不是 Git 仓库、项目准入、Skill 文件要求及协调校验保持有效。仓库外的本地规划与测试夹具不属于项目库存；六仓文件数量随真实输入变化，不是验收阈值。

隔离验收入口：`pwsh -NoProfile -File scripts/test-workspace-scanning.ps1` 与 `pwsh -NoProfile -File scripts/test-foundation-write.ps1`。它们使用各自唯一、含空格的系统临时目录；扫描夹具不修改真实契约，双写入者测试不获取真实工作区锁。

## 新项目

新项目先以 `proposed` 登记，不要求目录存在。ADR 接受后进入 `approved` 并创建独立仓库；README、AGENTS、LICENSE、状态页、开发计划和验收命令全部存在后才能改为 `active` 并成为工作流主仓库。
