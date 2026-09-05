---
name: prioritize
description: Choose and apply an evidence-aware method to rank product opportunities, features, assumptions, experiments, or backlog options. Use when a PM needs a defensible priority order, framework comparison, sensitivity check, or an explicit explanation of why one option should precede another. Use `strategy` for portfolio investment and where-to-play choices, `plan` for sequencing stable delivery scope, and `discovery` when the options or problem are not yet sufficiently defined.
---

# Prioritize

Turn comparable options into a transparent priority decision without inventing scores.

## Input Contract

Reuse supplied options, evidence, constraints, scoring inputs, strategic outcomes, and capacity. Ask only for a missing input that could reverse the ranking; otherwise continue with a qualitative method and label its limits.

## Process

1. Confirm the decision, owner, horizon, option set, constraints, and what the ranking will control.
2. Apply the PM decision challenge and reject a requested framework when its required inputs are absent or incomparable.
3. Select the smallest reliable method: value-effort, RICE, WSJF, Kano, opportunity scoring, weighted scoring, assumption risk, or qualitative pairwise comparison.
4. Normalize units and evidence confidence; keep raw inputs visible and never convert guesses into factual scores.
5. Rank options, run a sensitivity check on the most uncertain inputs, and expose ties or unstable positions.
6. Issue one verdict and identify excluded options, displaced work, decision owner, and review trigger.

## Output

- Priority decision and selected method
- Input and evidence table
- Ranked options with calculations or qualitative rationale
- Sensitivity and confidence assessment
- Rejected methods and options
- Capacity, dependency, and risk constraints
- Verdict, owner, next action, and review trigger

## Reference Routing

- Use `_refs/workflows/pm-decision-challenge.md`, `_refs/checklists/pm-decision-quality.md`, and `_refs/templates/skills/method-selection-record.md` to select and challenge the method.
- Use `_refs/operating-model/methodology-catalog.md` for named-method provenance and usage boundaries.
- Use `_refs/checklists/prioritization.md` for scoring discipline and `_refs/checklists/opportunity-scoring.md` for evidence-backed opportunity comparison.
- Use `_refs/templates/plan/prioritization-decision.md` for the decision artifact.
- Use `_refs/checklists/finance-metrics.md` only when economics are material; route full commercial analysis to `commercial`.
- Apply `_refs/operating-model/artifact-quality-system.md` and `_refs/checklists/source-backed-minimality.md` before handoff.

## Handoff

Send a product or portfolio choice to `strategy`, a stable ranked delivery set to `plan`, an assumption to `experiment`, or an unresolved option set to `discovery`. Persist an approved decision through `docs` and `memories`.
