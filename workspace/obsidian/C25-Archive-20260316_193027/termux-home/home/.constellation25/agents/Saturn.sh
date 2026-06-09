#!/bin/bash
# BANANI BUILD EXECUTION - Saturn.sh
INTENT="/data/data/com.termux/files/home/Agentik/nlp2code/complete_intent.json"
[ -f "$INTENT" ] && echo "🎯 Loading: $(jq -r ".complete_intent.primary_goal" "$INTENT" 2>/dev/null)"

#!/data/data/com.termux/files/usr/bin/bash
echo "[Saturn] Creating backup..."
tar -czf ~/.constellation25/backup/c25_backup_$(date +%Y%m%d).tar.gz ~/.constellation25/agents/ 2>/dev/null
echo "[Saturn] Backup saved"
