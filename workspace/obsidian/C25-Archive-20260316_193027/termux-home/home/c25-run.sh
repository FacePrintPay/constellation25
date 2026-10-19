#!/data/data/com.termux/files/usr/bin/bash
cd ~/.constellation25
echo "=== CONSTELLATION 25 ==="
echo "Agents: $(ls -1 agents/ 2>/dev/null | wc -l)"
echo "Modules: $(ls -1 modules/ 2>/dev/null | wc -l)"
echo ""
echo "Type agent name to run, or 'exit':"
echo -n "> "
read agent
if [ "$agent" = "exit" ]; then exit 0; fi
if [ -x "agents/${agent}.sh" ]; then
  ./agents/${agent}.sh
else
  echo "Agent not found: $agent"
fi
