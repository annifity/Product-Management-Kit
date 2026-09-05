---
name: analytics
description: Diagnose product performance and produce a decision-ready measurement plan from product events, funnels, cohorts, retention, activation, adoption, experiments, or KPI data. Use when a PM needs to define instrumentation, investigate metric movement, compare user segments, identify behavioral drivers, or turn product usage data into a recommended next analysis. Use `validate` for an independent evidence-quality verdict, `learn` after evidence is assessed and needs interpretation into a product decision, and `experiment` to design a prospective test.
---

# Product Analytics

Turn product data into a bounded diagnosis while preserving metric and causality limits.

## Input Contract

Reuse supplied data, charts, queries, event definitions, segments, baselines, targets, and decision context. If raw data is unavailable, produce an instrumentation and analysis plan rather than simulated findings.

## Process

1. Name the decision, product surface, population, natural usage interval, time window, and authoritative data source.
2. Validate metric contracts and data quality before interpreting movement.
3. Select the diagnostic lens: metric tree, funnel, cohort, retention, activation, adoption, segmentation, anomaly, or experiment readout.
4. Quantify absolute and relative change, denominators, segment differences, and uncertainty; separate correlation from causation.
5. Identify competing explanations, counterevidence, missing cuts, and the next cheapest analysis.
6. Issue a scoped diagnosis and route any evidence-quality verdict or product decision to its owner.

## Output

- Decision question and metric contract
- Data-quality and comparability assessment
- Baseline, target, movement, and segment analysis
- Diagnostic hypotheses and counterevidence
- Behavioral drivers labeled as correlation or tested cause
- Instrumentation or query requirements
- Evidence limits, next analysis, owner, and review trigger

## Reference Routing

- Use `_refs/workflows/product-analytics.md`, `_refs/checklists/product-analytics-quality.md`, and `_refs/templates/metrics/product-analytics-review.md` for the core diagnosis.
- Use `_refs/templates/metrics/metric-tree.md` and `_refs/schemas/metrics-event.md` for metric and event contracts.
- Use `_refs/workflows/pm-decision-challenge.md` and `_refs/checklists/pm-decision-quality.md` when a metric conclusion would create a material commitment.
- Use `_refs/templates/experiment/decision-criteria.md` only for completed experiment interpretation boundaries; route prospective design to `experiment`.
- Apply `_refs/operating-model/artifact-quality-system.md` and `_refs/checklists/source-backed-minimality.md` before handoff.

## Handoff

Route an independent evidence-quality verdict to `validate`, assessed findings requiring a product decision to `learn`, a testable causal hypothesis to `experiment`, a growth diagnosis to `growth`, and durable metric definitions to `docs` and `memories`.
