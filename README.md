# Annifity

Annifity is a portable AI Product Builder Kit. It helps an AI assistant turn product ideas into evidence, build-ready requirements, delivery handoff packs, UAT coverage, release packages, documentation, and durable product memory.

The design goal is simple: keep routing clear, package output into builder-ready artifacts, and put detailed product logic into reusable references under `_refs/`. Consumers should learn a predictable build path, not memorize a pile of procedures.

## Mental Model

Use these flow skills for most product-building work:

| Need | Use |
|---|---|
| Fuzzy idea, stakeholder ask, discovery, strategy, opportunity, solution options | `discovery` |
| Confirmed direction that needs a one-page product outline | `brief` |
| Build-to-learn flow, screen list, wireframe description, or builder prompt | `prototype` |
| Hypothesis, metrics, tracking plan, sample, and decision criteria | `experiment` |
| Prototype, experiment, artifact, UAT, risk, readiness, or traceability review | `validate` |
| Insight summary, retrospective, decision memo, roadmap recommendation | `learn` |
| BRD/PRD input, raw requirements, workflow, data/API rules, feature spec | `spec` |
| Roadmap, prioritization, delivery slices, epics, dependencies, grooming | `plan` |
| Active sprint support, developer questions, blockers, scope decisions | `execution` |
| Release, rollout, support handoff, release notes, post-ship memory | `ship` |

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
| Experiment Pack | Evidence is needed before delivery scope | Hypothesis, sample, tracking, metrics, guardrails, decision thresholds |
| Build Handoff Pack | A validated direction is ready for implementation planning | Spec IDs, workflows, data/API, NFRs, risk register, traceability, plan |
| Jira/UAT Pack | Scope must be split, assigned, tested, and accepted | Epics, stories, Given/When/Then AC, UAT register, REQ -> STORY -> AC -> UAT coverage |
| Release Pack | The team is preparing to ship or hand off | Readiness verdict, UAT signoff, rollout, rollback, support, stakeholder comms, accepted risks |
| Learning Pack | Evidence or release outcomes need to become decisions | Observations, interpretation, decision memo, roadmap recommendation, memory updates |

Use `_refs/operating-model/builder-packs.md` for the detailed pack contract and `_refs/operating-model/routing.md` when a request could match multiple skills.

## Prototype First vs Traditional

Prototype First avoids writing a long PRD too early:

```text
Idea -> PRO -> Frontend Prototype Builder (for example sdcorejs-agent) -> Runnable FE Prototype -> Feedback -> Learn/Validate -> PRD
```

Use it when the user wants quick validation, a UI demo, mockup, runnable FE prototype, test idea, client feedback before build, or is not sure the solution is right. `sdcorejs-agent` can be used as an external example builder for runnable FE with mock data, but the workflow is tool-agnostic.

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
- Strategy and business case: opportunity solution tree, market sizing, TAM/SAM/SOM, finance metrics, SaaS economics, pricing/ROI decision support.
- Workshop facilitation: guided mode, context dump mode, best guess mode, one-question turns, progress labels.
- Briefing: one-pager/Product Requirements Outline, goals, scope, metrics, AI-specific requirements, edge cases.
- Prototyping: user flows, screen lists, wireframe descriptions, Claude Code/Lovable/Bolt prompts.
- Experimentation: hypotheses, success metrics, tracking plans, sample logic, decision criteria.
- Learning: insight summaries, retrospectives, decision memos, roadmap recommendations.
- Specification: BRD, PRD, product spec, workflow map, data requirements, API contract, NFRs.
- Planning: prioritization, opportunity scoring, roadmap, release slices, epic map, dependency matrix, grooming questions.
- Delivery readiness: definition of ready, sprint readiness, operational readiness, risk register.
- Story work: story map, Jira epic/story, story splitting, INVEST, Given/When/Then AC.
- UAT: happy path, unhappy path, edge, boundary, permission, NFR scenario, priority, pass criteria, traceability, signoff.
- Change governance: minor/material/breaking changes, surgical edits, changelog, spec change context.
- Shipping: rollout plan, rollback, support notes, release notes, post-launch review.
- AI-native learning loop: initiative state, evidence ledger, metrics event schema, artifact quality scorecard, context manifest, approval gates.
- Knowledge and memory: decision ledger, evidence ledger, decision outcomes, template registry, docs index, AI context manifest.
- Product builder packaging: discovery, prototype, experiment, build handoff, Jira/UAT, release, and learning packs.
- Governance and risk: stakeholder decision rights, accepted risk ownership, security, privacy, accessibility, and AI-specific risk checks.

## Repository Layout

```text
skills/
  */SKILL.md               Canonical skill entry points

_refs/
  operating-model/         Annifity principles, gates, lifecycle, language policy
  workflows/               Multi-step PO workflows
  checklists/              Quality gates and review checklists
  templates/               Artifact templates
  schemas/                 Frontmatter, index, memory, decision record shapes
  integrations/            Jira, Confluence, Claude, Codex, Cursor, Copilot notes

.claude/skills/
.codex/skills/
.agents/skills/
.github/skills/
.cursor/rules/             Generated adapters

tools/
  sync-ai-skill-structures.ps1
  check-self-contained.ps1
  test-annifity.ps1
```

## Source Of Truth

Canonical behavior lives in:

- `skills/*/SKILL.md`
- `_refs/**`

Generated adapters live in:

- `.claude/skills/`
- `.codex/skills/`
- `.agents/skills/`
- `.github/skills/`
- `.cursor/rules/`

Do not edit generated adapters manually. Edit canonical files, then run sync.

## Working Rules

- Match the user's language by default.
- Prefer reading memory and existing docs before asking the user again.
- Keep skill bodies short; move reusable detail to `_refs/`.
- Do not invent facts. Mark assumptions and open questions.
- Use phase gates: discovery -> brief -> prototype -> experiment -> validate -> learn -> spec -> plan -> execution -> ship.
- Save artifacts through `docs` and durable context through `memories`.
- Treat baselined artifacts as change-controlled. Use `change` after baseline.
- Draft edits do not increase version; accepted published/spec changes do.

## Validation

Run checks:

```powershell
npm run guard
npm run ref:check
npm run contract:test
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

Initialize a local `.annifity/` workspace for generated docs and memories:

```powershell
npm run workspace:init
```

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
3. Run `npm run sync`.
4. Run `npm run guard` and `npm test`.

This keeps Annifity compact for consumers while still giving the agent deep PO operating knowledge when needed.
