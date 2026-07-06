---
name: prototype
description: Use when a product brief, raw idea, pain point, or validated direction needs a build-to-learn prototype plan, PRO - Prototyping Requirements One-Pager, user flow, screen list, wireframe description, clickable mockup prompt, Claude Code prompt, Lovable prompt, frontend prototype builder input, or prototype handoff before experimentation or specification.
---

# Prototype

Use this to turn a raw idea, pain point, brief, or validated direction into a lightweight prototype package. The goal is learning, not production delivery.

## PRO Mode

Use `PRO - Prototyping Requirements One-Pager` when the user has a raw idea, vague opportunity, quick frontend prototype request, or needs prompt-ready input for a selected frontend prototype builder. `sdcorejs-agent` is one external example target, not a required workflow dependency.

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

## Process

1. Read the raw idea, pain point, brief, target users, success metrics, constraints, and relevant memories.
2. Identify the riskiest assumptions the prototype should expose.
3. If the idea is too vague, propose 2-3 concept directions, score learning value / clarity / prototype feasibility, choose one direction, then continue with PRO or prototype planning.
4. If the user needs quick prototype generation, draft PRO using `_refs/templates/prototype/prototyping-requirements-one-pager.md` after the direction is clear.
5. Define the minimum user flow and screen list needed to learn.
6. Draft wireframe descriptions and prototype prompts for the selected builder.
7. State what the prototype deliberately excludes.
8. Recommend `experiment`, `validate`, or `spec` as the next step.

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

## Required References

- `_refs/operating-model/builder-packs.md`
- `_refs/workflows/prototype-first.md`
- `_refs/workflows/idea-to-prototype.md`
- `_refs/templates/prototype/prototyping-requirements-one-pager.md`
- `_refs/templates/prototype/prototype-feedback-summary.md`
- `_refs/templates/prototype/user-flow.md`
- `_refs/templates/prototype/screen-list.md`
- `_refs/templates/prototype/wireframe-description.md`
- `_refs/templates/prototype/claude-code-prompt.md`
- `_refs/templates/prototype/lovable-bolt-prompt.md`
- `_refs/checklists/pro-quality.md`
- `_refs/templates/ai/context-manifest.md`
- `_refs/operating-model/learning-loop.md`

## Handoff

Move to `experiment` when the prototype is ready for user or stakeholder testing. Move to `spec` only when the team has learned enough to define delivery requirements.
