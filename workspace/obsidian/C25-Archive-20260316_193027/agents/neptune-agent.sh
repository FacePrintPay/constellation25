#!/bin/bash
# BANANI BUILD EXECUTION - neptune-agent.sh
INTENT="/data/data/com.termux/files/home/Agentik/nlp2code/complete_intent.json"
[ -f "$INTENT" ] && echo "🎯 Loading: $(jq -r ".complete_intent.primary_goal" "$INTENT" 2>/dev/null)"


# 🔐 GITHUB TOKEN LOADING
load_github_token(){ local f="$HOME/.config/c25/secrets.env"; [[ -f "$f" ]] && source "$f" 2>/dev/null; export GITHUB_TOKEN="${GITHUB_TOKEN:-}"; [[ -z "$GITHUB_TOKEN" ]] && { echo "⚠️ No GITHUB_TOKEN" >&2; command -v termux-toast>/dev/null && termux-toast "GitHub auth missing" 2>/dev/null; return 1; }; return 0; }
git_auth_setup(){ git config --global credential.helper store 2>/dev/null; git config --global url."https://${GITHUB_TOKEN}@github.com/".insteadOf "https://github.com/" 2>/dev/null; }


# ═══════════════════════════════════════════════════════════════
# 🔐 GITHUB INTEGRATION (Fine-Grained PAT)
# Scopes: Contents(rw), Metadata(r), Actions(r)
# Token: $HOME/.config/c25/secrets.env (gitignored)
# ═══════════════════════════════════════════════════════════════

load_github_token() {
    local secret_file="$HOME/.config/c25/secrets.env"
    [[ -f "$secret_file" ]] && source "$secret_file" 2>/dev/null || true
    export GITHUB_TOKEN="${GITHUB_TOKEN:-}"
    if [[ -z "$GITHUB_TOKEN" ]]; then
        echo "⚠️  GITHUB_TOKEN not set" >&2
        command -v termux-toast >/dev/null && termux-toast "⚠️ GitHub auth missing" 2>/dev/null || true
        return 1
    fi
    return 0
}

git_auth_setup() {
    git config --global credential.helper store 2>/dev/null || true
    git config --global url."https://${GITHUB_TOKEN}@github.com/".insteadOf "https://github.com/" 2>/dev/null || true
}

#!/usr/bin/env bash
# 🌌 Neptune-Agent • Constellation 25 v3.0
# Architect: Cygel White (TotalRecall) • © 2026 Kre8tive Holdings • Commercial License • Not Open Source
AGENT_NAME="$(basename "$0" .sh)"
echo "🌌 ${AGENT_NAME^}-Agent: $*"
echo "✅ Status: Ready • Mock execution • $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "📦 Output: Agent '${AGENT_NAME}' processed: '$*'"
exit 0
