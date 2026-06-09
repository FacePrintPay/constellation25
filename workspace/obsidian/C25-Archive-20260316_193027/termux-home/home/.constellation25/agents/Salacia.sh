#!/bin/bash
# BANANI BUILD EXECUTION - Salacia.sh
INTENT="/data/data/com.termux/files/home/Agentik/nlp2code/complete_intent.json"
[ -f "$INTENT" ] && echo "🎯 Loading: $(jq -r ".complete_intent.primary_goal" "$INTENT" 2>/dev/null)"

#!/data/data/com.termux/files/usr/bin/bash
echo "[Salacia] Agent Online - Ready"
