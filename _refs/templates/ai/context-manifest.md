# Context Manifest

Use when designing AI-native workflows, memory, retrieval, or multi-agent handoffs.

## Decision Supported

[What specific decision or workflow does this context support?]

## Always Persisted Context

| Context | Why It Must Persist | Owner | Review Cadence |
|---|---|---|---|
| [Constraint / glossary / preference] | [Specific failure if excluded] | [Owner] | [Cadence] |

## Retrieved On Demand

| Context | Retrieval Trigger | Source | Freshness Rule |
|---|---|---|---|
| [Historical PRDs / research / tickets] | [When needed] | [Path/system] | [Rule] |

## Excluded Context

| Context | Why Excluded | Revisit Trigger |
|---|---|---|
| [Context] | [No concrete failure if excluded / stale / noisy] | [Trigger] |

## Boundary Rules

- Persist only context needed in most interactions or required by compliance/strategy.
- Retrieve episodic project context just in time.
- For each context element, state the failure that occurs if it is excluded.
- After research-heavy work, synthesize a plan, reset context, then implement from the plan.
- Assign one owner for context boundary and review it regularly.
