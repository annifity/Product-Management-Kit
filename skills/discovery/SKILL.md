---
name: discovery
description: Frame an unclear product problem or opportunity into a confirmed direction. Use for vague or solution-led stakeholder asks, early ideas, missing users/outcomes/evidence, customer interview or research synthesis, opportunity framing, solution exploration, workshops, market sizing, business-model questions, new external market/competitor/company research, or AI context design. Use `discovery` while evidence is raw or the problem or direction is unresolved; use `strategy` when evidence is sufficient for product or portfolio choices; use `competitive-intelligence` for a known category and recurring competitor baseline; use `learn` after evidence has been assessed; use `prototype` once a direction is clear enough to build to learn; use `knowledge` instead to retrieve existing facts.
---

# Discovery

Turn uncertainty into decision-ready problem framing before committing to an artifact or solution.

## Input Contract

Accept a raw idea, stakeholder ask, partial evidence, or existing context and reuse everything already supplied. Missing product decisions are discovery inputs, not facts to invent; ask one material question per turn by default and batch up to three only when the user explicitly requests a batch and the questions are independent.

## Process

1. Read relevant memories first when available:
   - `_refs/templates/memories/product-context.md`
   - `_refs/templates/memories/team-preferences.md`
   - `_refs/templates/memories/terminology.md`
   - `_refs/templates/memories/stakeholder-context.md`
2. Use the material-decision preflight to resolve the discovery consumer, evidence authority, artifact mode, and destination; retain unresolved product decisions as discovery questions rather than blocking discovery itself.
3. Clarify one material question at a time by default. Batch up to three only when explicitly requested and non-dependent. Prefer multiple-choice questions when the user is blocked.
4. Separate the real user problem from proposed solutions.
5. When the request embeds a preferred method, score, or solution, apply the PM decision challenge before accepting it; select the smallest method whose inputs are actually available.
6. For raw customer research, preserve source identity, consent boundaries,
   observations, counterevidence, and method limits before deriving findings or
   jobs; never invent a quote, participant, or pattern.
7. Identify users, pain, outcome, constraints, assumptions, evidence, success metrics, and non-goals.
8. For discovery work, define what must be learned before solutioning.
9. For solution exploration, diverge before converging and make trade-offs explicit.
10. Apply source-backed minimality and resolve the Discovery Gate approval through `_refs/operating-model/phase-gates.md`. Reuse a valid recorded approval only while its source, evidence, and material decisions remain unchanged; otherwise ask for a fresh decision before moving to `brief`, `prototype`, `experiment`, `learn`, or `spec`.

## Output

Return a compact discovery brief:

- Problem statement
- Target users and jobs
- Desired outcome
- Candidate approaches
- Evidence and confidence
- Research findings, counterevidence, and source trace when synthesis is requested
- Customer jobs and circumstances when supported by evidence
- Scope in / scope out
- Known constraints
- Assumptions
- Success metrics
- Open questions
- AI suitability, minimum autonomy, risk tier, and rejected non-AI alternatives when AI is proposed

## Reference Routing

Load only the references whose stated condition matches the request:

- **Core control:** use `_refs/operating-model/routing.md` for an ambiguous front door. Resolve `_refs/schemas/artifact-generation-contract.md` through `_refs/operating-model/artifact-profile-resolution.md`, run `_refs/checklists/material-decision-preflight.md`, and apply `_refs/checklists/source-backed-minimality.md`. Use `_refs/operating-model/learning-loop.md`, `_refs/operating-model/builder-packs.md`, and `_refs/operating-model/phase-gates.md` only for lifecycle, packaged handoff, or progression.
- **Customer evidence:** use `_refs/workflows/product-discovery.md` for strategic or feature discovery; `_refs/workflows/customer-discovery-synthesis.md` for raw research synthesis; `_refs/workflows/jobs-to-be-done-analysis.md` for evidence-backed customer jobs; `_refs/templates/learning/insight-summary.md` for a source-linked insight; and `_refs/templates/discovery/interview-plan.md` when preparing interviews.
- **Facilitation and external research:** use `_refs/workflows/workshop-facilitation.md` for interactive sessions and `_refs/workflows/research-evidence.md` when external facts, market, competitor, or company claims influence the decision.
- **Problem and opportunity analysis:** use `_refs/checklists/brainstorming-readiness.md` before delivery handoff, `_refs/checklists/business-analysis.md` for problem structure, and `_refs/checklists/opportunity-scoring.md` for comparison.
- **Method and decision integrity:** use `_refs/workflows/pm-decision-challenge.md`, `_refs/templates/skills/method-selection-record.md`, and `_refs/checklists/pm-decision-quality.md` when a requested framework, score, solution, or evidence gap could materially change the direction.
- **Commercial strategy:** use `_refs/workflows/market-sizing.md` with `_refs/templates/strategy/market-sizing.md` for TAM/SAM/SOM; use `_refs/checklists/finance-metrics.md` for pricing, ROI, retention, SaaS health, channel economics, or investment economics.
- **Solution and output shape:** use `_refs/workflows/solution-exploration.md` when the problem is clear but the solution is not; use `_refs/templates/discovery/discovery-brief.md` for validated discovery output and `_refs/templates/strategy/opportunity-solution-tree.md` for solution-led opportunity mapping.
- **Company or business model:** use `_refs/templates/strategy/company-research-brief.md` for company, competitor, partnership, or market-entry research and `_refs/templates/strategy/business-model-canvas.md` for business-model work.
- **Metrics, AI, and delivery transition:** use `_refs/templates/metrics/metric-tree.md` for metric structure, `_refs/templates/ai/context-manifest.md` for AI context and agent handoffs, `_refs/workflows/ai-native-pm-loop.md` for stateful multi-phase AI-native work, and `_refs/workflows/discovery-to-spec.md` for delivery transition.
- **AI suitability:** when AI is proposed, use `_refs/workflows/ai-suitability-risk-framing.md`, `_refs/checklists/ai-suitability-risk-gate.md`, and `_refs/templates/ai/opportunity-risk-brief.md` before committing to AI or an autonomy level.

## Handoff

When the user confirms a discovery package containing the problem, users,
outcome, scope, evidence limits, assumptions, and open questions, route it to
`brief` for alignment, `strategy` for product or portfolio choices, `prototype`
or `experiment` for learning, `learn` when assessed discovery evidence needs
interpretation, or `spec` only when the
delivery-entry gate is satisfied. Ask `docs` to save a session note and
`memories` to persist durable context.
