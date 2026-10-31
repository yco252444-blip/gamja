# Oink 펌웨어 뼈대 (dry-run 전용)

히터 핀을 설정하거나 구동하지 않는다. 판정 결과(JSON 한 줄)를 시리얼로 출력할 뿐이다.
`OINK_LIVE_OUTPUT`을 1로 바꾸면 의도적으로 컴파일이 실패한다. LIVE는 하드웨어 안전 3종(퓨즈+서모스탯+열퓨즈)과 사용자 승인 후에 구현한다.

| 파일 | 역할 |
|---|---|
| `oink_controller/control_core.h` | 순수 로직: 센서 검증, 부팅 OFF, 과열 래치, 연속 가열 상한+쿨다운, 히스테리시스 |
| `oink_controller/telemetry.h` | 원격 확인/분석용 JSON 한 줄. 전송 방식과 무관하며 제어 경로가 아님 |
| `oink_controller/config.h` | 핀과 빌드 설정 (배선 확인 전이라 미검증) |
| `oink_controller/oink_controller.ino` | DS18B20 12-bit 비동기 읽기 + 코어 호출 + 로그 |
| `test/test_control_core.cpp` | PC 단위 테스트 (보드 불필요) |

## 검증 (2026-09-21)
- PC 테스트: MSVC로 빌드해 전부 통과. 실행 방법은 아래.
- `arduino-cli compile` 성공. **업로드와 실기 동작은 미검증.**
- 코어의 모든 수치(setpoint, 상한, 쿨다운 등)는 가정이다. 열 시상수 실험(E1) 후 재설정한다.

## 테스트 실행 (Windows, MSVC)
`/utf-8`이 필요하다. 없으면 한글 주석 때문에 컴파일 오류가 난다.
```
cl /nologo /utf-8 /std:c++17 /EHsc /W4 test\test_control_core.cpp
```

## 컴파일 (업로드 아님)
```
arduino-cli compile --fqbn esp32:esp32:XIAO_ESP32S3 oink_controller
```

## 아직 없는 것
워치독(F2), 급변·고착 검사(D4), 텔레메트리 전송, 오프라인 로컬 버퍼링, 기기 벽시계 시각, INA219, MQ-137, 실제 히터 출력.
