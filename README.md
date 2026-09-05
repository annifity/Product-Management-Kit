# Annifity

Annifity is a portable AI Product Builder Kit. It helps an AI assistant turn product ideas into evidence, build-ready requirements, delivery handoff packs, UAT coverage, release packages, documentation, and durable product memory.

The design goal is simple: keep routing clear, package output into builder-ready artifacts, and put detailed product logic into reusable references under `_refs/`. Consumers should learn a predictable build path, not memorize a pile of procedures.

For multi-step work, Annifity shows an outcome-level progress checklist before execution and updates it only when state changes. The shared contract lives in `_refs/operating-model/task-progress.md`; it does not replace lifecycle phases, readiness gates, or artifact status.

## Mental Model

Use these flow skills for most product-building work:

| Need | Use |
|---|---|
| Fuzzy idea, stakeholder ask, opportunity, or solution options | `discovery` |
| Confirmed direction that needs a one-page product outline | `brief` |
| Build-to-learn flow, screen list, wireframe description, or builder prompt | `prototype` |
| Hypothesis, metrics, tracking plan, sample, and decision criteria | `experiment` |
| Prototype, experiment, artifact, UAT, risk, readiness, or traceability review | `validate` |
| Insight summary, retrospective, decision memo, roadmap recommendation | `learn` |
| Product vision, positioning, strategic outcomes, portfolio bets, investment allocation | `strategy` |
| BRD/PRD input, raw requirements, workflow, data/API rules, feature spec | `spec` |
| Accepted spec that needs UX/UI flows, screens, states, responsive rules, or design handoff | `design` |
| Delivery roadmap, release slices, epics, dependencies, milestones, grooming | `plan` |
| Active sprint support, developer questions, blockers, scope decisions | `execution` |
| Release, rollout, support handoff, release notes, post-ship memory | `ship` |

Use these decision skills when the primary job is a cross-phase PM decision:

| Decision need | Use |
|---|---|
| Rank opportunities, features, assumptions, experiments, or backlog options | `prioritize` |
| Define or diagnose product events, funnels, cohorts, retention, activation, adoption, or KPI movement | `analytics` |
| Find a growth constraint and design acquisition, activation, retention, referral, or monetization interventions | `growth` |
| Evaluate pricing, packaging, market size, SaaS metrics, unit economics, or investment economics | `commercial` |
| Design ICP, positioning, messaging, launch tier, channels, enablement, and adoption motion | `gtm` |
| Build a sourced competitor baseline, change digest, watchlist, or recurring intelligence record | `competitive-intelligence` |

Use artifact skills only when the user asks for a concrete artifact:

| Artifact Need | Use |
|---|---|
| PRD, BRD, one-pager, Confluence-ready requirement document | `prd` |
| User stories, epics, story maps, Jira stories, acceptance criteria | `user-story` |
| UAT plan, scenario tests, test case register, signoff coverage | `uat` |
| Requirement/spec change, impact analysis, changelog, Jira/Confluence update | `change` |
| Save/index/export artifacts | `docs` |
| Persist durable product context, decisions, terminology, preferences | `memories` |
| Look up existing context, decisions, docs, Jira/Confluence knowledge | `knowledge` |

## Builder Packs

Annifity packages work into handoff-friendly bundles instead of leaving users with isolated documents:

| Pack | When to use | Typical contents |
|---|---|---|
| Discovery Pack | The opportunity is shaped but not committed | Problem, users, evidence, options, assumptions, open questions, metric draft |
| Prototype Pack | The team needs proof-of-life before commitment | Learning objective, riskiest assumptions, flow, screen list, wireframe or builder prompt |
| PRO | A raw idea needs prompt-ready frontend prototype input | 11-section Prototyping Requirements One-Pager for a selected builder, capped at 500 words |
| Experiment Pack | Evidence is needed before delivery scope | Hypothesis, sample or AI golden set, tracking, graders, metrics, guardrails, regression and decision thresholds |
| Strategy Pack | Evidence must become product direction or portfolio investment choices | Vision, where-to-play/how-to-win choices, portfolio posture, exclusions, outcome measures, review triggers |
| Build Handoff Pack | A validated direction is ready for implementation planning | Spec IDs, workflows, data/API, NFRs, risk register, traceability, plan |
| Design Handoff Pack | Accepted user-visible behavior needs design resolution before delivery | Source-bound flows, screens, state matrix, design-system binding, accessibility, responsive rules, design gaps |
| Jira/UAT Pack | Scope must be split, assigned, tested, and accepted | Epics, stories, Given/When/Then AC, UAT register, REQ -> STORY -> AC -> UAT coverage |
| Release Pack | The team is preparing to ship or hand off | Readiness verdict, UAT signoff, rollout, rollback, support, stakeholder comms, accepted risks |
| Learning Pack | Evidence or release outcomes need to become decisions | Observations, interpretation, decision memo, roadmap recommendation, memory updates |
| Priority Decision Pack | Comparable options need a defensible rank | Method choice, inputs, ranking, sensitivity, displaced work, verdict |
| Analytics Diagnosis Pack | Product performance or instrumentation needs diagnosis | Metric contract, data quality, funnel/cohort findings, hypotheses, next analysis |
| Growth Plan | A lifecycle growth constraint needs intervention | Growth model, constraint, drivers, interventions, experiments, anti-plays |
| Commercial Decision Pack | Pricing, packaging, market, or economics need a decision | Input ledger, deterministic metrics, scenarios, sensitivity, verdict |
| GTM And Adoption Pack | A defined product needs a market motion | ICP, positioning, channels, enablement, adoption measurement, operational handoff |
| Competitive Intelligence Pack | Competitor signals need a dated baseline or update | Sources, fact/inference labels, change digest, implications, watchlist |

Use `_refs/operating-model/builder-packs.md` for the detailed pack contract and `_refs/operating-model/routing.md` when a request could match multiple skills.

## Prototype First vs Traditional

Prototype First avoids writing a long PRD too early:

```text
Idea -> PRO -> Frontend Prototype Builder -> Runnable FE Prototype -> Feedback -> Learn/Validate -> PRD
```

Use it when the user wants quick validation, a UI demo, mockup, runnable FE prototype, test idea, client feedback before build, or is not sure the solution is right. Builder selection remains tool-agnostic; add tool-specific instructions only when the user explicitly selects a target.

Traditional remains available for clear requirements:

```text
Spec -> PRD
```

Use it when a confirmed spec exists, the user asks for a detailed PRD immediately, or the team needs stakeholder documentation / delivery handoff. PRO is not a PRD; it is a lightweight prompt-ready artifact for learning before detailed requirements.

## What Annifity Covers

Annifity covers these Product Builder Kit capabilities through a clearer learning and delivery skill map:

- Discovery: strategic discovery, feature-level discovery, opportunity scoring, discovery brief.
- Research and evidence: source-backed external research, company research, evidence quality, citation discipline.
- Problem framing: business analysis, BRD maturity, root cause, stakeholder mapping, assumptions, success metrics.
- Solution exploration: diverge/converge, option matrix, trade-offs, riskiest assumptions.
- Strategy and portfolio: vision, positioning, where-to-play/how-to-win choices, strategic outcomes, portfolio bets, investment allocation, stop/start/continue decisions.
- Business case and economics: opportunity solution tree, market sizing, TAM/SAM/SOM, finance metrics, SaaS economics, pricing/ROI and AI unit-economics decision support.
- Prioritization decisions: method selection, evidence-aware scoring, sensitivity, displaced work, and review triggers.
- Product growth: acquisition quality, activation, retention, referral, monetization, growth loops, constraints, and intervention portfolios.
- Competitive intelligence: dated source ledger, baseline, change digest, product implications, and watch triggers.
- Workshop facilitation: guided mode, context dump mode, best guess mode, one-question turns, progress labels.
- Briefing: one-pager/Product Requirements Outline, goals, scope, metrics, AI-specific requirements, edge cases.
- Prototyping: user flows, screen lists, wireframe descriptions, Claude Code/Lovable/Bolt prompts.
- Experimentation: hypotheses, success metrics, tracking plans, sample logic, decision criteria.
- Customer research synthesis: source-linked observations, findings,
  counterevidence, customer jobs, confidence, and decision-ready insights.
- Learning: insight summaries, retrospectives, decision memos, roadmap recommendations.
- Specification: BRD, PRD, product spec, workflow map, data requirements, API contract, NFRs.
- Product design: spec-derived information architecture, user flows, screen and interaction/state contracts, responsive and accessibility obligations, design-system binding, and design handoff.
- Product analytics: metric contracts, instrumentation quality, funnels, cohorts, retention, adoption, outcome and guardrail evidence.
- Planning: delivery prioritization, release roadmap, release slices, epic map, dependency matrix, milestones, grooming questions.
- Delivery readiness: definition of ready, sprint readiness, operational readiness, risk register.
- Story work: story map, Jira epic/story, story splitting, INVEST, Given/When/Then AC.
- UAT: happy path, unhappy path, edge, boundary, permission, NFR scenario, priority, pass criteria, traceability, signoff.
- Change governance: minor/material/breaking changes, surgical edits, changelog, spec change context.
- Shipping and adoption: rollout plan, rollback, support notes, release notes, positioning, enablement, adoption measurement, post-launch review.
- AI-native learning loop: initiative state, evidence ledger, metrics event schema, context manifest, versioned evaluation suites, calibrated graders, regression/release gates, and approval gates.
- Knowledge and memory: decision ledger, evidence ledger, decision outcomes, template registry, docs index, AI context manifest.
- Product builder packaging: discovery, prototype, experiment, build handoff, design handoff, Jira/UAT, release, and learning packs.
- Governance and risk: stakeholder decision rights, accepted risk ownership, security, privacy, accessibility, and AI-specific risk checks.

## Repository Layout

```text
skills/
  */SKILL.md               Canonical skill instructions
  */agents/openai.yaml     Canonical Codex UI metadata

_refs/
  operating-model/         Annifity principles, gates, lifecycle, language policy
  workflows/               Multi-step PO workflows
  checklists/              Quality gates and review checklists
  templates/               Artifact templates
  schemas/                 Frontmatter, index, memory, decision record shapes
  integrations/            Jira, Confluence, Claude, Codex, Cursor, Copilot notes

.claude/skills/
.codex/skills/
.github/skills/
.cursor/rules/             Generated adapters

tools/
  sync-ai-skill-structures.ps1
  check-self-contained.ps1
  test-annifity.ps1

docs/                      Tracked source for the public static documentation site
tests/                     Tracked regression fixtures and contract tests
.annifity/                 Ignored, project-local generated artifacts and memories
```

`docs/` and `tests/` are canonical repository assets and must remain tracked.
`.annifity/` is runtime output and remains ignored. Run `npm run doctor` for a
read-only explanation of every allowed root and to flag unexpected or misplaced
roots such as `.sdcorejs/` or a deprecated duplicate agent-skill adapter.

## Source Of Truth

Canonical sources live in:

- `skills/*/SKILL.md`
- `skills/*/agents/openai.yaml`
- `_refs/**`

Generated adapters live in:

- `.claude/skills/`
- `.codex/skills/`
- `.github/skills/`
- `.cursor/rules/`

Generated adapters are project-local pointers into the canonical repository. They require the full Annifity repository root and are not standalone skill folders; do not copy or install one adapter folder by itself. Do not edit generated adapters manually. Edit canonical files, then run sync.

## Working Rules

- Match the user's language by default.
- Prefer reading memory and existing docs before asking the user again.
- Keep skill bodies short; move reusable detail to `_refs/`.
- Do not invent facts. Mark assumptions and open questions.
- Use phase gates: discovery -> brief -> prototype -> experiment -> validate ->
  learn -> strategy when portfolio choice is material -> spec -> design when
  user-visible -> plan -> execution -> ship.
- Save artifacts through `docs` and durable context through `memories`.
- Treat baselined artifacts as change-controlled. Use `change` after baseline.
- Draft edits do not increase version; accepted published/spec changes do.
- Resolve project artifact profiles and material decisions before drafting; do not silently replace project context with canonical defaults.
- Resolve controlled artifacts by stable ID, registry pointer, and SHA-256 rather than filename recency.
- Use fingerprinted preview and confirmation for protected local mutations, then prove removals and ignore changes with negative completeness.

## Validation

Run checks:

```powershell
npm run guard
npm run skill:validate
npm run ref:check
npm run routing:test
npm run sync:check
npm run contract:test
npm run design:test
npm run pm-calculators:test
npm run pm-quality:test
npm run p0:test
npm run p1:test
npm run p2:test
npm run doctor
npm test
```

Regenerate adapters:

```powershell
npm run sync
```

Full local check:

```powershell
npm run check
```

Initialize a local `.annifity/` workspace for generated docs, artifact-state registry, memories, and project artifact profiles:

```powershell
npm run workspace:init
```

Create a portable design package from an accepted local spec with
`tools/new-design-package.ps1`, then verify its manifest, source hash,
traceability scaffold, self-contained HTML, and accessibility baseline with
`tools/validate-design-package.ps1`. Existing packages are never overwritten
implicitly; revise them through the controlled mutation workflow.

## Docs Site

Annifity includes a static docs site under `docs/` to show the current skill capabilities, lifecycle flow, canonical skills, and reusable references.

Build the generated catalog:

```powershell
npm run docs:build
```

Open `docs/index.html` locally after building. If PowerShell blocks `npm.ps1`, use `npm.cmd run docs:build`.

If you publish the docs site, rebuild the catalog, validate skills, upload `docs/`, and deploy from the generated static files.

## Extension Guidelines

Create a new skill only when a capability has a distinct user trigger and cannot be naturally handled by an existing front-door skill.

Prefer adding references when the work is:

- A deeper checklist for an existing phase.
- A new artifact template.
- A workflow used by an existing skill.
- Integration guidance.
- A schema or memory shape.

Recommended pattern:

1. Add or update `_refs/...`.
2. Add a one-line route from the relevant `skills/*/SKILL.md`.
3. Add or update positive, negative, ambiguous, handoff, and multilingual routing cases when behavior changes.
4. Review `_refs/operating-model/skill-authoring.md` and `_refs/checklists/skill-quality.md`.
5. Run `npm run sync`.
6. Run `npm run check`.

This keeps Annifity compact for consumers while still giving the agent deep PO operating knowledge when needed.
