---
name: knowledge
description: Retrieve and synthesize existing product knowledge from local docs, memories, decision records, Jira, Confluence, pasted context, or workspace connectors, with source citations and confidence. Use when the user asks what exists, where it is documented, who owns it, or why a decision was made. This is read-oriented; use `docs` to write or index artifacts and `memories` to persist durable context.
---

# Knowledge

Ground answers in retrievable sources, distinguish conflicts, and state confidence.

## Input Contract

Reuse the user's question, supplied text, source paths, identifiers, and time boundary. Accept missing source locations and search only the available in-scope stores; do not turn absence of evidence into a fact. Ask only when identity or scope ambiguity would make the answer materially unreliable.

## Process

1. Search local `.annifity/docs/`, `.annifity/memories/`, decision records, and repository references first.
2. If workspace connectors are available, search Jira or Confluence using the user's context.
3. For historical decisions, try direct decision records first, then archaeology across docs/comments.
4. For factual or market claims, prefer evidence ledger records before general docs.
5. Cite every factual claim with a source path or URL.
6. If sources conflict, surface the conflict.
7. If sources are missing or stale, say so clearly.

## Reference Routing

Load only references needed for the source being searched:

- For Jira or Confluence lookup, use `_refs/integrations/jira.md` and/or `_refs/integrations/confluence.md`.
- When a question depends on the current accepted version of a governed artifact, use `_refs/operating-model/authoritative-baseline-resolution.md`; treat indexes, backlogs, links, and filenames as supporting evidence only.
- For current or historical decisions, use `_refs/templates/docs/decision-log.md`, `_refs/templates/docs/decision-ledger.md`, and `_refs/templates/memories/decisions.md` selectively.
- For evidence-backed factual claims, use `_refs/templates/docs/evidence-ledger.md`.
- For current initiative ownership or phase state, use `_refs/schemas/initiative-state.md`.

## Output

Return a concise answer, evidence table, confidence level, and suggested next lookup.

## Handoff

Return the cited evidence, conflicts, confidence, and unresolved gaps to the invoking workflow. Route to `docs` only when the user requests an artifact update and to `memories` only when confirmed durable context should be persisted.
