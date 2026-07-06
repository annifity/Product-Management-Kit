---
name: memories
description: Maintain durable Annifity product memory. Use before and after PO workflows to read and update product context, team preferences, terminology, stakeholder constraints, decisions, decision outcomes, assumptions, template preferences, lessons learned, and open questions in `.annifity/memories/`.
---

# Memories

Use this to avoid re-asking stable context and to preserve durable PO knowledge across sessions.

## Storage Policy

Use `.annifity/memories/` for workspace-specific memory:

- `.annifity/memories/product-context.md`
- `.annifity/memories/team-preferences.md`
- `.annifity/memories/terminology.md`
- `.annifity/memories/stakeholder-context.md`
- `.annifity/memories/decisions.md`
- `.annifity/memories/decision-outcomes.md`
- `.annifity/memories/initiative-state.md`
- `.annifity/memories/open-questions.md`

## Read Before Work

Before `po-brainstorming`, `po-spec`, `po-plan`, `po-execution`, `po-review`, or artifact creation, read only the memory files relevant to the request.

## Write After Gates

After confirmed decisions, phase gates, initiative state changes, template preferences, terminology choices, accepted risks, release outcomes, or unresolved questions, update memory using `_refs/schemas/memory-record.md` and `_refs/schemas/initiative-state.md` when the state is durable.

## Required References

- `_refs/templates/memories/product-context.md`
- `_refs/templates/memories/team-preferences.md`
- `_refs/templates/memories/terminology.md`
- `_refs/templates/memories/stakeholder-context.md`
- `_refs/templates/memories/decisions.md`
- `_refs/templates/memories/decision-outcomes.md`
- `_refs/templates/docs/decision-ledger.md`
- `_refs/templates/memories/open-questions.md`
- `_refs/schemas/memory-record.md`
- `_refs/schemas/decision-record.md`
- `_refs/schemas/initiative-state.md`
