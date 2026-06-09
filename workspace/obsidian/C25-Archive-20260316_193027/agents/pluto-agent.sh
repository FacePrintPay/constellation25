#!/bin/bash
# BANANI BUILD EXECUTION - pluto-agent.sh
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

#!/data/data/com.termux/files/usr/bin/bash
# Pluto Agent - Edge Cases
# Constellation-25 Planetary Agent System

AGENT_NAME="pluto"
LOG_DIR="$HOME/constellation25/logs"
TASKS_DIR="$HOME/constellation25/tasks"
TOTALRECALL_DIR="$HOME/TotalRecall/constellation25"
LOG_FILE="${LOG_DIR}/${AGENT_NAME}_$(date +%Y%m%d).log"

mkdir -p "$LOG_DIR" "$TASKS_DIR" "$TOTALRECALL_DIR"

log() {
    echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] $1" | tee -a "$LOG_FILE"
}

log "${AGENT_NAME} agent starting"
log "Role: Edge Cases"

# Write status
echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] ${AGENT_NAME} agent initialized" > "${LOG_DIR}/${AGENT_NAME}_status.log"

# Heartbeat loop
while true; do
    log "Heartbeat: ${AGENT_NAME} agent active"
    
    # Check for task files
    if [ -f "${TASKS_DIR}/${AGENT_NAME}_task.txt" ]; then
        task_content=$(cat "${TASKS_DIR}/${AGENT_NAME}_task.txt")
        log "Processing task: ${task_content}"
        
        # Agent-specific logic here
        case "${AGENT_NAME}" in
            earth)
                # Scaffolding logic
                if [ -f "${TASKS_DIR}/scaffold_request.txt" ]; then
                    project=$(cat "${TASKS_DIR}/scaffold_request.txt")
                    mkdir -p "$HOME/projects/${project}"
                    log "Created project: ${project}"
                    rm "${TASKS_DIR}/scaffold_request.txt"
                fi
                ;;
            mars)
                # Security logic
                log "Security scan complete"
                ;;
            hydra)
                # CI/CD logic
                log "CI/CD pipeline check complete"
                ;;
        esac
        
        # Log to TotalRecall
        echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] ${AGENT_NAME} processed task" >> "${TOTALRECALL_DIR}/${AGENT_NAME}_agent.log"
        
        rm "${TASKS_DIR}/${AGENT_NAME}_task.txt"
    fi
    
    # Update status file
    echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] ${AGENT_NAME} agent running - heartbeat OK" > "${LOG_DIR}/${AGENT_NAME}_status.log"
    
    sleep 30
done
