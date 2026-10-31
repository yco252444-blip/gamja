export default function DeviceList({ devices, selectedId, onSelect }) {
  const ids = Object.keys(devices);
  return (
    <div className="card">
      <h1>기기 목록</h1>
      {ids.length === 0 && <p style={{ color: "#888" }}>연결된 보드 없음 (STA 모드 펌웨어가 MQTT로 접속하면 여기 표시됩니다)</p>}
      <ul style={{ listStyle: "none", padding: 0, margin: 0 }}>
        {ids.map((id) => {
          const d = devices[id];
          return (
            <li
              key={id}
              onClick={() => onSelect(id)}
              style={{
                padding: "10px 12px",
                borderRadius: 8,
                cursor: "pointer",
                marginBottom: 6,
                background: id === selectedId ? "#262a33" : "transparent",
                display: "flex",
                justifyContent: "space-between",
                alignItems: "center",
              }}
            >
              <span>{id}</span>
              <span style={{ color: d.online ? "#4cf58b" : "#888", fontSize: 12 }}>
                {d.online ? "● online" : "○ offline"}
              </span>
            </li>
          );
        })}
      </ul>
    </div>
  );
}
