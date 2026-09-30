# Repository map

Read this reference when deciding ownership or the affected repositories.

| Repository | Owns | Must not own |
|---|---|---|
| `mc-plan-foundation` | Constitution, architecture, standards, ADRs, portfolio state, templates, this Skill | Business implementations or production secrets |
| `mc-plan-contracts` | Public OpenAPI, JSON Schema, events, generated/public SDK surface, compatibility matrix | Service business logic or private database models |
| `mc-plan-core` | MC Plan user mapping/profile, roles, developer apps, scopes, credits, daily entitlements, audit | Passwords, community resources, Skin conversations |
| `mc-plan-community` | Resources, versions, files, license snapshots, social graph, interactions, search, feeds, moderation, notifications | Passwords, global credit balance, generation conversations |
| `mc-plan-skin` | Conversations, render jobs, candidates, skin validation, provider adapters, Official/Standalone behavior | User master data, community interactions, global ledger |
| `mc-plan-ops` | Production topology, deploy manifests, proxy, monitoring, backup/restore, runbooks | Application source, public self-host defaults, committed secrets |

The workspace root is not a Git repository. Each child repository has its own history, releases, approvals, and rollback.

For a new module, use Foundation's `templates/new-module.md` before creating a repository or resource type.
