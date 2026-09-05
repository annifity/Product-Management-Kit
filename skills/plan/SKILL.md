---
name: plan
description: Convert a confirmed product spec and, when applicable, its accepted design handoff into an actionable delivery plan. Use for release slices, delivery roadmaps, delivery-level epic maps, milestones, dependencies, grooming questions, and team handoff sequencing. This skill owns cross-epic slicing and sequence for selected stable scope; use `prioritize` while comparable options still need ranking, `strategy` for portfolio investment choices, `design` for unresolved UX/UI handoff, `user-story` for ticket-ready work, `spec` when requirements are unstable, and `execution` after delivery begins.
---

# Plan

Sequence stable scope into executable slices without redefining requirements.

## Input Contract

Reuse the supplied spec, accepted design handoff when applicable, priorities, constraints, and delivery context. Require a confirmed, stable spec or scope baseline; if it is missing or unstable, stop and route to `spec`. Route to `design` when implementation planning depends on unresolved user-visible flows, screens, states, accessibility behavior, or blocking design gaps. Ask only for material gaps that block prioritization or sequencing, and continue through non-blocking gaps with labeled assumptions.

## Process

1. Read the confirmed spec, applicable accepted design contract and handoff, and relevant memories.
2. Run the material-decision preflight to resolve the planning consumer, source baseline, release mode, slicing responsibility, and destination.
3. Apply the approved strategic priority, then identify delivery roadmap placement, release slices, delivery-level epics, milestones, dependencies, and sequencing.
4. Separate discovery, design, engineering, QA, data, rollout, and go-live work.
5. Prepare team-specific grooming questions when details need engineering input.
6. Apply source-backed minimality, then flag blockers and decisions needed before execution.
7. Resolve the Plan Gate approval through `_refs/operating-model/phase-gates.md`. Reuse a valid recorded approval only while its source, evidence, and material decisions remain unchanged; otherwise ask for a fresh PO decision before handing off ticket-ready Jira epics, stories, or acceptance criteria to `user-story`, or entering execution.

## Output

- Delivery objective
- Release slice recommendation
- Delivery-level epic map and sequencing
- Delivery prioritization and roadmap rationale
- Milestones
- Dependency matrix
- Engineering grooming questions
- Risks and mitigations
- Definition of Ready checklist
- Recommended next artifact: `user-story`, `uat`, or `execution`

## Reference Routing

Load only references needed for the planning decision:

- For route, packaged handoff, or the core planning workflow, use `_refs/operating-model/routing.md`, `_refs/operating-model/builder-packs.md`, and `_refs/workflows/spec-to-delivery-plan.md` selectively.
- Before planning, resolve `_refs/schemas/artifact-generation-contract.md` through `_refs/operating-model/artifact-profile-resolution.md`, then use `_refs/checklists/material-decision-preflight.md`; before handoff, use `_refs/checklists/source-backed-minimality.md`.
- Resolve the governed source spec through `_refs/operating-model/authoritative-baseline-resolution.md`; block rather than plan from an unaccepted latest draft.
- When an accepted design handoff applies, use `_refs/schemas/design-contract.md` and `_refs/templates/design/design-handoff.md`; keep open `DESIGN-GAP-*` blockers visible in dependencies and grooming.
- For roadmap or grooming output, use `_refs/templates/plan/product-roadmap.md` and/or `_refs/templates/plan/grooming-questions.md`. For a milestone schedule, use `_refs/templates/plan/milestones.md`; for cross-epic or cross-team dependencies too complex for a single column, use `_refs/templates/plan/dependency-matrix.md`.
- For epic sequencing, use `_refs/templates/user-story/story-map.md`.
- For delivery prioritization within the selected bet, use `_refs/checklists/prioritization.md`. Route product or portfolio investment choices, opportunity comparisons, and strategic economics to `strategy`.
- For entry or release gates, use `_refs/checklists/definition-of-ready.md` and/or `_refs/checklists/ship-readiness.md`.
- When checking readiness to leave planning or enter execution, use `_refs/operating-model/phase-gates.md`.
- For risk, stakeholder, security, privacy, or accessibility concerns, use `_refs/checklists/risk-review.md`, `_refs/checklists/stakeholder-governance.md`, and `_refs/checklists/security-privacy-accessibility.md` selectively.

## Handoff

Move to `user-story` with the confirmed release slice, delivery-level epic map, sequence, dependencies, applicable design IDs, and unresolved grooming decisions; use `uat` for acceptance planning or `execution` once ticket-ready scope enters delivery.
