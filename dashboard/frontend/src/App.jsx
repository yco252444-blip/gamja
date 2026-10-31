import { useEffect, useState } from "react";
import { socket } from "./lib/socket";
import DeviceList from "./components/DeviceList.jsx";
import CameraPanel from "./components/CameraPanel.jsx";
import SensorPanel from "./components/SensorPanel.jsx";
import LedControl from "./components/LedControl.jsx";
import DetectionControl from "./components/DetectionControl.jsx";

export default function App() {
  const [devices, setDevices] = useState({});
  const [selectedId, setSelectedId] = useState(null);

  useEffect(() => {
    fetch("/api/devices")
      .then((r) => r.json())
      .then((list) => {
        const map = Object.fromEntries(list.map((d) => [d.id, d]));
        setDevices(map);
        if (!selectedId && list.length) setSelectedId(list[0].id);
      })
      .catch(() => {});

    function onSnapshot(list) {
      const map = Object.fromEntries(list.map((d) => [d.id, d]));
      setDevices(map);
    }
    function onUpdate({ device }) {
      setDevices((prev) => ({ ...prev, [device.id]: device }));
      setSelectedId((prev) => prev || device.id);
    }

    socket.on("devices:snapshot", onSnapshot);
    socket.on("device:update", onUpdate);
    return () => {
      socket.off("devices:snapshot", onSnapshot);
      socket.off("device:update", onUpdate);
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const selected = selectedId ? devices[selectedId] : null;

  return (
    <>
      <h1>XIAO ESP32S3 대시보드 (STA 모드)</h1>
      <div className="grid">
        <div style={{ display: "flex", flexDirection: "column", gap: 20 }}>
          <DeviceList devices={devices} selectedId={selectedId} onSelect={setSelectedId} />
          {selected && <SensorPanel telemetry={selected.telemetry} />}
          {selected && <LedControl deviceId={selected.id} />}
          {selected && <DetectionControl deviceId={selected.id} />}
        </div>
        <div>{selected && <CameraPanel deviceId={selected.id} detections={selected.detections} />}</div>
      </div>
    </>
  );
}
