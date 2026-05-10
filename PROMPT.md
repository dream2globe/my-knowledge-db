# 프로젝트 목적
옵시디언을 활용해서 나만의 지식 DB를 구현하세요.
- youtube에서 본 내용을 정리하거나 기억하기 좋게 정리함
- 시청한 youtube의 링크를 추가하면 내용을 확인하고 정리하여 위키 형태로 정리
- 시청한 내용에 대해 질문하면 답변 수행

# (중요) Karpathy의 LLM Wiki 개녕을 도입
- 링크: https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f

# 정리하고 싶은 자료의 주제
- 가상 자산: 불장단타왕(https://www.youtube.com/@DantaRang), 디파이 농부 조선생(https://www.youtube.com/@Web3World), 비트슈아(https://www.youtube.com/@BitShua)
- 주식 투자: 한경 글로벌마켓(https://www.youtube.com/@hkglobalmarket), 월가아재의 과학적 투자(https://www.youtube.com/@wsaj)
- AI Coding/IT: 개발동생(https://www.youtube.com/@%EA%B0%9C%EB%B0%9C%EB%8F%99%EC%83%9D), 조코딩(https://www.youtube.com/@jocoding), 실밸개발자(https://www.youtube.com/@sv.developer), 노정석(https://www.youtube.com/@chester_roh)
- 논문: 개인적으로 수집한 PDF 파일 혹은 notebooklm에 저장된 내용

# 작성할 내용
1. AGENTS.md — 위키 ㅋ관리 규칙 (Schema). 자료 넣기/질문하기/건강검진 3가지 운영 방법 정의
2. raw/ 폴더 — pdf와 같은 원본 자료를 보관하거나, 정리를 요청한 youtube의 링크가 담긴 텍스트 파일
3. wiki/ 폴더 — 정리된 지식 저장  (llm이 정리하고 관리)
4. wiki/index.md — 전체 목차  (자료가 추가될 때마다 업데이트)
5. wiki/log.md — 작업 이력

# 구현방법
raw와 wiki 안에는 하위 폴더 없이 플랫하게 관리하는 대신, 분류는 index.md 에서 카테고리별로 정리를 요청함.
위키 페이지는 마크 다운으로 작성하고, 페이지 간 [[위키링크]]로 교차 참조하도록 구현

# 중요한 규칙
- 모든 위키 페이지의 맨 앞에 > callout 블록으로 "자료의 카테고리"를 먼저 추가해야 함.
- 자료의 내용을 고려했을 때 이 내용에서 핵심이 뭔지를 첫 문단에서 바로 확인할 수 있게하고 그 아래에 구체적 내용이 오도록 정리.
- 항상 페이지를 wiki에 추가할때 교차 참조를 적극적으로 활용.