---
name: evaluate
description: Test the implementation against the Sprint Contract and deliver a pass/fail verdict
---

Find the Sprint Contract in `docs/plans/` and run the evaluator agent against the live app.

1. Locate the `*-contract.md` file. If none exists, tell the user to run `/sprint-contract` first.
2. Spin up the evaluator agent (`closed-loop:evaluator`) to test each contract item via Playwright MCP.
3. Write results to `docs/plans/{feature}-eval.md`.
4. Report the verdict.

On **FAIL**: surface the feedback summary and suggest "fix the flagged issues, then run `/evaluate` again."
On **PASS**: confirm completion and suggest next steps (code review, ship).

The loop runs up to 3 rounds. After 3 consecutive failures, recommend revisiting the spec.
