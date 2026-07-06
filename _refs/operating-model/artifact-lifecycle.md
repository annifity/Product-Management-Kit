# Artifact Lifecycle

## Draft

Create under `.annifity/docs/` with frontmatter and source context.

Draft edits do not increase document version unless the user explicitly asks.

For research-heavy or strategy artifacts, add evidence rows to `_refs/templates/docs/evidence-ledger.md` or the local evidence ledger.

## Review

Record reviewer feedback, blocking issues, and accepted risks.

For material handoffs, score the artifact with `_refs/checklists/artifact-quality-scorecard.md`.

## Baseline

Once approved, update docs index and decision log.

Baselined artifacts become change-controlled.

For initiative-level artifacts, update initiative state using `_refs/schemas/initiative-state.md`.

## Change

Use `change` for controlled updates after baseline.

Increase version only for accepted published/spec changes, not for draft iteration.

## Ship

Export final package and record post-ship decisions and lessons.

Record outcomes and lessons in memories after launch review.
