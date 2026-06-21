---
name: user-story
description: Create, split, refine, review, or export user stories and acceptance criteria from a PRD, BRD, feature spec, or confirmed product plan. Use for INVEST stories, story maps, Jira-ready stories, Given/When/Then acceptance criteria, and story quality review.
---

# User Story

Use this after `po-plan` or when the user provides enough source context to write implementation-ready stories.

## Process

1. Confirm source artifact and target format.
2. Build or validate an epic/story map.
3. Write stories that are independent, valuable, small, and testable.
4. Write acceptance criteria in Given/When/Then unless the user asks otherwise.
5. Flag dependencies, open questions, and out-of-scope work.
6. Ask `docs` to save or export the stories.

## Required References

- `_refs/templates/user-story/default-user-story.md`
- `_refs/templates/user-story/jira-user-story.md`
- `_refs/templates/user-story/acceptance-criteria-gwt.md`
- `_refs/templates/user-story/story-map.md`
- `_refs/checklists/story-quality-invest.md`

## Output

Return stories grouped by epic with IDs, acceptance criteria, dependencies, and notes.
