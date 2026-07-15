---
name: prd
description: Create, revise, translate, or export a formal PRD, BRD, requirements one-pager, Confluence-ready requirements page, or PRD from PRO plus client feedback. Use for direct revisions only while the artifact is draft/unbaselined or accepted scope remains unchanged; route committed baseline, scope, acceptance, or user-visible behavior changes to `change`. Use `brief` for a pre-delivery alignment one-pager, `spec` for the detailed delivery source of truth, and `validate` for an independent readiness verdict.
---

# PRD

Produce stakeholder-facing requirements artifacts that remain consistent with the canonical delivery source of truth.

Use `PRD from PRO + Client Feedback` when the user is in Prototype First Workflow and provides PRO, prototype behavior, client/user feedback, validation result, learning summary, or stakeholder decision. In this mode, the PRD must separate what was validated, what changed after feedback, what remains assumption, and what is ready for delivery specification.

## Process

1. Confirm whether the user needs a draft, direct revision, translation, or export; route an independent readiness verdict to `validate` and any revision that changes a committed baseline, scope, acceptance, or user-visible behavior to `change`.
2. Read relevant docs and memories.
3. Select the correct artifact type: BRD, PRD, PRD from PRO + Client Feedback, one-pager, Confluence HTML, or export package.
4. Use the selected template or default to `_refs/templates/prd/default-prd.md`.
5. Preserve explicit assumptions and open questions instead of inventing facts.
6. Ask for confirmation before publishing/exporting.
7. Ask `docs` to save the artifact and update the docs index.

## Reference Routing

Load only references needed for the requested artifact and format:

- For ambiguous routing, use `_refs/operating-model/routing.md`.
- For a standard PRD, BRD, or requirements one-pager, use exactly the matching base template: `_refs/templates/prd/default-prd.md`, `_refs/templates/brd/default-brd.md`, or `_refs/templates/prd/one-pager.md`.
- For PRD from prototype feedback, use `_refs/workflows/prototype-first.md`, `_refs/templates/prd/prd-from-pro-feedback.md`, and `_refs/templates/prototype/prototype-feedback-summary.md`.
- For Confluence or HTML export, use the requested format only: `_refs/templates/prd/confluence-html.md`, `_refs/templates/prd/confluence-html-strict.md`, or `_refs/templates/prd/prd-export-html.html`; use `_refs/integrations/confluence.md` only for Confluence interaction.
- For template registration, use `_refs/templates/docs/template-registry.md`.
- For metrics, market size, company research, or finance content, use `_refs/templates/metrics/metric-tree.md`, `_refs/templates/strategy/market-sizing.md`, `_refs/templates/strategy/company-research-brief.md`, `_refs/checklists/finance-metrics.md`, and `_refs/workflows/research-evidence.md` selectively.
- For requirements quality, analysis, or stakeholder governance while drafting, use `_refs/checklists/spec-quality.md`, `_refs/checklists/business-analysis.md`, and `_refs/checklists/stakeholder-governance.md` only where relevant.

## Output

Return the PRD or BRD in Markdown unless the user requests another format.

## Handoff

Move to `spec` with the confirmed PRD or BRD, evidence, scope boundaries, assumptions, and open questions; route later committed baseline changes to `change`.
