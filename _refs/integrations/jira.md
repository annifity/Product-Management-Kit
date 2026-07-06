# Jira Integration Notes

- Ask for project key before creating or referencing issues.
- Keep story summary short and user-facing.
- Put acceptance criteria in the description unless the workspace has a dedicated field.
- Preserve issue keys exactly.
- If no connector is available, produce CSV-ready output.

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
