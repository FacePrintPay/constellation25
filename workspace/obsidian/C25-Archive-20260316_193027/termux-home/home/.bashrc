# Clean Termux bashrc - FacePrintPay Recovery
export PATH="$HOME:$HOME/.local/bin:$PATH"
export HISTFILE="$HOME/.bash_history"
export HISTSIZE=10000
export HISTFILESIZE=20000
PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias c25="tmux attach -t c25"
source /data/data/com.termux/files/home/constellation-25/pathfinder.sh

# C25 Master Aliases
alias c25='tmux attach -t c25'
alias recall='tmux attach -t recall'
alias c25m='cd ~/C25-MASTER && ranger'
alias c25v='cd ~/C25-Vault && ranger'
alias c25i='bash ~/constellation-25/c25_inventory.sh'
alias c25r='ranger ~/C25-MASTER'
alias pf='source ~/constellation-25/pathfinder.sh && c25_resolve'
alias memlog='sqlite3 ~/constellation-25/memoria.db "SELECT timestamp,agent,event,detail FROM logs ORDER BY id DESC LIMIT 20;"'
alias c25start='tmux kill-session -t c25 2>/dev/null; tmux new-session -d -s c25 "cd ~/constellation-25 && npm start" && tmux kill-session -t recall 2>/dev/null; tmux new-session -d -s recall "node ~/constellation-25/totalrecall_ws.js" && echo "C25 ONLINE"'

# ── C25 CONSTELLATION-25 ALIASES ──
alias pathos='cd /data/data/com.termux/files/home/pathos && node server.js'
alias agents='tail -f /data/data/com.termux/files/home/agent_logs/agent_$1_*.log 2>/dev/null || ls /data/data/com.termux/files/home/agent_logs/'
alias agents-all='tail -n 20 /data/data/com.termux/files/home/agent_logs/agent_*.log'
alias sync-agents='cp -r /data/data/com.termux/files/home/agent_logs /sdcard/c25_backup/logs_$(date +%Y%m%d_%H%M%S) && echo "✓ Logs backed up to SD card"'
alias c25-status='curl -s http://localhost:3000/agents | python3 -m json.tool 2>/dev/null || echo "Pathos not running — type: pathos"'
alias c25-log='cat /data/data/com.termux/files/home/agent_logs/swarm_master.log | tail -30'
alias c25-health='curl -s http://localhost:3000/health'
alias c25='bash /data/data/com.termux/files/home/c25_launch.sh'
export PATH="$HOME/.npm-global/bin:$PATH"
# ── END C25 ──

alias r='ranger'
export C25_STORAGE=/data/data/com.termux/files/home/storage
export C25_HOME=/data/data/com.termux/files/home

# C25 Secure Tokens
[ -f ~/.env.tokens ] && source ~/.env.tokens

# ═══════════════════════════════════════
# C25 PERSISTENT HOME - Auto-runs on terminal open
# ═══════════════════════════════════════
c25_home_old() {
    # Check PATHOS
    PATHOS=$(curl -s --max-time 2 http://localhost:3000/api/proxy 2>/dev/null)
    
    # Check Ollama  
    OLLAMA=$(curl -s --max-time 2 http://localhost:11434/api/tags 2>/dev/null | python3 -c "import sys,json; d=json.load(sys.stdin); print(len(d.get('models',[])), 'models')" 2>/dev/null)

    # Check battery
    BAT=$(termux-battery-status 2>/dev/null | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['percentage'],'%',d['status'])" 2>/dev/null)

    echo ""
    echo "╔══════════════════════════════════════════╗"
    echo "║     🌟 CONSTELLATION-25 · GREENSBORO     ║"
    echo "╠══════════════════════════════════════════╣"
    if [ -n "$PATHOS" ]; then
        echo "║  ✅ PATHOS    : ONLINE (port 3000)       ║"
    else
        echo "║  ❌ PATHOS    : OFFLINE                  ║"
    fi
    if [ -n "$OLLAMA" ]; then
        echo "║  ✅ OLLAMA    : $OLLAMA                ║"
    else
        echo "║  ❌ OLLAMA    : OFFLINE                  ║"
    fi
    echo "║  🔋 BATTERY   : $BAT                  ║"
    echo "║  📁 SANDBOX   : ~/C25-MASTER/sandbox    ║"
    echo "╠══════════════════════════════════════════╣"
    echo "║  COMMANDS:                               ║"
    echo "║  sandbox  → Ranger file browser         ║"
    echo "║  c25m     → C25 MASTER                  ║"
    echo "║  agents   → tail agent logs             ║"
    echo "║  gsync    → sync all GitHub repos       ║"
    echo "╚══════════════════════════════════════════╝"
    echo ""
}

# Run on every new terminal
c25_home

# Auto-start services if not running
if ! curl -s --max-time 1 http://localhost:3000/api/proxy > /dev/null 2>&1; then
    echo "⚡ Starting PATHOS..."
    tmux new-session -d -s pathos \
      "node ~/github-repos/Constillation25/sovereign_gtp/backend/server.js" 2>/dev/null
fi

if ! curl -s --max-time 1 http://localhost:11434 > /dev/null 2>&1; then
    echo "⚡ Starting Ollama..."
    ollama serve > /dev/null 2>&1 &
fi
alias autopush='bash ~/c25-autopush.sh'

# C25 Persistent Agents - auto-run on terminal start
if [ -z "$C25_AGENTS_STARTED" ]; then
    export C25_AGENTS_STARTED=1
    # Run Earth scaffold in background
    bash ~/c25-persistent-agents.sh earth > /dev/null 2>&1 &
    # Open Ranger in C25 sandbox
    alias sandbox='ranger ~/github-repos/Constillation25'
    alias agents='bash ~/c25-persistent-agents.sh all'
    alias earth='bash ~/c25-persistent-agents.sh earth'
    alias moon='bash ~/c25-persistent-agents.sh moon'
    alias fix='bash ~/c25-persistent-agents.sh moon'
    alias ship='bash ~/c25-persistent-agents.sh saturn'
fi
alias swarm='bash ~/c25-swarm-sync.sh'
alias gsync='bash ~/c25-swarm-sync.sh'

c25_home() {
    BAT=$(termux-battery-status 2>/dev/null | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['percentage'],'%',d['status'])" 2>/dev/null)
    echo ""
    echo "╔══════════════════════════════════════════╗"
    echo "║   🌟 CONSTELLATION-25 · GREENSBORO      ║"
    echo "╠══════════════════════════════════════════╣"
    for port in 3000 3001 3002 3003 3004 3005 11434; do
        name=$(case $port in 3000) echo "PATHOS    ";; 3001) echo "Dashboard ";; 3002) echo "Keys API  ";; 3003) echo "Swarm API ";; 3004) echo "MyBuyo    ";; 3005) echo "Dig Dollar";; 11434) echo "Ollama    ";; esac)
        result=$(curl -s --max-time 1 http://localhost:$port 2>/dev/null | head -c 5)
        [ -n "$result" ] && printf "║  ✅ %s: port %-4s            ║\n" "$name" "$port" || printf "║  ❌ %s: OFFLINE             ║\n" "$name"
    done
    echo "╠══════════════════════════════════════════╣"
    echo "║  🔋 BATTERY : $BAT"
    echo "╠══════════════════════════════════════════╣"
    echo "║  swarm → full sync  autopush → push all ║"
    echo "║  sandbox → Ranger   agents → run all    ║"
    echo "╚══════════════════════════════════════════╝"
}
alias checkpoint='bash ~/c25-backup-checkpoint.sh'
alias gsync='bash ~/c25-swarm-sync.sh'
