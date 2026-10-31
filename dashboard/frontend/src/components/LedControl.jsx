import { useState } from "react";

export default function LedControl({ deviceId }) {
  const [state, setState] = useState("off");
  const [busy, setBusy] = useState(false);

  async function toggle() {
    const next = state === "on" ? "off" : "on";
    setBusy(true);
    try {
      const res = await fetch(`/api/devices/${deviceId}/led`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ state: next }),
      });
      if (res.ok) setState(next);
    } finally {
      setBusy(false);
    }
  }

  return (
    <div className="card">
      <h1>LED 제어</h1>
      <button
        onClick={toggle}
        disabled={busy}
        style={{
          padding: "10px 24px",
          fontSize: 16,
          border: "none",
          borderRadius: 8,
          cursor: busy ? "default" : "pointer",
          background: state === "on" ? "#4cf58b" : "#4c8bf5",
          color: state === "on" ? "#111" : "#fff",
        }}
      >
        LED {state === "on" ? "ON" : "OFF"}
      </button>
    </div>
  );
}
