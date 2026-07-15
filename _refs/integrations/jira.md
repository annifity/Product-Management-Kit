# Jira Integration Notes

- Ask for project key before creating or referencing issues.
- Keep story summary short and user-facing.
- Put acceptance criteria in the description unless the workspace has a dedicated field.
- Preserve issue keys exactly.
- If no connector is available, produce CSV-ready output.

## Mutation Approval Gate

1. Draft the proposed Jira create, update, or bulk operation without changing Jira.
2. Preview the target project, issue type or keys, summaries, fields, links, and operation count.
3. Ask for explicit user approval of that preview before executing any mutation. A request for Jira-ready content, export, or CSV is not approval to mutate Jira.
4. Execute only the approved operations. If the preview changes materially, show the revised preview and ask again.
5. Report created or updated issue keys, URLs when available, skipped operations, and failures after execution.

## Recommended Mapping

| Artifact | Jira Target |
|---|---|
| Roadmap initiative | Epic |
| User story | Story |
| Change affecting implementation | Comment plus label |
| Blocking dependency | Linked issue or blocker note |

## Change Governance

- Label affected tickets with `spec-changed-sprint[XX]` when a sprint change is accepted.
- Add a comment with summary, version, affected AC, and spec change context link.
- For rejected changes, comment with rejection rationale and owner.
