// Mirrors device state from a remote-hosted instance of this same dashboard
// (e.g. the Railway deployment) into this LOCAL backend's in-memory
// registry. Lets this local dashboard show/control a board whose firmware
// currently points its MQTT client at the remote broker instead of this
// local one (e.g. firmware/xiao_dashboard_sta_noml, not in this repo -> Railway) - without
// needing the board to also connect to this local MQTT broker.
//
// Crucially, this also seeds device.ip locally from the remote's retained
// status message - so the existing stream.jpg/capture routes' direct-LAN
// fetch keeps working unmodified whenever this machine is on the same LAN
// as the board (the common case: same office WiFi as the board).
const deviceRegistry = require("./deviceRegistry");

function start({ remoteBaseUrl, onUpdate, intervalMs = 3000 } = {}) {
  if (!remoteBaseUrl) return { stop: () => {} };

  let stopped = false;

  async function poll() {
    if (stopped) return;
    try {
      const res = await fetch(`${remoteBaseUrl}/api/devices`, { signal: AbortSignal.timeout(5000) });
      if (res.ok) {
        const remoteDevices = await res.json();
        for (const remote of remoteDevices) {
          const device = deviceRegistry.updateStatus(remote.id, { online: remote.online, ip: remote.ip });
          if (remote.telemetry) deviceRegistry.updateTelemetry(remote.id, remote.telemetry);
          if (remote.detections) deviceRegistry.updateDetections(remote.id, remote.detections);
          if (onUpdate) onUpdate("mirror", device);
        }
      }
    } catch (err) {
      console.error("[remoteMirror] poll failed:", err.message);
    }
    if (!stopped) setTimeout(poll, intervalMs);
  }

  poll();
  return { stop: () => { stopped = true; } };
}

module.exports = { start };
