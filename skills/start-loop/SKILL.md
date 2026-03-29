---
name: start-loop
version: 0.1.0
description: |
  Autonomous development loop that builds complete applications from a brief request.
  Three agents — Planner, Generator, Evaluator — run in a self-correcting feedback loop.
  This skill should be used when the user says "start loop", "start-loop", "build this",
  "make this app", "build it for me", "create this app", "implement this",
  "autonomous build", "full build", "build from scratch", or describes an application
  they want built end-to-end. Also triggers when the user provides a 1-4 sentence app
  description and expects a complete, working result.
  This is the main entry point for long-running autonomous development.
---

# Start Loop — Autonomous Development Cycle

Build complete, working applications from a brief request. Three agents — Planner, Generator, Evaluator — coordinate through file-based communication in an autonomous feedback loop.

## The architecture

```
User request (1-4 sentences)
  ↓
[Planner] → docs/plans/spec.md (detailed spec + sprints)
  ↓
  ↓ For each sprint:
  ↓   ┌─────────────────────────────────────────┐
  ↓   │ [Sprint Contract] → {sprint}-contract.md │
  ↓   │        ↓                                  │
  ↓   │ [Generator] → implements code             │
  ↓   │        ↓                                  │
  ↓   │ [Evaluator] → tests via browser           │
  ↓   │        ↓                                  │
  ↓   │   PASS → next sprint                      │
  ↓   │   FAIL → Generator reads feedback → fix   │
  ↓   │          → Evaluator retests (max 3)      │
  ↓   └─────────────────────────────────────────┘
  ↓
All sprints PASS → done
```

## Workflow

### Phase 0: Setup

Before starting, collect two things from the user:

1. **The request** — what they want built (1-4 sentences is enough)
2. **The dev server URL** — where the app will run (default: `http://localhost:3000`). Ask once, remember for all sprints.

Create the `docs/plans/` directory if it doesn't exist.

### Phase 1: Planning

Spawn the Planner agent to expand the request into a spec.

```
Use the Agent tool:
  subagent_type: "closed-loop:planner"
  description: "Planning app architecture"
  prompt: |
    Read the user request below and create a detailed spec with sprint decomposition.
    Save to docs/plans/spec.md.

    User request: {user_request}
```

After the Planner finishes, read `docs/plans/spec.md` and present the sprint summary:
- Number of sprints and their goals
- Key features per sprint
- Out of scope items

**Get user sign-off before proceeding.** If the user wants changes, re-run the Planner with the feedback. Once approved, the spec is frozen.

### Phase 2: Sprint execution loop

For each sprint in the spec, run: contract → generate → evaluate → (fix loop).

Track state as you go:
- `current_sprint`: which sprint number (1-based)
- `current_round`: which eval round (1-3)
- `app_url`: the dev server URL from Phase 0

#### Step 1: Generate the Sprint Contract

Write the contract yourself (the orchestrator) based on the spec. Use the sprint-contract skill's principles:
- Must Pass: 3-7 items describing user-visible behaviors
- Should Pass: 1-5 quality items
- Won't Test: what's out of scope for this sprint

Save to `docs/plans/sprint-{N}-contract.md`.

For Sprint 1, always include: "Dev server starts and the app is reachable at {app_url}."

#### Step 2: Run the Generator

Spawn the Generator agent. It has full code access (Read, Write, Edit, Bash).

```
Use the Agent tool:
  subagent_type: "closed-loop:generator"
  description: "Implementing sprint {N}"
  prompt: |
    Implement Sprint {N}: {sprint_name}.

    Read the full spec: docs/plans/spec.md
    Read your contract: docs/plans/sprint-{N}-contract.md

    The app should be reachable at {app_url} when you're done.
    Start the dev server if it's not running.

    {If sprint > 1: "This builds on previous sprints. Read the existing codebase first."}

    Implement all contract items. Before signaling completion, you MUST pass
    your self-verification checklist: build, lint, type check, existing tests,
    and dev server health. Only signal "Implementation complete" after all
    checks pass.
```

If the Generator fails to produce output (timeout, error), report to the user and ask how to proceed.

**Why the Generator verifies first:** The Evaluator is expensive — it launches a browser and clicks through the app. Build failures, type errors, and broken tests are cheap to catch. The Generator's self-check gate ensures the Evaluator only spends time on user-facing issues that code-level checks can't find.

#### Step 3: Run the Evaluator

After the Generator completes, spawn the Evaluator. It has browser-only access.

```
Use the Agent tool:
  subagent_type: "closed-loop:evaluator"
  description: "Evaluating sprint {N}"
  prompt: |
    Test the running app at {app_url} against the sprint contract.

    Contract: docs/plans/sprint-{N}-contract.md
    Write results to: docs/plans/sprint-{N}-eval.md

    This is evaluation round {current_round}.
```

If the Evaluator can't reach the app, check if the dev server is running. If not, ask the Generator to restart it before retrying.

#### Step 4: Handle the verdict

Read `docs/plans/sprint-{N}-eval.md` and check the verdict.

**PASS →** Log and advance:
> "Sprint {N} PASSED (round {R}). Moving to Sprint {N+1}."

Increment `current_sprint`, reset `current_round` to 1.

**FAIL + round < 3 →** Feed eval back to Generator:

```
Use the Agent tool:
  subagent_type: "closed-loop:generator"
  description: "Fixing sprint {N} round {R}"
  prompt: |
    Your implementation failed evaluation round {R}.

    Read the feedback: docs/plans/sprint-{N}-eval.md
    Read the contract: docs/plans/sprint-{N}-contract.md

    Fix ONLY the items marked FAIL. Do not touch passing items.
    The app must remain reachable at {app_url}.

    Signal completion when done.
```

Increment `current_round`, go back to Step 3.

**FAIL + round = 3 →** Stop and escalate to the user:
> "Sprint {N} failed after 3 rounds.
>  Failing items: {list from eval}
>  The contract or spec may need revision. Options:
>  1. Revise the sprint contract and retry
>  2. Simplify the sprint scope
>  3. Skip this sprint and continue"

### Phase 3: Completion

When all sprints pass:

1. Summary: what was built, sprints completed, total rounds used
2. Files created/modified by each sprint
3. Suggest next steps: manual QA, code review, `/evaluate` for targeted retesting, deployment

## File-based communication

All agent communication happens through files in `docs/plans/`:

| File | Written by | Read by |
|------|-----------|---------|
| `spec.md` | Planner | Orchestrator, Generator |
| `sprint-{N}-contract.md` | Orchestrator | Generator, Evaluator |
| `sprint-{N}-eval.md` | Evaluator | Generator, Orchestrator |

File naming uses sprint numbers (`sprint-1`, `sprint-2`) not sprint names, to avoid path issues with spaces or special characters.

This is intentional. File-based communication creates an audit trail — you can always see exactly what each agent produced and what feedback was given.

## Error recovery

| Situation | Action |
|-----------|--------|
| Planner produces no spec | Ask user to clarify the request, retry |
| Generator times out | Report to user with partial progress, ask to continue or adjust scope |
| Evaluator can't reach app | Check if dev server is running, ask Generator to restart if needed |
| Dev server crashes mid-eval | Re-run Generator to restart server, then re-run Evaluator (same round) |
| Sprint fails 3 rounds | Escalate to user with options (revise contract, simplify, skip) |
| User interrupts | Pause, ask what to change. Resume from last completed sprint. |

## Existing codebase

When running `/start-loop` on a project that already has code:

1. **Planner must explore first.** The Planner agent reads the existing codebase (tech stack, patterns, data models) before writing the spec. The spec should build on what exists, not start from scratch.

2. **Sprint 1 is different.** Instead of scaffolding a new project, Sprint 1 integrates the new feature into the existing architecture. The contract should include: "Existing functionality is not broken."

3. **Generator respects conventions.** The Generator prompt for existing codebases should include: "Match the existing code style, use existing components/utilities, and follow established patterns."

## Resuming after interruption

The `docs/plans/` directory is the durable state. To resume:

1. Read `docs/plans/spec.md` for the full plan
2. List all `sprint-{N}-eval.md` files to find the last completed sprint
3. Check the last eval's verdict:
   - PASS → start the next sprint
   - FAIL → check the round number and continue the fix loop
   - No eval file for sprint N → the Generator was interrupted, re-run it
4. Ask the user to confirm the app URL and dev server status

## Practical tips

- **First sprint is critical.** It sets up the project skeleton. If Sprint 1 fails, everything downstream is blocked. Include dev server setup in Sprint 1's contract.
- **Don't parallelize sprints.** They build on each other. Run them strictly in order.
- **Keep the user informed.** After each sprint passes, give a one-line update. Don't wait until all sprints are done.
- **Sprint naming convention.** Use `sprint-{N}` for file names. The sprint's descriptive name goes inside the contract file, not the filename.
- **Resumability.** If the session dies, the files in `docs/plans/` are the state. A new session can read the spec, find the last eval file, and continue from there.
