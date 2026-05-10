# LLM Wiki — 나만의 지식 DB

> Obsidian + Kilo(AI 에이전트)로 구현하는 개인 지식 베이스입니다.
> YouTube 영상·PDF·웹 클립을 원본 그대로 보관하고, AI가 위키 페이지로 컴파일·유지합니다.

---

## 목적

**"본 것을 잊지 않고, 쌓아서 활용합니다."**

- YouTube에서 시청한 가상자산·주식·AI 영상의 핵심 내용을 위키로 자동 정리합니다.
- 시청 이력이 쌓일수록 지식이 서로 연결되어 더 깊은 질문에 답할 수 있게 됩니다.
- Obsidian 그래프 뷰로 지식 간 연결 구조를 시각적으로 탐색할 수 있습니다.

---

## Karpathy의 LLM Wiki 패턴

이 프로젝트는 Andrej Karpathy가 제안한 **LLM Wiki 패턴** ([원문 링크](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f))을 기반으로 합니다.

**핵심 아이디어**: LLM이 원본 소스를 읽고 위키로 직접 컴파일하여 **영속적이고 복리적인 지식 아티팩트**를 만듭니다.

| 방식 | 특징 |
|---|---|
| 일반 메모 | 사람이 직접 정리 → 유지 비용이 높아 금방 포기 |
| RAG (벡터 검색) | 원본을 실시간 검색 → 맥락 분산, 지식이 쌓이지 않음 |
| **LLM Wiki** | AI가 원본을 읽고 위키로 증류 → 지식이 연결되며 누적됨 |

> *"The wiki is a persistent, compounding artifact. The cross-references are already there. The contradictions have already been flagged. The synthesis already reflects everything you've read."* — Karpathy

**역할 분담:**
- **사람**: 소스 큐레이션, 질문, 방향 제시
- **AI (Kilo)**: 요약, 교차 참조, 위키 페이지 작성·유지 등 모든 정리 작업

---

## 프로젝트 구조

```
test-knowledge-db/
├── markdown/                  ← Obsidian vault 루트
│   ├── raw/                   # 원본 소스 (불변 — 절대 수정하지 않음)
│   │   ├── *.txt              # YouTube transcript (ingest_youtube.sh 생성)
│   │   └── *.pdf              # PDF 논문·자료
│   ├── wiki/                  # Kilo가 생성·관리하는 위키 (플랫 구조)
│   │   ├── index.md           # 전체 목차 (카테고리별 분류, 자동 업데이트)
│   │   ├── log.md             # 작업 이력 (append-only)
│   │   └── *.md               # 위키 페이지들
│   └── scripts/               # 자동화 스크립트
│       ├── ingest_youtube.sh  # YouTube URL → raw transcript 파이프라인
│       └── transcribe.py      # faster-whisper 래퍼 (CUDA, large-v3)
├── .venv/                     # Python 가상환경 (uv 관리)
├── pyproject.toml             # Python 의존성
├── AGENTS.md                  # Kilo 운영 규칙 (ingest/query/lint 절차 정의)
└── README.md
```

> `raw/`와 `wiki/` 모두 하위 폴더 없이 **플랫하게** 관리합니다. 분류는 `index.md`에서 카테고리별로 이루어집니다.

---

## 전체 워크플로우

```
① 소스 준비                ② raw/ 저장              ③ Kilo에게 ingest 요청
─────────────────────────────────────────────────────────────────────────
YouTube URL    ──▶  ingest_youtube.sh  ──▶  "raw/파일명.txt 를 ingest해줘"
PDF 파일       ──▶  raw/에 직접 복사   ──▶         │
웹 클립 (txt)  ──▶  raw/에 직접 저장   ──▶         ▼
                                            wiki/{제목}.md 생성
                                            index.md 업데이트
                                            log.md 기록
                                            [[위키링크]] 연결
```

---

## 초기 설정

### 1. 사전 요구사항

```bash
# ffmpeg 설치 (오디오 변환에 필요)
sudo apt install ffmpeg

# uv 설치 (Python 패키지 매니저)
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### 2. Python 환경 구축

```bash
cd /home/shyeon/workspace/project/test-knowledge-db

uv venv
uv pip install faster-whisper yt-dlp
```

> 이미 `.venv/`가 존재하면 이 단계는 건너뜁니다.

### 3. 기술 스택

| 구성요소 | 역할 |
|---|---|
| [faster-whisper](https://github.com/SYSTRAN/faster-whisper) | 음성 → 텍스트 변환 (Whisper large-v3, CUDA) |
| [yt-dlp](https://github.com/yt-dlp/yt-dlp) | YouTube 오디오 다운로드 |
| [Kilo](https://kilo.ai) | AI 에이전트 — 위키 컴파일·관리 |
| [Obsidian](https://obsidian.md) | 위키 탐색 뷰어 (그래프 뷰, 백링크) |

> **GPU 권장**: GTX 3090 기준 large-v3 모델(~10GB VRAM), 30분 영상 변환에 약 2-3분이 소요됩니다.

---

## 소스 추가하는 법 (raw/ 채우기)

### 방법 A — YouTube 영상 (자동, 권장)

`ingest_youtube.sh`가 yt-dlp 다운로드 → faster-whisper 변환을 한 번에 처리합니다.

```bash
cd /home/shyeon/workspace/project/test-knowledge-db

./markdown/scripts/ingest_youtube.sh "https://youtube.com/watch?v=VIDEO_ID"

# 한국어 영상은 --lang ko 지정 (속도 향상)
./markdown/scripts/ingest_youtube.sh "https://youtube.com/watch?v=VIDEO_ID" --lang ko
```

완료되면 `markdown/raw/{영상 제목}.txt`가 자동 생성됩니다.

**생성되는 파일 형식:**
```
# Transcript

## 메타데이터
- 제목: 영상 제목
- 채널: 채널명
- URL: https://youtube.com/watch?v=...
- 업로드 날짜: YYYY-MM-DD
- 처리 날짜: YYYY-MM-DD
- 언어: ko (신뢰도: 0.998)
- 오디오 길이: 1823.0초 (30.4분)
- 모델: large-v3

## 전체 텍스트
(전체 스크립트)

## 타임스탬프
[00:00] 첫 번째 문장
[00:12] 두 번째 문장
...
```

---

### 방법 B — 이미 다운로드된 오디오 파일

m4a/mp3/wav 파일이 있을 때 `transcribe.py`를 직접 실행합니다.

```bash
.venv/bin/python markdown/scripts/transcribe.py audio.m4a \
    --output markdown/raw/제목.txt \
    --title "영상 제목" \
    --channel "채널명" \
    --url "https://youtube.com/watch?v=..." \
    --language ko
```

**옵션 전체:**

| 옵션 | 기본값 | 설명 |
|---|---|---|
| `--output` | stdout | 저장 경로 |
| `--model` | `large-v3` | Whisper 모델 |
| `--device` | `cuda` | `cuda` / `cpu` / `auto` |
| `--compute-type` | `float16` | GTX 3090 최적값 |
| `--language` | 자동감지 | `ko` / `en` / `ja` 등 |
| `--title` | — | 메타데이터용 제목 |
| `--channel` | — | 메타데이터용 채널명 |
| `--url` | — | 메타데이터용 원본 URL |
| `--upload-date` | — | `YYYYMMDD` 형식 |

---

### 방법 C — PDF 논문

PDF는 그대로 `markdown/raw/`에 복사하시면 됩니다. Kilo가 직접 읽어 처리합니다.

```bash
cp ~/Downloads/paper.pdf markdown/raw/논문_제목.pdf
```

---

### 방법 D — 웹 클립 / 직접 작성

아래 형식으로 `.txt` 파일을 만들어 `markdown/raw/`에 저장합니다.

```
# Transcript

## 메타데이터
- 제목: 페이지 제목
- 채널: 출처명
- URL: https://...
- 업로드 날짜: YYYY-MM-DD
- 처리 날짜: YYYY-MM-DD

## 전체 텍스트
(내용 전문)
```

---

## Kilo 사용법

### 1. 위키 페이지 생성 (ingest)

raw 파일이 준비된 후 Kilo에게 요청합니다.

```
"raw/단타 롱타이밍, 이 패턴 나오면 무조건 진입.txt 를 ingest해서 위키 페이지를 만들어줘"
```

Kilo가 자동으로 아래 작업을 수행합니다.
1. raw 파일 읽기
2. 카테고리 분류 (가상자산 / 주식 / AI·IT / 논문)
3. `wiki/{제목}.md` 위키 페이지 생성
4. `wiki/index.md` 목차 업데이트
5. `wiki/log.md` 작업 이력 기록
6. 기존 페이지와 `[[위키링크]]` 연결

---

### 2. 질문하기 (query)

```
"비트코인에 대해 알고 있는 거 알려줘"
"최근 AI 코딩 트렌드 위키에서 찾아봐"
"불장단타왕이 말한 단타 전략 정리해줘"
```

Kilo가 `index.md`를 참조해 관련 페이지들을 읽고 종합적인 답변을 생성합니다. 유용한 답변은 새 위키 페이지로 저장할 수 있습니다.

---

### 3. 건강검진 (lint)

```
"위키 건강검진 해줘"
```

점검 항목:
- **Orphan 페이지**: `index.md`에 등재되지 않은 파일
- **끊어진 위키링크**: 대상 파일이 없는 `[[링크]]`
- **중복 내용**: 동일 주제 페이지 2개 이상 → 통합 제안
- **모순 내용**: 같은 사실에 대한 상충 기술 탐지
- **최신성**: 90일 이상 업데이트 없는 카테고리 확인

---

## 위키 페이지 형식

모든 위키 페이지는 아래 형식을 따릅니다.

```markdown
> [!info] 카테고리: {카테고리} | 소스: {YouTube/PDF/웹} | 날짜: {YYYY-MM-DD}
> 채널/출처: {채널명 또는 저자} | URL: {URL 또는 "없음"}

## 핵심 요약

{1-2문장. 이 페이지에서 가장 중요한 인사이트가 무엇인지 바로 파악할 수 있게 작성.}

---

## 상세 내용

### {섹션 1 제목}
{내용}

### {섹션 2 제목}
{내용}

---

## 관련 페이지

- [[관련 페이지 1]]
- [[관련 페이지 2]]
```

**작성 원칙:**
- 맨 앞 callout 블록에 카테고리를 반드시 표시합니다.
- 핵심 요약이 먼저, 세부 내용이 그 아래에 위치합니다.
- 숫자·날짜·고유명사는 원문 그대로 보존합니다.
- 기존 위키 페이지와 최소 1개 이상 위키링크로 적극 연결합니다.
- 한국어 소스는 한국어로, 영어 소스는 영어로 작성합니다.

---

## 정리 대상 채널

| 카테고리 | 채널 | URL |
|---|---|---|
| 가상자산 | 불장단타왕 | [링크](https://www.youtube.com/@DantaRang) |
| 가상자산 | 디파이 농부 조선생 | [링크](https://www.youtube.com/@Web3World) |
| 주식 투자 | 한경 글로벌마켓 | [링크](https://www.youtube.com/@hkglobalmarket) |
| 주식 투자 | 월가아재의 과학적 투자 | [링크](https://www.youtube.com/@wsaj) |
| AI·IT | 개발동생 | [링크](https://www.youtube.com/@개발동생) |
| AI·IT | 조코딩 | [링크](https://www.youtube.com/@jocoding) |
| AI·IT | 실밸개발자 | [링크](https://www.youtube.com/@sv.developer) |
| AI·IT | 노정석 (AI Frontier) | [링크](https://aifrontier.kr/ko/episodes/ep96/) |
| AI·IT | BitShua | [링크](https://www.youtube.com/@BitShua) |
| 논문 | PDF 파일 / NotebookLM | — |

---

## Obsidian에서 열기

Obsidian에서 `markdown/` 폴더를 vault로 열면 됩니다.
`[[위키링크]]`, 그래프 뷰, 백링크가 모두 활성화되어 있습니다.

---

## 불변 규칙

1. `raw/` 파일은 절대 수정·삭제하지 않습니다 — 소스의 진실(source of truth).
2. `wiki/log.md`는 append-only입니다 — 기존 로그 항목을 수정하지 않습니다.
3. `wiki/index.md`는 항상 실제 파일 목록과 일치해야 합니다.
4. 위키 페이지 파일명에 타임스탬프나 랜덤 ID를 사용하지 않습니다.
5. 사용자 동의 없이 위키 페이지를 삭제하지 않습니다 (통합 제안만 합니다).
