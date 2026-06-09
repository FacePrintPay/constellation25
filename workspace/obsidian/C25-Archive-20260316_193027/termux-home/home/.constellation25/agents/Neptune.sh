#!/bin/bash
# BANANI BUILD EXECUTION - Neptune.sh
INTENT="/data/data/com.termux/files/home/Agentik/nlp2code/complete_intent.json"
[ -f "$INTENT" ] && echo "🎯 Loading: $(jq -r ".complete_intent.primary_goal" "$INTENT" 2>/dev/null)"

#!/data/data/com.termux/files/usr/bin/bash
echo "[Neptune] Database Status:"
ls -la ~/.constellation25/state/ 2>/dev/null || echo "  No state files"
echo "[Neptune] Status complete"
