---
name: docs
description: Maintain Annifity working documents automatically. Use alongside every PO workflow to create, update, index, export, summarize, version, and link PRDs, BRDs, specs, user stories, UAT cases, decision logs, decision ledger records, changelogs, templates, session notes, release documents, and traceability artifacts in `.annifity/docs/`.
---

# Docs

Use this as the documentation habit for Annifity workflows.

## Storage Policy

Write generated user artifacts under `.annifity/docs/` unless the user requests another path:

- `.annifity/docs/index.md`
- `.annifity/docs/prd/`
- `.annifity/docs/specs/`
- `.annifity/docs/brd/`
- `.annifity/docs/user-stories/`
- `.annifity/docs/uat/`
- `.annifity/docs/decisions/`
- `.annifity/docs/evidence/`
- `.annifity/docs/traceability/`
- `.annifity/docs/templates/`
- `.annifity/docs/changelog/`
- `.annifity/docs/exports/`

## Process

1. Save or update the artifact.
2. Add frontmatter following `_refs/schemas/doc-frontmatter.md`.
3. Update `.annifity/docs/index.md` using `_refs/templates/docs/docs-index.md`.
4. Append decision, evidence, change, or traceability records when relevant.
5. Preserve draft vs published/versioned state.
6. Report exact paths changed.

## Required References

- `_refs/operating-model/artifact-lifecycle.md`
- `_refs/templates/docs/session-note.md`
- `_refs/templates/docs/decision-log.md`
- `_refs/templates/docs/decision-ledger.md`
- `_refs/templates/docs/evidence-ledger.md`
- `_refs/templates/docs/template-registry.md`
- `_refs/templates/docs/docs-index.md`
- `_refs/templates/docs/release-note.md`
- `_refs/schemas/doc-frontmatter.md`
- `_refs/schemas/artifact-index.md`
- `_refs/schemas/decision-record.md`
- `_refs/schemas/initiative-state.md`
