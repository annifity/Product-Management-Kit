---
name: growth
description: Diagnose and improve sustainable product growth across acquisition quality, activation, engagement, retention, referral, expansion, and growth loops. Use when a PM needs to find a growth constraint, identify an aha or critical event, explain churn, design a growth model, or build an evidence-backed intervention and experiment backlog. Use `analytics` for measurement-only diagnosis, `gtm` for positioning and launch-channel planning, and `commercial` for pricing, packaging, or unit-economics decisions.
---

# Product Growth

Find the binding growth constraint and design interventions that improve durable user value rather than vanity activity.

## Input Contract

Reuse supplied funnel, cohort, channel, retention, revenue, segment, product-quality, and experiment evidence. Without data, return a diagnostic plan and required instrumentation, not fabricated growth findings.

## Process

1. Define the growth outcome, product model, ICP, natural usage frequency, critical value event, and decision horizon.
2. Map acquisition, activation, engagement, retention, referral, and monetization; locate the highest-volume or highest-value constraint.
3. Segment by cohort, channel, persona, plan, account, and activation state when supported by data.
4. Distinguish causal drivers from correlated power-user behavior and product-quality failures from messaging or channel failures.
5. Apply the PM decision challenge, quantify opportunity where inputs permit, and reject generic engagement tactics or unsupported benchmarks.
6. Prioritize two or three interventions, counter-metrics, minimum tests, owners, and review triggers.

## Output

- Growth model and binding constraint
- Critical event, natural frequency, and lifecycle diagnosis
- Segment and cohort evidence
- Driver, detractor, and causality assessment
- Prioritized interventions and anti-plays
- Experiment backlog with success and guardrail metrics
- Verdict, owner, next action, and review trigger

## Reference Routing

- Use `_refs/workflows/product-growth.md`, `_refs/checklists/growth-quality.md`, and `_refs/templates/metrics/growth-plan.md` for the core diagnosis and plan.
- Use `_refs/workflows/product-analytics.md`, `_refs/checklists/product-analytics-quality.md`, `_refs/templates/metrics/metric-tree.md`, and `_refs/schemas/metrics-event.md` for evidence and instrumentation.
- Use `_refs/workflows/pm-decision-challenge.md` and `_refs/checklists/pm-decision-quality.md` for method and recommendation integrity.
- Use `_refs/workflows/go-to-market-adoption.md` only when the constraint is launch or channel adoption; route the complete motion to `gtm`.
- Apply `_refs/operating-model/artifact-quality-system.md` and `_refs/checklists/source-backed-minimality.md` before handoff.

## Handoff

Route measurement gaps to `analytics`, causal tests to `experiment`, positioning or channel action to `gtm`, pricing or packaging action to `commercial`, and assessed growth learning to `learn` or `strategy` according to decision scope.
