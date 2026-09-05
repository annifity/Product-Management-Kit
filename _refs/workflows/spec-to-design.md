# Spec-To-Design Workflow

Use this workflow when an accepted product specification must become a UX/UI design package for review, planning, story authoring, or implementation handoff.

## Reference Lineage

Annifity's implementation is original and provider-neutral. It adapts workflow
ideas, not source code or bundled design data, from:

- `google-labs-code/stitch-skills` (Apache-2.0): skill-sized design operations,
  explicit design-system artifacts, self-contained HTML extraction, and
  validation-oriented scripts;
- `nextlevelbuilder/ui-ux-pro-max-skill` (MIT): design-system-first reasoning,
  accessibility/anti-pattern checks, and separating reusable foundations from
  page-level overrides;
- `JimLiu/baoyu-design` (MIT): repo-local, self-contained HTML design artifacts
  and a tight preview/review iteration loop.

Do not copy their templates, datasets, component libraries, prompts, or
vendor-specific execution instructions into Annifity. Keep the canonical
workflow source-bound, portable, and compatible with optional render adapters.

## Entry Conditions

- Resolve the authoritative source baseline and exact requirement IDs.
- Confirm the user-visible surface, primary consumers, deliverable mode, design authority, and destination.
- Reuse supplied brand, platform, accessibility, locale, and design-system constraints.
- Stop when requirements are not stable enough to define interface behavior; route draft clarification to `spec` and accepted-scope changes to `change`.

## Workflow

1. **Extract the interface contract.** Map users, jobs, requirements, workflows, rules, permissions, data, NFRs, exclusions, and acceptance signals from the accepted source.
2. **Frame the design.** Define target surfaces, fidelity, review decision, primary tasks, constraints, and explicit non-goals in the design brief.
3. **Model navigation and flow.** Define information architecture, entry points, exits, decision points, interruptions, and role-specific paths. Assign stable `FLOW-*` IDs.
4. **Inventory screens.** Create only screens needed by sourced tasks. Assign stable `SCREEN-*` IDs and map each screen to `REQ-*` and `FLOW-*`.
5. **Complete states and interactions.** Cover default, loading, empty, error, success, disabled, permission-denied, partial-data, stale-data, offline, and conflict states only when applicable. Record why a state is not applicable.
6. **Bind the visual system.** Use an accepted design system when available. Otherwise keep the package structural or create a clearly provisional system only within confirmed design authority.
7. **Specify quality obligations.** Define responsive behavior, keyboard and screen-reader behavior, non-color status cues, content and localization constraints, sensitive-data handling, and AI review or override states when applicable.
8. **Trace and review.** Complete `REQ -> FLOW -> SCREEN -> STATE/INTERACTION` coverage, register design gaps, run design readiness and quality checks, and resolve the Design Gate.
9. **Prepare the handoff.** Package the accepted contract, human-readable source identity, design-system binding, unresolved gaps, review evidence, and a concise user-facing result for the next skill. Retain the source fingerprint and resolver details only in the machine-readable manifest or technical audit record.

## Design Gap Protocol

Create a `DESIGN-GAP-*` record when the design requires a decision absent from, or conflicting with, the accepted source.

| Field | Required content |
|---|---|
| Gap | Missing or conflicting behavior in plain language |
| Source impact | Requirement, rule, permission, state, data, or NFR affected |
| Design impact | Blocked flow, screen, state, or component |
| Owner | Product, design, legal, security, engineering, or other decision owner |
| Route | `spec` for draft clarification; `change` for accepted-baseline impact |
| Status | Open / resolved / accepted risk |

Do not hide a gap with placeholder UI, invented copy, disabled controls, or a visually plausible default.

## Good Example

An accepted approval spec defines reviewer and requester roles, approve and reject outcomes, reason capture, and permission denial. The design creates one queue flow, one review screen, explicit approve/reject confirmation states, and a permission-denied state, all mapped to the source IDs. Color and spacing remain provisional because no design system was supplied.

## Anti-Pattern

A mockup adds bulk approval, auto-approval, and real-time notifications because they make the dashboard feel complete. None has a source requirement, so the mockup silently expands delivery scope.

## Failure Modes

| Failure | Signal | Consequence | Correction | Prevention |
|---|---|---|---|---|
| Mockup promotion | A visible control has no source ID | Visual invention becomes accepted scope | Remove it or open a design gap | Require source mapping per screen action |
| Happy-path design | Loading, error, denial, or empty states are absent | Delivery and UAT discover behavior late | Complete the applicable state matrix | Run design readiness before visual polish |
| System drift | Screens use inconsistent values or stale tokens | Handoff is expensive to implement | Rebind to the accepted design system | Record design-system ID and version |
| Tool lock-in | The package requires a vendor not selected by the user | Portable execution fails | Keep the canonical package tool-neutral | Treat render targets as optional adapters |
| Unreviewable handoff | Screen images have no behavior or traceability | Engineering must reconstruct intent | Add screen specs and coverage mapping | Require the Design Handoff Pack |

## Exit Criteria

The workflow exits only when every in-scope requirement is mapped or registered as a gap, applicable states are covered, design authority and design-system status are explicit, quality checks are complete, and the Design Gate result is recorded.
