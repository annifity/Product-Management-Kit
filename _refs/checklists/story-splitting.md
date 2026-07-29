# Story Splitting Checklist

Use when a story or epic is too large to estimate, sequence, or deliver independently.

- Complete the Responsibility Preview in `_refs/checklists/material-decision-preflight.md` before choosing the number of stories.
- Confirm whether Product wants one end-to-end story, independently releasable slices, or an enabling task plus user-facing stories.
- Split by workflow step when each step can deliver observable value.
- Split by actor or role when permissions or journeys differ.
- Split by business rule when rules can be delivered safely in phases.
- Split by data state when lifecycle states can be released incrementally.
- Split the happy path first only when deferred exceptions, controls, and risks are explicitly accepted and the slice remains safe and valuable.
- Split by integration boundary when mocks or stubs allow progress.
- Keep each story independently testable with clear acceptance criteria.
- Preserve traceability to the original requirement and mark deferred scope.

Avoid splitting by technical layer only, such as "frontend story" and "backend story", unless it is an explicit enabling task.

Do not split merely because a template has several sections or actors. Do not move a confirmed rule to another story unless its new owner, dependency, and release sequence are explicit.
