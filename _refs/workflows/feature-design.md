# Feature Design Workflow

Use after discovery or a BRD when the team needs an engineering-ready feature design.

## Steps

1. Problem analysis: capture problem, objective, stakeholders, assumptions, and open questions.
2. Solution exploration: use `_refs/workflows/solution-exploration.md` when the approach is not settled.
3. Workflow design: map actors, states, decision points, exception flows, and operational handling.
4. Edge case analysis: use `_refs/checklists/edge-cases.md` and record severity, owner, and mitigation.
5. Requirement definition: write functional requirements, NFRs, business rules, dependencies, and constraints.
6. Acceptance handoff: define requirement-level acceptance signals and hand the confirmed requirements, workflow, rules, and edge cases to `plan` or `user-story`; do not author ticket-ready stories inside feature design.
7. Readiness review: check consistency across problem, workflow, requirements, edge cases, acceptance signals, and operations.

## Hard Rules

- Do not write requirements before the problem is understood.
- Do not let feature design silently take ownership of release slicing, story mapping, or ticket-ready acceptance criteria.
- If a critical edge case changes the solution, return to solution exploration.
- If requirements conflict with business rules, fix requirements before planning.
