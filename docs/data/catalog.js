window.ANNIFITY_CATALOG = {
    "generatedAt":  "2026-07-06T14:01:11Z",
    "summary":  {
                    "skillCount":  17,
                    "referenceCount":  125,
                    "workflowCount":  18,
                    "checklistCount":  20,
                    "templateCount":  67
                },
    "skills":  [
                   {
                       "name":  "brief",
                       "description":  "Use when a confirmed discovery direction needs a concise one-pager or Product Requirements Outline before prototype, experiment, spec, roadmap, or stakeholder alignment work. Applies to problem framing, goals, target users, scope, success metrics, AI-specific requirements, edge cases, and risks.",
                       "source":  "skills/brief/SKILL.md",
                       "references":  [
                                          "_refs/checklists/business-analysis.md",
                                          "_refs/checklists/edge-cases.md",
                                          "_refs/checklists/stakeholder-governance.md",
                                          "_refs/operating-model/builder-packs.md",
                                          "_refs/operating-model/learning-loop.md",
                                          "_refs/operating-model/routing.md",
                                          "_refs/templates/ai/context-manifest.md",
                                          "_refs/templates/metrics/metric-tree.md",
                                          "_refs/templates/prd/one-pager.md",
                                          "_refs/workflows/ai-native-pm-loop.md"
                                      ]
                   },
                   {
                       "name":  "change",
                       "description":  "Manage requirement changes to existing PRDs, BRDs, specs, user stories, UAT, Jira tickets, Confluence pages, or release scope. Use when requirements change mid-flight, a stakeholder updates scope, a document needs controlled edits, spec versioning, surgical patching, impact analysis, changelog, notification, or AI context handoff.",
                       "source":  "skills/change/SKILL.md",
                       "references":  [
                                          "_refs/checklists/stakeholder-governance.md",
                                          "_refs/integrations/confluence.md",
                                          "_refs/integrations/jira.md",
                                          "_refs/operating-model/routing.md",
                                          "_refs/templates/change/changelog.md",
                                          "_refs/templates/change/change-plan.md",
                                          "_refs/templates/change/impact-analysis.md",
                                          "_refs/templates/change/spec-change-context.md",
                                          "_refs/workflows/change-governance.md"
                                      ]
                   },
                   {
                       "name":  "discovery",
                       "description":  "Use when early product ideas, stakeholder asks, vague feature requests, product discovery, opportunity framing, strategy questions, solution options, scope clarification, market sizing, finance or business model thinking, workshop facilitation, external research, AI context design, or problem framing need shaping before a brief, prototype, experiment, spec, or artifact.",
                       "source":  "skills/discovery/SKILL.md",
                       "references":  [
                                          "_refs/checklists/brainstorming-readiness.md",
                                          "_refs/checklists/business-analysis.md",
                                          "_refs/checklists/finance-metrics.md",
                                          "_refs/checklists/opportunity-scoring.md",
                                          "_refs/operating-model/builder-packs.md",
                                          "_refs/operating-model/learning-loop.md",
                                          "_refs/operating-model/phase-gates.md",
                                          "_refs/operating-model/routing.md",
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
                       "description":  "Maintain Annifity working documents automatically. Use alongside every PO workflow to create, update, index, export, summarize, version, and link PRDs, BRDs, specs, user stories, UAT cases, decision logs, decision ledger records, changelogs, templates, session notes, release documents, and traceability artifacts in `.annifity/docs/`.",
                       "source":  "skills/docs/SKILL.md",
                       "references":  [
                                          "_refs/operating-model/artifact-lifecycle.md",
                                          "_refs/schemas/artifact-index.md",
                                          "_refs/schemas/decision-record.md",
                                          "_refs/schemas/doc-frontmatter.md",
                                          "_refs/schemas/initiative-state.md",
                                          "_refs/templates/docs/decision-ledger.md",
                                          "_refs/templates/docs/decision-log.md",
                                          "_refs/templates/docs/docs-index.md",
                                          "_refs/templates/docs/evidence-ledger.md",
                                          "_refs/templates/docs/release-note.md",
                                          "_refs/templates/docs/session-note.md",
                                          "_refs/templates/docs/template-registry.md"
                                      ]
                   },
                   {
                       "name":  "execution",
                       "description":  "Use when active delivery after planning begins needs product-owner support, including developer questions, scope decisions, requirement interpretation, blocked tickets, acceptance clarification, trade-off decisions, Jira/Confluence context handoff, dependency decisions, or controlled updates while implementation is underway.",
                       "source":  "skills/execution/SKILL.md",
                       "references":  [
                                          "_refs/checklists/stakeholder-governance.md",
                                          "_refs/integrations/jira.md",
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
                       "description":  "Use when a product hypothesis, prototype, or brief needs a validation experiment with success metrics, tracking plan, decision criteria, sample size, learning plan, or evidence design. Applies before building production scope and differs from UAT, which verifies acceptance of committed delivery.",
                       "source":  "skills/experiment/SKILL.md",
                       "references":  [
                                          "_refs/checklists/security-privacy-accessibility.md",
                                          "_refs/operating-model/builder-packs.md",
                                          "_refs/operating-model/learning-loop.md",
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
                       "description":  "Retrieve and synthesize organizational product knowledge from local docs, memories, decision ledger records, pasted context, Jira, Confluence, or available workspace connectors. Use for feature existence checks, ownership questions, decision history, archaeology of past decisions, runbooks, artifact lookup, template lookup, and product context retrieval.",
                       "source":  "skills/knowledge/SKILL.md",
                       "references":  [
                                          "_refs/integrations/confluence.md",
                                          "_refs/integrations/jira.md",
                                          "_refs/schemas/initiative-state.md",
                                          "_refs/templates/docs/decision-ledger.md",
                                          "_refs/templates/docs/decision-log.md",
                                          "_refs/templates/docs/evidence-ledger.md",
                                          "_refs/templates/memories/decisions.md"
                                      ]
                   },
                   {
                       "name":  "learn",
                       "description":  "Use when discovery, prototype, experiment, validation, release, or post-ship evidence needs to become an insight summary, product retrospective, decision memo, roadmap recommendation, memory update, or next-loop recommendation.",
                       "source":  "skills/learn/SKILL.md",
                       "references":  [
                                          "_refs/operating-model/builder-packs.md",
                                          "_refs/operating-model/learning-loop.md",
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
                       "description":  "Maintain durable Annifity product memory. Use before and after PO workflows to read and update product context, team preferences, terminology, stakeholder constraints, decisions, decision outcomes, assumptions, template preferences, lessons learned, and open questions in `.annifity/memories/`.",
                       "source":  "skills/memories/SKILL.md",
                       "references":  [
                                          "_refs/schemas/decision-record.md",
                                          "_refs/schemas/initiative-state.md",
                                          "_refs/schemas/memory-record.md",
                                          "_refs/templates/docs/decision-ledger.md",
                                          "_refs/templates/memories/decision-outcomes.md",
                                          "_refs/templates/memories/decisions.md",
                                          "_refs/templates/memories/open-questions.md",
                                          "_refs/templates/memories/product-context.md",
                                          "_refs/templates/memories/stakeholder-context.md",
                                          "_refs/templates/memories/team-preferences.md",
                                          "_refs/templates/memories/terminology.md"
                                      ]
                   },
                   {
                       "name":  "plan",
                       "description":  "Use when a confirmed product spec needs a delivery plan, roadmap slice, prioritization decision, business case, market/finance-informed investment decision, epic map, release slices, dependency map, milestone plan, grooming questions, or team handoff sequence before execution, story writing, sprint planning, or roadmap communication.",
                       "source":  "skills/plan/SKILL.md",
                       "references":  [
                                          "_refs/checklists/definition-of-ready.md",
                                          "_refs/checklists/finance-metrics.md",
                                          "_refs/checklists/opportunity-scoring.md",
                                          "_refs/checklists/prioritization.md",
                                          "_refs/checklists/risk-review.md",
                                          "_refs/checklists/security-privacy-accessibility.md",
                                          "_refs/checklists/ship-readiness.md",
                                          "_refs/checklists/stakeholder-governance.md",
                                          "_refs/operating-model/builder-packs.md",
                                          "_refs/operating-model/routing.md",
                                          "_refs/templates/plan/grooming-questions.md",
                                          "_refs/templates/plan/product-roadmap.md",
                                          "_refs/templates/user-story/story-map.md",
                                          "_refs/workflows/market-sizing.md",
                                          "_refs/workflows/spec-to-delivery-plan.md"
                                      ]
                   },
                   {
                       "name":  "prd",
                       "description":  "Create, revise, review, translate, or export Product Requirement Documents and BRD-style requirement artifacts. Use when the user asks for a PRD, BRD, one-pager, product requirements document, product spec document, PRD/BRD review, translation, export, Confluence-ready document, strict Confluence HTML, or PRD from PRO + Client Feedback after prototype review, validation result, learning summary, or stakeholder decision.",
                       "source":  "skills/prd/SKILL.md",
                       "references":  [
                                          "_refs/checklists/business-analysis.md",
                                          "_refs/checklists/finance-metrics.md",
                                          "_refs/checklists/spec-quality.md",
                                          "_refs/checklists/stakeholder-governance.md",
                                          "_refs/integrations/confluence.md",
                                          "_refs/operating-model/routing.md",
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
                       "description":  "Use when a product brief, raw idea, pain point, or validated direction needs a build-to-learn prototype plan, PRO - Prototyping Requirements One-Pager, user flow, screen list, wireframe description, clickable mockup prompt, Claude Code prompt, Lovable prompt, frontend prototype builder input, or prototype handoff before experimentation or specification.",
                       "source":  "skills/prototype/SKILL.md",
                       "references":  [
                                          "_refs/checklists/pro-quality.md",
                                          "_refs/operating-model/builder-packs.md",
                                          "_refs/operating-model/learning-loop.md",
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
                       "description":  "Use when a product change needs release, rollout, stakeholder handoff, support handoff, retirement, release readiness, launch planning, support notes, rollback planning, EOL communication, signoff, final document bundle, release notes, decision summary, UAT signoff, or post-ship memory capture.",
                       "source":  "skills/ship/SKILL.md",
                       "references":  [
                                          "_refs/checklists/operational-readiness.md",
                                          "_refs/checklists/security-privacy-accessibility.md",
                                          "_refs/checklists/ship-readiness.md",
                                          "_refs/checklists/stakeholder-governance.md",
                                          "_refs/operating-model/builder-packs.md",
                                          "_refs/operating-model/routing.md",
                                          "_refs/templates/docs/release-note.md",
                                          "_refs/templates/release/rollout-plan.md",
                                          "_refs/templates/risk/risk-register.md",
                                          "_refs/templates/traceability/rtm.md",
                                          "_refs/workflows/release-readiness.md"
                                      ]
                   },
                   {
                       "name":  "spec",
                       "description":  "Use when a confirmed product idea, PRD input, BRD, meeting note, discovery brief, roadmap item, learning outcome, or brainstorming brief needs to become a precise product specification with scope, business rules, workflows, state behavior, edge cases, data/API rules, non-functional requirements, assumptions, risks, and open questions before delivery planning.",
                       "source":  "skills/spec/SKILL.md",
                       "references":  [
                                          "_refs/checklists/artifact-quality-scorecard.md",
                                          "_refs/checklists/business-analysis.md",
                                          "_refs/checklists/definition-of-ready.md",
                                          "_refs/checklists/edge-cases.md",
                                          "_refs/checklists/risk-review.md",
                                          "_refs/checklists/security-privacy-accessibility.md",
                                          "_refs/checklists/solution-quality.md",
                                          "_refs/checklists/spec-quality.md",
                                          "_refs/checklists/stakeholder-governance.md",
                                          "_refs/operating-model/builder-packs.md",
                                          "_refs/operating-model/routing.md",
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
                       "description":  "Create or review User Acceptance Testing plans, scenario tests, test case registers, and coverage reports from PRDs, BRDs, specs, user stories, acceptance criteria, or release scope. Use for UAT coverage, role-based scenarios, happy paths, unhappy paths, boundary cases, permission validation, NFR scenarios, execution logs, and signoff readiness.",
                       "source":  "skills/uat/SKILL.md",
                       "references":  [
                                          "_refs/checklists/security-privacy-accessibility.md",
                                          "_refs/checklists/uat-coverage.md",
                                          "_refs/operating-model/builder-packs.md",
                                          "_refs/templates/traceability/rtm.md",
                                          "_refs/templates/uat/scenario-test.md",
                                          "_refs/templates/uat/test-case-register.md",
                                          "_refs/templates/uat/uat-plan.md"
                                      ]
                   },
                   {
                       "name":  "user-story",
                       "description":  "Create, split, refine, review, map, or export user stories, epics, acceptance criteria, story maps, Jira tickets, and Confluence-ready story pages from a PRD, BRD, feature spec, roadmap item, or confirmed product plan. Use for INVEST stories, story splitting, epic breakdown, story maps, Jira-ready stories, Given/When/Then acceptance criteria, and story quality review.",
                       "source":  "skills/user-story/SKILL.md",
                       "references":  [
                                          "_refs/checklists/story-quality-invest.md",
                                          "_refs/checklists/story-splitting.md",
                                          "_refs/integrations/confluence.md",
                                          "_refs/integrations/jira.md",
                                          "_refs/operating-model/builder-packs.md",
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
                       "description":  "Use when product artifacts, prototypes, experiments, sprint scope, QA packages, release readiness, stakeholder handoff, or implementation inputs need validation. Applies to PRDs, BRDs, specs, user stories, acceptance criteria, UAT cases, risk registers, traceability, edge cases, sprint readiness, operational readiness, delivery readiness, experiment outcomes, and document quality.",
                       "source":  "skills/validate/SKILL.md",
                       "references":  [
                                          "_refs/checklists/artifact-quality-scorecard.md",
                                          "_refs/checklists/business-analysis.md",
                                          "_refs/checklists/definition-of-done.md",
                                          "_refs/checklists/definition-of-ready.md",
                                          "_refs/checklists/edge-cases.md",
                                          "_refs/checklists/operational-readiness.md",
                                          "_refs/checklists/risk-review.md",
                                          "_refs/checklists/security-privacy-accessibility.md",
                                          "_refs/checklists/ship-readiness.md",
                                          "_refs/checklists/spec-quality.md",
                                          "_refs/checklists/stakeholder-governance.md",
                                          "_refs/checklists/story-quality-invest.md",
                                          "_refs/checklists/uat-coverage.md",
                                          "_refs/operating-model/routing.md",
                                          "_refs/templates/experiment/decision-criteria.md",
                                          "_refs/templates/prototype/prototype-feedback-summary.md",
                                          "_refs/templates/risk/risk-register.md",
                                          "_refs/templates/traceability/rtm.md",
                                          "_refs/workflows/prototype-first.md",
                                          "_refs/workflows/sprint-readiness.md"
                                      ]
                   }
               ],
    "references":  [
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
                           "lines":  14
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
                           "path":  "_refs/checklists/solution-quality.md",
                           "group":  "checklists",
                           "name":  "solution-quality",
                           "lines":  14
                       },
                       {
                           "path":  "_refs/checklists/spec-quality.md",
                           "group":  "checklists",
                           "name":  "spec-quality",
                           "lines":  18
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
                           "lines":  10
                       },
                       {
                           "path":  "_refs/checklists/story-splitting.md",
                           "group":  "checklists",
                           "name":  "story-splitting",
                           "lines":  14
                       },
                       {
                           "path":  "_refs/checklists/uat-coverage.md",
                           "group":  "checklists",
                           "name":  "uat-coverage",
                           "lines":  44
                       },
                       {
                           "path":  "_refs/index.md",
                           "group":  "overview",
                           "name":  "index",
                           "lines":  59
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
                           "lines":  22
                       },
                       {
                           "path":  "_refs/operating-model/annifity-principles.md",
                           "group":  "operating-model",
                           "name":  "annifity-principles",
                           "lines":  8
                       },
                       {
                           "path":  "_refs/operating-model/artifact-lifecycle.md",
                           "group":  "operating-model",
                           "name":  "artifact-lifecycle",
                           "lines":  35
                       },
                       {
                           "path":  "_refs/operating-model/builder-packs.md",
                           "group":  "operating-model",
                           "name":  "builder-packs",
                           "lines":  87
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
                           "lines":  43
                       },
                       {
                           "path":  "_refs/operating-model/routing.md",
                           "group":  "operating-model",
                           "name":  "routing",
                           "lines":  57
                       },
                       {
                           "path":  "_refs/schemas/artifact-index.md",
                           "group":  "schemas",
                           "name":  "artifact-index",
                           "lines":  10
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
                           "lines":  13
                       },
                       {
                           "path":  "_refs/schemas/initiative-state.md",
                           "group":  "schemas",
                           "name":  "initiative-state",
                           "lines":  91
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
                           "lines":  39
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
                           "path":  "_refs/templates/docs/release-note.md",
                           "group":  "templates",
                           "name":  "release-note",
                           "lines":  21
                       },
                       {
                           "path":  "_refs/templates/docs/session-note.md",
                           "group":  "templates",
                           "name":  "session-note",
                           "lines":  19
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
                           "lines":  12
                       },
                       {
                           "path":  "_refs/templates/uat/uat-plan.md",
                           "group":  "templates",
                           "name":  "uat-plan",
                           "lines":  21
                       },
                       {
                           "path":  "_refs/templates/user-story/acceptance-criteria-gwt.md",
                           "group":  "templates",
                           "name":  "acceptance-criteria-gwt",
                           "lines":  10
                       },
                       {
                           "path":  "_refs/templates/user-story/confluence-html.md",
                           "group":  "templates",
                           "name":  "confluence-html",
                           "lines":  24
                       },
                       {
                           "path":  "_refs/templates/user-story/default-user-story.md",
                           "group":  "templates",
                           "name":  "default-user-story",
                           "lines":  25
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
                           "lines":  17
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
                           "lines":  27
                       },
                       {
                           "path":  "_refs/workflows/workshop-facilitation.md",
                           "group":  "workflows",
                           "name":  "workshop-facilitation",
                           "lines":  51
                       }
                   ]
};
