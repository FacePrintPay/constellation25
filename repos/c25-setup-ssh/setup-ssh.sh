#!/data/data/com.termux/files/usr/bin/bash
# --- STEP 1: Ensure SSH key exists ---
SSH_KEY="$HOME/.ssh/id_ed25519"
if [ ! -f "$SSH_KEY" ]; then
  echo "🔐 Generating new SSH key for GitHub..."
  mkdir -p ~/.ssh
  ssh-keygen -t ed25519 -C "cygel.co@gmail.com" -f "$SSH_KEY" -N ""
  echo -e "\n🔑 Your public key (add this to GitHub → Settings → SSH Keys):"
  cat "${SSH_KEY}.pub"
  echo -e "\n🌐 Go add it NOW at: https://github.com/settings/keys\n"
  read -p "Press ENTER after you've added the key to GitHub..."
fi
# --- STEP 2: Define repo paths ---
REPOS=(
  "TheKre8tive/AiKre8tive-Stargate"
  "Kre8tive-Space/aikre8tive-planetary-grid"
  "FacePrintPay/PaThosAi"
  "TheKre8tive/AiKre8tive-ProofStack"
  "FacePrintPay/FacePrintPay"
  "FacePrintPay/Orange"
  "FacePrintPay/agentik"
  "FacePrintPay/AiKre8tive_Sovereign_Genesis"
)
# --- STEP 3: Convert remotes to SSH ---
echo "🔄 Converting remotes to SSH..."
cd ~/github
for rel_path in "${REPOS[@]}"; do
  if [ -d "$rel_path" ]; then
    cd "$rel_path"
    # Get current remote URL
    CURRENT=$(git remote get-url origin 2>/dev/null)
    if [[ "$CURRENT" == https://* ]]; then
      # Extract org/repo from path
      ORG_REPO=$(echo "$rel_path" | sed 's|/|/|')
      NEW_URL="git@github.com:${ORG_REPO}.git"
      echo "  ➤ $rel_path: $CURRENT → $NEW_URL"
      git remote set-url origin "$NEW_URL"
    else
      echo "  ➤ $rel_path: already using SSH or invalid"
    fi
    cd ~/github
  else
    echo "  ⚠️ Skipped (not found): $rel_path"
  fi
done
# --- STEP 4: Test GitHub SSH connection ---
echo -e "\n🧪 Testing GitHub SSH access..."
ssh -T git@github.com 2>&1 | grep -E "(successfully|Hi)" && \
  echo -e "✅ SUCCESS: Authenticated as FacePrintPay / Cygel!" || \
  echo -e "❌ FAILED: Check your SSH key on GitHub."
# --- FINAL INSTRUCTION ---
echo -e "\n🚀 Next: Re-run your clone script (or pull) — no more username prompts!"
