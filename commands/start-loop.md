---
name: start-loop
description: Start an autonomous development loop — plan, build, and evaluate a complete application
---

Start the closed-loop feedback cycle: Planner → Generator ↔ Evaluator.

1. Ask the user what they want to build (or read the request if already provided).
2. Spawn the Planner to create a spec with sprint decomposition.
3. Get user sign-off on the spec.
4. For each sprint: generate contract → implement → evaluate → fix until PASS.
5. Report completion when all sprints pass.

This is the main entry point for long-running autonomous development. The loop runs automatically — the user only needs to approve the initial spec. If previous progress exists in `docs/plans/`, the loop resumes from where it left off.
