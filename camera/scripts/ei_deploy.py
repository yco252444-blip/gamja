"""Build and download the Edge Impulse Arduino library, install it into the
arduino-cli sketchbook, and apply the on-device fixes required for the model
to actually boot on the ESP32-S3 (documented in
.claude/skills/xiao-edgeimpulse-train/SKILL.md step 5).

Usage:
    python ei_deploy.py
    python ei_deploy.py --sketchbook-dir "C:\\Users\\me\\Documents\\Arduino"
"""
import argparse
import os
import re
import shutil
import subprocess
import sys
import zipfile

import requests

from ei_common import STUDIO_BASE, get_api_key, get_project_id, poll_job

BUILD_DIR = os.path.join(os.path.dirname(__file__), "..", "build")


def build_ondevice_model(api_key, project_id, engine):
    resp = requests.post(
        f"{STUDIO_BASE}/{project_id}/jobs/build-ondevice-model",
        headers={"x-api-key": api_key},
        params={"type": "arduino"},
        json={"engine": engine},
    )
    resp.raise_for_status()
    job_id = resp.json()["id"]
    print(f"build-ondevice-model job {job_id} started (engine={engine})")
    poll_job(api_key, project_id, job_id, label="build-ondevice-model", timeout=1800)


def download_library(api_key, project_id, dest_zip):
    resp = requests.get(
        f"{STUDIO_BASE}/{project_id}/deployment/download",
        headers={"x-api-key": api_key},
        params={"type": "arduino"},
    )
    resp.raise_for_status()
    os.makedirs(os.path.dirname(dest_zip), exist_ok=True)
    with open(dest_zip, "wb") as f:
        f.write(resp.content)
    print(f"Downloaded library zip: {dest_zip} ({len(resp.content)} bytes)")


def detect_sketchbook_dir(cli_value):
    if cli_value:
        return cli_value
    try:
        out = subprocess.run(
            ["arduino-cli", "config", "get", "directories.user"],
            capture_output=True, text=True, check=True,
        )
        path = out.stdout.strip()
        if path:
            return path
    except Exception:
        pass
    sys.exit(
        "Could not auto-detect the arduino-cli sketchbook (arduino-cli not "
        "found on PATH). Pass --sketchbook-dir explicitly, e.g. "
        "\"C:\\Users\\<you>\\Documents\\Arduino\"."
    )


def install_library(zip_path, sketchbook_dir):
    extract_dir = os.path.join(BUILD_DIR, "extracted")
    if os.path.isdir(extract_dir):
        shutil.rmtree(extract_dir)
    with zipfile.ZipFile(zip_path) as zf:
        zf.extractall(extract_dir)

    # the zip usually nests one folder — flatten so libraries/<name>/src/... exists
    entries = os.listdir(extract_dir)
    if len(entries) == 1 and os.path.isdir(os.path.join(extract_dir, entries[0])):
        source_root = os.path.join(extract_dir, entries[0])
        lib_name = entries[0]
    else:
        source_root = extract_dir
        lib_name = "ei_inferencing"

    libraries_dir = os.path.join(sketchbook_dir, "libraries")
    target = os.path.join(libraries_dir, lib_name)
    if os.path.isdir(target):
        shutil.rmtree(target)
    os.makedirs(libraries_dir, exist_ok=True)
    shutil.copytree(source_root, target)
    print(f"Installed library at: {target}")
    return target


def find_inferencing_header(lib_dir):
    src_dir = os.path.join(lib_dir, "src")
    if not os.path.isdir(src_dir):
        return None
    for fname in os.listdir(src_dir):
        if fname.endswith("_inferencing.h"):
            return fname
    return None


def patch_overflow_buffer(lib_dir):
    """Pitfall: ei_classifier_porting.h hard-defines
    EI_MAX_OVERFLOW_BUFFER_COUNT 30 for ESP32-S3 with no #ifndef guard, so
    build flags and model defaults are ignored, causing a tensor-arena
    overflow crash on boot for vision models. Bump it to 2048."""
    path = os.path.join(
        lib_dir, "src", "edge-impulse-sdk", "porting", "ei_classifier_porting.h"
    )
    if not os.path.isfile(path):
        print(f"WARNING: {path} not found — skipping overflow-buffer patch (check manually).")
        return False

    with open(path, "r", encoding="utf-8") as f:
        content = f.read()

    pattern = r"(#define\s+EI_MAX_OVERFLOW_BUFFER_COUNT\s+)30\b"
    new_content, count = re.subn(pattern, r"\g<1>2048", content)
    if count == 0:
        print(
            "WARNING: EI_MAX_OVERFLOW_BUFFER_COUNT 30 not found in "
            f"{path} — the SDK version may differ; patch manually if vision "
            "inference crashes on boot."
        )
        return False

    with open(path, "w", encoding="utf-8") as f:
        f.write(new_content)
    print(f"Patched EI_MAX_OVERFLOW_BUFFER_COUNT 30 -> 2048 in {path}")
    return True


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--api-key")
    parser.add_argument("--project-id")
    parser.add_argument("--engine", default="tflite-eon")
    parser.add_argument("--sketchbook-dir", help="defaults to `arduino-cli config get directories.user`")
    parser.add_argument("--skip-build", action="store_true", help="reuse the last built deployment instead of rebuilding")
    args = parser.parse_args()

    api_key = get_api_key(args.api_key)
    project_id = get_project_id(api_key, args.project_id)
    print(f"Project id: {project_id}, engine: {args.engine}")

    if not args.skip_build:
        build_ondevice_model(api_key, project_id, args.engine)

    zip_path = os.path.join(BUILD_DIR, f"{project_id}_inferencing.zip")
    download_library(api_key, project_id, zip_path)

    sketchbook_dir = detect_sketchbook_dir(args.sketchbook_dir)
    lib_dir = install_library(zip_path, sketchbook_dir)
    header = find_inferencing_header(lib_dir)
    patch_overflow_buffer(lib_dir)

    print()
    print("Done. Remaining manual steps:")
    if header:
        print(f'  1. In the firmware .ino, set __EI_INFERENCING_HEADER__ to <{header}>')
    else:
        print("  1. Find the *_inferencing.h under the installed library's src/ and use it for __EI_INFERENCING_HEADER__")
    print("  2. Compile with --clean the first time after swapping this library:")
    print("     arduino-cli compile --clean --fqbn esp32:esp32:XIAO_ESP32S3 --board-options PSRAM=opi <sketch_dir>")
    print("  3. PSRAM=opi is mandatory for both compile and upload.")


if __name__ == "__main__":
    main()
