# Generation Result

Return a short, localized result alongside an authored artifact or preview.
Describe the outcome in product-document language, not resolver terminology.
Do not label this user-facing summary with resolver or audit terminology. Embed
it inside the artifact only when the resolved project profile requires metadata;
otherwise keep it in the handoff response.

## User-Facing Result

| Field | Value |
|---|---|
| Result | Created / updated / preview only / blocked |
| Target | Exact artifact ID, version, or path |
| Sources used | Human-readable authoritative source names |
| Baseline impact | New draft / draft updated / new baseline / no baseline change |
| Decisions applied | Only material decisions relevant to the result |
| Needs attention | None or the exact user decision required |

Keep this result compact. Omit fields that do not help the user review the
outcome. Do not expose internal resolver fields, machine-state labels, raw
hashes, profile data, context IDs, or confirmation tokens. Translate internal
state into its practical meaning: what happened, what artifact was affected,
whether an accepted baseline changed, and what the user needs to decide.

Use source IDs, versions, and lifecycle only from an authoritative resolution.
If no accepted source can be resolved, label the document identity as a
candidate and take it from declared identity metadata, never from a filename,
title, changelog, or provenance/source prose.

Persist required audit evidence separately according to
`_refs/schemas/artifact-generation-contract.md`. Do not copy that machine record
into this result unless the user explicitly requests technical diagnostics or
an audit export. Never ask the user to read, repeat, paste, or approve a machine
identifier. This result does not itself approve a baseline, external publish,
or mutation.
