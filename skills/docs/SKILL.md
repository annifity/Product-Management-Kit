---
name: docs
description: Create, update, version, index, link, summarize, or export Annifity working artifacts under `.annifity/docs/`. Use as a supporting skill alongside PO workflows, or as the primary skill when the request is specifically document storage, indexing, versioning, or export. Use `knowledge` for read-only retrieval and `memories` for durable cross-session context rather than artifact management.
---

# Docs

Maintain the artifact store and index without changing the owning workflow's product decisions.

## Input Contract

Reuse the supplied artifact, exact path, project, baseline, and requested operation. Ask only when target identity, write disposition, or destructive end state is material and unresolved. Never select a project template, baseline, or replacement path from filename recency alone.

## Storage Policy

Write generated user artifacts under `.annifity/docs/` unless the user requests another path:

- `.annifity/docs/index.md`
- `.annifity/docs/artifact-state-registry.json`
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

1. Resolve the artifact-generation contract, project profile, material decisions, target, and write disposition before writing.
2. For a governed existing artifact, resolve the authoritative baseline and latest pointer; block ambiguity instead of selecting by filename or date.
3. Inspect the existing artifact, registry, index entry, and dirty working-tree overlap.
4. Create a new artifact only when the target is absent; update or merge only when identity and target are unambiguous.
5. Use the local mutation-safety workflow for any confirmation-required operation and always for baseline change, overwrite, move, rename, deletion, ignore-rule change, bulk operation, or generated replacement.
6. Never overwrite an unrelated, published, or versioned artifact. Preserve content, frontmatter, history, and draft versus baseline state during a merge.
7. Add or update governed metadata and registry state only after the content write succeeds. If the resolved profile forbids frontmatter, use registry metadata instead of injecting YAML.
8. Update `.annifity/docs/index.md` only after the artifact and registry are consistent.
9. For removal, move, rename, ignore, or scope-narrowing work, run negative completeness against the declared end state.
10. Append decision, evidence, change, or traceability records when relevant and report exact paths, versions, fingerprints, and verification evidence.

## Reference Routing

Load only references needed for the artifact operation:

- For project-specific generation rules, use `_refs/schemas/artifact-generation-contract.md` with `_refs/operating-model/artifact-profile-resolution.md` and `_refs/checklists/material-decision-preflight.md`.
- For lifecycle or publication state, use `_refs/operating-model/artifact-lifecycle.md`, `_refs/schemas/artifact-state-registry.md`, and `_refs/operating-model/authoritative-baseline-resolution.md`.
- For protected local writes, use `_refs/workflows/local-mutation-safety.md` with `_refs/schemas/mutation-preview.md`; for remove, move, rename, ignore, or narrowing verification, use `_refs/checklists/negative-completeness.md`.
- For whole-artifact pruning before storage, use `_refs/checklists/source-backed-minimality.md`.
- For a Draw.io handoff, validate the exact diagram, linked sources, and removed/stale labels through `_refs/schemas/drawio-validation-manifest.md` before reporting it as usable.
- For session, decision, evidence, template, or release artifacts, use the matching template: `_refs/templates/docs/session-note.md`, `_refs/templates/docs/decision-log.md`, `_refs/templates/docs/decision-ledger.md`, `_refs/templates/docs/evidence-ledger.md`, `_refs/templates/docs/template-registry.md`, or `_refs/templates/docs/release-note.md`.
- For the companion contract evidence returned with any authored artifact, use `_refs/templates/docs/generation-receipt.md`; keep it outside the artifact when the project profile forbids embedded metadata.
- For index changes, use `_refs/templates/docs/docs-index.md` and `_refs/schemas/artifact-index.md`.
- For document metadata, use `_refs/schemas/doc-frontmatter.md`.
- For decision or initiative records, use `_refs/schemas/decision-record.md` and/or `_refs/schemas/initiative-state.md`.

## Output

Return the requested artifact operation result with exact target identity, path, version, lifecycle, baseline/latest pointer state, content hash, index impact, generation receipt, and verification evidence. For a blocked or preview-only operation, return diagnostics and planned effects without implying that a write occurred.

## Handoff

Return the exact artifact paths, versions, index links, generation receipt, and unresolved conflicts to the invoking workflow. Do not select a new product phase or change the owning workflow's decisions.
