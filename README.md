# aw-dbom

A GitHub Agentic Workflow demo showcasing [Makoto](https://usemakoto.dev) **Data Bills of Materials (DBOMs)** as a security/compliance gate for autonomous data pipelines.

Uses the [asw101/dbom](https://github.com/asw101/dbom) CLI toolkit to generate, validate, and gate data assets — the same commands work locally and in CI.

## What This Demo Shows

An agentic workflow that **discovers**, **fetches**, **attests**, and **gates** data assets:

```
┌───────────────┐   ┌───────────────┐   ┌───────────────┐   ┌───────────────┐
│    Discover   │-->│     Fetch     │-->│ Auto-Generate │-->│     Gate      │
│    assets     │   │   external    │   │     DBOMs     │   │   validate    │
└───────────────┘   └───────────────┘   └───────────────┘   └───────────────┘
  Scan data/ for      Download from       Create origin       4-step Makoto
  CSV, JSON, etc.     URLs in sources     attestations +      verification:
                      .yaml               DBOM for assets     fetch, verify,
                                          missing them        hash, lineage
```

### Two Modes

| Mode | Behavior |
|------|----------|
| `gate` | Validate existing DBOMs only — fail if any asset lacks a valid DBOM |
| `auto-generate` | Discover untracked assets and generate DBOMs before gating |
| `both` (default) | Auto-generate + gate |

## Quick Start (Local)

```bash
# Prerequisites: just, python3
brew install just  # macOS

# Clone
git clone https://github.com/asw101/aw-dbom.git
cd aw-dbom

# Run the full demo
just demo

# Or run in gate-only mode (will fail for assets without DBOMs)
just demo gate

# Show status of all assets
just status

# Show lineage chain for an asset
just lineage dboms/sample-metrics.dbom.json

# Clean up generated artifacts
just demo-clean
```

## Quick Start (GitHub Actions Workflow)

1. Go to **Actions** → **DBOM Gate** → **Run workflow**
2. Select mode: `gate`, `auto-generate`, or `both`
3. The workflow runs the same `just gate` commands as local

## Quick Start (GitHub Agentic Workflow)

The [agentic workflow](.github/workflows/dbom-agentic.md) uses [GitHub Agentic Workflows](https://github.com/github/gh-aw) to run the same pipeline with an AI agent that reasons about results and reports via discussions/issues.

- **Manual**: Actions → **DBOM Agentic Gate** → **Run workflow**
- **Automatic**: Pushes to `data/`, `dboms/`, or `attestations/` trigger it
- **Scheduled**: Runs daily on weekdays

See [docs/agentic-workflow.md](docs/agentic-workflow.md) for details.

## Repository Structure

```
aw-dbom/
├── Justfile                          # Demo entrypoint (wraps dbom CLI)
├── data/
│   ├── local/
│   │   ├── sample-metrics.csv        # Sample sensor data (has DBOM ✓)
│   │   └── config.json               # Pipeline config (no DBOM ✗ — triggers auto-gen)
│   └── external/
│       └── sources.yaml              # URLs to fetch (iris.csv)
├── dboms/
│   └── sample-metrics.dbom.json      # Pre-existing DBOM (gate-pass demo)
├── attestations/
│   └── sample-metrics.origin.json    # Pre-existing origin attestation
├── dbom/                             # Vendored CLI (cloned at runtime)
├── .github/workflows/
│   ├── dbom-agent.yml                # GitHub Actions Workflow
│   └── dbom-agentic.md               # GitHub Agentic Workflow (gh-aw)
├── docs/                             # Documentation
│   ├── local-cli.md
│   ├── actions-workflow.md
│   ├── agentic-workflow.md
│   └── signing-roadmap.md
└── _/
    └── PLAN.md                       # Implementation plan
```

## Example Output

```
═══════════════════════════════════════
 DBOM Gate Pipeline (mode: both)
═══════════════════════════════════════

▸ Step 1: Discovering data assets...
  Found 2 data asset(s)

▸ Step 2: Fetching external datasets...
  ✓ iris.csv (9cc1c345c71b...)

▸ Step 3: Auto-generating missing DBOMs...
  ✓ Attestation: attestations/iris.origin.json
  ✓ DBOM:        dboms/iris.dbom.json
  ✓ Attestation: attestations/config.origin.json
  ✓ DBOM:        dboms/config.dbom.json

▸ Step 4: Validating all DBOMs...
  ✓ config.dbom.json: PASS
  ✓ iris.dbom.json: PASS
  ✓ sample-metrics.dbom.json: PASS

╔══════════════════════════════════════════════════════════╗
║                   DBOM Status Summary                    ║
╠══════════════════════════════════════════════════════════╣
║ Asset                          │ DBOM     │ Level        ║
╠══════════════════════════════════════════════════════════╣
║ config                         │ ✓        │ L1           ║
║ sample-metrics                 │ ✓        │ L1           ║
║ iris                           │ ✓        │ L1           ║
╚══════════════════════════════════════════════════════════╝
```

## Makoto Spec Alignment

This demo targets **Makoto L1** (Provenance Exists):

- Attestations use **in-toto Statement v1** format
- Origin predicate: `makoto.dev/origin/v1`
- Transform predicate: `makoto.dev/transform/v1`
- DBOM is an aggregate document referencing attestations
- Validation follows the 4-step Makoto process

See [docs/signing-roadmap.md](docs/signing-roadmap.md) for the path to L2 (Authentic Provenance) via Sigstore/cosign or GitHub GPG keys.

## Links

- [**Documentation**](docs/) — Local CLI, GitHub Actions Workflow, GitHub Agentic Workflow, signing roadmap
- [usemakoto.dev](https://usemakoto.dev) — Makoto specification
- [asw101/dbom](https://github.com/asw101/dbom) — Reusable CLI toolkit
- [asw101/justfiles](https://github.com/asw101/justfiles) — Justfile pattern
- [github/gh-aw](https://github.com/github/gh-aw) — GitHub Agentic Workflows

## License

MIT