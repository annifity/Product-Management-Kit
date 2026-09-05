# Design Quality Checklist

Use before resolving the Design Gate or handing a design package to planning, story authoring, or implementation.

## Source And Traceability

- Every in-scope requirement maps to a flow, screen, state, interaction, or explicit design gap.
- Every action and user-visible outcome has an authoritative source ID.
- The source baseline and design-system version match the current contract.
- No illustrative mockup detail has been promoted into accepted behavior.

## Flow And State Quality

- Navigation, entry, exit, cancellation, back behavior, interruptions, and recovery are explicit.
- Default, loading, empty, error, success, disabled, permission-denied, partial, stale, offline, and conflict states are covered or marked not applicable with a reason.
- Role, permission, and sensitive-action differences are visible.
- Destructive or irreversible actions include sourced confirmation and recovery behavior.

## Responsive And Accessibility

- Target viewports and layout changes are specified without horizontal overflow.
- Keyboard order, focus visibility, semantic structure, labels, and error association are defined.
- Status does not rely on color alone, and contrast obligations are explicit.
- Touch targets, zoom, reduced motion, and assistive-technology behavior are addressed when applicable.

## System And Content Consistency

- Colors, typography, spacing, shape, elevation, and component variants reference the bound design system.
- Provisional tokens are clearly distinguished from accepted tokens.
- Content uses product terminology and defines empty, error, permission, and recovery copy.
- Locale, date, time, number, truncation, and long-content behavior are addressed when applicable.

## AI-Native UX

- Generated, recommended, uncertain, stale, failed, and unavailable states are distinguishable.
- Source, confidence, limitation, and freshness information appear when required by the AI behavior contract.
- Human review, edit, approve, reject, override, fallback, and escalation controls match accepted authority.
- Feedback capture and prohibited autonomous actions do not exceed the accepted AI behavior.

## Handoff

- The design contract, screen specs, state matrix, design-system binding, traceability, and design-gap register are included.
- Blocking gaps have owners and routes.
- Review evidence, gate decision, human-readable source identity, and concise
  user-facing result are present. Machine-readable fingerprints remain in the
  manifest or technical audit record and are not copied into the handoff by
  default.

## Verdict

- **Ready:** traceability is complete, applicable quality dimensions pass, and no blocking design gap remains.
- **Needs revision:** behavior remains sourced but recoverable quality or coverage gaps exist.
- **Blocked:** unsupported behavior, source conflict, authority ambiguity, or an unresolved material accessibility or permission gap remains.
