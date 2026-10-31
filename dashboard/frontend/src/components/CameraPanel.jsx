import { useEffect, useRef, useState } from "react";

const COLORS = { empty: "#888", breadboard: "#4cf58b", charger: "#f5c94c" };
const DEFAULT_COLOR = "#4c8bf5";

// Draws each detection box as a percentage-positioned overlay div.
// Classification model today -> boxes has exactly one full-frame entry
// (x=0,y=0,w=1,h=1). A FOMO model later would send several real boxes and
// this loop already handles that with no change.
export default function CameraPanel({ deviceId, detections }) {
  const [tick, setTick] = useState(0);
  const imgRef = useRef(null);
  const [label, setLabel] = useState("empty");
  const [saveMsg, setSaveMsg] = useState("");
  const [frameBoost, setFrameBoost] = useState(false);

  useEffect(() => {
    const t = setInterval(() => setTick((n) => n + 1), 600);
    return () => clearInterval(t);
  }, []);

  const boxes = detections?.boxes || [];

  async function toggleFrameBoost() {
    const next = !frameBoost;
    try {
      const r = await fetch(`/api/devices/${deviceId}/framerate`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ state: next ? "on" : "off" }),
      });
      if (r.ok) setFrameBoost(next);
    } catch (err) {
      // ignore, button just won't flip
    }
  }

  async function saveToPC() {
    setSaveMsg("저장 중...");
    try {
      const r = await fetch(`/api/devices/${deviceId}/capture`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ label }),
      });
      const d = await r.json();
      setSaveMsg(r.ok ? `저장됨: ${d.path}` : `실패: ${d.error}`);
    } catch (err) {
      setSaveMsg(`실패: ${err}`);
    }
  }

  return (
    <div className="card">
      <h1>웹캠 스트리밍 + Object Detection</h1>
      <div style={{ position: "relative", display: "inline-block" }}>
        <img
          ref={imgRef}
          src={`/api/devices/${deviceId}/stream.jpg?t=${tick}`}
          alt="camera stream"
          style={{ width: 320, height: 320, objectFit: "cover", borderRadius: 8, display: "block", background: "#000" }}
          onError={(e) => {
            e.currentTarget.style.opacity = 0.3;
          }}
          onLoad={(e) => {
            e.currentTarget.style.opacity = 1;
          }}
        />
        {boxes.map((b, i) => {
          const color = COLORS[b.label] || DEFAULT_COLOR;
          return (
            <div
              key={i}
              style={{
                position: "absolute",
                left: `${b.x * 100}%`,
                top: `${b.y * 100}%`,
                width: `${b.w * 100}%`,
                height: `${b.h * 100}%`,
                border: `3px solid ${color}`,
                borderRadius: 4,
                pointerEvents: "none",
              }}
            >
              <span
                style={{
                  position: "absolute",
                  left: 0,
                  top: 0,
                  background: color,
                  color: "#111",
                  fontSize: 12,
                  fontWeight: "bold",
                  padding: "2px 6px",
                  borderRadius: "4px 0 4px 0",
                }}
              >
                {b.label} {(b.confidence * 100).toFixed(0)}%
              </span>
            </div>
          );
        })}
      </div>
      <div style={{ color: "#888", fontSize: 13, marginTop: 8 }}>
        {detections ? `dsp ${detections.dsp_ms}ms + nn ${detections.nn_ms}ms` : "감지 결과 대기 중..."}
      </div>
      <div style={{ marginTop: 8 }}>
        <button
          onClick={toggleFrameBoost}
          style={{
            padding: "6px 14px",
            borderRadius: 6,
            cursor: "pointer",
            background: frameBoost ? "#4cf58b" : "#666",
            color: frameBoost ? "#111" : "#fff",
          }}
        >
          {frameBoost ? "프레임 부스트 중 (5fps)" : "프레임 부스트 (1.5→5fps)"}
        </button>
      </div>
      <div style={{ marginTop: 12, display: "flex", gap: 8, justifyContent: "center", alignItems: "center" }}>
        <input
          value={label}
          onChange={(e) => setLabel(e.target.value)}
          placeholder="라벨 (예: empty)"
          style={{ padding: "6px 10px", borderRadius: 6, border: "1px solid #444" }}
        />
        <button onClick={saveToPC} style={{ padding: "6px 14px", borderRadius: 6, cursor: "pointer" }}>
          현재 프레임 PC에 저장
        </button>
      </div>
      {saveMsg && <div style={{ color: "#888", fontSize: 12, marginTop: 4 }}>{saveMsg}</div>}
    </div>
  );
}
