import { useState } from "react";

// Pauses/resumes the board's own inference loop (STA mode runs it
// continuously on a timer regardless of who's watching the dashboard) — off
// while collecting training photos so it isn't wastefully running detection
// against every frame you take for the next model's dataset.
export default function DetectionControl({ deviceId }) {
  const [state, setState] = useState("on");
  const [busy, setBusy] = useState(false);

  async function toggle() {
    const next = state === "on" ? "off" : "on";
    setBusy(true);
    try {
      const res = await fetch(`/api/devices/${deviceId}/detect`, {
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
      <h1>Object Detection</h1>
      <button
        onClick={toggle}
        disabled={busy}
        style={{
          padding: "10px 24px",
          fontSize: 16,
          border: "none",
          borderRadius: 8,
          cursor: busy ? "default" : "pointer",
          background: state === "on" ? "#4cf58b" : "#666",
          color: state === "on" ? "#111" : "#fff",
        }}
      >
        감지 {state === "on" ? "실행 중" : "중지됨"}
      </button>
    </div>
  );
}
