const fs = require("fs");
const path = require("path");
const express = require("express");
const deviceRegistry = require("../deviceRegistry");
const { queryHistory, upsertDeviceState } = require("../supabase");

// dashboard/backend/src/routes -> AI_makerton_base/camera/dataset
const DATASET_DIR = path.join(__dirname, "..", "..", "..", "..", "camera", "dataset");
const LABEL_RE = /^[a-zA-Z0-9_-]{1,40}$/;

function createDevicesRouter({ publishLedCommand, publishDetectCommand, publishFrameRateCommand }) {
  const router = express.Router();

  router.get("/", (req, res) => {
    res.json(deviceRegistry.list());
  });

  // Persisted history (Supabase) — separate from the in-memory "latest value"
  // endpoints below. 404s with a clear message if Supabase isn't configured.
  router.get("/:id/history/:kind(telemetry|detections)", async (req, res) => {
    const limit = Math.min(parseInt(req.query.limit, 10) || 100, 1000);
    try {
      const rows = await queryHistory(req.params.kind, req.params.id, limit);
      res.json(rows);
    } catch (err) {
      res.status(503).json({ error: String(err) });
    }
  });

  router.get("/:id", (req, res) => {
    const device = deviceRegistry.get(req.params.id);
    if (!device) return res.status(404).json({ error: "unknown device" });
    res.json(device);
  });

  router.post("/:id/led", async (req, res) => {
    const { state } = req.body || {};
    if (state !== "on" && state !== "off") {
      return res.status(400).json({ error: 'body must be {"state":"on"|"off"}' });
    }
    try {
      await publishLedCommand(req.params.id, state);
      upsertDeviceState(req.params.id, { led_state: state });
      res.json({ ok: true, state });
    } catch (err) {
      res.status(500).json({ error: String(err) });
    }
  });

  // Pauses/resumes the board's own inference loop (STA mode runs it
  // continuously on a timer regardless of who's watching — this stops that,
  // e.g. while collecting training photos so /detections isn't just noise).
  router.post("/:id/detect", async (req, res) => {
    const { state } = req.body || {};
    if (state !== "on" && state !== "off") {
      return res.status(400).json({ error: 'body must be {"state":"on"|"off"}' });
    }
    try {
      await publishDetectCommand(req.params.id, state);
      res.json({ ok: true, state });
    } catch (err) {
      res.status(500).json({ error: String(err) });
    }
  });

  // Boosts the camera's MQTT publish rate (~3fps idle -> ~6fps boosted),
  // e.g. while actively taking training photos and wanting a smoother preview.
  router.post("/:id/framerate", async (req, res) => {
    const { state } = req.body || {};
    if (state !== "on" && state !== "off") {
      return res.status(400).json({ error: 'body must be {"state":"on"|"off"}' });
    }
    try {
      await publishFrameRateCommand(req.params.id, state);
      res.json({ ok: true, state });
    } catch (err) {
      res.status(500).json({ error: String(err) });
    }
  });

  // Camera: prefer the frame the board already pushed over MQTT (xiao/<id>/frame) -
  // no extra HTTP round-trip to the board needed. Falls back to pulling the
  // board's own /jpg over the LAN (device.ip, from its last retained MQTT
  // status message) if no frame has arrived over MQTT yet.
  router.get("/:id/stream.jpg", async (req, res) => {
    const frame = deviceRegistry.getFrame(req.params.id);
    if (frame) {
      res.set("Content-Type", "image/jpeg");
      res.set("Cache-Control", "no-store");
      return res.send(frame.buffer);
    }

    const device = deviceRegistry.get(req.params.id);
    if (!device || !device.ip) {
      return res.status(404).json({ error: "no frame received yet (MQTT or HTTP)" });
    }
    try {
      const upstream = await fetch(`http://${device.ip}/jpg`, {
        signal: AbortSignal.timeout(5000),
      });
      if (!upstream.ok) {
        return res.status(502).json({ error: `board returned ${upstream.status}` });
      }
      const buf = Buffer.from(await upstream.arrayBuffer());
      res.set("Content-Type", upstream.headers.get("content-type") || "image/jpeg");
      res.set("Cache-Control", "no-store");
      res.send(buf);
    } catch (err) {
      res.status(504).json({ error: `board unreachable: ${err}` });
    }
  });

  // Local export: grabs the board's current frame - same source priority as
  // stream.jpg (MQTT frame first, HTTP-by-IP fallback), so this works
  // whether the board only reaches this backend over MQTT (e.g. via
  // Railway, or any network with internet) or is on the same LAN - and
  // writes it straight to this machine's disk under camera/dataset/<label>/,
  // ready for ei_upload_dataset.py to pick up.
  router.post("/:id/capture", async (req, res) => {
    const { label } = req.body || {};
    if (typeof label !== "string" || !LABEL_RE.test(label)) {
      return res.status(400).json({ error: "label must match ^[a-zA-Z0-9_-]{1,40}$" });
    }

    let buf;
    const frame = deviceRegistry.getFrame(req.params.id);
    if (frame) {
      buf = frame.buffer;
    } else {
      const device = deviceRegistry.get(req.params.id);
      if (!device || !device.ip) {
        return res.status(404).json({ error: "no frame received yet (MQTT or HTTP)" });
      }
      try {
        const upstream = await fetch(`http://${device.ip}/jpg`, {
          signal: AbortSignal.timeout(5000),
        });
        if (!upstream.ok) {
          return res.status(502).json({ error: `board returned ${upstream.status}` });
        }
        buf = Buffer.from(await upstream.arrayBuffer());
      } catch (err) {
        return res.status(504).json({ error: `capture failed: ${err}` });
      }
    }

    const labelDir = path.join(DATASET_DIR, label);
    fs.mkdirSync(labelDir, { recursive: true });
    const filename = `${label}_${Date.now()}_${Math.random().toString(36).slice(2, 8)}.jpg`;
    fs.writeFileSync(path.join(labelDir, filename), buf);
    res.json({ ok: true, path: path.join("camera", "dataset", label, filename) });
  });

  return router;
}

module.exports = { createDevicesRouter };
