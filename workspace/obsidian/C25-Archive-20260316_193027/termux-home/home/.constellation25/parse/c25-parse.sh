#!/data/data/com.termux/files/usr/bin/bash
# C25 PARSER AGENT v1.0
# Usage: paste conversation into ~/.c25_input.txt then run: c25-parse

INPUT="${1:-$HOME/.c25_input.txt}"

echo "🔍 Parsing: $INPUT"
echo "════════════════════════════"

# Extract bash commands from conversation
grep -E "^(cd |mkdir |echo |for |chmod |find |ls |cat |rm |cp |mv |source |export |alias)" "$INPUT" 2>/dev/null | while read line; do
  echo "$line"
done

echo "════════════════════════════"
echo "✅ Extracted commands above. Copy and run in Termux."

