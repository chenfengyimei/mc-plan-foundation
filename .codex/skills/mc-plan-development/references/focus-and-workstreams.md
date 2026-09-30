# Focus and workstreams

Read this reference before any MC Plan write operation.

## Required record

The authoritative state is in Foundation:

- `memory/current/repositories.json`: registered repositories and lifecycle.
- `memory/current/direction.json`: current global milestone and allowed projects.
- `memory/workstreams/active/<tracking-id>.json`: one task's scope and locks.

The active record must have one primary repository, at most two writable supporting repositories, explicit read-only references, clean base commits, branches containing the Tracking ID, objective, in/out scope, contract impact, Owner, and acceptance evidence target.

Foundation coordination writes limited to this workstream's record do not add a Foundation lock. Any other Foundation edit requires Foundation as primary or supporting.

## Preflight

1. If the user did not provide a Tracking ID for a write task, allocate the next unused `MCP-<milestone>-<primary>-<number>` ID.
2. Confirm the task aligns with the current direction. An exception is allowed only for security/data-loss response, compliance correction, or Foundation governance and must contain user authorization and reason.
3. Check all active records. If any writable repository overlaps, stop and require completion, cancellation, handoff, or explicit takeover.
4. Create and commit the active record before editing a target repository.
5. Create the declared short-lived branches, then run:

```powershell
pwsh -File .\mc-plan-foundation\scripts\validate-coordination.ps1 `
  -TrackingId <ID> -Phase Start
```

Do not proceed when validation fails.

## Checkpoints and scope

After each coherent commit, record the commit and actual verification. Before adding a writable repository, update and commit the record, confirm the two-support limit, create its branch, and rerun `Continue` validation. More repositories require linked sequential workstreams.

Read-only repositories do not lock and must remain unchanged. A dirty repository not covered by any active lock is a stop condition.

## Handoff, takeover, and completion

- Blocked work remains locked and records the exact unblock condition.
- Handoff or takeover appends history with old/new Owner, time, repository commits, remaining work, and reason. Never auto-expire a lock.
- Completion records observable evidence, validation and final commits, moves the file to `completed/`, and passes `-Phase Finish` before releasing branches.
- Update portfolio or repository status only when its milestone actually changes.
