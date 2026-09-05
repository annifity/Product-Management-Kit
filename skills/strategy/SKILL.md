---
name: strategy
description: Define or revise product strategy and portfolio choices from evidence. Use for product vision, strategic choices, positioning, target segments, outcome and OKR architecture, portfolio bets, investment allocation, strategic roadmap themes, and stop/start/continue decisions across initiatives. Use `discovery` while an opportunity is unclear, `learn` when assessed evidence needs interpretation, `prioritize` to rank a defined option set, `commercial` for pricing or economic analysis, and `plan` only after a selected bet has stable delivery scope.
---

# Strategy

Turn evidence and constraints into explicit product and portfolio choices.

## Input Contract

Reuse the supplied company direction, product context, assessed evidence, portfolio state, constraints, and prior decisions. Require a named decision horizon and decision owner; if evidence is incomplete, distinguish a reversible directional choice from an irreversible investment commitment rather than inventing certainty. Route raw opportunity research to `discovery` and unassessed results to `validate`.

## Process

1. Resolve the current strategic baseline, durable decisions, evidence, and portfolio commitments.
2. Run the material-decision preflight for decision owner, horizon, source authority, decision mode, and destination.
3. Define the target users or segments, product outcome, strategic problem, and relevant market or operating constraints.
4. Apply the PM decision challenge; select a method whose required inputs exist and reject false precision, solution-led framing, or an unsupported strategic narrative.
5. Make choices explicit: where to play, how to win, capabilities required, what not to pursue, and which assumptions carry the strategy.
6. Compare portfolio bets using outcome contribution, evidence confidence, risk, dependency, capacity, time horizon, and economics.
7. Define outcome measures, guardrails, review triggers, and start/continue/stop/sequence decisions without converting themes into delivery commitments.
8. Issue a decision verdict, apply source-backed minimality, record dissent and residual uncertainty, then resolve the Strategy Gate before handing a selected bet to specification or planning.

## Output

- Strategic decision and horizon
- Product vision or strategic intent
- Target users, segments, and positioning
- Where-to-play and how-to-win choices
- Strategic outcomes, measures, and guardrails
- Portfolio bet assessment and investment recommendation
- Start, continue, sequence, pause, or stop decisions
- Explicit non-goals and rejected alternatives
- Assumptions, risks, evidence confidence, and review triggers
- Decision owner, consulted stakeholders, and next gate
- Decision verdict and conditions

## Reference Routing

Load only references required by the strategic decision:

- For the core workflow, use `_refs/workflows/product-strategy-portfolio.md`; use `_refs/checklists/strategy-quality.md` before handoff.
- For method selection, red-team review, and verdict, use `_refs/workflows/pm-decision-challenge.md`, `_refs/templates/skills/method-selection-record.md`, and `_refs/checklists/pm-decision-quality.md`.
- For output shape, use `_refs/templates/strategy/product-strategy.md` for one product or `_refs/templates/strategy/portfolio-decision.md` for choices across initiatives; use `_refs/templates/strategy/positioning-statement.md` when the choice includes a positioning claim.
- Resolve `_refs/schemas/artifact-generation-contract.md` through `_refs/operating-model/artifact-profile-resolution.md`, run `_refs/checklists/material-decision-preflight.md`, and apply `_refs/checklists/source-backed-minimality.md`.
- Resolve governed strategy and decision sources through `_refs/operating-model/authoritative-baseline-resolution.md`; use `_refs/operating-model/routing.md` when the request may instead be discovery, learning, or delivery planning.
- Use `_refs/checklists/opportunity-scoring.md`, `_refs/checklists/prioritization.md`, `_refs/checklists/finance-metrics.md`, and `_refs/workflows/market-sizing.md` only when the decision needs those analyses.
- For assessed product performance or adoption evidence, preserve the metric contract and evidence limits from `_refs/workflows/product-analytics.md`; do not infer causality from a dashboard trend.
- When AI is material, use `_refs/checklists/ai-suitability-risk-gate.md`, `_refs/checklists/ai-unit-economics.md`, and `_refs/templates/ai/unit-economics.md`; do not treat “AI-powered” as a strategic rationale.
- Use `_refs/workflows/stakeholder-decision-governance.md` when authority, dissent, escalation, or communication affects the choice.
- For positioning, launch motion, and adoption implications of a selected strategy, use `_refs/workflows/go-to-market-adoption.md`; leave release readiness and external action to `ship`.
- Resolve progression through the Strategy Gate in `_refs/operating-model/phase-gates.md`.

## Handoff

Hand a selected and approved bet to `brief` for compact alignment, `prototype` or `experiment` for learning, `spec` when delivery definition is justified, or `plan` only when stable delivery scope already exists. Send new uncertainty to `discovery`, assessed evidence requiring interpretation to `learn`, and durable choices to `docs` and `memories`.
