#!/usr/bin/env bash
# ingest_youtube.sh — YouTube URL → raw transcript 파이프라인
#
# 사용법:
#   ./ingest_youtube.sh <YouTube_URL> [--lang ko]
#
# 동작:
#   1. yt-dlp로 오디오(m4a) 및 메타데이터 추출
#   2. transcribe.py로 faster-whisper 변환 (large-v3, CUDA)
#   3. raw/{제목}.txt 저장
#
# 의존성:
#   - yt-dlp (프로젝트 .venv에 설치됨)
#   - faster-whisper (프로젝트 .venv에 설치됨)
#   - ffmpeg (시스템 설치 필요: sudo apt install ffmpeg)

set -euo pipefail

# ── 경로 설정 ────────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../" && pwd)"
RAW_DIR="$PROJECT_ROOT/markdown/raw"
VENV_PYTHON="$PROJECT_ROOT/.venv/bin/python"
TRANSCRIBE_SCRIPT="$SCRIPT_DIR/transcribe.py"
TMP_DIR="$(mktemp -d /tmp/ingest_youtube_XXXXXX)"

# ── CUDA 라이브러리 경로 설정 ─────────────────────────────────────────────────
# uv/pip으로 설치된 nvidia-cublas-cu12, nvidia-cudnn-cu12 등의 .so 파일은
# site-packages/nvidia/*/lib/ 에 위치하므로 LD_LIBRARY_PATH에 추가한다.
VENV_SITE="$PROJECT_ROOT/.venv/lib/python3.12/site-packages"
NVIDIA_CUDA_LIBS=""
for lib_dir in "$VENV_SITE"/nvidia/*/lib; do
    [[ -d "$lib_dir" ]] && NVIDIA_CUDA_LIBS="$lib_dir:$NVIDIA_CUDA_LIBS"
done
if [[ -n "$NVIDIA_CUDA_LIBS" ]]; then
    export LD_LIBRARY_PATH="${NVIDIA_CUDA_LIBS}${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
fi

# ── 인수 파싱 ────────────────────────────────────────────────────────────────
if [[ $# -lt 1 ]]; then
    echo "사용법: $0 <YouTube_URL> [--lang ko]"
    exit 1
fi

URL="$1"
LANG=""
shift

while [[ $# -gt 0 ]]; do
    case "$1" in
        --lang|-l)
            LANG="$2"
            shift 2
            ;;
        *)
            echo "[오류] 알 수 없는 옵션: $1"
            exit 1
            ;;
    esac
done

# ── 사전 검사 ────────────────────────────────────────────────────────────────
if [[ ! -f "$VENV_PYTHON" ]]; then
    echo "[오류] .venv가 없습니다. 프로젝트 루트에서 'uv venv && uv pip install faster-whisper yt-dlp' 실행 후 다시 시도하세요."
    exit 1
fi

if ! command -v ffmpeg &>/dev/null; then
    echo "[오류] ffmpeg이 설치되지 않았습니다. 'sudo apt install ffmpeg'로 설치하세요."
    exit 1
fi

mkdir -p "$RAW_DIR"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[ingest] URL: $URL"
echo "[ingest] 임시 디렉토리: $TMP_DIR"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ── Step 1: 메타데이터 추출 ──────────────────────────────────────────────────
echo "[ingest] Step 1/3: 메타데이터 추출 중..."

TITLE=$("$PROJECT_ROOT/.venv/bin/yt-dlp" --get-title "$URL" 2>/dev/null || echo "unknown_title")
CHANNEL=$("$PROJECT_ROOT/.venv/bin/yt-dlp" --get-filename -o "%(uploader)s" "$URL" 2>/dev/null || echo "unknown_channel")
UPLOAD_DATE=$("$PROJECT_ROOT/.venv/bin/yt-dlp" --get-filename -o "%(upload_date)s" "$URL" 2>/dev/null || echo "")

echo "[ingest] 제목: $TITLE"
echo "[ingest] 채널: $CHANNEL"
echo "[ingest] 업로드 날짜: $UPLOAD_DATE"

# ── Step 2: 오디오 다운로드 ──────────────────────────────────────────────────
echo "[ingest] Step 2/3: 오디오 다운로드 중..."

AUDIO_PATH="$TMP_DIR/audio.%(ext)s"
"$PROJECT_ROOT/.venv/bin/yt-dlp" \
    --format "bestaudio[ext=m4a]/bestaudio" \
    --output "$AUDIO_PATH" \
    --extract-audio \
    --audio-format m4a \
    --no-playlist \
    --quiet \
    --progress \
    "$URL"

# 다운로드된 파일 탐지
AUDIO_FILE=$(ls "$TMP_DIR"/audio.* 2>/dev/null | head -n1)
if [[ -z "$AUDIO_FILE" ]]; then
    echo "[오류] 오디오 파일 다운로드 실패"
    rm -rf "$TMP_DIR"
    exit 1
fi
echo "[ingest] 오디오 파일: $AUDIO_FILE"

# ── Step 3: Whisper 변환 ─────────────────────────────────────────────────────
echo "[ingest] Step 3/3: faster-whisper 변환 중 (large-v3, CUDA)..."

# 파일명으로 사용할 수 있도록 제목 정리 (특수문자 제거)
SAFE_TITLE=$(echo "$TITLE" | tr -d '/:*?"<>|\\' | sed 's/  */ /g' | cut -c1-100)
OUTPUT_FILE="$RAW_DIR/${SAFE_TITLE}.txt"

LANG_ARG=""
if [[ -n "$LANG" ]]; then
    LANG_ARG="--language $LANG"
fi

"$VENV_PYTHON" "$TRANSCRIBE_SCRIPT" \
    "$AUDIO_FILE" \
    --output "$OUTPUT_FILE" \
    --model large-v3 \
    --device cuda \
    --compute-type float16 \
    --title "$TITLE" \
    --channel "$CHANNEL" \
    --url "$URL" \
    --upload-date "$UPLOAD_DATE" \
    $LANG_ARG

# ── 정리 ─────────────────────────────────────────────────────────────────────
rm -rf "$TMP_DIR"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[ingest] 완료!"
echo "[ingest] 저장 위치: $OUTPUT_FILE"
echo ""
echo "다음 단계: Kilo에게 아래 명령으로 위키 페이지를 생성하세요"
echo "  \"raw/${SAFE_TITLE}.txt 를 ingest해서 위키 페이지를 만들어줘\""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
