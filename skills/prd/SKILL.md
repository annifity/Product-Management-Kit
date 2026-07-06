---
name: prd
description: Create, revise, review, translate, or export Product Requirement Documents and BRD-style requirement artifacts. Use when the user asks for a PRD, BRD, one-pager, product requirements document, product spec document, PRD/BRD review, translation, export, Confluence-ready document, or strict Confluence HTML.
---

# PRD

Use this for PRD and BRD-style artifacts. For fuzzy ideas, start with `po-brainstorming`; for detailed requirements, use the confirmed `po-spec` output.

## Process

1. Confirm whether the user needs draft, revision, review, translation, or export.
2. Read relevant docs and memories.
3. Select the correct artifact type: BRD, PRD, one-pager, Confluence HTML, or export package.
4. Use the selected template or default to `_refs/templates/prd/default-prd.md`.
5. Preserve explicit assumptions and open questions instead of inventing facts.
6. Ask for confirmation before publishing/exporting.
7. Ask `docs` to save the artifact and update the docs index.

## Required References

- `_refs/templates/prd/default-prd.md`
- `_refs/templates/prd/one-pager.md`
- `_refs/templates/prd/confluence-html.md`
- `_refs/templates/prd/confluence-html-strict.md`
- `_refs/templates/prd/prd-export-html.html`
- `_refs/templates/brd/default-brd.md`
- `_refs/templates/metrics/metric-tree.md`
- `_refs/templates/strategy/market-sizing.md`
- `_refs/templates/strategy/company-research-brief.md`
- `_refs/templates/docs/template-registry.md`
- `_refs/checklists/spec-quality.md`
- `_refs/checklists/business-analysis.md`
- `_refs/checklists/finance-metrics.md`
- `_refs/workflows/research-evidence.md`
- `_refs/integrations/confluence.md`

## Output

Return the PRD or BRD in Markdown unless the user requests another format.
