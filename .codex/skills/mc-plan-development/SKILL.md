---
name: mc-plan-development
description: Plan, implement, review, or hand off work in an MC Plan repository while enforcing one primary repository, bounded supporting repositories, repository locks, contract ordering, validation, and current project records. Use for mc-plan-foundation, mc-plan-contracts, mc-plan-core, mc-plan-community, mc-plan-skin, mc-plan-ops, and future registered MC Plan projects; do not use for unrelated Minecraft work.
metadata:
  short-description: Coordinate focused MC Plan development
---

# MC Plan Development

Keep every change focused, independently deliverable, contract-compatible, and recoverable by another session.

## Discover

1. Locate `mc-plan-foundation` and compare this installed Skill with its authoritative copy by running the canonical `scripts/install.ps1 -Check`. For a write task, stop if the copy is missing or stale.
2. Read Foundation's constitution, current direction, repository registry, active workstreams, and the complete `AGENTS.md` of every repository the task may write.
3. Read [repository-map.md](references/repository-map.md) when ownership is unclear. Read only the relevant architecture, ADR, standard, status, and contract documents.

Read-only explanation or diagnosis does not need a lock. Before any edit, branch, commit, code generation, migration, or state-changing command, follow [focus-and-workstreams.md](references/focus-and-workstreams.md).

## Work

- Use exactly one primary repository and no more than two writable supporting repositories. Other repositories are read-only references.
- Never edit a repository outside the active record. Expand and revalidate the record before changing scope.
- Keep data and behavior in the owning service. Never import another repository's source, query its database, or copy public contract types.
- For a public API, Schema, event, scope, SDK, visibility, or retention change, follow [contract-changes.md](references/contract-changes.md) before implementation.
- Preserve unrelated user work. Never put secrets, tokens, production values, personal data, or AI prompts in Git or logs.

## Finish

Run the repository's declared checks and the coordination validator. Record only checks that actually passed.

Read [workflow-and-handoff.md](references/workflow-and-handoff.md) for cross-repository ordering, incomplete work, takeover, or completion. Update the correct truth source: Contracts for public interfaces, ADRs for durable choices, repository status for local milestones, Foundation portfolio for portfolio milestones, and the workstream record for scope, commits, validation, blockers, and handoff.

Do not claim completion while required implementation, verification, record closure, or lock release remains.
