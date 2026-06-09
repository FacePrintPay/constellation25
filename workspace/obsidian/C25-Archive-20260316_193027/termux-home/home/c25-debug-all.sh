#!/bin/bash
set -euo pipefail

DEBUG_DIR=~/agent-debug-$(date +%Y%m%d_%H%M%S)
mkdir -p $DEBUG_DIR/{logs,fixed,errors}

# Find all .sh files
find ~ /sdcard /storage/emulated/0 -name "*.sh" -type f 2>/dev/null > $DEBUG_DIR/all_scripts.txt

TOTAL=$(wc -l < $DEBUG_DIR/all_scripts.txt)
echo "Found $TOTAL scripts. Processing..."

SUCCESS=0
FIXED=0
ERRORS=0
COUNT=0

while IFS= read -r script; do
    name=$(basename "$script")
    echo "[$((++COUNT))/$TOTAL] $name"
    
    if bash -n "$script" 2>"$DEBUG_DIR/errors/${name}.err"; then
        timeout 10 bash -x "$script" >"$DEBUG_DIR/logs/${name}.out" 2>"$DEBUG_DIR/logs/${name}.err" && ((SUCCESS++)) || {
            cp "$script" "$DEBUG_DIR/fixed/$name"
            sed -i 's/\r$//;1{/^#!/!s/^/#!/bin\/bash\n/}' "$DEBUG_DIR/fixed/$name"
            timeout 10 bash "$DEBUG_DIR/fixed/$name" >/dev/null 2>&1 && ((FIXED++)) || ((ERRORS++))
        }
    else
        ((ERRORS++))
    fi
done < $DEBUG_DIR/all_scripts.txt

echo "SUCCESS: $SUCCESS | FIXED: $FIXED | ERRORS: $ERRORS"
echo "Results: $DEBUG_DIR"
