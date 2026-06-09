#!/data/data/com.termux/files/usr/bin/bash
# C25 FULL 25-AGENT BUILD + HTML RECOVERY
# Runs all commands, fixes failures, greps all HTML
# #MrGGTP | Cygel White | FacePrintPay Inc

HOME="${HOME:-/data/data/com.termux/files/home}"
export PATH="/data/data/com.termux/files/usr/bin:$PATH"

PATHOS="http://localhost:3100"
TRUTH="/data/data/com.termux/files/home/storage/external-1/external-1/TERMUX_TRUTH"
MONO="$HOME/C25-MONO"
LOG="/data/data/com.termux/files/home/storage/external-1/external-1/C25_BUILD_ALL.log"
FIXED="/data/data/com.termux/files/home/storage/external-1/external-1/C25_FIXED"
FAILED="/data/data/com.termux/files/home/storage/external-1/external-1/C25_FAILED"
HTML_OUT="/data/data/com.termux/files/home/storage/external-1/external-1/C25_HTML_RECOVERY"
REPORT="/data/data/com.termux/files/home/storage/external-1/external-1/C25_FINAL_REPORT.txt"

mkdir -p "$FIXED" "$FAILED" "$HTML_OUT"
> "$LOG"

PASS=0; FAIL=0; FIXED_COUNT=0; SKIP=0
TLIMIT=15

log() {
    echo "[$(date '+%H:%M:%S')] $1" | tee -a "$LOG"
}

log "========================================================"
log "C25 FULL BUILD — 25 AGENTS — $(date)"
log "========================================================"

# ── BOOT PATHOS ───────────────────────────────────────────────
log "[BOOT] Starting Pathos..."
pkill -f 'node server.js' 2>/dev/null || true
sleep 1
cd "$HOME/pathos" && node server.js >> "$LOG" 2>&1 &
sleep 3
STATUS=$(curl -s "$PATHOS/status" 2>/dev/null || echo "offline")
log "[BOOT] Pathos: $STATUS"

# ── 25 AGENT ROSTER ───────────────────────────────────────────
AGENTS=(
    "Earth:Base Ops:8001"
    "Moon:Memory:8002"
    "Sun:Optimize:8003"
    "Mercury:Routing:8004"
    "Venus:UI/UX:8005"
    "Mars:Engineering:8006"
    "Jupiter:Orchestrate:8007"
    "Saturn:Data:8008"
    "Uranus:R&D:8009"
    "Neptune:Compliance:8010"
    "Cygnus:Patterns:8011"
    "Orion:Content:8012"
    "Andromeda:Media:8013"
    "Pleiades:Distribution:8014"
    "Sirius:CI/CD:8015"
    "CanisMajor:Sovereignty:8016"
    "Hydra:Pipelines:8017"
    "Apollo:Launch:8018"
    "Artemis:Recovery:8019"
    "Titan:Scale:8020"
    "Vega:Analytics:8021"
    "Draco:Security:8022"
    "Lyra:Harmony:8023"
    "Phoenix:Rebuild:8024"
    "Zenith:Apex:8025"
)

log "[AGENTS] 25 agents registered"
for A in "${AGENTS[@]}"; do
    N=$(echo "$A"|cut -d: -f1)
    R=$(echo "$A"|cut -d: -f2)
    P=$(echo "$A"|cut -d: -f3)
    log "  $N ($R) port:$P"
done

# ── RUN + FIX FUNCTION ────────────────────────────────────────
run_and_fix() {
    local SCRIPT="$1" TYPE="$2" AGENT="$3"
    [ -f "$SCRIPT" ] || return
    echo "$SCRIPT" | grep -qE "node_modules|site-packages|venv|nvm\.sh|flutter|thrift|pnpm|cassandra|pip/_vendor|__pycache__" && { ((SKIP++)); return; }

    local NAME=$(basename "$SCRIPT")
    local OUT="/tmp/c25out_$$"

    timeout $TLIMIT $TYPE "$SCRIPT" > "$OUT" 2>&1
    local CODE=$?

    if [ $CODE -eq 0 ]; then
        ((PASS++))
        log "  ✓ [$AGENT] $NAME"
        rm -f "$OUT"; return
    fi

    [ $CODE -eq 124 ] && { ((SKIP++)); log "  ⏱ [$AGENT] $NAME TIMEOUT"; rm -f "$OUT"; return; }

    local ERR=$(head -3 "$OUT" 2>/dev/null)
    log "  ✗ [$AGENT] $NAME | $ERR"
    cp "$SCRIPT" "$FAILED/$NAME" 2>/dev/null || true

    # Auto-fix
    local FIX="/tmp/fix_$$_$NAME"
    cp "$SCRIPT" "$FIX"
    if [ "$TYPE" = "bash" ]; then
        sed -i '1s|#!/bin/bash|#!/data/data/com.termux/files/usr/bin/bash|' "$FIX"
        sed -i '1s|#!/usr/bin/bash|#!/data/data/com.termux/files/usr/bin/bash|' "$FIX"
        sed -i '1s|#!/bin/sh|#!/data/data/com.termux/files/usr/bin/bash|' "$FIX"
        sed -i "s|/home/user/|$HOME/|g; s|/root/|$HOME/|g" "$FIX"
    else
        sed -i '1s|#!/usr/bin/python.*|#!/data/data/com.termux/files/usr/bin/python3|' "$FIX"
        sed -i "s|/home/user/|$HOME/|g; s|/root/|$HOME/|g" "$FIX"
    fi

    # Fix missing modules
    if echo "$ERR" | grep -q "ModuleNotFoundError"; then
        MOD=$(echo "$ERR" | sed "s/.*No module named '//;s/'.*//")
        [ -n "$MOD" ] && pip install "$MOD" --break-system-packages -q 2>/dev/null && log "    → installed: $MOD"
    fi

    # Fix missing commands
    if echo "$ERR" | grep -q "command not found"; then
        CMD=$(echo "$ERR" | awk '{print $1}')
        pkg install "$CMD" -y -q 2>/dev/null && log "    → installed pkg: $CMD"
    fi

    timeout $TLIMIT $TYPE "$FIX" >> "$OUT" 2>&1
    if [ $? -eq 0 ]; then
        ((FIXED_COUNT++)); ((PASS++))
        cp "$FIX" "$FIXED/$NAME"
        log "    ✓ FIXED: $NAME"
    else
        ((FAIL++))
        echo "$SCRIPT" >> "$FAILED/failed_list.txt"
    fi
    rm -f "$OUT" "$FIX"
}

# ── STEP 1: CONFIRMED EXECUTED ────────────────────────────────
log ""
log "[1/5] Confirmed-executed scripts..."
[ -f "$TRUTH/CONFIRMED_EXECUTED.txt" ] && while IFS= read -r line; do
    S=$(echo "$line" | awk '{print $2}')
    [ -z "$S" ] && continue
    echo "$S" | grep -q "\.py$" && run_and_fix "$S" "python3" "Moon" || run_and_fix "$S" "bash" "Earth"
done < "$TRUTH/CONFIRMED_EXECUTED.txt"
log "  PASS=$PASS FAIL=$FAIL FIXED=$FIXED_COUNT SKIP=$SKIP"

# ── STEP 2: ALL BASH FROM MONO ────────────────────────────────
log ""
log "[2/5] All bash scripts from mono repo..."
[ -d "$MONO/bash" ] && for S in "$MONO/bash"/*.sh; do
    run_and_fix "$S" "bash" "Mars"
done
log "  PASS=$PASS FAIL=$FAIL FIXED=$FIXED_COUNT SKIP=$SKIP"

# ── STEP 3: ALL PYTHON FROM MONO ──────────────────────────────
log ""
log "[3/5] All python scripts from mono repo..."
[ -d "$MONO/python" ] && for S in "$MONO/python"/*.py; do
    run_and_fix "$S" "python3" "Saturn"
done
log "  PASS=$PASS FAIL=$FAIL FIXED=$FIXED_COUNT SKIP=$SKIP"

# ── STEP 4: GREP ALL HTML FILES ───────────────────────────────
log ""
log "[4/5] VENUS — Grepping ALL HTML files from complete history..."

HTML_INDEX="$HTML_OUT/HTML_INDEX.txt"
HTML_ALL="$HTML_OUT/ALL_HTML_COMBINED.html"

> "$HTML_INDEX"
> "$HTML_ALL"

HTML_COUNT=0

# Search everywhere
for SEARCH_ROOT in "$HOME" "/sdcard"; do
    find "$SEARCH_ROOT" -name "*.html" -o -name "index.html" -o -name "*.htm" 2>/dev/null | \
    grep -vE "node_modules|\.git|site-packages|venv|flutter|thrift|pnpm" | \
    while IFS= read -r HTML; do
        [ -f "$HTML" ] || continue
        SZ=$(wc -c < "$HTML" 2>/dev/null || echo 0)
        [ "$SZ" -lt 100 ] && continue
        echo "$SZ $HTML" >> "$HTML_INDEX"
        echo "" >> "$HTML_ALL"
        echo "<!-- ===== FILE: $HTML ===== -->" >> "$HTML_ALL"
        cat "$HTML" >> "$HTML_ALL"
        ((HTML_COUNT++)) || true
        log "  [Venus] HTML: $(basename $HTML) ($SZ bytes)"
    done
done

log "  Total HTML files found and indexed: $HTML_COUNT"

# Sort by size — biggest first
sort -rn "$HTML_INDEX" -o "$HTML_INDEX"
log "  Top 10 HTML files by size:"
head -10 "$HTML_INDEX" | while read SIZE PATH; do
    log "    ${SIZE}b  $PATH"
done

# Copy top HTML files to vault
mkdir -p "$HTML_OUT/top"
head -20 "$HTML_INDEX" | while read SIZE PATH; do
    cp "$PATH" "$HTML_OUT/top/$(basename $PATH)" 2>/dev/null || true
done

# Push HTML recovery to mono repo
log "  Pushing HTML files to GitHub..."
mkdir -p "$MONO/html"
head -50 "$HTML_INDEX" | while read SIZE PATH; do
    cp "$PATH" "$MONO/html/$(echo $PATH | md5sum | cut -c1-6)_$(basename $PATH)" 2>/dev/null || true
done

cd "$MONO" && git add html/ 2>/dev/null && \
git commit -m "Venus agent — HTML recovery: all index.html and web files" 2>/dev/null && \
git push 2>/dev/null && log "  HTML files pushed to C25-mono" || log "  Git push skipped"

# ── STEP 5: 25 AGENT STATUS ───────────────────────────────────
log ""
log "[5/5] All 25 agents dispatching via Pathos..."
for AGENT_DEF in "${AGENTS[@]}"; do
    NAME=$(echo "$AGENT_DEF" | cut -d: -f1)
    RESULT=$(curl -s -X POST "$PATHOS/dispatch" \
        -H "Content-Type: application/json" \
        -d "{\"agent\":\"$NAME\",\"prompt\":\"build complete — report status\"}" \
        2>/dev/null | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('response','no response')[:100])" 2>/dev/null \
        || echo "offline")
    log "  [$NAME] $RESULT"
done

# ── FINAL REPORT ──────────────────────────────────────────────
log ""
log "========================================================"
log "C25 BUILD COMPLETE — $(date)"
log "========================================================"
log "PASS         : $PASS"
log "FAIL         : $FAIL"
log "AUTO-FIXED   : $FIXED_COUNT"
log "SKIP/TIMEOUT : $SKIP"
log "HTML FILES   : $HTML_COUNT"
log ""
log "OUTPUTS:"
log "  Fixed scripts : $FIXED/"
log "  Failed scripts: $FAILED/"
log "  HTML recovery : $HTML_OUT/"
log "  Full log      : $LOG"
log "  GitHub        : https://github.com/FacePrintPay/C25-mono"
log ""
log "PATHOS STATUS:"
curl -s "$PATHOS/status" 2>/dev/null | python3 -c "import json,sys; d=json.load(sys.stdin); print('  Agents: '+str(d.get('agents',0)))" 2>/dev/null || log "  Check: curl http://localhost:3100/status"
log "========================================================"

cat > "$REPORT" << EOF
C25 SOVEREIGN AI EMPIRE — FINAL BUILD REPORT
$(date)
========================================
PASS         : $PASS
FAIL         : $FAIL
AUTO-FIXED   : $FIXED_COUNT
SKIP/TIMEOUT : $SKIP
HTML FILES   : $HTML_COUNT
TOTAL        : $((PASS+FAIL+SKIP))
========================================
GitHub: https://github.com/FacePrintPay/C25-mono
Docker: ghcr.io/faceprintpay/constellation-25:latest
Pathos: http://localhost:3100
========================================
EOF

cat "$REPORT" | tee -a "$LOG"
