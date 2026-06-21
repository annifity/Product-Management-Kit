---
name: po-plan
description: Convert a confirmed product spec into a delivery plan, epic map, release slices, dependency map, milestone plan, and team handoff sequence. Use after specification and before execution or story writing.
---

# PO Plan

Use this when the spec is stable enough to plan delivery.

## Process

1. Read the confirmed spec and relevant memories.
2. Identify release slices, epics, milestones, dependencies, and sequencing.
3. Separate discovery, design, engineering, QA, data, and go-live work.
4. Flag blockers and decisions needed before execution.
5. Ask for PO confirmation before writing detailed user stories or entering execution.

## Output

- Delivery objective
- Release slice recommendation
- Epic map
- Milestones
- Dependency matrix
- Risks and mitigations
- Definition of Ready checklist
- Recommended next artifact: `user-story`, `uat`, or `po-execution`

## Required References

- `_refs/workflows/spec-to-delivery-plan.md`
- `_refs/templates/user-story/story-map.md`
- `_refs/checklists/ship-readiness.md`
- `_refs/checklists/risk-review.md`
