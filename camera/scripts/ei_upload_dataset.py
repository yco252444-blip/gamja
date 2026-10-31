"""Upload a local labeled dataset to Edge Impulse using the edge-impulse-uploader
CLI (part of `edge-impulse-cli`, installed globally via `npm install -g
edge-impulse-cli`).

Expects a folder laid out as:
    data-dir/
      <label_a>/*.jpg (or .png, .wav)
      <label_b>/*.jpg
      ...

This is exactly what the xiao-webcam-ap/sta collector page's ZIP export
produces once unzipped (label.1.jpg, label.2.jpg, ...) — point --data-dir at
the extracted folder.

Usage:
    python ei_upload_dataset.py --data-dir ./dataset
    python ei_upload_dataset.py --data-dir ./dataset --wipe-first

Note: wiping existing raw data has no edge-impulse-cli equivalent, so
--wipe-first still goes through the Studio REST API (project administration,
not data upload).
"""
import argparse
import os
import subprocess
import sys

import requests

from ei_common import STUDIO_BASE, get_api_key, get_project_id

IMAGE_EXTS = {".jpg", ".jpeg", ".png"}
AUDIO_EXTS = {".wav"}

UPLOADER_CMD = "edge-impulse-uploader.cmd" if os.name == "nt" else "edge-impulse-uploader"

# keep each CLI invocation's argv comfortably under Windows' ~8191-char limit
CHUNK_SIZE = 50


def wipe_project(api_key, project_id):
    print("Wiping existing raw data (one project = one model)...")
    resp = requests.post(
        f"{STUDIO_BASE}/{project_id}/raw-data/delete-all",
        headers={"x-api-key": api_key},
    )
    resp.raise_for_status()


def upload_label(api_key, label, paths):
    """Uploads all files for one label via edge-impulse-uploader, in chunks.
    --category split lets the CLI auto-assign train/test per file (no
    separate rebalance step needed)."""
    ok = 0
    for i in range(0, len(paths), CHUNK_SIZE):
        batch = paths[i : i + CHUNK_SIZE]
        cmd = [
            UPLOADER_CMD,
            "--api-key", api_key,
            "--category", "split",
            "--label", label,
            "--silent",
            *batch,
        ]
        result = subprocess.run(cmd, capture_output=True, text=True)
        if result.returncode != 0:
            print(f"  FAILED batch of {len(batch)} file(s): {result.stderr.strip()[:300] or result.stdout.strip()[:300]}")
            continue
        ok += len(batch)
    return ok


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--data-dir", required=True, help="folder with one subfolder per label")
    parser.add_argument("--api-key", help="Edge Impulse admin API key (else EI_API_KEY / camera/.env)")
    parser.add_argument("--project-id", help="defaults to the API key's first project (only used for --wipe-first)")
    parser.add_argument("--wipe-first", action="store_true", help="delete all existing raw data before uploading")
    args = parser.parse_args()

    if not os.path.isdir(args.data_dir):
        sys.exit(f"--data-dir not found: {args.data_dir}")

    api_key = get_api_key(args.api_key)

    if args.wipe_first:
        project_id = get_project_id(api_key, args.project_id)
        print(f"Project id: {project_id}")
        wipe_project(api_key, project_id)

    total, ok = 0, 0
    for label in sorted(os.listdir(args.data_dir)):
        label_dir = os.path.join(args.data_dir, label)
        if not os.path.isdir(label_dir):
            continue
        files = [
            os.path.join(label_dir, f)
            for f in sorted(os.listdir(label_dir))
            if os.path.splitext(f)[1].lower() in IMAGE_EXTS | AUDIO_EXTS
        ]
        print(f"Label '{label}': {len(files)} files")
        total += len(files)
        if files:
            ok += upload_label(api_key, label, files)

    print(f"Uploaded {ok}/{total} files")
    print("Done.")


if __name__ == "__main__":
    main()
