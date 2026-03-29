---
name: sprint-contract
description: Define pass/fail criteria for the current feature before implementation begins
---

Draft a Sprint Contract for the current feature by reading the plan and extracting testable criteria.

1. Find the plan file in `docs/plans/`, or ask the user which feature to write a contract for.
2. Identify the core user flows and edge cases worth guarding.
3. Draft Must Pass (3–7), Should Pass (1–5), and Won't Test items.
4. Review with the user and get their sign-off.
5. Save to `docs/plans/{feature-name}-contract.md`.

Every item should describe something a user can see or do in a browser. If it can't be verified by clicking through the app, it doesn't belong in the contract.
