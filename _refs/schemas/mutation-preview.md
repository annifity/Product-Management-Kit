# Mutation Preview Schema

This schema defines the deterministic request, preview, and confirmation receipt used by `tools/new-mutation-preview.ps1` and `tools/confirm-mutation-preview.ps1`.

## Intent Input

```json
{
  "schemaVersion": 1,
  "intent": "Remove an obsolete workflow and its references.",
  "sources": ["workspace/workflows/obsolete.md", "review/change.SKILL.md"],
  "targets": ["workspace/workflows/obsolete.md", "skills/change/SKILL.md"],
  "changes": [
    {
      "operation": "delete",
      "path": "workspace/workflows/obsolete.md",
      "reason": "Remove the obsolete workflow."
    },
    {
      "operation": "update",
      "path": "skills/change/SKILL.md",
      "contentSource": "review/change.SKILL.md",
      "reason": "Remove the canonical route."
    }
  ],
  "expectedAfter": [
    {
      "path": "workspace/workflows/obsolete.md",
      "state": "absent"
    },
    {
      "path": "skills/change/SKILL.md",
      "state": "file",
      "sha256": "<sha256-of-review/change.SKILL.md>"
    }
  ],
  "negativeCompleteness": {
    "schemaVersion": 1,
    "exactPaths": [
      {
        "path": "workspace/workflows/obsolete.md",
        "expected": "absent"
      },
      {
        "path": "skills/change/SKILL.md",
        "expected": "present",
        "kind": "file"
      }
    ],
    "residualReferences": [
      {
        "pattern": "obsolete\\.md",
        "expected": "absent",
        "searchPaths": ["skills", "_refs"]
      }
    ]
  }
}
```

Required fields are `schemaVersion`, `intent`, `sources`, `targets`, `changes`,
`expectedAfter`, and `negativeCompleteness`. Version must be `1`. Paths are
unique, repository-relative, slash-normalized, and contained by the supplied
workspace root.

Each content mutation (`create`, `update`, `overwrite`, `ignore-update`, or
`generated-replace`) requires exactly one of:

- `contentSource`: a reviewed file listed in `sources`; its SHA-256 must equal
  the target's expected-after hash; or
- `proposedPatch`: the exact human-reviewable patch text, with the expected
  target SHA-256 declared separately.

Delete requires an absent after-state. Move or rename requires exact `from` and
`to` paths. Every target has exactly one `expectedAfter` record with state and,
for a file or directory, SHA-256. `negativeCompleteness` is the complete
schema-versioned manifest later executed from this same confirmed preview.
Unknown intent fields are retained and fingerprinted.

The tools do not interpret or execute operations. The declared changes are an approval contract, not shell commands.

## Generated Preview

```json
{
  "schemaVersion": 1,
  "algorithm": "SHA-256",
  "changeIntent": {},
  "snapshots": {
    "sources": [],
    "targets": []
  },
  "expectedAfter": [],
  "hashes": {
    "intentSha256": "<64 lowercase hex>",
    "sourcesSha256": "<64 lowercase hex>",
    "targetsSha256": "<64 lowercase hex>",
    "expectedAfterSha256": "<64 lowercase hex>",
    "fingerprint": "<64 lowercase hex>"
  }
}
```

Each snapshot contains a normalized path, state (`absent`, `file`, or `directory`), and SHA-256 hash. A directory hash covers the sorted relative path, type, and hash of every descendant. Symbolic links and reparse points are rejected.

Canonical JSON sorts object keys ordinally, preserves array order, uses UTF-8, and excludes timestamps and absolute workspace paths. The combined fingerprint hashes these lines exactly:

```text
schemaVersion=1
intentSha256=<hash>
sourcesSha256=<hash>
targetsSha256=<hash>
expectedAfterSha256=<hash>
```

Identical intent and workspace state therefore produce an identical preview on repeat runs.

## Confirmation Receipt

Confirmation requires the caller-supplied fingerprint from the internally bound
preview to equal the recorded fingerprint and a fresh recomputation to equal all
recorded hashes. The user's natural-language approval authorizes the
human-readable action-and-impact summary; the user must not be asked to supply
or repeat the fingerprint.

```json
{
  "schemaVersion": 1,
  "status": "confirmed",
  "algorithm": "SHA-256",
  "fingerprint": "<64 lowercase hex>",
  "intentSha256": "<64 lowercase hex>",
  "sourcesSha256": "<64 lowercase hex>",
  "targetsSha256": "<64 lowercase hex>",
  "expectedAfterSha256": "<64 lowercase hex>"
}
```

The receipt contains no timestamp and is deterministic. It is emitted to standard output; the confirmation tool does not write into the workspace or apply the mutation.

## Post-Apply Verification

Run `tools/verify-mutation-result.ps1` with the confirmed fingerprint after the
apply step. It compares every actual target state and SHA-256 with
`expectedAfter`, then executes the exact `negativeCompleteness` manifest bound
inside the preview. A different manifest or resulting content cannot pass.
