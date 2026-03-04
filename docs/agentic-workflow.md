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

- [gh-aw CLI extension](https://github.com/github/gh-aw) installed (for compilation)
- Repository initialized with `gh aw init`

## Links

- [GitHub Agentic Workflows docs](https://github.github.com/gh-aw/)
- [gh-aw repository](https://github.com/github/gh-aw)
- [Safe outputs reference](https://github.github.com/gh-aw/reference/safe-outputs/)
