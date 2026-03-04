# Directory containing this Justfile
root := justfile_directory()

# Vendored dbom CLI
dbom_dir := root / "dbom"
dbom_justfile := dbom_dir / "Justfile"
dbom_repo := "https://github.com/asw101/dbom.git"

# List available recipes
default:
    @just --list

# --- Vendor ---

# Clone or update the vendored dbom CLI toolkit
vendor:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ -d "{{dbom_dir}}/.git" ]; then
        echo "Updating vendored dbom CLI..."
        git -C "{{dbom_dir}}" pull --ff-only
    else
        echo "Cloning dbom CLI toolkit..."
        rm -rf "{{dbom_dir}}"
        git clone "{{dbom_repo}}" "{{dbom_dir}}"
    fi
    echo "✓ dbom CLI ready at {{dbom_dir}}"

# --- Demo ---

# Run the full demo pipeline end-to-end
demo mode="both": vendor
    #!/usr/bin/env bash
    set -euo pipefail
    echo "🚀 Running DBOM demo (mode: {{mode}})..."
    echo ""
    just --justfile "{{dbom_justfile}}" gate {{mode}}
    echo ""
    just --justfile "{{dbom_justfile}}" status

# Show status of all data assets
status: _require-dbom
    @just --justfile "{{dbom_justfile}}" status

# Show DBOM lineage for an asset
lineage file: _require-dbom
    @just --justfile "{{dbom_justfile}}" lineage {{file}}

# Internal: ensure dbom CLI is vendored
_require-dbom:
    #!/usr/bin/env bash
    if [ ! -f "{{dbom_justfile}}" ]; then
        echo "dbom CLI not found. Run 'just vendor' first." >&2
        exit 1
    fi

# Reset demo state (clear generated DBOMs, fetched data, attestations)
demo-clean:
    #!/usr/bin/env bash
    echo "Cleaning generated artifacts..."
    rm -f dboms/config.dbom.json dboms/iris.dbom.json
    rm -f attestations/config.origin.json attestations/iris.origin.json
    rm -f attestations/*_filtered.transform.json
    rm -f data/external/iris.csv
    rm -f data/local/*_filtered.*
    echo "✓ Clean. Pre-existing sample-metrics DBOM preserved."
