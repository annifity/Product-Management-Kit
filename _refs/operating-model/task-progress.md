# Task Progress Operating Model

Use this shared behavior for Annifity work that has multiple meaningful steps. It describes execution progress only; it does not replace lifecycle, gate, or artifact status.

## Activation

Show a progress checklist before the first tool call or mutation when any of these conditions applies:

- two or more independently verifiable execution outcomes;
- more than one lifecycle phase, tool, or file;
- a material artifact is created or changed;
- audit, research, implementation, validation, dependency, approval, or decision-gate work;
- an Annifity workflow or Builder Pack whose duration could make current state unclear.

Do not add a checklist to an immediately answerable question, a single read, a small one-step edit, or a short lookup with no follow-on workflow. If a simple request expands, create the checklist as soon as multiple outcomes emerge.

## User-Facing State

Use stable task numbers and these markers:

```text
[ ] Pending
[~] In progress
[x] Completed
[!] Blocked or awaiting a user decision
[-] Skipped or removed from scope
```

Write tasks as business or artifact outcomes that the user can verify. Do not expose tool calls, commands, file reads, or line edits as tasks.

```markdown
Progress

- [x] 1. Confirm the accepted source and requested outcome
- [~] 2. Draft the requirements package — in progress
- [ ] 3. Validate coverage and traceability
- [ ] 4. Deliver the artifact and remaining decisions
```

## State Transitions

1. Publish the initial checklist before execution begins.
2. Keep at most one item `[~]` unless outcomes are genuinely executing in parallel.
3. Update only when an outcome changes state: completion, next-step start, blocker, meaningful plan change, or recovery after interruption.
4. Do not republish unchanged state or turn the checklist into a tool log.
5. Mark `[x]` only when observable evidence satisfies the outcome. Record machine evidence internally; summarize it in plain language when useful.
6. For `[!]`, state the concrete blocker and the user input, owner action, or external change needed next. Leave dependent work pending.
7. For `[-]`, state why the item no longer applies.
8. When the plan changes, retain completed items and stable IDs, skip superseded items, add new items, and give one short reason.
9. When the user redirects the work, reconcile the existing checklist instead of starting an unrelated history.
10. After interruption or context compaction, reconstruct state from artifacts, results, tests, and decisions. Do not infer that an in-progress item completed.

## Runtime Adaptation

- When a native task or todo tool exists, use it as the source of truth and show a concise human-readable summary. Keep native and visible states consistent.
- Without a native tool, maintain the Markdown checklist in progress updates with stable IDs and order.
- Do not claim background execution unless the runtime actually supports it.
- Keep machine-only fields from `_refs/schemas/task-progress-state.md` out of routine business-facing updates.

## Status Boundaries

Keep four concepts separate:

| Concept | Meaning |
|---|---|
| Task status | How far the AI has progressed through its work |
| Phase status | Where the initiative sits in the product lifecycle |
| Gate status | Whether evidence permits lifecycle progression |
| Artifact status | Whether a deliverable is draft, reviewed, accepted, superseded, or retired |

Completing an assessment task does not imply that its gate passed. For example, `- [x] Assess Spec Gate` may correctly produce `Result: blocked because permission rules are missing.`

## Final Response

For multi-step work, the final response must be self-contained and include:

1. the primary result;
2. the final checklist or a compact status summary;
3. artifacts created or changed;
4. validation performed and its result;
5. remaining work or blockers;
6. an explicit statement when no required work remains.

Do not claim completion while a required item is pending, in progress, or blocked.

Use `_refs/schemas/task-progress-state.md` when state must be persisted or exchanged, `_refs/templates/docs/task-progress-checklist.md` for a reusable display shape, and `_refs/checklists/task-progress-quality.md` when reviewing behavior.
