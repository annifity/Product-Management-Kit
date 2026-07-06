# UAT Coverage Checklist

Every UAT package must cover business acceptance from the user's perspective. Do not write unit, implementation, or database tests here.

## Mandatory Categories

| Category | What It Tests | Minimum Coverage |
|---|---|---|
| Happy path | Primary success flow with valid actor, state, and input | At least 1 per actor per core action |
| Unhappy path | Expected failure states and business rule violations | At least 2 per feature |
| Boundary and validation | Exact min, max, empty, duplicate, invalid, long, special-character, and Unicode values | At least 3 material boundaries |
| Permission validation | Allowed and explicitly denied role/action pairs | Every role-action pair mentioned |
| Edge scenarios | Timeout, concurrent action, retry, empty state, stale data, partial failure | Every high/critical edge case from review |
| NFR scenarios | Performance, accessibility, security, reliability, offline/degraded mode | When relevant to user acceptance or release risk |

## Test Case Requirements

- Trace every test case to a requirement, story, business rule, or acceptance criterion.
- State data setup and preconditions.
- Write expected results as observable behavior: UI message, status, notification, permission denial, audit event, or business outcome.
- Include pass criteria and fail indicators.
- Flag assumed acceptance criteria as "assumed - needs confirmation".
- Cover permission denial beyond hidden UI; direct URL/API bypass must be rejected when relevant.
- Assign priority to every case: Critical / High / Medium / Low.

## Priority Guide

| Priority | Meaning |
|---|---|
| Critical | Release blocker if failed; core business function or compliance path. |
| High | Important user flow; significant UX, revenue, or support impact if failed. |
| Medium | Secondary path; workaround exists but behavior is expected. |
| Low | Rare edge or minor acceptance detail. |

## Coverage Output

| Area | Covered? | Evidence | Gap / Action |
|---|---|---|---|
| Happy path | Yes / No | [TC IDs] | [Gap] |
| Unhappy path | Yes / No | [TC IDs] | [Gap] |
| Boundary | Yes / No | [TC IDs] | [Gap] |
| Permission | Yes / No | [TC IDs] | [Gap] |
| Edge | Yes / No | [TC IDs] | [Gap] |
| NFR | Yes / No / N/A | [TC IDs] | [Gap] |
