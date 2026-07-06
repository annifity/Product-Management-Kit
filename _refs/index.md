# Annifity References

Annifity keeps skill files short and loads detailed guidance from `_refs/` only when needed.

## Routing

- Operating model: `_refs/operating-model/`
- End-to-end process: `_refs/workflows/`
- Quality checks: `_refs/checklists/`
- Artifact templates: `_refs/templates/`
- Persisted record shapes: `_refs/schemas/`
- Tool-specific notes: `_refs/integrations/`

Skills should load only the relevant reference files for the current task.

## Reference Families

- Discovery and strategy: product discovery, research evidence, discovery interview plan, opportunity scoring, opportunity solution tree, solution exploration, market sizing, company research, business model canvas, metric tree.
- Business and finance: finance metrics, feature investment economics, pricing/ROI inputs, SaaS health signals, market sizing.
- Specification: BRD analysis, product spec, workflow map, data requirements, API contract, feature design, requirement analysis.
- Planning: prioritization, roadmap, story map, grooming questions, definition of ready, market/finance-informed sequencing.
- Delivery and review: sprint readiness, edge case review, risk register, traceability matrix, UAT, operational readiness.
- Shipping and change: release readiness, rollout plan, change governance, spec change context.
- Documentation and memory: docs index, evidence ledger, decision ledger, template registry, initiative state, memory schemas, context manifest for AI-native workflows.

## High-ROI Capability Routes

| Need | Reference |
|---|---|
| Analyze raw BRD or vague requirements | `_refs/workflows/requirement-analysis.md` + `_refs/checklists/business-analysis.md` |
| Map a workflow deeply | `_refs/templates/spec/workflow-spec.md` |
| Stress-test edge cases | `_refs/checklists/edge-cases.md` |
| Review product/project risk | `_refs/checklists/risk-review.md` + `_refs/templates/risk/risk-register.md` |
| Generate UAT with priority and pass criteria | `_refs/checklists/uat-coverage.md` + `_refs/templates/uat/test-case-register.md` |
| Score artifact quality before handoff | `_refs/checklists/artifact-quality-scorecard.md` |
| Run an interactive PM workshop | `_refs/workflows/workshop-facilitation.md` |
| Do external research with evidence quality | `_refs/workflows/research-evidence.md` |
| Persist evidence behind claims | `_refs/templates/docs/evidence-ledger.md` |
| Track initiative state across phases | `_refs/schemas/initiative-state.md` |
| Run AI-native PM loop | `_refs/workflows/ai-native-pm-loop.md` |
| Size a market | `_refs/workflows/market-sizing.md` + `_refs/templates/strategy/market-sizing.md` |
| Apply finance or SaaS decision metrics | `_refs/checklists/finance-metrics.md` |
| Map opportunities before solutions | `_refs/templates/strategy/opportunity-solution-tree.md` |
| Improve AI workflow context design | `_refs/templates/ai/context-manifest.md` |
