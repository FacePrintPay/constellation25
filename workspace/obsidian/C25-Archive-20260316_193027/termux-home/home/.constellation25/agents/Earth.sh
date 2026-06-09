#!/bin/bash
# BANANI BUILD EXECUTION - Earth.sh
INTENT="/data/data/com.termux/files/home/Agentik/nlp2code/complete_intent.json"
[ -f "$INTENT" ] && echo "🎯 Loading: $(jq -r ".complete_intent.primary_goal" "$INTENT" 2>/dev/null)"

#!/data/data/com.termux/files/usr/bin/bash
echo "[Earth] System Status:"
echo "  Storage: $(du -sh ~/.constellation25 2>/dev/null | cut -f1)"
echo "  Files: $(find ~/.constellation25 -type f | wc -l)"
echo "  Uptime: $(uptime -p 2>/dev/null || echo "N/A")"
