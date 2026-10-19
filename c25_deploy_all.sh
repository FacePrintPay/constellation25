#!/usr/bin/env bash
################################################################################
# Constellation25 Automated Fix & Deploy Script
# Launches all 25 agents to scan, fix, and deploy 299 repositories
################################################################################

set -euo pipefail

C25_HOME="${C25_HOME:-.}"
AGENTS_SCRIPT="$C25_HOME/c25_master_deployment.py"
LOG_DIR="$C25_HOME/logs"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

mkdir -p "$LOG_DIR"

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║   CONSTELLATION25 AUTOMATED DEPLOYMENT & REPAIR              ║"
echo "║              Scanning 299 repositories...                     ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# Check dependencies
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 required but not installed"
    exit 1
fi

echo "✓ Starting master deployment agent..."
python3 "$AGENTS_SCRIPT" 2>&1 | tee "$LOG_DIR/deploy_$TIMESTAMP.log"

echo ""
echo "✓ Deployment complete. Check logs:"
echo "  $LOG_DIR/deploy_$TIMESTAMP.log"
