# Orca에서 Antigravity(agy) 무료 에이전트 쓰기 — 설치 안내

Claude Code가 없는 팀원용이다. **Orca**(여러 AI 에이전트를 한 화면에서 돌리는 앱)에서 구글의 **Antigravity CLI(`agy`)** 를 쓸 수 있게 준비한다.

## 먼저 알아둘 것

- **API 키는 필요 없다.** 개인 Gmail 계정으로 로그인만 하면 된다. (API 키 이야기는 아래 "API 키가 필요한가?" 참고)
- Orca는 `agy` 명령을 PATH에서 **자동으로 찾는다.** 그래서 "등록"은 다음 세 가지다: ① `agy` 설치 ② Google 로그인 ③ Orca 재시작.
- 준비물: Windows 10/11, 인터넷, **개인 Gmail 계정**, Chrome 브라우저.

## 방법 A — 더블클릭 (가장 쉬움)

1. Orca가 없으면 https://github.com/stablyai/orca/releases 에서 **Windows(.exe)** 를 받아 설치한다.
2. 이 폴더의 **`install.bat`** 을 더블클릭한다. (파란 "Windows의 PC 보호" 창이 뜨면 **추가 정보 → 실행**)
3. 스크립트가 알아서 한다: Orca 확인 → `agy` 설치(구글 공식 스크립트) → PATH 확인 → 경로를 클립보드에 복사.
4. "지금 로그인 창을 열까요?"에서 **Y** → 새 창이 열린다. (아래 "로그인 절차" 그대로 진행)
5. **Orca를 완전히 종료했다가 다시 실행**한다. (실행 중인 Orca는 새 PATH를 모른다)
6. Orca → 설정(Settings) → **Agents** 에서 **Antigravity**가 보이면 켠다. 새 탭(New Tab)에서 Antigravity를 고르면 끝.

상태만 보고 싶으면(아무것도 설치·변경 안 함): `install.bat check`

### 항상 전체(Global) PATH에 설치한다 — 관리자 권한 창이 뜬다

이 스크립트는 agy 경로를 사용자 PATH가 아니라 **시스템 전체(Machine) PATH**에 등록한다. 그래서 실행하면 **관리자 권한(UAC) 창이 자동으로 뜬다** — 거기서 **예**를 눌러야 계속 진행된다. (사용자 PATH만 쓰던 예전 버전보다 어떤 계정·어떤 방식으로 뜬 Orca든 PATH를 보게 될 확률이 높다.)

**다만 이게 만능은 아니다(미검증):** Orca 쪽 GitHub 이슈 트래커에는 PATH 문제와 무관하게 Antigravity 감지·연동 자체가 버그인 사례들이 보고돼 있다. 전체 PATH로 등록해도 안 되면:
1. Orca를 최신 버전으로 업데이트
2. Settings > Agents의 Antigravity 줄에 `agy.exe` 전체 경로(스크립트가 클립보드에 복사해 둠)를 직접 붙여넣기
3. 그래도 안 되면 Orca 안의 **일반 터미널 탭**에서 `agy`를 그냥 실행 — Antigravity 전용 통합이 안 되더라도 터미널 안에서 도는 에이전트로는 쓸 수 있다.

## 방법 B — 터미널 명령

PowerShell을 열고 이 폴더로 이동한 뒤:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\install-antigravity-agent.ps1
```

스크립트 없이 구글 공식 명령만 직접 실행해도 된다 (같은 결과):

```powershell
irm https://antigravity.google/cli/install.ps1 | iex
agy
```

CMD라면: `curl -fsSL https://antigravity.google/cli/install.cmd -o install.cmd && install.cmd && del install.cmd`

설치 위치는 `C:\Users\<사용자>\AppData\Local\agy\bin\agy.exe` 이다.

## 로그인 절차 (처음 한 번)

1. 터미널에서 `agy` 를 실행한다. (방법 A는 스크립트가 창을 열어준다)
2. 로그인 방법을 묻는다 → **`1. Google OAuth`** 를 고르고 Enter. (**2번 "Use a Google Cloud project"는 고르지 않는다**)
3. 브라우저가 열린다 → **개인 Gmail** 로 로그인한다.
4. 화면에 **인증 코드**가 나오면 복사해서 `agy` 창에 붙여넣고 Enter.
5. **약관 동의**와 **폴더 신뢰(trust)** 질문이 나오면 허용한다.
6. 로그인 정보는 Windows 자격 증명 관리자에 저장되어 다음부터 다시 묻지 않는다. 로그아웃은 `agy` 안에서 `/logout`.

## API 키가 필요한가?

**보통은 필요 없다.** 확인한 내용은 이렇다.

| 방식 | 필요한가 | 근거 |
|---|---|---|
| **Google 로그인(OAuth)** | 이걸 쓴다. API 키 없음 | 공식 설치 문서·Google 코드랩이 이 방식을 안내한다 |
| Gemini API 키(Google AI Studio) | 불필요 | 공식 저장소 이슈(#78)에서 메인테이너가 "Gemini API Key is not supported currently"라고 답하고 닫음. 일부 자료는 `ANTIGRAVITY_API_KEY`/`GEMINI_API_KEY`를 언급하지만 **자료끼리 엇갈려 확인하지 못했다** |
| Google Cloud 프로젝트 | 불필요 | 기업/조직용. 과금 프로젝트가 필요하다 |

즉 "구글 AI에서 API를 받아야 했던 것 같다"는 기억은, 헤드리스·CI·SDK 같은 다른 용도이거나 예전 Gemini CLI 방식일 가능성이 있다. **Orca에서 쓰는 이 절차에서는 필요 없다.** 혹시 로그인 화면에서 API 키를 요구하면 진행하지 말고 화면을 캡처해 팀장에게 보내달라.

## 무료인가?

- Google Antigravity 요금 페이지에 **Individual(Free) $0** 플랜이 있다. 여러 모델 접근, 무제한 탭 완성·명령 요청, 대신 **주간(weekly) 사용량 제한**이 있다.
- **제한이 얼마인지 숫자는 확인하지 못했다.** 공식 요금 페이지는 "FAQ 참고"라고만 하고, CLI(`agy`)에도 같은 한도가 적용되는지는 명시하지 않았다(미확인).
- 유료(Google AI Pro/Ultra)는 한도가 더 높고 5시간마다 갱신된다. **무료로 쓰려면 결제 정보를 넣지 않는다.**
- 정책은 바뀔 수 있다. 사용량이 막히면 그 메시지를 캡처해 공유해 달라.
- 학교·회사(Workspace) 계정은 관리자 설정으로 막힐 수 있다. **개인 Gmail** 을 쓴다. (막히는지는 확인하지 못했다)

## 문제 해결

| 증상 | 해결 |
|---|---|
| Orca의 Agents 목록에 Antigravity가 없거나 회색 | Orca를 **완전히 종료**(트레이 아이콘도) 후 재실행. 그래도 안 되면 Agents의 Antigravity 줄 명령 칸에 `agy.exe` 경로를 붙여넣기 (스크립트가 클립보드에 복사해 둠) |
| 그래도 Orca에서 안 잡힘 | Orca에서 **일반 터미널 탭**을 열고 `agy` 입력. 터미널에서 돌아가는 CLI는 Orca 안에서도 돌아간다 |
| `agy` 를 찾을 수 없다 | 새 PowerShell 창을 연다. 안 되면 `C:\Users\<사용자>\AppData\Local\agy\bin` 이 PATH에 있는지 `install.bat check` 로 확인 |
| "Windows의 PC 보호" 창 | 추가 정보 → 실행 (내려받은 .bat 파일이라 뜨는 정상 경고) |
| "스크립트 실행이 비활성화" 오류 | `install.bat` 으로 실행하면 우회된다. 직접 실행하려면 방법 B의 `-ExecutionPolicy Bypass` 명령을 쓴다 |
| 로그인 창이 바로 닫힘 | 일반 터미널에서 `agy` 를 직접 실행해 오류 문구를 본다 |
| 브라우저 로그인이 안 됨 | Chrome 사용, 개인 Gmail 사용, 사내/학교 계정이면 개인 계정으로 |
| 오류 메시지가 나옴 | 화면을 캡처해서 팀장에게 보낸다 |

## 이 스크립트가 하는 일 (안전 확인용)

- 하는 것: Orca 설치 확인, `https://antigravity.google/cli/install.ps1`(구글 공식)을 받아 실행, `agy` 폴더가 PATH에 없으면 **시스템 전체(Machine) PATH에 추가**(그래서 관리자 권한 창이 뜬다), 경로를 클립보드에 복사, 로그인 창 열기(선택).
- 하지 않는 것: 비밀번호·키 입력 받기, 파일이나 정보를 밖으로 보내기, Orca 설정 파일 수정. (PATH를 전체로 등록하는 것 외에는 시스템을 건드리지 않는다.)
- 로그인은 전부 브라우저에서 구글이 처리한다.
- 지우려면: `%LOCALAPPDATA%\agy` 폴더 삭제 + 시스템 PATH(제어판 > 시스템 > 고급 시스템 설정 > 환경 변수 > Path, Machine 쪽)에서 해당 항목 제거(관리자 권한 필요).

## 검증 상태 (2026-09-22)

- **확인함**: 이 PC의 Orca 1.4.152 본체 코드에 Antigravity가 내장 에이전트로 있고 `agy`를 감지·실행하는 설정(`detectCmd`/`launchCmd`: `agy`)이 들어 있다. 스크립트의 점검 모드(`install.bat check`)가 이 PC에서 정상 동작하고 한글이 정상 표시된다.
- **미검증**: 깨끗한 PC에서 설치부터 로그인까지 전체 흐름을 끝까지 돌려본 적은 없다(이 PC에는 `agy`가 아직 없고, 설치는 실행하지 않았다). Orca의 Settings > Agents 화면 이름과 "경로 직접 입력" 칸은 Orca GitHub 자료 기준이며 화면은 버전에 따라 다를 수 있다. 무료 한도 수치, 학교/회사 계정 제한, API 키 방식은 위에 쓴 대로 확인하지 못했다.

## 관리자(팀장)용

- 배포: 이 `AGENTinstall` 폴더를 통째로 zip으로 묶어 전달한다. 시크릿이나 개인 정보는 들어 있지 않다.
- 처음 한 명이 끝까지 돌려보고, 막히는 지점이 있으면 이 문서의 "문제 해결"에 추가한다.

## 출처

- Antigravity CLI 설치·인증 문서: https://antigravity.google/docs/cli/install
- Antigravity CLI 저장소: https://github.com/google-antigravity/antigravity-cli
- Google 코드랩(Hands-on with Antigravity CLI): https://codelabs.developers.google.com/antigravity-cli-hands-on
- API 키 관련 이슈 #78: https://github.com/google-antigravity/antigravity-cli/issues/78
- Antigravity 요금: https://antigravity.google/pricing
- Orca: https://github.com/stablyai/orca
- Orca 커스텀 에이전트 명령 PR #21653: https://github.com/stablyai/orca/pull/21653
