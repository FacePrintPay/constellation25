#!/bin/bash
# BANANI BUILD EXECUTION - run.sh
INTENT="/data/data/com.termux/files/home/Agentik/nlp2code/complete_intent.json"
[ -f "$INTENT" ] && echo "🎯 Loading: $(jq -r ".complete_intent.primary_goal" "$INTENT" 2>/dev/null)"

#!/data/data/com.termux/files/usr/bin/bash
grep -E "^(mkdir|cd|echo|for|chmod|find|ls|cat|rm|cp|mv|source|export|alias)" | bash
