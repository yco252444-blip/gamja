// telemetry.h - 원격 확인/분석용 텔레메트리 한 줄(JSON).
// 전송 방식(MQTT/HTTP)과 무관하며 제어 경로가 아니다. 서버가 죽어도 제어는 동작해야 한다.
#pragma once
#include <math.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>

#include "control_core.h"

namespace oink {

constexpr int TELEMETRY_SCHEMA_VERSION = 1;

// 반환: 쓴 길이. 버퍼가 모자라면 0.
// seq는 재전송/누락 판별용, uptime_ms는 기기 기준 시간. 분석에는 기기 시각이 필요하다.
// TODO: 기기 벽시계 시각(ts_ms, NTP)과 run_id/exp/arm 메타데이터 추가 (E1~E5 로깅 스키마).
inline size_t buildTelemetryJson(char* buf, size_t n, uint32_t seq, uint32_t uptimeMs,
                                 const Decision& d, bool dryRun) {
  char temp[16];
  if (d.tempValid && !isnan(d.tempC)) snprintf(temp, sizeof temp, "%.4f", d.tempC);
  else snprintf(temp, sizeof temp, "null");

  const int w = snprintf(
      buf, n,
      "{\"v\":%d,\"seq\":%lu,\"uptime_ms\":%lu,\"temp_c\":%s,\"sensor_ok\":%s,"
      "\"want_on\":%s,\"heater_cmd\":%s,\"dry_run\":%s,\"reasons\":%u}",
      TELEMETRY_SCHEMA_VERSION, (unsigned long)seq, (unsigned long)uptimeMs, temp,
      d.tempValid ? "true" : "false", d.wantOn ? "true" : "false",
      d.heaterOn ? "true" : "false", dryRun ? "true" : "false", (unsigned)d.reasons);
  if (w < 0 || (size_t)w >= n) return 0;
  return (size_t)w;
}

}  // namespace oink
