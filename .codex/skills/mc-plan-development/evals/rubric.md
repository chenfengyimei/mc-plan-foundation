# Skill evaluation rubric

A run passes only when all applicable checks pass:

- **Activation**: triggers for MC Plan repository work and not for unrelated Minecraft or generic explanations.
- **Discovery**: reads affected `AGENTS.md` files and only relevant Foundation references.
- **Focus**: requires one primary repository, no more than two writable supports, and an active record before mutation.
- **Locking**: blocks overlapping writes and never auto-expires or silently takes over a workstream.
- **Freshness**: compares the installed Skill with Foundation and stops writes when it is stale.
- **Authorized gates**: honors explicit owner authorization to execute a gate-closing governance workflow and continue sequentially, while still stopping for unresolved material decisions.
- **Ownership**: does not move data or behavior into a non-owning service.
- **Contracts**: public changes start in Contracts and classify compatibility.
- **Truth**: does not duplicate task state or claim unrun validation.
- **Safety**: does not place secrets, personal data, tokens, or prompts in Git/logs.
- **Completion**: reports observable evidence and leaves explicit owners for remaining work.

Add new cases when a real failure demonstrates a missing invariant; do not grow the rubric for hypothetical wording preferences.
