// control_core.h - Oink 히터 제어 순수 로직 (Arduino 헤더 없음, PC에서 테스트 가능)
// 아래 기본값은 전부 가정이며 미검증. 열 시상수 실험(E1) 후 재설정한다 (계획서 D5/F5).
#pragma once
#include <math.h>
#include <stdint.h>

namespace oink {

// 히터를 강제로 OFF 하는 이유 (비트마스크). 0이면 정상 제어 중.
enum Reason : uint16_t {
  R_NONE = 0,
  R_BOOT_HOLD = 1 << 0,  // 부팅 직후 강제 OFF 구간
  R_SENSOR = 1 << 1,     // 센서 무효 / 오래됨 / 복귀 대기
  R_OVERTEMP = 1 << 2,   // 과열 래치
  R_COOLDOWN = 1 << 3,   // 최대 연속 가열 후 쿨다운
  R_WDT = 1 << 4,        // 워치독 이상
};

struct Config {
  float setpointC = 37.0f;
  float hysteresisC = 0.5f;
  float maxSafeC = 42.0f;          // 이 이상이면 과열 래치
  float overtempResumeC = 40.0f;   // 래치 해제 온도 (maxSafeC보다 낮게)
  uint32_t bootHoldMs = 10000;
  uint32_t maxSampleAgeMs = 5000;  // 이보다 오래된 샘플은 무효
  uint8_t goodSamplesToResume = 3; // 센서 오류 후 연속 정상 샘플 수
  uint32_t maxHeatMs = 300000;     // 연속 가열 상한
  uint32_t cooldownMs = 60000;
  uint32_t minOnMs = 10000;
  uint32_t minOffMs = 10000;
};

// DS18B20 원값 검증. NaN, -127(연결 끊김), 85.0(변환 전 초기값), 범위 밖은 무효.
// 실제 85.0℃도 무효 처리되지만 maxSafeC보다 훨씬 높아 OFF 쪽이라 안전하다.
inline bool tempValid(float t) {
  if (isnan(t)) return false;
  if (t < -55.0f || t > 125.0f) return false;
  if (t == 85.0f) return false;
  return true;
}

struct Decision {
  bool heaterOn;     // 최종 출력 요구 (dry-run에서는 실제 출력하지 않음)
  bool wantOn;       // 안전 게이트 이전의 히스테리시스 요구
  uint16_t reasons;  // Reason 비트마스크
  bool tempValid;    // 센서가 제어에 쓸 수 있는 상태인지
  float tempC;
};

class Supervisor {
 public:
  explicit Supervisor(const Config& cfg = Config()) : cfg_(cfg) {}

  // 항상 OFF 상태로 시작한다.
  void begin(uint32_t nowMs) {
    t0_ = nowMs;
    lastChangeMs_ = nowMs;
    heaterOn_ = false;
  }

  // 새 온도 샘플이 나올 때마다 호출.
  void onSample(uint32_t nowMs, float raw) {
    if (tempValid(raw)) {
      tempC_ = raw;
      lastValidMs_ = nowMs;
      hasValid_ = true;
      if (good_ < 255) good_++;
    } else {
      good_ = 0;
    }
  }

  // loop마다 호출. nowMs는 millis()이며 uint32 오버플로에 안전하다.
  Decision tick(uint32_t nowMs, bool wdtOk) {
    uint16_t r = R_NONE;

    const bool ageOk = hasValid_ && (uint32_t)(nowMs - lastValidMs_) <= cfg_.maxSampleAgeMs;
    const bool sensorOk = ageOk && good_ >= cfg_.goodSamplesToResume;

    if ((uint32_t)(nowMs - t0_) < cfg_.bootHoldMs) r |= R_BOOT_HOLD;
    if (!wdtOk) r |= R_WDT;
    if (!sensorOk) r |= R_SENSOR;

    if (sensorOk) {
      if (tempC_ >= cfg_.maxSafeC) overtemp_ = true;
      else if (overtemp_ && tempC_ <= cfg_.overtempResumeC) overtemp_ = false;
    }
    if (overtemp_) r |= R_OVERTEMP;

    if (heaterOn_ && (uint32_t)(nowMs - onSinceMs_) >= cfg_.maxHeatMs) {
      coolActive_ = true;
      coolUntilMs_ = nowMs + cfg_.cooldownMs;
    }
    if (coolActive_) {
      if ((int32_t)(nowMs - coolUntilMs_) < 0) r |= R_COOLDOWN;
      else coolActive_ = false;
    }

    bool want = heaterOn_;
    if (sensorOk) {
      if (tempC_ <= cfg_.setpointC - cfg_.hysteresisC) want = true;
      else if (tempC_ >= cfg_.setpointC) want = false;
    }

    bool next;
    if (r != R_NONE) {
      next = false;  // 안전 OFF는 최소 유지시간과 무관하게 즉시
    } else {
      next = heaterOn_;
      if (want != heaterOn_) {
        const uint32_t held = nowMs - lastChangeMs_;
        if (held >= (heaterOn_ ? cfg_.minOnMs : cfg_.minOffMs)) next = want;
      }
    }
    if (next != heaterOn_) {
      heaterOn_ = next;
      lastChangeMs_ = nowMs;
      if (next) onSinceMs_ = nowMs;
    }

    return Decision{heaterOn_, want, r, sensorOk, tempC_};
  }

 private:
  Config cfg_;
  uint32_t t0_ = 0;
  uint32_t lastChangeMs_ = 0;
  uint32_t onSinceMs_ = 0;
  uint32_t lastValidMs_ = 0;
  uint32_t coolUntilMs_ = 0;
  float tempC_ = NAN;
  uint8_t good_ = 0;
  bool hasValid_ = false;
  bool heaterOn_ = false;
  bool overtemp_ = false;
  bool coolActive_ = false;
};

}  // namespace oink

// TODO(D4): 급변률·N회 연속 동일값(고착) 검사는 아직 없다.
