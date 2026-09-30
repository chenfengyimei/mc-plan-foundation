# Cross-repository workflow and handoff

Read this reference for changes spanning repositories, changing durable decisions, or ending before all dependent work is complete.

## Planning

- Read the current direction and every active workstream before defining scope.
- Assign one tracking ID and list every affected repository.
- Choose exactly one primary repository, at most two writable supporting repositories, and explicit read-only references.
- Define acceptance evidence per repository and the integration evidence for the whole change.
- Order work by compatibility: contract, producer, SDK, consumer, operations, documentation.
- Identify data migration, feature flag, observability, rollout, rollback, and retention effects.

## Records

- Validate repository locks before work, after scope changes, and before completion.
- Use an ADR only for a durable choice with meaningful alternatives or cross-project impact.
- Update a repository `docs/STATUS.md` only when its milestone state changes.
- Update Foundation portfolio state only when a portfolio milestone changes.
- Keep detailed task progress, review discussion, and assignees in GitHub Issue/PR.
- Use Foundation's handoff template when unfinished work moves to another person, agent, or task.
- Never release a lock because time passed or the working tree happens to be clean; record completion, cancellation, handoff, or takeover.

## Completion report

Include:

1. Observable outcome.
2. Repositories and public contract versions changed.
3. Validation commands and results.
4. Migrations, deployment order, flags, and rollback constraints.
5. Remaining work, risks, and exact owner or blocking decision.

Never report a task complete because documentation exists if required implementation or verification remains.
