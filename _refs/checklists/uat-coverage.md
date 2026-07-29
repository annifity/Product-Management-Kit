# UAT Coverage Checklist

Every UAT package must cover business acceptance from the user's perspective. Do not write unit, implementation, or database tests here.

## Risk-Based Categories

Select coverage from confirmed behavior, the deliverable mode, and release risk. Do not create cases to satisfy a numeric quota.

| Category | What It Tests | Applicability Rule |
|---|---|---|
| Happy path | Primary success flow with valid actor, state, and input | Cover each core action needed by the selected UAT mode |
| Unhappy path | Expected failure states and business rule violations | Cover each sourced rejection or material rule failure |
| Boundary and validation | Confirmed minimum, maximum, empty, duplicate, invalid, or cross-boundary behavior | Cover only boundaries defined by a source or accepted risk analysis |
| Permission validation | Allowed and explicitly denied role/action pairs | Cover roles and scopes named by the source; include protected-action denial when material |
| Edge scenarios | Timeout, concurrent action, retry, empty state, stale data, partial failure | Cover only sourced behavior or a release-risk assumption explicitly marked as a blocker |
| NFR scenarios | Performance, accessibility, security, reliability, offline/degraded mode | Cover sourced acceptance thresholds and applicable release risks |

For each category, record `Covered`, `Gap`, or `N/A` with a short source- or risk-based reason. `N/A` is not a missing test when the category is genuinely irrelevant to the selected mode.

## Test Case Requirements

- Trace every test case to a requirement, story, business rule, or acceptance criterion.
- State data setup and preconditions.
- Write expected results as observable behavior: UI message, status, notification, permission denial, audit event, or business outcome.
- Include pass criteria and fail indicators.
- Flag assumed acceptance criteria as "assumed - needs confirmation" and do not treat them as passed acceptance.
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

| Area | Status | Evidence / Applicability Reason | Gap / Action |
|---|---|---|---|
| Happy path | Covered / Gap / N/A | [TC IDs or reason] | [Gap] |
| Unhappy path | Covered / Gap / N/A | [TC IDs or reason] | [Gap] |
| Boundary | Covered / Gap / N/A | [TC IDs or reason] | [Gap] |
| Permission | Covered / Gap / N/A | [TC IDs or reason] | [Gap] |
| Edge | Covered / Gap / N/A | [TC IDs or reason] | [Gap] |
| NFR | Covered / Gap / N/A | [TC IDs or reason] | [Gap] |
