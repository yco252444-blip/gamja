require("dotenv").config();
const http = require("http");
const path = require("path");
const fs = require("fs");
const express = require("express");
const mqttBroker = require("./mqttBroker");
const remoteMirror = require("./remoteMirror");
const socket = require("./socket");
const { createDevicesRouter } = require("./routes/devices");

const HTTP_PORT = process.env.PORT || 4000;
const MQTT_PORT = process.env.MQTT_PORT || 1883;

const app = express();
app.use(express.json());

const httpServer = http.createServer(app);
const { broadcastUpdate } = socket.attach(httpServer);

const { publishLedCommand, publishDetectCommand, publishFrameRateCommand } = mqttBroker.start({
  port: MQTT_PORT,
  onUpdate: (kind, device) => {
    if (device) broadcastUpdate(kind, device);
  },
});

// Optional: mirror a remote-hosted instance's devices (e.g. Railway) so this
// local dashboard shows boards even when their firmware's MQTT client points
// at that remote broker instead of this local one. No-op if unset.
remoteMirror.start({
  remoteBaseUrl: process.env.REMOTE_DASHBOARD_URL,
  onUpdate: (kind, device) => {
    if (device) broadcastUpdate(kind, device);
  },
});

app.get("/api/health", (req, res) => res.json({ ok: true }));
app.use("/api/devices", createDevicesRouter({ publishLedCommand, publishDetectCommand, publishFrameRateCommand }));

// Serve the built React dashboard from the same origin/port as the API, so
// the frontend's relative fetch("/api/...")/io() calls just work with no
// separate frontend host or CORS config (single Railway service deploy).
// No-op locally unless dashboard/frontend/dist exists (run `npm run build`
// in dashboard/frontend first, or just use the Vite dev server instead).
const FRONTEND_DIST = path.join(__dirname, "..", "..", "frontend", "dist");
if (fs.existsSync(FRONTEND_DIST)) {
  app.use(express.static(FRONTEND_DIST));
  app.get(/^(?!\/api\/).*/, (req, res) => res.sendFile(path.join(FRONTEND_DIST, "index.html")));
}

httpServer.listen(HTTP_PORT, () => {
  console.log(`[http] dashboard backend listening on port ${HTTP_PORT}`);
  console.log(`[http] MQTT broker for boards: <this-machine-lan-ip>:${MQTT_PORT}`);
});
