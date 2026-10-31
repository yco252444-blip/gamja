// config.h - Oink 핀·빌드 설정. 배선 확인 전이라 모든 핀은 미검증.
#pragma once

// 0: dry-run (판정만 계산, 히터 핀을 건드리지 않음). 1은 아직 구현하지 않는다.
#define OINK_LIVE_OUTPUT 0

// DS18B20 OneWire: MK1 코드 기준 D2/GPIO3. GPIO3이 스트래핑 핀인지는 데이터시트 미확인.
constexpr uint8_t DS18B20_PIN = D2;

// 12-bit 변환은 최대 750ms. 여유를 두고 800ms 후 읽는다.
constexpr uint32_t DS18B20_CONVERT_MS = 800;

constexpr uint32_t LOG_PERIOD_MS = 1000;
