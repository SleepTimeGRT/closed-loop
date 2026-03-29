---
name: evaluate
description: |
  Run the Evaluator against the Sprint Contract — test the live app with Playwright MCP
  and produce a pass/fail verdict with actionable feedback.
  This skill should be used when the user says "evaluate", "test this", "QA", "verify",
  "check against contract", "feedback loop", "run evaluator", "does it pass",
  "check if it works", "ready to test", "did I meet the spec", "is this ready to ship".
  Requires a sprint contract file — if missing, prompt to create one via /sprint-contract first.
version: 0.1.0
---

# Evaluate

Open the app in a browser, walk through the Sprint Contract item by item, and deliver a verdict. This is the quality gate between "code complete" and "ready to ship."

## The evaluator's mindset

The Evaluator is a separate role from the Generator — and that separation is the whole point. When agents evaluate their own work, they tend to declare success even when the quality is obviously lacking. By keeping evaluation independent, you get honest, actionable feedback.

The rules that make this work:

1. **Stay out of the code.** Don't open source files. Don't reason about implementation. You're testing what the user sees, not how it's built.
2. **Stick to the contract.** The Sprint Contract is the only scorecard. Tempting as it is to flag other issues, anything outside the contract is out of scope.
3. **Report symptoms, not fixes.** "The signup form goes blank on duplicate emails" is useful feedback. "You should add a try-catch in the handler" is not — that's the Generator's job.
4. **Capture evidence.** Every judgment needs proof: a screenshot, a console error, or a snapshot of the page state.

## Running an evaluation

### 1. Find the contract

```bash
find docs/plans/ -name "*-contract.md" 2>/dev/null
```

If there's no contract, stop here:
> "No Sprint Contract found. Create one with `/sprint-contract` before evaluating."

### 2. Check prerequisites

Make sure the app is actually running at the URLs the contract specifies:

```bash
curl -s -o /dev/null -w "%{http_code}" {app-url}  # URL from the sprint contract
```

If it's not up, stop:
> "The app isn't running. Start the dev server and try again."

### 3. Test with Playwright MCP

Hand this off to the evaluator agent (`closed-loop:evaluator`) — a subagent scoped to Playwright MCP browser tools only, with no access to source code files. Invoke it via the Agent tool with `subagent_type: "closed-loop:evaluator"`.

The testing pattern for each contract item:
1. `browser_navigate` to the target page
2. `browser_snapshot` the initial state
3. `browser_click` / `browser_fill_form` to perform the user's actions
4. `browser_snapshot` the result
5. `browser_take_screenshot` for the record
6. Compare what happened against what the contract says should happen

### 4. Render the verdict

| Outcome | Verdict |
|---------|---------|
| Every Must passes; at most 1 Should fails | **PASS** |
| Any Must item fails | **FAIL** |
| 2 or more Should items fail | **FAIL** |

### 5. Write the eval file

Save to `docs/plans/{feature-name}-eval.md`.

See `references/eval-template.md` for the output format. See `examples/sample-eval-pass.md` and `examples/sample-eval-fail.md` for what good eval output looks like.

On FAIL, the "Generator Feedback" section at the bottom of the eval file is the handoff document. It should describe what went wrong clearly enough that the Generator can reproduce the issue — without prescribing how to fix it.

## The feedback loop

Evaluation drives an iterative cycle between Generator and Evaluator:

```
Round 1 → PASS → ship it
        → FAIL → Generator reads the eval feedback, fixes, re-runs /evaluate

Round 2 → PASS → ship it
        → FAIL → only the remaining issues go back

Round 3 → PASS → ship it
        → FAIL → something is probably wrong with the spec, not the code
                  → recommend going back to the Planner
```

Three rounds is the cap. If it still isn't passing after three attempts, the contract or the underlying spec likely needs rethinking — grinding on the implementation won't help.

## Round tracking

- No existing eval file → this is Round 1.
- Existing eval shows Round N → this is Round N+1.
- Each round overwrites the previous eval file (no appending).

## Off-limits

- Opening or reading source code
- Suggesting implementation changes
- Testing anything not in the contract
- Ignoring the 3-round cap

## Where this fits in the workflow

```
Planner (spec / review)
  → /sprint-contract (lock the criteria)
  → Architecture review
  → Implementation (Generator)
  → Lint + type check (automatic)
  → /evaluate ← you are here
  → PASS → code review (optional) → ship
```

Quality layers, each catching different things:

| Layer | Tool | What it catches |
|-------|------|-----------------|
| 1 | Lint + type check | Syntax, type errors |
| 2 | /evaluate | Broken user flows, UX issues |
| 3 | Code review | Structural problems, maintainability |
| 4 | E2E test suite | Regressions in existing features |
