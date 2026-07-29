# Confluence User Story Notes

Use when the user asks for a Confluence-ready story page.

## Section Selection

Always include User Story, the minimum context or flow needed to understand it, Acceptance Criteria, and Change Log.

Include Pre-condition, Alternative Flow, Business Rules, Dependencies, Out of Scope, and Design only when confirmed scope and `_refs/checklists/source-backed-minimality.md` make them relevant. Do not create empty or filler sections to match a generic page shape.

## Writing Rules

- Use Given/When/Then tables for acceptance criteria.
- Apply `_refs/checklists/acceptance-criteria-quality.md` and use stable AC IDs.
- Apply `_refs/checklists/source-backed-minimality.md` to the complete story page.
- Put confirmed validation failures, permission denial, and other user-visible failure behavior in acceptance criteria, not only edge cases.
- Keep Change Log append-only.
- For strict HTML table and link rules, use `_refs/integrations/confluence.md`.
