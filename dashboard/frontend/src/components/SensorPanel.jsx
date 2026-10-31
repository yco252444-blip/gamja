// Basic real-time telemetry readout. Onboard fields (uptime/heap/rssi) plus
// whatever keys the firmware's readSensorsJson() puts under "sensors" —
// extend the firmware and this will pick up new keys automatically. A few
// known keys (temp_c, humidity) get a friendlier label/unit; unknown keys
// still render generically so nothing is silently dropped.
const SENSOR_LABELS = {
  a0: { label: "A0 센서", unit: "" },
  temp_c: { label: "온도", unit: "°C" },
  humidity: { label: "습도", unit: "%" },
  co2_ppm: { label: "CO2", unit: " ppm" },
};

export default function SensorPanel({ telemetry }) {
  const sensors = telemetry?.sensors || {};

  return (
    <div className="card">
      <h1>센서 데이터</h1>
      {!telemetry && <p style={{ color: "#888" }}>텔레메트리 대기 중...</p>}
      {telemetry && (
        <table style={{ width: "100%", fontSize: 14, borderCollapse: "collapse" }}>
          <tbody>
            <Row label="uptime" value={`${(telemetry.uptime_ms / 1000).toFixed(0)}s`} />
            <Row label="free heap" value={`${telemetry.free_heap} bytes`} />
            <Row label="WiFi RSSI" value={`${telemetry.rssi} dBm`} />
            {Object.entries(sensors).map(([key, value]) => {
              const known = SENSOR_LABELS[key];
              const display = value == null ? "-" : `${value}${known?.unit || ""}`;
              return <Row key={key} label={known?.label || key} value={display} />;
            })}
          </tbody>
        </table>
      )}
    </div>
  );
}

function Row({ label, value }) {
  return (
    <tr style={{ borderTop: "1px solid #262a33" }}>
      <td style={{ padding: "6px 0", color: "#aaa" }}>{label}</td>
      <td style={{ padding: "6px 0", textAlign: "right", fontWeight: 600 }}>{value}</td>
    </tr>
  );
}
