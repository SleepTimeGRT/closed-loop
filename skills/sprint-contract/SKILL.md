---
name: sprint-contract
description: |
  Create a Sprint Contract — a testable pass/fail checklist that defines what "done" means
  for a feature, finalized before implementation begins.
  This skill should be used when the user says "sprint contract", "contract", "write a contract",
  "acceptance criteria", "definition of done", "done criteria", "pass/fail criteria",
  "completion criteria", "what counts as done", "define test criteria",
  or is about to start implementing a feature and needs testable completion criteria.
  This skill should also be triggered before /evaluate — a contract is required for evaluation.
version: 0.1.0
---

# Sprint Contract

A Sprint Contract pins down what "done" looks like before anyone writes a line of code. The Evaluator tests against this contract and nothing else — so if it's not in the contract, it doesn't get tested.

## Principles

1. **Lock it before building.** Once implementation starts, the contract is frozen. Changing criteria mid-sprint just moves the goalposts. If the spec itself is wrong, go back to the Planner — don't patch the contract.

2. **Think like a user, not an engineer.** Every item should describe something a person can see or do in a browser. "Vendor sees the matched product name" is testable. "RPC returns the correct type" is not — that's the type checker's job.

3. **Keep it testable.** If you can't verify it by clicking through the app in a browser, it doesn't belong in the contract.

4. **Three tiers, no more.** Must / Should / Won't Test. This structure prevents the feedback loop from running forever — Must items gate the verdict, Should items raise the quality bar, and Won't Test items keep scope in check.

## How to write one

1. Read the plan file in `docs/plans/`, or ask the user which feature needs a contract.
2. Pull out the core user flows — the happy paths and critical error states.
3. Draft the three tiers: Must Pass (3–7 items), Should Pass (1–5), Won't Test.
4. Show the draft and get the user's sign-off before saving.
5. Save to `docs/plans/{feature-name}-contract.md`.

The full template and a worked example are in `references/template.md`.

## Writing guide

### Must Pass — any single failure means FAIL

These are the non-negotiable user flows. If any one of them breaks, the feature isn't shippable.

Aim for 3–7 items. More than 7 usually means the sprint is too big — split it.

Good:
- "New user completes signup, verifies email, and lands on the dashboard"
- "Adding an item to the cart and checking out shows the order confirmation"

Weak:
- "API returns 200" — not a user-facing behavior
- "Code passes TypeScript strict mode" — that's what the linter is for
- "All edge cases are handled" — vague and untestable

### Should Pass — two or more failures means FAIL

These are quality-of-life items. The feature technically works without them, but failing two or more signals the implementation isn't polished enough.

Good:
- "Product list loads in under 2 seconds"
- "Empty state shows a clear call-to-action"
- "Pressing Enter submits the form"

### Won't Test — explicitly out of scope

Name the things you're intentionally skipping. This keeps the Evaluator from wandering into territory that isn't relevant yet.

Examples:
- "Performance under load — this sprint is about correctness"
- "Accessibility — dedicated sprint coming later"
- "Offline support — not in MVP"

### How many items?

| Tier | Min | Sweet spot | Max |
|------|-----|-----------|-----|
| Must | 3 | 5 | 7 |
| Should | 1 | 3 | 5 |
| Won't Test | 1 | 2 | — |

## Getting sign-off

Always review the draft with the user before finalizing:
- "Here's what I'll evaluate against — anything you'd change?"
- Pay special attention to Must vs Should classification. Users often have strong opinions about what's truly blocking vs nice-to-have.
- If the user promotes or demotes an item, update immediately.

## Where this fits

```
/sprint-contract  →  contract saved
  →  Implementation (Generator)
  →  /evaluate (Playwright tests against the contract)
  →  FAIL → feedback → fixes → /evaluate again
  →  PASS → ship
```
