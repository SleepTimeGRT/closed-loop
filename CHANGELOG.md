# Changelog

## 0.4.0

- **Generator: strict TDD** — RED→GREEN hard gate, no broken tests allowed, verification evidence required
- **Generator: failure diagnostics** — check server/runtime logs and sample real data before guessing at fixes
- **Planner: constraint discovery** — auto-discover validation rules, enums, length limits, security rules before sprint decomposition
- **Planner: spec conflict check** — detect interface/timing/naming conflicts when extending existing specs
- **Planner: integration test sprint** — auto-include E2E flow testing sprint for 5+ sprint projects
- **Evaluator: environment preflight** — distinguish environment issues from code bugs, report clearly
- **Evaluator: screenshot management** — screenshots saved to `docs/plans/screenshots/`, not project root
- **Plugin review fixes** — MIT LICENSE, consistent skill descriptions, version fields, trigger phrases
- **Auto-update system** — SessionStart hook checks GitHub for new versions, `/upgrade` command

## 0.3.0

- Renamed `/harness` to `/start-loop` for clearer naming
- Added automatic update check on session start
- Added `/upgrade` command for manual updates
- Added TODOS.md for roadmap tracking

## 0.2.1

- Added HANDOFF.md to .gitignore
- Version bump

## 0.2.0

- Full harness architecture: Planner, Generator, Evaluator autonomous loop
- Generator discovers project test infra and writes tests before implementing
- Generator self-verification gate before Evaluator handoff
- File-based communication via `docs/plans/`
- Sprint contract system with Must Pass / Should Pass / Won't Test
- Evaluator uses Playwright MCP for browser-only QA
