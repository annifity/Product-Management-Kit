---
name: knowledge
description: Retrieve and synthesize organizational product knowledge from local docs, memories, decision ledger records, pasted context, Jira, Confluence, or available workspace connectors. Use for feature existence checks, ownership questions, decision history, archaeology of past decisions, runbooks, artifact lookup, template lookup, and product context retrieval.
---

# Knowledge

Use this when the user asks what already exists, who owns something, why a decision was made, or where a process is documented.

## Process

1. Search local `.annifity/docs/`, `.annifity/memories/`, decision records, and repository references first.
2. If workspace connectors are available, search Jira or Confluence using the user's context.
3. For historical decisions, try direct decision records first, then archaeology across docs/comments.
4. For factual or market claims, prefer evidence ledger records before general docs.
5. Cite every factual claim with a source path or URL.
6. If sources conflict, surface the conflict.
7. If sources are missing or stale, say so clearly.

## Required References

- `_refs/integrations/jira.md`
- `_refs/integrations/confluence.md`
- `_refs/templates/docs/decision-log.md`
- `_refs/templates/docs/decision-ledger.md`
- `_refs/templates/docs/evidence-ledger.md`
- `_refs/templates/memories/decisions.md`
- `_refs/schemas/initiative-state.md`

## Output

Return a concise answer, evidence table, confidence level, and suggested next lookup.
