---
name: execution
description: Provide product-owner decisions and requirement clarification during active implementation after planning. Use for developer questions, blocked tickets, acceptance interpretation, dependency or trade-off decisions, defect triage, and Jira/Confluence context handoff. Use `change` when the answer modifies committed scope, acceptance criteria, or user-visible behavior; use `validate` for a readiness or quality audit rather than day-to-day delivery support.
---

# Execution

Answer delivery questions against accepted sources and escalate any baseline movement through change control.

## Input Contract

Reuse the supplied ticket, question, accepted source, applicable design contract, decision history, and delivery state. An authoritative active baseline is required for a binding clarification; if it cannot be resolved, return the blocker instead of answering from a newer draft or memory. Ask only for a missing fact that changes the route or decision.

## Process

1. Resolve the authoritative active spec, applicable design, and story baselines, then load their decisions, open questions, and relevant memories.
2. Classify the request as clarification, scope decision, blocker, defect triage, or change. When outcome, urgency, authority, evidence, or scope impact is unclear, separate the likely outcome from the literal ask, label assumptions, and ask only one route-changing question. When that question requires product or business confirmation, apply the User Confirmation Clarity Gate: state the decision in plain language, explain its user-visible impact, provide concrete options when known, and leave technical mechanism choices with the technical owner.
3. Answer from source documents when possible.
4. Escalate to `change` if the answer changes committed scope, acceptance criteria, launch scope, or user-visible behavior.
5. For active implementation changes, include affected tickets, AC, UAT, and AI context impact.
6. Record durable decisions through `docs` and `memories`.

## Output

- Short answer
- Source or rationale
- Impact on scope, story, UAT, or release
- Decision owner
- Affected tickets or artifacts
- Follow-up action

## Reference Routing

Load only references needed for the delivery question:

- For ambiguous routing or standard delivery support, use `_refs/operating-model/routing.md` and `_refs/workflows/execution-support.md`.
- For the active-delivery boundary and escalation decision, use the Execution Gate in `_refs/operating-model/phase-gates.md`.
- When clarification may change the baseline, use `_refs/workflows/change-governance.md` and `_refs/templates/change/spec-change-context.md`.
- For controlled source selection, use `_refs/operating-model/authoritative-baseline-resolution.md`; never answer from a newer unaccepted draft merely because its filename or date is latest.
- For authority, escalation, or communication decisions, use `_refs/checklists/stakeholder-governance.md`.
- Before requesting product or business confirmation, use the User Confirmation Clarity Gate in `_refs/checklists/material-decision-preflight.md`.
- For material cross-team decisions, dissent, or missed decision SLAs, use `_refs/workflows/stakeholder-decision-governance.md` and `_refs/templates/strategy/stakeholder-decision-map.md`.
- For durable decision capture, use `_refs/templates/docs/decision-log.md` and `_refs/templates/docs/decision-ledger.md`.
- For ticket-specific work, use `_refs/integrations/jira.md`.
- For a design implementation question, use `_refs/schemas/design-contract.md` and the linked screen, state, interaction, and gap IDs; route behavior changes to `change`.

## Handoff

Route baseline movement to `change` with the source, affected scope, tickets, acceptance criteria, and decision needed. When implementation is ready for business acceptance, hand the confirmed decisions, updated ticket context, and unresolved risks to `uat`; return ordinary clarifications to the delivery team with their source and owner.
