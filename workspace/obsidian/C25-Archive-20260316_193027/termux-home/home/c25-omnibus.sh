#!/usr/bin/env bash
# ========================================================
# CONSTELLATION 25 - YESQUIDPRO OMNIBUS PROTOCOL v3.0
# Termux-Native • Ollama-Only • Zero External Dependencies
# Pathos-Sovereign-1 Core • Debug-Optimized
# ========================================================
set -eo pipefail

# Directories
C25="$HOME/.c25"
REPOS="$HOME/github-repos"
mkdir -p "$C25" "$REPOS/constellation25/agents"

# Colors (Termux-safe)
CYAN='\033[0;36m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
log() { echo -e "${CYAN}[$(date '+%H:%M:%S')]${NC} $1"; }
ok() { echo -e "${GREEN}✅ $1${NC}"; }

# YesQuidpro Omnibus: Setup Routine
omnibus_setup() {
  log "🌀 YesQuidpro Omnibus Protocol: Initializing..."
  
  # Install Ollama if missing
  if ! command -v ollama &>/dev/null; then
    log "📦 Installing Ollama..."
    if command -v pkg &>/dev/null; then
      pkg install curl -y 2>/dev/null || true
    fi
    curl -fsSL https://ollama.com/install.sh 2>/dev/null | sh || {
      log "${YELLOW}⚠️ Auto-install failed. Run manually:${NC}"
      log "  curl -fsSL https://ollama.com/install.sh | sh"
      return 1
    }
  fi
  
  # Pull codellama (lightweight, fast)
  if ! ollama list 2>/dev/null | grep -q codellama; then
    log "🤖 Pulling codellama model..."
    ollama pull codellama 2>/dev/null || ollama pull llama3.2 2>/dev/null
  fi
  
  ok "Omnibus runtime ready"
}

# Configure-Agent: SSH (YesQuidpro Secure Channel)
omnibus_configure() {
  local repo="${1:-constellation25}"
  local user="${2:-Faceprintpay}"
  local key="$HOME/.ssh/c25_omnibus_key"
  
  log "🔐 Omnibus Secure Channel: $user/$repo"
  mkdir -p "$HOME/.ssh"
  
  # Generate key if missing
  if [ ! -f "$key" ]; then
    ssh-keygen -t ed25519 -C "omnibus@$(hostname)" -f "$key" -N "" -q 2>/dev/null || {
      # Fallback for Termux without full ssh-keygen
      echo "OMNIBUS_KEY_$(date +%s)" > "$key"
      chmod 600 "$key"
    }
  fi
  
  # Show public key
  echo ""
  echo -e "${YELLOW}📋 GitHub SSH Key Setup${NC}"
  echo "URL: https://github.com/settings/keys"
  echo "Key:"
  if [ -f "$key.pub" ]; then
    cat "$key.pub"
  else
    echo "# Key generated: $key (add manually to GitHub)"
  fi
  echo ""
  echo -e "${YELLOW}Press Enter after adding to GitHub...${NC}"
  read -r
  
  # Configure git remote
  local path="$REPOS/$repo"
  mkdir -p "$path" && cd "$path"
  git init 2>/dev/null || true
  git remote set-url origin "git@github.com:$user/$repo.git" 2>/dev/null || \
  git remote add origin "git@github.com:$user/$repo.git" 2>/dev/null || true
  
  # Save config
  echo "{\"repo\":\"$repo\",\"user\":\"$user\",\"key\":\"$key\"}" > "$C25/omnibus_ssh.json"
  ok "Omnibus Secure Channel active"
}

# Agent Code Generation (Ollama Direct)
omnibus_generate() {
  local agent="$1"
  local task="$2"
  
  log "🤖 $agent [Ollama-local]"
  
  # Direct ollama call - no JSON wrapping, no escaping issues
  ollama run codellama "You are $agent. Task: $task. Output ONLY code or bash. No explanations." 2>/dev/null || \
  ollama run llama3.2 "You are $agent. Task: $task. Output ONLY code. No markdown." 2>/dev/null || \
  echo "# Fallback: $agent generated placeholder for: $task"
}

# Activate Any Agent
omnibus_activate() {
  local input="$1"
  
  # Extract agent name (robust regex)
  local agent=$(echo "$input" | grep -oE '[A-Za-z]+-Agent' | head -1)
  [ -z "$agent" ] && agent="Scaffold-Agent"
  
  log "🌀 Activating: $agent"
  
  # Special handler: Configure-Agent
  if [[ "$agent" == "Configure-Agent" ]]; then
    omnibus_configure "constellation25" "Faceprintpay"
    return 0
  fi
  
  # Generate code
  local code=$(omnibus_generate "$agent" "$input")
  
  # Save to file
  local file="$REPOS/constellation25/agents/${agent}_$(date +%s).sh"
  echo "$code" > "$file"
  ok "Saved: $file"
  
  # Preview (first 20 lines)
  echo -e "${YELLOW}━━━ Preview ━━━${NC}"
  echo "$code" | head -20
  echo -e "${YELLOW}━━━ End ━━━${NC}"
}

# Git Push (Omnibus Sync)
omnibus_push() {
  cd "$REPOS/constellation25" 2>/dev/null || return
  git add -A 2>/dev/null || true
  git commit -m "🌀 Omnibus: $(date '+%H:%M')" 2>/dev/null || true
  
  # Push if SSH configured
  if [ -f "$C25/omnibus_ssh.json" ]; then
    git push origin main 2>/dev/null || git push origin master 2>/dev/null || true
  fi
}

# Terminal Loop (YesQuidpro Input Handler)
omnibus_loop() {
  log "🌀 YesQuidpro Omnibus: Ready"
  echo -e "${GREEN}Agents:${NC} Scaffold Secure Configure Deploy Parse"
  echo -e "${YELLOW}Commands:${NC} 'quit' to exit • Mention agent to activate${NC}"
  echo ""
  
  while true; do
    printf "${CYAN}🌌 Omnibus > ${NC}"
    read -r cmd  # Simple read - no -e flag for Termux compatibility
    
    # Exit conditions
    [[ "$cmd" == "quit" || "$cmd" == "exit" ]] && break
    [[ -z "$cmd" ]] && continue
    
    # Process command
    omnibus_activate "$cmd"
    omnibus_push
    echo ""
  done
  
  ok "Omnibus session complete"
}

# Banner
omnibus_banner() {
  clear
  echo -e "${CYAN}╔════════════════════════════════════════════════╗${NC}"
  echo -e "${CYAN}║ 🌀 CONSTELLATION 25 • YESQUIDPRO OMNIBUS v3.0 ║${NC}"
  echo -e "${CYAN}║ Termux-Native • Ollama-Only • Debug-Optimized ║${NC}"
  echo -e "${CYAN}╚════════════════════════════════════════════════╝${NC}"
  echo ""
}

# Main Entry
main() {
  omnibus_banner
  omnibus_setup || { log "${YELLOW}⚠️ Setup incomplete, continuing...${NC}"; }
  omnibus_loop
}

main
