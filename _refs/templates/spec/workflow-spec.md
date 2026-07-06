# Workflow Map: [Workflow Name]

Use for workflow design, workflow audit, BRD/PRD review, incident analysis, and operational risk discovery.

## 1. Workflow Summary

- Scope:
- Purpose:
- Start state:
- End state:
- Critical path:
- Explicit non-goals:

## 2. Actor Matrix

| Actor | Role | Trigger | Output | System? |
|---|---|---|---|---|
| [Actor] | Initiator / Approver / Operator / External system / Support | [Trigger] | [Output] | Yes / No |

## 3. State Transition Table

| From State | Event | To State | Condition | Invalid If | Recovery |
|---|---|---|---|---|---|
| [State] | [Event] | [State] | [Condition] | [Invalid condition] | [Rollback / retry / support] |

Flag duplicate transitions, concurrent write risks, stuck states, missing rollback transitions, and states with no owner.

## 4. Main Flow

| Step | Actor/System | Action | Input | Output | State Change |
|---|---|---|---|---|---|
| 1 | [Actor] | [Action] | [Input] | [Output] | [State] |

## 5. Decision Tree

```text
[Decision point]
├─ If [condition] -> [path]
└─ Else -> [path]
```

Capture approval conditions, validation rules, rejection paths, bypass paths, and default behavior.

## 6. Exception Scenarios

| Scenario | Trigger | System Behavior | Recovery | Gap? |
|---|---|---|---|---|
| Timeout | [Trigger] | [Behavior] | [Recovery] | Yes / No |
| Partial failure | [Trigger] | [Behavior] | [Recovery] | Yes / No |
| Sync conflict | [Trigger] | [Behavior] | [Recovery] | Yes / No |

## 7. Operational Concerns

- SLA checkpoints:
- Escalation paths:
- Support runbook:
- Manual override mechanism:
- Observability and alert gaps:
- Audit trail:
- Data correction path:

## 8. Technical Risks

| Risk | Component | Likelihood | Impact | Mitigation |
|---|---|---|---|---|
| [Risk] | [Component] | High / Medium / Low | High / Medium / Low | [Mitigation] |

## Quality Checks

- Every state has an entry and exit.
- Invalid transitions are explicit.
- Retry and idempotency behavior are defined.
- Partial failure and rollback are defined.
- Permission and bypass behavior are covered.
- Support can identify and resolve stuck states.
- Critical state changes are auditable.
