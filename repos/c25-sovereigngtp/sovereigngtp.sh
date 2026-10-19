#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RESET='\033[0m'
echo -e "${CYAN}🌌 SOVEREIGNGTP FULL STACK DEPLOYMENT${RESET}"
echo "Author: Cygel White (#MrGGTP)"
echo "Build: CygNus • Plan ID: 52f7b763"
echo
PROJECT="$HOME/sovereigngtp"
mkdir -p "$PROJECT/assets" "$PROJECT/docs"
echo -e "${CYAN}📦 Installing Termux dependencies...${RESET}"
pkg install -y nodejs git cloudflared
cat > "$PROJECT/WHITEPAPER.md" <<'WP'
# SovereignGTP
A mobile-native, creator-owned AI runtime running entirely in Termux.
No cloud. No vendor lock-in. You own the stack.
WP
cat > "$PROJECT/README.md" <<'RM'
# SovereignGTP
Everything lives in:
~/sovereigngtp
RM
echo -e "${GREEN}✅ SovereignGTP deployed to $PROJECT${RESET}"
