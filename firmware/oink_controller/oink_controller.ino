// oink_controller.ino - Oink 제어 펌웨어 뼈대 (dry-run 전용)
// 히터 핀은 설정도 구동도 하지 않는다. 판정 결과만 시리얼로 출력한다.
#include <DallasTemperature.h>
#include <OneWire.h>

#include "config.h"
#include "control_core.h"
#include "telemetry.h"

#if OINK_LIVE_OUTPUT
#error "LIVE 출력은 하드웨어 안전 3종(퓨즈+서모스탯+열퓨즈) 확인과 사용자 승인 후에 구현한다."
#endif

OneWire oneWire(DS18B20_PIN);
DallasTemperature ds(&oneWire);
oink::Supervisor sup;
uint32_t convStartMs = 0;
uint32_t lastLogMs = 0;
uint32_t seq = 0;

void setup() {
  Serial.begin(115200);
  delay(3000);  // USB CDC 열거 대기

  ds.begin();
  ds.setResolution(12);
  ds.setWaitForConversion(false);
  ds.requestTemperatures();
  convStartMs = millis();
  sup.begin(millis());

  Serial.println("[oink] dry-run: heater pin not driven");
}

void loop() {
  const uint32_t now = millis();

  if (now - convStartMs >= DS18B20_CONVERT_MS) {
    sup.onSample(now, ds.getTempCByIndex(0));
    ds.requestTemperatures();
    convStartMs = now;
  }

  const oink::Decision d = sup.tick(now, true);  // TODO(F2): 워치독 상태 연결

  if (now - lastLogMs >= LOG_PERIOD_MS) {
    lastLogMs = now;
    char line[192];
    if (oink::buildTelemetryJson(line, sizeof line, seq++, now, d, true)) Serial.println(line);
  }
}

// TODO(F2): esp_task_wdt 워치독
// TODO: 텔레메트리 전송(MQTT 또는 HTTPS)과 오프라인 로컬 버퍼링, INA219, MQ-137
// 원격 확인/분석 경로는 텔레메트리 전용이며 제어에는 관여하지 않는다.
