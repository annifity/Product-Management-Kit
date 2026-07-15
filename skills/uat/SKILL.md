---
name: uat
description: Create, refine, execute, or record User Acceptance Testing plans, scenario tests, and test-case registers from confirmed requirements or stories. Use for role-based happy, unhappy, boundary, permission, and NFR scenarios, traceability, execution logs, and acceptance results. Use `validate` for an independent audit of UAT coverage/readiness and `ship` for the final release package or signoff summary.
---

# UAT

Express confirmed scope as observable business-acceptance scenarios and execution evidence.

## Input Contract

- Reuse requirements, stories, acceptance criteria, roles, and execution evidence supplied inline or by file.
- Accept partial input and expose coverage gaps; ask only for missing information that changes a test condition or pass criterion.
- If no confirmed requirement or acceptance source exists, stop and route to `spec` or `user-story`. Do not invent acceptance behavior; label safe assumptions and open questions.

## Process

1. Read the source PRD/spec/stories.
2. Identify roles, flows, permissions, data conditions, acceptance criteria, and NFR thresholds.
3. Produce test cases covering happy path, unhappy path, edge/boundary, permission, and NFR scenarios.
4. Trace every test case to a requirement, story, or acceptance criterion.
5. Assign priority and pass/fail indicators to every test case.
6. Flag missing acceptance criteria as open questions.
7. Ask `docs` to save the UAT plan.

## Reference Routing

Load only references needed for the requested UAT artifact:

- For packaged UAT handoff, use `_refs/operating-model/builder-packs.md`.
- For a plan, case register, or scenario package, use only the matching template: `_refs/templates/uat/uat-plan.md`, `_refs/templates/uat/test-case-register.md`, or `_refs/templates/uat/scenario-test.md`.
- For coverage review while authoring, use `_refs/checklists/uat-coverage.md`.
- For sensitive data, permissions, security, privacy, or accessibility scenarios, use `_refs/checklists/security-privacy-accessibility.md`.
- For requirement-to-test traceability, use `_refs/templates/traceability/rtm.md`.

## Output

Return a UAT plan plus a test case register or scenario test package.

## Handoff

Route the UAT package to `validate` when cases, priorities, pass criteria, and source traceability are complete enough for an independent coverage verdict. Route to `ship` only after execution results and a signoff decision exist, with failed cases, waivers, and accepted risks explicitly recorded.
