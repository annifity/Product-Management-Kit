---
name: prototype
description: Create a build-to-learn prototype package from a sufficiently clear product direction. Use for a PRO (Prototyping Requirements One-Pager), minimum user flow, screen list, wireframe descriptions, clickable mockup or frontend-builder prompt, and prototype handoff before experiment, PRD, or spec. If a raw idea still lacks a clear problem, user, or outcome, use `discovery` first; use `design` when accepted requirements need a delivery-facing UX/UI contract rather than a learning mockup.
---

# Prototype

Build the smallest package needed to test a product direction; the goal is learning, not production delivery.

## PRO Mode

Use `PRO - Prototyping Requirements One-Pager` when a raw idea or opportunity already identifies enough of the problem, target user, and intended outcome to choose a learning direction, or when the user needs prompt-ready input for a selected frontend prototype builder. Keep builder selection tool-agnostic unless the user explicitly names a target.

Use Prototype First Workflow when the user wants to create PRO, generate a runnable frontend prototype, collect feedback, then produce PRD after learning.

PRO is:

- A compact, prompt-ready prototype one-pager.
- Limited to exactly 11 sections and at most 500 words.
- Designed to generate a runnable frontend prototype with mock data.

PRO is not:

- A PRD.
- A full product spec.
- An engineering handoff document.
- A production-ready build request.
- A replacement for discovery, validation, experiment design, or learning synthesis.

## Input Contract

Reuse the supplied problem, target user, intended outcome, brief, evidence, constraints, design authority, and builder choice. A prototype direction requires the problem, user, and learning outcome to be clear; otherwise stop at `discovery`. Accept partial screen or flow detail and label only the assumptions needed to build to learn.

## Process

1. Read the raw idea, pain point, brief, target users, success metrics, constraints, and relevant memories.
2. Run the material-decision preflight to resolve the prototype consumer, learning mode, source authority, design authority, format, and destination.
3. Identify the riskiest assumptions the prototype should expose.
4. If the problem, target user, or intended outcome is missing and selecting a direction would require product strategy, stop and route to `discovery`. If those are clear but the prototype concept is not, compare 2-3 concept directions by learning value, clarity, and prototype feasibility before continuing.
5. If the user needs quick prototype generation, draft PRO using `_refs/templates/prototype/prototyping-requirements-one-pager.md` after the direction is clear.
6. Define the minimum user flow and screen list needed to learn.
7. Draft wireframe descriptions and prototype prompts for the selected builder.
8. Apply source-backed minimality and state what the prototype deliberately excludes.
9. Recommend `experiment`, `validate`, or `spec` as the next step.

## Output

- Prototype objective
- PRO - Prototyping Requirements One-Pager when prompt-ready prototype input is needed
- Learning questions
- User flow
- Screen list
- Wireframe descriptions
- Prototype builder prompt
- Out-of-scope production concerns
- Next validation step

## Reference Routing

Load only references needed for the prototype mode and target builder:

- For packaged prototype-first work, use `_refs/operating-model/builder-packs.md`, `_refs/workflows/prototype-first.md`, and `_refs/operating-model/learning-loop.md` selectively.
- Before authoring, resolve `_refs/schemas/artifact-generation-contract.md` through `_refs/operating-model/artifact-profile-resolution.md`, then use `_refs/checklists/material-decision-preflight.md`; before handoff, use `_refs/checklists/source-backed-minimality.md`.
- When prototype direction depends on a governed brief, PRD, or spec, resolve it through `_refs/operating-model/authoritative-baseline-resolution.md`.
- For direction-to-prototype workflow, use `_refs/workflows/idea-to-prototype.md`.
- For PRO creation and validation, use `_refs/templates/prototype/prototyping-requirements-one-pager.md` and `_refs/checklists/pro-quality.md`.
- For prototype feedback capture, use `_refs/templates/prototype/prototype-feedback-summary.md`.
- When checking readiness to move from prototype into experiment, validation, or delivery definition, use `_refs/operating-model/phase-gates.md`.
- For flow, screens, or wireframes, use only the matching template: `_refs/templates/prototype/user-flow.md`, `_refs/templates/prototype/screen-list.md`, or `_refs/templates/prototype/wireframe-description.md`.
- For builder output, use `_refs/templates/prototype/claude-code-prompt.md` or `_refs/templates/prototype/lovable-bolt-prompt.md` only when that target is selected.
- For AI context design, use `_refs/templates/ai/context-manifest.md`.

## Handoff

Hand the prototype objective, runnable artifact or prompt package, minimum flow, screens, exclusions, and validation method to `experiment` when testing is next. Route to `spec` only after prototype evidence establishes enough confirmed behavior and scope to enter delivery definition.
