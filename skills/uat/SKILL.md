---
name: uat
description: Create or review User Acceptance Testing plans and test cases from PRDs, specs, user stories, acceptance criteria, or release scope. Use for UAT coverage, role-based scenarios, happy paths, unhappy paths, boundary cases, and signoff readiness.
---

# UAT

Use this when requirements or stories are ready for acceptance validation.

## Process

1. Read the source PRD/spec/stories.
2. Identify roles, flows, permissions, data conditions, and acceptance criteria.
3. Produce test cases covering happy path, unhappy path, boundary, and permission scenarios.
4. Trace every test case to a requirement or story.
5. Flag missing acceptance criteria as open questions.
6. Ask `docs` to save the UAT plan.

## Required References

- `_refs/templates/uat/uat-plan.md`
- `_refs/templates/uat/test-case-register.md`
- `_refs/checklists/uat-coverage.md`

## Output

Return a UAT plan plus a test case register.
