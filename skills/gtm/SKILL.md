---
name: gtm
description: Design an evidence-backed go-to-market and adoption motion for a defined product, feature, or segment. Use when a PM needs ICP, positioning, messaging, launch tier, channel strategy, enablement, rollout audiences, adoption hypotheses, or launch measurement before release operations. Use `strategy` for where-to-play and how-to-win choices, `commercial` for pricing and packaging decisions, `growth` for lifecycle optimization, and `ship` for release readiness, rollback, support, and execution.
---

# Go-to-Market

Translate a selected product direction into a testable market and adoption motion without claiming operational release readiness.

## Input Contract

Reuse supplied strategy, product scope, ICP evidence, positioning, pricing, launch constraints, channel evidence, and adoption baselines. If the product or audience is unresolved, return the blocking decision and route upstream.

## Process

1. Confirm product scope, target segment, buyer/user roles, desired behavior, launch horizon, and decision owner.
2. Validate positioning against the nearest real alternative and preserve evidence limits.
3. Select launch tier, audience sequence, message, channels, enablement, adoption hypothesis, and counter-metrics.
4. Apply the PM decision challenge to weak differentiation, unsupported channel claims, or a launch without measurable user behavior.
5. Define responsibilities, dependencies, experiments, measurement windows, stop conditions, and the operational handoff boundary.
6. Issue the GTM verdict without asserting release readiness.

## Output

- GTM decision, target segment, buyer, and user
- Positioning and message hierarchy
- Launch tier, audience sequence, and channel rationale
- Enablement and adoption plan
- Metrics, guardrails, experiments, and stop conditions
- Dependencies, risks, owners, and timeline
- Verdict and operational handoff

## Reference Routing

- Use `_refs/workflows/go-to-market-adoption.md`, `_refs/checklists/gtm-quality.md`, and `_refs/templates/release/go-to-market-plan.md` for the core motion.
- Use `_refs/templates/strategy/positioning-statement.md` for positioning and `_refs/workflows/stakeholder-decision-governance.md` for authority and dissent.
- Use `_refs/workflows/product-analytics.md`, `_refs/templates/metrics/metric-tree.md`, and `_refs/schemas/metrics-event.md` for adoption measurement.
- Use `_refs/workflows/pm-decision-challenge.md`, `_refs/checklists/pm-decision-quality.md`, `_refs/operating-model/artifact-quality-system.md`, and `_refs/checklists/source-backed-minimality.md` before handoff.

## Handoff

Route unresolved strategy to `strategy`, pricing or packaging to `commercial`, lifecycle optimization to `growth`, and the approved market motion to `ship` for release readiness, rollout, rollback, support, and external execution approval.
