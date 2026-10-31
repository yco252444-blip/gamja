// Optional persistent history for telemetry/detections (Supabase Postgres).
// The in-memory device registry only keeps the latest value per device;
// this fire-and-forget layer additionally appends every event to
// telemetry_events / detection_events so history survives backend restarts.
// Inactive (no-op) if SUPABASE_URL / SUPABASE_SERVICE_ROLE_KEY are unset.
const { createClient } = require("@supabase/supabase-js");

const url = process.env.SUPABASE_URL;
const key = process.env.SUPABASE_SERVICE_ROLE_KEY;

const client = url && key ? createClient(url, key) : null;

if (!client) {
  console.warn("[supabase] SUPABASE_URL/SUPABASE_SERVICE_ROLE_KEY not set — history persistence disabled");
}

function recordTelemetry(deviceId, payload) {
  if (!client) return;
  client
    .from("telemetry_events")
    .insert({ device_id: deviceId, payload })
    .then(({ error }) => {
      if (error) console.error("[supabase] telemetry insert failed:", error.message);
    });
}

function recordDetection(deviceId, payload) {
  if (!client) return;
  client
    .from("detection_events")
    .insert({ device_id: deviceId, payload })
    .then(({ error }) => {
      if (error) console.error("[supabase] detection insert failed:", error.message);
    });
}

// Upserts the single "latest state" row the remote viewer (AI_makerton_deploy,
// Vercel) subscribes to via Realtime — keeps arbitrary fields, only touching
// what's passed in `patch` (online/telemetry/detections/led_state).
function upsertDeviceState(deviceId, patch) {
  if (!client) return;
  client
    .from("device_state")
    .upsert(
      { device_id: deviceId, ...patch, updated_at: new Date().toISOString() },
      { onConflict: "device_id" }
    )
    .then(({ error }) => {
      if (error) console.error("[supabase] device_state upsert failed:", error.message);
    });
}

const HISTORY_TABLE = { telemetry: "telemetry_events", detections: "detection_events" };

async function queryHistory(kind, deviceId, limit) {
  if (!client) throw new Error("Supabase not configured (SUPABASE_URL/SUPABASE_SERVICE_ROLE_KEY unset)");
  const { data, error } = await client
    .from(HISTORY_TABLE[kind])
    .select("payload, created_at")
    .eq("device_id", deviceId)
    .order("created_at", { ascending: false })
    .limit(limit);
  if (error) throw new Error(error.message);
  return data;
}

module.exports = { recordTelemetry, recordDetection, upsertDeviceState, queryHistory };
