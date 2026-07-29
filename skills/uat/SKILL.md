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
- For a governed source, `authoritative-baseline-resolution` must return `resolved` before case design. A named draft, newest filename, or unmanaged candidate is not a confirmed source. When resolution is blocked, return only the resolution diagnostics and unblock action unless the user explicitly asks for a non-executable exploratory test-design draft.

## Process

1. Resolve every governed source baseline. Stop before test design on any blocked result.
2. Run the material-decision preflight to resolve source authority, audience, explicit `business-demo`, `business-acceptance`, or `full-regression` mode, and destination. Do not choose a mode merely because the user said “UAT”.
3. Read the source PRD/spec/stories and identify roles, flows, permissions, data conditions, acceptance criteria, and NFR thresholds.
4. Produce risk-based test coverage for only the applicable happy, unhappy, edge/boundary, permission, and NFR behavior.
5. Trace every test case to a requirement, story, or acceptance criterion.
6. Assign priority and pass/fail indicators to every test case.
7. Flag missing or non-ready acceptance criteria as source gaps. Do not invent or silently rewrite acceptance behavior in UAT.
8. Apply source-backed minimality for the selected UAT mode, then ask `docs` to save the package.

## Reference Routing

Load only references needed for the requested UAT artifact:

- For packaged UAT handoff, use `_refs/operating-model/builder-packs.md`.
- Before test design, resolve `_refs/schemas/artifact-generation-contract.md` through `_refs/operating-model/artifact-profile-resolution.md`, then use `_refs/checklists/material-decision-preflight.md`; before handoff, use `_refs/checklists/source-backed-minimality.md`.
- Resolve every governed PRD, spec, story, and AC source through `_refs/operating-model/authoritative-baseline-resolution.md`; stop when the accepted baseline is ambiguous or unmanaged.
- For a plan, case register, or scenario package, use only the matching template: `_refs/templates/uat/uat-plan.md`, `_refs/templates/uat/test-case-register.md`, or `_refs/templates/uat/scenario-test.md`.
- When source AC quality is uncertain, use `_refs/checklists/acceptance-criteria-quality.md` only to identify the gap and route authoring repairs to `user-story`.
- For coverage review while authoring, use `_refs/checklists/uat-coverage.md`.
- For sensitive data, permissions, security, privacy, or accessibility scenarios, use `_refs/checklists/security-privacy-accessibility.md`.
- For requirement-to-test traceability, use `_refs/templates/traceability/rtm.md`.

## Output

Return a UAT plan plus a test case register or scenario test package and the compact generation receipt. A blocked baseline or material preflight returns diagnostics only, not a provisional case package.

## Handoff

Route AC authoring gaps to `user-story` or missing source behavior to `spec`; route committed acceptance changes to `change`. Route the UAT package to `validate` when cases, priorities, pass criteria, and source traceability are complete enough for an independent coverage verdict. Route to `ship` only after execution results and a signoff decision exist, with failed cases, waivers, and accepted risks explicitly recorded.
