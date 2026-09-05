# Annifity References

Annifity keeps skill files short and loads detailed guidance from `_refs/` only when needed.

## Routing

- Operating model: `_refs/operating-model/`
- Routing and builder packs: `_refs/operating-model/routing.md`, `_refs/operating-model/builder-packs.md`
- End-to-end process: `_refs/workflows/`
- Quality checks: `_refs/checklists/`
- Artifact templates: `_refs/templates/`
- Persisted record shapes: `_refs/schemas/`
- Tool-specific notes: `_refs/integrations/`

Skills should load only the relevant reference files for the current task.

## Shared Execution Behavior

| Need | Use |
|---|---|
| Show and maintain progress for multi-step work | `_refs/operating-model/task-progress.md` |
| Persist or exchange task progress state | `_refs/schemas/task-progress-state.md` |
| Render a concise user-facing checklist | `_refs/templates/docs/task-progress-checklist.md` |
| Review task-progress behavior | `_refs/checklists/task-progress-quality.md` |

## Reference Families

- Discovery and strategy: product discovery, customer research synthesis,
  jobs-to-be-done analysis, discovery interview plan, research evidence,
  opportunity scoring, product strategy and portfolio choices, opportunity
  solution tree, solution exploration, market sizing, company research,
  business model canvas, metric tree.
- Learning loop: brief, prototype, experiment design, AI evaluation, validation, learning synthesis, decision criteria, roadmap recommendation.
- Business and finance: finance metrics, feature investment economics, pricing/ROI inputs, SaaS health signals, market sizing.
- Specification and product design: BRD analysis, product spec, workflow map, data requirements, API contract, feature design, requirement analysis, spec-to-design workflow, design contract, screens, states, design-system binding, and design handoff.
- Planning: prioritization, roadmap, story map, grooming questions, definition of ready, market/finance-informed sequencing.
- Delivery and review: sprint readiness, edge case review, risk register, traceability matrix, UAT, operational readiness.
- Analytics: metric contracts, instrumentation, funnels, cohorts, retention, adoption, outcome evidence, and data-quality verdicts.
- Shipping and change: release readiness, rollout and go-to-market/adoption plans, change governance, spec change context.
- Documentation and memory: docs index, evidence ledger, decision ledger, template registry, initiative state, metrics events, memory schemas, context manifest for AI-native workflows.
- Governance and risk: stakeholder governance, security/privacy/accessibility, risk acceptance, AI risk review, AI evaluation release gate.
- Skill authoring: canonical authoring standard with an integrated workflow, skill template, routing contracts, and quality gate.

## High-ROI Capability Routes

| Need | Reference |
|---|---|
| Choose the right Annifity skill | `_refs/operating-model/routing.md` |
| Create or review an Annifity canonical skill change | `_refs/operating-model/skill-authoring.md` + `_refs/checklists/skill-quality.md` + `_refs/templates/skills/skill-template.md` |
| Package output as a Product Builder Kit handoff | `_refs/operating-model/builder-packs.md` |
| Create prompt-ready input for a runnable frontend prototype | `_refs/templates/prototype/prototyping-requirements-one-pager.md` + `_refs/checklists/pro-quality.md` |
| Run prototype-first before PRD | `_refs/workflows/prototype-first.md` |
| Turn prototype feedback into PRD input | `_refs/templates/prototype/prototype-feedback-summary.md` + `_refs/templates/prd/prd-from-pro-feedback.md` |
| Analyze raw BRD or vague requirements | `_refs/workflows/requirement-analysis.md` + `_refs/checklists/business-analysis.md` |
| Map a workflow deeply | `_refs/templates/spec/workflow-spec.md` |
| Turn an accepted spec into a design handoff | `_refs/workflows/spec-to-design.md` + `_refs/schemas/design-contract.md` + `_refs/schemas/design-artifact-manifest.md` + `_refs/templates/design/design-handoff.md` |
| Check spec-derived design readiness and quality | `_refs/checklists/design-readiness.md` + `_refs/checklists/design-quality.md` + `_refs/templates/design/spec-design-traceability.md` |
| Author or review acceptance criteria | `_refs/checklists/acceptance-criteria-quality.md` + `_refs/templates/user-story/acceptance-criteria-gwt.md` |
| Audit selected session rework evidence safely | `_refs/schemas/session-rework-observation.md` |
| Run blind semantic first-pass regressions | `_refs/schemas/semantic-forward-test.md` |
| Validate all canonical skill output/template contracts | `_refs/schemas/skill-output-contract.md` |
| Build first-pass quality telemetry by skill version | `_refs/schemas/first-pass-quality-dashboard.md` |
| Validate Draw.io structure, sources, and stale labels | `_refs/schemas/drawio-validation-manifest.md` |
| Lint docs, memories, decisions, and index consistency | `_refs/schemas/context-consistency-manifest.md` |
| Resolve or reuse a phase-gate approval safely | `_refs/operating-model/phase-gates.md` + `_refs/schemas/initiative-state.md` |
| Audit repository-root ownership and Git policy | `tools/repo-root-manifest.json` + `tools/invoke-repo-doctor.ps1` |
| Resolve project-specific artifact rules | `_refs/schemas/artifact-generation-contract.md` + `_refs/operating-model/artifact-profile-resolution.md` |
| Return evidence of the exact generation context | `_refs/templates/docs/generation-receipt.md` |
| Confirm source, mode, ownership, and baseline before authoring | `_refs/checklists/material-decision-preflight.md` |
| Select the accepted baseline | `_refs/schemas/artifact-state-registry.md` + `_refs/operating-model/authoritative-baseline-resolution.md` |
| Migrate legacy artifacts into the baseline registry | `tools/new-artifact-registry-migration.ps1` + `_refs/schemas/artifact-state-registry.md` + `_refs/workflows/local-mutation-safety.md` |
| Sign and verify reusable phase-gate approval | `tools/sign-phase-gate-approval.ps1` + `tools/resolve-phase-gate-approval.ps1` + `_refs/operating-model/phase-gates.md` |
| Remove filler and scope leakage | `_refs/checklists/source-backed-minimality.md` |
| Preview and confirm a protected local mutation | `_refs/workflows/local-mutation-safety.md` + `_refs/schemas/mutation-preview.md` |
| Verify removal, ignore, move, or narrowing end state | `_refs/checklists/negative-completeness.md` |
| Stress-test edge cases | `_refs/checklists/edge-cases.md` |
| Review product/project risk | `_refs/checklists/risk-review.md` + `_refs/templates/risk/risk-register.md` |
| Generate UAT with priority and pass criteria | `_refs/checklists/uat-coverage.md` + `_refs/templates/uat/test-case-register.md` |
| Score artifact quality before handoff | `_refs/checklists/artifact-quality-scorecard.md` |
| Apply the material artifact quality anatomy | `_refs/operating-model/artifact-quality-system.md` + `_refs/templates/skills/gold-example.md` |
| Challenge a PM method or material recommendation | `_refs/workflows/pm-decision-challenge.md` + `_refs/checklists/pm-decision-quality.md` + `_refs/templates/skills/method-selection-record.md` |
| Record method provenance and reuse boundaries | `_refs/schemas/methodology-record.md` |
| Review named PM methods and provenance | `_refs/operating-model/methodology-catalog.md` |
| Rank product options with a transparent method | `_refs/templates/plan/prioritization-decision.md` + `_refs/checklists/prioritization.md` |
| Diagnose a sustainable product growth constraint | `_refs/workflows/product-growth.md` + `_refs/checklists/growth-quality.md` + `_refs/templates/metrics/growth-plan.md` |
| Make a pricing, packaging, or economics decision | `_refs/workflows/commercial-decision.md` + `_refs/checklists/commercial-quality.md` + `_refs/templates/strategy/commercial-decision.md` |
| Build recurring sourced competitive intelligence | `_refs/workflows/competitive-intelligence.md` + `_refs/checklists/competitive-intelligence-quality.md` + `_refs/templates/strategy/competitive-intelligence-brief.md` |
| Review a go-to-market and adoption motion | `_refs/checklists/gtm-quality.md` + `_refs/workflows/go-to-market-adoption.md` |
| Run an interactive PM workshop | `_refs/workflows/workshop-facilitation.md` |
| Do external research with evidence quality | `_refs/workflows/research-evidence.md` |
| Turn raw customer research into traceable findings | `_refs/workflows/customer-discovery-synthesis.md` + `_refs/templates/learning/insight-summary.md` |
| Frame evidence-backed customer progress and alternatives | `_refs/workflows/jobs-to-be-done-analysis.md` |
| Persist evidence behind claims | `_refs/templates/docs/evidence-ledger.md` |
| Track initiative state across phases | `_refs/schemas/initiative-state.md` |
| Run AI-native PM loop | `_refs/workflows/ai-native-pm-loop.md` |
| Understand the Annifity loop | `_refs/operating-model/learning-loop.md` |
| Move from idea to prototype | `_refs/workflows/idea-to-prototype.md` |
| Design a validation experiment | `_refs/workflows/experiment-design.md` |
| Design and assess an AI product evaluation | `_refs/workflows/ai-evaluation.md` + `_refs/schemas/ai-evaluation-suite.md` + `_refs/templates/ai/evaluation-plan.md` + `_refs/checklists/ai-evaluation-release-gate.md` |
| Specify bounded AI behavior | `_refs/workflows/ai-product-specification.md` + `_refs/schemas/ai-behavior-contract.md` + `_refs/templates/ai/behavior-spec.md` |
| Frame AI suitability and risk before commitment | `_refs/workflows/ai-suitability-risk-framing.md` + `_refs/checklists/ai-suitability-risk-gate.md` + `_refs/templates/ai/opportunity-risk-brief.md` |
| Monitor deployed AI behavior | `_refs/workflows/ai-production-monitoring.md` + `_refs/schemas/ai-production-monitoring-plan.md` + `_refs/checklists/ai-production-readiness.md` |
| Make product strategy and portfolio choices | `_refs/workflows/product-strategy-portfolio.md` + `_refs/checklists/strategy-quality.md` |
| Review product analytics evidence | `_refs/workflows/product-analytics.md` + `_refs/checklists/product-analytics-quality.md` + `_refs/templates/metrics/product-analytics-review.md` |
| Plan go-to-market and adoption | `_refs/workflows/go-to-market-adoption.md` + `_refs/templates/release/go-to-market-plan.md` |
| Govern stakeholder decisions | `_refs/workflows/stakeholder-decision-governance.md` + `_refs/templates/strategy/stakeholder-decision-map.md` |
| Synthesize learning into a decision | `_refs/workflows/learning-synthesis.md` |
| Define metrics events | `_refs/schemas/metrics-event.md` |
| Size a market | `_refs/workflows/market-sizing.md` + `_refs/templates/strategy/market-sizing.md` |
| Apply finance or SaaS decision metrics | `_refs/checklists/finance-metrics.md` |
| Map opportunities before solutions | `_refs/templates/strategy/opportunity-solution-tree.md` |
| Improve AI workflow context design | `_refs/templates/ai/context-manifest.md` |
| Review stakeholder decision rights | `_refs/checklists/stakeholder-governance.md` |
| Review security, privacy, accessibility, or AI risk | `_refs/checklists/security-privacy-accessibility.md` |
