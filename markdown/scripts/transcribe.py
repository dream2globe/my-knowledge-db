#!/usr/bin/env python3
"""
faster-whisper 래퍼 스크립트
모델: large-v3 | 디바이스: CUDA (GTX 3090) | compute_type: float16

사용법:
    python transcribe.py <audio_file> [--output <output_file>] [--model <model_name>]

출력:
    - stdout 또는 지정 파일에 메타데이터 + 전체 transcript 텍스트
"""

import argparse
import sys
import os
from datetime import datetime
from pathlib import Path


def transcribe(
    audio_path: str,
    model_name: str = "large-v3",
    device: str = "cuda",
    compute_type: str = "float16",
    language: str = None,
) -> dict:
    """
    오디오 파일을 텍스트로 변환한다.

    Args:
        audio_path: 오디오 파일 경로
        model_name: faster-whisper 모델 이름 (기본: large-v3)
        device: 연산 장치 (기본: cuda)
        compute_type: 연산 타입 (기본: float16, GTX 3090 최적)
        language: 언어 코드 (None이면 자동 감지, 예: "ko", "en")

    Returns:
        {
            "text": str,           # 전체 transcript
            "language": str,       # 감지된 언어
            "language_prob": float,
            "duration": float,     # 오디오 길이 (초)
            "segments": list,      # 세그먼트별 상세 정보
        }
    """
    from faster_whisper import WhisperModel

    print(f"[transcribe] 모델 로딩: {model_name} ({device}, {compute_type})", file=sys.stderr)
    model = WhisperModel(model_name, device=device, compute_type=compute_type)

    print(f"[transcribe] 변환 시작: {audio_path}", file=sys.stderr)
    segments, info = model.transcribe(
        audio_path,
        language=language,
        beam_size=5,
        vad_filter=True,
        vad_parameters={"min_silence_duration_ms": 500},
    )

    # 세그먼트 수집 (generator 소진)
    segment_list = []
    full_text_parts = []
    for seg in segments:
        segment_list.append({
            "start": round(seg.start, 2),
            "end": round(seg.end, 2),
            "text": seg.text.strip(),
        })
        full_text_parts.append(seg.text.strip())
        # 진행 상황 출력
        print(f"[transcribe] {seg.start:.1f}s → {seg.end:.1f}s : {seg.text.strip()[:60]}", file=sys.stderr)

    return {
        "text": " ".join(full_text_parts),
        "language": info.language,
        "language_prob": round(info.language_probability, 3),
        "duration": round(info.duration, 1),
        "segments": segment_list,
    }


def format_output(result: dict, metadata: dict) -> str:
    """transcript 결과를 메타데이터 포함 텍스트로 포맷한다."""
    lines = []

    # 메타데이터 헤더
    lines.append("# Transcript")
    lines.append("")
    lines.append("## 메타데이터")
    lines.append("")
    if metadata.get("title"):
        lines.append(f"- 제목: {metadata['title']}")
    if metadata.get("channel"):
        lines.append(f"- 채널: {metadata['channel']}")
    if metadata.get("url"):
        lines.append(f"- URL: {metadata['url']}")
    if metadata.get("upload_date"):
        lines.append(f"- 업로드 날짜: {metadata['upload_date']}")
    lines.append(f"- 처리 날짜: {datetime.now().strftime('%Y-%m-%d')}")
    lines.append(f"- 언어: {result['language']} (신뢰도: {result['language_prob']})")
    lines.append(f"- 오디오 길이: {result['duration']}초 ({result['duration']/60:.1f}분)")
    lines.append(f"- 모델: {metadata.get('model', 'large-v3')}")
    lines.append("")

    # 전체 텍스트
    lines.append("## 전체 텍스트")
    lines.append("")
    lines.append(result["text"])
    lines.append("")

    # 타임스탬프별 세그먼트
    lines.append("## 타임스탬프")
    lines.append("")
    for seg in result["segments"]:
        start_fmt = f"{int(seg['start']//60):02d}:{int(seg['start']%60):02d}"
        lines.append(f"[{start_fmt}] {seg['text']}")
    lines.append("")

    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(
        description="faster-whisper로 오디오 파일을 텍스트로 변환합니다."
    )
    parser.add_argument("audio", help="변환할 오디오 파일 경로")
    parser.add_argument(
        "--output", "-o",
        help="출력 파일 경로 (기본: stdout)",
        default=None,
    )
    parser.add_argument(
        "--model", "-m",
        help="사용할 모델 (기본: large-v3)",
        default="large-v3",
    )
    parser.add_argument(
        "--device",
        help="연산 장치 (기본: cuda)",
        default="cuda",
        choices=["cuda", "cpu", "auto"],
    )
    parser.add_argument(
        "--compute-type",
        help="연산 타입 (기본: float16)",
        default="float16",
        choices=["float16", "int8_float16", "int8", "float32"],
    )
    parser.add_argument(
        "--language", "-l",
        help="언어 코드 (기본: 자동감지, 예: ko, en, ja)",
        default=None,
    )
    # 메타데이터 (ingest_youtube.sh에서 전달)
    parser.add_argument("--title", help="영상 제목", default="")
    parser.add_argument("--channel", help="채널명", default="")
    parser.add_argument("--url", help="원본 URL", default="")
    parser.add_argument("--upload-date", help="업로드 날짜 (YYYYMMDD)", default="")

    args = parser.parse_args()

    if not os.path.exists(args.audio):
        print(f"[오류] 파일을 찾을 수 없습니다: {args.audio}", file=sys.stderr)
        sys.exit(1)

    result = transcribe(
        audio_path=args.audio,
        model_name=args.model,
        device=args.device,
        compute_type=args.compute_type,
        language=args.language,
    )

    # 날짜 포맷 변환 (YYYYMMDD → YYYY-MM-DD)
    upload_date = args.upload_date
    if upload_date and len(upload_date) == 8:
        upload_date = f"{upload_date[:4]}-{upload_date[4:6]}-{upload_date[6:]}"

    metadata = {
        "title": args.title,
        "channel": args.channel,
        "url": args.url,
        "upload_date": upload_date,
        "model": args.model,
    }

    output_text = format_output(result, metadata)

    if args.output:
        Path(args.output).parent.mkdir(parents=True, exist_ok=True)
        Path(args.output).write_text(output_text, encoding="utf-8")
        print(f"[transcribe] 저장 완료: {args.output}", file=sys.stderr)
    else:
        print(output_text)


if __name__ == "__main__":
    main()
