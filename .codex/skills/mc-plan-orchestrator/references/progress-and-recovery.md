# Progress reconciliation and recovery

## Evidence order

Use current evidence in this order:

1. repository worktree, branch, reachable commits, and executable validation output;
2. Foundation active/completed workstream records and current direction;
3. target repository STATUS and development plan;
4. verified external CI or deployment evidence, when authorized and available;
5. another session's narrative report.

Do not discard a narrative report; turn each claim into a check. A named commit must exist, a clean claim must match `git status`, and a validation claim must appear in the workstream or be rerun when risk warrants it.

## Completion dimensions

Report each dimension separately:

| Dimension | Evidence |
|---|---|
| Scope implemented | Required files and behavior exist at named commits |
| Verification passed | Required commands actually passed against those commits |
| Coordination complete | Record is in `completed/`, final commits are filled, Finish passes, locks released |
| Integrated locally | Final commit is reachable from the repository's local `main` |
| Published remotely | Remote exists and the intended commit is pushed; never assume this |
| Product milestone complete | Direction exit criteria and all dependent workstreams are satisfied |

“Core code is complete” may be true while “Core workflow is complete” and “F1 Core is complete” are false.

## Recovery decisions

### Active owner is still working

Do not duplicate the Tracking ID or writable repositories. Wait, inspect status, or ask the user to authorize a message to the owner session. A separate non-overlapping workflow may proceed if direction permits.

### Work is implemented but record is blocked or open

Compare `blocked_reason` with current live state. If its condition has disappeared, label the reason stale and produce a continuation/closure prompt for the existing owner. Do not silently rewrite the record from an unrelated read-only session.

### Session disappeared

The lock remains. Inspect commits and worktree, then require an explicit user-authorized handoff or takeover recorded in `handoff_history`. Continue on the existing branch and Tracking ID when possible; do not create a replacement workflow to evade the lock.

### Dirty repository has no valid lock

Stop writes. Identify changed paths without modifying them, compare with recent commits and records, and generate a recovery prompt. The recovery owner must determine provenance, preserve user work, then either register an authorized workflow or restore a clean state through a user-approved action.

### Wrong branch or untraceable base

Stop writes. Do not move, reset, stash, or cherry-pick user work automatically. Produce the exact branch/commit discrepancy and request or use explicit recovery authority.

### Validation failed

Keep the workstream open. Distinguish an in-scope implementation defect from infrastructure or missing credential. Repair only within declared repositories and scope; otherwise record the blocker and handoff evidence.

## Reconciliation output

For every relevant workstream report:

- owner and Tracking ID;
- writable locks;
- record status versus observed Git status;
- last checkpoint and whether it is reachable;
- implementation, validation, closure, integration, and milestone states;
- stale or contradictory facts;
- single next action and who should perform it.

When state is changing in another Codex thread, prefer a bounded wait over polling. Stay quiet on unchanged state unless the user asked for periodic reports. For external agents, ask them to return the full packet defined in `dispatch-prompts.md`, then verify it locally.

