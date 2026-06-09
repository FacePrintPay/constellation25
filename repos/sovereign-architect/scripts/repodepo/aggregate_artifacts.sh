#!/bin/bash
# Artifact Aggregator - Collects all Claude artifacts

REPO_ROOT="$HOME/Kre8tiveKonceptz_RepoDepo"
ARTIFACTS_DIR="$REPO_ROOT/artifacts"

echo "🔍 Scanning for Claude artifacts..."

# Find all .sh, .py, .js files from various sources
find "$HOME" -type f \( -name "*.sh" -o -name "*.py" -o -name "*.js" \) \
    -not -path "*/\.*" \
    -not -path "*/node_modules/*" \
    2>/dev/null | while read -r file; do
    
    # Categorize based on filename/content
    if grep -q "YESQUID\|PaTHos" "$file" 2>/dev/null; then
        cat="01_yesquid_pathos"
    elif grep -q "state\|persistent\|checksum" "$file" 2>/dev/null; then
        cat="02_state_management"
    elif grep -q "gsutil\|gcloud\|cloud" "$file" 2>/dev/null; then
        cat="03_cloud_integration"
    elif grep -q "videocourt\|blockchain" "$file" 2>/dev/null; then
        cat="04_videocourts"
    else
        cat="05_tools_utilities"
    fi
    
    # Copy to appropriate category
    basename_file=$(basename "$file")
    cp "$file" "$ARTIFACTS_DIR/$cat/$basename_file" 2>/dev/null
    echo "  ✓ $basename_file → $cat"
done

echo "✅ Artifact aggregation complete!"
