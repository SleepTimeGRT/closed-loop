# Closed Loop Plugin — Development Spec

## Overview

Claude Code 플러그인으로, 자율적 개발 피드백 루프를 제공한다. Anthropic의 Harness 아키텍처에서 영감을 받아, Planner → Generator ↔ Evaluator 3개 에이전트가 협업하여 완전한 애플리케이션을 만든다.

## Current State

v0.2.0 — 기본 구조 완성. 3개 에이전트, 3개 커맨드, 3개 스킬이 정의되어 있음.

## Sprints

### Sprint 1: Agent definitions 검증 및 보강 ✅
**Goal:** 3개 에이전트(planner, generator, evaluator)의 정의가 실제로 Claude Code에서 동작 가능한 수준으로 완성

Done:
- planner.md — 스펙 확장 + 스프린트 분해
- generator.md — 자율 코딩 + eval 피드백 자동 수정
- evaluator.md — Playwright 브라우저 QA

### Sprint 2: Harness orchestration 검증 ✅
**Goal:** `/start-loop` 커맨드가 실제로 planner → generator ↔ evaluator 루프를 오케스트레이션할 수 있는 수준

**Depends on:** Sprint 1

Done:
- Agent 호출 패턴을 실제 Claude Code Agent 도구 형태로 수정
- Phase 0 (Setup) 추가 — app URL 수집, docs/plans/ 생성
- Sprint 파일 네이밍 통일: `sprint-{N}-contract.md`, `sprint-{N}-eval.md`
- 에러 복구 테이블 추가 (timeout, server crash, 3-round fail 등)
- Resumability 안내 추가 — 세션이 죽어도 파일 기반 상태에서 재개 가능
- Sprint Contract 생성 주체 명확화 — 오케스트레이터가 직접 작성

### Sprint 3: Edge cases & robustness ✅
**Goal:** 실제 사용 시 발생할 수 있는 엣지 케이스에 대한 가이드가 포함됨

**Depends on:** Sprint 2

Done:
- Harness skill: 기존 코드베이스 대응 섹션, 세션 재개(resume) 절차 추가
- Generator agent: 기존 코드베이스 작업 가이드, dev server 관리 절차 추가
- Planner agent: 기존 코드베이스 탐색, 요청이 너무 클 때 MVP 컷 전략 추가
- Evaluator agent: 앱 미응답, 빈 페이지, 모호한 계약, flaky 동작 대응 추가

### Sprint 4: Documentation & examples ✅
**Goal:** 새 사용자가 README만 읽고 바로 `/start-loop`를 실행할 수 있는 수준

**Depends on:** Sprint 3

Done:
- README에 Quick start (설치 → /start-loop 실행 → 자동 진행 흐름 설명)
- 실제 프롬프트 예시: 레시피 공유 앱 시나리오
- docs/plans/ 디렉토리 구조 예시
- Sprint contract 예시 (Must/Should/Won't Test)
- Eval 결과 예시 (FAIL 케이스 — 구체적 증상, repro steps, console errors)
- Troubleshooting 가이드 5가지 시나리오

## Out of Scope

- Evaluator 외부 로그 수집 기능 (향후 버전)
- 멀티 프로젝트 지원
- 비용 최적화 (model 선택 전략)
- CI/CD 통합
