# Design Readiness Checklist

Use before drafting or materially revising a spec-derived design package.

## Source Gate

- The authoritative spec ID, version, path, and SHA-256 are resolved.
- In-scope requirement, role, workflow, rule, permission, state, NFR, and exclusion IDs are known.
- Conflicts between accepted sources are resolved or recorded as blockers.
- The requested design does not require inventing product behavior.

## Decision Gate

- Target users, surfaces, viewports, locales, and fidelity are explicit.
- The review consumer and decision are explicit.
- Mockup and behavior authority are explicit.
- The existing design system and brand source are identified, or their absence is recorded.
- The output destination and baseline disposition are resolved.

## Coverage Gate

- Primary tasks and entry/exit points can be mapped from the source.
- Role and permission differences are known.
- Applicable data freshness, loading, empty, error, success, denial, offline, partial, and conflict states can be determined.
- Accessibility, responsive, privacy, security, and AI-specific obligations are identified when relevant.

## Stop Conditions

Stop the affected portion when:

- a new action, outcome, permission, state transition, threshold, or data field must be invented;
- a mockup conflicts with the accepted source;
- a design-system or brand decision is material but has no authority;
- a source change would require `change`;
- the requested fidelity cannot be reviewed with the available evidence.

## Verdict

- **Ready:** all material source and design decisions are confirmed or explicitly not applicable.
- **Ready with provisional visuals:** behavior is fully sourced, while reversible visual choices are labeled provisional.
- **Blocked:** an unresolved gap would alter behavior, authority, acceptance, accessibility, or handoff scope.
