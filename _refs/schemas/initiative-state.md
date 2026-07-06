# Initiative State Schema

Use to persist the current state of a product initiative across discovery, specification, planning, execution, review, and ship.

```yaml
---
id: INIT-001
name: [Initiative name]
owner: [Owner]
status: discovery | spec | planning | execution | review | ship | shipped | parked | cancelled
phase_gate: not_started | in_progress | blocked | ready | approved
updated: YYYY-MM-DD
sources:
  - [doc path / Jira / Confluence / decision]
---
```

## State Fields

| Field | Required | Notes |
|---|---|---|
| id | Yes | Stable ID for traceability. |
| name | Yes | Human-readable initiative name. |
| owner | Yes | Accountable PM/PO or decision owner. |
| status | Yes | Current lifecycle phase. |
| phase_gate | Yes | Readiness state within current phase. |
| updated | Yes | Last material update date. |
| sources | Yes | Source artifacts, decisions, tickets, or evidence. |

## Phase Data

```yaml
discovery:
  problem_statement: [Summary]
  evidence_quality: high | medium | low
  open_questions: [Count or links]
spec:
  requirement_count: 0
  readiness_score: 0
  blockers: [Count or links]
planning:
  priority_method: [RICE / WSJF / MoSCoW / value-effort / other]
  release_slice: [Now / Next / Later]
execution:
  active_scope_changes: [Count or links]
  delivery_risks: [Count or links]
review:
  artifact_quality_score: 0
  blocking_issues: [Count or links]
ship:
  uat_status: not_started | in_progress | signed_off
  rollout_status: not_started | ready | launched
```

## Transition Rules

- Discovery -> Spec only when problem, target user, outcome, evidence, assumptions, and success metric are explicit or consciously deferred.
- Spec -> Planning only when requirements are testable, traceable, and readiness blockers are owned.
- Planning -> Execution only when release slice, dependencies, owners, and Definition of Ready are clear.
- Execution -> Review when implementation questions, scope changes, and acceptance criteria are stabilized.
- Review -> Ship only when blocking issues are resolved or accepted, UAT coverage is complete, and release risk is owned.
- Any phase -> Parked when evidence, priority, capacity, or business value no longer justifies progress.

## Handoff Output

At phase transition, emit:

- Current status and phase gate.
- Source artifacts.
- Decisions made.
- Evidence and confidence.
- Open blockers and owners.
- Next recommended skill or workflow.
