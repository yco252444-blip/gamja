// Embedded MQTT broker (Aedes) — the "자체 MQTT 서버" the STA-mode firmware
// connects to. No separate Mosquitto process: this runs inside the same
// Node process as the dashboard API, on MQTT_PORT (default 1883).
//
// Topics published by boards (firmware/xiao_dashboard_sta, not in this repo):
//   xiao/<id>/status       retained, LWT   {"online":bool,"ip":"..."}
//   xiao/<id>/telemetry                    {"uptime_ms","free_heap","rssi","sensors":{...}}
//   xiao/<id>/detections                   {"boxes":[...],"dsp_ms","nn_ms"}
//   xiao/<id>/frame                        raw JPEG bytes (not JSON) — sent over MQTT
//                                           instead of the board serving /jpg directly,
//                                           since that requires an inbound HTTP path to
//                                           the board (a private LAN address a cloud-hosted
//                                           backend like Railway can't reach on its own -
//                                           MQTT publish is outbound from the board, so it
//                                           works the same everywhere STA/MQTT already does)
// Topics the backend publishes to (commands):
//   xiao/<id>/cmd/led                      "on" | "off"
//   xiao/<id>/cmd/detect                   "on" | "off" — pause/resume on-device inference
//                                           (the model keeps running otherwise, whether or
//                                           not anyone is viewing the dashboard)
//   xiao/<id>/cmd/framerate                 "on" | "off" — boost the camera frame publish
//                                           rate (~3fps idle -> ~6fps boosted)
const net = require("net");
const Aedes = require("aedes");
const deviceRegistry = require("./deviceRegistry");
const { recordTelemetry, recordDetection, upsertDeviceState } = require("./supabase");

const TOPIC_RE = /^xiao\/([^/]+)\/(status|telemetry|detections|frame)$/;

function start({ port = 1883, onUpdate } = {}) {
  const aedes = new Aedes();
  const server = net.createServer(aedes.handle);

  aedes.on("publish", (packet, client) => {
    if (!client) return; // ignore the broker's own internal publishes
    const match = TOPIC_RE.exec(packet.topic);
    if (!match) return;
    const [, deviceId, kind] = match;

    if (kind === "frame") {
      // Raw JPEG bytes, not JSON - skip parsing, skip Socket.IO broadcast
      // (the frontend polls /api/devices/:id/stream.jpg via <img>, not the
      // websocket), skip Supabase (history tables are for JSON telemetry).
      deviceRegistry.updateFrame(deviceId, packet.payload);
      return;
    }

    let payload;
    try {
      payload = JSON.parse(packet.payload.toString());
    } catch (err) {
      return;
    }

    let device;
    if (kind === "status") {
      device = deviceRegistry.updateStatus(deviceId, payload);
      upsertDeviceState(deviceId, { online: device.online });
    } else if (kind === "telemetry") {
      device = deviceRegistry.updateTelemetry(deviceId, payload);
      recordTelemetry(deviceId, payload);
      upsertDeviceState(deviceId, { online: true, telemetry: payload });
    } else if (kind === "detections") {
      device = deviceRegistry.updateDetections(deviceId, payload);
      recordDetection(deviceId, payload);
      upsertDeviceState(deviceId, { online: true, detections: payload });
    }

    if (onUpdate) onUpdate(kind, device);
  });

  aedes.on("clientDisconnect", (client) => {
    console.log(`[mqtt] client disconnected: ${client.id}`);
  });

  server.listen(port, () => {
    console.log(`[mqtt] Aedes broker listening on port ${port}`);
  });

  function publishLedCommand(deviceId, state) {
    return new Promise((resolve, reject) => {
      aedes.publish(
        {
          cmd: "publish",
          qos: 0,
          topic: `xiao/${deviceId}/cmd/led`,
          payload: Buffer.from(state),
          retain: false,
        },
        (err) => (err ? reject(err) : resolve())
      );
    });
  }

  function publishDetectCommand(deviceId, state) {
    return new Promise((resolve, reject) => {
      aedes.publish(
        {
          cmd: "publish",
          qos: 0,
          topic: `xiao/${deviceId}/cmd/detect`,
          payload: Buffer.from(state),
          retain: false,
        },
        (err) => (err ? reject(err) : resolve())
      );
    });
  }

  function publishFrameRateCommand(deviceId, state) {
    return new Promise((resolve, reject) => {
      aedes.publish(
        {
          cmd: "publish",
          qos: 0,
          topic: `xiao/${deviceId}/cmd/framerate`,
          payload: Buffer.from(state),
          retain: false,
        },
        (err) => (err ? reject(err) : resolve())
      );
    });
  }

  return { aedes, server, publishLedCommand, publishDetectCommand, publishFrameRateCommand };
}

module.exports = { start };
