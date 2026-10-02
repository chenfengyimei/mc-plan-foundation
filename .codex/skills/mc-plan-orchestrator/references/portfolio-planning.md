# Portfolio planning

## Priority order

Choose the next action in this order unless the owner explicitly changes direction:

1. protect data, security, compliance, and user work;
2. close or correctly hand off work that is implemented and verified;
3. unblock the active global primary direction;
4. complete contract or infrastructure dependencies for that direction;
5. run an already authorized restricted-preparation workflow with disjoint locks;
6. plan later milestones or admit a new module.

Do not equate the most visible repository with the global priority. Read `memory/current/direction.json`.

## Slice work

Each dispatched write workflow has:

- one outcome and one primary repository;
- zero to two writable supporting repositories;
- an explicit contract classification;
- testable exit criteria;
- exclusions that prevent the session from drifting into the next milestone.

When a goal needs more than two supporting repositories, split it into dependency-ordered workflows. Keep the integration story in the plan, not in simultaneous locks.

## Concurrency

Build a writable lock set for each active or proposed workflow. Two workflows may run together only if their sets are disjoint and both are allowed by current direction. Shared read-only references are safe.

Safe example:

```text
Core + Contracts workstream   ||   Skin-only restricted preparation
```

Unsafe example:

```text
Core + Contracts workstream   ||   another Contracts workstream
```

Do not reserve future repositories before a workflow needs them. Do not launch multiple conversations against the same workflow unless one is explicitly read-only and cannot mutate state.

## Dependency patterns

- Public interface: Contracts → producer → SDK → consumer → Ops.
- Service runtime: service image/ports/health/migrations → Ops environment.
- Official Skin integration: Core identity/entitlement → Community publication → Skin official flow.
- Standalone Skin work may proceed only within the restrictions recorded in current direction and its ADR.
- Community interaction layers follow the repository development plan after the resource publication loop.

## Future modules

For a Mod, map, texture, or other new module:

1. dispatch a Foundation proposal using the new-module template;
2. decide ownership, data, independent deployment, license, privacy, cost, resource type, and operations owner;
3. accept an ADR and register lifecycle `proposed`, then `approved`;
4. create the top-level Git repository and required skeleton;
5. update registry, repository map, portfolio, and Contracts/Ops impact;
6. permit implementation only after lifecycle becomes `active`.

Do not create a project directory merely because it appears in a roadmap idea.

## Planning deliverable

For each proposed workstream state:

- order and dependency;
- owner session/tool;
- Tracking ID only if already allocated—otherwise mark it “to be allocated after live preflight”;
- primary/support/reference repositories;
- lock set and concurrency compatibility;
- observable outcome and validation;
- start gate, finish gate, and stop condition.

Keep long-range plans flexible at workflow granularity. Persist durable direction in Foundation only through a valid Foundation workstream.

