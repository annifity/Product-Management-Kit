---
name: user-story
description: Create, split, refine, review, map, or export user stories, epics, acceptance criteria, story maps, Jira tickets, and Confluence-ready story pages from a PRD, BRD, feature spec, roadmap item, or confirmed product plan. Use for INVEST stories, story splitting, epic breakdown, story maps, Jira-ready stories, Given/When/Then acceptance criteria, and story quality review.
---

# User Story

Use this after `plan` or when the user provides enough source context to write implementation-ready stories.

## Process

1. Confirm source artifact and target format.
2. Build or validate an epic/story map.
3. Split large epics or stories before writing detailed implementation stories.
4. Write stories that are independent, valuable, small, and testable.
5. Write acceptance criteria in Given/When/Then unless the user asks otherwise.
6. Keep unhappy paths in acceptance criteria and reserve edge-case sections for technical edge cases.
7. Flag dependencies, open questions, and out-of-scope work.
8. Ask `docs` to save or export the stories.

## Required References

- `_refs/templates/user-story/default-user-story.md`
- `_refs/templates/user-story/jira-user-story.md`
- `_refs/templates/user-story/jira-epic.md`
- `_refs/templates/user-story/acceptance-criteria-gwt.md`
- `_refs/templates/user-story/story-map.md`
- `_refs/templates/user-story/confluence-html.md`
- `_refs/checklists/story-quality-invest.md`
- `_refs/checklists/story-splitting.md`
- `_refs/workflows/workshop-facilitation.md`
- `_refs/integrations/jira.md`
- `_refs/integrations/confluence.md`

## Output

Return stories grouped by epic with IDs, acceptance criteria, dependencies, and notes.
