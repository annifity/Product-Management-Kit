# AI Suitability And Risk Framing

Use before committing to AI as the solution or selecting an autonomy level.

## Decision Supported

Choose `no AI`, deterministic rules, AI assistance, or bounded AI action based
on user value, uncertainty, failure impact, evidence needs, and operating cost.

## Process

1. State the user task, current alternative, pain, desired outcome, and evidence.
2. Identify whether the task contains ambiguity, unstructured input, prediction,
   generation, or adaptation that deterministic logic cannot satisfy well.
3. Compare four options: no change, deterministic workflow, AI assistance, and
   bounded AI action. Include human effort and failure recovery.
4. Define the minimum useful autonomy: suggest, draft, decide, or act.
5. Map affected users, communities, decisions, rights, and irreversible effects.
6. Assess failure severity, likelihood, detectability, reversibility, and scale.
7. Classify the risk tier with `_refs/checklists/ai-suitability-risk-gate.md`.
8. Compare build, buy, and hybrid options using data rights, differentiation,
   control, evaluation access, switching cost, unit economics, and vendor risk.
9. Name the evidence required before the next investment or autonomy increase.
10. Recommend proceed, prototype, experiment, use deterministic logic, narrow
    scope, or stop.

## Output

- User task and outcome
- AI suitability decision and rejected alternatives
- Minimum autonomy and human authority
- Risk tier with rationale
- Affected groups and unacceptable outcomes
- Data/evaluation feasibility
- Build/buy/hybrid recommendation
- Evidence plan, owner, and next gate

## Good Example

Use AI to draft an internal answer from approved policy sources, while a human
retains send authority. This is preferable to autonomous sending because source
coverage and failure cost are not yet understood.

## Anti-Pattern

“Add AI because users expect a chatbot.” No user task, advantage, risk,
fallback, or evidence threshold supports the choice.

## Failure Modes

| Failure | Signal | Consequence | Correction | Prevention |
|---|---|---|---|---|
| AI by default | Options omit deterministic or process changes | Complexity is accepted without value evidence | Compare all four solution modes | Require a non-AI alternative |
| Autonomy leap | Prototype moves directly to external action | Failure reaches users before controls exist | Start at the lowest useful autonomy | Require authority boundaries |
| Risk tier by label | “Internal” is treated as low risk | Sensitive or irreversible impact is missed | Score impact and reversibility | Review affected decisions and data |
| Vendor-only economics | Inference price is compared without review, fallback, or switching cost | Business case understates operating cost | Use cost per successful outcome | Include human and failure cost |
