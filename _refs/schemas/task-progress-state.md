# Task Progress State Contract

Use this schema only when execution progress must be persisted, exchanged, or validated. Routine user updates should expose the readable checklist, not raw fields.

```yaml
progress_id: stable-progress-id
title: Human-readable work title
overall_status: pending | in_progress | completed | blocked | completed_with_skips
tasks:
  - task_id: stable-task-id
    order: 1
    title: Human-readable outcome
    status: pending | in_progress | completed | blocked | skipped
    outcome: Verifiable expected result
    depends_on: []
    evidence: []
    blocker: null
    next_action: null
    status_reason: null
updated_at: null
```

## Invariants

- Keep `progress_id`, `task_id`, and task order stable across updates unless a new task is inserted.
- A `completed` task has non-empty evidence or an observable result.
- A `blocked` task has a concrete `blocker` and `next_action`.
- A `skipped` task has a `status_reason`.
- At most one task is `in_progress` unless declared dependencies permit genuine parallel execution.
- A dependent task cannot become `in_progress` or `completed` while a required dependency remains `pending`, `in_progress`, or `blocked`.
- `overall_status: completed` requires every required task to be `completed`.
- `overall_status: completed_with_skips` requires every non-skipped task to be `completed` and every skip to have a reason.
- `overall_status: blocked` requires at least one required task to be `blocked` and no safely actionable task to remain in progress.
- Do not use timestamps to determine dependency order or completion.
- Never map task completion to lifecycle-gate approval without separate gate evidence.

## Marker Mapping

| State | Marker |
|---|---|
| `pending` | `[ ]` |
| `in_progress` | `[~]` |
| `completed` | `[x]` |
| `blocked` | `[!]` |
| `skipped` | `[-]` |

## Evidence Examples

Acceptable evidence includes an authored file path, a validation result, a tool result, a user decision, or an inspectable artifact. A statement such as “worked on it” is not evidence.
