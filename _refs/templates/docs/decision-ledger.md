# Decision Ledger

Use for durable decision capture, retrieval, and outcome tracking.

## Decision Record

```yaml
---
id: DEC-001
date: YYYY-MM-DD
owner: [Owner]
status: active | superseded | rejected
outcome: pending | success | partial | failed
topics: [topic]
sources:
  - [Jira/Confluence/doc path]
---
```

## Decision

[What was decided in one or two sentences.]

## Context

[Why the decision was needed.]

## Options Considered

| Option | Rationale | Trade-off |
|---|---|---|
| [Option] | [Rationale] | [Trade-off] |

## Evidence

| Source | Signal |
|---|---|
| [Source] | [Signal] |

## Consequences

[Expected impact, risks, and follow-up.]

## Outcome Review

| Date | Outcome | Lesson |
|---|---|---|
| YYYY-MM-DD | Pending / Success / Partial / Failed | [Lesson] |

## Query Hints

Tag decisions by topic, feature, stakeholder, Jira key, and outcome so `knowledge` can retrieve them later.
