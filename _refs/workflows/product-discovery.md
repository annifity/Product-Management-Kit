# Product Discovery Workflow

Use before specification when the team must answer "should we build this?" before "how do we build this?"

## Track Selection

- Strategic discovery: quarterly planning, market signal, strategic shift, new opportunity space.
- Feature-level discovery: roadmap item, stakeholder request, high uncertainty about a feature problem.
- Fast path: if a related opportunity already has strong evidence, start from synthesis instead of repeating research.

## Strategic Discovery

1. Capture market, customer, operational, competitor, or stakeholder signals.
2. Frame an opportunity hypothesis and "how might we" question.
3. Run lightweight research from at least three independent signals using `_refs/workflows/research-evidence.md` for material external claims.
4. When the decision depends on market size or business case, use `_refs/workflows/market-sizing.md` and `_refs/checklists/finance-metrics.md`.
5. Use `_refs/templates/strategy/opportunity-solution-tree.md` when stakeholders jump to a solution before the opportunity is clear.
6. Score impact, confidence, and strategic fit using `_refs/checklists/opportunity-scoring.md`.
7. Add a roadmap candidate or park the opportunity with rationale.

## Feature-Level Discovery

1. Write the problem hypothesis and research questions.
2. Define what "validated" means before collecting evidence.
3. Plan interviews with `_refs/templates/discovery/interview-plan.md`, desk research, data review, or operational observation.
4. Synthesize raw evidence with
   `_refs/workflows/customer-discovery-synthesis.md`; preserve source IDs,
   counterevidence, privacy constraints, and method limitations.
5. Use `_refs/workflows/jobs-to-be-done-analysis.md` when the product decision
   depends on customer progress, circumstances, alternatives, or barriers.
6. Recommend solution direction without designing the full solution.
7. Produce `_refs/templates/discovery/discovery-brief.md` and hand off to `brief`, `prototype`, `experiment`, or `spec` based on confidence and delivery readiness.

## Gates

- Do not propose a solution before the problem can be stated without solution language.
- Do not mark discovery complete without evidence and confidence.
- If confidence is low, park, research more, or explicitly accept the uncertainty.
- Do not treat market size as product validation; pair market sizing with customer evidence.
- Do not treat uncited external claims as facts; mark them as assumptions or low-quality signals.
- Do not turn paraphrases into quotations, count repeated notes from one
  participant as independent support, or hide contradictory evidence.
