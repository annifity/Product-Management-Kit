# PRO Quality Checklist

Use this to review a PRO - Prototyping Requirements One-Pager before sending it to a selected frontend prototype builder. Keep the review tool-agnostic unless the user explicitly selects a target.

## Required Shape

- Has exactly 11 sections from `_refs/templates/prototype/prototyping-requirements-one-pager.md`.
- Is at or below 500 words.
- Uses short bullets or short sentences.
- Is prompt-ready for a runnable frontend prototype.

## Required Content

- Problem statement and goal explain why the prototype exists in 1-2 short sentences.
- Target users and core use case are concrete enough to drive the golden paths.
- Key requirements list only 3-5 must-have prototype capabilities or UI components.
- AI considerations are described when relevant, including behavior, tone, accuracy, latency, context/data inputs, fallback, or N/A.
- Golden paths include 2-3 realistic flows, including AI-powered or conversational flows when relevant.
- Edge cases and risks include 2-3 realistic red flags such as missing data, unsupported AI requests, privacy, trust, or ambiguous ownership.
- Assumptions and constraints state what must be true and what the prototype deliberately will not solve.
- Success metrics or criteria define observable value, usability, response quality, satisfaction, trust, time, or edit-rate signals.
- Non-goals prevent PRD/spec/backlog expansion.
- Prompt-ready input is specific enough for the selected builder, with tool-specific notes only when the user selected a target.
- Next steps name the testing plan, feedback session, experiment, or decision point after prototype learning.

## Boundaries

- PRO is not a PRD.
- PRO is not a full product spec.
- PRO is not an engineering handoff.
- PRO is not for building a production-ready system.
- PRO does not replace discovery, validation, experiment design, or learning synthesis.
