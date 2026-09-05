# Execution Support

Use during active implementation to answer quickly from the accepted baseline
without turning every clarification into a new requirement.

## Request Types

- Clarification: explain existing scope.
- Decision: choose between valid options.
- Blocker: identify owner and next action.
- Defect triage: compare actual behavior with accepted requirements.
- Change: invoke `change` when baseline scope moves.

## Operating Cadence

1. Resolve the authoritative spec, story, AC, decision, and release baseline.
2. Classify the request and record its delivery impact, urgency, and decision deadline.
3. Answer ordinary clarification directly with a source citation.
4. For a valid option decision, state alternatives, trade-offs, recommendation, owner, and deadline.
5. For a blocker, name the blocked item, dependency, owner, escalation time, workaround, and impact of waiting.
6. For a suspected defect, compare expected and actual behavior, reproduction evidence, affected users, severity, and release impact.
7. Route any committed scope, acceptance, launch scope, or user-visible behavior movement to `change`.
8. Propagate the outcome to affected tickets, UAT, release context, docs, and memories.

## Decision Boundary

| Situation | Action |
|---|---|
| Accepted source answers the question | Clarify and cite it |
| Accepted sources conflict | Return blocker and decision owner |
| Multiple implementations satisfy accepted behavior | Recommend within the accepted boundary |
| Required behavior is absent from accepted scope | Route to `change` |
| Actual behavior violates accepted source | Triage as defect |
| Newer draft differs from active baseline | Do not use it until accepted |

## Response Shape

- Short answer and request type
- Accepted source and confidence
- Scope, ticket, AC, UAT, release, or AI-context impact
- Decision owner and deadline
- Affected artifacts
- Follow-up or escalation

## Service Expectations

- Keep a decision queue with age, owner, and delivery impact.
- Escalate unanswered material decisions before they block the critical path.
- Review repeated clarifications as a signal that the spec, story, glossary, or
  handoff needs repair.
- Never use response speed as a reason to bypass baseline resolution or change
  control.
