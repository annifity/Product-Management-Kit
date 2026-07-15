---
name: memories
description: Read and persist durable Annifity context under `.annifity/memories/`, including stable product context, terminology, team preferences, stakeholder constraints, confirmed decisions and outcomes, initiative state, lessons, and open questions. Use as workflow support, or primarily when the user asks to remember or update cross-session context. Use `knowledge` for broad retrieval and `docs` for versioned product artifacts.
---

# Memories

Preserve only durable, confirmed context so later sessions do not re-ask or reinterpret it.

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

Before `discovery`, `brief`, `prototype`, `experiment`, `validate`, `learn`, `spec`, `plan`, `execution`, `ship`, or artifact creation, read only the memory files relevant to the request.

## Write After Gates

After confirmed decisions, phase gates, initiative state changes, template preferences, terminology choices, accepted risks, release outcomes, or unresolved questions, update memory using `_refs/schemas/memory-record.md` and `_refs/schemas/initiative-state.md` when the state is durable.

Before writing, inspect the target file and identify the record being updated. Append or merge only when the target record is known; do not replace the whole file or overwrite unrelated history. If new context conflicts with an existing memory, preserve both claims with sources/status, surface the conflict, and ask before destructive replacement. Never promote an unconfirmed inference to durable memory.

## Reference Routing

Load only references needed for the memory category being read or changed:

- For product, team, terminology, or stakeholder context, use the matching template: `_refs/templates/memories/product-context.md`, `_refs/templates/memories/team-preferences.md`, `_refs/templates/memories/terminology.md`, or `_refs/templates/memories/stakeholder-context.md`.
- For decisions and outcomes, use `_refs/templates/memories/decisions.md`, `_refs/templates/memories/decision-outcomes.md`, and `_refs/templates/docs/decision-ledger.md` selectively.
- For unresolved items, use `_refs/templates/memories/open-questions.md`.
- For record structure, use `_refs/schemas/memory-record.md`, `_refs/schemas/decision-record.md`, and/or `_refs/schemas/initiative-state.md` according to the target record.

## Handoff

Return the exact memory paths, record identifiers, persisted state, and unresolved conflicts to the invoking workflow. Do not promote an unconfirmed claim or choose the next product phase on behalf of the owning workflow.
