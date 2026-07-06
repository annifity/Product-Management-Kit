# Initiative State Schema

Use to persist the current state of a product initiative across discovery, brief, prototype, experiment, validation, learning, specification, planning, execution, and ship.

```yaml
---
id: INIT-001
name: [Initiative name]
owner: [Owner]
status: discovery | brief | prototype | experiment | validate | learn | spec | plan | execution | ship | shipped | parked | cancelled
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
brief:
  success_metric_count: 0
  scope_confidence: high | medium | low
  open_questions: [Count or links]
prototype:
  learning_question_count: 0
  prototype_status: not_started | drafted | tested
experiment:
  hypothesis_count: 0
  tracking_status: not_started | ready | collecting | complete
validate:
  verdict: ready | needs_revision | blocked
  blocking_issues: [Count or links]
learn:
  decision: iterate | specify | plan | ship | park | reject
  confidence: high | medium | low
spec:
  requirement_count: 0
  readiness_score: 0
  blockers: [Count or links]
plan:
  priority_method: [RICE / WSJF / MoSCoW / value-effort / other]
  release_slice: [Now / Next / Later]
execution:
  active_scope_changes: [Count or links]
  delivery_risks: [Count or links]
ship:
  uat_status: not_started | in_progress | signed_off
  rollout_status: not_started | ready | launched
```

## Transition Rules

- Discovery -> Brief only when problem, target user, outcome, evidence, assumptions, and success metric are explicit or consciously deferred.
- Brief -> Prototype or Experiment only when the learning objective and scope boundaries are clear.
- Prototype -> Experiment only when there is something concrete enough to test.
- Experiment -> Validate only when criteria and evidence collection are complete enough to review.
- Validate -> Learn when prototype or experiment results are compared against the agreed criteria and should feed product learning.
- Validate -> Ship when blocking issues are resolved or accepted, UAT coverage is complete, and release risk is owned.
- Learn -> Spec only when evidence supports delivery commitment.
- Spec -> Plan only when requirements are testable, traceable, and readiness blockers are owned.
- Plan -> Execution only when release slice, dependencies, owners, and Definition of Ready are clear.
- Execution -> Validate when implementation questions, scope changes, and acceptance criteria are stabilized enough for readiness review.
- Any phase -> Parked when evidence, priority, capacity, or business value no longer justifies progress.

## Handoff Output

At phase transition, emit:

- Current status and phase gate.
- Source artifacts.
- Decisions made.
- Evidence and confidence.
- Open blockers and owners.
- Next recommended skill or workflow.
