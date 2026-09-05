---
name: commercial
description: Evaluate product commercial viability through pricing, packaging, willingness-to-pay, market sizing, SaaS metrics, unit economics, channel economics, or feature investment analysis. Use when a PM needs a quantified commercial decision, sensitivity analysis, monetization hypothesis, or business-case recommendation. Use `discovery` when the customer problem or market is still unclear, `strategy` for portfolio investment choices, `growth` for funnel or retention diagnosis, and `gtm` for launch messaging and channels.
---

# Commercial Decisions

Turn sourced commercial inputs into a transparent decision without false precision.

## Input Contract

Reuse supplied prices, costs, cohorts, revenue, churn, margins, segments, market sources, constraints, and prior decisions. Require units, currency, time period, population, and source for material calculations; report unavailable results rather than inventing inputs.

## Process

1. Define the commercial decision, owner, horizon, alternatives, and affected customers.
2. Select the analysis: pricing/packaging, willingness-to-pay, market sizing, SaaS health, unit economics, channel economics, or feature investment case.
3. Apply the PM decision challenge and record assumptions, source dates, comparability, and sensitivity ranges.
4. Run deterministic finance calculations where supported; preserve raw inputs and formula definitions.
5. Compare scenarios, customer-value implications, business impact, downside, and invalidation conditions.
6. Issue one verdict with conditions, owner, next evidence, and review trigger.

## Output

- Commercial decision and alternatives
- Source and assumption ledger
- Calculated metrics and formula definitions
- Scenario and sensitivity comparison
- Customer-value, revenue, margin, and risk implications
- Rejected options and invalidation conditions
- Verdict, owner, next action, and review trigger

## Reference Routing

- Use `_refs/workflows/commercial-decision.md`, `_refs/checklists/commercial-quality.md`, and `_refs/templates/strategy/commercial-decision.md` for the core artifact.
- Use `_refs/workflows/market-sizing.md` and `_refs/templates/strategy/market-sizing.md` for TAM/SAM/SOM.
- Use `_refs/checklists/finance-metrics.md`, `_refs/checklists/ai-unit-economics.md`, and `_refs/templates/ai/unit-economics.md` only when applicable.
- Run `tools/calculate-finance-metrics.ps1` for supported SaaS metrics; do not hand-derive or invent values.
- Use `_refs/workflows/pm-decision-challenge.md`, `_refs/checklists/pm-decision-quality.md`, `_refs/operating-model/artifact-quality-system.md`, and `_refs/checklists/source-backed-minimality.md` before handoff.

## Handoff

Route unresolved customer or market evidence to `discovery`, portfolio implications to `strategy`, price or packaging experiments to `experiment`, adoption implications to `growth` or `gtm`, and an approved investment decision to `plan` only after scope is stable.
