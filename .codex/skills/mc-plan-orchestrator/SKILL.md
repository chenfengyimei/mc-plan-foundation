---
name: mc-plan-orchestrator
description: Orchestrate MC Plan work across conversations and tools by reading current Foundation and Git evidence, reconciling progress, generating complete dispatch prompts from short goals, recovering incomplete work, and planning safe next workstreams. Use when the user asks what to develop next, wants a prompt for Codex, ChatGPT Work, Codely/GLM, or another agent, wants to coordinate or monitor MC Plan sessions, or needs a portfolio-level status or recovery plan. Do not use for unrelated projects or as a substitute for mc-plan-development inside an implementation workstream.
metadata:
  short-description: Orchestrate MC Plan sessions and prompts
---

# MC Plan Orchestrator

Act as the MC Plan main-session coordinator. Ground every recommendation in current files and Git state, not conversation memory or another agent's prose report.

## Separate orchestration from implementation

- Use this Skill for portfolio status, task slicing, dispatch prompts, cross-session sequencing, monitoring, recovery, and next-step planning.
- Use `$mc-plan-development` for any repository write, implementation, review that changes files, workstream creation, handoff, or closure.
- Prompt generation and status inspection are read-only. Do not create a workstream merely to answer or draft a prompt.
- Never treat “main agent” as blanket authority. Creating threads, sending messages, taking over a workstream, pushing, deploying, or changing external state still requires the user's direct authorization.

## Refresh live truth

Before producing a current status, recovery decision, roadmap, or dispatch prompt:

1. Locate `mc-plan-foundation`. Read its current direction, repository registry, portfolio, and every active workstream.
2. Run the canonical installer `scripts/install.ps1 -Check` for this Skill when available. For a write task, stop and synchronize a stale user-level copy before proceeding.
3. Inspect branch, HEAD, worktree status, and remotes for every repository relevant to the request. Preserve unrelated changes.
4. Read the target repository's complete `AGENTS.md`, `docs/STATUS.md`, and `docs/development-plan.md`, plus relevant ADRs, contracts, and completed workstream records.
5. If a report from another session names commits or validations, verify the commits exist and compare the report with Git and the active record. Treat unverified prose as a lead, not truth.

Read [progress-and-recovery.md](references/progress-and-recovery.md) when work is active, blocked, dirty, handed off, or claimed complete. Read [portfolio-planning.md](references/portfolio-planning.md) when selecting the next task or coordinating multiple sessions.

## Turn a short brief into a dispatch

Accept minimal input such as:

```text
目标：继续 Skin Standalone 最小链路
工具/模型：Codely / GLM-5.3
限制：只做本地提交
```

Infer safe details from live truth. Ask at most one question only when a missing choice would materially change product scope, legal/privacy posture, cost, external accounts, or repository ownership. Otherwise choose the smallest valid workstream and state the assumption.

Read [dispatch-prompts.md](references/dispatch-prompts.md). Generate one copyable prompt that includes current evidence, exact Skill locations, required reading, authority actually granted by the user, the primary/support/reference repositories, lock and branch rules, scope and exclusions, contract order, concrete implementation outcome, validation, finish/merge/cleanup behavior, and stop conditions. Do not copy a stale static prompt without reconciling it to current state.

For an agent outside Codex, point it to both authoritative Skill files under Foundation and tell it to follow them as local operating protocols. Do not claim that Codely, GLM, or another tool supports Codex-only capabilities.

## Coordinate safely

- Prefer finishing or correctly handing off nearly complete work before opening a competing workflow.
- Allow parallel work only when writable repository sets do not overlap and direction rules permit it. Read-only references never consume locks.
- An active lock never expires automatically. Choose among waiting, a recorded handoff, or an explicitly authorized takeover.
- Never assign one Tracking ID to two live conversations. Identify one owner session for each writable workstream.
- If a public contract must change, sequence Contracts, producer, SDK, consumer, then Ops. Split stages into dependent workstreams rather than holding many locks.
- Future modules enter through the Foundation proposal and ADR process before a top-level repository becomes active.

When Codex thread tools are available, read or wait on relevant threads for status. Create, fork, hand off, archive, or send messages only when the user directly authorizes that action. External sessions are coordinated through copyable prompts and committed Foundation records.

## Report and hand off

Return these sections unless the user asks for a narrower answer:

1. `当前事实` — global direction, active workstreams, locks, relevant Git state, and confidence.
2. `统筹判断` — what is complete, incomplete, stale, blocked, or safe to run in parallel.
3. `建议顺序` — one owner and one primary repository per next workstream, with dependencies.
4. `可复制提示词` — one prompt tailored to the chosen agent and goal.
5. `回收条件` — what evidence the other session must return and how the main session should verify it.

Clearly distinguish implementation complete, validations passed, workstream closed, local-main integrated, and product milestone complete. Never collapse them into a single “done.” If the user asks this main session to execute the plan, switch to `$mc-plan-development`, create or take over a valid workstream, and persist progress in Foundation rather than only in chat.
