---
name: prd
description: Create, revise, review, translate, or export Product Requirement Documents. Use when the user asks for a PRD, PRD draft, PRD review, product requirements document, product spec document, PRD translation, PRD export, or Confluence-ready PRD.
---

# PRD

Use this for PRD artifacts. For fuzzy ideas, start with `po-brainstorming`; for detailed requirements, use the confirmed `po-spec` output.

## Process

1. Confirm whether the user needs draft, revision, review, translation, or export.
2. Read relevant docs and memories.
3. Use the selected template or default to `_refs/templates/prd/default-prd.md`.
4. Preserve explicit assumptions and open questions instead of inventing facts.
5. Ask for confirmation before publishing/exporting.
6. Ask `docs` to save the PRD and update the docs index.

## Required References

- `_refs/templates/prd/default-prd.md`
- `_refs/templates/prd/one-pager.md`
- `_refs/templates/prd/confluence-html.md`
- `_refs/templates/prd/prd-export-html.html`
- `_refs/checklists/spec-quality.md`

## Output

Return the PRD in Markdown unless the user requests another format.
