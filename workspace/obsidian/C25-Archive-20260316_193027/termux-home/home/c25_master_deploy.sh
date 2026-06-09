#!/bin/bash
DEPLOY_DIR="$HOME/c25_static_master"
HTML_SOURCE="$HOME/c25-live/constellation/index.html"

mkdir -p "$DEPLOY_DIR"
cp "$HTML_SOURCE" "$DEPLOY_DIR/index.html"

cat > "$DEPLOY_DIR/vercel.json" << 'JSON'
{
  "version": 2,
  "builds": [{"src": "index.html", "use": "@vercel/static"}],
  "routes": [{"src": "/(.*)", "dest": "/index.html"}]
}
JSON

cd "$DEPLOY_DIR"

PROJECTS=(
  "constellation25-dashboard"
  "constellation25"
  "sovereign-gtp"
  "agentik"
  "fp-build-fixer"
  "sovereign_genesis"
  "sovereign"
  "kreativekoncepts"
  "constellation-25-live"
  "constellation25-root"
  "ai-metaverse-orgin"
  "ai-kre8tive-sovereign-genesis"
  "aikre8tive-bioauth"
  "cyg-nus-master"
  "total_recall_forensics"
)

for PROJECT in "${PROJECTS[@]}"; do
  echo "🚀 Deploying $PROJECT..."
  vercel deploy --yes --prod --name "$PROJECT" --scope faceprintpays-projects 2>&1 | tail -2
  sleep 3
done

echo "✅ DONE"
