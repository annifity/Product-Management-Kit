# Requirement Analysis Workflow

Use for BRDs, raw requirements, meeting notes, or feature specs before writing PRDs or user stories.

## Process

1. Assess source maturity with `_refs/checklists/business-analysis.md`: Raw, Partial, or Complete.
2. If Raw, ask no more than 3 missing-core questions before proceeding.
3. Extract feature list, actors, business rules, assumptions, dependencies, and constraints.
4. Run ten-dimension analysis: feature list, business rules, intent, ambiguity, assumptions, workflow, edge cases, dependencies, risks, implementation readiness.
5. Map workflow gaps, missing states, stuck states, invalid transitions, exception paths, and recovery behavior.
6. Identify edge cases and risks with severity, business impact, owner, and mitigation.
7. Group clarification questions by stakeholder and mark each as Block / Clarify / Deferred.
8. Calculate readiness score and run the solution readiness gate before PRD/spec/story writing.

## Solution Readiness Gate

Proceed only when:

- Problem is understood.
- Root cause is visible.
- Constraints are known.
- Success metrics or acceptance signals exist.
- Critical business rules are explicit.
- Primary workflow and exception behavior are mapped.
- High-severity ambiguity has owner and resolution path.

If any gate fails, return a gap report with Block/Clarify questions and owners.

## Output

- Requirement summary.
- Feature list with F-IDs.
- Business rules with BR-IDs.
- Ambiguities and contradictions.
- Hidden assumptions and risk if wrong.
- Missing information.
- Workflow gaps.
- Edge cases and risks.
- Stakeholder clarification questions.
- Readiness score and verdict.

## Gap Report Template

| ID | Type | Finding | Severity | Business Impact | Owner | Action |
|---|---|---|---|---|---|---|
| GAP-001 | Ambiguity / Assumption / Missing Info / Workflow / Dependency / Risk | [Finding] | High / Medium / Low | [Impact for High/Medium] | [Owner] | Block / Clarify / Deferred |

## Stakeholder Questions

Group questions by answer owner.

| Stakeholder | Question | Label | Needed Before |
|---|---|---|---|
| Product Owner | [Question] | Block / Clarify | Spec / Planning / Sprint |
| Tech Lead | [Question] | Block / Clarify | Spec / Planning / Sprint |
| Business/Ops | [Question] | Block / Clarify | Spec / Planning / Sprint |
