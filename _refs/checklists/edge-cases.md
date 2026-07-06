# Edge Case Checklist

Check every relevant category. Mark "none found" when clean.

## Analysis Lenses

Apply all lenses to every workflow or state transition.

- State integrity: invalid transitions, impossible states, orphaned states, stuck states, rollback inconsistencies.
- Concurrency: simultaneous actors, duplicate submissions, multi-tab overwrite, async conflict, stale writes.
- Failure recovery: partial completion, timeout, background job interruption, notification failure, rollback path.
- Data integrity: source-of-truth conflict, cache drift, duplicate records, stale reads, eventual consistency gap.
- Permission and security: role escalation, direct API bypass, stale permission cache, self-approval, unauthorized state change.
- Operational reality: support intervention, manual override, escalation, SLA breach, monitoring, audit trail.
- Abuse and misuse: spam retries, malicious payloads, repeated approval/rejection, automation overload.

## Categories

- Invalid state transitions.
- Race conditions and concurrency risks.
- Empty, missing, duplicate, long, special-character, and invalid input.
- Duplicate actions from retries, refresh, double submit, webhook retry, or multi-tab use.
- Concurrent edits or conflicting actors.
- Partial failure across systems.
- Retry and idempotency behavior.
- Timeout, SLA breach, and recovery behavior.
- Synchronization gaps across cache, database, events, jobs, and downstream systems.
- Permission mismatch, stale permission, self-approval, and role escalation.
- Direct API or URL bypass of frontend permissions.
- Data consistency after rollback, manual correction, or reprocessing.
- Integration failure, degraded mode, malformed external response, and vendor outage.
- Manual intervention, stuck state, and support override gaps.
- Abuse, misuse, rate limits, automation overload, or unintended workflow path.
- Audit, traceability, alerting, and observability gaps.

For each edge case, capture trigger, preconditions, expected behavior, recovery, severity, and one owner.

## Severity Guide

| Severity | Meaning | Release Handling |
|---|---|---|
| Critical | Data corruption, security breach, financial impact, irreversible state, system deadlock | Must be resolved or explicitly accepted before build/release. |
| High | User-visible failure, SLA breach, silent data loss, significant manual recovery | Needs mitigation, owner, and test coverage. |
| Medium | Degraded UX, recoverable inconsistency, support workaround required | Track with owner and UAT/QA coverage. |
| Low | Rare minor edge with contained impact | Park or document accepted behavior. |

## Edge Case Register

| ID | Workflow | Category | Trigger | Preconditions | Failure Mode | Expected Behavior | Recovery | Severity | Owner |
|---|---|---|---|---|---|---|---|---|---|
| EC-001 | [Workflow] | [Category] | [Trigger] | [Preconditions] | [Failure] | [Expected] | [Recovery] | Critical / High / Medium / Low | Product / Backend / Frontend / Operations / QA |

## Quality Rules

- Every critical or high edge case needs mitigation and owner.
- Do not list generic infrastructure failures unless the workflow lacks degraded-mode behavior.
- Every retryable workflow must define idempotency behavior.
- Every multi-step workflow must define rollback or compensating action.
- If a category is clean, explicitly write "none found" with a short rationale.
