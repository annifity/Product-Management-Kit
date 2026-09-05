# Artifact Quality System

Use this operating model for material PM artifacts whose failure could create rework, a wrong investment, an unsafe release, or stakeholder misalignment.

## Required Anatomy

Every material artifact family must expose five independently reviewable surfaces:

1. **Method:** the decision supported, required inputs, branches, failure modes, and stopping rules.
2. **Template:** required sections and stable fields without invented content.
3. **Gold example:** synthetic, evidence-labeled output that demonstrates expected depth and restraint.
4. **Rubric:** observable quality criteria, blockers, and verdict rules.
5. **Eval:** positive, negative, boundary, and quality cases that can fail when behavior regresses.

The surfaces may be shared when several skills produce the same artifact family. Do not duplicate them inside every `SKILL.md`.

## Artifact Contract

A high-quality artifact must make these elements inspectable when applicable:

- Decision, audience, owner, horizon, and current status
- Authoritative inputs and material evidence
- Facts, inferences, assumptions, recommendations, and counterevidence
- Scope, exclusions, trade-offs, rejected alternatives, dependencies, and risks
- Metric definitions, baseline, target, window, source, and guardrails
- Stable IDs and traceability for governed requirements
- Verdict, unresolved blockers, next action, and review trigger

Absence is valid when a field does not apply. Silence is not valid when the field is material; write `Not available`, explain the consequence, and name the acquisition path.

## Gold Example Rules

- Use synthetic products, people, metrics, and evidence.
- Demonstrate at least one rejected option or explicit non-goal.
- Include evidence limits and do not present placeholders as facts.
- Prefer one compact complete example over several shallow variants.
- Do not copy examples or prose from external repositories.

Use `examples/end-to-end/product-builder-kit-example.md` as the lifecycle-level quality anchor and `examples/end-to-end/pro-one-pager-example.md` as the prototype-first anchor. Artifact-specific examples may be added only when these anchors do not make quality observable.

## Review Sequence

1. Resolve source authority and intended audience.
2. Validate required sections and stable identifiers.
3. Apply `_refs/workflows/pm-decision-challenge.md` to the decision logic.
4. Apply the artifact-specific checklist and `_refs/checklists/artifact-quality-scorecard.md`.
5. Compare depth, evidence discipline, and restraint with the gold example; do not copy its content.
6. Issue `ready`, `needs revision`, or `blocked`, with blockers separated from improvements.

## Trade-Off

Gold examples improve consistency but consume context and can anchor the model too strongly. Load an example only when the user requests a high-stakes artifact, the expected depth is ambiguous, or an eval specifically requires it. Method and template remain the default minimum.
