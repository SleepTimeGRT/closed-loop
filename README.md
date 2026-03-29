# Closed Loop

A Claude Code plugin that adds a self-correcting feedback loop to your development workflow. Instead of relying on a single agent to both build and judge its own work, Harness separates **generation** from **evaluation** — the same insight behind code review, but automated and structured.

## The problem

When you ask an agent to build something and then evaluate what it built, it almost always says the work is great — even when it clearly isn't. Self-evaluation is unreliable because the same context that produced the code also produces the judgment.

## How Harness fixes it

Harness introduces two workflow steps that sit between "code complete" and "ready to ship":

1. **Sprint Contract** (`/sprint-contract`) — Before implementation, define exactly what "done" looks like in terms a browser can verify. Must-pass items, should-pass items, and explicit exclusions.

2. **Evaluate** (`/evaluate`) — After implementation, a separate evaluator agent opens the running app in a browser, walks through the contract item by item, and delivers a pass/fail verdict with evidence.

If the evaluation fails, the feedback goes back to the generator with specific, reproducible symptoms — not vague complaints. The generator fixes the issues and the evaluation runs again, up to three rounds.

```
/sprint-contract  →  lock the criteria
     ↓
  implement
     ↓
/evaluate         →  PASS → ship
                  →  FAIL → read feedback → fix → /evaluate again (max 3 rounds)
                  →  3x FAIL → spec needs rethinking
```

## Prerequisites

- **Playwright MCP server** must be configured and available. The evaluator agent uses Playwright browser tools (`browser_navigate`, `browser_click`, `browser_snapshot`, etc.) to test the running app. If you have the `playwright` plugin installed, this is already set up.

- **A running dev server.** The evaluator tests against a live app — it needs something to point a browser at.

## What's in the box

| Component | File | Purpose |
|-----------|------|---------|
| `/sprint-contract` command | `commands/sprint-contract.md` | Entry point for creating a contract |
| `/evaluate` command | `commands/evaluate.md` | Entry point for running an evaluation |
| Sprint Contract skill | `skills/sprint-contract/` | Detailed guide for writing good contracts |
| Evaluate skill | `skills/evaluate/` | Full evaluation procedure, templates, examples |
| Evaluator agent | `agents/evaluator.md` | Skeptical QA subagent scoped to browser-only testing |

## Quick start

1. Install the plugin.
2. When you're about to implement a feature, run `/sprint-contract` to define what success looks like.
3. Build the feature.
4. Run `/evaluate` to test against the contract.
5. If it fails, read the feedback, fix the issues, and run `/evaluate` again.

## Design decisions

**Why a separate agent for evaluation?** The evaluator agent is configured with `color: red` and explicit rules against reading source code or suggesting fixes. This isn't just convention — it's enforced at the agent level so the evaluation stays focused on what the user sees, not how the code works.

**Why three tiers in the contract?** Must / Should / Won't Test prevents two failure modes: (1) infinite loops where every minor issue blocks shipping, and (2) scope creep where the evaluator starts testing things nobody asked for.

**Why a 3-round cap?** If the implementation still fails after three evaluation rounds, the problem is almost certainly in the spec — not the code. Continuing to iterate on the implementation would be grinding against a flawed target.
