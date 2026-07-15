---
name: plan
description: Convert a confirmed product spec into an actionable delivery plan. Use for prioritization or investment decisions, roadmap and release slices, delivery-level epic maps, milestones, dependencies, grooming questions, and team handoff sequencing. This skill owns cross-epic slicing and sequence; use `user-story` for ticket-ready Jira epics, stories, and acceptance criteria, `spec` when requirements are unstable, and `execution` after delivery begins.
---

# Plan

Sequence stable scope into executable slices without redefining requirements.

## Input Contract

Reuse the supplied spec, priorities, constraints, and delivery context. Require a confirmed, stable spec or scope baseline; if it is missing or unstable, stop and route to `spec`. Ask only for material gaps that block prioritization or sequencing, and continue through non-blocking gaps with labeled assumptions.

## Process

1. Read the confirmed spec and relevant memories.
2. Identify priority, roadmap placement, release slices, delivery-level epics, milestones, dependencies, and sequencing.
3. Separate discovery, design, engineering, QA, data, rollout, and go-live work.
4. Prepare team-specific grooming questions when details need engineering input.
5. Flag blockers and decisions needed before execution.
6. Ask for PO confirmation before handing off ticket-ready Jira epics, stories, or acceptance criteria to `user-story`, or entering execution.

## Output

- Delivery objective
- Release slice recommendation
- Delivery-level epic map and sequencing
- Prioritization or roadmap rationale
- Milestones
- Dependency matrix
- Engineering grooming questions
- Risks and mitigations
- Definition of Ready checklist
- Recommended next artifact: `user-story`, `uat`, or `execution`

## Reference Routing

Load only references needed for the planning decision:

- For route, packaged handoff, or the core planning workflow, use `_refs/operating-model/routing.md`, `_refs/operating-model/builder-packs.md`, and `_refs/workflows/spec-to-delivery-plan.md` selectively.
- For roadmap or grooming output, use `_refs/templates/plan/product-roadmap.md` and/or `_refs/templates/plan/grooming-questions.md`.
- For epic sequencing, use `_refs/templates/user-story/story-map.md`.
- For prioritization, opportunity, finance, or market-size decisions, use `_refs/checklists/prioritization.md`, `_refs/checklists/opportunity-scoring.md`, `_refs/checklists/finance-metrics.md`, and `_refs/workflows/market-sizing.md` only as applicable.
- For entry or release gates, use `_refs/checklists/definition-of-ready.md` and/or `_refs/checklists/ship-readiness.md`.
- When checking readiness to leave planning or enter execution, use `_refs/operating-model/phase-gates.md`.
- For risk, stakeholder, security, privacy, or accessibility concerns, use `_refs/checklists/risk-review.md`, `_refs/checklists/stakeholder-governance.md`, and `_refs/checklists/security-privacy-accessibility.md` selectively.

## Handoff

Move to `user-story` with the confirmed release slice, delivery-level epic map, sequence, dependencies, and unresolved grooming decisions; use `uat` for acceptance planning or `execution` once ticket-ready scope enters delivery.
