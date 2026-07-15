---
name: spec
description: Turn confirmed product context into the detailed delivery source of truth. Use for a product or workflow specification with scoped requirements, business rules, states, permissions, edge cases, data/API behavior, non-functional requirements, assumptions, risks, and traceability before planning. Use `brief` while only direction-level alignment is needed, `prd` for a formal stakeholder requirements document, and `plan` only after the spec is stable.
---

# Spec

Define canonical delivery behavior precisely enough for planning, story authoring, and acceptance testing.

## Process

1. Load the latest relevant docs and memories if available.
2. Classify the source input: raw ask, discovery brief, BRD, PRD, meeting note, or existing spec.
3. If the source lacks a confirmed problem, target users, or intended outcome, or selecting scope requires product strategy, stop and route to `discovery`. If direction is confirmed but only alignment-level detail exists, route to `brief`; do not invent delivery behavior.
4. Confirm the artifact target: product spec, BRD/PRD section, workflow spec, data/API note, or requirements register.
5. Draft a spec with requirement IDs, business rules, explicit assumptions, and source traceability.
6. Map primary workflows, states, permissions, data touchpoints, dependencies, and failure modes.
7. Run quality checks for ambiguity, edge cases, risk, operational readiness, and testability.
8. Ask the user to confirm before moving to `plan` or artifact skills such as `prd`.

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

## Reference Routing

Load only references needed for the source and specification surface:

- For ambiguous route, packaged handoff, or discovery transition, use `_refs/operating-model/routing.md`, `_refs/operating-model/builder-packs.md`, and `_refs/workflows/discovery-to-spec.md` selectively.
- Before declaring the spec ready for planning, use the Spec Gate in `_refs/operating-model/phase-gates.md`.
- For the target spec, use only the matching template: `_refs/templates/spec/product-spec.md`, `_refs/templates/spec/workflow-spec.md`, `_refs/templates/spec/data-requirements.md`, or `_refs/templates/spec/api-contract.md`; use `_refs/templates/brd/default-brd.md` only when analyzing or structuring BRD input.
- For metric structure, use `_refs/templates/metrics/metric-tree.md`.
- For core requirement analysis or feature design, use `_refs/workflows/requirement-analysis.md` and/or `_refs/workflows/feature-design.md`.
- For quality and delivery readiness, use `_refs/checklists/spec-quality.md`, `_refs/checklists/artifact-quality-scorecard.md`, `_refs/checklists/business-analysis.md`, `_refs/checklists/definition-of-ready.md`, and `_refs/checklists/solution-quality.md` selectively.
- For edge cases, risk, governance, security, privacy, or accessibility, use `_refs/checklists/edge-cases.md`, `_refs/checklists/risk-review.md`, `_refs/checklists/stakeholder-governance.md`, and `_refs/checklists/security-privacy-accessibility.md` only as applicable.
- For external evidence, use `_refs/workflows/research-evidence.md`.
- For AI-native multi-phase context, use `_refs/workflows/ai-native-pm-loop.md`.

## Handoff

Route to `plan` only when the Spec Gate passes and the confirmed spec contains testable scope, rules, risks, dependencies, and acceptance signals. Route to `prd` when stakeholders need a formal document derived from that confirmed source of truth.
