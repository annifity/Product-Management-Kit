# Skill Quality Checklist

Use this checklist to review a new or materially changed Annifity canonical skill and its routed references.

## Routing Gate

- The description states both the outcome and recognizable trigger conditions.
- The trigger is distinct from the nearest front-door skills.
- Negative and ambiguous cases name what must not win the route.
- A new front door passed the skill-versus-reference decision in `_refs/operating-model/skill-authoring.md`.
- Handoffs and committed-scope escalation are explicit.

## Input Gate

- Inline context is treated as input already supplied.
- Complete, partial, and missing input are supported.
- Only material gaps cause follow-up questions.
- Best-effort assumptions are labeled.
- No runtime-specific argument placeholder reduces portability.

## Execution Gate

- The high-level process is sequential and actionable.
- Decision branches, stop conditions, approvals, and escalation conditions are explicit where relevant.
- The output contract is observable and useful to the next phase.
- The skill stays compact; reusable depth is routed to `_refs/`.

## Teaching And Decision Quality Gate

- Concepts and jargon are explained in plain language when needed.
- The method explains which decision it improves and which failure it prevents.
- Trade-offs are visible rather than hidden behind a universal best practice.
- A realistic good example and anti-pattern exist when quality would otherwise be ambiguous.
- Important failure modes include signal, consequence, correction, and prevention.

## Evidence And Assumption Gate

- Facts, evidence, inference, assumptions, and recommendations are distinguishable.
- Material claims have sources or are labeled as assumptions.
- Confidence and evidence limitations are visible.
- Quotes, metrics, approvals, and research results are never invented.

## Reference Gate

- Every referenced path resolves.
- Every new reference has a direct inbound route from a canonical skill.
- No duplicate template, checklist, workflow, schema, or integration guide was added.
- No circular route or stale path was introduced.
- Long knowledge is in `_refs/`, not duplicated in `SKILL.md`.

## Portability And Safety Gate

- Canonical frontmatter contains only supported fields.
- Naming follows lowercase kebab-case and current repository conventions.
- Scripts are deterministic, reviewed, dependency-light, non-destructive, and network-free unless the repository explicitly permits otherwise.
- No secret, local absolute path, or external skill dependency is committed.
- External source use passed the license gate.

## Validation Gate

- Positive, negative, ambiguous, and handoff cases are present for changed routing behavior.
- Vietnamese and English cases exist when the skill is user-facing.
- `npm run skill:validate` passes for canonical frontmatter and UI metadata.
- `npm run routing:test` passes.
- `npm run ref:check` passes with no orphan reference.
- `npm run contract:test` and targeted checks pass.
- `npm run sync`, then the read-only `npm run sync:check`, `npm run docs:build`, `npm test`, and `git diff --check` pass.
- Generated diffs match the canonical change and contain no unrelated churn.

## Named Failure Modes

| Failure | Signal | Consequence | Correction | Prevention |
|---|---|---|---|---|
| Trigger fog | Description lists a broad domain but no user situation | Neighboring skills compete unpredictably | Rewrite around outcome, trigger, and boundary | Add negative and ambiguous routing cases |
| Input amnesia | Agent asks for facts already supplied inline | User effort rises and trust falls | Reuse supplied context and ask only material gaps | Review the input contract |
| Reference orphan | A new `_refs/` file has no canonical inbound route | Knowledge becomes undiscoverable | Add a specific route or remove the file | Run `npm run ref:check` |
| Front-door bloat | Detailed theory and templates accumulate in `SKILL.md` | Context and maintenance cost grow | Move reusable depth to the correct reference family | Review line growth and duplication |
| Hidden assumption | Recommendation sounds factual without evidence | Decisions become hard to audit | Label the assumption, confidence, and validation step | Apply the evidence gate |
| Adapter drift | Generated files differ from canonical intent | Platforms behave inconsistently | Re-run sync and inspect generated paths/descriptions | Keep generated files read-only by policy |

## Verdict

- **Ready**: every applicable gate passes and no routing or license blocker remains.
- **Needs revision**: the change is recoverable but has quality, evidence, or coverage gaps.
- **Blocked**: trigger collision, broken/orphan reference, unsafe behavior, unsupported schema change, or unresolved license risk remains.
