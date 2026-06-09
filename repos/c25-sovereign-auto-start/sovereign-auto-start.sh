#!/data/data/com.termux/files/usr/bin/bash
# Sovereign Engine Auto-Start – CyGeL White #MrGGTP – 2026
# Runs every time Termux opens
LOG="$HOME/sovereign_engine/auto-start.log"
echo "Auto-start triggered – $(date)" >> "$LOG"
# Optional: Bio gate on every startup (uncomment if you want it)
# termux-fingerprint -t "Engine Boot" -d "CyGeL White #MrGGTP – Confirm Startup" || {
#   echo "Boot auth failed – exiting" >> "$LOG"
#   exit 1
# }
# Change to home or engine dir
cd ~ || exit 1
# If full 25-agent sync exists, run it
if [ -f "./sovereign-sync.sh" ]; then
  echo "Running full 25-agent sync..." >> "$LOG"
  bash ./sovereign-sync.sh >> "$LOG" 2>&1
else
  echo "Full sync script not found – running lightweight populate" >> "$LOG"
  ENGINE_DIR="$HOME/sovereign_engine"
  PROMPT_FILE="$ENGINE_DIR/prompt.txt"
  OUTPUT_JSON="$ENGINE_DIR/conversation_engine.json"
  mkdir -p "$ENGINE_DIR/logs"
  # Auto-create/populate prompt.txt if missing
  if [ ! -f "$PROMPT_FILE" ]; then
    echo "[ARCHITECT] Build Agentik sales page with Gamma link" > "$PROMPT_FILE"
    echo "[MONETIZATION] Inject Cash App link: \$Agentik" >> "$PROMPT_FILE"
    echo "[MESHARTIST] Generate ECB glitch QR" >> "$PROMPT_FILE"
    for i in {4..25}; do
      echo "[AGENT$i] Process task $i" >> "$PROMPT_FILE"
    done
    echo "Created default 25-agent prompt.txt" >> "$LOG"
  fi
  # Quick manifest populate (lightweight)
  python3 - <<PY >> "$LOG" 2>&1
import json, re
from datetime import datetime
with open('$PROMPT_FILE', 'r') as f:
    prompt = f.read().strip()
agents = []
for line in prompt.split('\n'):
    match = re.match(r'\[([A-Z0-9_]+)\]\s*(.*)', line.strip())
    if match:
        agents.append({'role': match.group(1), 'instruction': match.group(2)})
# Pad to 25 if needed
while len(agents) < 25:
    agents.append({'role': f'AGENT{len(agents)+1}', 'instruction': 'Auto-generated placeholder'})
manifest = {
    "session_id": datetime.now().strftime('%Y-%m-%d-%H%M%S'),
    "timestamp": datetime.now().isoformat(),
    "author": "CyGeL White #MrGGTP",
    "agents": agents,
    "auto_populated_on_boot": True
}
with open('$OUTPUT_JSON', 'w') as f:
    json.dump(manifest, f, indent=2)
print(f"Auto-populated manifest with {len(agents)} agents")
PY
  echo "Lightweight populate complete – manifest ready at $OUTPUT_JSON" >> "$LOG"
fi
echo "Auto-start finished – $(date)" >> "$LOG"
