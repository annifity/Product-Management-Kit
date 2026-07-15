---
name: user-story
description: Create, split, refine, revise, or export ticket-ready Jira epic definitions, implementation-ready user stories, story maps, and acceptance criteria from a confirmed PRD, spec, roadmap item, or delivery plan. Use for INVEST splitting, Jira-ready tickets, and Given/When/Then criteria. Use `plan` for epic maps, sequencing, milestones, and dependencies; use `validate` for an independent story-quality/readiness verdict rather than authoring or correction.
---

# User Story

Decompose confirmed scope into small, testable delivery slices without changing its business intent.

## Input Contract

- Reuse supplied context and do not ask for information already present.
- Accept complete or partial input; ask only for gaps that materially affect scope, behavior, acceptance, or ticket structure, and label any assumptions used to continue.
- If confirmed source scope or delivery structure is missing, route to `spec` for scope and rules or `plan` for the epic map, sequencing, milestones, and dependencies before writing tickets.

## Boundary

Own ticket-ready Jira epic definitions, stories, and acceptance criteria. `plan` owns the delivery-level epic map, sequencing, milestones, and dependencies.

## Process

1. Confirm source artifact and target format.
2. Reuse the confirmed epic map or delivery plan when supplied; create only the ticket-level epic and story structure here.
3. Split large epics or stories before writing detailed implementation stories.
4. Write stories that are independent, valuable, small, and testable.
5. Write acceptance criteria in Given/When/Then unless the user asks otherwise.
6. Keep unhappy paths in acceptance criteria and reserve edge-case sections for technical edge cases.
7. Flag dependencies, open questions, and out-of-scope work.
8. Ask `docs` to save or export the stories.
9. For Jira mutations, follow the draft, preview, explicit-approval, execution, and result-reporting gate in `_refs/integrations/jira.md`; Jira-ready or export wording alone is not mutation approval.

## Reference Routing

Load only references needed for the requested story format and destination:

- For packaged handoff, use `_refs/operating-model/builder-packs.md`.
- For standard, Jira, epic, GWT, map, or Confluence output, use only the matching template: `_refs/templates/user-story/default-user-story.md`, `_refs/templates/user-story/jira-user-story.md`, `_refs/templates/user-story/jira-epic.md`, `_refs/templates/user-story/acceptance-criteria-gwt.md`, `_refs/templates/user-story/story-map.md`, or `_refs/templates/user-story/confluence-html.md`.
- For authoring quality or splitting decisions, use `_refs/checklists/story-quality-invest.md` and/or `_refs/checklists/story-splitting.md`.
- For requirement-to-story coverage, use `_refs/templates/traceability/rtm.md`.
- For collaborative story mapping, use `_refs/workflows/workshop-facilitation.md`.
- For external publishing, use `_refs/integrations/jira.md` and/or `_refs/integrations/confluence.md` only when that system is in scope.

## Output

Return stories grouped by epic with IDs, acceptance criteria, dependencies, and notes.

## Handoff

Hand off implementation-ready stories to `execution` and acceptance coverage to `uat`. The minimum ready package includes the source reference, ticket-ready epic and story definitions, acceptance criteria, dependencies, assumptions or open questions, and traceability IDs.
