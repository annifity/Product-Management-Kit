# Artifact Profile Resolution

Resolve an artifact profile before any skill drafts, revises, baselines,
publishes, or exports a product artifact. The resolver prevents generic defaults
from silently overriding supplied project context.

## Resolution Sequence

1. Identify `project`, `artifactType`, intended `action`, and required profile
   keys through `_refs/checklists/material-decision-preflight.md`.
2. Collect only relevant structured sources. Do not infer a value from unrelated
   prose.
3. Validate that accepted decisions have an accepted status and resolve
   controlled baselines through
   `_refs/operating-model/authoritative-baseline-resolution.md`.
4. Resolve each property using the precedence table.
5. Detect same-level disagreements, locked-value changes, missing required
   values, and unresolved material questions.
6. Produce generation context, provenance, conflicts, blockers, fingerprint,
   and write disposition.
7. Draft only when disposition permits it. Re-resolve before applying a
   previously confirmed preview.

## Precedence

Higher ranks win. The rank within a tier makes the result deterministic while
retaining the requested broad precedence.

| Tier | Rank | Layer | Selection rule |
|---:|---:|---|---|
| 1 | 900 | `explicit-request` | Direct user instruction in the active request |
| 2 | 800 | `accepted-decision` | Accepted decision that applies to this artifact |
| 2 | 790 | `accepted-baseline` | Accepted or baselined source artifact |
| 3 | 700 | `artifact-profile` | Artifact-specific project profile |
| 3 | 690 | `project-profile` | Project-wide profile |
| 3 | 680 | `team-preferences` | Durable team preference |
| 4 | 600 | `terminology` | Confirmed term or definition |
| 4 | 590 | `open-questions` | Confirmed constraint plus unresolved question state |
| 5 | 100 | `canonical-fallback` | Annifity default used only when no higher source supplies a value |

Array order never affects selection. Sources with the same rank are ordered by
source ID for reproducible diagnostics, but differing values at that rank create
a conflict rather than a silent tie-break.

## Decision Rules

### Normal override

When a higher-ranked source differs from a lower-ranked source, select the
higher-ranked value and record an informational `precedence-override`.

### Accepted-value change

If an explicit request changes a material or locked accepted decision/baseline:

- without `changeAuthorized` and `changeEvidence`, resolve the requested value
  for preview but set disposition to `blocked`;
- with authorization evidence, set disposition to
  `confirmation-required` and route the actual baseline change through
  `change`.

Precedence determines the proposed value. Governance determines whether it may
be written.

### Same-rank disagreement

- Material key: block.
- Non-material key: select by stable source ID, report a warning, and require
  confirmation.

### Open question

Never treat a proposed answer in an open question as confirmed behavior. A
material open question blocks until an explicit-request, accepted-decision, or
accepted-baseline source lists its ID under `resolvesQuestions` and supplies
the affected values. Profiles, preferences, fallbacks, and bare top-level IDs
cannot resolve questions. A non-material open question requires confirmation
and remains visible in the result.

### Missing value

Every key in `requiredKeys` must resolve. A missing required value is a material
conflict and blocks drafting.

## Write Dispositions

| State | Meaning | Required action |
|---|---|---|
| `allowed` | No unresolved material conflict or confirmation gate | Proceed using the exact resolved profile |
| `confirmation-required` | The profile is deterministic but contains a warning, non-material open question, or authorized baseline change | Show preview and fingerprint; obtain confirmation |
| `blocked` | A material conflict, unresolved material question, or required-value gap exists | Resolve authority or route committed-scope change to `change` |

The resolver does not create or modify the target artifact. It only establishes
the contract a later write must follow through
`_refs/workflows/local-mutation-safety.md`.

## Provenance And Fingerprint

For each key, retain the selected source and every lower-ranked source whose
value was different. Sort keys, sources, conflicts, and questions before
fingerprinting. The fingerprint covers:

- project, artifact type, and action;
- consumer, deliverable mode, source authority, baseline target, constraints,
  and material decisions;
- resolved property values;
- selected provenance;
- conflicts, blockers, and open questions;
- write disposition and change evidence.

Do not include time, machine paths, source-array order, or other volatile data.

## Failure Modes

| Failure | Signal | Consequence | Correction | Prevention |
|---|---|---|---|---|
| Prompt-only profile | Output follows remembered prose but has no provenance | Project rules are applied inconsistently | Create structured profile values and resolve them | Require a resolver fingerprint before drafting |
| Draft treated as authority | A draft decision overrides an accepted baseline | Unapproved behavior enters delivery scope | Reject the source status and use an accepted source | Validate accepted-layer statuses |
| Silent baseline rewrite | Explicit request changes a locked field and writing continues | Committed scope changes without governance | Block or require authorized change evidence | Mark material keys and accepted locks |
| Source-order tie break | Reordering source files changes output | Reproduction and tests become unreliable | Sort by rank and source ID; report same-rank conflict | Compare fingerprints from reordered fixtures |
| Stale confirmation | A preview is confirmed after its context changed | Written artifact differs from reviewed preview | Resolve again and compare fingerprint | Store fingerprint with preview and confirmation |

## Handoff

- `allowed`: pass `resolvedProfile`, `provenance`, and `fingerprint` to the
  authoring skill.
- `confirmation-required`: pass the same package to the preview/confirmation
  gate.
- `blocked` by accepted-scope conflict: pass the conflict and affected keys to
  `change`.
- `blocked` by missing authority or open question: return the smallest material
  question to the user or source owner.
- For every disposition, return the compact generation receipt defined in
  `_refs/templates/docs/generation-receipt.md`; a blocked receipt records the
  exact blockers and must not be presented as approval to draft or mutate.
