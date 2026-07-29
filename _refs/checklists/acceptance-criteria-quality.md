# Acceptance Criteria Quality Standard

Use this standard to author, revise, or review acceptance criteria. Apply INVEST to the User Story itself; apply this standard to each acceptance criterion and to the complete AC set.

Apply `_refs/checklists/source-backed-minimality.md` to the surrounding story and its sections; do not use criterion-level AC checks as a reason to retain irrelevant dependencies, exclusions, NFR sections, or repeated story prose.

## Purpose And Boundary

Acceptance criteria define the confirmed behavior that makes a story acceptable. They must let delivery and UAT derive tests without inventing a product rule.

- Use Given/When/Then by default, or the user's requested format when it preserves the same semantics.
- Keep AC focused on business or user-observable system-boundary behavior.
- Keep test data, execution steps, environment, priority, exhaustive permutations, and result recording in UAT.
- Keep implementation mechanics in technical design, unit tests, or integration tests unless an API or protocol is itself the confirmed product contract.
- Do not promote assumptions or open questions into accepted behavior.

## Quality Gate

Every applicable dimension must pass. Do not average a blocker into a score.

| Dimension | Required Standard |
|---|---|
| Source alignment | Map the AC to confirmed story scope, a requirement, business rule, decision, or other authoritative source. Do not silently add an actor, state, threshold, message, notification, retry, or user-visible behavior. |
| Scope fidelity | Keep the expected behavior inside the story boundary. Expose a dependency or open question instead of importing another story's behavior. |
| Observable outcome | State an outcome visible to the user or at a defined system boundary, such as a status, permission decision, notification, business result, or sourced audit event. |
| Objective testability | Provide a deterministic pass/fail oracle. Replace words such as `correctly`, `appropriately`, `as expected`, `quickly`, or `user-friendly` with confirmed behavior or a sourced threshold. |
| Atomicity | Use one primary trigger and one coherent behavior per scenario. Split independently triggered branches or outcomes that can fail separately. |
| Clarity | Identify the material actor, state, data condition, trigger, and result. Avoid ambiguous pronouns, undefined terms, and hidden conditions. |
| Rule consistency | Use the same roles, terminology, states, validation rules, and permissions as the confirmed source. Do not contradict another AC in the same scope. |
| Implementation independence | Describe what must happen, not services, tables, classes, algorithms, framework calls, or internal orchestration. |
| Minimal sufficiency | Include every material acceptance rule, but remove duplicate scenarios, repeated story prose, speculative defensive cases, and implementation-only detail. |
| Traceability | Give each AC a stable unique ID when the artifact supports IDs, and maintain the source-to-story-to-AC-to-UAT chain. |

If source scope, rules, states, permissions, or expected outcomes are missing or contradictory, stop AC authoring and route the gap to `spec`. If correcting the AC changes committed acceptance or user-visible behavior, route the change to `change`.

## Given When Then Construction

- **Scenario title:** Name the behavior and distinguish it from every other scenario.
- **Given:** State only material actor, permission, state, and data preconditions. Do not describe test navigation or the action under test.
- **When:** State one primary user action, business event, or system event.
- **Then:** State the observable business outcome and the resulting state or protected-state effect when relevant.
- **And / But:** Extend the same clause and coherent outcome. Split the scenario when another trigger, branch, or independently failing behavior appears.
- **Examples:** Use examples to clarify a general rule, not to replace it. Use a scenario outline only when the same rule applies to multiple data sets.

Exact copy, timing, limits, response codes, and audit events are acceptance conditions only when a confirmed source makes them part of the contract.

## Coverage Selection

Build a minimum-sufficient AC set. Coverage is relevance-based, not quota-based.

Always cover:

- the primary accepted outcome for each core action represented by the story;
- every confirmed business or validation rule that changes the result;
- every explicit user-visible rejection or failure behavior in scope.

Cover when applicable:

- allowed and denied permission behavior for roles or scopes named by the story;
- valid and invalid state transitions;
- material empty, minimum, maximum, duplicate, invalid, or cross-boundary conditions defined by the source;
- user-observable timeout, concurrent action, stale-data, retry, partial-failure, recovery, accessibility, security, privacy, or other NFR behavior confirmed for this story.

Do not:

- force an AC for every checklist category when the category is irrelevant;
- invent generic infrastructure failures or recovery rules;
- treat a hidden button as sufficient permission denial when the protected action must also be rejected;
- copy an exhaustive UAT catalogue into the story;
- duplicate one outcome only to use different wording or sample values.

Record an explicit gap when a source requirement has no AC. Use `N/A` only with a short relevance reason during a formal review.

## Traceability And Change Control

- Prefer stable IDs such as `AC-01`, unless a project convention overrides the format.
- Map each AC to its source requirement, rule, or decision directly or through the RTM.
- Ensure every committed source requirement maps to an AC or an explicitly accepted gap.
- Let one AC generate multiple UAT cases when data, roles, or environments vary; do not duplicate the business rule in each AC.
- Do not silently renumber or rewrite baselined AC. Treat additions, removals, or meaning changes as controlled changes.
- Preserve assumptions and open questions separately from accepted behavior.

## Good Example

```gherkin
Scenario: Reject an invoice with an invalid due date (AC-02)
  Given the due date is earlier than the issue date
  When the accountant attempts to save the invoice
  Then no invoice is created
  And the message explains that the due date cannot precede the issue date
```

This scenario has one trigger, an objective rejection outcome, a protected-state effect, and a clear rule that UAT can exercise with multiple dates.

## Anti-pattern

```gherkin
Scenario: Validate and save the invoice
  Given the invoice screen is open
  When Save is clicked
  Then InvoiceService validates the fields, calls the API, inserts a row, logs the event, and shows an appropriate result quickly
```

This scenario mixes implementation mechanics, multiple independently failing outcomes, vague terms, and behavior that may not be confirmed by the source.

## Failure Modes

| Failure | Signal | Consequence | Correction | Prevention |
|---|---|---|---|---|
| Scope smuggling | AC introduces an unsupported role, state, message, threshold, notification, or retry | Unapproved product behavior becomes delivery scope | Remove it or obtain a confirmed source; route material gaps to `spec` or `change` | Map every AC to source before handoff |
| Vague oracle | Outcome says `works`, `appropriate`, `correct`, `fast`, or `successful` without a definition | Pass/fail depends on interpretation | State the observable result and sourced threshold | Apply the objective-testability gate |
| Implementation screenplay | AC names internal services, tables, classes, algorithms, or call order | Acceptance becomes brittle and constrains design | Restate the system-boundary outcome | Apply the implementation-independence gate |
| Scenario braid | One scenario contains multiple triggers, branches, or unrelated outcomes | Failures cannot be isolated and the behavior is hard to reason about | Split into atomic scenarios | Check one primary trigger and one coherent behavior |
| Hidden state mutation | A failure message is defined but the resulting data or state effect is not | Partial writes and rollback expectations remain ambiguous | State the protected or resulting state when material | Review failure-state effects |
| Happy-path tunnel | Only the primary success flow is covered despite sourced rules or denials | Material acceptance behavior remains undefined | Add only the applicable rejection, permission, boundary, or transition scenarios | Run relevance-based coverage selection |
| UI-only authorization | AC checks only that an action is hidden | Direct action or API bypass behavior remains undefined | Assert denial and unchanged protected state; keep UI visibility separate if sourced | Review allowed and denied behavior together |
| Example as rule | AC covers one sample value but never states the general rule | Other valid or invalid values remain open to interpretation | State the general rule and retain examples only as clarification | Review source-rule coverage |
| Duplicate acceptance | Several AC express the same trigger and outcome with minor wording changes | Story becomes noisy and contradictions emerge | Merge equivalent scenarios | Perform a deduplication pass |
| Test-case flood | AC lists clicks, setup, permutations, priority, and execution evidence | The acceptance contract is obscured and hard to maintain | Keep rule-defining behavior in AC and move execution detail to UAT | Apply the AC-versus-UAT boundary |

## Verdict

- **Ready:** Every applicable quality dimension passes, relevant coverage is present, traceability is complete enough for the handoff, and no material acceptance assumption remains.
- **Needs revision:** The intended behavior is confirmed, but wording, atomicity, duplication, implementation leakage, coverage, or traceability must be repaired.
- **Blocked:** Missing or contradictory source scope, rule, state, permission, or expected outcome prevents an objective acceptance decision.
