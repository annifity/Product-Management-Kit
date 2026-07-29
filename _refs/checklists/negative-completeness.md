# Negative Completeness

Use this gate after a request removes, ignores, renames, moves, or narrows repository content. A successful write or delete is not sufficient evidence that the requested end state exists.

## Required Evidence

Record all checks in a JSON manifest and run `tools/test-negative-completeness.ps1`.

1. **Exact paths**: name every path that must be present or absent. For present paths, state whether any item, a file, or a directory is required.
2. **Residual references**: search the smallest relevant roots for obsolete names, paths, identifiers, or instructions. Use an absent expectation for forbidden references and a present expectation for a required replacement.
3. **Git-ignore behavior**: use `git check-ignore --no-index -v` evidence for paths that must be ignored or not ignored. A line in `.gitignore` without matching evidence is not enough.
4. **Repository state**: inspect `git status --short` and the scoped diff. Preserve unrelated user changes.
5. **Generated surfaces**: when a canonical source affects generated adapters or catalogs, verify the generated outputs according to the repository workflow.

Do not silently broaden search roots, infer an unspecified replacement, or treat an ignored path as deleted.

## Manifest Contract

Paths and search roots are relative to the supplied workspace root. Absolute paths and paths that escape that root are rejected.

```json
{
  "schemaVersion": 1,
  "exactPaths": [
    { "path": "obsolete.md", "expected": "absent" },
    { "path": "README.md", "expected": "present", "kind": "file" }
  ],
  "residualReferences": [
    {
      "pattern": "obsolete\\.md",
      "expected": "absent",
      "searchPaths": ["skills", "_refs"],
      "includeGlobs": ["*.md"],
      "excludePaths": []
    },
    {
      "pattern": "replacement.md",
      "expected": "present",
      "searchPaths": ["README.md"],
      "minimumMatches": 1
    }
  ],
  "gitIgnore": [
    { "path": ".annifity/docs/example.md", "expected": "ignored" },
    { "path": "tests/fixtures/example.json", "expected": "not-ignored" }
  ]
}
```

Residual patterns are regular expressions by default and are matched case-insensitively. Set `fixedString` or `caseSensitive` to `true` when required. `includeGlobs` and `excludePaths` use repository-relative wildcard patterns. An absent reference must have zero matching lines. A present reference defaults to at least one matching line and may declare `minimumMatches` or `maximumMatches`.

## Verdict

- **Pass**: every exact-path, residual-reference, and ignore check matches its declared expectation and evidence is reported.
- **Fail**: any expected item is missing, forbidden item remains, required reference is absent, ignore behavior differs, or a check cannot run.
- **Blocked**: the intended end state or search boundary is ambiguous. Confirm it before mutation.

