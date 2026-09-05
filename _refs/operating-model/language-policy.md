# Language Policy

- Reply in the user's language unless they ask otherwise.
- Keep product terms consistent with memory terminology.
- Do not translate proper nouns, product names, team names, Jira keys, URLs, or code identifiers.
- When translating artifacts, preserve Markdown structure and tables.
- If mixed Vietnamese and English terms exist, keep the term used by the team.

## User-Facing Technical Boundary

- Describe artifact operations as the completed action, target, source/version
  in human-readable form, effect on any approved version, blocker, and next
  action.
- Do not label the default response a generation receipt, resolver result, or
  technical audit.
- Keep raw hashes, fingerprints, `writeDisposition`, `resolvedProfile`, internal
  source IDs, and profile-contract details internal unless the user explicitly
  asks for diagnostics or an audit/export requires them.
- Explain stale-state mismatches in plain language by naming what changed and
  which action must be repeated; do not expose raw comparison values.
- Translate internal phase and skill labels into the business action they
  perform. A code-form skill name may follow that explanation when it helps the
  user invoke the next step; never make the label carry the meaning by itself.
- Take displayed artifact identity and version from authoritative resolution or
  declared document metadata, never from filenames, changelogs, or provenance
  prose.
- When technical evidence is explicitly requested, first explain its practical
  meaning; never ask a business user to approve or repeat a machine identifier.
