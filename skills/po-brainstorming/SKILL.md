---
name: po-brainstorming
description: Explore early product ideas, stakeholder asks, vague feature requests, or unclear problems before writing specs or artifacts. Use when the user needs PO-style brainstorming, problem framing, discovery questions, option exploration, scope clarification, or a Superpowers-like gate before moving to specification.
---

# PO Brainstorming

Use this as the first phase of Annifity when the request is still fuzzy, solution-led, or missing product context.

## Process

1. Read relevant memories first when available:
   - `_refs/templates/memories/product-context.md`
   - `_refs/templates/memories/team-preferences.md`
   - `_refs/templates/memories/terminology.md`
   - `_refs/templates/memories/stakeholder-context.md`
2. Clarify one question at a time. Prefer multiple-choice questions when the user is blocked.
3. Separate the real user problem from proposed solutions.
4. Identify users, pain, outcome, constraints, assumptions, success metrics, and non-goals.
5. Offer 2-3 product approaches when multiple paths are plausible.
6. Ask for explicit confirmation before moving to `po-spec`.

## Output

Return a compact brainstorming brief:

- Problem statement
- Target users and jobs
- Desired outcome
- Candidate approaches
- Scope in / scope out
- Known constraints
- Assumptions
- Success metrics
- Open questions

## Required References

- Use `_refs/operating-model/po-flow.md` for the overall phase model.
- Use `_refs/checklists/brainstorming-readiness.md` before handing off to `po-spec`.
- Use `_refs/workflows/discovery-to-spec.md` when moving from idea to spec.

## Handoff

When the user confirms the brief, suggest `po-spec` as the next phase. Ask `docs` to save a session note and `memories` to persist durable context.
