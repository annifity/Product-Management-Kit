# Metric Tree

Use when defining success metrics for discovery, BRD, PRD, roadmap, or release review.

## Outcome

[Business or user outcome.]

## Metric Taxonomy

| Level | Metric | Type | Baseline | Target | Time Window | Source | Owner | Review Cadence |
|---|---|---|---|---|---|---|---|---|
| North Star / KPI | [Metric] | Business / User | [Baseline] | [Target] | [Window] | [Source] | [Owner] | [Cadence] |
| User Outcome | [Metric] | Output | [Baseline] | [Target] | [Window] | [Source] | [Owner] | [Cadence] |
| Input Metric | [Metric] | Leading | [Baseline] | [Target] | [Window] | [Source] | [Owner] | [Cadence] |
| Guardrail | [Metric] | Quality / Risk | [Baseline] | [Target] | [Window] | [Source] | [Owner] | [Cadence] |

## Measurement Notes

- Define event, data source, frequency, and exclusions.
- Separate leading indicators from lagging indicators.
- Separate success metrics from acceptance criteria.
- Include operational and quality guardrails when user impact is material.
- Name the data owner and review cadence.
- Define the decision threshold: continue, iterate, rollback, or stop.
- Link instrumentation to `_refs/schemas/metrics-event.md` when event tracking is needed.
