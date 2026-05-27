# Local CLI Usage

Run the DBOM pipeline locally using [just](https://github.com/casey/just) and the [makoto-project/makoto-cli](https://github.com/makoto-project/makoto-cli) CLI toolkit.

## Prerequisites

- [just](https://github.com/casey/just) — `brew install just` (macOS) or `cargo install just`
- Python 3.10+
- `pip` — used to install the [Makoto Python SDK](https://github.com/makoto-project/usemakoto.dev/tree/main/sdk/python)
- `pyyaml` — `pip install pyyaml` (only needed for external fetch)

## Setup

```bash
git clone https://github.com/makoto-project/makoto-workflows.git
cd makoto-workflows

# Vendor the makoto-cli CLI toolkit (clones into makoto-cli/ and runs
# `pip install -r requirements.txt`, which pulls in the Makoto SDK).
just vendor
```

The `vendor` recipe clones [makoto-project/makoto-cli](https://github.com/makoto-project/makoto-cli) into `makoto-cli/` (gitignored) and installs its Python dependencies (including the [`makoto` SDK](https://github.com/makoto-project/usemakoto.dev/tree/main/sdk/python)). Run it again to pull the latest version.

## Recipes

```bash
just vendor            # Clone or update the makoto-cli CLI toolkit
just demo              # Run the full pipeline (auto-generate + gate)
just demo gate         # Gate-only mode (validate existing DBOMs)
just status            # Show status table of all assets
just lineage FILE      # Show lineage chain for a DBOM
just demo-clean        # Remove generated artifacts
```

## Example

```bash
$ just demo
═══════════════════════════════════════
 DBOM Gate Pipeline (mode: both)
═══════════════════════════════════════

▸ Step 1: Discovering data assets...
  Found 2 data asset(s)

▸ Step 2: Fetching external datasets...
  ✓ iris.csv (9cc1c345c71b...)

▸ Step 3: Auto-generating missing DBOMs...
  ✓ DBOM: dboms/config.dbom.json   (schema v0.1, signer github:makoto-cli)
  ✓ DBOM: dboms/iris.dbom.json     (schema v0.1, signer github:makoto-cli)

▸ Step 4: Validating all DBOMs...
  ✓ config.dbom.json:         PASS  (schema, hash, signature)
  ✓ iris.dbom.json:           PASS  (schema, hash, signature)
  ✓ sample-metrics.dbom.json: PASS  (schema, hash, signature)
```

## Alias Pattern

Clone the toolkit once and use it from anywhere:

```bash
git clone https://github.com/makoto-project/makoto-cli.git ~/makoto-cli
alias makoto-cli='just --justfile ~/makoto-cli/Justfile'

# Then from any project directory:
makoto-cli generate mydata.csv
makoto-cli validate-all
makoto-cli gate
```

See the [makoto-project/justfiles](https://github.com/makoto-project/justfiles) repo for more on this pattern.
