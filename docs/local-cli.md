# Local CLI Usage

Run the DBOM pipeline locally using [just](https://github.com/casey/just) and the [makoto-project/dbom](https://github.com/makoto-project/dbom) CLI toolkit.

## Prerequisites

- [just](https://github.com/casey/just) — `brew install just` (macOS) or `cargo install just`
- Python 3.10+
- `pyyaml` — `pip install pyyaml` (only needed for external fetch)

## Setup

```bash
git clone https://github.com/makoto-project/aw-dbom.git
cd aw-dbom

# Vendor the dbom CLI toolkit (clone into dbom/)
just vendor
```

The `vendor` recipe clones [makoto-project/dbom](https://github.com/makoto-project/dbom) into `dbom/` (gitignored). Run it again to pull the latest version.

## Recipes

```bash
just vendor            # Clone or update the dbom CLI toolkit
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
  ✓ DBOM: dboms/config.dbom.json
  ✓ DBOM: dboms/iris.dbom.json

▸ Step 4: Validating all DBOMs...
  ✓ config.dbom.json: PASS
  ✓ iris.dbom.json: PASS
  ✓ sample-metrics.dbom.json: PASS
```

## Alias Pattern

Clone the toolkit once and use it from anywhere:

```bash
git clone https://github.com/makoto-project/dbom.git ~/dbom
alias dbom='just --justfile ~/dbom/Justfile'

# Then from any project directory:
dbom generate mydata.csv
dbom validate-all
dbom gate
```

See the [makoto-project/justfiles](https://github.com/makoto-project/justfiles) repo for more on this pattern.
