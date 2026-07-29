# Artifact Lifecycle

Artifact lifecycle state is document publication state, not a product decision
or implementation status. Use the stable identity and field definitions in
`_refs/schemas/doc-frontmatter.md`.

## Draft

Create under `.annifity/docs/` with frontmatter and source context.

Draft edits do not increase document version unless the user explicitly asks.

For research-heavy or strategy artifacts, add evidence rows to `_refs/templates/docs/evidence-ledger.md` or the local evidence ledger.

## Review

Record reviewer feedback, blocking issues, and accepted risks.

For material handoffs, score the artifact with `_refs/checklists/artifact-quality-scorecard.md`.

## Baseline

Once approved, update the docs index, decision log when relevant, and the
artifact-state registry defined by
`_refs/schemas/artifact-state-registry.md`.

Baselined artifacts become change-controlled.

For initiative-level artifacts, update initiative state using `_refs/schemas/initiative-state.md`.

Only one `baselined` or `shipped` version may be the active baseline for a
stable `artifact_id`. A newer draft may be the latest version without becoming
the baseline.

## Change

Use `change` for controlled updates after baseline.

Increase version only for accepted published/spec changes, not for draft iteration.

When a replacement is accepted:

1. Record the new version and its SHA-256.
2. Mark the replaced version `superseded`.
3. Add the explicit supersession edge from the new version to its immediate
   predecessor.
4. Move the baseline pointer atomically to the new version.
5. Keep the latest pointer separate when a newer unaccepted draft exists.

Do not select a baseline from the newest filename, date, directory order, or
largest-looking version string. Resolve it using
`_refs/operating-model/authoritative-baseline-resolution.md`.

## Ship

Export final package and record post-ship decisions and lessons.

Record outcomes and lessons in memories after launch review.

`shipped` remains an active baseline state until another accepted version
supersedes it.

## Invalid States

Block downstream work when any of the following is true:

- two or more active baseline versions exist for one `artifact_id`;
- the registry points to a missing, modified, or superseded file;
- required stable identity, version, source, or lifecycle metadata is absent;
- a supersession edge references a missing version, crosses artifact identity,
  creates a cycle, or has more than one successor;
- a filename or index disagrees with the registry and no authoritative source
  resolves the conflict.
