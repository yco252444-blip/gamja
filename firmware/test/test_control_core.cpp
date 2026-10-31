// PC 테스트: control_core.h (보드 불필요)
#include <stdint.h>
#include <stdio.h>
#include <string.h>

#include "../oink_controller/control_core.h"
#include "../oink_controller/telemetry.h"

using namespace oink;

static int failures = 0;
#define CHECK(cond)                                              \
  do {                                                           \
    if (!(cond)) {                                               \
      printf("FAIL line %d: %s\n", __LINE__, #cond);             \
      failures++;                                                \
    }                                                            \
  } while (0)

// 1초 단위로 온도를 넣으며 진행. 마지막 Decision 반환.
struct Sim {
  Supervisor s;
  uint32_t now;
  explicit Sim(uint32_t t0, const Config& c = Config()) : s(c), now(t0) { s.begin(now); }
  Decision step(float temp, bool wdt = true, bool sample = true) {
    now += 1000;
    if (sample) s.onSample(now, temp);
    return s.tick(now, wdt);
  }
};

static void test_boot_hold() {
  Sim sim(0);
  for (int i = 1; i < 10; i++) {  // now = 1000..9000
    Decision d = sim.step(20.0f);
    CHECK(!d.heaterOn);
    CHECK(i >= 10 || (d.reasons & R_BOOT_HOLD));
  }
  Decision d = sim.step(20.0f);   // now = 10000
  CHECK(d.heaterOn);
  CHECK(d.reasons == R_NONE);
}

static void test_invalid_samples() {
  Sim sim(0);
  for (int i = 0; i < 15; i++) {  // 85.0만 들어오면 계속 OFF
    Decision d = sim.step(85.0f);
    CHECK(!d.heaterOn);
    CHECK(d.reasons & R_SENSOR);
  }
  CHECK(!tempValid(-127.0f));
  CHECK(!tempValid(NAN));
  CHECK(!tempValid(200.0f));
  CHECK(tempValid(30.0625f));

  // 정상 3개 뒤에야 복귀
  Decision d = sim.step(30.0f);
  CHECK(!d.heaterOn && (d.reasons & R_SENSOR));
  sim.step(30.0f);
  d = sim.step(30.0f);
  CHECK(d.heaterOn);
}

static void test_stale_sample() {
  Sim sim(0);
  Decision d;
  for (int i = 0; i < 12; i++) d = sim.step(30.0f);
  CHECK(d.heaterOn);
  for (int i = 0; i < 5; i++) d = sim.step(30.0f, true, false);  // 샘플 없음, 5s까지는 허용
  CHECK(d.heaterOn);
  d = sim.step(30.0f, true, false);                               // 6s 경과
  CHECK(!d.heaterOn && (d.reasons & R_SENSOR));
}

static void test_hysteresis_and_min_times() {
  Sim sim(0);
  Decision d;
  for (int i = 0; i < 11; i++) d = sim.step(36.0f);  // now=11000, ON since 10000
  CHECK(d.heaterOn);
  d = sim.step(38.0f);                                // 12000: minOn 미충족 (2s)
  CHECK(d.heaterOn && !d.wantOn);
  for (int i = 0; i < 7; i++) d = sim.step(38.0f);    // 19000: 9s 경과, 아직 ON
  CHECK(d.heaterOn);
  d = sim.step(38.0f);                                // 20000: 10s 경과, OFF
  CHECK(!d.heaterOn);
  for (int i = 0; i < 12; i++) d = sim.step(36.7f);   // 히스테리시스 대역 안: OFF 유지
  CHECK(!d.heaterOn);
  d = sim.step(36.5f);                                // setpoint - hyst: ON
  CHECK(d.heaterOn);
}

static void test_overtemp_latch() {
  Sim sim(0);
  Decision d;
  for (int i = 0; i < 12; i++) d = sim.step(36.0f);
  CHECK(d.heaterOn);
  d = sim.step(43.0f);  // minOn 무시하고 즉시 OFF
  CHECK(!d.heaterOn && (d.reasons & R_OVERTEMP));
  d = sim.step(41.0f);  // 해제 온도(40) 위: 래치 유지
  CHECK(!d.heaterOn && (d.reasons & R_OVERTEMP));
  d = sim.step(40.0f);  // 해제
  CHECK(!(d.reasons & R_OVERTEMP));
}

static void test_max_continuous_heat() {
  Sim sim(0);
  Decision d;
  for (int i = 0; i < 10; i++) d = sim.step(30.0f);  // 10000: ON
  CHECK(d.heaterOn);
  for (int i = 0; i < 299; i++) d = sim.step(30.0f); // 309000
  CHECK(d.heaterOn);
  d = sim.step(30.0f);                                // 310000: 300s 도달 -> OFF
  CHECK(!d.heaterOn && (d.reasons & R_COOLDOWN));
  for (int i = 0; i < 59; i++) {
    d = sim.step(30.0f);
    CHECK(!d.heaterOn);                               // 쿨다운 동안 재점등 불가
  }
  d = sim.step(30.0f);                                // 쿨다운 종료 후 다시 ON
  CHECK(d.heaterOn);
}

static void test_watchdog_fault() {
  Sim sim(0);
  Decision d;
  for (int i = 0; i < 12; i++) d = sim.step(30.0f);
  CHECK(d.heaterOn);
  d = sim.step(30.0f, false);
  CHECK(!d.heaterOn && (d.reasons & R_WDT));
}

static void test_millis_rollover() {
  Sim sim(0xFFFFFFFFu - 5000u);  // 5초 뒤 오버플로
  Decision d;
  bool everOn = false, offAfterOn = false;
  for (int i = 0; i < 400; i++) {  // 오버플로를 지나 연속 가열 상한까지
    d = sim.step(30.0f);
    if (d.heaterOn) everOn = true;
    if (everOn && !d.heaterOn) offAfterOn = true;
  }
  CHECK(everOn);
  CHECK(offAfterOn);  // 상한 후 쿨다운이 오버플로 뒤에도 동작
}

static void test_telemetry_json() {
  char buf[192];
  Decision ok{true, true, R_NONE, true, 30.0f};
  size_t n = buildTelemetryJson(buf, sizeof buf, 7, 12345, ok, true);
  CHECK(n > 0);
  CHECK(strstr(buf, "\"temp_c\":30.0000") != nullptr);
  CHECK(strstr(buf, "\"heater_cmd\":true") != nullptr);
  CHECK(strstr(buf, "\"dry_run\":true") != nullptr);
  CHECK(strstr(buf, "\"seq\":7") != nullptr);

  Decision bad{false, false, R_SENSOR, false, NAN};
  n = buildTelemetryJson(buf, sizeof buf, 8, 13000, bad, true);
  CHECK(n > 0);
  CHECK(strstr(buf, "\"temp_c\":null") != nullptr);
  CHECK(strstr(buf, "\"reasons\":2") != nullptr);

  char tiny[8];
  CHECK(buildTelemetryJson(tiny, sizeof tiny, 1, 1, ok, true) == 0);
}

int main() {
  test_telemetry_json();
  test_boot_hold();
  test_invalid_samples();
  test_stale_sample();
  test_hysteresis_and_min_times();
  test_overtemp_latch();
  test_max_continuous_heat();
  test_watchdog_fault();
  test_millis_rollover();
  printf(failures ? "FAILED: %d\n" : "ALL PASSED\n", failures);
  return failures ? 1 : 0;
}
