#!/bin/bash
# BANANI BUILD EXECUTION - Uranus.sh
INTENT="/data/data/com.termux/files/home/Agentik/nlp2code/complete_intent.json"
[ -f "$INTENT" ] && echo "🎯 Loading: $(jq -r ".complete_intent.primary_goal" "$INTENT" 2>/dev/null)"

#!/data/data/com.termux/files/usr/bin/bash
echo "[Uranus] Network Check:"
ping -c 1 8.8.8.8 >/dev/null 2>&1 && echo "  Online" || echo "  Offline"
echo "[Uranus] Check complete"
