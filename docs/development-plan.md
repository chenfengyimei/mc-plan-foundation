# Foundation 开发计划

状态：Active

当前职责：MC Plan 治理、架构、组合状态、标准、ADR、模板和协作 Skill

## 固定顺序

1. 明确提案目标、所有权、成功标准和受影响仓库。
2. 检查宪法与现有 ADR；持久跨仓选择先新增 ADR。
3. 更新架构、标准、注册表、路线图或模板中的唯一真相。
4. 只有真实反复工作流才进入 Skill；确定性规则进入脚本。
5. 执行协调、链接、JSON、Skill、命名和跨仓一致性验证。

## 契约与辅助仓库

Foundation 不拥有产品接口。公共语义变化由 Foundation/ADR 先决定，再以 Contracts 为主仓库建立独立工作流。Foundation 治理任务通常没有辅助仓库；读取其他仓库不产生锁。

## 验收命令

```powershell
# 在 /Users/chenfeng/xm/MC/mc-plan-foundation 运行
pwsh -NoProfile -File scripts/validate-workspace.ps1 -WorkspaceRoot /Users/chenfeng/xm/MC
pwsh -NoProfile -File scripts/test-coordination.ps1
pwsh -NoProfile -File scripts/test-workspace-scanning.ps1
pwsh -NoProfile -File scripts/test-foundation-write.ps1
```

Skill 变更还必须运行官方 `quick_validate.py`、安装/版本漂移测试和行为用例静态检查。

## 2026-10-05 并行开发治理

工作流 `MCP-F1-FOUNDATION-008`（已关闭：final `9814ac0aed57e5c8614dc2b36da81db80a1d8d9a`，main ff-only 合并并推送，详见其 completed 记录），Owner `Codex/01a10c60-19a8-7c20-9f65-dbec5553ee4c`，仅写 Foundation；方向例外为所有者 00 提示授权的 `foundation-governance`，全局 F1/Core 不变。初始快照 Foundation `5320cb0`；注册前 Codely 已正常提交 CORE-005 登记/契约检查点，因此实际 base 为 `221d4852e0fe79f6c7ca4f82bc65e1341e06e88d`，登记提交 `89b708f530e245b5b5425a31b853935ccc9a866a`。不重复启动 Core，也不修改其记录。

第一次检查点尝试因短锁占用及他人协调记录修改被入口拒绝，未 stage 或提交他人内容。所有者随后要求继续；重新预检时 Foundation 为 `fda7b9484d24ac8297aae7291f61bc58f2af08b4`，index 干净、仅本会话治理路径待提交。期间 CORE-005/SDK 关闭与 Skin 正式交接均由其他会话提交，本分支保留这些提交；核实二者最终提交在业务仓 main 上、Finish 通过，不替 SDK 推送、不修改 Skin 记录。

复现使用独立 Git 夹具，无真实契约改动：

```powershell
git show 221d485:scripts/validate-workspace.ps1 > /private/tmp/mc-governance-baseline-01a10c60.ps1
pwsh -NoProfile -File scripts/test-workspace-scanning.ps1 `
  -ValidatorPath /private/tmp/mc-governance-baseline-01a10c60.ps1 -ReproduceBaseline
```

复现三项均符合预期：干净 exit 0，依赖重复 $id exit 1，依赖 YAML 缺失相对 $ref exit 1。修复后扫描库存按注册仓库/Git 规则生成；21 项隔离回归覆盖依赖、隐藏源、临时/忽略产物、真实 JSON/重复 ID/引用/Markdown 失败、受跟踪 `.codex`、协调 JSON、含空格路径及项目/工作区门槛。计数随真实文件变化，不作为测试断言。

短锁测试使用两个实际 PowerShell 子进程和受控进入/释放信号，验证失败立即返回、持有者证据、异常/native 失败释放、令牌不匹配保留、未完成证据/额外内容保留、共享 index/错误分支拒绝、治理 Owner/精确路径检查，以及只提交本 ID 记录的 helper。入口与调用协议见 [协调文档](coordination.md)，长期选择见 [ADR-0010](../decisions/0010-foundation-write-transactions.md)。

实际结果：首次工作区验收通过（6 个 active 仓库、111 Markdown、51 JSON），继续时已安装 SDK 的实际工作区再次通过（6 仓、111 Markdown、56 JSON）；协调回归 14/14、扫描回归 21/21、短锁/提交隔离回归 14/14 均通过（exit 0），Continue 通过。Markdown 数量变化来自按注册仓库扫描及新增 ADR；仓库外 CODELY/草案记忆不再计入，JSON 增量包含真实协调记录、alpha.4 契约与 SDK 文件，不使用固定数量作条件。最终提交和关闭证据保存在本工作流 completed 记录；Finish 在关闭事务中执行，随后本地 main ff-only 合并并正常 push。

本次不修改 Skill 内容；仅运行现有 Check 确认安装未漂移：

```powershell
pwsh -NoProfile -File .codex/skills/mc-plan-development/scripts/install.ps1 -Check
pwsh -NoProfile -File .codex/skills/mc-plan-orchestrator/scripts/install.ps1 -Check
pwsh -NoProfile -File scripts/validate-coordination.ps1 -WorkspaceRoot /Users/chenfeng/xm/MC -TrackingId MCP-F1-FOUNDATION-008 -Phase Start
pwsh -NoProfile -File scripts/validate-coordination.ps1 -WorkspaceRoot /Users/chenfeng/xm/MC -TrackingId MCP-F1-FOUNDATION-008 -Phase Continue
# 记录已提交并移入 completed、仓库干净后运行
pwsh -NoProfile -File scripts/validate-coordination.ps1 -WorkspaceRoot /Users/chenfeng/xm/MC -TrackingId MCP-F1-FOUNDATION-008 -Phase Finish
```

治理关闭后 A/B 可开始注册，C 等 A 关闭并释放 Contracts 锁后再注册；继续时 A/C 已由其他会话关闭，不重复登记；B 后续亦已注册为 `MCP-F1-OPS-001` 并关闭，不预留 ID。本任务不改变 Skin 当前 blocked/所有权/锁。短锁仅支持遵守入口的同 Mac 协调事务，不能声称任意并发写入安全；若会话不能使用入口，Foundation 注册/记录更新必须全部串行协调。

## 2026-10-05 残余治理叙述同步

工作流 `MCP-F1-FOUNDATION-010`，Owner `Codely/session-0-governance-sync`，仅写 Foundation（零辅助）；方向例外为所有者“核实完善与开发，按照你能做的以及当前目标，开始执行完成完善”指示授权的 `foundation-governance`，全局 F1/Core 不变。Base `69b5576bb232eedd25c38b7c34a2d70730de69af`。本切片完成 `MCP-F1-FOUNDATION-009` 明确范围外的余项：[协调文档](coordination.md) 本包注册顺序段与开发计划 008 段遗留的 B 状态句补记为 B=`MCP-F1-OPS-001` 已注册并关闭的完成事实（保留历史，不改协议）；`memory/current/portfolio.md` 与 `docs/STATUS.md` 的记录现状段对齐 30 个 completed、当前活动清单、Contracts 已获授权推送与 CORE-006 关闭（outbox 发布器，无传输绑定）事实。运行本开发计划声明的四条验收命令与 Start/Continue/Finish；无远端推送授权，本地 ff-only 合并 main 后推送状态如实记录。

## 完成条件

- 长期决策、组合状态、接口和单仓状态分别写入正确真相源。
- 机器记录可解析，活动锁无冲突，链接和仓库地图一致。
- 没有业务源码、秘密、生产值或重复 Skill 副本。

## 不得提前实现

Foundation 不初始化 Next.js、NestJS、Prisma、SDK 或生产部署，不替业务仓库决定未获得证据的字段和厂商。
