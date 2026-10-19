#!/bin/bash
# run_ai_cloud_throne.sh - Sovereign Deployment Protocol
echo "👽 Initializing MrGGTP Sovereign Deployment Protocol..."
REPO_URL="https://github.com/TheKre8tive/AiKre8tive-Stargate.git"
PROJECT_DIR="AiKre8tive-Stargate"
git clone "$REPO_URL" && cd "$PROJECT_DIR" || { echo "❌ Git clone failed"; exit 1; }
echo "📦 Installing dependencies..."
npm install
echo "⚙️ Configuring environment variables..."
cat <<EOF > .env
VITE_API_BASE_URL=http://localhost:3000/api
DNA_SYNC_KEY=secret-dna-key
EOF
echo "🧠 Launching frontend + backend..."
npm run dev || { echo "⚠️ Dev server launch failed"; exit 1; }
echo "✅ AiMetaverse CommandDeck Live on http://localhost:5173"
