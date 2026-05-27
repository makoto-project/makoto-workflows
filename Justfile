# Directory containing this Justfile
root := justfile_directory()

# Vendored makoto-cli CLI
makoto_cli_dir := root / "makoto-cli"
makoto_cli_justfile := makoto_cli_dir / "Justfile"
makoto_cli_repo := "https://github.com/makoto-project/makoto-cli.git"

# List available recipes
default:
    @just --list

# --- Vendor ---

# Clone or update the vendored makoto-cli CLI toolkit
vendor:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ -d "{{makoto_cli_dir}}/.git" ]; then
        echo "Updating vendored makoto-cli CLI..."
        git -C "{{makoto_cli_dir}}" pull --ff-only
    else
        echo "Cloning makoto-cli CLI toolkit..."
        rm -rf "{{makoto_cli_dir}}"
        git clone "{{makoto_cli_repo}}" "{{makoto_cli_dir}}"
    fi
    echo "Installing makoto-cli dependencies (makoto SDK)..."
    just --justfile "{{makoto_cli_justfile}}" install
    echo "✓ makoto-cli CLI ready at {{makoto_cli_dir}}"

# --- Demo ---

# Run the full demo pipeline end-to-end
demo mode="both": vendor
    #!/usr/bin/env bash
    set -euo pipefail
    echo "🚀 Running DBOM demo (mode: {{mode}})..."
    echo ""
    just --justfile "{{makoto_cli_justfile}}" gate {{mode}}
    echo ""
    just --justfile "{{makoto_cli_justfile}}" status

# Show status of all data assets
status: _require-makoto-cli
    @just --justfile "{{makoto_cli_justfile}}" status

# Show DBOM lineage for an asset
lineage file: _require-makoto-cli
    @just --justfile "{{makoto_cli_justfile}}" lineage {{file}}

# Internal: ensure makoto-cli CLI is vendored
_require-makoto-cli:
    #!/usr/bin/env bash
    if [ ! -f "{{makoto_cli_justfile}}" ]; then
        echo "makoto-cli CLI not found. Run 'just vendor' first." >&2
        exit 1
    fi

# Reset demo state (clear generated DBOMs and fetched data)
demo-clean:
    #!/usr/bin/env bash
    echo "Cleaning generated artifacts..."
    rm -f dboms/config.dbom.json dboms/iris.dbom.json
    rm -f dboms/*_filtered.dbom.json
    rm -f data/external/iris.csv
    rm -f data/local/*_filtered.*
    echo "✓ Clean. Pre-existing sample-metrics DBOM preserved."
