---
name: uat
description: Create or review User Acceptance Testing plans, scenario tests, test case registers, and coverage reports from PRDs, BRDs, specs, user stories, acceptance criteria, or release scope. Use for UAT coverage, role-based scenarios, happy paths, unhappy paths, boundary cases, permission validation, NFR scenarios, execution logs, and signoff readiness.
---

# UAT

Use this when requirements or stories are ready for acceptance validation.

## Process

1. Read the source PRD/spec/stories.
2. Identify roles, flows, permissions, data conditions, acceptance criteria, and NFR thresholds.
3. Produce test cases covering happy path, unhappy path, edge/boundary, permission, and NFR scenarios.
4. Trace every test case to a requirement, story, or acceptance criterion.
5. Assign priority and pass/fail indicators to every test case.
6. Flag missing acceptance criteria as open questions.
7. Ask `docs` to save the UAT plan.

## Required References

- `_refs/operating-model/builder-packs.md`
- `_refs/templates/uat/uat-plan.md`
- `_refs/templates/uat/test-case-register.md`
- `_refs/templates/uat/scenario-test.md`
- `_refs/checklists/uat-coverage.md`
- `_refs/checklists/security-privacy-accessibility.md`
- `_refs/templates/traceability/rtm.md`

## Output

Return a UAT plan plus a test case register or scenario test package.
