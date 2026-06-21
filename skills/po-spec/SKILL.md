---
name: po-spec
description: Turn a confirmed product idea, PRD input, BRD, meeting note, or brainstorming brief into a precise product specification. Use for scope, requirements, workflows, edge cases, data rules, non-functional requirements, assumptions, risks, and open questions before delivery planning.
---

# PO Spec

Use this after `po-brainstorming` or whenever the user has enough context to define what should be built.

## Process

1. Load the latest relevant docs and memories if available.
2. Confirm the source input and artifact target.
3. Draft a spec with requirement IDs and explicit assumptions.
4. Map primary workflows, states, permissions, data touchpoints, and failure modes.
5. Run quality checks for ambiguity, edge cases, risk, and testability.
6. Ask the user to confirm before moving to `po-plan` or artifact skills such as `prd`.

## Spec Sections

- Context
- Problem and objective
- Users and roles
- Scope in / scope out
- Functional requirements
- Non-functional requirements
- Workflow and state behavior
- Data and integration notes
- Permissions and compliance notes
- Risks and edge cases
- Dependencies
- Open questions
- Acceptance signals

## Required References

- `_refs/templates/spec/product-spec.md`
- `_refs/templates/spec/workflow-spec.md`
- `_refs/checklists/spec-quality.md`
- `_refs/checklists/edge-cases.md`
- `_refs/checklists/risk-review.md`
- `_refs/workflows/discovery-to-spec.md`

## Handoff

If the spec is confirmed, move to `po-plan`. If the user wants a formal PRD, use `prd`.
