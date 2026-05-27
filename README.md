# makoto-workflows

A GitHub Agentic Workflows demo showcasing [Makoto](https://usemakoto.dev) **Data Bills of Materials (DBOMs)** as a security/compliance gate for autonomous data pipelines.

Uses the [makoto-project/makoto-cli](https://github.com/makoto-project/makoto-cli) CLI toolkit to generate, validate, and gate data assets — the same commands work locally and in CI.

## What This Demo Shows

An agentic workflow that **discovers**, **fetches**, **attests**, and **gates** data assets:

```
┌───────────────┐   ┌───────────────┐   ┌───────────────┐   ┌───────────────┐
│    Discover   │-->│     Fetch     │-->│ Auto-Generate │-->│     Gate      │
│    assets     │   │   external    │   │     DBOMs     │   │   validate    │
└───────────────┘   └───────────────┘   └───────────────┘   └───────────────┘
  Scan data/ for      Download from       Self-contained      makoto SDK
  CSV, JSON, etc.     URLs in sources     v0.1 DBOM per       verify: schema,
                      .yaml               asset (Makoto SDK)  data hash, sig
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
git clone https://github.com/makoto-project/makoto-workflows.git
cd makoto-workflows

# Vendor the makoto-cli CLI toolkit
just vendor

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

The [Actions workflow](.github/workflows/dbom-agent.yml) runs the DBOM gate pipeline as a deterministic CI job.

1. Go to **Actions** → **DBOM Gate** → **Run workflow**
2. Select mode: `gate`, `auto-generate`, or `both`
3. The workflow runs the same `just gate` commands as local

See [docs/actions-workflow.md](docs/actions-workflow.md) for details.

## Quick Start (GitHub Agentic Workflows)

The [agentic workflow](.github/workflows/dbom-agentic.md) uses [GitHub Agentic Workflows](https://github.com/github/gh-aw) to run the same pipeline with an AI agent that reasons about results and reports via discussions/issues.

- **Manual**: Actions → **DBOM Agentic Gate** → **Run workflow**
- **Automatic**: Pushes to `data/` or `dboms/` trigger it
- **Scheduled**: Runs daily on weekdays

See [docs/agentic-workflow.md](docs/agentic-workflow.md) for details.

## Repository Structure

```
makoto-workflows/
├── .gitignore                        # Excludes vendored makoto-cli/
├── Justfile                          # Demo entrypoint (wraps makoto-cli CLI)
├── data/
│   ├── local/
│   │   ├── sample-metrics.csv        # Sample sensor data (has DBOM ✓)
│   │   └── config.json               # Pipeline config (no DBOM ✗ — triggers auto-gen)
│   └── external/
│       └── sources.yaml              # URLs to fetch (iris.csv)
├── dboms/
│   └── sample-metrics.dbom.json      # Pre-existing v0.1 DBOM (gate-pass demo)
├── makoto-cli/                       # Vendored CLI (via `just vendor`)
├── .github/workflows/
│   ├── dbom-agent.yml                # GitHub Actions Workflow
│   └── dbom-agentic.md               # GitHub Agentic Workflows (gh-aw)
└── docs/                             # Documentation
    ├── local-cli.md
    ├── actions-workflow.md
    ├── agentic-workflow.md
    └── signing-roadmap.md
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
  ✓ DBOM: dboms/iris.dbom.json   (schema v0.1, signer github:makoto-cli)
  ✓ DBOM: dboms/config.dbom.json (schema v0.1, signer github:makoto-cli)

▸ Step 4: Checking DBOM coverage...
  ✓ All assets have DBOMs

▸ Step 5: Validating all DBOMs...
  ✓ config.dbom.json:         PASS  (schema, hash, signature)
  ✓ iris.dbom.json:           PASS  (schema, hash, signature)
  ✓ sample-metrics.dbom.json: PASS  (schema, hash, signature)

✓ 3/3 DBOM(s) passed validation

╔══════════════════════════════════════════════════════════════════════╗
║                       DBOM Status Summary                            ║
╠══════════════════════════════════════════════════════════════════════╣
║ Asset                        │ DBOM   │ Schema   │ Signer             ║
╠══════════════════════════════════════════════════════════════════════╣
║ iris                         │ ✓      │ v0.1     │ github:makoto-cli  ║
║ config                       │ ✓      │ v0.1     │ github:makoto-cli  ║
║ sample-metrics               │ ✓      │ v0.1     │ github:makoto-proj ║
╚══════════════════════════════════════════════════════════════════════╝
```

## Makoto Spec Alignment

This demo targets **Makoto L1** (Provenance Exists) using the
[Makoto Python SDK](https://github.com/makoto-project/usemakoto.dev/tree/main/sdk/python):

- Each asset has a **self-contained v0.1 DBOM** at `dboms/<name>.dbom.json`
  (no separate attestation files)
- DBOMs follow the SDK's `v0.1` schema: `schema_version`, `id`, `created_at`,
  `source.{uri,hash,format}`, `signature.{algorithm,value,signer}`, `lineage[]`
- Origin is `lineage[0]`; transforms append additional `lineage[]` entries
  with `input_hash`/`output_hash` chaining
- At L1, `signature.value` is a deterministic mock (`sha256(file_hash + signer)`)
- Validation runs through `makoto.verify()`: schema → data hash → signature

See [docs/signing-roadmap.md](docs/signing-roadmap.md) for the path to L2
(Authentic Provenance) via Sigstore/cosign or GitHub GPG keys wrapped around
the v0.1 DBOM.

## Links

- [**Documentation**](docs/) — Local CLI, GitHub Actions Workflow, GitHub Agentic Workflows, signing roadmap
- [usemakoto.dev](https://usemakoto.dev) — Makoto specification
- [makoto-project/makoto-cli](https://github.com/makoto-project/makoto-cli) — Reusable CLI toolkit
- [makoto-project/justfiles](https://github.com/makoto-project/justfiles) — Justfile pattern
- [github/gh-aw](https://github.com/github/gh-aw) — GitHub Agentic Workflows

## License

MIT