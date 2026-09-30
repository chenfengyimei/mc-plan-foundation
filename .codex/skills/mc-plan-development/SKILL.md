---
name: mc-plan-development
description: Plan, implement, review, or hand off changes across MC Plan repositories while preserving service ownership, public contracts, compatibility, and project records. Use for work in mc-plan-foundation, mc-plan-contracts, mc-plan-core, mc-plan-community, mc-plan-skin, or mc-plan-ops; do not use for unrelated Minecraft projects.
metadata:
  short-description: Coordinate MC Plan multi-repo development
---

# MC Plan Development

Keep MC Plan changes independently deployable, contract-compatible, and traceable.

## Start

1. Find the workspace and affected repository or repositories. Read each affected `AGENTS.md` completely.
2. Read Foundation's `docs/constitution.md` and only the architecture, standard, ADR, or memory files relevant to the task.
3. Read [repository-map.md](references/repository-map.md) when ownership or repository scope is unclear.
4. State the task goal, acceptance evidence, affected repositories, and whether a public contract changes before editing.

If the requested change conflicts with the constitution, an accepted ADR, privacy truth, or repository ownership, stop and surface the conflict. Do not silently route around it.

## Work

- Keep data and behavior in the owning service. Never import another repository's source, query its database, or copy public contract types.
- For a public API, schema, event, scope, or SDK change, follow [contract-changes.md](references/contract-changes.md) before changing implementations.
- Make the smallest coherent change. Preserve unrelated user work and authorization boundaries.
- Use the actual validation commands declared by each repository. Do not claim a check passed unless it ran successfully.
- Treat secrets, tokens, production values, personal data, and AI prompts as sensitive; never place them in Git or logs.

## Finish

Read [workflow-and-handoff.md](references/workflow-and-handoff.md) when the task crosses repositories, changes a decision, or needs handoff.

Report completed behavior and evidence. Update only the correct truth source:

- Contracts for public interfaces.
- An ADR for durable cross-project decisions.
- The owning repository for implementation status.
- Foundation portfolio state for milestone-level changes.
- GitHub Issue/PR for task discussion and review state.

Do not create speculative documentation, duplicate task state, or update memory merely to narrate routine work.
