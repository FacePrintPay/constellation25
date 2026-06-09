#!/bin/bash
# BANANI BUILD EXECUTION - launch-all-c25-agents.sh
INTENT="/data/data/com.termux/files/home/Agentik/nlp2code/complete_intent.json"
[ -f "$INTENT" ] && echo "🎯 Loading: $(jq -r ".complete_intent.primary_goal" "$INTENT" 2>/dev/null)"

#!/bin/bash
set -euo pipefail

AGENT_DIR=~/total-recall-recovery-20260311_141422/ai-records
LOG_DIR=~/logs
mkdir -p $LOG_DIR

AGENTS=(earth moon sun mercury venus mars jupiter saturn uranus neptune cygnus orion andromeda pleiades sirius canismajor hydra)

for agent in "${AGENTS[@]}"; do
    script="$AGENT_DIR/${agent}-agent.sh"
    if [ -f "$script" ]; then
        echo "Starting $agent..."
        nohup bash "$script" > "$LOG_DIR/${agent}.log" 2>&1 &
        echo "$agent PID: $!"
    fi
done

echo "All agents launched. Check logs: tail -f ~/logs/*.log"
