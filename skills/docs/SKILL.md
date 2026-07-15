---
name: docs
description: Create, update, version, index, link, summarize, or export Annifity working artifacts under `.annifity/docs/`. Use as a supporting skill alongside PO workflows, or as the primary skill when the request is specifically document storage, indexing, versioning, or export. Use `knowledge` for read-only retrieval and `memories` for durable cross-session context rather than artifact management.
---

# Docs

Maintain the artifact store and index without changing the owning workflow's product decisions.

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

1. Resolve the intended target and inspect the existing artifact and index entry before writing.
2. Create a new artifact only when the target is absent; update or merge only when the existing target is unambiguous.
3. Never overwrite an unrelated, published, or versioned artifact. Surface content or path conflicts, preserve both versions, and ask before destructive replacement.
4. Preserve existing content, frontmatter, version history, and draft vs published state during a merge.
5. Add or update frontmatter following `_refs/schemas/doc-frontmatter.md`.
6. Update `.annifity/docs/index.md` using `_refs/templates/docs/docs-index.md` only after the artifact write succeeds.
7. Append decision, evidence, change, or traceability records when relevant.
8. Report exact paths changed.

## Reference Routing

Load only references needed for the artifact operation:

- For lifecycle or publication state, use `_refs/operating-model/artifact-lifecycle.md`.
- For session, decision, evidence, template, or release artifacts, use the matching template: `_refs/templates/docs/session-note.md`, `_refs/templates/docs/decision-log.md`, `_refs/templates/docs/decision-ledger.md`, `_refs/templates/docs/evidence-ledger.md`, `_refs/templates/docs/template-registry.md`, or `_refs/templates/docs/release-note.md`.
- For index changes, use `_refs/templates/docs/docs-index.md` and `_refs/schemas/artifact-index.md`.
- For document metadata, use `_refs/schemas/doc-frontmatter.md`.
- For decision or initiative records, use `_refs/schemas/decision-record.md` and/or `_refs/schemas/initiative-state.md`.

## Handoff

Return the exact artifact paths, versions, index links, and unresolved conflicts to the invoking workflow. Do not select a new product phase or change the owning workflow's decisions.
