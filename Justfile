# Directory containing this Justfile
root := justfile_directory()

# Vendored dbom CLI
dbom_justfile := root / "dbom" / "Justfile"

# List available recipes
default:
    @just --list

# --- Demo ---

# Run the full demo pipeline end-to-end
demo mode="both":
    #!/usr/bin/env bash
    set -euo pipefail
    echo "🚀 Running DBOM demo (mode: {{mode}})..."
    echo ""
    # Ensure dbom CLI is available
    if [ ! -f "{{dbom_justfile}}" ]; then
        echo "Cloning dbom CLI toolkit..."
        git clone https://github.com/asw101/dbom.git "{{root}}/dbom"
    fi
    just --justfile "{{dbom_justfile}}" gate {{mode}}
    echo ""
    just --justfile "{{dbom_justfile}}" status

# Show status of all data assets
status:
    #!/usr/bin/env bash
    if [ ! -f "{{dbom_justfile}}" ]; then
        echo "dbom CLI not found. Run 'just demo' first." >&2
        exit 1
    fi
    just --justfile "{{dbom_justfile}}" status

# Show DBOM lineage for an asset
lineage file:
    #!/usr/bin/env bash
    if [ ! -f "{{dbom_justfile}}" ]; then
        echo "dbom CLI not found. Run 'just demo' first." >&2
        exit 1
    fi
    just --justfile "{{dbom_justfile}}" lineage {{file}}

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
