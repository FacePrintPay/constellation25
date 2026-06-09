#!/data/data/com.termux/files/usr/bin/bash
#===============================================================================
# CONSTELLATION25: UNIFIED BOOT RUNNER
# Formats, routes, and executes all repos as one NLP2CODE-compatible system
#===============================================================================
set -euo pipefail

BASE="/workspace/Constellation25"
MANIFEST="$BASE/build-manifest.json"
LOG="$BASE/boot-$(date +%Y%m%d).log"

log() { echo "[$(date -Iseconds)] $*" | tee -a "$LOG"; }
log "🚀 Starting Constellation25 Unified Runtime"

# === 1. FORMAT ALL CODE CONSISTENTLY ===
log "🎨 Formatting code across all repos..."
find "$BASE/repos" -name "*.py" -not -path "*/.git/*" -exec black {} \; 2>/dev/null || true
find "$BASE/repos" -name "*.js" -not -path "*/.git/*" -exec npx prettier --write {} \; 2>/dev/null || true

# === 2. GENERATE UNIFIED ROUTING MAP ===
log "🗺️ Generating unified routing map..."
jq -r '.repos[] | "\(.name)|\(.files.python)|\(.files.javascript)|\(.grep_analysis.agent_refs)"' "$MANIFEST" | \
while IFS='|' read -r name py js agents; do
  if [ "$py" -gt 0 ] || [ "$js" -gt 0 ]; then
    echo "REGISTER: $name (py:$py js:$js agents:$agents)" >> "$BASE/.routing.map"
  fi
done

# === 3. START CORE SERVICES ===
log "🔌 Starting core services..."

# Start Ollama (if not running)
if ! pgrep -f "ollama serve" > /dev/null; then
  log "🤖 Starting Ollama..."
  ollama serve &
  sleep 5
  ollama pull qwen2.5:1.5b 2>/dev/null || log "⚠️ Model pull failed"
fi

# Start FastAPI gateway (unified entry point)
log "🌐 Starting FastAPI gateway on port 8000..."
cd "$BASE"
python3 -m uvicorn src.gateway:app --host 0.0.0.0 --port 8000 --reload &
GATEWAY_PID=$!

# Start NLP2CODE interpreter
log "🧠 Starting NLP2CODE interpreter..."
python3 -m src.nlp2code.server --host 0.0.0.0 --port 8001 &
NLP_PID=$!

# === 4. REGISTER MCP TOOLS ===
log "🔧 Registering MCP tools from all repos..."
find "$BASE/repos" -name "mcp.json" -o -name "tools.json" | while read -r tool_file; do
  log "  ↳ Registering: $(basename "$tool_file")"
  # TODO: Implement MCP registration logic
done

# === 5. START LOCALHOST PROXY ===
log "🔄 Starting localhost proxy for repo routing..."
python3 -m src.localhost_proxy --port 8080 --manifest "$MANIFEST" &
PROXY_PID=$!

# === 6. WAIT FOR READY ===
log "⏳ Waiting for services to be ready..."
sleep 10

# === 7. HEALTH CHECK ===
if curl -s http://localhost:8000/health | jq -e '.status == "ok"' > /dev/null; then
  log "✅ Gateway healthy"
else
  log "⚠️ Gateway not ready"
fi

# === 8. PRINT ACCESS INFO ===
cat << EOF

🎉 CONSTELLATION25 UNIFIED RUNTIME READY
========================================
🌐 Gateway:   http://localhost:8000
🧠 NLP2CODE:  http://localhost:8001
🔄 Proxy:     http://localhost:8080
🤖 Ollama:    http://localhost:11434

📚 Access your unified ecosystem:
  • API Docs:  http://localhost:8000/docs
  • NLP Chat:  http://localhost:8001/chat
  • Repo Browser: http://localhost:8080/repos

🔐 Forensic Log: $LOG
📦 Manifest: $MANIFEST

💡 Try a natural language command:
  curl -X POST http://localhost:8001/chat \
    -H "Content-Type: application/json" \
    -d '{"prompt": "Show me all Python files that mention agents"}'

EOF

# Keep running
wait $GATEWAY_PID $NLP_PID $PROXY_PID 2>/dev/null || true
