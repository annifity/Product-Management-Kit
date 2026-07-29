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

1. Run the material-decision preflight to resolve source authority, project constraints, story mode, baseline target, and behavior ownership.
2. Reuse the confirmed epic map or delivery plan when supplied; create only the ticket-level epic and story structure here.
3. Confirm the responsibility preview before splitting or merging stories, then split only independently valuable delivery slices.
4. Write stories that are independent, valuable, small, and testable.
5. Write source-aligned acceptance criteria that pass `_refs/checklists/acceptance-criteria-quality.md`; use Given/When/Then unless the user asks otherwise.
6. Cover only relevant success, business-rule, validation, permission, boundary, state, and user-visible failure behavior. Keep implementation-only technical edge cases outside AC and do not invent behavior for checklist completeness.
7. Apply source-backed minimality; include dependencies, open questions, and out-of-scope work only when relevant and sourced.
8. Ask `docs` to save or export the stories.
9. For Jira mutations, follow the draft, preview, explicit-approval, execution, and result-reporting gate in `_refs/integrations/jira.md`; Jira-ready or export wording alone is not mutation approval.

## Reference Routing

Load only references needed for the requested story format and destination:

- For packaged handoff, use `_refs/operating-model/builder-packs.md`.
- Before authoring or slicing, resolve `_refs/schemas/artifact-generation-contract.md` through `_refs/operating-model/artifact-profile-resolution.md`, then use `_refs/checklists/material-decision-preflight.md`; before handoff, use `_refs/checklists/source-backed-minimality.md`.
- When deriving or revising stories from a governed PRD, spec, plan, or story, resolve `_refs/operating-model/authoritative-baseline-resolution.md`; never choose by filename or date.
- For standard, Jira, epic, map, or Confluence output, use only the matching template: `_refs/templates/user-story/default-user-story.md`, `_refs/templates/user-story/jira-user-story.md`, `_refs/templates/user-story/jira-epic.md`, `_refs/templates/user-story/story-map.md`, or `_refs/templates/user-story/confluence-html.md`.
- For criterion-level AC authoring or repair, use `_refs/checklists/acceptance-criteria-quality.md` with `_refs/templates/user-story/acceptance-criteria-gwt.md`.
- For story-level INVEST quality or splitting decisions, use `_refs/checklists/story-quality-invest.md` and/or `_refs/checklists/story-splitting.md`.
- For requirement-to-story coverage, use `_refs/templates/traceability/rtm.md`.
- For collaborative story mapping, use `_refs/workflows/workshop-facilitation.md`.
- For external publishing, use `_refs/integrations/jira.md` and/or `_refs/integrations/confluence.md` only when that system is in scope.

## Output

Return the smallest project-profile-compliant ticket structure plus the compact generation receipt from the resolved contract. Group by epic only when an epic is confirmed. Use a confirmed ID or an explicit `TBD` placeholder; never synthesize a project code, Jira key, release, or label. Include dependencies, exclusions, design links, and open-question notes only when they are sourced and material to the ticket.

## Handoff

Hand off implementation-ready stories to `execution` and acceptance coverage to `uat`. The minimum ready package includes the source reference, ticket-ready story definition, stable source-aligned acceptance-criteria IDs, applicable confirmed dependencies, material assumptions or open questions, and required traceability IDs. Do not add empty sections to satisfy this list.
