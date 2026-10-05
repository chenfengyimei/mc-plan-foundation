# ADR-0010：同一 Mac 的 Foundation 协调写入使用短事务锁

状态：Accepted
日期：2026-10-05

## 背景

ADR-0007 允许业务锁不重叠的会话写各自 Foundation 协调记录，但同一 Mac 的会话共享 Foundation 工作树、分支和 Git index。仅靠业务仓库锁无法避免 ID 分配、记录更新、提交或同步相互穿插。项目所有者在 00 治理任务中明确授权先验证共享写入协议，再开放后续注册。

## 决策

同一工作区所有 Foundation 写入及相关 Git 操作由 [短锁入口](../scripts/invoke-foundation-write.ps1) 包围。工作区根的 `.mc-plan-foundation-write.lock` 通过原子 `mkdir` 获取，`holder.json` 保存会话、任务、UTC 时间、事务说明和随机令牌。只有获取者令牌匹配才能在 `finally` 释放；竞争失败立即返回，不等待、不自动过期、不根据 PID/时长强占。

普通业务会话只在干净 Foundation `main` 上更新自己的 active/completed 记录，并使用 `Submit-FoundationRecord` 校验精确路径后提交。同步、重新读取记录与分配 ID、更新、提交、正常 push 都在同一次短事务内。Foundation 作为主/辅助业务仓库时仍独占其仓库锁；普通协调事务被入口拒绝，治理持有者可显式声明自己的分支及精确修改路径。

业务实现、安装、构建和长测试在短事务之外进行。工作区验收的项目输入以已注册 active 仓库的 Git 跟踪文件及非忽略未跟踪文件为准，Markdown、Foundation/Contracts JSON 和 Contracts 引用共用库存；安装与验证产物不成为契约，真实源校验不放宽。具体过滤与恢复步骤见 [协调协议](../docs/coordination.md)。

## 后果

不同业务仓库可并行实现，Foundation 的协调操作串行提交。该协议依赖所有写入者使用同一入口；它不保护绕过入口的 Git 命令，也不提供跨机器或任意并发编辑保证。进程被强杀可能留下锁，必须由原持有者核实完整证据并显式恢复，其他会话返回协调，不删除他人的锁。

## 变更条件

跨机器共享 checkout、独立 Foundation worktree/index 或持续的集中协调服务需要另立 ADR；不得用自动过期或 force push 绕过现协议。
