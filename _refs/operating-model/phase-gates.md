# Phase Gates

Use `_refs/schemas/initiative-state.md` when a phase gate changes the durable
state of an initiative. Resolve approval reuse with
`tools/resolve-phase-gate-approval.ps1`; a remembered answer or prior chat turn
is not an approval record.

## Stable Gate IDs

Gate IDs identify the readiness decision, not a particular downstream route.
Keep them unchanged when wording or the next recommended skill changes.

| Gate | Stable ID |
|---|---|
| Discovery | `phase.discovery.ready` |
| Brief | `phase.brief.ready` |
| Prototype | `phase.prototype.ready` |
| Experiment | `phase.experiment.ready` |
| Validate | `phase.validate.ready` |
| Learn | `phase.learn.ready` |
| Strategy | `phase.strategy.ready` |
| Spec | `phase.spec.ready` |
| Design | `phase.design.ready` |
| Plan | `phase.plan.ready` |
| Execution | `phase.execution.ready` |
| Ship | `phase.ship.ready` |

## Approval Reuse

An approval is reusable only when all of these remain true:

- the stable gate ID matches;
- the source, artifact-profile, evidence, and material-question fingerprints
  produce the same gate fingerprint;
- the complete approval record has a valid HMAC-SHA256 attestation from the
  currently configured environment key;
- the recorded decision is `approved` and its status is `active`;
- the approval has not expired, been revoked, been superseded, or received an
  invalidation event;
- no unresolved material question remains.

Supply `asOf` explicitly when resolving expiry. Never use wall-clock time inside
the resolver. If any fingerprint changes, require a fresh decision even when
the prose appears equivalent.

Create the unsigned record described in `_refs/schemas/initiative-state.md`,
then attest it with `tools/sign-phase-gate-approval.ps1`. The signer and resolver
read `ANNIFITY_PHASE_GATE_APPROVAL_HMAC_KEY_ID` and the Base64 secret
`ANNIFITY_PHASE_GATE_APPROVAL_HMAC_KEY` from the process environment. Never
accept key material from request JSON or CLI arguments, and never persist or
print it. Only the signed approval record may cross the process boundary.

The resolver fails closed when the attestation is absent, malformed, signed by
the wrong secret, or names a key ID other than the active one. Missing, invalid,
and unknown key states remain distinct stable reason codes. After rotation,
re-sign any approval that still needs reuse; do not keep an old key in approval
data or repository files.

Before asking for a phase-transition decision, resolve the matching stable gate
ID and current fingerprint. Continue without repeating the question only when
the resolver returns a reusable approval. Ask for a fresh decision when no
record exists, the resolver rejects it, the fingerprint changed, or a material
question remains. Approval reuse authorizes only the phase transition; it never
authorizes a separate file mutation, publication, external write, or release.

## User-Facing Boundary

Keep approval bindings, attestations, hashes, resolver states, reason codes, and
machine identifiers internal. Tell the user whether the phase can proceed, what
changed since any prior approval, which product decision remains open, and what
happens next. Never ask the user to read, repeat, paste, or approve a machine
identifier.

## Material Question Protocol

Ask one material question per turn by default. Ask two or three only when the
user explicitly requests a batch and the selected questions have no unresolved
dependencies on one another. Never ask more than three in one turn. Keep
dependent questions deferred until their prerequisites are resolved.

## Discovery Gate

Gate ID: `phase.discovery.ready`.

Proceed only when problem, users, outcome, scope, assumptions, and open questions are explicit.

## Brief Gate

Gate ID: `phase.brief.ready`.

Proceed only when problem, goals, target users, scope boundaries, success metrics, AI-specific requirements when relevant, edge cases, risks, and open questions are explicit.

## Prototype Gate

Gate ID: `phase.prototype.ready`.

Proceed only when the prototype has a clear learning objective, minimum user flow, screen list, prompt or wireframe package, exclusions, and validation method.

## Experiment Gate

Gate ID: `phase.experiment.ready`.

Proceed only when hypothesis, method, participants or sample, tracking plan,
success metrics, guardrails, and decision criteria are explicit. For AI
behavior, the versioned evaluation suite, deployment slices, graders,
precommitted hard blockers, baseline comparison, and applicable latency/cost
budgets must also be explicit. Material evidence should be captured with
`_refs/templates/docs/evidence-ledger.md`.

## Validate Gate

Gate ID: `phase.validate.ready`.

Proceed only when results have been compared against the agreed criteria, blockers are separated from improvements, and accepted risks have a named owner.

## Learn Gate

Gate ID: `phase.learn.ready`.

Proceed only when observations, interpretations, decision, roadmap implication, memory updates, and next-loop or delivery action are explicit.

## Strategy Gate

Gate ID: `phase.strategy.ready`.

Proceed only when the decision owner, horizon, target users or segments,
where-to-play and how-to-win choices, explicit exclusions, portfolio or
investment posture, outcome measures, evidence confidence, affected
commitments, and review triggers are explicit. When AI is material, suitability,
risk tier, evaluation burden, monitoring implications, and unit economics must
also be addressed.

## Spec Gate

Gate ID: `phase.spec.ready`.

Proceed only when requirements are testable, scope boundaries are clear, risks are visible, security/privacy/accessibility implications are reviewed when relevant, and artifact quality score is reviewed when the work is high stakes.

For material AI behavior, the accepted specification must also define intended
and prohibited behavior, autonomy and human authority, context/data/tool
boundaries, fallback and escalation, quality/latency/cost budgets, evaluation
traceability, and production monitoring or explicit not-applicable decisions.

## Design Gate

Gate ID: `phase.design.ready`.

Use this gate when accepted user-visible requirements need a design handoff.
Proceed only when the exact source baseline and design authority are recorded;
in-scope requirements map to flows, screens, and applicable interaction or
state behavior; responsive and accessibility obligations are reviewed; the
design-system binding is explicit; and every unsupported or conflicting design
need is resolved or recorded as a blocking design gap. The gate is optional
when the accepted scope has no user-visible design surface.

## Plan Gate

Gate ID: `phase.plan.ready`.

Proceed only when epics, dependencies, milestones, and blockers are known.

## Execution Gate

Gate ID: `phase.execution.ready`.

Escalate to `change` when an answer modifies committed scope or acceptance criteria.

## Ship Gate

Gate ID: `phase.ship.ready`.

Release only when UAT, operational readiness, stakeholder communication,
rollback/support, security/privacy/accessibility risk, and post-launch memory
capture are ready or accepted as risks with named owners. An AI-enabled release
or material model, prompt, retrieval, tool, policy, or data change also requires
a comparable AI evaluation verdict; critical-slice and hard-blocker failures
cannot be accepted as an aggregate pass. The exact deployment scope must also
have authorized production signals, incident ownership, human fallback,
rollback, configuration-drift detection, and re-evaluation triggers.
