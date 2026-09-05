# Routing

Use this when a request could match more than one Annifity skill. Route by the user's job, not by the artifact name alone.

## Product Builder Path

| User intent | Primary route | Support route |
|---|---|---|
| "Should we build this?" or a fuzzy stakeholder ask | `discovery` | `knowledge`, `memories` |
| Incoming Slack/email/mandate/escalation with unclear outcome, urgency, authority, evidence, or scope impact | `discovery` | `execution` for active delivery; `change` for committed-scope impact |
| Confirmed problem or learning question needs a quick prototype, demo UI, mockup, runnable FE, or client-feedback loop before build | `prototype` via Prototype First Workflow | `discovery` first when the problem, target user, or intended outcome is still unclear |
| Raw idea + user asks for PRD but also mentions prototype or feedback first | recommend Prototype First before PRD | `prd` only after feedback or explicit override |
| Confirmed direction needs compact alignment | `brief` | `docs`, `memories` |
| The team needs a proof-of-life flow before commitment | `prototype` | `experiment` |
| The team needs evidence and decision criteria | `experiment` | `validate`, `learn` |
| Evidence, prototype, artifact, or readiness needs review | `validate` | Target artifact skill |
| Product events, funnels, cohorts, retention, activation, adoption, or metric movement needs diagnosis or instrumentation | `analytics` | `validate` for an independent evidence-quality verdict; `learn` for a product decision |
| Acquisition, activation, retention, referral, monetization, or a growth loop needs an intervention plan | `growth` | `analytics`, `experiment`, `gtm`, `commercial` |
| Opportunities, features, assumptions, experiments, or backlog options need a defensible rank | `prioritize` | `strategy` for portfolio choice; `plan` for stable delivery sequence |
| Pricing, packaging, market size, SaaS health, unit economics, or investment economics needs analysis | `commercial` | `strategy`, `growth`, `gtm` |
| ICP, positioning, messaging, launch tier, channels, enablement, or adoption motion needs design | `gtm` | `ship` for operational release readiness |
| A competitor baseline, change digest, watchlist, or recurring market signal needs sourced analysis | `competitive-intelligence` | `discovery`, `strategy`, `knowledge` |
| Annifity canonical skill or routed reference needs a quality/readiness review | `validate` using skill-authoring quality references | Repository authoring workflow for correction |
| Evidence must become a decision or roadmap recommendation | `learn` | `docs`, `memories` |
| Product vision, positioning, strategic outcomes, portfolio bets, investment allocation, or start/stop choices | `strategy` | `discovery`, `learn`, `knowledge` |
| Requirements must become buildable scope | `spec` | `prd`, `plan` |
| Accepted spec must become a traceable UX/UI design, screen/state contract, or design handoff | `design` | `validate` for review; `plan` or `user-story` after the Design Gate |
| Confirmed spec + user asks for PRD | Traditional Workflow: `spec` -> `prd` | `docs` |
| PRO + client/user/prototype feedback | `prd` using PRD from PRO + Client Feedback | `learn`, `validate` |
| Stakeholders need a formal PRD/BRD/export | `prd` | `spec`, `docs` |
| Delivery structure: roadmap/release slices, epic map, milestones, dependencies, and sequencing | `plan` | `user-story` for ticket-ready epics and stories; `uat` |
| Ticket-ready Jira epic definitions, stories, story maps, and acceptance criteria | `user-story` | `plan` for delivery-level epic mapping and sequencing; `uat`, `docs` |
| Acceptance testing from confirmed scope | `uat` | `validate`, `ship` |
| Implementation is underway and a question/blocker appears | `execution` | `change` when scope changes |
| Baselined scope, acceptance criteria, or release scope changes | `change` | `docs`, `memories` |
| Release, rollout, support handoff, signoff, retirement | `ship` | `uat`, `learn` |
| Find existing facts, decisions, owners, runbooks, docs | `knowledge` | `docs`, `memories` |
| Save artifacts or durable context | `docs`, `memories` | Any flow skill |

## Boundary Rules

- `brief` is a one-page direction artifact. It aligns on problem, users, goals, scope, metrics, assumptions, and risks before deeper work.
- `strategy` owns product and portfolio choices, strategic outcomes, investment posture, and explicit exclusions. It does not own release slicing or ticket sequencing.
- `prioritize` selects a method and ranks comparable options. It does not select product strategy or sequence stable delivery work.
- `analytics` diagnoses product data and instrumentation. `validate` owns an independent evidence-quality verdict; `learn` owns the resulting product decision.
- `growth` owns the cross-lifecycle growth constraint and intervention portfolio. Measurement-only work stays with `analytics`, while pricing and market motion route to `commercial` and `gtm`.
- `commercial` owns pricing, packaging, market sizing, and economics. It does not own portfolio allocation, growth lifecycle diagnosis, or external launch execution.
- `gtm` owns the market and adoption motion before release operations. `ship` owns readiness, rollout, rollback, support, and external execution approval.
- `competitive-intelligence` owns sourced, dated, recurring competitor records. A one-off existing-fact lookup belongs to `knowledge`; unresolved market framing belongs to `discovery`.
- `prototype` PRO mode creates a prompt-ready Prototyping Requirements One-Pager before PRD/spec/backlog work when the next goal is a fast runnable frontend prototype.
- `spec` is the canonical delivery source of truth when build scope exists. It owns requirement IDs, workflows, states, business rules, NFRs, data/API rules, risks, and acceptance signals.
- `design` translates accepted user-visible behavior into flows, screens, interaction/state coverage, responsive and accessibility obligations, and a design-system-bound handoff. It does not own product behavior and must route missing or changed behavior to `spec` or `change`.
- `prd` is a stakeholder communication/export artifact. If a confirmed `spec` exists, the PRD should derive from it rather than conflict with it. In Prototype First, PRD must derive from PRO + feedback + learning.
- `validate` audits an existing artifact, evidence set, or readiness package and gives a verdict. Route creation or substantive revision to the owning skill (`prd`, `spec`, `user-story`, `uat`, `plan`, or `ship`) and use `validate` after the artifact exists.
- Product analytics is a distinct diagnostic front door: `analytics` defines or diagnoses measurement, `validate` independently judges evidence quality, `learn` interprets assessed evidence, and `strategy` owns any resulting portfolio choice.
- Draft or unbaselined revisions that preserve accepted scope stay with the owning artifact skill. Route to `change` when feedback changes an accepted baseline, scope, acceptance, launch scope, or user-visible behavior.
- Incoming messages stay within existing front doors: use `discovery` for a new or fuzzy outcome, `execution` for baseline clarification during delivery, and `change` when committed scope moves.
- `validate` reviews Annifity skill quality; creating or updating canonical skill sources follows `_refs/operating-model/skill-authoring.md` and does not justify a new product-work front door by itself.
- `knowledge` reads and synthesizes existing facts or artifacts; `docs` creates, versions, indexes, and exports working artifacts; `memories` persists durable decisions, terminology, preferences, and lessons. For a mixed request, route by the user's primary verb and call the other support skills only for the named save or persistence step. These are system habits, not substitutes for the product phase skill.

## Source Of Truth Hierarchy

When artifacts conflict, prefer this order unless the user explicitly changes the baseline:

1. Accepted decisions and durable memories.
2. Confirmed spec IDs and business rules.
3. Accepted design contracts for presentation and interaction detail within their declared authority.
4. PRD/BRD prose derived from the spec.
5. User stories and acceptance criteria.
6. UAT and release checklists.
7. Release notes and post-ship learning.

## Escalation Rules

- If an answer modifies committed scope, acceptance criteria, launch scope, or user-visible behavior, route to `change`.
- If the user asks for quick prototype generation, frontend prototype builder input, or names a specific frontend prototype builder, route to `prototype` PRO mode before `prd`, `spec`, `plan`, or `user-story`.
- If the user asks to turn an accepted spec into delivery UX/UI, screens, states, responsive behavior, accessibility behavior, or a design handoff, route to `design`; do not route a build-to-learn mockup or an independent design review there.
- If the user mentions detailed PRD, full spec, engineering handoff, backlog, or delivery planning, choose Traditional Workflow unless the same request mentions prototype-first validation. If the unresolved decision is which product or portfolio bet to fund, route to `strategy` before delivery planning.
- Route to delivery artifacts when requirements are already confirmed and spec-ready, or after prototype/experiment learning is explicit. If neither condition holds, use discovery, brief, prototype, or experiment first unless the decision owner explicitly accepts the risk of skipping validation.
- If a request needs approval, name the decision maker, approver, consulted stakeholders, informed stakeholders, and decision deadline.
- If risk is accepted rather than fixed, name the owner, accepted-by, accepted-date, review date, and residual risk.
