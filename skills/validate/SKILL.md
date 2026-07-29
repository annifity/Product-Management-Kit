---
name: validate
description: Audit an existing product artifact, evidence set, delivery package, or Annifity canonical skill and return a readiness or quality verdict with findings. Use when the user asks to review, validate, assess readiness, check completeness, consistency, testability, coverage, traceability, risk, or go/no-go status. Use `prd`, `spec`, `user-story`, `uat`, or `ship` to create or substantially rewrite those artifacts; use `validate` as the primary route for an independent review, with domain skills applied only for requested fixes.
---

# Validate

Apply the checklist that matches the existing target, then issue an evidence-backed verdict before any requested repair.

## Input Contract

- Reuse the target, criteria, evidence, and prior decisions supplied inline or by file.
- If the target is missing or inaccessible, ask for it and do not issue a readiness verdict.
- Accept partial evidence only for a scoped verdict; state evidence limits, label assumptions, and ask only for a gap that could change the verdict or route.

## Process

1. Identify the target: PRD, spec, story, UAT, prototype, experiment, change plan, release package, or canonical skill change.
2. Review against the relevant checklist or readiness workflow.
3. Check cross-artifact consistency and traceability when multiple artifacts exist.
4. Separate blockers from improvements and accepted risks; require a named owner for every accepted material risk.
5. Provide inline fixes when the user asks for correction, not only critique.
6. Recommend the next phase: revise, learn, plan, execution, UAT, or ship.

## Output

- Verdict: ready / needs revision / blocked
- Evidence reviewed and evidence limits
- Findings by severity
- Blocking issues
- Important improvements
- Traceability or readiness gaps
- Inline fixes or suggested edits
- Residual risks
- Recommendation
- Next action

## Reference Routing

Load only references matching the review target:

- For ambiguous routing, use `_refs/operating-model/routing.md`.
- For lifecycle or phase-readiness verdicts, use the matching gate in `_refs/operating-model/phase-gates.md`.
- For Annifity canonical skill authoring, use `_refs/operating-model/skill-authoring.md`, `_refs/checklists/skill-quality.md`, and `_refs/templates/skills/skill-template.md`.
- For first-pass semantic regressions, use `_refs/schemas/semantic-forward-test.md`; keep candidate, blind evaluator, and hidden-oracle stages separated.
- For canonical skill input/output/handoff and primary-template field conformance, use `_refs/schemas/skill-output-contract.md`.
- For a privacy-safe rework audit over explicitly selected session evidence, use `_refs/schemas/session-rework-observation.md`; never discover or scan the user's session home implicitly.
- For first-pass telemetry and skill-version trends, use `_refs/schemas/first-pass-quality-dashboard.md` only after privacy-safe session observations exist.
- For bounded Draw.io usability, source-link, and stale-label checks, use `_refs/schemas/drawio-validation-manifest.md`.
- For bounded docs/memories/decision/index consistency, use `_refs/schemas/context-consistency-manifest.md`.
- For a phase transition or approval-reuse audit, use `_refs/operating-model/phase-gates.md`, `_refs/schemas/initiative-state.md`, and the read-only resolver `tools/resolve-phase-gate-approval.ps1`.
- For Annifity repository-root hygiene, run the read-only `tools/invoke-repo-doctor.ps1` against `tools/repo-root-manifest.json`; do not infer that canonical `docs/` or `tests/` should be ignored.
- When reviewing Annifity principles or bilingual behavior, use `_refs/operating-model/annifity-principles.md` and/or `_refs/operating-model/language-policy.md`.
- When reviewing generated platform adapters, use only the target platform reference: `_refs/integrations/claude.md`, `_refs/integrations/codex.md`, `_refs/integrations/copilot.md`, or `_refs/integrations/cursor.md`.
- For prototype-first evidence, use `_refs/workflows/prototype-first.md` and `_refs/templates/prototype/prototype-feedback-summary.md`.
- For a general artifact or requirements review, use `_refs/checklists/artifact-quality-scorecard.md`, `_refs/checklists/business-analysis.md`, `_refs/checklists/spec-quality.md`, and `_refs/checklists/edge-cases.md` selectively.
- To audit whether authoring resolved `_refs/schemas/artifact-generation-contract.md` through `_refs/operating-model/artifact-profile-resolution.md` with the right consumer, source, mode, ownership, and baseline, use `_refs/checklists/material-decision-preflight.md`; to detect filler, duplication, scope leakage, or misplaced content, use `_refs/checklists/source-backed-minimality.md`.
- When the verdict depends on a governed baseline, use `_refs/operating-model/authoritative-baseline-resolution.md`; report a blocked verdict when identity, hash, supersession, or pointer invariants fail.
- When auditing a protected local change, verify its preview and after-state through `_refs/workflows/local-mutation-safety.md` and `_refs/schemas/mutation-preview.md`; use `_refs/checklists/negative-completeness.md` for removal, ignore, move, rename, or narrowing claims.
- For story reviews, use `_refs/checklists/story-quality-invest.md` for the story slice and `_refs/checklists/acceptance-criteria-quality.md` for its AC. For UAT reviews, use `_refs/checklists/uat-coverage.md`.
- For sprint or implementation readiness, use `_refs/workflows/sprint-readiness.md`, `_refs/checklists/definition-of-ready.md`, and/or `_refs/checklists/definition-of-done.md`.
- For release or operations readiness, use `_refs/checklists/ship-readiness.md` and/or `_refs/checklists/operational-readiness.md`.
- For risk, governance, security, privacy, or accessibility, use `_refs/checklists/risk-review.md`, `_refs/checklists/stakeholder-governance.md`, `_refs/checklists/security-privacy-accessibility.md`, and `_refs/templates/risk/risk-register.md` only as applicable.
- For cross-artifact traceability, use `_refs/templates/traceability/rtm.md`.
- For experiment-result evaluation, use `_refs/templates/experiment/decision-criteria.md`.

## Handoff

Return the verdict, blockers, evidence limits, and repair scope to the skill that owns the reviewed artifact. Route assessed product evidence to `learn`. Route toward `plan`, `execution`, or `ship` only when the applicable gate passes or each accepted material risk has a named owner.
