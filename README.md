# Closed Loop

A Claude Code plugin that builds complete applications through a self-correcting feedback loop. Instead of relying on a single agent to both build and judge its own work, Closed Loop separates **generation** from **evaluation** — the same insight behind code review, but automated and structured.

Inspired by [Anthropic's Harness architecture](https://www.anthropic.com/engineering/start-loop-design-long-running-apps) for long-running autonomous development.

## The problem

When you ask an agent to build something and then evaluate what it built, it almost always says the work is great — even when it clearly isn't. Self-evaluation is unreliable because the same context that produced the code also produces the judgment.

## How it works

Three agents — **Planner**, **Generator**, **Evaluator** — coordinate through file-based communication in an autonomous feedback loop.

```
User request (1-4 sentences)
  ↓
[Planner] → detailed spec + sprint decomposition
  ↓
  For each sprint:
  ┌─────────────────────────────────────────┐
  │ [Sprint Contract] → lock the criteria   │
  │        ↓                                │
  │ [Generator] → implement the code        │
  │        ↓                                │
  │ [Evaluator] → test via browser          │
  │        ↓                                │
  │   PASS → next sprint                    │
  │   FAIL → Generator reads feedback       │
  │          → fixes → Evaluator retests    │
  │          (max 3 rounds)                 │
  └─────────────────────────────────────────┘
  ↓
All sprints PASS → done
```

### The agents

**Planner** — Takes a brief request and expands it into a detailed spec with sprint decomposition. Each sprint delivers a working, testable increment.

**Generator** — Autonomous coding agent. Implements each sprint, then reads evaluation feedback and fixes issues until the sprint passes. Stays in scope — only implements what's in the contract.

**Evaluator** — Skeptical QA agent. Opens the running app in a browser via Playwright MCP, walks through the contract item by item, and delivers a pass/fail verdict with evidence. No source code access. No fix suggestions. Just symptoms and proof.

### The contract

A Sprint Contract defines what "done" looks like in three tiers:

- **Must Pass** (3-7 items) — any single failure means FAIL
- **Should Pass** (1-5 items) — two or more failures means FAIL
- **Won't Test** — explicitly out of scope

This prevents two failure modes: infinite loops where every minor issue blocks shipping, and scope creep where the evaluator starts testing things nobody asked for.

## Prerequisites

- **Playwright MCP server** must be configured and available. The evaluator uses Playwright browser tools to test the running app.
- **A running dev server.** The evaluator tests against a live app — it needs something to point a browser at.

## Quick start

### 1. Install the plugin

```bash
claude plugin:add closed-loop@sleeptimegrt-plugins
# or directly
claude plugin:add --url https://github.com/SleepTimeGRT/closed-loop
```

### 2. Full autonomous loop

```
/start-loop
> Build a recipe sharing app where users can post recipes with photos,
> search by ingredient, and save favorites.
```

What happens next:

1. **Planner** creates `docs/plans/spec.md` — 5 sprints covering auth, recipe CRUD, search, favorites, polish
2. You review and approve the spec
3. For each sprint, the loop runs automatically:
   - Orchestrator writes the sprint contract
   - **Generator** implements the code, starts the dev server
   - **Evaluator** opens the browser, clicks through every contract item
   - On FAIL: Generator reads the eval feedback, fixes, Evaluator retests
   - On PASS: next sprint

### 3. Standalone commands

You can also use the building blocks independently:

```
/sprint-contract    → define pass/fail criteria before you start coding
/evaluate           → test what you built against the contract
```

This is useful when you're coding manually and just want the evaluation loop — without the full Planner/Generator automation.

## Example: what the files look like

After running `/start-loop`, your `docs/plans/` directory contains:

```
docs/plans/
├── spec.md                  # Full spec from the Planner
├── sprint-1-contract.md     # What Sprint 1 must achieve
├── sprint-1-eval.md         # Evaluator's verdict (PASS round 1)
├── sprint-2-contract.md     # What Sprint 2 must achieve
├── sprint-2-eval.md         # Evaluator's verdict (FAIL round 1, PASS round 2)
├── sprint-3-contract.md
└── sprint-3-eval.md
```

A sprint contract looks like:

```markdown
# Sprint 1: Project skeleton + auth

**App URL:** http://localhost:3000

## Must Pass
1. Dev server starts and the app is reachable at http://localhost:3000
2. Landing page renders with app name and navigation
3. User can sign up with email and password
4. User can log in and sees the dashboard
5. Logged-out user is redirected to login page

## Should Pass
1. Form validation shows errors for invalid email
2. Password field masks input

## Won't Test
- Social login (Sprint 4)
- Profile editing (Sprint 3)
```

An eval result (on failure) looks like:

```markdown
# Evaluation: Sprint 2 — Recipe CRUD

Verdict: **FAIL**
Round: 1/3

## Results
| # | Tier   | Item                              | Result |
|---|--------|-----------------------------------|--------|
| 1 | Must   | User can create a recipe          | PASS   |
| 2 | Must   | Recipe displays with all fields   | FAIL   |
| 3 | Must   | User can edit their own recipe    | PASS   |

## Failure details

### FAIL #2: Recipe displays with all fields
- **Expected**: Recipe page shows title, ingredients, steps, and photo
- **Actual**: Photo area shows a broken image icon. Alt text reads "undefined"
- **Repro**: Navigate to /recipes/1 → photo section shows broken image
- **Console errors**: GET http://localhost:3000/uploads/undefined 404

## Generator feedback
The recipe detail page renders but the photo URL is not being passed correctly.
The image src contains "undefined" instead of the actual file path.
```

## What's in the box

| Component | File | Purpose |
|-----------|------|---------|
| `/start-loop` command | `commands/start-loop.md` | Entry point for autonomous development loop |
| `/sprint-contract` command | `commands/sprint-contract.md` | Entry point for creating a contract |
| `/evaluate` command | `commands/evaluate.md` | Entry point for running an evaluation |
| Start Loop skill | `skills/start-loop/` | Full orchestration — planner → generator ↔ evaluator |
| Sprint Contract skill | `skills/sprint-contract/` | Detailed guide for writing good contracts |
| Evaluate skill | `skills/evaluate/` | Full evaluation procedure, templates, examples |
| Planner agent | `agents/planner.md` | Spec expansion + sprint decomposition |
| Generator agent | `agents/generator.md` | Autonomous coding + self-correction from feedback |
| Evaluator agent | `agents/evaluator.md` | Skeptical QA via Playwright browser testing |

## Troubleshooting

**"No Sprint Contract found"**
Run `/sprint-contract` first, or use `/start-loop` which creates contracts automatically.

**Evaluator can't reach the app**
Make sure your dev server is running. The Generator starts it automatically in `/start-loop` mode, but in standalone `/evaluate` mode, you need to start it yourself.

**Sprint keeps failing after 3 rounds**
The problem is likely in the contract or spec, not the code. Options:
1. Revise the sprint contract to be more realistic
2. Split the sprint into smaller pieces
3. Skip and come back later

**Evaluator reports things not in the contract**
This shouldn't happen — the Evaluator is scoped to contract items only. If it does, the contract may be ambiguous. Tighten the wording.

**Want to resume after a session died?**
The `docs/plans/` files are the durable state. Start a new session and run `/start-loop` — it will detect existing files and offer to resume from the last completed sprint.

## Design decisions

**Why three agents?** The GAN-inspired separation is the core insight. The Generator builds, the Evaluator breaks. Neither can do the other's job, and that tension produces better results than a single agent doing both. The Planner provides the structure they operate within.

**Why file-based communication?** Every piece of agent output — specs, contracts, eval results — is written to `docs/plans/`. This creates an audit trail and enables the feedback loop: the Generator reads the eval file to know exactly what to fix.

**Why sprints?** Complex applications can't be built in one pass. Sprints break the work into independently testable increments. Each sprint builds on the last, and each one passes through the full generate-evaluate loop.

**Why a 3-round cap?** If the implementation still fails after three evaluation rounds, the problem is almost certainly in the spec — not the code. Continuing to iterate would be grinding against a flawed target.

**Why three tiers in the contract?** Must / Should / Won't Test prevents two failure modes: (1) infinite loops where every minor issue blocks shipping, and (2) scope creep where the evaluator starts testing things nobody asked for.

## Reference

- [Harness: designing agents for long-running application development](https://www.anthropic.com/engineering/start-loop-design-long-running-apps) — the Anthropic engineering blog post that inspired this plugin's architecture.
