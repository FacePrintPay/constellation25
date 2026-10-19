#!/usr/bin/env bash
# ========================================================
# CONSTELLATION 25 - PROTOTYPE v2.0 (FULLY FIXED)
# Agent Detection + Claude Parsing + SSH Configure-Agent
# ========================================================
set -eo pipefail

C25_DIR="$HOME/.c25"
REPOS_DIR="$HOME/github-repos"
mkdir -p "$C25_DIR" "$REPOS_DIR/constellation25/agents" "$C25_DIR/keys"

# Colors
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; MAGENTA='\033[0;35m'; NC='\033[0m'

log() { echo -e "${CYAN}[$(date '+%H:%M:%S')]${NC} $1"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; }
agent() { log "🤖 $1"; }

# API Key Setup
setup_keys() {
  if [ ! -f "$C25_DIR/keys/claude_key" ]; then
    echo -e "${RED}⚠️  Claude API Key Required${NC}"
    echo "Get it: https://console.anthropic.com/settings/keys"
    echo -n "Paste key (sk-ant-...): "
    read -r key
    echo "$key" > "$C25_DIR/keys/claude_key"
    chmod 600 "$C25_DIR/keys/claude_key"
    success "Key saved"
  fi
  export ANTHROPIC_API_KEY=$(cat "$C25_DIR/keys/claude_key")
}

# Configure-Agent: SSH Setup
configure_ssh() {
  local repo_name="${1:-constellation25}"
  local github_user="${2:-Faceprintpay}"
  local key_path="$HOME/.ssh/c25_deploy_key"
  
  agent "Configure-Agent: Setting up SSH for $github_user/$repo_name"
  
  mkdir -p "$HOME/.ssh"
  
  if [ ! -f "$key_path" ]; then
    log "🔐 Generating Ed25519 SSH key..."
    ssh-keygen -t ed25519 -C "c25@$(hostname)" -f "$key_path" -N "" -q 2>/dev/null || {
      # Fallback if ssh-keygen fails
      log "⚠️ ssh-keygen failed, creating placeholder..."
      echo "PLACEHOLDER_KEY" > "$key_path"
    }
    chmod 600 "$key_path" 2>/dev/null || true
  fi
  
  echo ""
  echo -e "${MAGENTA}╔═══════════════════════════════════════════════════════════╗${NC}"
  echo -e "${MAGENTA}║  📋 ADD THIS KEY TO GITHUB (One-Time)                    ║${NC}"
  echo -e "${MAGENTA}╚═══════════════════════════════════════════════════════════╝${NC}"
  echo ""
  echo -e "${CYAN}1. Visit:${NC} https://github.com/settings/keys"
  echo -e "${CYAN}2. Click 'New SSH key'${NC}"
  echo -e "${CYAN}3. Paste this:${NC}"
  echo ""
  
  if [ -f "$key_path.pub" ]; then
    echo -e "${GREEN}$(cat "$key_path.pub")${NC}"
  else
    echo -e "${YELLOW}Public key not found. Run: ssh-keygen -y -f $key_path${NC}"
  fi
  
  echo ""
  echo -e "${YELLOW}⚠️  Press Enter after adding to GitHub...${NC}"
  read -r
  
  # Configure git remote
  local repo_path="$REPOS_DIR/$repo_name"
  if [ -d "$repo_path/.git" ]; then
    cd "$repo_path"
    git remote set-url origin "git@github.com:$github_user/$repo_name.git" 2>/dev/null || \
    git remote add origin "git@github.com:$github_user/$repo_name.git" 2>/dev/null || true
    success "Git remote configured for SSH"
  fi
  
  # Save config
  echo "{\"ssh_key\":\"$key_path\",\"repo\":\"$repo_name\"}" > "$C25_DIR/ssh_config.json"
  success "✅ Configure-Agent complete - SSH ready for auto-push"
}

# Call Claude API
call_claude() {
  local agent="$1"
  local task="$2"
  
  local response
  response=$(curl -s --max-time 45 \
    -H "x-api-key: $ANTHROPIC_API_KEY" \
    -H "content-type: application/json" \
    -H "anthropic-version: 2023-06-01" \
    -d "{
      \"model\": \"claude-sonnet-4-5-20250929\",
      \"max_tokens\": 1024,
      \"messages\": [{\"role\": \"user\", \"content\": \"You are $agent. Task: $task. Output ONLY code/commands. No explanations.\"}]
    }" \
    "https://api.anthropic.com/v1/messages" 2>&1)
  
  echo "$response"
}

# Parse Claude Response
parse_response() {
  local response="$1"
  local code=""
  
  # Try jq first
  if command -v jq &>/dev/null; then
    code=$(echo "$response" | jq -r '.content[0].text // empty' 2>/dev/null || true)
  fi
  
  # Fallback grep
  if [ -z "$code" ]; then
    code=$(echo "$response" | grep -oP '(?<="text":")[^"]*' 2>/dev/null | head -1 || true)
  fi
  
  # Final fallback
  if [ -z "$code" ]; then
    code=$(echo "$response" | sed -n 's/.*"text":\s*"\([^"]*\)".*/\1/p' | head -1 || true)
  fi
  
  echo "$code"
}

# Activate Any Agent
activate_agent() {
  local input="$1"
  
  # Extract agent name - FIXED regex
  local agent=""
  agent=$(echo "$input" | grep -oE '[A-Za-z]+-Agent' | head -1 || echo "")
  
  # Default to Scaffold-Agent if none found
  if [ -z "$agent" ]; then
    agent="Scaffold-Agent"
  fi
  
  log "🤖 Activating: $agent"
  
  # Special handler for Configure-Agent
  if [[ "$agent" == "Configure-Agent" ]]; then
    configure_ssh "constellation25" "Faceprintpay"
    return 0
  fi
  
  # Call Claude
  local response
  response=$(call_claude "$agent" "$input")
  
  # Parse response
  local code
  code=$(parse_response "$response")
  
  # Save output
  local output_file="$REPOS_DIR/constellation25/agents/${agent}_$(date +%s).sh"
  echo "$code" > "$output_file"
  
  success "Saved: $output_file"
  
  # Show preview
  echo -e "${YELLOW}━━━ Output Preview ━━━${NC}"
  if [ -n "$code" ]; then
    echo "$code" | head -30
  else
    echo -e "${RED}⚠️  No code generated. Raw response:${NC}"
    echo "$response" | head -c 500
  fi
  echo -e "${YELLOW}━━━ End Preview ━━━${NC}"
}

# Git Push
push_repo() {
  cd "$REPOS_DIR/constellation25"
  git init 2>/dev/null || true
  git add -A
  git commit -m "🤖 C25 Agent $(date '+%Y-%m-%d %H:%M:%S')" 2>/dev/null || true
  
  # Check for SSH config
  if [ -f "$C25_DIR/ssh_config.json" ]; then
    log "🔐 SSH configured - attempting push..."
    git push origin main 2>/dev/null || git push origin master 2>/dev/null || true
  else
    log "📦 Commit ready (run Configure-Agent for auto-push)"
  fi
}

# Banner
banner() {
  clear
  echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
  echo -e "${CYAN}║   🌌 CONSTELLATION 25 - PROTOTYPE v2.0 (FIXED)          ║${NC}"
  echo -e "${CYAN}║      Mention any Agent to activate it                    ║${NC}"
  echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
  echo ""
  echo -e "${GREEN}Available Agents:${NC}"
  echo "  • Scaffold-Agent  - Generate code/projects"
  echo "  • Secure-Agent    - Scan for vulnerabilities"
  echo "  • Configure-Agent - Setup SSH for auto-push"
  echo "  • Deploy-Agent    - Push to GitHub"
  echo "  • Parse-Agent     - Analyze code"
  echo ""
  echo -e "${YELLOW}Type 'quit' to exit${NC}"
  echo ""
}

# Main Loop
main() {
  banner
  setup_keys
  
  while true; do
    echo -ne "${CYAN}🌌 You > ${NC}"
    read -r cmd
    
    [ "$cmd" = "quit" ] && break
    [ -z "$cmd" ] && continue
    
    activate_agent "$cmd"
    push_repo
    echo ""
  done
  
  success "Session complete. Check ~/github-repos/constellation25/agents/"
}

main
