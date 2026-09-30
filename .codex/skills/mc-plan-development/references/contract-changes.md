# Public contract changes

Read this reference when a task changes an HTTP API, JSON Schema, event, OAuth scope, error code, SDK type, retention-visible behavior, or resource state.

## Required sequence

1. Identify the contract owner and current published version.
2. Classify the change as compatible or breaking. Adding a required field, narrowing accepted values, renaming, deleting, or changing semantics is breaking.
3. Update `mc-plan-contracts` first, including examples and compatibility notes. Do not invent fields that the product has not decided.
4. Validate OpenAPI and every referenced JSON Schema.
5. Publish or select a prerelease contract version for implementation work.
6. Update producer, SDK, then consumers in a deployable order. Use tolerant readers and expand/migrate/contract when old and new versions overlap.
7. Run provider and consumer contract tests. Record the version combination in the compatibility matrix.
8. Release stable contracts only after at least one conforming implementation has passed integration tests.

## Invariants

- Never duplicate contract types into service-owned source.
- Cross-service IDs are opaque strings and never database foreign keys.
- Writes that may be retried define idempotency semantics.
- Events may be duplicated or reordered; consumers are idempotent.
- OAuth scopes are public contract surface. New scopes require least-privilege review.
- Retention or visibility changes must match user-facing policy and runtime configuration.

If implementation urgency conflicts with this sequence, surface the risk instead of bypassing Contracts.
