---
title: "Claude Code — CLAUDE.md 마스터 치트시트"
source: "https://raspy-roll-970.notion.site/Claude-Code-CLAUDE-md-35df7725c9d981c3a349c2e9745bf013#10cb757d12d84c6392566c48cd35a837"
author:
published:
created: 2026-05-12
description: "A collaborative AI workspace, built on your company context. Build and orchestrate agents right alongside your team's projects, meetings, and connected apps."
tags:
  - "clippings"
---
![⚡ Page icon](https://notion-emojis.s3-us-west-2.amazonaws.com/prod/svg-twitter/26a1.svg)

이 페이지는 [CLAUDE.md](http://claude.md/) 작성법 영상의 핵심 정리 치트시트입니다. [CLAUDE.md](http://claude.md/) 를 "README"가 아니라 "Claude가 같은 실수를 안 하게 하는 가드레일"이라는 관점에서 다시 설계합니다. 작동 원리, 크기 관리, 작성 팁, 공식 플러그인까지 한 페이지에 담았습니다.[1\. CLAUDE.md는 어떻게 작동하는가](https://raspy-roll-970.notion.site/Claude-Code-CLAUDE-md-35df7725c9d981c3a349c2e9745bf013?pvs=25#2bd69b72b2954501887f4b9517ec8120)[1-1. 자동 로드되는 4가지 위치](https://raspy-roll-970.notion.site/Claude-Code-CLAUDE-md-35df7725c9d981c3a349c2e9745bf013?pvs=25#db128923d7bd41c4bdc28bdde071954d)[1-2. 8-layer 컨텍스트 모델](https://raspy-roll-970.notion.site/Claude-Code-CLAUDE-md-35df7725c9d981c3a349c2e9745bf013?pvs=25#af114f25ade04764a463cccb98527845)[2\. 좋은 CLAUDE.md 쓰는 법 (핵심)](https://raspy-roll-970.notion.site/Claude-Code-CLAUDE-md-35df7725c9d981c3a349c2e9745bf013?pvs=25#f579a411672247d1926e57682f80048f)[2-1. 제1원칙 — Non-obvious invariants only](https://raspy-roll-970.notion.site/Claude-Code-CLAUDE-md-35df7725c9d981c3a349c2e9745bf013?pvs=25#bdf9aa7d6dc54571b5be846ca5f12f31)[2-2. 공식 4가지 원칙](https://raspy-roll-970.notion.site/Claude-Code-CLAUDE-md-35df7725c9d981c3a349c2e9745bf013?pvs=25#35f51b93404443358b7657ba838759e6)[2-3. High-ROI 워크플로우 — 오늘의 핵심](https://raspy-roll-970.notion.site/Claude-Code-CLAUDE-md-35df7725c9d981c3a349c2e9745bf013?pvs=25#d84df70bcf2e4c5788dcae24c949772d)[2-4. 빌드·테스트·린트 명령어를 꼭 넣어라](https://raspy-roll-970.notion.site/Claude-Code-CLAUDE-md-35df7725c9d981c3a349c2e9745bf013?pvs=25#78813964d0e94e068bb617b5e3c47924)[2-5. @import로 분할 관리하기](https://raspy-roll-970.notion.site/Claude-Code-CLAUDE-md-35df7725c9d981c3a349c2e9745bf013?pvs=25#5e965f96e8a8460ea8ac0ffba775e07c)[2-6. 안티패턴 정리](https://raspy-roll-970.notion.site/Claude-Code-CLAUDE-md-35df7725c9d981c3a349c2e9745bf013?pvs=25#1ab782ec4cb941adb2aa804d0131feae)[3\. 플러그인 & 스킬로 자동 관리](https://raspy-roll-970.notion.site/Claude-Code-CLAUDE-md-35df7725c9d981c3a349c2e9745bf013?pvs=25#61704095064f422b88254c44d81ce726)[3-1. 전역에 Karpathy 스킬 넣기](https://raspy-roll-970.notion.site/Claude-Code-CLAUDE-md-35df7725c9d981c3a349c2e9745bf013?pvs=25#55562dd2687940b9a00340b3f6b5984b)[3-2. claude-md-management 플러그인 (메인 도구)](https://raspy-roll-970.notion.site/Claude-Code-CLAUDE-md-35df7725c9d981c3a349c2e9745bf013?pvs=25#0da2760d7ade4be3829cb24f55566baf)[3-3. 팀에서 관리하는 법 (보너스)](https://raspy-roll-970.notion.site/Claude-Code-CLAUDE-md-35df7725c9d981c3a349c2e9745bf013?pvs=25#9c4a7006069d4b0b85e7d255163f6c0f)[4\. 한 페이지 체크리스트](https://raspy-roll-970.notion.site/Claude-Code-CLAUDE-md-35df7725c9d981c3a349c2e9745bf013?pvs=25#10cb757d12d84c6392566c48cd35a837)

오늘의 한 줄 정의 "인간이 읽는 README가 아니라, Claude가 같은 실수를 안 하게 하는 instructions" 이 한 줄만 받아들이면 [CLAUDE.md](http://claude.md/) 를 쓰는 방식이 바뀝니다. 더 짧아지고, 더 정확해지고, 결과 품질이 올라갑니다.

## 1\. CLAUDE.md는 어떻게 작동하는가

### 1-1. 자동 로드되는 4가지 위치

[CLAUDE.md](http://claude.md/) 는 한 군데에 있는 파일이 아닙니다. Claude Code는 매 메시지마다 아래 4가지 위치에서 자동으로 읽어와 합쳐서 전달합니다. 직접 import하거나 호출할 필요가 없습니다.

| 위치 | 용도 | 비유 |
| --- | --- | --- |
| ~/.claude/CLAUDE.md | 전역 — 모든 프로젝트 공통 | 내 개인 노트 |
| <repo>/.claude/CLAUDE.md | 팀 공유 — 소스컨트롤에 체크인 | 회사 가이드 |
| <repo>/CLAUDE.local.md | 개인 per-repo —  .gitignore  에 추가 | 책상 위 메모 |
| <subdir>/CLAUDE.md | 서브디렉토리 — 특정 폴더만 적용 | 부서별 규칙 |

어디에 둘지 결정하는 한 줄 규칙 • 범용적이면 → 위쪽 (전역/팀 공유) • 특수하면 → 아래쪽 ([CLAUDE.local.md](http://claude.local.md/), 서브디렉토리) 예: 내 코딩 스타일·커뮤니케이션 선호도 → 전역 / 빌드·테스트 명령어 → 팀 공유 / 개인 단축어·임시 토큰 → [CLAUDE.local.md](http://claude.local.md/) / 모노레포 패키지별 규칙 → 서브디렉토리.

### 1-2. 8-layer 컨텍스트 모델

사실 Claude Code는 [CLAUDE.md](http://claude.md/) 만 읽는 게 아닙니다. 총 8개 레이어의 컨텍스트가 매 요청마다 합쳐집니다.

시스템 프롬프트

도구 정의

전역 [CLAUDE.md](http://claude.md/) (

~/.claude/CLAUDE.md

)

프로젝트 [CLAUDE.md](http://claude.md/) (

<repo>/.claude/CLAUDE.md

)

[CLAUDE.local.md](http://claude.local.md/)

서브디렉토리 [CLAUDE.md](http://claude.md/)

대화 히스토리

현재 사용자 메시지

아래로 갈수록 더 구체적이고 더 우선됩니다. • 서브디렉토리 [CLAUDE.md](http://claude.md/) 가 전역과 충돌하면 → 서브디렉토리가 이깁니다 • 사용자의 현재 메시지가 → 가장 강력 그래서 "이 규칙은 어디에 둘까?"는 결국 "얼마나 범용적인가?"의 문제입니다.

바로 확인하는 법: /memory Claude Code 터미널에서

/memory

를 입력하면, 현재 로드된 [CLAUDE.md](http://claude.md/) 4개 위치가 트리로 표시됩니다. "이게 다 매번 같이 전송되고 있구나"를 시각적으로 한 번 확인하고 가시는 걸 추천합니다.

## 2\. 좋은 CLAUDE.md 쓰는 법 (핵심)

### 2-1. 제1원칙 — Non-obvious invariants only

"코드만 봐도 알 수 있는 건 쓰지 마세요." Claude는 코드를 읽을 수 있습니다. [CLAUDE.md](http://claude.md/) 에는 코드만 봐서는 알 수 없는 함정과 규칙만 쓰세요.

| 쓰지 마세요 (코드로 알 수 있음) | 쓰세요 (숨은 규칙) |
| --- | --- |
| "이 프로젝트는 React를 사용합니다" | "Hooks 안에서는 fetch 직접 호출 금지 — useSWR 써야 함" |
| "src/ 폴더에 컴포넌트가 있습니다" | "auth/ 폴더 수정할 땐 반드시 보안팀 리뷰 필요" |
| "TypeScript로 작성됐습니다" | "any 타입은 PR 자동 거절됨" |

다이어트 신호 — 부풀려진 BAD [CLAUDE.md](http://claude.md/) (300줄, 프로젝트 README 복붙)에서 80줄짜리 GOOD으로 줄였더니 토큰 4000 → 800. 줄어든 220줄의 99%는 "코드 보면 알 수 있는 것"이었습니다.

### 2-2. 공식 4가지 원칙

안트로픽이 공식 문서에서 권장하는 작성 원칙입니다.

Specific (구체적으로) — "테스트 잘 짜라" / "Vitest로 짜고 mock 금지"

Structured (구조화된 마크다운) — 헤딩·리스트로 스캔 가능하게.

Reviewed (정기 검토) — 한 달에 한 번 다이어트.

Concise (간결하게) — 100줄 이하 권장.

4가지 중 가장 강조하고 싶은 건 1번 — 구체성입니다. "테스트 잘 짜라" 는 아무 의미가 없습니다. "Vitest로 작성하고, 외부 API는 절대 mock 금지, 실제 테스트 DB 사용" — 이렇게 쓰셔야 합니다. 구체적일수록 강력해집니다.

### 2-3. High-ROI 워크플로우 — 오늘의 핵심

오늘 영상에서 딱 하나만 기억하실 거라면 이겁니다. "Claude가 실수했을 때, 그 자리에서 바로 — '이 실수 다시는 안 하게 [CLAUDE.md](http://claude.md/) 에 반영해줘.'" 실수 한 번이 → 영구적인 규칙이 되는 사이클. 처음부터 완벽하게 쓰려고 하지 마세요. 실수에 반응만 잘 해도 [CLAUDE.md](http://claude.md/) 는 알아서 자랍니다.

4단계 사이클

Claude한테 작업 요청 → 잘못된 방식으로 처리함 (예: "이 함수 테스트 짜줘" → mock으로 짜버림)

사용자가 즉시 지적 → "우리는 mock 안 쓰기로 했잖아. 이거 [CLAUDE.md](http://claude.md/) 에 반영해줘."

Claude가 [CLAUDE.md](http://claude.md/) 에 한 줄 규칙 추가

새 세션에서 같은 요청 → 이번엔 실제 DB로 짬

더 빠른 방법 —

#

단축 메모 채팅창에

#

을 누르고 메모를 입력하면 [CLAUDE.md](http://claude.md/) 에 추가할 후보로 뜹니다. 어디에 추가할지(전역? 프로젝트? 서브디렉토리?)도 골라서 저장 가능. 손이 가장 안 가는 방법.

### 2-4. 빌드·테스트·린트 명령어를 꼭 넣어라

이거 하나만 넣어도 결과 품질이 2~3배 올라갑니다.

\## 명령어 - 빌드: \`npm run build\` - 테스트: \`npm test -- --run\` (watch 모드 금지) - 린트: \`npm run lint:fix\` - 타입체크: \`tsc --noEmit\`

명령어가 명시되어 있지 않으면 Claude는 추측합니다. package.json을 뒤져보고, 잘못된 명령어를 시도하고, 실패하고, 다시 시도하고… 이 시간이 다 비용이고 토큰입니다. 명시되어 있으면 → 바로 정답으로 갑니다.

### 2-5. @import로 분할 관리하기

[CLAUDE.md](http://claude.md/) 가 80~100줄에 가까워지면 분할하고 싶어집니다. 이때 쓰는 게 @import 문법입니다.

\# CLAUDE.md @./docs/coding-style.md @./docs/testing-rules.md

위처럼 적으면 두 파일이 자동으로 합쳐져 로드됩니다. 큰 가이드를 주제별로 쪼개고 싶을 때 유용합니다.

보너스 — [AGENTS.md](http://agents.md/) 트릭 같은 파일을

AGENTS.md

라는 이름으로 저장하면 OpenAI Codex도 같은 파일을 읽습니다. Claude Code랑 Codex 둘 다 쓰시는 분들은 → 한 파일로 두 도구를 동시에 커버할 수 있습니다.

### 2-6. 안티패턴 정리

| 쓰지 마세요 | 대신 이렇게 쓰세요 |
| --- | --- |
| 인간용 README 설명 | 숨겨진 invariants(불변 규칙) |
| 코드로 알 수 있는 폴더 구조 | 우선순위가 충돌할 때의 결정 규칙 |
| 모든 디렉토리 설명 | 자주 발생하는 gotcha와 함정 |
| "코드를 깨끗하게 짜라" 같은 추상적 가이드 | "함수 30줄 넘으면 분리, any 금지" 같은 측정 가능한 규칙 |

핵심 한 줄 [CLAUDE.md](http://claude.md/) 는 사람한테 프로젝트를 소개하는 문서가 아니라, AI한테 가드레일을 치는 도구입니다. → 사람이 읽기 좋게 쓰지 말고, AI가 실수 안 하게 쓰세요.

## 3\. 플러그인 & 스킬로 자동 관리

### 3-1. 전역에 Karpathy 스킬 넣기

안드레이 카파시가 만든 스킬 모음이 깃허브에 공개되어 있습니다.

forrestchang/andrej-karpathy-skills Karpathy가 평소 코딩할 때 쓰는 워크플로우와 컨벤션(코드 리뷰 순서, 디버깅 절차, 변수 네이밍 등)을 스킬 형태로 정리한 모음.

왜 "전역"에 넣는가? 이건 특정 프로젝트 규칙이 아니라 범용 워크플로우입니다. → 프로젝트 [CLAUDE.md](http://claude.md/) 가 아니라 전역

~/.claude/CLAUDE.md

에 등록해, 모든 프로젝트에서 일관되게 적용되도록 하세요.

설치 3단계

깃허브에서 레포 클론

스킬 디렉토리를

~/.claude/skills/

로 옮기기전역

~/.claude/CLAUDE.md

에 한 줄 추가하여 활성화

### 3-2. claude-md-management 플러그인 (메인 도구)

안트로픽이 공식으로 만든 플러그인입니다. 손으로 [CLAUDE.md](http://claude.md/) 를 다이어트할 필요가 없어집니다.

anthropics/claude-plugins-official → claude-md-management 설치하면 두 개의 슬래시 명령어가 추가됩니다.

| 명령어 | 하는 일 |
| --- | --- |
| /revise-claude-md | 기존 [CLAUDE.md](http://claude.md/) 를 분석해서 개선점 제안 ("이 항목은 코드로 알 수 있어요" / "이 규칙은 너무 추상적이에요" / "이건 서브디렉토리로 옮기는 게 좋아요") |
| /claude-md-improver | 분석 결과를 바탕으로 더 좋은 형태로 자동 리팩토링 |

설치 (Claude Code 안에서 한 줄)

/plugin install anthropics/claude-plugins-official:claude-md-management

운용 팁 — 한 달에 한 번 월 1회

/revise-claude-md

→

/claude-md-improver

사이클을 돌리면 [CLAUDE.md](http://claude.md/) 가 비대해지는 걸 자동으로 막을 수 있습니다. → always-on 비용 절감으로 직결됩니다.

### 3-3. 팀에서 관리하는 법 (보너스)

팀 규모가 커지면

@import

로 모듈화하는 걸 권장합니다.

\# CLAUDE.md (팀 메인) @./.claude/coding-style.md @./.claude/api-conventions.md @./.claude/security-rules.md

[CLAUDE.md](http://claude.md/) 변경도 코드리뷰 대상으로 다루세요. 누가 함부로 추가하면 200줄짜리 매뉴얼이 금방 됩니다. → PR로 받고, 새 규칙은 "왜 추가하는지" 코멘트를 의무화하는 걸 추천합니다.

## 4\. 한 페이지 체크리스트

한 달에 한 번, 아래 6가지로 우리 [CLAUDE.md](http://claude.md/) 를 점검하세요. 안 맞는 게 있으면

/revise-claude-md

로 다이어트.

100줄 이하인가?

빌드·테스트·린트 명령어가 명시되어 있는가?

코드만 봐도 알 수 있는 내용은 빠져 있는가?

구체적인 규칙인가? ("잘 짜라" 같은 추상 표현은 없는가)

마지막 업데이트가 최근 한 달 이내인가?

실수가 났을 때 바로바로 반영되고 있는가?

핵심 정리 [CLAUDE.md](http://claude.md/) 는 README가 아닙니다. 사람한테 프로젝트를 소개하는 문서가 아니라, Claude가 같은 실수를 반복하지 않게 만드는 가드레일. 작게 유지하고, 실수가 날 때마다 채워나가는 — 살아있는 문서라고 생각하세요.

이 영상은 Claude Code 완전정복 시리즈의 한 편입니다. 입문 치트시트 → 실전 워크플로우 → 고급 자동화 & 확장 → [CLAUDE.md](http://claude.md/) 마스터 (현재) 같은 시리즈 다른 치트시트도 부모 페이지에서 함께 확인하세요. 결국 "AI가 실수 안 하게 쓰는 한 페이지"가 모든 자동화의 출발점입니다.