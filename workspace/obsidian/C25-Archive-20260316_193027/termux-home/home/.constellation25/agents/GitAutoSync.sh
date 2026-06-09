#!/bin/bash
# BANANI BUILD EXECUTION - GitAutoSync.sh
INTENT="/data/data/com.termux/files/home/Agentik/nlp2code/complete_intent.json"
[ -f "$INTENT" ] && echo "🎯 Loading: $(jq -r ".complete_intent.primary_goal" "$INTENT" 2>/dev/null)"

#!/data/data/com.termux/files/usr/bin/bash
C25="$HOME/.constellation25"
cd "$C25" || exit 1

echo "[GitAutoSync] Starting..."

# Try to get PAT from clipboard (user copies PAT once before running)
if command -v termux-clipboard-get &>/dev/null; then
  CLIP=$(termux-clipboard-get 2>/dev/null | tr -d '\n\r')
  if [[ "$CLIP" =~ ^ghp_[A-Za-z0-9]{36,} ]]; then
    echo "  ✅ PAT found in clipboard"
    git remote set-url origin https://faceprintpay:${CLIP}@github.com/FacePrintPay/constellation25.git
  fi
fi

# Check if remote has PAT embedded
REMOTE=$(git config --get remote.origin.url 2>/dev/null)
if [[ "$REMOTE" =~ faceprintpay:ghp_ ]]; then
  echo "  ✅ Auth configured in remote URL"
else
  echo "  ⚠️ No PAT in remote URL"
  echo "  💡 Copy your PAT to clipboard, then run: git remote set-url origin https://faceprintpay:\$PAT@github.com/FacePrintPay/constellation25.git"
fi

# Enable credential helper for fallback
git config --global credential.helper store 2>/dev/null

# Do the sync
echo "[GitAutoSync] Checking changes..."
git add -A 2>/dev/null
if git diff --cached --quiet; then
  echo "  📭 No changes to commit"
else
  git commit -m "Auto-sync: $(date '+%Y-%m-%d %H:%M')" 2>/dev/null && echo "  ✅ Committed"
fi

# Push with verbose error output
echo "[GitAutoSync] Pushing..."
if git push -v origin master 2>&1 | tee /tmp/push.log | grep -q "Successfully"; then
  echo "  ✅ Pushed to GitHub"
  command -v termux-notification &>/dev/null && termux-notification -t "C25 Sync" -c "✅ Pushed" 2>/dev/null
else
  echo "  ❌ Push failed — checking error:"
  grep -E "error:|fatal:|Authentication" /tmp/push.log | tail -3
  command -v termux-notification &>/dev/null && termux-notification -t "C25 Sync" -c "❌ Push failed" 2>/dev/null
fi

echo "[GitAutoSync] Done"
