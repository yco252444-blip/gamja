# Edge Impulse ML pipeline scripts

Implements the data collection -> training -> deployment pipeline documented
in [`.claude/skills/xiao-edgeimpulse-train/SKILL.md`](../.claude/skills/xiao-edgeimpulse-train/SKILL.md)
as runnable Python scripts, using only the Edge Impulse REST API
(`edge-impulse-cli` is not needed and its `serialport` dependency fails to
build on modern Node/Windows).

## Setup

```powershell
pip install -r requirements.txt
```

Put your Edge Impulse **admin** API key in `camera/.env` (not committed):

```
EI_API_KEY=ei_...
```

The auto-created project key ("Ingestion & deployment" role) can upload data
but cannot create impulses or start training. Get an admin key from Studio ->
Dashboard -> Keys -> Add new API key -> Role **Admin (full access)** (copy it
immediately — it's truncated in the list afterwards).

## Pipeline

1. **Collect data** — flash a camera sketch (`firmware/xiao_dashboard_ap` or
   `xiao_dashboard_sta`, not in this repo — generate from the skill templates) in **collector** mode (see the `xiao-webcam-ap`/
   `xiao-webcam-sta` skill's `web_collect.ino.tpl`), capture labeled photos
   from the board's web UI, download the ZIP, unzip it locally.

2. **Upload**:
   ```powershell
   python scripts/ei_upload_dataset.py --data-dir ./dataset
   ```

3. **Train** (creates the impulse, generates features, trains):
   ```powershell
   python scripts/ei_train.py --type vision
   # or: python scripts/ei_train.py --type audio
   ```

4. **Deploy** (builds + downloads the Arduino library, installs it into the
   arduino-cli sketchbook, and applies the two on-device fixes needed for the
   model to actually boot on the ESP32-S3):
   ```powershell
   python scripts/ei_deploy.py
   ```
   Prints the exact `__EI_INFERENCING_HEADER__` value to put in
   `firmware/xiao_dashboard_ap/xiao_dashboard_ap.ino` and
   `firmware/xiao_dashboard_sta/xiao_dashboard_sta.ino` (not in this repo), plus the mandatory
   `--clean --board-options PSRAM=opi` compile command.

Each script is independent — re-run `ei_train.py` alone to retrain on an
already-uploaded dataset, or `ei_deploy.py --skip-build` to reinstall the
last built library without rebuilding.
