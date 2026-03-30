# TODOs

## P1 — /start-loop 실전 테스트 ✅ 완료

### Medicount (2026-03-30)
4 sprints, 3 fix cycles (7→8→8.5). 리뷰: `docs/reviews/medicount-2026-03-30.md`
핵심: Evaluator 브라우저 테스트가 "코드는 맞지만 데이터가 안 맞는" 버그 발견. Generator 초기 품질과 Evaluator 환경 안정성이 병목.

### 삼행시 백일장 (2026-03-30)
8 sprints 전체 PASS, 177 테스트. 리뷰: `docs/reviews/toss-samhaengsi-2026-03-30.md`
핵심: 리뷰 단계(office-hours→CEO→Eng→Design)가 구현 품질에 확실한 영향. Evaluator 미실행(환경 제약)으로 Generator 자체 검증만 수행 — "진짜 closed-loop" 아님.

### 마니또 (2026-03-30)
4 루프, 288 테스트, CF 17개. 리뷰: `docs/reviews/toss-manito-2026-03-30.md`
핵심: Planner가 기존 validation 규칙 안 읽어서 반복 실패. Generator가 에뮬레이터 로그 못 읽어서 수동 개입 20%. 통합 테스트에서만 발견되는 Firestore 트랜잭션 버그 발견 — mock 한계 증명.

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

## P2.5 — 실전 리뷰 기반 개선 (3개 프로젝트 피드백)

**Source:** `docs/reviews/medicount-2026-03-30.md`, `docs/reviews/toss-samhaengsi-2026-03-30.md`, `docs/reviews/toss-manito-2026-03-30.md`

### a. Generator: 실제 데이터 검증 단계 추가 ✅ 완료 (generic "sample real data" 단계로 구현)
- Generator가 스키마만 보고 쿼리를 작성 → 실제 데이터와 안 맞는 문제
- 구현 전에 `SELECT * FROM table LIMIT 5` 등으로 데이터 샘플 확인하는 단계 추가
- 특히 search/filter 쿼리에서 exact match vs partial match 판단에 필수
**Effort:** S (CC: ~15min, generator.md 수정)

### b. Evaluator: 환경 프리플라이트 체크 ✅ 완료 (evaluate SKILL.md Step 2 강화)
- 환경 문제 vs 코드 문제 구분 로직 추가
- 외부 의존성 접근 불가 시 ENVIRONMENT 이슈로 보고

### c. 스크린샷 관리 ✅ 완료
- evaluator.md에 `docs/plans/screenshots/` 경로 지정
- .gitignore에 `docs/plans/screenshots/` 추가

### d. Planner: 암묵적 가정 제거 ✅ 완료 (Step 2.5 "Discover constraints and rules"로 구현)
- validation rules, constants, enums, security rules, API contracts 탐색
- generic하게 구현 (특정 프레임워크 이름 대신 패턴 기반)

### e. 스프린트 간 통합 테스트 ✅ 완료 (Planner sprint sizing guide에 추가)
- 5+ 스프린트 시 통합 테스트 스프린트 자동 포함 가이드

### f. Planner: 기존 코드의 validation/enum/제약 필수 읽기 ✅ 완료 (d와 통합, Step 2.5)
- d와 동일한 Step 2.5에서 처리됨

### g. Generator: 에뮬레이터/런타임 로그 접근 ✅ 완료 (Step 5g "diagnose before fixing"으로 구현)
- 서버/런타임 로그 확인, 데이터 샘플링, 디버그 로깅 단계 추가
- generic하게 구현 (에뮬레이터/docker/프레임워크 로그 모두 커버)

### h. 스펙 변경 시 자동 충돌 검사 ✅ 완료 (Planner에 "Spec conflict check" 섹션 추가)
- 기존 spec과 새 feature의 인터페이스/타이밍/네이밍 충돌 검사
- 충돌 발견 시 유저에게 제시 후 진행

## P3 — /progress 커맨드 + Dependency Visualization

**What:** 프로젝트 상태 조회 커맨드. Feature 목록, 상태, 의존성 ASCII 그래프 출력.
**Why:** spec 진화 구현 시 관측성 도구. 프로젝트가 커질 때 현재 상태 파악에 필수.
**Effort:** S (CC: ~15min)
**Depends on:** P2 (Spec 진화 구현)
**Context:** /status는 Claude Code 내장 커맨드와 충돌하므로 /progress 사용.

## P4 (장기) — 프로젝트별 진화형 Harness

**What:** generic core를 유지하면서, 프로젝트별로 사용할수록 자동 특화되는 구조.
**Why:** 3개 실전 프로젝트에서 공통 패턴 — 같은 프로젝트를 반복 사용할수록 에이전트가 알아야 할 지식(제약조건, 데이터 패턴, 환경 특성)이 축적되는데, 매 세션마다 재발견하면 비효율.
**구상:**
  - `docs/plans/project-profile.md` 자동 생성/업데이트
  - Planner가 발견한 제약조건 → 프로필에 누적
  - Generator가 학습한 데이터 패턴 → 프로필에 누적
  - Evaluator가 학습한 환경 특성 → 프로필에 누적
  - 핵심 원칙: **generic core(agents/*.md)는 건드리지 않고, 프로젝트별 지식만 파일로 축적**
**Effort:** L-XL
**Depends on:** P2 (Spec 진화) + 추가 실전 테스트
**Context:** CEO 리뷰(2026-03-30)에서 "공용 플러그인은 유지하되, 프로젝트별 특화가 장기 목표"로 합의.
