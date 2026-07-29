# Sprint Readiness Workflow

Use when a feature seems designed but must be proven ready before engineering commitment.

## Steps

1. Preflight: apply `_refs/checklists/material-decision-preflight.md` to source authority, ownership, states, mode, and baseline.
2. Requirement completeness: find missing requirements, contradictions, weak terms, and open questions.
3. Workflow validation: ensure actors, states, transitions, rollbacks, and sourced exception flows are complete.
4. Edge case validation: check only applicable concurrency, rollback, timeout, validation, permission, and integration risks.
5. Acceptance criteria review: apply `_refs/checklists/acceptance-criteria-quality.md`, rewrite non-ready AC, and add only relevant missing coverage.
6. Dependency analysis: identify hard blockers, soft blockers, and mockable dependencies.
7. UAT coverage review: use the selected UAT mode and risk-based happy, unhappy, edge, permission, and NFR coverage.
8. Minimality: apply `_refs/checklists/source-backed-minimality.md` to remove filler, duplicate truth, scope leakage, and misplaced content.
9. Operational readiness: check runbooks, alerts, overrides, escalation, monitoring, and audit trail.
10. Engineering grooming preparation: create questions by Backend, Frontend, QA, and Architecture.
11. Hard-blocker gate: evaluate the blockers below before interpreting the score.
12. Final readiness verdict: Ready, Ready with Conditions, or Not Ready.

## Score

| Dimension | Max |
|---|---:|
| Requirement completeness | 20 |
| Workflow completeness | 20 |
| Edge case coverage | 20 |
| Acceptance criteria quality | 20 |
| Operational readiness | 20 |

80-100 is ready. 60-79 is ready with conditions. Below 60 is not ready.

The score never overrides a hard blocker. A feature is `Not Ready` regardless
of score when any of these conditions remains:

- source authority or accepted baseline is unresolved;
- a material product decision is missing, contradictory, or unowned;
- acceptance criteria fail a non-waivable AC Quality Standard gate;
- a Definition of Ready blocker prevents deterministic implementation or
  verification;
- a critical dependency has no owner, resolution path, or accepted mock;
- the required UAT mode has no traceable pass criterion for a critical risk.

Record the blocker IDs, owner, and unblock action. Re-score only after the
underlying evidence changes.
