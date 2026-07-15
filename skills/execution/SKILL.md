---
name: execution
description: Provide product-owner decisions and requirement clarification during active implementation after planning. Use for developer questions, blocked tickets, acceptance interpretation, dependency or trade-off decisions, defect triage, and Jira/Confluence context handoff. Use `change` when the answer modifies committed scope, acceptance criteria, or user-visible behavior; use `validate` for a readiness or quality audit rather than day-to-day delivery support.
---

# Execution

Answer delivery questions against accepted sources and escalate any baseline movement through change control.

## Process

1. Load the active spec, stories, decisions, open questions, and memories.
2. Classify the request as clarification, scope decision, blocker, defect triage, or change. When outcome, urgency, authority, evidence, or scope impact is unclear, separate the likely outcome from the literal ask, label assumptions, and ask only one route-changing question.
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
- For authority, escalation, or communication decisions, use `_refs/checklists/stakeholder-governance.md`.
- For durable decision capture, use `_refs/templates/docs/decision-log.md` and `_refs/templates/docs/decision-ledger.md`.
- For ticket-specific work, use `_refs/integrations/jira.md`.

## Handoff

Route baseline movement to `change` with the source, affected scope, tickets, acceptance criteria, and decision needed. When implementation is ready for business acceptance, hand the confirmed decisions, updated ticket context, and unresolved risks to `uat`; return ordinary clarifications to the delivery team with their source and owner.
