#!/bin/bash
# BANANI BUILD EXECUTION - Mercury.sh
INTENT="/data/data/com.termux/files/home/Agentik/nlp2code/complete_intent.json"
[ -f "$INTENT" ] && echo "🎯 Loading: $(jq -r ".complete_intent.primary_goal" "$INTENT" 2>/dev/null)"

#!/data/data/com.termux/files/usr/bin/bash
echo "[Mercury] Deploying..."
cp -r ~/c25-demo-teaser/* ~/.constellation25/deploy/ 2>/dev/null || echo "No source files"
echo "[Mercury] Deploy complete"
