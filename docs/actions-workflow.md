# GitHub Actions Workflow

A traditional GitHub Actions workflow that runs the DBOM gate pipeline as a deterministic CI job.

**File**: [`.github/workflows/dbom-agent.yml`](../.github/workflows/dbom-agent.yml)

## Triggers

| Trigger | When |
|---------|------|
| `workflow_dispatch` | Manual — choose mode from the Actions UI |
| `push` on `data/**`, `dboms/**`, `attestations/**` | Automatic — when data files change |

## What It Does

1. Checks out the repo
2. Sets up Python 3.12 and installs `just`
3. Clones the [asw101/dbom](https://github.com/asw101/dbom) toolkit
4. Runs `just gate` with the selected mode
5. Posts the status table to the GitHub Actions step summary

## Modes

| Mode | Behavior |
|------|----------|
| `gate` | Validate existing DBOMs only — fail if any asset lacks a valid DBOM |
| `auto-generate` | Discover untracked assets and generate DBOMs before gating |
| `both` (default) | Auto-generate + gate |

## Running

1. Go to **Actions** → **DBOM Gate** → **Run workflow**
2. Select the mode from the dropdown
3. Click **Run workflow**

Or push a change to any file under `data/`, `dboms/`, or `attestations/` to trigger automatically.

## Differences from Agentic Workflow

This workflow is **deterministic** — it runs the same commands every time and produces the same results. It doesn't reason about failures or create issues. Use it when you want straightforward CI gating.

For AI-assisted analysis and reporting, see [Agentic Workflow](agentic-workflow.md).
