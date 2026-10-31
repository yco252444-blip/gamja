"""Create the impulse, generate features, and train — audio (keyword
spotting) or vision (image classification) — via the Edge Impulse REST API.

Usage:
    python ei_train.py --type vision
    python ei_train.py --type audio --training-cycles 100 --learning-rate 0.005
"""
import argparse
import sys

import requests

from ei_common import STUDIO_BASE, get_api_key, get_job_stdout, get_project_id, poll_job

AUDIO_IMPULSE = {
    "inputBlocks": [
        {
            "id": 1,
            "type": "time-series",
            "name": "Time series data",
            "title": "Time series data",
            "windowSizeMs": 1000,
            "windowIncreaseMs": 500,
            "frequencyHz": 16000,
            "padZeros": True,
        }
    ],
    # implementationVersion 4 is required — without it MFCC falls back to v1
    # and feature generation fails with "mel filterbank contains all zeros"
    "dspBlocks": [
        {"id": 2, "type": "mfcc", "name": "MFCC", "axes": ["audio"], "title": "MFCC", "implementationVersion": 4}
    ],
    "learnBlocks": [{"id": 3, "type": "keras", "name": "Classifier", "dsp": [2], "title": "Classification"}],
}

VISION_IMPULSE = {
    "inputBlocks": [
        {"id": 1, "type": "image", "name": "Images", "title": "Image data", "imageWidth": 96, "imageHeight": 96, "resizeMode": "squash"}
    ],
    "dspBlocks": [
        {"id": 2, "type": "image", "name": "Image", "axes": ["image"], "title": "Image", "implementationVersion": 1}
    ],
    "learnBlocks": [
        {"id": 3, "type": "keras-transfer-image", "name": "Transfer learning", "dsp": [2], "title": "Transfer learning (Images)"}
    ],
}

DEFAULTS = {
    "audio": {"trainingCycles": 100, "learningRate": 0.005},
    "vision": {"trainingCycles": 20, "learningRate": 0.0005},
}


def create_impulse(api_key, project_id, impulse_type):
    body = AUDIO_IMPULSE if impulse_type == "audio" else VISION_IMPULSE
    resp = requests.post(
        f"{STUDIO_BASE}/{project_id}/impulse", headers={"x-api-key": api_key}, json=body
    )
    if resp.status_code >= 300:
        sys.exit(f"impulse creation failed: {resp.status_code} {resp.text}")
    print("Impulse created.")


def generate_features(api_key, project_id):
    resp = requests.post(
        f"{STUDIO_BASE}/{project_id}/jobs/generate-features",
        headers={"x-api-key": api_key},
        json={"dspId": 2, "calculateFeatureImportance": False},
    )
    resp.raise_for_status()
    job_id = resp.json()["id"]
    print(f"generate-features job {job_id} started")
    poll_job(api_key, project_id, job_id, label="generate-features")


def train(api_key, project_id, impulse_type, training_cycles, learning_rate):
    resp = requests.post(
        f"{STUDIO_BASE}/{project_id}/jobs/train/keras/3",
        headers={"x-api-key": api_key},
        json={"trainingCycles": training_cycles, "learningRate": learning_rate},
    )
    resp.raise_for_status()
    job_id = resp.json()["id"]
    print(f"train job {job_id} started")
    poll_job(api_key, project_id, job_id, label="train", timeout=3600)

    for line in get_job_stdout(api_key, project_id, job_id):
        if "val_accuracy" in line or "accuracy" in line:
            print(line)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--type", choices=["audio", "vision"], required=True)
    parser.add_argument("--api-key")
    parser.add_argument("--project-id")
    parser.add_argument("--training-cycles", type=int)
    parser.add_argument("--learning-rate", type=float)
    parser.add_argument("--skip-impulse-creation", action="store_true", help="use if the impulse already exists")
    args = parser.parse_args()

    api_key = get_api_key(args.api_key)
    project_id = get_project_id(api_key, args.project_id)
    print(f"Project id: {project_id}, type: {args.type}")

    defaults = DEFAULTS[args.type]
    cycles = args.training_cycles or defaults["trainingCycles"]
    lr = args.learning_rate or defaults["learningRate"]

    if not args.skip_impulse_creation:
        create_impulse(api_key, project_id, args.type)

    generate_features(api_key, project_id)
    train(api_key, project_id, args.type, cycles, lr)
    print("Training complete. Next: python ei_deploy.py")


if __name__ == "__main__":
    main()
