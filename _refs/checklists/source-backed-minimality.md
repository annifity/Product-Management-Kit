# Source-Backed Minimality

Use this gate to produce the smallest artifact that preserves every confirmed decision needed by its consumer. Apply `_refs/checklists/acceptance-criteria-quality.md` separately to criterion-level AC quality.

Minimality means complete for the selected deliverable mode, not short at the cost of missing behavior.

## Composition Gate

Every retained section, table, requirement, scenario, dependency, exclusion, and NFR statement must pass:

| Dimension | Required Standard |
|---|---|
| Source | Trace to supplied context, an authoritative artifact, accepted decision, project profile, or explicitly labeled assumption |
| Relevance | Help the named consumer make the decision or perform the handoff selected in the deliverable mode |
| Ownership | Remain inside the owning artifact, story, feature, system, and workflow phase |
| Distinctness | Add information not already expressed more authoritatively elsewhere in the artifact |
| Specificity | State confirmed behavior precisely without inventing thresholds, copy, UI mechanics, retries, or states |
| Placement | Put product behavior, NFR, test execution detail, technical design, and release evidence in their owning artifacts |
| Traceability | Preserve stable IDs and source links where the artifact contract requires them |

Remove or relocate content that fails any applicable dimension. Record a gap instead of filling it with generic best practice.

## Section Rules

- Include a dependency only when another capability, system, data source, decision, or delivery item can block implementation, testing, or release.
- Include Out of Scope only for adjacent behavior a reasonable reader could otherwise mistake as included.
- Include an open question only when unresolved and material to this artifact; do not copy the complete project question register.
- Include story-level NFR only when a confirmed source makes it acceptance-relevant. Keep broader quality targets in the parent PRD, spec, UAT, or release gate.
- Keep test data, execution steps, environment, priority, permutations, and result recording in UAT rather than AC.
- Keep internal services, data structures, algorithms, and orchestration in technical design unless they are the confirmed external contract.
- Do not add a section merely because a generic template contains it. Omit it or mark `N/A` only when the target format requires an explicit applicability record.

## Pruning Pass

Before handoff:

1. Map each material statement to its source or labeled assumption.
2. Compare repeated behavior across context, flow, requirements, AC, dependencies, and exclusions.
3. Keep the most authoritative expression and remove weaker duplicates.
4. Check every error, boundary, permission, timeout, retry, and NFR statement for source and relevance.
5. Check cross-story and cross-system behavior against the responsibility preview.
6. Confirm the resulting artifact still satisfies the selected consumer and mode.

## Good Example

A concise story depends on an external identity service that can block save. Retain that dependency and the sourced denial outcome. Omit generic accessibility, performance, offline, audit, and retry sections when the parent PRD owns them and the story has no source-specific acceptance rule.

## Anti-pattern

A story repeats the same validation in an information table, Main Flow, Business Rules, three AC, an Edge Cases section, and UAT-like permutations. It also lists the target screen and shared design file as dependencies. The output is long but adds no decision value.

## Failure Modes

| Failure | Signal | Consequence | Correction | Prevention |
|---|---|---|---|---|
| Checklist filler | Sections exist only because the template lists them | Output becomes noisy and invites contradictions | Remove non-applicable sections | Apply relevance before template completion |
| Defensive invention | Generic failures, retries, or safeguards lack a source | Unapproved scope enters delivery | Replace with a gap or remove | Require provenance for each behavior |
| Duplicate truth | The same rule appears in several sections | Later edits create drift | Keep one authoritative expression | Run the pruning pass |
| Scope halo | Broad product areas appear in dependencies or exclusions | Story boundary looks larger than it is | Retain only adjacent blockers or exclusions | Apply ownership and adjacency checks |
| NFR leakage | Parent-level targets become story AC without authorization | Story becomes oversized and brittle | Move the target to its owning artifact | Resolve NFR placement in preflight |

## Verdict

- **Ready:** Every retained item is sourced, relevant, correctly owned, distinct, and properly placed.
- **Needs revision:** Confirmed content exists, but duplication, placement, or irrelevant sections remain.
- **Blocked:** Completing the artifact requires inventing material behavior or choosing an unresolved owner.
