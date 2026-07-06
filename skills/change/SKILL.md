---
name: change
description: Manage requirement changes to existing PRDs, BRDs, specs, user stories, UAT, Jira tickets, Confluence pages, or release scope. Use when requirements change mid-flight, a stakeholder updates scope, a document needs controlled edits, spec versioning, surgical patching, impact analysis, changelog, notification, or AI context handoff.
---

# Change

Use this for controlled product requirement changes.

## Process

1. Identify the current baseline artifact.
2. Clarify the requested change.
3. Classify change impact: minor, material/medium, or breaking.
4. Assess impact on scope, stories, UAT, Jira tickets, Confluence pages, timeline, dependencies, risk, and release.
5. Draft a change plan and ask for confirmation before applying edits.
6. Apply surgical edits consistently across affected artifacts.
7. Ask `docs` to update changelog, spec context, and decision logs.
8. Ask `memories` to persist durable decisions.

## Required References

- `_refs/workflows/change-governance.md`
- `_refs/templates/change/change-plan.md`
- `_refs/templates/change/impact-analysis.md`
- `_refs/templates/change/changelog.md`
- `_refs/templates/change/spec-change-context.md`
- `_refs/integrations/jira.md`
- `_refs/integrations/confluence.md`

## Output

Return impact analysis, proposed edits, and changelog entries.
