# Changelog

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
