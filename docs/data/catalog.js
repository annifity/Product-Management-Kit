window.ANNIFITY_CATALOG = {
    "generatedAt":  "2026-07-06T14:01:11Z",
    "summary":  {
                    "skillCount":  17,
                    "referenceCount":  146,
                    "workflowCount":  19,
                    "checklistCount":  25,
                    "templateCount":  70
                },
    "skills":  [
                   {
                       "name":  "brief",
                       "description":  "Create a concise product-direction brief or Product Requirements Outline from confirmed discovery. Use for a one-page alignment artifact covering problem, users, goals, scope, metrics, assumptions, and risks before prototype, experiment, or detailed requirements. Use `brief` for pre-delivery direction; use `prd` for a formal PRD/BRD and `spec` for implementation-ready rules and behavior.",
                       "source":  "skills/brief/SKILL.md",
                       "references":  [
                                          "_refs/checklists/business-analysis.md",
                                          "_refs/checklists/edge-cases.md",
                                          "_refs/checklists/material-decision-preflight.md",
                                          "_refs/checklists/source-backed-minimality.md",
                                          "_refs/checklists/stakeholder-governance.md",
                                          "_refs/operating-model/artifact-profile-resolution.md",
                                          "_refs/operating-model/authoritative-baseline-resolution.md",
                                          "_refs/operating-model/builder-packs.md",
                                          "_refs/operating-model/learning-loop.md",
                                          "_refs/operating-model/phase-gates.md",
                                          "_refs/operating-model/routing.md",
                                          "_refs/schemas/artifact-generation-contract.md",
                                          "_refs/templates/ai/context-manifest.md",
                                          "_refs/templates/metrics/metric-tree.md",
                                          "_refs/templates/prd/one-pager.md",
                                          "_refs/workflows/ai-native-pm-loop.md"
                                      ]
                   },
                   {
                       "name":  "change",
                       "description":  "Assess and apply controlled changes to an existing PRD, BRD, spec, user story, UAT package, Jira/Confluence record, or release baseline. Use when scope or requirements change mid-flight and impact analysis, versioned edits, traceable patching, changelog, or stakeholder notification is needed. Use `execution` for delivery clarification that does not change the baseline; route here when committed scope, acceptance, or user-visible behavior changes.",
                       "source":  "skills/change/SKILL.md",
                       "references":  [
                                          "_refs/checklists/material-decision-preflight.md",
                                          "_refs/checklists/negative-completeness.md",
                                          "_refs/checklists/source-backed-minimality.md",
                                          "_refs/checklists/stakeholder-governance.md",
                                          "_refs/integrations/confluence.md",
                                          "_refs/integrations/jira.md",
                                          "_refs/operating-model/artifact-profile-resolution.md",
                                          "_refs/operating-model/authoritative-baseline-resolution.md",
                                          "_refs/operating-model/routing.md",
                                          "_refs/schemas/artifact-generation-contract.md",
                                          "_refs/schemas/artifact-state-registry.md",
                                          "_refs/schemas/mutation-preview.md",
                                          "_refs/templates/change/changelog.md",
                                          "_refs/templates/change/change-plan.md",
                                          "_refs/templates/change/impact-analysis.md",
                                          "_refs/templates/change/spec-change-context.md",
                                          "_refs/workflows/change-governance.md",
                                          "_refs/workflows/local-mutation-safety.md"
                                      ]
                   },
                   {
                       "name":  "discovery",
                       "description":  "Frame an unclear product problem or opportunity into a confirmed direction. Use for vague or solution-led stakeholder asks, early ideas, missing users/outcomes/evidence, product strategy, opportunity framing, solution exploration, workshops, market sizing, business-model questions, research, or AI context design. Use `discovery` while the problem or direction is unresolved; use `prototype` once a direction is clear enough to build to learn.",
                       "source":  "skills/discovery/SKILL.md",
                       "references":  [
                                          "_refs/checklists/brainstorming-readiness.md",
                                          "_refs/checklists/business-analysis.md",
                                          "_refs/checklists/finance-metrics.md",
                                          "_refs/checklists/material-decision-preflight.md",
                                          "_refs/checklists/opportunity-scoring.md",
                                          "_refs/checklists/source-backed-minimality.md",
                                          "_refs/operating-model/artifact-profile-resolution.md",
                                          "_refs/operating-model/builder-packs.md",
                                          "_refs/operating-model/learning-loop.md",
                                          "_refs/operating-model/phase-gates.md",
                                          "_refs/operating-model/routing.md",
                                          "_refs/schemas/artifact-generation-contract.md",
                                          "_refs/templates/ai/context-manifest.md",
                                          "_refs/templates/discovery/discovery-brief.md",
                                          "_refs/templates/discovery/interview-plan.md",
                                          "_refs/templates/memories/product-context.md",
                                          "_refs/templates/memories/stakeholder-context.md",
                                          "_refs/templates/memories/team-preferences.md",
                                          "_refs/templates/memories/terminology.md",
                                          "_refs/templates/metrics/metric-tree.md",
                                          "_refs/templates/strategy/business-model-canvas.md",
                                          "_refs/templates/strategy/company-research-brief.md",
                                          "_refs/templates/strategy/market-sizing.md",
                                          "_refs/templates/strategy/opportunity-solution-tree.md",
                                          "_refs/workflows/ai-native-pm-loop.md",
                                          "_refs/workflows/discovery-to-spec.md",
                                          "_refs/workflows/market-sizing.md",
                                          "_refs/workflows/product-discovery.md",
                                          "_refs/workflows/research-evidence.md",
                                          "_refs/workflows/solution-exploration.md",
                                          "_refs/workflows/workshop-facilitation.md"
                                      ]
                   },
                   {
                       "name":  "docs",
                       "description":  "Create, update, version, index, link, summarize, or export Annifity working artifacts under `.annifity/docs/`. Use as a supporting skill alongside PO workflows, or as the primary skill when the request is specifically document storage, indexing, versioning, or export. Use `knowledge` for read-only retrieval and `memories` for durable cross-session context rather than artifact management.",
                       "source":  "skills/docs/SKILL.md",
                       "references":  [
                                          "_refs/checklists/material-decision-preflight.md",
                                          "_refs/checklists/negative-completeness.md",
                                          "_refs/checklists/source-backed-minimality.md",
                                          "_refs/operating-model/artifact-lifecycle.md",
                                          "_refs/operating-model/artifact-profile-resolution.md",
                                          "_refs/operating-model/authoritative-baseline-resolution.md",
                                          "_refs/schemas/artifact-generation-contract.md",
                                          "_refs/schemas/artifact-index.md",
                                          "_refs/schemas/artifact-state-registry.md",
                                          "_refs/schemas/decision-record.md",
                                          "_refs/schemas/doc-frontmatter.md",
                                          "_refs/schemas/drawio-validation-manifest.md",
                                          "_refs/schemas/initiative-state.md",
                                          "_refs/schemas/mutation-preview.md",
                                          "_refs/templates/docs/decision-ledger.md",
                                          "_refs/templates/docs/decision-log.md",
                                          "_refs/templates/docs/docs-index.md",
                                          "_refs/templates/docs/evidence-ledger.md",
                                          "_refs/templates/docs/generation-receipt.md",
                                          "_refs/templates/docs/release-note.md",
                                          "_refs/templates/docs/session-note.md",
                                          "_refs/templates/docs/template-registry.md",
                                          "_refs/workflows/local-mutation-safety.md"
                                      ]
                   },
                   {
                       "name":  "execution",
                       "description":  "Provide product-owner decisions and requirement clarification during active implementation after planning. Use for developer questions, blocked tickets, acceptance interpretation, dependency or trade-off decisions, defect triage, and Jira/Confluence context handoff. Use `change` when the answer modifies committed scope, acceptance criteria, or user-visible behavior; use `validate` for a readiness or quality audit rather than day-to-day delivery support.",
                       "source":  "skills/execution/SKILL.md",
                       "references":  [
                                          "_refs/checklists/stakeholder-governance.md",
                                          "_refs/integrations/jira.md",
                                          "_refs/operating-model/authoritative-baseline-resolution.md",
                                          "_refs/operating-model/phase-gates.md",
                                          "_refs/operating-model/routing.md",
                                          "_refs/templates/change/spec-change-context.md",
                                          "_refs/templates/docs/decision-ledger.md",
                                          "_refs/templates/docs/decision-log.md",
                                          "_refs/workflows/change-governance.md",
                                          "_refs/workflows/execution-support.md"
                                      ]
                   },
                   {
                       "name":  "experiment",
                       "description":  "Design an evidence-producing product experiment from a hypothesis, brief, or prototype. Use when the user needs an experiment method, participants or sample size, success metrics, tracking, guardrails, or precommitted go/iterate/stop criteria before production delivery. Use `validate` after evidence exists to judge results; use `uat` to verify acceptance of already committed behavior.",
                       "source":  "skills/experiment/SKILL.md",
                       "references":  [
                                          "_refs/checklists/material-decision-preflight.md",
                                          "_refs/checklists/security-privacy-accessibility.md",
                                          "_refs/checklists/source-backed-minimality.md",
                                          "_refs/operating-model/artifact-profile-resolution.md",
                                          "_refs/operating-model/authoritative-baseline-resolution.md",
                                          "_refs/operating-model/builder-packs.md",
                                          "_refs/operating-model/learning-loop.md",
                                          "_refs/operating-model/phase-gates.md",
                                          "_refs/schemas/artifact-generation-contract.md",
                                          "_refs/schemas/metrics-event.md",
                                          "_refs/templates/docs/evidence-ledger.md",
                                          "_refs/templates/experiment/decision-criteria.md",
                                          "_refs/templates/experiment/experiment-plan.md",
                                          "_refs/templates/experiment/hypothesis.md",
                                          "_refs/templates/experiment/sample-size.md",
                                          "_refs/templates/experiment/tracking-plan.md",
                                          "_refs/workflows/experiment-design.md"
                                      ]
                   },
                   {
                       "name":  "knowledge",
                       "description":  "Retrieve and synthesize existing product knowledge from local docs, memories, decision records, Jira, Confluence, pasted context, or workspace connectors, with source citations and confidence. Use when the user asks what exists, where it is documented, who owns it, or why a decision was made. This is read-oriented; use `docs` to write or index artifacts and `memories` to persist durable context.",
                       "source":  "skills/knowledge/SKILL.md",
                       "references":  [
                                          "_refs/integrations/confluence.md",
                                          "_refs/integrations/jira.md",
                                          "_refs/operating-model/authoritative-baseline-resolution.md",
                                          "_refs/schemas/initiative-state.md",
                                          "_refs/templates/docs/decision-ledger.md",
                                          "_refs/templates/docs/decision-log.md",
                                          "_refs/templates/docs/evidence-ledger.md",
                                          "_refs/templates/memories/decisions.md"
                                      ]
                   },
                   {
                       "name":  "learn",
                       "description":  "Synthesize completed discovery, prototype, experiment, validation, release, or post-ship evidence into reusable insight and a product decision. Use for insight summaries, retrospectives, decision memos, roadmap recommendations, and next-loop recommendations after evidence has been assessed. Use `validate` for the readiness/result verdict itself; use `learn` to interpret what the evidence means and what to do next.",
                       "source":  "skills/learn/SKILL.md",
                       "references":  [
                                          "_refs/checklists/material-decision-preflight.md",
                                          "_refs/checklists/source-backed-minimality.md",
                                          "_refs/operating-model/artifact-profile-resolution.md",
                                          "_refs/operating-model/authoritative-baseline-resolution.md",
                                          "_refs/operating-model/builder-packs.md",
                                          "_refs/operating-model/learning-loop.md",
                                          "_refs/operating-model/phase-gates.md",
                                          "_refs/schemas/artifact-generation-contract.md",
                                          "_refs/templates/docs/decision-ledger.md",
                                          "_refs/templates/learning/decision-memo.md",
                                          "_refs/templates/learning/insight-summary.md",
                                          "_refs/templates/learning/product-retrospective.md",
                                          "_refs/templates/learning/roadmap-recommendation.md",
                                          "_refs/templates/memories/decision-outcomes.md",
                                          "_refs/templates/prototype/prototype-feedback-summary.md",
                                          "_refs/workflows/learning-synthesis.md",
                                          "_refs/workflows/prototype-first.md"
                                      ]
                   },
                   {
                       "name":  "memories",
                       "description":  "Read and persist durable Annifity context under `.annifity/memories/`, including stable product context, terminology, team preferences, stakeholder constraints, confirmed decisions and outcomes, initiative state, lessons, and open questions. Use as workflow support, or primarily when the user asks to remember or update cross-session context. Use `knowledge` for broad retrieval and `docs` for versioned product artifacts.",
                       "source":  "skills/memories/SKILL.md",
                       "references":  [
                                          "_refs/checklists/negative-completeness.md",
                                          "_refs/schemas/artifact-generation-contract.md",
                                          "_refs/schemas/decision-record.md",
                                          "_refs/schemas/initiative-state.md",
                                          "_refs/schemas/memory-record.md",
                                          "_refs/schemas/mutation-preview.md",
                                          "_refs/templates/docs/decision-ledger.md",
                                          "_refs/templates/memories/artifact-generation-contract.md",
                                          "_refs/templates/memories/decision-outcomes.md",
                                          "_refs/templates/memories/decisions.md",
                                          "_refs/templates/memories/open-questions.md",
                                          "_refs/templates/memories/product-context.md",
                                          "_refs/templates/memories/stakeholder-context.md",
                                          "_refs/templates/memories/team-preferences.md",
                                          "_refs/templates/memories/terminology.md",
                                          "_refs/workflows/local-mutation-safety.md"
                                      ]
                   },
                   {
                       "name":  "plan",
                       "description":  "Convert a confirmed product spec into an actionable delivery plan. Use for prioritization or investment decisions, roadmap and release slices, delivery-level epic maps, milestones, dependencies, grooming questions, and team handoff sequencing. This skill owns cross-epic slicing and sequence; use `user-story` for ticket-ready Jira epics, stories, and acceptance criteria, `spec` when requirements are unstable, and `execution` after delivery begins.",
                       "source":  "skills/plan/SKILL.md",
                       "references":  [
                                          "_refs/checklists/definition-of-ready.md",
                                          "_refs/checklists/finance-metrics.md",
                                          "_refs/checklists/material-decision-preflight.md",
                                          "_refs/checklists/opportunity-scoring.md",
                                          "_refs/checklists/prioritization.md",
                                          "_refs/checklists/risk-review.md",
                                          "_refs/checklists/security-privacy-accessibility.md",
                                          "_refs/checklists/ship-readiness.md",
                                          "_refs/checklists/source-backed-minimality.md",
                                          "_refs/checklists/stakeholder-governance.md",
                                          "_refs/operating-model/artifact-profile-resolution.md",
                                          "_refs/operating-model/authoritative-baseline-resolution.md",
                                          "_refs/operating-model/builder-packs.md",
                                          "_refs/operating-model/phase-gates.md",
                                          "_refs/operating-model/routing.md",
                                          "_refs/schemas/artifact-generation-contract.md",
                                          "_refs/templates/plan/grooming-questions.md",
                                          "_refs/templates/plan/product-roadmap.md",
                                          "_refs/templates/user-story/story-map.md",
                                          "_refs/workflows/market-sizing.md",
                                          "_refs/workflows/spec-to-delivery-plan.md"
                                      ]
                   },
                   {
                       "name":  "prd",
                       "description":  "Create, revise, translate, or export a formal PRD, BRD, requirements one-pager, Confluence-ready requirements page, or PRD from PRO plus client feedback. Use for direct revisions only while the artifact is draft/unbaselined or accepted scope remains unchanged; route committed baseline, scope, acceptance, or user-visible behavior changes to `change`. Use `brief` for a pre-delivery alignment one-pager, `spec` for the detailed delivery source of truth, and `validate` for an independent readiness verdict.",
                       "source":  "skills/prd/SKILL.md",
                       "references":  [
                                          "_refs/checklists/business-analysis.md",
                                          "_refs/checklists/finance-metrics.md",
                                          "_refs/checklists/material-decision-preflight.md",
                                          "_refs/checklists/source-backed-minimality.md",
                                          "_refs/checklists/spec-quality.md",
                                          "_refs/checklists/stakeholder-governance.md",
                                          "_refs/integrations/confluence.md",
                                          "_refs/operating-model/artifact-profile-resolution.md",
                                          "_refs/operating-model/authoritative-baseline-resolution.md",
                                          "_refs/operating-model/routing.md",
                                          "_refs/schemas/artifact-generation-contract.md",
                                          "_refs/templates/brd/default-brd.md",
                                          "_refs/templates/docs/template-registry.md",
                                          "_refs/templates/metrics/metric-tree.md",
                                          "_refs/templates/prd/confluence-html.md",
                                          "_refs/templates/prd/confluence-html-strict.md",
                                          "_refs/templates/prd/default-prd.md",
                                          "_refs/templates/prd/one-pager.md",
                                          "_refs/templates/prd/prd-export-html.html",
                                          "_refs/templates/prd/prd-from-pro-feedback.md",
                                          "_refs/templates/prototype/prototype-feedback-summary.md",
                                          "_refs/templates/strategy/company-research-brief.md",
                                          "_refs/templates/strategy/market-sizing.md",
                                          "_refs/workflows/prototype-first.md",
                                          "_refs/workflows/research-evidence.md"
                                      ]
                   },
                   {
                       "name":  "prototype",
                       "description":  "Create a build-to-learn prototype package from a sufficiently clear product direction. Use for a PRO (Prototyping Requirements One-Pager), minimum user flow, screen list, wireframe descriptions, clickable mockup or frontend-builder prompt, and prototype handoff before experiment, PRD, or spec. If a raw idea still lacks a clear problem, user, or outcome, use `discovery` first; this skill prototypes a direction rather than resolving product strategy.",
                       "source":  "skills/prototype/SKILL.md",
                       "references":  [
                                          "_refs/checklists/material-decision-preflight.md",
                                          "_refs/checklists/pro-quality.md",
                                          "_refs/checklists/source-backed-minimality.md",
                                          "_refs/operating-model/artifact-profile-resolution.md",
                                          "_refs/operating-model/authoritative-baseline-resolution.md",
                                          "_refs/operating-model/builder-packs.md",
                                          "_refs/operating-model/learning-loop.md",
                                          "_refs/operating-model/phase-gates.md",
                                          "_refs/schemas/artifact-generation-contract.md",
                                          "_refs/templates/ai/context-manifest.md",
                                          "_refs/templates/prototype/claude-code-prompt.md",
                                          "_refs/templates/prototype/lovable-bolt-prompt.md",
                                          "_refs/templates/prototype/prototype-feedback-summary.md",
                                          "_refs/templates/prototype/prototyping-requirements-one-pager.md",
                                          "_refs/templates/prototype/screen-list.md",
                                          "_refs/templates/prototype/user-flow.md",
                                          "_refs/templates/prototype/wireframe-description.md",
                                          "_refs/workflows/idea-to-prototype.md",
                                          "_refs/workflows/prototype-first.md"
                                      ]
                   },
                   {
                       "name":  "ship",
                       "description":  "Prepare and coordinate a product release, rollout, retirement, or final stakeholder/support handoff. Use when the requested outcome is a ship package such as a launch or EOL plan, release notes, rollback/support notes, final document bundle, UAT signoff summary, or post-ship capture. Use `validate` for a read-only readiness audit without package creation and `uat` to create or execute acceptance tests.",
                       "source":  "skills/ship/SKILL.md",
                       "references":  [
                                          "_refs/checklists/material-decision-preflight.md",
                                          "_refs/checklists/operational-readiness.md",
                                          "_refs/checklists/security-privacy-accessibility.md",
                                          "_refs/checklists/ship-readiness.md",
                                          "_refs/checklists/source-backed-minimality.md",
                                          "_refs/checklists/stakeholder-governance.md",
                                          "_refs/operating-model/artifact-profile-resolution.md",
                                          "_refs/operating-model/authoritative-baseline-resolution.md",
                                          "_refs/operating-model/builder-packs.md",
                                          "_refs/operating-model/phase-gates.md",
                                          "_refs/operating-model/routing.md",
                                          "_refs/schemas/artifact-generation-contract.md",
                                          "_refs/templates/docs/release-note.md",
                                          "_refs/templates/release/rollout-plan.md",
                                          "_refs/templates/risk/risk-register.md",
                                          "_refs/templates/traceability/rtm.md",
                                          "_refs/workflows/release-readiness.md"
                                      ]
                   },
                   {
                       "name":  "spec",
                       "description":  "Turn confirmed product context into the detailed delivery source of truth. Use for a product or workflow specification with scoped requirements, business rules, states, permissions, edge cases, data/API behavior, non-functional requirements, assumptions, risks, and traceability before planning. Use `brief` while only direction-level alignment is needed, `prd` for a formal stakeholder requirements document, and `plan` only after the spec is stable.",
                       "source":  "skills/spec/SKILL.md",
                       "references":  [
                                          "_refs/checklists/artifact-quality-scorecard.md",
                                          "_refs/checklists/business-analysis.md",
                                          "_refs/checklists/definition-of-ready.md",
                                          "_refs/checklists/edge-cases.md",
                                          "_refs/checklists/material-decision-preflight.md",
                                          "_refs/checklists/risk-review.md",
                                          "_refs/checklists/security-privacy-accessibility.md",
                                          "_refs/checklists/solution-quality.md",
                                          "_refs/checklists/source-backed-minimality.md",
                                          "_refs/checklists/spec-quality.md",
                                          "_refs/checklists/stakeholder-governance.md",
                                          "_refs/operating-model/artifact-profile-resolution.md",
                                          "_refs/operating-model/authoritative-baseline-resolution.md",
                                          "_refs/operating-model/builder-packs.md",
                                          "_refs/operating-model/phase-gates.md",
                                          "_refs/operating-model/routing.md",
                                          "_refs/schemas/artifact-generation-contract.md",
                                          "_refs/templates/brd/default-brd.md",
                                          "_refs/templates/metrics/metric-tree.md",
                                          "_refs/templates/spec/api-contract.md",
                                          "_refs/templates/spec/data-requirements.md",
                                          "_refs/templates/spec/product-spec.md",
                                          "_refs/templates/spec/workflow-spec.md",
                                          "_refs/workflows/ai-native-pm-loop.md",
                                          "_refs/workflows/discovery-to-spec.md",
                                          "_refs/workflows/feature-design.md",
                                          "_refs/workflows/requirement-analysis.md",
                                          "_refs/workflows/research-evidence.md"
                                      ]
                   },
                   {
                       "name":  "uat",
                       "description":  "Create, refine, execute, or record User Acceptance Testing plans, scenario tests, and test-case registers from confirmed requirements or stories. Use for role-based happy, unhappy, boundary, permission, and NFR scenarios, traceability, execution logs, and acceptance results. Use `validate` for an independent audit of UAT coverage/readiness and `ship` for the final release package or signoff summary.",
                       "source":  "skills/uat/SKILL.md",
                       "references":  [
                                          "_refs/checklists/acceptance-criteria-quality.md",
                                          "_refs/checklists/material-decision-preflight.md",
                                          "_refs/checklists/security-privacy-accessibility.md",
                                          "_refs/checklists/source-backed-minimality.md",
                                          "_refs/checklists/uat-coverage.md",
                                          "_refs/operating-model/artifact-profile-resolution.md",
                                          "_refs/operating-model/authoritative-baseline-resolution.md",
                                          "_refs/operating-model/builder-packs.md",
                                          "_refs/schemas/artifact-generation-contract.md",
                                          "_refs/templates/traceability/rtm.md",
                                          "_refs/templates/uat/scenario-test.md",
                                          "_refs/templates/uat/test-case-register.md",
                                          "_refs/templates/uat/uat-plan.md"
                                      ]
                   },
                   {
                       "name":  "user-story",
                       "description":  "Create, split, refine, revise, or export ticket-ready Jira epic definitions, implementation-ready user stories, story maps, and acceptance criteria from a confirmed PRD, spec, roadmap item, or delivery plan. Use for INVEST splitting, Jira-ready tickets, and Given/When/Then criteria. Use `plan` for epic maps, sequencing, milestones, and dependencies; use `validate` for an independent story-quality/readiness verdict rather than authoring or correction.",
                       "source":  "skills/user-story/SKILL.md",
                       "references":  [
                                          "_refs/checklists/acceptance-criteria-quality.md",
                                          "_refs/checklists/material-decision-preflight.md",
                                          "_refs/checklists/source-backed-minimality.md",
                                          "_refs/checklists/story-quality-invest.md",
                                          "_refs/checklists/story-splitting.md",
                                          "_refs/integrations/confluence.md",
                                          "_refs/integrations/jira.md",
                                          "_refs/operating-model/artifact-profile-resolution.md",
                                          "_refs/operating-model/authoritative-baseline-resolution.md",
                                          "_refs/operating-model/builder-packs.md",
                                          "_refs/schemas/artifact-generation-contract.md",
                                          "_refs/templates/traceability/rtm.md",
                                          "_refs/templates/user-story/acceptance-criteria-gwt.md",
                                          "_refs/templates/user-story/confluence-html.md",
                                          "_refs/templates/user-story/default-user-story.md",
                                          "_refs/templates/user-story/jira-epic.md",
                                          "_refs/templates/user-story/jira-user-story.md",
                                          "_refs/templates/user-story/story-map.md",
                                          "_refs/workflows/workshop-facilitation.md"
                                      ]
                   },
                   {
                       "name":  "validate",
                       "description":  "Audit an existing product artifact, evidence set, delivery package, or Annifity canonical skill and return a readiness or quality verdict with findings. Use when the user asks to review, validate, assess readiness, check completeness, consistency, testability, coverage, traceability, risk, or go/no-go status. Use `prd`, `spec`, `user-story`, `uat`, or `ship` to create or substantially rewrite those artifacts; use `validate` as the primary route for an independent review, with domain skills applied only for requested fixes.",
                       "source":  "skills/validate/SKILL.md",
                       "references":  [
                                          "_refs/checklists/acceptance-criteria-quality.md",
                                          "_refs/checklists/artifact-quality-scorecard.md",
                                          "_refs/checklists/business-analysis.md",
                                          "_refs/checklists/definition-of-done.md",
                                          "_refs/checklists/definition-of-ready.md",
                                          "_refs/checklists/edge-cases.md",
                                          "_refs/checklists/material-decision-preflight.md",
                                          "_refs/checklists/negative-completeness.md",
                                          "_refs/checklists/operational-readiness.md",
                                          "_refs/checklists/risk-review.md",
                                          "_refs/checklists/security-privacy-accessibility.md",
                                          "_refs/checklists/ship-readiness.md",
                                          "_refs/checklists/skill-quality.md",
                                          "_refs/checklists/source-backed-minimality.md",
                                          "_refs/checklists/spec-quality.md",
                                          "_refs/checklists/stakeholder-governance.md",
                                          "_refs/checklists/story-quality-invest.md",
                                          "_refs/checklists/uat-coverage.md",
                                          "_refs/integrations/claude.md",
                                          "_refs/integrations/codex.md",
                                          "_refs/integrations/copilot.md",
                                          "_refs/integrations/cursor.md",
                                          "_refs/operating-model/annifity-principles.md",
                                          "_refs/operating-model/artifact-profile-resolution.md",
                                          "_refs/operating-model/authoritative-baseline-resolution.md",
                                          "_refs/operating-model/language-policy.md",
                                          "_refs/operating-model/phase-gates.md",
                                          "_refs/operating-model/routing.md",
                                          "_refs/operating-model/skill-authoring.md",
                                          "_refs/schemas/artifact-generation-contract.md",
                                          "_refs/schemas/context-consistency-manifest.md",
                                          "_refs/schemas/drawio-validation-manifest.md",
                                          "_refs/schemas/first-pass-quality-dashboard.md",
                                          "_refs/schemas/initiative-state.md",
                                          "_refs/schemas/mutation-preview.md",
                                          "_refs/schemas/semantic-forward-test.md",
                                          "_refs/schemas/session-rework-observation.md",
                                          "_refs/schemas/skill-output-contract.md",
                                          "_refs/templates/experiment/decision-criteria.md",
                                          "_refs/templates/prototype/prototype-feedback-summary.md",
                                          "_refs/templates/risk/risk-register.md",
                                          "_refs/templates/skills/skill-template.md",
                                          "_refs/templates/traceability/rtm.md",
                                          "_refs/workflows/local-mutation-safety.md",
                                          "_refs/workflows/prototype-first.md",
                                          "_refs/workflows/sprint-readiness.md"
                                      ]
                   }
               ],
    "references":  [
                       {
                           "path":  "_refs/checklists/acceptance-criteria-quality.md",
                           "group":  "checklists",
                           "name":  "acceptance-criteria-quality",
                           "lines":  125
                       },
                       {
                           "path":  "_refs/checklists/artifact-quality-scorecard.md",
                           "group":  "checklists",
                           "name":  "artifact-quality-scorecard",
                           "lines":  37
                       },
                       {
                           "path":  "_refs/checklists/brainstorming-readiness.md",
                           "group":  "checklists",
                           "name":  "brainstorming-readiness",
                           "lines":  12
                       },
                       {
                           "path":  "_refs/checklists/business-analysis.md",
                           "group":  "checklists",
                           "name":  "business-analysis",
                           "lines":  99
                       },
                       {
                           "path":  "_refs/checklists/definition-of-done.md",
                           "group":  "checklists",
                           "name":  "definition-of-done",
                           "lines":  14
                       },
                       {
                           "path":  "_refs/checklists/definition-of-ready.md",
                           "group":  "checklists",
                           "name":  "definition-of-ready",
                           "lines":  16
                       },
                       {
                           "path":  "_refs/checklists/edge-cases.md",
                           "group":  "checklists",
                           "name":  "edge-cases",
                           "lines":  59
                       },
                       {
                           "path":  "_refs/checklists/finance-metrics.md",
                           "group":  "checklists",
                           "name":  "finance-metrics",
                           "lines":  61
                       },
                       {
                           "path":  "_refs/checklists/material-decision-preflight.md",
                           "group":  "checklists",
                           "name":  "material-decision-preflight",
                           "lines":  96
                       },
                       {
                           "path":  "_refs/checklists/negative-completeness.md",
                           "group":  "checklists",
                           "name":  "negative-completeness",
                           "lines":  57
                       },
                       {
                           "path":  "_refs/checklists/operational-readiness.md",
                           "group":  "checklists",
                           "name":  "operational-readiness",
                           "lines":  14
                       },
                       {
                           "path":  "_refs/checklists/opportunity-scoring.md",
                           "group":  "checklists",
                           "name":  "opportunity-scoring",
                           "lines":  23
                       },
                       {
                           "path":  "_refs/checklists/prioritization.md",
                           "group":  "checklists",
                           "name":  "prioritization",
                           "lines":  43
                       },
                       {
                           "path":  "_refs/checklists/pro-quality.md",
                           "group":  "checklists",
                           "name":  "pro-quality",
                           "lines":  32
                       },
                       {
                           "path":  "_refs/checklists/risk-review.md",
                           "group":  "checklists",
                           "name":  "risk-review",
                           "lines":  52
                       },
                       {
                           "path":  "_refs/checklists/security-privacy-accessibility.md",
                           "group":  "checklists",
                           "name":  "security-privacy-accessibility",
                           "lines":  46
                       },
                       {
                           "path":  "_refs/checklists/ship-readiness.md",
                           "group":  "checklists",
                           "name":  "ship-readiness",
                           "lines":  15
                       },
                       {
                           "path":  "_refs/checklists/skill-quality.md",
                           "group":  "checklists",
                           "name":  "skill-quality",
                           "lines":  85
                       },
                       {
                           "path":  "_refs/checklists/solution-quality.md",
                           "group":  "checklists",
                           "name":  "solution-quality",
                           "lines":  14
                       },
                       {
                           "path":  "_refs/checklists/source-backed-minimality.md",
                           "group":  "checklists",
                           "name":  "source-backed-minimality",
                           "lines":  66
                       },
                       {
                           "path":  "_refs/checklists/spec-quality.md",
                           "group":  "checklists",
                           "name":  "spec-quality",
                           "lines":  20
                       },
                       {
                           "path":  "_refs/checklists/stakeholder-governance.md",
                           "group":  "checklists",
                           "name":  "stakeholder-governance",
                           "lines":  38
                       },
                       {
                           "path":  "_refs/checklists/story-quality-invest.md",
                           "group":  "checklists",
                           "name":  "story-quality-invest",
                           "lines":  11
                       },
                       {
                           "path":  "_refs/checklists/story-splitting.md",
                           "group":  "checklists",
                           "name":  "story-splitting",
                           "lines":  18
                       },
                       {
                           "path":  "_refs/checklists/uat-coverage.md",
                           "group":  "checklists",
                           "name":  "uat-coverage",
                           "lines":  48
                       },
                       {
                           "path":  "_refs/index.md",
                           "group":  "overview",
                           "name":  "index",
                           "lines":  79
                       },
                       {
                           "path":  "_refs/integrations/claude.md",
                           "group":  "integrations",
                           "name":  "claude",
                           "lines":  7
                       },
                       {
                           "path":  "_refs/integrations/codex.md",
                           "group":  "integrations",
                           "name":  "codex",
                           "lines":  7
                       },
                       {
                           "path":  "_refs/integrations/confluence.md",
                           "group":  "integrations",
                           "name":  "confluence",
                           "lines":  18
                       },
                       {
                           "path":  "_refs/integrations/copilot.md",
                           "group":  "integrations",
                           "name":  "copilot",
                           "lines":  7
                       },
                       {
                           "path":  "_refs/integrations/cursor.md",
                           "group":  "integrations",
                           "name":  "cursor",
                           "lines":  7
                       },
                       {
                           "path":  "_refs/integrations/jira.md",
                           "group":  "integrations",
                           "name":  "jira",
                           "lines":  30
                       },
                       {
                           "path":  "_refs/operating-model/annifity-principles.md",
                           "group":  "operating-model",
                           "name":  "annifity-principles",
                           "lines":  10
                       },
                       {
                           "path":  "_refs/operating-model/artifact-lifecycle.md",
                           "group":  "operating-model",
                           "name":  "artifact-lifecycle",
                           "lines":  73
                       },
                       {
                           "path":  "_refs/operating-model/artifact-profile-resolution.md",
                           "group":  "operating-model",
                           "name":  "artifact-profile-resolution",
                           "lines":  135
                       },
                       {
                           "path":  "_refs/operating-model/authoritative-baseline-resolution.md",
                           "group":  "operating-model",
                           "name":  "authoritative-baseline-resolution",
                           "lines":  91
                       },
                       {
                           "path":  "_refs/operating-model/builder-packs.md",
                           "group":  "operating-model",
                           "name":  "builder-packs",
                           "lines":  89
                       },
                       {
                           "path":  "_refs/operating-model/language-policy.md",
                           "group":  "operating-model",
                           "name":  "language-policy",
                           "lines":  7
                       },
                       {
                           "path":  "_refs/operating-model/learning-loop.md",
                           "group":  "operating-model",
                           "name":  "learning-loop",
                           "lines":  34
                       },
                       {
                           "path":  "_refs/operating-model/phase-gates.md",
                           "group":  "operating-model",
                           "name":  "phase-gates",
                           "lines":  122
                       },
                       {
                           "path":  "_refs/operating-model/routing.md",
                           "group":  "operating-model",
                           "name":  "routing",
                           "lines":  62
                       },
                       {
                           "path":  "_refs/operating-model/skill-authoring.md",
                           "group":  "operating-model",
                           "name":  "skill-authoring",
                           "lines":  214
                       },
                       {
                           "path":  "_refs/schemas/artifact-generation-contract.md",
                           "group":  "schemas",
                           "name":  "artifact-generation-contract",
                           "lines":  246
                       },
                       {
                           "path":  "_refs/schemas/artifact-index.md",
                           "group":  "schemas",
                           "name":  "artifact-index",
                           "lines":  10
                       },
                       {
                           "path":  "_refs/schemas/artifact-state-registry.md",
                           "group":  "schemas",
                           "name":  "artifact-state-registry",
                           "lines":  160
                       },
                       {
                           "path":  "_refs/schemas/context-consistency-manifest.md",
                           "group":  "schemas",
                           "name":  "context-consistency-manifest",
                           "lines":  161
                       },
                       {
                           "path":  "_refs/schemas/decision-record.md",
                           "group":  "schemas",
                           "name":  "decision-record",
                           "lines":  28
                       },
                       {
                           "path":  "_refs/schemas/doc-frontmatter.md",
                           "group":  "schemas",
                           "name":  "doc-frontmatter",
                           "lines":  62
                       },
                       {
                           "path":  "_refs/schemas/drawio-validation-manifest.md",
                           "group":  "schemas",
                           "name":  "drawio-validation-manifest",
                           "lines":  103
                       },
                       {
                           "path":  "_refs/schemas/first-pass-quality-dashboard.md",
                           "group":  "schemas",
                           "name":  "first-pass-quality-dashboard",
                           "lines":  95
                       },
                       {
                           "path":  "_refs/schemas/initiative-state.md",
                           "group":  "schemas",
                           "name":  "initiative-state",
                           "lines":  257
                       },
                       {
                           "path":  "_refs/schemas/memory-record.md",
                           "group":  "schemas",
                           "name":  "memory-record",
                           "lines":  12
                       },
                       {
                           "path":  "_refs/schemas/metrics-event.md",
                           "group":  "schemas",
                           "name":  "metrics-event",
                           "lines":  26
                       },
                       {
                           "path":  "_refs/schemas/mutation-preview.md",
                           "group":  "schemas",
                           "name":  "mutation-preview",
                           "lines":  142
                       },
                       {
                           "path":  "_refs/schemas/semantic-forward-test.md",
                           "group":  "schemas",
                           "name":  "semantic-forward-test",
                           "lines":  193
                       },
                       {
                           "path":  "_refs/schemas/session-rework-observation.md",
                           "group":  "schemas",
                           "name":  "session-rework-observation",
                           "lines":  316
                       },
                       {
                           "path":  "_refs/schemas/skill-output-contract.md",
                           "group":  "schemas",
                           "name":  "skill-output-contract",
                           "lines":  72
                       },
                       {
                           "path":  "_refs/templates/ai/context-manifest.md",
                           "group":  "templates",
                           "name":  "context-manifest",
                           "lines":  33
                       },
                       {
                           "path":  "_refs/templates/brd/default-brd.md",
                           "group":  "templates",
                           "name":  "default-brd",
                           "lines":  85
                       },
                       {
                           "path":  "_refs/templates/change/changelog.md",
                           "group":  "templates",
                           "name":  "changelog",
                           "lines":  5
                       },
                       {
                           "path":  "_refs/templates/change/change-plan.md",
                           "group":  "templates",
                           "name":  "change-plan",
                           "lines":  17
                       },
                       {
                           "path":  "_refs/templates/change/impact-analysis.md",
                           "group":  "templates",
                           "name":  "impact-analysis",
                           "lines":  8
                       },
                       {
                           "path":  "_refs/templates/change/spec-change-context.md",
                           "group":  "templates",
                           "name":  "spec-change-context",
                           "lines":  29
                       },
                       {
                           "path":  "_refs/templates/discovery/discovery-brief.md",
                           "group":  "templates",
                           "name":  "discovery-brief",
                           "lines":  41
                       },
                       {
                           "path":  "_refs/templates/discovery/interview-plan.md",
                           "group":  "templates",
                           "name":  "interview-plan",
                           "lines":  59
                       },
                       {
                           "path":  "_refs/templates/docs/decision-ledger.md",
                           "group":  "templates",
                           "name":  "decision-ledger",
                           "lines":  52
                       },
                       {
                           "path":  "_refs/templates/docs/decision-log.md",
                           "group":  "templates",
                           "name":  "decision-log",
                           "lines":  5
                       },
                       {
                           "path":  "_refs/templates/docs/docs-index.md",
                           "group":  "templates",
                           "name":  "docs-index",
                           "lines":  5
                       },
                       {
                           "path":  "_refs/templates/docs/evidence-ledger.md",
                           "group":  "templates",
                           "name":  "evidence-ledger",
                           "lines":  34
                       },
                       {
                           "path":  "_refs/templates/docs/generation-receipt.md",
                           "group":  "templates",
                           "name":  "generation-receipt",
                           "lines":  19
                       },
                       {
                           "path":  "_refs/templates/docs/release-note.md",
                           "group":  "templates",
                           "name":  "release-note",
                           "lines":  21
                       },
                       {
                           "path":  "_refs/templates/docs/session-note.md",
                           "group":  "templates",
                           "name":  "session-note",
                           "lines":  23
                       },
                       {
                           "path":  "_refs/templates/docs/template-registry.md",
                           "group":  "templates",
                           "name":  "template-registry",
                           "lines":  14
                       },
                       {
                           "path":  "_refs/templates/experiment/decision-criteria.md",
                           "group":  "templates",
                           "name":  "decision-criteria",
                           "lines":  16
                       },
                       {
                           "path":  "_refs/templates/experiment/experiment-plan.md",
                           "group":  "templates",
                           "name":  "experiment-plan",
                           "lines":  31
                       },
                       {
                           "path":  "_refs/templates/experiment/hypothesis.md",
                           "group":  "templates",
                           "name":  "hypothesis",
                           "lines":  13
                       },
                       {
                           "path":  "_refs/templates/experiment/sample-size.md",
                           "group":  "templates",
                           "name":  "sample-size",
                           "lines":  19
                       },
                       {
                           "path":  "_refs/templates/experiment/tracking-plan.md",
                           "group":  "templates",
                           "name":  "tracking-plan",
                           "lines":  15
                       },
                       {
                           "path":  "_refs/templates/learning/decision-memo.md",
                           "group":  "templates",
                           "name":  "decision-memo",
                           "lines":  25
                       },
                       {
                           "path":  "_refs/templates/learning/insight-summary.md",
                           "group":  "templates",
                           "name":  "insight-summary",
                           "lines":  21
                       },
                       {
                           "path":  "_refs/templates/learning/product-retrospective.md",
                           "group":  "templates",
                           "name":  "product-retrospective",
                           "lines":  21
                       },
                       {
                           "path":  "_refs/templates/learning/roadmap-recommendation.md",
                           "group":  "templates",
                           "name":  "roadmap-recommendation",
                           "lines":  21
                       },
                       {
                           "path":  "_refs/templates/memories/artifact-generation-contract.md",
                           "group":  "templates",
                           "name":  "artifact-generation-contract",
                           "lines":  81
                       },
                       {
                           "path":  "_refs/templates/memories/decision-outcomes.md",
                           "group":  "templates",
                           "name":  "decision-outcomes",
                           "lines":  5
                       },
                       {
                           "path":  "_refs/templates/memories/decisions.md",
                           "group":  "templates",
                           "name":  "decisions",
                           "lines":  5
                       },
                       {
                           "path":  "_refs/templates/memories/open-questions.md",
                           "group":  "templates",
                           "name":  "open-questions",
                           "lines":  5
                       },
                       {
                           "path":  "_refs/templates/memories/product-context.md",
                           "group":  "templates",
                           "name":  "product-context",
                           "lines":  5
                       },
                       {
                           "path":  "_refs/templates/memories/stakeholder-context.md",
                           "group":  "templates",
                           "name":  "stakeholder-context",
                           "lines":  5
                       },
                       {
                           "path":  "_refs/templates/memories/team-preferences.md",
                           "group":  "templates",
                           "name":  "team-preferences",
                           "lines":  5
                       },
                       {
                           "path":  "_refs/templates/memories/terminology.md",
                           "group":  "templates",
                           "name":  "terminology",
                           "lines":  5
                       },
                       {
                           "path":  "_refs/templates/metrics/metric-tree.md",
                           "group":  "templates",
                           "name":  "metric-tree",
                           "lines":  26
                       },
                       {
                           "path":  "_refs/templates/plan/grooming-questions.md",
                           "group":  "templates",
                           "name":  "grooming-questions",
                           "lines":  27
                       },
                       {
                           "path":  "_refs/templates/plan/product-roadmap.md",
                           "group":  "templates",
                           "name":  "product-roadmap",
                           "lines":  24
                       },
                       {
                           "path":  "_refs/templates/prd/confluence-html.md",
                           "group":  "templates",
                           "name":  "confluence-html",
                           "lines":  7
                       },
                       {
                           "path":  "_refs/templates/prd/confluence-html-strict.md",
                           "group":  "templates",
                           "name":  "confluence-html-strict",
                           "lines":  27
                       },
                       {
                           "path":  "_refs/templates/prd/default-prd.md",
                           "group":  "templates",
                           "name":  "default-prd",
                           "lines":  42
                       },
                       {
                           "path":  "_refs/templates/prd/one-pager.md",
                           "group":  "templates",
                           "name":  "one-pager",
                           "lines":  49
                       },
                       {
                           "path":  "_refs/templates/prd/prd-export-html.html",
                           "group":  "templates",
                           "name":  "prd-export-html",
                           "lines":  21
                       },
                       {
                           "path":  "_refs/templates/prd/prd-from-pro-feedback.md",
                           "group":  "templates",
                           "name":  "prd-from-pro-feedback",
                           "lines":  71
                       },
                       {
                           "path":  "_refs/templates/prototype/claude-code-prompt.md",
                           "group":  "templates",
                           "name":  "claude-code-prompt",
                           "lines":  25
                       },
                       {
                           "path":  "_refs/templates/prototype/lovable-bolt-prompt.md",
                           "group":  "templates",
                           "name":  "lovable-bolt-prompt",
                           "lines":  26
                       },
                       {
                           "path":  "_refs/templates/prototype/prototype-feedback-summary.md",
                           "group":  "templates",
                           "name":  "prototype-feedback-summary",
                           "lines":  39
                       },
                       {
                           "path":  "_refs/templates/prototype/prototyping-requirements-one-pager.md",
                           "group":  "templates",
                           "name":  "prototyping-requirements-one-pager",
                           "lines":  53
                       },
                       {
                           "path":  "_refs/templates/prototype/screen-list.md",
                           "group":  "templates",
                           "name":  "screen-list",
                           "lines":  11
                       },
                       {
                           "path":  "_refs/templates/prototype/user-flow.md",
                           "group":  "templates",
                           "name":  "user-flow",
                           "lines":  23
                       },
                       {
                           "path":  "_refs/templates/prototype/wireframe-description.md",
                           "group":  "templates",
                           "name":  "wireframe-description",
                           "lines":  24
                       },
                       {
                           "path":  "_refs/templates/release/rollout-plan.md",
                           "group":  "templates",
                           "name":  "rollout-plan",
                           "lines":  37
                       },
                       {
                           "path":  "_refs/templates/risk/risk-register.md",
                           "group":  "templates",
                           "name":  "risk-register",
                           "lines":  44
                       },
                       {
                           "path":  "_refs/templates/skills/skill-template.md",
                           "group":  "templates",
                           "name":  "skill-template",
                           "lines":  52
                       },
                       {
                           "path":  "_refs/templates/spec/api-contract.md",
                           "group":  "templates",
                           "name":  "api-contract",
                           "lines":  27
                       },
                       {
                           "path":  "_refs/templates/spec/data-requirements.md",
                           "group":  "templates",
                           "name":  "data-requirements",
                           "lines":  9
                       },
                       {
                           "path":  "_refs/templates/spec/product-spec.md",
                           "group":  "templates",
                           "name":  "product-spec",
                           "lines":  28
                       },
                       {
                           "path":  "_refs/templates/spec/workflow-spec.md",
                           "group":  "templates",
                           "name":  "workflow-spec",
                           "lines":  76
                       },
                       {
                           "path":  "_refs/templates/strategy/business-model-canvas.md",
                           "group":  "templates",
                           "name":  "business-model-canvas",
                           "lines":  25
                       },
                       {
                           "path":  "_refs/templates/strategy/company-research-brief.md",
                           "group":  "templates",
                           "name":  "company-research-brief",
                           "lines":  47
                       },
                       {
                           "path":  "_refs/templates/strategy/market-sizing.md",
                           "group":  "templates",
                           "name":  "market-sizing",
                           "lines":  32
                       },
                       {
                           "path":  "_refs/templates/strategy/opportunity-solution-tree.md",
                           "group":  "templates",
                           "name":  "opportunity-solution-tree",
                           "lines":  38
                       },
                       {
                           "path":  "_refs/templates/traceability/rtm.md",
                           "group":  "templates",
                           "name":  "rtm",
                           "lines":  38
                       },
                       {
                           "path":  "_refs/templates/uat/scenario-test.md",
                           "group":  "templates",
                           "name":  "scenario-test",
                           "lines":  41
                       },
                       {
                           "path":  "_refs/templates/uat/test-case-register.md",
                           "group":  "templates",
                           "name":  "test-case-register",
                           "lines":  13
                       },
                       {
                           "path":  "_refs/templates/uat/uat-plan.md",
                           "group":  "templates",
                           "name":  "uat-plan",
                           "lines":  37
                       },
                       {
                           "path":  "_refs/templates/user-story/acceptance-criteria-gwt.md",
                           "group":  "templates",
                           "name":  "acceptance-criteria-gwt",
                           "lines":  11
                       },
                       {
                           "path":  "_refs/templates/user-story/confluence-html.md",
                           "group":  "templates",
                           "name":  "confluence-html",
                           "lines":  18
                       },
                       {
                           "path":  "_refs/templates/user-story/default-user-story.md",
                           "group":  "templates",
                           "name":  "default-user-story",
                           "lines":  30
                       },
                       {
                           "path":  "_refs/templates/user-story/jira-epic.md",
                           "group":  "templates",
                           "name":  "jira-epic",
                           "lines":  39
                       },
                       {
                           "path":  "_refs/templates/user-story/jira-user-story.md",
                           "group":  "templates",
                           "name":  "jira-user-story",
                           "lines":  25
                       },
                       {
                           "path":  "_refs/templates/user-story/story-map.md",
                           "group":  "templates",
                           "name":  "story-map",
                           "lines":  5
                       },
                       {
                           "path":  "_refs/workflows/ai-native-pm-loop.md",
                           "group":  "workflows",
                           "name":  "ai-native-pm-loop",
                           "lines":  47
                       },
                       {
                           "path":  "_refs/workflows/change-governance.md",
                           "group":  "workflows",
                           "name":  "change-governance",
                           "lines":  16
                       },
                       {
                           "path":  "_refs/workflows/discovery-to-spec.md",
                           "group":  "workflows",
                           "name":  "discovery-to-spec",
                           "lines":  14
                       },
                       {
                           "path":  "_refs/workflows/execution-support.md",
                           "group":  "workflows",
                           "name":  "execution-support",
                           "lines":  17
                       },
                       {
                           "path":  "_refs/workflows/experiment-design.md",
                           "group":  "workflows",
                           "name":  "experiment-design",
                           "lines":  23
                       },
                       {
                           "path":  "_refs/workflows/feature-design.md",
                           "group":  "workflows",
                           "name":  "feature-design",
                           "lines":  20
                       },
                       {
                           "path":  "_refs/workflows/idea-to-prototype.md",
                           "group":  "workflows",
                           "name":  "idea-to-prototype",
                           "lines":  12
                       },
                       {
                           "path":  "_refs/workflows/learning-synthesis.md",
                           "group":  "workflows",
                           "name":  "learning-synthesis",
                           "lines":  19
                       },
                       {
                           "path":  "_refs/workflows/local-mutation-safety.md",
                           "group":  "workflows",
                           "name":  "local-mutation-safety",
                           "lines":  103
                       },
                       {
                           "path":  "_refs/workflows/market-sizing.md",
                           "group":  "workflows",
                           "name":  "market-sizing",
                           "lines":  45
                       },
                       {
                           "path":  "_refs/workflows/product-discovery.md",
                           "group":  "workflows",
                           "name":  "product-discovery",
                           "lines":  36
                       },
                       {
                           "path":  "_refs/workflows/prototype-first.md",
                           "group":  "workflows",
                           "name":  "prototype-first",
                           "lines":  76
                       },
                       {
                           "path":  "_refs/workflows/release-readiness.md",
                           "group":  "workflows",
                           "name":  "release-readiness",
                           "lines":  13
                       },
                       {
                           "path":  "_refs/workflows/requirement-analysis.md",
                           "group":  "workflows",
                           "name":  "requirement-analysis",
                           "lines":  57
                       },
                       {
                           "path":  "_refs/workflows/research-evidence.md",
                           "group":  "workflows",
                           "name":  "research-evidence",
                           "lines":  47
                       },
                       {
                           "path":  "_refs/workflows/solution-exploration.md",
                           "group":  "workflows",
                           "name":  "solution-exploration",
                           "lines":  26
                       },
                       {
                           "path":  "_refs/workflows/spec-to-delivery-plan.md",
                           "group":  "workflows",
                           "name":  "spec-to-delivery-plan",
                           "lines":  11
                       },
                       {
                           "path":  "_refs/workflows/sprint-readiness.md",
                           "group":  "workflows",
                           "name":  "sprint-readiness",
                           "lines":  44
                       },
                       {
                           "path":  "_refs/workflows/workshop-facilitation.md",
                           "group":  "workflows",
                           "name":  "workshop-facilitation",
                           "lines":  51
                       }
                   ]
};
