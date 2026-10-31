// In-memory registry of known XIAO boards, keyed by device id (the same id
// used in MQTT topics: xiao/<id>/...). No persistence — this is meant to
// stay basic; the registry rebuilds itself from retained MQTT messages and
// fresh publishes as devices reconnect.
const devices = new Map();
// Latest camera frame per device, kept separate from `devices` so it never
// gets pulled into the JSON responses from list()/get() (a raw JPEG buffer
// in there would bloat every /api/devices poll).
const frames = new Map();

function getOrCreate(deviceId) {
  let device = devices.get(deviceId);
  if (!device) {
    device = { id: deviceId, online: false, ip: null, telemetry: null, detections: null, lastSeen: null };
    devices.set(deviceId, device);
  }
  return device;
}

function updateStatus(deviceId, status) {
  const device = getOrCreate(deviceId);
  device.online = !!status.online;
  if (status.ip) device.ip = status.ip;
  device.lastSeen = Date.now();
  return device;
}

function updateTelemetry(deviceId, telemetry) {
  const device = getOrCreate(deviceId);
  device.telemetry = telemetry;
  device.lastSeen = Date.now();
  return device;
}

function updateDetections(deviceId, detections) {
  const device = getOrCreate(deviceId);
  device.detections = detections;
  device.lastSeen = Date.now();
  return device;
}

function updateFrame(deviceId, buffer) {
  frames.set(deviceId, { buffer, at: Date.now() });
  const device = getOrCreate(deviceId);
  device.lastSeen = Date.now();
  return device;
}

function getFrame(deviceId) {
  return frames.get(deviceId) || null;
}

function list() {
  return Array.from(devices.values());
}

function get(deviceId) {
  return devices.get(deviceId) || null;
}

module.exports = { updateStatus, updateTelemetry, updateDetections, updateFrame, getFrame, list, get };
