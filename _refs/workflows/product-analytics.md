# Product Analytics Workflow

Use to define, inspect, or interpret product usage and outcome evidence. Keep measurement design, evidence validation, and product decision ownership explicit.

## Analytics Contract

- Name the product question, decision owner, population, time window, baseline, and decision deadline.
- Define the metric, unit of analysis, eligibility, exclusions, dimensions, source system, and freshness requirement.
- Link every behavioral metric to its event definition in `_refs/schemas/metrics-event.md`.
- Separate descriptive evidence from causal claims. Observational change is not proof that a product change caused it.

## Workflow

1. Frame the decision and the behavior or outcome that evidence must illuminate.
2. Define a metric tree: outcome metric, leading indicators, diagnostic metrics, and guardrails.
3. Specify events, identity rules, attribution window, cohorts, segments, time zone, bot/internal traffic handling, and late or duplicate event behavior.
4. Establish the baseline, target or threshold, comparison method, minimum sample or observation window, and material slices.
5. Validate data completeness, freshness, consistency, join coverage, denominator stability, and known instrumentation changes.
6. Analyze trends, funnels, cohorts, retention, feature adoption, or guardrails. Preserve counts and denominators beside rates.
7. Identify alternative explanations, confounders, missing slices, and evidence limits.
8. Issue a scoped evidence verdict through `validate`; send assessed evidence to `learn` for product interpretation and to `strategy`, `spec`, or `plan` only through an explicit decision.

## Decision Modes

| Mode | Required output | Primary skill |
|---|---|---|
| Measurement design | Metric definitions, events, QA, baseline plan | `experiment` or the owning artifact skill |
| Evidence quality review | Data-quality and comparability verdict | `validate` |
| Product interpretation | Insight, confidence, decision, next action | `learn` |
| Strategic portfolio review | Outcome contribution and investment implication | `strategy` |
| Post-release monitoring | Adoption, outcome, guardrail, incident signals | `ship`, then `validate` / `learn` |

## Failure Modes

- Vanity metrics without a product decision.
- Rates without counts or stable denominators.
- Mixing users, accounts, sessions, or events across numerator and denominator.
- Changing event definitions inside a trend without marking the break.
- Aggregate success hiding a harmed segment.
- Declaring causality from correlation.
- Reporting dashboards without owner, threshold, or next action.
