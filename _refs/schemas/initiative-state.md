# Initiative State Schema

Use to persist the current state of a product initiative across discovery,
brief, prototype, experiment, validation, learning, strategy, specification,
design, planning, execution, and ship.

```yaml
---
id: INIT-001
name: [Initiative name]
owner: [Owner]
status: discovery | brief | prototype | experiment | validate | learn | strategy | spec | design | plan | execution | ship | shipped | parked | cancelled
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

## Phase Gate Approval Record

Use UTF-8 JSON with `tools/resolve-phase-gate-approval.ps1` to evaluate whether
a prior gate approval is reusable. The resolver is read-only and accepts the
same document through `-RequestPath` or `-RequestJson`.

```json
{
  "schemaVersion": "1.0",
  "gateId": "phase.spec.ready",
  "sourceFingerprint": "sha256:<64 lowercase hex>",
  "profileFingerprint": "sha256:<64 lowercase hex>",
  "evidence": [
    {
      "id": "SPEC-001-v1.2",
      "kind": "artifact",
      "source": ".annifity/docs/specs/SPEC-001_v1.2.md",
      "fingerprint": "sha256:<64 lowercase hex>"
    }
  ],
  "materialQuestions": [
    {
      "id": "OQ-001",
      "rank": 1,
      "text": "Who owns the exception decision?",
      "dependsOnQuestionIds": []
    }
  ],
  "questionPolicy": {
    "explicitBatchRequested": false,
    "maxQuestions": 1,
    "resolvedQuestionIds": []
  },
  "asOf": "2026-07-28T00:00:00Z",
  "invalidationEvents": [],
  "priorApproval": null
}
```

`gateId` must be one of the stable IDs in
`_refs/operating-model/phase-gates.md`. Source, profile, and evidence
fingerprints use `sha256:<64 lowercase hex>`. Evidence IDs are unique and the
resolver sorts evidence by ID before hashing.

Material questions are sorted by numeric `rank`, then ID. By default the
resolver selects one eligible question. `maxQuestions` may be two or three only
when `explicitBatchRequested` is `true`; a selected question is eligible only
when every ID in `dependsOnQuestionIds` appears in `resolvedQuestionIds`.

### Prior approval

Persist the exact approval context rather than only a conversational yes/no:

```json
{
  "approvalId": "APP-SPEC-001",
  "gateId": "phase.spec.ready",
  "gateFingerprint": "sha256:<resolver gate fingerprint>",
  "sourceFingerprint": "sha256:<64 lowercase hex>",
  "profileFingerprint": "sha256:<64 lowercase hex>",
  "evidence": [
    {
      "id": "SPEC-001-v1.2",
      "kind": "artifact",
      "source": ".annifity/docs/specs/SPEC-001_v1.2.md",
      "fingerprint": "sha256:<64 lowercase hex>"
    }
  ],
  "materialQuestions": [],
  "decision": "approved",
  "status": "active",
  "decidedBy": "user:product-owner",
  "decidedAt": "2026-07-28T00:00:00Z",
  "expiresAt": "2026-08-11T00:00:00Z",
  "invalidatedAt": null,
  "invalidationReasons": [],
  "attestation": {
    "schemaVersion": "1.0",
    "algorithm": "HMAC-SHA256",
    "keyId": "phase-gate-approval-2026-01",
    "signature": "hmac-sha256:<64 lowercase hex>"
  }
}
```

Allowed decisions are `approved`, `rejected`, and `deferred`. Allowed recorded
statuses are `active`, `revoked`, `superseded`, and `invalidated`. `expiresAt`
may be `null`; an unbounded approval still becomes stale when its gate
fingerprint changes. An approved record cannot contain unresolved material
questions. Each current invalidation event requires stable `id`, human-readable
`reason`, and ISO-8601 `recordedAt`; the resolver sorts events by ID and rejects
reuse when any event is present.

An unsigned record is never reusable. Create the record without `attestation`,
then run `tools/sign-phase-gate-approval.ps1` with `-ApprovalPath` or
`-ApprovalJson`. The signer adds the attestation and writes the signed record to
standard output; it does not write the source file.

The signer and resolver read the one active verification key only from the
process environment:

- `ANNIFITY_PHASE_GATE_APPROVAL_HMAC_KEY_ID` is the non-secret key ID,
  containing 1-64 ASCII letters, digits, dots, underscores, or hyphens, starting
  with a letter or digit; surrounding whitespace is invalid and key-ID matching
  is case-sensitive;
- `ANNIFITY_PHASE_GATE_APPROVAL_HMAC_KEY` is the Base64 encoding of at least 32
  secret bytes.

Never put the secret in approval or request JSON, a command argument, tool
output, logs, fixtures, generated artifacts, or the repository. Rotate both
environment values together and re-sign any approval that must remain reusable;
an approval naming any other key ID fails closed.

The attestation proves that a process holding the configured key signed the
complete record. It does not independently authenticate the human named by
`decidedBy`. Restrict the signer and environment key to the trusted approval
capture boundary; untrusted request producers may submit signed records to the
resolver but must not receive key access.

### Attestation canonical payload

The HMAC input is UTF-8 without a BOM and is the whitespace-free canonical JSON
of this envelope:

```json
{
  "domain": "annifity.phase-gate-approval",
  "schemaVersion": "1.0",
  "algorithm": "HMAC-SHA256",
  "keyId": "<attestation keyId>",
  "approval": "<the complete top-level approval object except attestation>"
}
```

Object property names are sorted by ordinal code-point order at every depth.
Array order is preserved. Strings and JSON types are preserved exactly; numbers
use invariant-culture JSON spelling, and booleans and null use lowercase JSON
literals. The `attestation` property is excluded in full. Therefore approval
fields must not be edited, reordered within arrays, or retyped after signing.
Top-level property order does not affect the signature.

The gate fingerprint covers the stable gate ID, source fingerprint, profile
fingerprint, canonical evidence, and canonical material questions. It excludes
the question-display policy, decision, timestamps, and approval identity.
Approval reuse requires exact equality between the stored and freshly resolved
gate fingerprint, a valid approval attestation, and an active, unexpired,
non-invalidated approved decision.

The resolver returns:

- canonical gate, evidence, and question fingerprints;
- prior decision and computed reuse status;
- attestation status and non-secret key ID, without the signature or secret;
- deterministic reasons for non-reuse;
- the eligible questions to ask now and the deferred questions.

Attestation failures use stable reasons:
`approval-attestation-missing`, `approval-attestation-invalid`,
`approval-attestation-key-missing`, `approval-attestation-key-invalid`, and
`approval-attestation-key-unknown`. Each produces `invalid-attestation` reuse
status and requires a fresh, correctly signed approval before reuse.

Do not persist the computed reuse status as a substitute for fresh resolution.
Store the approval record and resolve it again against current source and
profile fingerprints.

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
design:
  source_spec: [artifact_id@version]
  mode: screen-architecture | wireframe | visual-design | interactive-html
  traceability_status: incomplete | ready | blocked
  design_gate: not_started | in_progress | blocked | ready | approved
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
- Spec -> Design when accepted user-visible behavior needs flows, screens,
  interaction/state coverage, responsive rules, accessibility obligations, or
  design-system binding.
- Spec -> Plan directly when requirements are testable and traceable and no
  design phase applies.
- Design -> Validate or Plan only when the source baseline remains current,
  traceability is complete or gaps are owned, and the Design Gate passes.
- Design -> Spec or Change when the design exposes a missing decision or would
  alter accepted behavior.
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
