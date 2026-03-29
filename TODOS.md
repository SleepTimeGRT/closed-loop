# TODOs

## P1 — /start-loop 실전 테스트

**What:** 실제 프로젝트에서 /start-loop를 end-to-end로 돌리기. 3-5 sprint까지 진행.
**Why:** 플러그인의 핵심 가치 검증. Spec 진화 설계의 전제 조건. 현재까지 구조적 검증만 됨.
**Effort:** M (CC: ~30min)
**Depends on:** Playwright MCP 설정 + 테스트할 프로젝트 선정
**Context:** HANDOFF.md "Next Steps" #1에서도 언급됨. zero-based project (새 프로젝트)와 existing codebase 모두 테스트 필요.

## P2 — Spec 진화 구현 (post-validation)

**What:** /start-loop 검증 후, spec이 성장하는 프로젝트를 지원하는 기능 구현.
**Why:** 실전 경험에서 실제 한계를 확인한 후 적용. 추측이 아닌 관찰 기반 설계.
**Effort:** L (CC: ~1hr)
**Depends on:** P1 완료. /start-loop가 실제로 어디서 깨지는지 확인 후.
**Context:** 디자인 문서 보존됨: `~/.gstack/projects/SleepTimeGRT-closed-loop/minchul-main-design-20260329-141634.md`. 두 가지 경로:
  1. 단순한 경로 (Codex 제안): flat spec.md + "active feature" 섹션 + 크기 임계값 초과 시만 분리
  2. Living Spec Tree (디자인 문서): spec-index.md + features/{name}/spec.md 트리 구조
  실전에서 flat spec의 한계가 확인되면 Living Spec Tree로 진화.
  /evolve 별도 커맨드 대신 /start-loop 확장으로 구현 (Codex 피드백 반영).

## P3 — /progress 커맨드 + Dependency Visualization

**What:** 프로젝트 상태 조회 커맨드. Feature 목록, 상태, 의존성 ASCII 그래프 출력.
**Why:** spec 진화 구현 시 관측성 도구. 프로젝트가 커질 때 현재 상태 파악에 필수.
**Effort:** S (CC: ~15min)
**Depends on:** P2 (Spec 진화 구현)
**Context:** /status는 Claude Code 내장 커맨드와 충돌하므로 /progress 사용.
