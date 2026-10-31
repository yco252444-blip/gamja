// Relays MQTT-derived device updates to browser dashboards in real time.
const { Server } = require("socket.io");
const deviceRegistry = require("./deviceRegistry");

function attach(httpServer, { corsOrigin = "*" } = {}) {
  const io = new Server(httpServer, { cors: { origin: corsOrigin } });

  io.on("connection", (socket) => {
    socket.emit("devices:snapshot", deviceRegistry.list());
  });

  function broadcastUpdate(kind, device) {
    io.emit("device:update", { kind, device });
  }

  return { io, broadcastUpdate };
}

module.exports = { attach };
