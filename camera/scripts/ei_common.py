"""Shared helpers for the Edge Impulse REST pipeline scripts.

Implements the flow documented in .claude/skills/xiao-edgeimpulse-train/
SKILL.md using only the REST API (no edge-impulse-cli — its serialport
dependency fails to build on modern Node/Windows).
"""
import os
import sys
import time
import requests

STUDIO_BASE = "https://studio.edgeimpulse.com/v1/api"
INGESTION_BASE = "https://ingestion.edgeimpulse.com/api"

ENV_PATH = os.path.join(os.path.dirname(__file__), "..", ".env")


def _load_dotenv(path=ENV_PATH):
    if not os.path.isfile(path):
        return
    with open(path, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            key, _, value = line.partition("=")
            os.environ.setdefault(key.strip(), value.strip())


def get_api_key(cli_value=None):
    """Admin API key (ei_...). Required for impulse creation and training —
    the auto-created project key ("Ingestion & deployment" role) can upload
    data but returns "insufficient permissions (valid roles: [admin])" for
    everything else. Get one from Studio -> Dashboard -> Keys -> Add new API
    key -> Role Admin (full access)."""
    _load_dotenv()
    key = cli_value or os.environ.get("EI_API_KEY")
    if not key:
        sys.exit(
            "No Edge Impulse API key found. Pass --api-key, set EI_API_KEY, "
            "or put EI_API_KEY=ei_... in camera/.env"
        )
    return key


def get_project_id(api_key, cli_value=None):
    if cli_value:
        return cli_value
    resp = requests.get(f"{STUDIO_BASE}/projects", headers={"x-api-key": api_key})
    resp.raise_for_status()
    projects = resp.json().get("projects", [])
    if not projects:
        sys.exit("No Edge Impulse projects found for this API key.")
    return projects[0]["id"]


def poll_job(api_key, project_id, job_id, interval=12, timeout=1800, label="job"):
    """Poll a job until it finishes; on failure, print its stdout logs
    (newest-first) before raising, matching the skill's documented pattern."""
    headers = {"x-api-key": api_key}
    start = time.time()
    while time.time() - start < timeout:
        resp = requests.get(
            f"{STUDIO_BASE}/{project_id}/jobs/{job_id}/status", headers=headers
        )
        resp.raise_for_status()
        job = resp.json().get("job", {})
        if job.get("finished"):
            if job.get("finishedSuccessful"):
                print(f"[{label}] finished successfully")
                return job
            logs = requests.get(
                f"{STUDIO_BASE}/{project_id}/jobs/{job_id}/stdout", headers=headers
            )
            lines = [l.get("data", "") for l in logs.json().get("stdout", [])]
            print(f"[{label}] FAILED. Last log lines:\n" + "\n".join(lines[:40]))
            sys.exit(f"{label} failed (job {job_id})")
        print(f"[{label}] still running...")
        time.sleep(interval)
    sys.exit(f"{label} timed out after {timeout}s (job {job_id})")


def get_job_stdout(api_key, project_id, job_id):
    resp = requests.get(
        f"{STUDIO_BASE}/{project_id}/jobs/{job_id}/stdout",
        headers={"x-api-key": api_key},
    )
    resp.raise_for_status()
    return [l.get("data", "") for l in resp.json().get("stdout", [])]
