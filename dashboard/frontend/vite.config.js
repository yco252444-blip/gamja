import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

const BACKEND = process.env.VITE_BACKEND_URL || "http://localhost:4000";

export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    proxy: {
      "/api": BACKEND,
      "/socket.io": { target: BACKEND, ws: true },
    },
  },
});
