# Jobs-To-Be-Done Analysis

Use this reference when customer discovery needs to explain the progress people
seek in a particular circumstance and why they choose, keep, combine, or abandon
an alternative. It supports problem framing; it does not validate a market,
prove demand, or prescribe a feature.

## Contents

1. [Core Distinctions](#core-distinctions)
2. [Required Evidence](#required-evidence)
3. [Process](#process)
4. [Job Record](#job-record)
5. [Quality Gate](#quality-gate)
6. [Example](#example)
7. [Failure Modes](#failure-modes)
8. [Source And License Note](#source-and-license-note)

## Core Distinctions

- A **job** is desired progress in context, not a product, feature, persona, or
  task list.
- A **circumstance** is the trigger, constraint, environment, or event that
  makes the progress matter.
- An **alternative** is anything currently used to make progress, including
  manual work, delay, another product, or doing nothing.
- An **outcome signal** describes how a person recognizes better progress. It is
  not automatically a product metric.

Use demographic or firmographic segments only when evidence shows that they
change the circumstance, constraint, behavior, or desired progress.

## Required Evidence

Prefer evidence about a recent real event:

- what triggered action;
- what the person was trying to change or achieve;
- what they tried before and what they used instead;
- what created urgency, attraction, hesitation, or habit;
- what trade-offs they accepted;
- what happened and how they judged the result.

Hypothetical preference, feature voting, and generic aspiration are weak inputs.
Keep them as assumptions until behavior or another direct signal supports them.

## Process

1. Select one decision and one relevant circumstance. Do not analyze an entire
   persona or product at once.
2. Reconstruct the event timeline from trigger through outcome using source IDs.
3. Describe current and rejected alternatives, including non-consumption or
   manual workarounds.
4. Separate the progress sought from the chosen solution.
5. Identify functional, emotional, and social dimensions only when the evidence
   supports them; do not fill all dimensions by convention.
6. Record forces that encourage change and forces that preserve the status quo
   in plain language.
7. Write a provisional job statement:

   `When [evidenced circumstance], [customer or actor] needs to [make progress],
   so that [evidenced outcome becomes possible].`

8. Link every clause to observations. Mark unsupported clauses as assumptions.
9. Compare the statement against counterexamples and relevant segments.
10. Decide whether to research more, reframe the opportunity, compare solution
    directions, prototype, or experiment.

## Job Record

| Field | Content |
|---|---|
| Job ID | Stable identifier |
| Actor and relevant segment | Who experiences the circumstance |
| Trigger and circumstance | When and under which constraints the job arises |
| Desired progress | What changes for the actor |
| Current alternatives | Products, workarounds, delay, or non-consumption |
| Barriers and trade-offs | What prevents or complicates progress |
| Outcome signals | How better progress is recognized |
| Evidence IDs | Supporting and contradicting source references |
| Confidence | High/Medium/Low with rationale |
| Assumptions and open questions | What still needs evidence |
| Decision implication | Which product decision this informs |

## Quality Gate

A provisional job is usable when:

- it is stable across plausible solution choices;
- its circumstance and progress are supported by source evidence;
- alternatives and barriers are visible;
- it avoids invented motives and universal claims;
- it states confidence and counterevidence;
- it informs a concrete research or product decision.

## Example

Synthetic evidence:

- S-02 and S-04 prepare coverage for multiple shift types and manually compare
  role requirements with scheduled staff.
- S-03 operates one fixed shift and does not perform this comparison.

Provisional job:

> When preparing coverage for a variable upcoming shift, a duty supervisor
> needs to identify role-level staffing gaps before assignments are finalized,
> so that shortages can be resolved without rebuilding the roster manually.

Anti-pattern:

> Supervisors need an AI staffing dashboard.

The anti-pattern embeds a solution, omits the triggering circumstance, and
cannot be traced to the desired progress.

## Failure Modes

| Failure | Signal | Consequence | Correction | Prevention |
|---|---|---|---|---|
| Feature in disguise | The job names a screen, automation, or product | Solution bias survives discovery | Rewrite it without the proposed solution | Test whether several solutions could satisfy it |
| Persona shorthand | The job is inferred from a title or demographic | Unsupported motivation becomes fact | Reconstruct a real circumstance and event | Require source-linked behavior |
| Timeless abstraction | The statement could apply to anyone at any time | It cannot guide research or prioritization | Add trigger, constraint, and outcome | Require a bounded circumstance |
| Framework completion | Empty emotional or social fields are invented | The model looks complete but evidence is false | Leave unsupported dimensions blank | Evidence-link each populated field |
| Demand claim | A clear job is treated as proof of willingness to adopt | Investment confidence is overstated | Run an experiment or market test | Separate problem evidence from demand evidence |

## Source And License Note

This is an independently written operational reference. The conceptual basis is
the [Christensen Institute overview of Jobs to Be Done](https://www.christenseninstitute.org/resources/theory/jobs-to-be-done/),
which frames a job as progress people seek toward a goal or aspiration in
particular circumstances. The source is cited for theory background only; no
proprietary template, wording, or example is reproduced.
