#!/bin/bash
# BANANI BUILD EXECUTION - Venus.sh
INTENT="/data/data/com.termux/files/home/Agentik/nlp2code/complete_intent.json"
[ -f "$INTENT" ] && echo "🎯 Loading: $(jq -r ".complete_intent.primary_goal" "$INTENT" 2>/dev/null)"

#!/data/data/com.termux/files/usr/bin/bash
echo "[Venus] Scanning security..."
find ~/.constellation25 -type f -perm 777 2>/dev/null | head -10
echo "[Venus] Scan complete"
