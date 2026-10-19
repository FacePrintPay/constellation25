#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

echo "🚀 DEPLOYING FACEPRINTPAY ECOSYSTEM"
echo "===================================="

# Your projects to deploy
PROJECTS=(
  "Constellation25"
  "Agentik"
  "SovereignGTP"
  "VideoCourts"
  "MyBuyO"
  "AiRecords"
  "AiKre8tive"
  "PaTHos"
  "VerseD"
)

OWNER="FacePrintPay"
DEPLOYED=0
FAILED=0

for proj in "${PROJECTS[@]}"; do
  echo ""
  echo "🔷 Deploying: $proj"
  
  # Find the repo
  REPO_DIR=$(find ~ -maxdepth 4 -type d -iname "*${proj,,}*" ! -path "*/node_modules/*" ! -path "*/.git/*" | head -1)
  
  if [ -z "$REPO_DIR" ]; then
    echo "  ⚠️  Not found locally"
    FAILED=$((FAILED + 1))
    continue
  fi
  
  echo "  📁 Found: $REPO_DIR"
  cd "$REPO_DIR"
  
  # Check if it's a git repo
  if [ ! -d ".git" ]; then
    echo "  ⚠️  Not a git repo, initializing..."
    git init -q
    git config user.email "agent@faceprintpay.dev" 2>/dev/null || true
    git config user.name "DeployAgent" 2>/dev/null || true
    git add . -q
    git commit -m "🚀 Initial deploy: $proj" -q 2>/dev/null || true
  fi
  
  # Set remote
  REPO_NAME=$(basename "$REPO_DIR" | sed 's/[^a-zA-Z0-9]//g')
  git remote remove origin 2>/dev/null || true
  git remote add origin "https://github.com/$OWNER/$REPO_NAME.git" 2>/dev/null || true
  
  # Try to push
  if git push -u origin main --force -q 2>/dev/null; then
    echo "  ✅ Deployed: https://github.com/$OWNER/$REPO_NAME"
    DEPLOYED=$((DEPLOYED + 1))
  elif git push -u origin master --force -q 2>/dev/null; then
    echo "  ✅ Deployed: https://github.com/$OWNER/$REPO_NAME"
    DEPLOYED=$((DEPLOYED + 1))
  else
    echo "  ❌ Push failed (may need to create repo on GitHub first)"
    FAILED=$((FAILED + 1))
  fi
  
done

echo ""
echo "===================================="
echo "✅ DEPLOYMENT COMPLETE"
echo "   Deployed: $DEPLOYED"
echo "   Failed: $FAILED"
echo "===================================="
