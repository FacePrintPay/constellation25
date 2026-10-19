#!/bin/bash
# BANANI BUILD EXECUTION - engine.sh
INTENT="/data/data/com.termux/files/home/Agentik/nlp2code/complete_intent.json"
[ -f "$INTENT" ] && echo "🎯 Loading: $(jq -r ".complete_intent.primary_goal" "$INTENT" 2>/dev/null)"

#!/data/data/com.termux/files/usr/bin/bash

AGENT=$1
FILE=$2
OUTPUT="$HOME/.agent-engine/output"
LOGS="$HOME/C25-MASTER/agent_logs"
mkdir -p "$OUTPUT" "$LOGS"

FAST="llama3.2:1b"
DEEP="llama3.2:1b"  # use 1b for everything until RAM confirmed stable

[ ! -f "$FILE" ] && echo "❌ No file: $FILE" && exit 1

CONTENT=$(cat "$FILE")
FNAME=$(basename "$FILE")
TS=$(date '+%Y%m%d_%H%M%S')

case $AGENT in
  earth)      P="Analyze this code structure and suggest improvements:" ;;
  moon)       P="Find and fix syntax errors in this code. Show what's wrong and the fix:" ;;
  sun)        P="Optimize this code for performance:" ;;
  mercury)    P="Generate unit tests for this code:" ;;
  venus)      P="Suggest UI/UX improvements:" ;;
  mars)       P="Scan for security vulnerabilities:" ;;
  jupiter)    P="Generate documentation for this code:" ;;
  saturn)     P="Refactor this code using best practices:" ;;
  uranus)     P="Review async operations and background tasks:" ;;
  neptune)    P="Perform deep analysis and find hidden issues:" ;;
  cygnus)     P="How should multiple agents collaborate on this?" ;;
  orion)      P="Identify all patterns and anti-patterns:" ;;
  andromeda)  P="How does this scale to 10x load?" ;;
  pleiades)   P="Break this into parallel executable tasks:" ;;
  sirius)     P="Rank all issues by priority HIGH/MED/LOW:" ;;
  canismajor) P="Security audit - check auth and guard logic:" ;;
  hydra)      P="Identify opportunities for multi-threading:" ;;
  *)          P="Analyze this code:" ;;
esac

echo ""
echo "╔══════════════════════════════════════╗"
echo "║  🌟 C25 AGENT: $(echo $AGENT | tr '[:lower:]' '[:upper:]')"
echo "║  📄 File: $FNAME"
echo "║  🤖 Model: $FAST"
echo "╚══════════════════════════════════════╝"
echo ""

RESULT=$(curl -s --max-time 120 http://localhost:11434/api/generate \
  -d "{
    \"model\": \"$FAST\",
    \"prompt\": \"$P\n\nFILE: $FNAME\n---\n$CONTENT\n---\",
    \"stream\": false,
    \"options\": {\"num_predict\": 500}
  }" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('response','no response'))")

echo "$RESULT"
echo "$RESULT" > "$OUTPUT/last_output.txt"
echo "$RESULT" > "$OUTPUT/${AGENT}_${FNAME}_${TS}.txt"
echo "$TS | $AGENT | $FILE" >> "$LOGS/agent_activity.log"

echo ""
echo "✅ Saved to: $OUTPUT/last_output.txt"
