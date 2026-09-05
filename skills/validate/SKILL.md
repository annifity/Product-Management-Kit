---
name: validate
description: Audit an existing product artifact, UX/UI design, evidence set, AI evaluation results, delivery package, or an Annifity repository skill/reference file and return a readiness or quality verdict with findings. Use when the user asks to review, validate, compare AI baseline and candidate runs, assess regression or release readiness, check completeness, consistency, testability, coverage, traceability, risk, or go/no-go status. Use `analytics` to diagnose metric movement or design instrumentation and `experiment` before results exist. Use `prd`, `spec`, `user-story`, `uat`, or `ship` to create or substantially rewrite those artifacts, and `design` to author or substantially revise a UX/UI package.
---

# Validate

Apply the checklist that matches the existing target, then issue an evidence-backed verdict before any requested repair.

## Input Contract

- Reuse the target, criteria, evidence, and prior decisions supplied inline or by file.
- If the target is missing or inaccessible, ask for it and do not issue a readiness verdict.
- Accept partial evidence only for a scoped verdict; state evidence limits, label assumptions, and ask only for a gap that could change the verdict or route.

## Process

1. Identify the target: PRD, spec, UX/UI design, story, UAT, prototype, experiment, product analytics evidence, AI evaluation suite/run, change plan, release package, or canonical skill change.
2. Review against the relevant checklist or readiness workflow.
3. For a material PM decision, apply the method, evidence, metric, causality, commercial, and recommendation checks before accepting the artifact's conclusion.
4. Check cross-artifact consistency and traceability when multiple artifacts exist.
5. Separate blockers from improvements and accepted risks; require a named owner for every accepted material risk.
6. Provide inline fixes when the user asks for correction, not only critique.
7. Recommend the next phase: revise, learn, plan, execution, UAT, or ship.

## Output

- Verdict: ready / needs revision / blocked
- Evidence reviewed and evidence limits
- Findings by severity
- Blocking issues
- Important improvements
- Traceability or readiness gaps
- Inline fixes or suggested edits
- Residual risks
- Baseline-to-candidate and per-slice deltas, required whenever an AI evaluation is the target — an aggregate pass must never substitute for a missing or failing slice result
- Recommendation
- Next action

## Reference Routing

Load only references matching the review target:

- **Route and lifecycle:** use `_refs/operating-model/routing.md` for ambiguous intent and `_refs/operating-model/phase-gates.md` for phase readiness. For approval reuse, also use `_refs/schemas/initiative-state.md` and the read-only `tools/resolve-phase-gate-approval.ps1`.
- **Canonical skill quality:** use `_refs/operating-model/skill-authoring.md`, `_refs/checklists/skill-quality.md`, and `_refs/templates/skills/skill-template.md` for authoring; use `_refs/schemas/skill-output-contract.md` for input/output/handoff conformance and `_refs/schemas/semantic-forward-test.md` for isolated first-pass regressions.
- **Task-progress behavior:** use `_refs/operating-model/task-progress.md`, `_refs/schemas/task-progress-state.md`, `_refs/templates/docs/task-progress-checklist.md`, and `_refs/checklists/task-progress-quality.md` to audit activation, transitions, evidence, interruption recovery, final status, and runtime portability.
- **Artifact and PM decision quality:** use `_refs/operating-model/artifact-quality-system.md`, `_refs/operating-model/methodology-catalog.md`, `_refs/workflows/pm-decision-challenge.md`, `_refs/checklists/pm-decision-quality.md`, `_refs/templates/skills/method-selection-record.md`, and `_refs/schemas/methodology-record.md` when the target makes or supports a material product decision. Use `_refs/templates/skills/gold-example.md` to author an independent synthetic quality anchor; load a gold example only when the expected depth is ambiguous or the eval requires it.
- **Product-quality telemetry:** use `_refs/schemas/session-rework-observation.md` only for explicitly selected privacy-safe session evidence, then `_refs/schemas/first-pass-quality-dashboard.md` for aggregated trends. Use `_refs/schemas/drawio-validation-manifest.md` for bounded Draw.io checks and `_refs/schemas/context-consistency-manifest.md` for bounded docs, memories, decision, and index consistency.
- **Product analytics:** use `_refs/workflows/product-analytics.md`, `_refs/checklists/product-analytics-quality.md`, `_refs/templates/metrics/product-analytics-review.md`, and `_refs/schemas/metrics-event.md` to assess instrumentation, comparability, outcome, adoption, funnel, cohort, retention, or guardrail evidence. Issue the evidence verdict here; route interpretation and a product decision to `learn`.
- **Repository and adapters:** run read-only `tools/invoke-repo-doctor.ps1` against `tools/repo-root-manifest.json` for root hygiene. Use `_refs/operating-model/annifity-principles.md` or `_refs/operating-model/language-policy.md` for principles or bilingual behavior, and only the target adapter guide: `_refs/integrations/claude.md`, `_refs/integrations/codex.md`, `_refs/integrations/copilot.md`, or `_refs/integrations/cursor.md`.
- **Artifact evidence and source control:** use `_refs/workflows/prototype-first.md` with `_refs/templates/prototype/prototype-feedback-summary.md` for prototype evidence. For general artifacts, select from `_refs/checklists/artifact-quality-scorecard.md`, `_refs/checklists/business-analysis.md`, `_refs/checklists/spec-quality.md`, and `_refs/checklists/edge-cases.md`. Audit the generation contract with `_refs/schemas/artifact-generation-contract.md`, `_refs/operating-model/artifact-profile-resolution.md`, `_refs/checklists/material-decision-preflight.md`, and `_refs/checklists/source-backed-minimality.md`; resolve governed sources through `_refs/operating-model/authoritative-baseline-resolution.md`.
- **Product design:** use `_refs/schemas/design-contract.md`, `_refs/schemas/design-artifact-manifest.md`, `_refs/checklists/design-readiness.md`, `_refs/checklists/design-quality.md`, `_refs/templates/design/design-review.md`, and `_refs/templates/design/spec-design-traceability.md` to audit source coverage, screen and state completeness, design authority, responsive and accessibility obligations, design-system binding, artifact integrity, and design gaps.
- **Mutation and completeness:** audit protected changes with `_refs/workflows/local-mutation-safety.md` and `_refs/schemas/mutation-preview.md`; use `_refs/checklists/negative-completeness.md` for removal, ignore, move, rename, or narrowing claims.
- **Delivery quality:** use `_refs/checklists/story-quality-invest.md` and `_refs/checklists/acceptance-criteria-quality.md` for stories, `_refs/checklists/uat-coverage.md` for UAT, and `_refs/workflows/sprint-readiness.md`, `_refs/checklists/definition-of-ready.md`, or `_refs/checklists/definition-of-done.md` for implementation readiness.
- **Release, risk, and traceability:** use `_refs/checklists/ship-readiness.md` or `_refs/checklists/operational-readiness.md` for release readiness; select `_refs/checklists/risk-review.md`, `_refs/checklists/stakeholder-governance.md`, `_refs/checklists/security-privacy-accessibility.md`, and `_refs/templates/risk/risk-register.md` only as applicable; use `_refs/templates/traceability/rtm.md` for cross-artifact traceability.
- **Experiment and AI results:** use `_refs/templates/experiment/decision-criteria.md` for experiment results. For AI results, use `_refs/workflows/ai-evaluation.md`, `_refs/schemas/ai-evaluation-suite.md`, and `_refs/checklists/ai-evaluation-release-gate.md`; run the read-only `tools/resolve-ai-evaluation-verdict.ps1` against the evaluation suite to compute per-slice/per-criterion pass results before writing the verdict; never hand-derive threshold comparisons or let an aggregate score hide a critical-slice or hard-blocker failure.
- **AI production evidence:** use `_refs/workflows/ai-production-monitoring.md`, `_refs/schemas/ai-production-monitoring-plan.md`, and `_refs/checklists/ai-production-readiness.md` for drift, incidents, feedback, online slices, rollback, and re-evaluation readiness.

## Handoff

Return the verdict, blockers, evidence limits, and repair scope to the skill that owns the reviewed artifact. Route assessed product evidence to `learn`. Route toward `plan`, `execution`, or `ship` only when the applicable gate passes or each accepted material risk has a named owner.
