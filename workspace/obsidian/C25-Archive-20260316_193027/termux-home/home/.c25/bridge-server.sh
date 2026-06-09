#!/usr/bin/env bash
PORT="${1:-8080}"
AGENT_DIR="$HOME/constellation25/agents"
while true; do
  # Read HTTP POST body (simple parser)
  read -r request
  while read -r header && [ "$header" != $'\r' ] && [ -n "$header" ]; do :; done
  read -r -t 2 content_length
  if [[ "$content_length" =~ ^Content-Length:\ ([0-9]+) ]]; then
    read -r -N "${BASH_REMATCH[1]}" body
  fi
  # Parse command: AGENT_NAME args...
  if [[ "$body" =~ agent=([^&]+)&cmd=(.+) ]]; then
    agent="${BASH_REMATCH[1]}"; cmd="${BASH_REMATCH[2]}"
    script="$AGENT_DIR/${agent,,}-agent.sh"
    if [ -x "$script" ]; then
      output=$("$script" "$cmd" 2>&1) || output="❌ Error: $output"
    else
      output="⚠️ Agent script not found: $script"
    fi
  else
    output="🌌 C25 Bridge: POST agent=<name>&cmd=<command>"
  fi
  # Respond
  echo -e "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n\r\n$output"
done
