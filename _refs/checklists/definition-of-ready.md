# Definition Of Ready

A feature is ready for delivery planning only when these items are explicit or consciously deferred.

- Business problem and target users are agreed.
- The material-decision preflight has one authoritative source, resolved ownership, a selected deliverable mode, and no blocking conflict.
- Scope in and scope out are clear.
- Business rules and validation rules are documented.
- End-to-end workflow includes happy path and key exception paths.
- State transitions include valid transitions, invalid conditions, and stuck-state handling.
- Requirements are testable and traceable to source context.
- The AC set passes `_refs/checklists/acceptance-criteria-quality.md`, including relevant unhappy paths and permission behavior.
- Edge cases and critical risks have mitigation or accepted-risk decisions.
- Dependencies have owners, status, and fallback or mock strategy.
- UAT approach, data setup, and signoff owner are known.
- The package passes `_refs/checklists/source-backed-minimality.md`; no filler, duplicate truth, speculative behavior, or misplaced NFR remains.
