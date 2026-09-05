# Task Progress Quality Checklist

Use this gate to review a multi-step Annifity execution or a runtime adapter's progress behavior.

## Activation

- The checklist appears before the first execution tool call or mutation when the task is multi-step.
- A simple answer, single read, or small one-step edit does not receive a synthetic plan.
- A task that expands in scope receives a checklist when the additional outcomes emerge.

## State Integrity

- Stable task IDs or numbers survive status updates, redirection, and interruption.
- At most one task is in progress unless real parallel execution is visible.
- Completed items have evidence or an observable result.
- Blocked items name the blocker and next action.
- Skipped items name the reason.
- Dependencies cannot complete ahead of unmet required work.
- Unchanged state is not republished.

## Communication

- Task names describe user-visible, business, or artifact outcomes rather than tools and commands.
- The display distinguishes completed, current, remaining, blocked, and skipped work.
- Routine updates hide raw schema and machine-only fields.
- Final responses summarize result, status, artifacts, validation, and remaining work.

## Product-State Boundary

- Task, lifecycle phase, gate, and artifact status remain distinct.
- Completing an assessment does not imply that the assessed gate passed.
- “Complete” is not claimed while required work is pending, active, or blocked.

## Runtime Portability

- Claude Code, Codex, GitHub Copilot, Cursor, and Markdown-only runtimes receive equivalent visible semantics.
- A native task tool is the source of truth when available; its state and the visible summary do not conflict.
- No unsupported background-work claim appears.

## Verdict

- **Ready:** every applicable item passes.
- **Needs revision:** visibility or update quality is weak but state remains recoverable.
- **Blocked:** state is contradictory, completion lacks evidence, or required blocked work is reported as complete.
