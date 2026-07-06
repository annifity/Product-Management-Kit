# Routing

Use this when a request could match more than one Annifity skill. Route by the user's job, not by the artifact name alone.

## Product Builder Path

| User intent | Primary route | Support route |
|---|---|---|
| "Should we build this?" or a fuzzy stakeholder ask | `discovery` | `knowledge`, `memories` |
| Raw idea, vague pain point, quick prototype, validate quickly, demo UI, mockup, runnable FE, test idea, client feedback before build | `prototype` via Prototype First Workflow | `discovery` when problem is unclear |
| Raw idea + user asks for PRD but also mentions prototype or feedback first | recommend Prototype First before PRD | `prd` only after feedback or explicit override |
| Confirmed direction needs compact alignment | `brief` | `docs`, `memories` |
| The team needs a proof-of-life flow before commitment | `prototype` | `experiment` |
| The team needs evidence and decision criteria | `experiment` | `validate`, `learn` |
| Evidence, prototype, artifact, or readiness needs review | `validate` | Target artifact skill |
| Evidence must become a decision or roadmap recommendation | `learn` | `docs`, `memories` |
| Requirements must become buildable scope | `spec` | `prd`, `plan` |
| Confirmed spec + user asks for PRD | Traditional Workflow: `spec` -> `prd` | `docs` |
| PRO + client/user/prototype feedback | `prd` using PRD from PRO + Client Feedback | `learn`, `validate` |
| Stakeholders need a formal PRD/BRD/export | `prd` | `spec`, `docs` |
| Delivery sequencing, epics, milestones, dependencies | `plan` | `user-story`, `uat` |
| Jira stories, epics, story maps, acceptance criteria | `user-story` | `uat`, `docs` |
| Acceptance testing from confirmed scope | `uat` | `validate`, `ship` |
| Implementation is underway and a question/blocker appears | `execution` | `change` when scope changes |
| Baselined scope, acceptance criteria, or release scope changes | `change` | `docs`, `memories` |
| Release, rollout, support handoff, signoff, retirement | `ship` | `uat`, `learn` |
| Find existing facts, decisions, owners, runbooks, docs | `knowledge` | `docs`, `memories` |
| Save artifacts or durable context | `docs`, `memories` | Any flow skill |

## Boundary Rules

- `brief` is a one-page direction artifact. It aligns on problem, users, goals, scope, metrics, assumptions, and risks before deeper work.
- `prototype` PRO mode creates a prompt-ready Prototyping Requirements One-Pager before PRD/spec/backlog work when the next goal is a fast runnable frontend prototype.
- `spec` is the canonical delivery source of truth when build scope exists. It owns requirement IDs, workflows, states, business rules, NFRs, data/API rules, risks, and acceptance signals.
- `prd` is a stakeholder communication/export artifact. If a confirmed `spec` exists, the PRD should derive from it rather than conflict with it. In Prototype First, PRD must derive from PRO + feedback + learning.
- `validate` gives a readiness verdict. It should route specialized creation work to `uat`, `ship`, `spec`, or `plan` instead of absorbing those jobs.
- `docs`, `memories`, and `knowledge` are system habits. They support the work but are not substitutes for the product phase skill.

## Source Of Truth Hierarchy

When artifacts conflict, prefer this order unless the user explicitly changes the baseline:

1. Accepted decisions and durable memories.
2. Confirmed spec IDs and business rules.
3. PRD/BRD prose derived from the spec.
4. User stories and acceptance criteria.
5. UAT and release checklists.
6. Release notes and post-ship learning.

## Escalation Rules

- If an answer modifies committed scope, acceptance criteria, launch scope, or user-visible behavior, route to `change`.
- If the user asks for quick prototype generation, frontend prototype builder input, or a specific builder such as `sdcorejs-agent`, route to `prototype` PRO mode before `prd`, `spec`, `plan`, or `user-story`.
- If the user mentions detailed PRD, full spec, engineering handoff, backlog, or delivery planning, choose Traditional Workflow unless the same request mentions prototype-first validation.
- Only route to delivery artifacts after prototype or experiment learning is explicit or the user accepts the risk of skipping validation.
- If a request needs approval, name the decision maker, approver, consulted stakeholders, informed stakeholders, and decision deadline.
- If risk is accepted rather than fixed, name the owner, accepted-by, accepted-date, review date, and residual risk.
