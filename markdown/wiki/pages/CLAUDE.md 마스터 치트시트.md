> [!info] 카테고리: AI·IT | 소스: 웹 | 날짜: 2026-05-12
> 채널/출처: Notion | URL: https://raspy-roll-970.notion.site/Claude-Code-CLAUDE-md-35df7725c9d981c3a349c2e9745bf013#10cb757d12d84c6392566c48cd35a837

## 핵심 요약

CLAUDE.md를 단순한 인간용 README가 아니라 "Claude가 같은 실수를 반복하지 않게 하는 가드레일"로 활용하는 핵심 가이드. CLAUDE.md의 작동 방식, 8레이어 컨텍스트 구조, 효과적인 작성 원칙 및 자동 관리 플러그인까지 다루어 코드 작성 시 AI의 오작동을 줄이고 생산성을 극대화하는 방법을 안내한다.

---

## 상세 내용

### 1. CLAUDE.md의 작동 원리
Claude Code는 매 메시지마다 다음 4가지 위치에서 CLAUDE.md를 자동으로 읽어와 합쳐서 전달한다.
- `~/.claude/CLAUDE.md` (전역): 개인 노트. 모든 프로젝트 공통 규칙.
- `<repo>/.claude/CLAUDE.md` (프로젝트 전역): 회사 가이드. 팀 공유 (소스컨트롤 포함).
- `<repo>/CLAUDE.local.md` (개인/로컬): 개인 단축어나 임시 규칙 (.gitignore).
- `<subdir>/CLAUDE.md` (서브디렉토리): 부서별/폴더별 규칙.

**8-layer 컨텍스트 모델:**
시스템 프롬프트, 도구 정의, 전역 CLAUDE.md, 프로젝트 CLAUDE.md, CLAUDE.local.md, 서브디렉토리 CLAUDE.md, 대화 히스토리, 사용자 메시지 순서로 로드되며, 아래로 갈수록 더 구체적이고 우선순위가 높다. `/memory` 명령어로 로드된 상태를 확인할 수 있다.

### 2. 좋은 CLAUDE.md 작성법
- **제1원칙 (Non-obvious invariants only):** 코드를 통해 알 수 있는 정보(예: "React 사용")는 쓰지 않고, 숨겨진 규칙(예: "Hooks 내 fetch 금지, useSWR 사용")만 명시한다.
- **공식 4대 원칙:** Specific (구체적으로), Structured (구조화), Reviewed (월 1회 점검), Concise (100줄 이하 유지).
- **High-ROI 워크플로우:** Claude가 실수했을 때 즉시 지적하여 "이 규칙을 CLAUDE.md에 추가해달라"고 요청한다. 채팅창에 `#`을 입력하여 단축 메모를 남겨도 된다.
- **필수 명령어:** 빌드(`npm run build`), 테스트, 린트(`npm run lint:fix`) 명령어를 반드시 포함해야 탐색에 낭비되는 시간과 토큰을 아낄 수 있다.
- **분할 관리 (@import):** 내용이 길어지면 `@./docs/coding-style.md`와 같이 분할하고, `AGENTS.md`를 함께 두어 Codex 등 다른 도구와 규칙을 공유할 수도 있다.

### 3. 플러그인 & 스킬 자동 관리
- **Karpathy 스킬:** Andrej Karpathy의 워크플로우를 스킬 형태로 `~/.claude/skills/`에 추가하고 전역 CLAUDE.md에 등록하여 범용적으로 사용한다.
- **claude-md-management 플러그인:** 공식 플러그인으로, `/revise-claude-md` 명령어로 기존 항목을 분석하고 `/claude-md-improver` 명령어로 자동 리팩토링 및 다이어트를 수행한다. 월 1회 실행을 권장한다.

---

## 관련 페이지

- [[클로드 코드 마스터 가이드]]
- [[하네스 프레임워크 세팅 가이드]]
- [[코덱스 바이브 코딩]]
