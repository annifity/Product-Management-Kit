# Sprint Readiness Workflow

Use when a feature seems designed but must be proven ready before engineering commitment.

## Steps

1. Requirement completeness: find missing requirements, contradictions, weak terms, and open questions.
2. Workflow validation: ensure actors, states, transitions, rollbacks, and exception flows are complete.
3. Edge case validation: check concurrency, rollback, timeout, validation, permission, and integration failures.
4. Acceptance criteria review: rewrite vague AC and add missing unhappy paths.
5. Dependency analysis: identify hard blockers, soft blockers, and mockable dependencies.
6. UAT coverage review: check happy, unhappy, edge, permission, and NFR coverage.
7. Operational readiness: check runbooks, alerts, overrides, escalation, monitoring, and audit trail.
8. Engineering grooming preparation: create questions by Backend, Frontend, QA, and Architecture.
9. Final readiness score: Ready, Ready with Conditions, or Not Ready.

## Score

| Dimension | Max |
|---|---:|
| Requirement completeness | 20 |
| Workflow completeness | 20 |
| Edge case coverage | 20 |
| Acceptance criteria quality | 20 |
| Operational readiness | 20 |

80-100 is ready. 60-79 is ready with conditions. Below 60 is not ready.
