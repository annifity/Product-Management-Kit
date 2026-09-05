# Local Mutation Safety

Use this workflow for local file creation, update, move, rename, deletion, ignore-rule changes, or generated-output refreshes. It provides Preview -> Confirm -> Apply protection and a post-change negative-completeness gate.

First use the `writeDisposition` from
`_refs/schemas/artifact-generation-contract.md`:

- `blocked`: do not preview or write;
- `confirmation-required`: run the complete workflow below;
- `allowed`: an explicit user request may authorize an unbaselined, reversible
  draft create/update at an unambiguous path; still verify the end state, and
  use the complete workflow if the operation becomes material.

Always require the complete Preview -> Confirm -> Apply workflow for a baseline
change, overwrite, move, rename, deletion, ignore-rule change, bulk operation,
or generated-output replacement.

## User-Facing Confirmation

Ask the user to approve the proposed action and its effect, not an internal
identifier.

- If approval also requires a product or business decision, apply the User
  Confirmation Clarity Gate in
  `_refs/checklists/material-decision-preflight.md` first. Keep the product
  decision separate from permission to edit files.
- Match the user's language.
- State the exact action, affected paths or item count, expected end state, and
  any destructive or baseline impact.
- Ask one direct question that can be answered naturally, such as `Có, hãy cập
  nhật` or `Không`.
- Never ask the user to read, repeat, paste, or approve a fingerprint, hash,
  `writeDisposition`, or profile-contract value.
- Keep fingerprints in the preview and confirmation tools as internal stale
  state protection. Bind the user's plain-language approval to the current
  preview fingerprint when invoking the tool.
- Do not ask again when the user's current request already explicitly
  authorizes an `allowed`, unbaselined, reversible draft create/update and the
  exact target is unambiguous.

Good:

> Tôi sẽ cập nhật 3 user story đang ở trạng thái draft và không thay đổi các
> bản đã finalize. Bạn xác nhận thực hiện chứ?

Avoid:

> Confirm fingerprint `sha256:...` for a `confirmation-required` mutation?

## 1. Bound The Mutation

1. Inspect `git status --short`.
2. Separate user-owned or unrelated changes from the requested scope.
3. Write a mutation-intent JSON document using `_refs/schemas/mutation-preview.md`.
4. List the exact source and target paths. Keep paths repository-relative and reject paths outside the workspace root.
5. State the intended operations and end state without embedding commands.

If the requested target, replacement, or ownership is ambiguous, stop and confirm it.

## 2. Preview

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/new-mutation-preview.ps1 `
  -IntentPath <intent.json> `
  -RootPath <workspace-root> `
  -OutputPath <preview.json>
```

The preview records deterministic SHA-256 hashes for:

- the canonical change intent;
- current source snapshots;
- current target snapshots;
- the reviewed patch or content-source mapping and exact expected after-state;
- the complete negative-completeness manifest;
- the combined preview fingerprint.

Review the operations, source and target states, expected negative-completeness
checks, and preview fingerprint internally. Show the user only the
human-readable action-and-impact summary unless they request technical
diagnostics. Preview generation does not apply an operation.

## 3. Confirm

Obtain explicit confirmation of the human-readable action-and-impact summary.
Use the fingerprint from that unchanged preview when running:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/confirm-mutation-preview.ps1 `
  -PreviewPath <preview.json> `
  -RootPath <workspace-root> `
  -ConfirmFingerprint <sha256>
```

Confirmation recomputes the intent and filesystem snapshots. A mismatched confirmation or stale source/target state fails closed. Regenerate and re-review the preview; never reuse stale approval.

The confirmation command is read-only for the workspace and emits a receipt to standard output. It does not create, update, move, or delete the declared paths.

## 4. Apply

Only after successful confirmation:

1. Apply exactly the confirmed operations and content bytes with the appropriate repository editing mechanism.
2. Do not touch unrelated dirty files.
3. If the requested operations change before application, discard the receipt and create a new preview.
4. Run the repository-specific sync only when canonical changes require it.

The preview and confirmation tools deliberately do not implement this step.

## 5. Verify The End State

The complete negative-completeness manifest and exact after-state are already
bound into the confirmed preview. After application, run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/verify-mutation-result.ps1 `
  -PreviewPath <preview.json> `
  -RootPath <workspace-root> `
  -ConfirmFingerprint <sha256>
```

The verifier rejects unexpected content, missing/extra targets, or a different
negative-completeness contract. Then inspect the scoped diff and
`git status --short`. Report exact-path results, residual-reference results,
matching ignore rule evidence, tests, and any intentionally retained
references.

## Stop Conditions

Stop without applying when:

- the preview fingerprint is stale or does not match the confirmed value;
- a source or target escapes the workspace root;
- a declared path is a symbolic link or reparse point;
- an unrelated dirty change overlaps the target;
- the negative-completeness contract is incomplete or contradictory;
- a destructive or external action requires authority not supplied by the user.
