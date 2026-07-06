---
name: po-spec
description: Turn a confirmed product idea, PRD input, BRD, meeting note, discovery brief, roadmap item, or brainstorming brief into a precise product specification. Use for BRD analysis, feature design, scope, business rules, requirements, workflows, state behavior, edge cases, data/API rules, non-functional requirements, assumptions, risks, and open questions before delivery planning.
---

# PO Spec

Use this after `po-brainstorming` or whenever the user has enough context to define what should be built. Also use it to analyze BRDs or raw requirements before creating PRDs, stories, or UAT.

## Process

1. Load the latest relevant docs and memories if available.
2. Classify the source input: raw ask, discovery brief, BRD, PRD, meeting note, or existing spec.
3. Confirm the artifact target: product spec, BRD/PRD section, workflow spec, data/API note, or requirements register.
4. Draft a spec with requirement IDs, business rules, explicit assumptions, and source traceability.
5. Map primary workflows, states, permissions, data touchpoints, dependencies, and failure modes.
6. Run quality checks for ambiguity, edge cases, risk, operational readiness, and testability.
7. Ask the user to confirm before moving to `po-plan` or artifact skills such as `prd`.

## Spec Sections

- Context
- Problem and objective
- Users and roles
- Scope in / scope out
- Functional requirements
- Non-functional requirements
- Workflow and state behavior
- Data and integration notes
- API contract notes
- Business rules
- Permissions and compliance notes
- Risks and edge cases
- Dependencies
- Open questions
- Acceptance signals

## Required References

- `_refs/templates/spec/product-spec.md`
- `_refs/templates/spec/workflow-spec.md`
- `_refs/templates/spec/data-requirements.md`
- `_refs/templates/spec/api-contract.md`
- `_refs/templates/brd/default-brd.md`
- `_refs/templates/metrics/metric-tree.md`
- `_refs/checklists/spec-quality.md`
- `_refs/checklists/artifact-quality-scorecard.md`
- `_refs/checklists/business-analysis.md`
- `_refs/checklists/definition-of-ready.md`
- `_refs/checklists/solution-quality.md`
- `_refs/checklists/edge-cases.md`
- `_refs/checklists/risk-review.md`
- `_refs/workflows/feature-design.md`
- `_refs/workflows/requirement-analysis.md`
- `_refs/workflows/research-evidence.md`
- `_refs/workflows/ai-native-pm-loop.md`
- `_refs/workflows/discovery-to-spec.md`

## Handoff

If the spec is confirmed, move to `po-plan`. If the user wants a formal PRD or BRD-style document, use `prd`.
