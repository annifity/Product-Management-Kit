# Learning Loop

Annifity is a Product Builder Kit. It separates learning work from delivery work so a team can move from idea to evidence, build handoff, release, and learning without losing context.

## Core Loop

1. `discovery`: clarify the problem, users, opportunity, evidence, and candidate directions.
2. `brief`: summarize the chosen direction as a one-page Product Requirements Outline.
3. `prototype`: turn the brief into a build-to-learn flow, screen list, wireframe description, or builder prompt.
4. `experiment`: define the hypothesis, metrics, sample, tracking, and decision criteria.
5. `validate`: review prototype, experiment, artifact, or readiness results against agreed criteria.
6. `learn`: synthesize evidence into insight, decision, memory, and roadmap recommendation.
7. `spec`: convert a validated direction into working requirements when delivery is justified.
8. `plan` / `execution` / `ship`: move through delivery planning, implementation support, and release when scope is ready.

## Skill Layers

- Flow skills: `discovery`, `brief`, `prototype`, `experiment`, `validate`, `learn`, `spec`, `plan`, `execution`, `ship`.
- Artifact skills: `prd`, `user-story`, `uat`, `change`.
- Habit and system skills: `docs`, `memories`, `knowledge`.

Use `_refs/operating-model/builder-packs.md` to decide which package of artifacts the user should receive at each stage.
Use `_refs/operating-model/routing.md` when a request could match multiple skills.

## Routing Rules

- If the user asks "should we build this?", start with `discovery`.
- If the user asks for a concise product direction, use `brief`.
- If the team needs to see or test a concept before committing, use `prototype` and `experiment`.
- If evidence has been collected, use `validate` and `learn`.
- If the team is ready to build, use `spec` then `plan`.
- If delivery is underway, use `execution`.
- If release or handoff is near, use `ship`.
- If the user asks for "the build pack", "handoff pack", "release pack", or similar packaged output, use `_refs/operating-model/builder-packs.md`.
