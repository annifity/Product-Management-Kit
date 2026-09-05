# Product Analytics Quality Checklist

## Decision And Metric Definition

- [ ] Product question, decision owner, deadline, and possible actions are explicit.
- [ ] Outcome, leading, diagnostic, and guardrail metrics have distinct roles.
- [ ] Numerator, denominator, unit of analysis, eligibility, exclusions, and time window are defined.
- [ ] Baseline, target or threshold, and material slices are named.

## Instrumentation And Data Quality

- [ ] Events follow `_refs/schemas/metrics-event.md`.
- [ ] Identity, deduplication, attribution, time zone, bot/internal traffic, and late-event rules are explicit.
- [ ] Completeness, freshness, consistency, joins, and instrumentation changes are checked.
- [ ] Counts and denominators accompany percentages or rates.

## Analysis Quality

- [ ] Segment, cohort, funnel, retention, or adoption method matches the question.
- [ ] Comparisons use compatible definitions and observation windows.
- [ ] Alternative explanations, confounders, uncertainty, and missing evidence are visible.
- [ ] Aggregate performance does not hide a material harmed slice.
- [ ] Causal language is used only when the design supports it.

## Handoff

- [ ] Evidence-quality verdict is separate from product interpretation.
- [ ] Insight, confidence, decision, owner, and next action are traceable.
- [ ] Dashboard or monitoring output has thresholds and review triggers, not metrics alone.
