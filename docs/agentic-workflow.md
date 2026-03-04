# GitHub Agentic Workflow

An AI-powered workflow using [GitHub Agentic Workflows (gh-aw)](https://github.com/github/gh-aw) that runs the same DBOM pipeline but wraps it with an AI agent for intelligent analysis and reporting.

**File**: [`.github/workflows/dbom-agentic.md`](../.github/workflows/dbom-agentic.md)

## How It Differs from the Actions Workflow

| | Actions Workflow | Agentic Workflow |
|---|---|---|
| **Intelligence** | Deterministic scripts | AI agent with reasoning |
| **Output** | Step summary (text) | Discussions, issues (structured) |
| **Failure handling** | Pass/fail exit code | Root cause analysis + issue creation |
| **Schedule** | Manual or push only | Also runs on a weekday schedule |
| **Adaptability** | Requires code changes | Edit the markdown prompt directly |

## Triggers

| Trigger | When |
|---------|------|
| `workflow_dispatch` | Manual dispatch from Actions UI |
| `push` on `data/**`, `dboms/**`, `attestations/**` | When data files change |
| `schedule` | Daily on weekdays (time scattered by compiler) |

## What the Agent Does

1. **Setup** — Clones the `asw101/dbom` toolkit, installs dependencies
2. **Run pipeline** — Executes `just gate both` (same as local/Actions)
3. **Analyze** — Reads output, identifies failures, missing DBOMs, anomalies
4. **Report** via safe outputs:
   - **All pass** → Creates a discussion with the audit summary
   - **Failures** → Creates an issue per failing asset with details
   - **Nothing to do** → Calls `noop` (no noise)

## Safe Outputs

The agent communicates through [safe outputs](https://github.github.com/gh-aw/reference/safe-outputs/) — structured write operations that run in a separate job with appropriate permissions:

| Output | Purpose |
|--------|---------|
| `create-discussion` | Audit reports (auto-closes older ones) |
| `create-issue` | Validation failures (up to 3 per run) |
| `noop` | Signal completion when no action needed |

## Architecture

```
┌──────────────────────────────────────────────────┐
│  GitHub Agentic Workflows                        │
│                                                  │
│  ┌──────────┐   ┌──────────┐   ┌──────────┐     │
│  │  Setup   │-->│just gate │-->│ Analyze  │     │
│  │ (steps)  │   │  (bash)  │   │ (agent)  │     │
│  └──────────┘   └──────────┘   └─────┬────┘     │
│                                      │          │
│                            ┌─────────┴────────┐ │
│                            │   Safe Outputs   │ │
│                            │  discussion /    │ │
│                            │  issue / noop    │ │
│                            └──────────────────┘ │
└──────────────────────────────────────────────────┘
```

## Editing the Prompt

The agent's instructions live in the **markdown body** of `dbom-agentic.md` (below the YAML frontmatter). You can edit these directly on GitHub.com — changes take effect on the next run without recompilation.

Only changes to the **YAML frontmatter** (triggers, tools, permissions, safe outputs) require recompilation:

```bash
gh aw compile dbom-agentic
```

## Prerequisites

- A **GitHub Copilot** subscription (or Anthropic/OpenAI/Gemini API key)
- **GitHub Actions** enabled on the repository
- **GitHub CLI** (`gh`) v2.0.0+ — [install](https://cli.github.com)
- **gh-aw CLI extension** — `gh extension install github/gh-aw`

## Setup

### 1. Install the gh-aw CLI extension

```bash
gh extension install github/gh-aw
```

### 2. Choose an AI engine and add the secret

The agentic workflow needs an AI engine to run. Pick one and add the corresponding secret:

| Engine | Secret Name | How to Get It |
|--------|-------------|---------------|
| **Copilot** (default) | `COPILOT_GITHUB_TOKEN` | [Create a fine-grained PAT](https://github.com/settings/personal-access-tokens/new?name=COPILOT_GITHUB_TOKEN&description=GitHub+Agentic+Workflows+-+Copilot+engine+authentication&user_copilot_requests=read) with **Copilot Requests → Read** permission |
| Claude | `ANTHROPIC_API_KEY` | [Anthropic console](https://platform.claude.com/docs/en/get-started) |
| Codex | `OPENAI_API_KEY` | [OpenAI platform](https://platform.openai.com/api-keys) |
| Gemini | `GEMINI_API_KEY` | [Google AI Studio](https://aistudio.google.com/api-keys) |

Add the secret via CLI:

```bash
# For Copilot (default engine):
gh aw secrets set COPILOT_GITHUB_TOKEN --value "<your-github-pat>"

# Or via GitHub UI:
# Settings → Secrets and variables → Actions → New repository secret
```

> **Important**: For `COPILOT_GITHUB_TOKEN`, the PAT's **Resource owner** must be your **user account** (not an organization), and the token owner must have an active Copilot license.

### 3. Verify secrets are configured

```bash
gh aw secrets bootstrap
```

### 4. Initialize the repository (already done for aw-dbom)

```bash
gh aw init
```

This creates `.gitattributes`, `.github/agents/`, `copilot-setup-steps.yml`, and VS Code config. This step has already been run for this repository.

### 5. Trigger your first run

```bash
# Manual trigger from the CLI
gh aw run dbom-agentic

# Or from the GitHub UI:
# Actions → DBOM Agentic Gate → Run workflow
```

The workflow will also run automatically on:
- Pushes to `data/**`, `dboms/**`, or `attestations/**`
- A daily weekday schedule

### 6. Check results

After the run completes (2-5 minutes), check:
- **Discussions** tab — for audit summaries (when everything passes)
- **Issues** tab — for validation failures (tagged `dbom`, `automated`)
- **Actions** tab — for run logs and details

### Using a different engine

To switch from the default Copilot engine, add `engine:` to the workflow frontmatter in `dbom-agentic.md` and recompile:

```yaml
engine: claude   # or: codex, gemini
```

```bash
gh aw compile dbom-agentic
```

## Links

- [GitHub Agentic Workflows docs](https://github.github.com/gh-aw/)
- [gh-aw repository](https://github.com/github/gh-aw)
- [Authentication reference](https://github.github.com/gh-aw/reference/auth/)
- [Safe outputs reference](https://github.github.com/gh-aw/reference/safe-outputs/)
- [AI engines reference](https://github.github.com/gh-aw/reference/engines/)
