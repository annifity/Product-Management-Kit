---
name: knowledge
description: Retrieve and synthesize organizational product knowledge from local docs, pasted context, Jira, Confluence, or available workspace connectors. Use for feature existence checks, ownership questions, decision history, runbooks, and product context lookup.
---

# Knowledge

Use this when the user asks what already exists, who owns something, why a decision was made, or where a process is documented.

## Process

1. Search local `.annifity/docs/`, `.annifity/memories/`, and repository references first.
2. If workspace connectors are available, search Jira or Confluence using the user's context.
3. Cite every factual claim with a source path or URL.
4. If sources conflict, surface the conflict.
5. If sources are missing or stale, say so clearly.

## Required References

- `_refs/integrations/jira.md`
- `_refs/integrations/confluence.md`
- `_refs/templates/docs/decision-log.md`
- `_refs/templates/memories/decisions.md`

## Output

Return a concise answer, evidence table, confidence level, and suggested next lookup.
