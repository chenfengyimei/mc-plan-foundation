# Dispatch prompt protocol

Use this protocol to expand a short owner brief into one current, executable prompt. The generated prompt is a snapshot plus a mandatory instruction to reread live state; it is never a replacement for Foundation.

## Inputs

Extract or infer:

- objective and desired outcome;
- target tool and model, if the user cares;
- implementation, review, recovery, monitoring, or planning intent;
- local-only, remote, deployment, cost, time, or quality constraints;
- direct authorizations already granted by the user.

Do not invent authorization. “Generate a prompt” authorizes drafting, not sending it, creating a thread, taking over a lock, pushing, or deploying.

## Select the dispatch type

| Situation | Prompt type |
|---|---|
| No conflicting workstream and goal fits direction | Start a bounded implementation workstream |
| Same goal already has an owner and active lock | Continue in the owner session or wait; do not start a duplicate |
| Prior session stopped and the user authorized transfer | Inspect and record handoff/takeover before editing |
| Repository is dirty without a valid lock | Recovery and evidence collection; no edits until ownership is resolved |
| Implementation and validation are done but record is open | Close and integrate the existing workstream, not a new implementation |
| Goal needs a public contract change | Contracts-first sequence with dependent follow-up prompts |
| Goal is a future module | Foundation proposal and ADR prompt before repository creation |
| User only wants status or planning | Read-only audit prompt; no branch or workstream |

## Required prompt blocks

Every implementation or recovery prompt must contain:

1. **Role and outcome** — one concrete result, not “improve the project.”
2. **Workspace** — actual root and repository paths.
3. **Authoritative Skills** — absolute paths to:
   - `mc-plan-foundation/.codex/skills/mc-plan-orchestrator/SKILL.md` for coordination context when relevant;
   - `mc-plan-foundation/.codex/skills/mc-plan-development/SKILL.md` for writes.
4. **Live startup check** — direction, registry, every active record, target AGENTS/STATUS/development plan, relevant Git branch/HEAD/worktree/remotes.
5. **Current snapshot** — observed milestone, active locks, target branch/commit, and any existing Tracking ID. Label it as a snapshot that must be verified.
6. **Authority** — quote or accurately paraphrase what the owner authorized. State actions that remain unauthorized.
7. **Repository roles** — exactly one primary, at most two writable supports, and explicit read-only references.
8. **Scope and exclusions** — implementation-sized items and non-goals.
9. **Contract impact** — none, read-only, or a Contracts-first dependency. Never ask an implementer to invent public fields.
10. **Execution behavior** — report startup facts, then proceed without asking for redundant permission when the stated gates are satisfied.
11. **Verification** — repository-declared commands plus coordination Start/Continue/Finish for writes.
12. **Finish behavior** — small local commits, checkpoint hashes, close/move the record, local-main integration only when authorized and clean, branch cleanup rules, no remote push by default.
13. **Stop conditions** — lock conflict, stale Skill, unknown repository, undeclared dirty work, material product/legal/cost decision, missing external credential, or failed evidence that cannot be repaired in scope.
14. **Return packet** — Tracking ID, commits, validations, changed files/behavior, remaining blockers, record location, merge status, and next safe action.

## Tool adaptations

### Codex desktop or ChatGPT Work with local executor

- State that installed Skills may be used, but Foundation is authoritative.
- If thread tools exist, they may inspect or wait read-only. Messaging, creating, forking, handing off, or archiving needs direct user authorization.
- Use clickable paths only in the response back to the user; the dispatched agent can use filesystem paths.

### Codely with GLM or another local coding agent

- Tell it to open the two Foundation `SKILL.md` files directly even if it has no Skill registry.
- Express commands and file paths explicitly. Do not require Codex-specific thread tools, writing blocks, or UI directives.
- Require it to commit checkpoints and update the Foundation workstream so another tool can verify the result.

### Agent without local filesystem access

- It cannot implement or assert current status. Limit the prompt to analysis based on supplied files, or ask the owner to use an agent with local Git/filesystem access.

## Prompt skeleton

```text
你正在执行 MC Plan 的一个有边界工作流。目标是：<outcome>。

工作区与权威协议：
- 根目录：<absolute-root>
- 先完整读取：<orchestrator-skill-path>（统筹背景）
- 写操作必须完整读取并执行：<development-skill-path>

已核对快照（仍须在本会话重新验证）：<direction, locks, target git state>。

项目所有者授权：<actual authorization>。
未授权：<push/deploy/takeover/etc>。

主仓库：<one>
可写辅助：<zero-to-two>
只读参考：<list>
既有 Tracking ID：<id-or-none>

范围：<bounded items>
排除：<explicit non-goals>
契约影响与顺序：<classification>

先执行只读启动检查并报告；若状态与快照一致且不存在停止条件，立即继续合法的现有工作流或创建获准的新工作流，不要再次索要已经明确授予的许可。完成真实实现、验证、记录、提交和关闭；不要用报告或占位骨架代替结果。

验收：<commands and observable evidence>
停止条件：<specific blockers>
完成后返回：<return packet>。
```

Use the target repository's actual development plan to replace every placeholder. The final prompt must be usable without relying on the current chat history.
