# Annifity Skill Authoring Standard

Use this standard to create or materially update canonical Annifity skills and their reusable references. Keep the repository's front-door architecture intact: a small number of distinct skills route into deeper `_refs/` content.

## Contents

1. [Source Of Truth](#1-source-of-truth)
2. [Skill Or Reference Decision](#2-skill-or-reference-decision)
3. [Trigger Contract](#3-trigger-contract)
4. [Input Contract](#4-input-contract)
5. [Front-Door Body Contract](#5-front-door-body-contract)
6. [Reference Design](#6-reference-design)
7. [Decisions, Gates, And Handoffs](#7-decisions-gates-and-handoffs)
8. [Assumptions And Evidence](#8-assumptions-and-evidence)
9. [Examples And Failure Modes](#9-examples-and-failure-modes)
10. [Cross-References And Orphans](#10-cross-references-and-orphans)
11. [Trigger And Routing Tests](#11-trigger-and-routing-tests)
12. [Authoring Workflow](#12-authoring-workflow)
13. [External Sources And License Gate](#13-external-sources-and-license-gate)
14. [Generated Adapters](#14-generated-adapters)
15. [Definition Of Done](#15-definition-of-done)

## 1. Source Of Truth

- Edit canonical packages under `skills/*/` and shared content under `_refs/**` only. Each canonical package owns `SKILL.md` and, when UI metadata is supported, `agents/openai.yaml`.
- Treat `.claude/skills/`, `.codex/skills/`, `.github/skills/`, `.cursor/rules/`, and generated catalogs as outputs.
- Keep canonical frontmatter limited to `name` and `description` until the repository schema and generators explicitly support more fields.
- Use lowercase kebab-case for skill folders and names. Keep names at 64 characters or fewer.
- Keep `agents/openai.yaml` to quoted `display_name`, 25-64 character `short_description`, and a one-sentence `default_prompt` that explicitly names `$skill-name`; validate it with `npm run skill:validate`.

## 2. Skill Or Reference Decision

Create a front-door skill only when all answers are yes:

1. Does the user express a distinct intent that can be recognized before the body is loaded?
2. Does the intent produce an outcome that differs from every existing front door?
3. Is the capability too awkward to route through an existing skill plus a reference?
4. Is expected use frequent enough to justify another routing choice?
5. Can ownership, positive and negative triggers, handoffs, and tests be defined without collision?

Otherwise place the content by function:

| Content | Location |
|---|---|
| Shared principle or lifecycle rule | `_refs/operating-model/` |
| Multi-step procedure | `_refs/workflows/` |
| Quality or readiness gate | `_refs/checklists/` |
| Reusable artifact shape | `_refs/templates/` |
| Persisted or machine-readable contract | `_refs/schemas/` |
| Platform or connector guidance | `_refs/integrations/` |

Do not create a skill merely because another repository has one with the same topic.

## 3. Trigger Contract

Write the description as trigger metadata, not promotional copy.

- State the action or outcome.
- State the situations, inputs, or user language that should activate it.
- Make the closest boundary or handoff discoverable when overlap is likely.
- Keep the wording specific enough to distinguish neighboring skills.
- Put all trigger information in `description`; the body is loaded only after routing.

Good pattern: `Create or review [outcome]. Use when [recognizable situations]. Route [neighboring intent] to [skill].`

Weak pattern: `A powerful assistant for all product work.`

## 4. Input Contract

Treat context supplied with the request as input already collected.

- Accept complete, partial, or absent context.
- Reuse inline text, files, links, and prior confirmed decisions; do not ask for them again.
- Ask only for a missing fact that materially changes the result.
- When safe progress is possible, continue with labeled assumptions and open questions.
- Avoid runtime-specific placeholders or argument syntax that harms portability.
- For guided work, ask one material question per turn by default. Batch up to
  three only when the user explicitly requests batching and the questions are
  independent; offer short numbered choices only when they reduce effort.

## 5. Front-Door Body Contract

Keep `SKILL.md` short enough to route and execute the top-level job. Use imperative language.

Include the minimum needed to:

- execute the high-level process;
- define the output contract;
- select decision branches, stop conditions, and escalation conditions;
- load the required references;
- identify the phase gate and downstream handoff.

Prefer the repository's compact sections: `Process`, `Output`, `Reference Routing`, and `Handoff`. Route each reference by a recognizable condition and load only the minimum relevant files. Add `Input Contract` or `Decision Points` only when the behavior would otherwise be ambiguous. Do not duplicate detailed teaching material from `_refs/` inside the skill.

## 6. Reference Design

Put durable depth in references. A substantial capability reference should contain only the parts that improve execution or learning:

- why the method exists and which decision it supports;
- plain-language concepts and trade-offs;
- sequential steps with branches and stop conditions;
- at least one concrete good example and one anti-pattern when examples materially clarify quality;
- named failure modes with signal, consequence, correction, and prevention check;
- output or readiness criteria;
- sources for external frameworks or material factual claims.

Keep references one hop from `SKILL.md` where practical. Do not require a chain of references to discover essential instructions.

## 7. Decisions, Gates, And Handoffs

For each material branch, define:

- the condition;
- the available paths;
- the selection rule;
- the evidence or assumption used;
- the stop, escalation, or approval condition;
- the next skill, workflow, or artifact.

Use `_refs/operating-model/phase-gates.md` for lifecycle gates. A handoff must name the receiving skill and the minimum state or artifact it receives. Route committed-scope changes to `change`.

## 8. Assumptions And Evidence

- Separate facts, evidence, inference, assumption, and recommendation.
- Attach a source or local path to material claims.
- Label confidence and evidence limits when they affect a decision.
- Make assumptions visible in the output and identify how to validate them.
- Never fabricate customer quotes, metrics, approvals, owners, or research results.

## 9. Examples And Failure Modes

Write examples independently for Annifity; do not copy examples from a reference repository.

Use this failure-mode shape:

| Field | Meaning |
|---|---|
| Failure | Short, memorable name |
| Signal | Observable symptom |
| Consequence | Decision or delivery harm |
| Correction | Immediate repair |
| Prevention | Check that catches recurrence |

Avoid generic examples that only replace nouns in a placeholder. Use a realistic decision, input, and expected output boundary.

## 10. Cross-References And Orphans

- Every new `_refs/` file must be referenced directly by at least one canonical `skills/*/SKILL.md`.
- Every referenced path must resolve from the repository root.
- Update routes when a file moves or a skill boundary changes.
- Do not create circular handoffs or duplicate templates, checklists, or workflows.
- Run `npm run ref:check`; an orphan reference is a failed quality gate.

## 11. Trigger And Routing Tests

Maintain cases under `tests/fixtures/routing/skill-routing-cases.json`.

- Positive: the intended skill is the clear primary route.
- Negative: a superficially similar request must not route to the skill.
- Ambiguous: the case names the primary route and the nearest routes it must beat.
- Handoff: the upstream state and receiving skill are explicit.
- Multilingual: include Vietnamese and English when the trigger is user-facing.

Static routing tests validate a meaningful lexical bridge from each prompt to expected/focus metadata plus declared boundary contracts; they do not prove live model behavior or semantic accuracy. Use forward tests with fresh context for high-risk trigger changes, without revealing the expected answer to the evaluator.

For first-pass semantic behavior, use
`_refs/schemas/semantic-forward-test.md`. Keep the candidate task, blind
evaluator task, and hidden oracle in separate surfaces, and record exact source
hashes plus distinct context IDs.

## 12. Authoring Workflow

Use this standard as the create/update workflow. Use `_refs/templates/skills/skill-template.md` only for a justified new front door, and review with `_refs/checklists/skill-quality.md` before synchronization.

Required sequence:

1. Search for overlap and choose skill versus reference.
2. Define inputs, outcome, boundary, decisions, and handoff.
3. Plan only the reusable resources that are needed.
4. Edit canonical sources and tests together.
5. Run targeted validation.
6. Run sync and inspect generated diffs.
7. Run the full repository check.

## 13. External Sources And License Gate

- Read the source license at the pinned version before reuse.
- Prefer independent implementation of general patterns with new wording and examples.
- Do not copy or closely adapt prose, templates, examples, or decision trees unless compatibility and obligations are confirmed.
- Record uncertain cases as `Requires human/legal license review`.
- Add attribution or third-party notices only when material is actually reused or adapted.

## 14. Generated Adapters

After canonical edits, run `npm run sync`. Never patch generated adapters manually. Generated adapter folders are project-local views that resolve canonical `skills/` and `_refs/` paths from the repository root; they are not standalone install bundles. Inspect generated changes for the same skill set, correct descriptions, valid paths, UI metadata where supported, and no unrelated churn. Run the read-only `npm run sync:check` gate after synchronization.

## 15. Definition Of Done

A skill change is done only when:

- the trigger is distinct and says what and when;
- inline input is reused and missing input behavior is explicit;
- `Input Contract`, `Output`, and `Handoff` conform to
  `_refs/schemas/skill-output-contract.md`, including primary-template fields;
- output, decisions, assumptions, evidence, gate, and handoff are clear;
- required references resolve and none are orphaned;
- good examples and failure modes exist where they improve the capability;
- positive, negative, ambiguous, handoff, and multilingual routing cases are updated as relevant;
- no unsupported frontmatter or runtime-specific syntax was introduced;
- canonical UI metadata passes repository validation when present;
- canonical and generated structures are synchronized;
- targeted structural and semantic tests, `npm run check`, and
  `git diff --check` pass;
- the final diff contains only intentional changes.
