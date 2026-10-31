# PDF 작성 규칙 (사용자 지시 정리)

## 언제
- 시각화(Artifact·HTML 페이지)를 만들거나 고치면 **매번** 같은 내용을 PDF로 다시 뽑는다.
- 저장 위치: Oink 최상위 폴더 (예: `Oink_패드전원배선_재료표.pdf`). 같은 이름으로 덮어쓴다.

## 모양
- 흰 배경.
- 부분(섹션)마다 **새 페이지**에서 시작.
- 각 부분에 소제목. (예: "번호별 부품 설명", "전원 배선에 필요한 부품")
- 표·카드가 페이지 경계에서 **잘리지 않게** (한 줄이 두 페이지에 걸치면 안 됨, 소제목이 페이지 끝에 혼자 남으면 안 됨).
- 앞 페이지가 절반 이상 비면 다음 부분을 새 페이지로 넘기지 말고 바로 이어 쓴다.
- 빈 공간이 있으면 짧은 메모는 따로 페이지를 쓰지 말고 그 자리에 넣는다. (예: 물 빼는 구멍 메모 → 전원 표 아래)
- 이미지 글자가 깨지면 업스케일하지 말고 **고해상도로 다시 렌더**하고, 라벨은 이미지가 아니라 **PDF 글자**로 올린다.

## 현재 재료표 PDF 순서
1. 배선도 + 범례
2. 번호별 부품 설명
3. 전원 배선에 필요한 부품 (+ 물 빼는 구멍 메모)
4. 3L + 3L 적층 구조 (+ 통에 뚫을 구멍 표는 새 페이지)
5. Oink 전체 재료 (주최측 문의 그룹 포함)

## 만드는 법
1. HTML 앞에 `<!doctype html><html lang="ko"><head><meta charset="utf-8">…` 한 줄을 붙여 `print.html`을 만든다.
2. 인쇄 CSS (`@media print`):
   - `print-color-adjust:exact`
   - `.pb{break-before:page}` — 새 페이지 시작할 요소에 `class="pb"`
   - `tr,td,th,h2,h3,.p{break-inside:avoid}`, `h2,h3{break-after:avoid}`, `thead{display:table-header-group}`
3. Edge headless로 출력:
   ```
   "/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe" --headless=new --disable-gpu --no-pdf-header-footer --virtual-time-budget=8000 --print-to-pdf="<Oink>/<파일명>.pdf" "file:///<경로>/print.html"
   ```
4. 쪽수 확인: PDF에서 `/Type /Page` 개수 (정규식 `/Type\s*/Page[^s]`).

## 기타
- 커밋은 지시 있을 때만.
- 미검증 값은 PDF에도 "미검증"으로 표시.
