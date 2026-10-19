#!/data/data/com.termux/files/usr/bin/bash
# SOVEREIGN AI PROTOCOL - UNIFIED LAUNCHER
# Starts: Backend + ngrok + Cloudflare Tunnel
set -euo pipefail
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
RESET='\033[0m'
echo -e "${MAGENTA}╔════════════════════════════════════════════════════════╗${RESET}"
echo -e "${MAGENTA}║  🚀 Sovereign AI Protocol - Unified Launch Sequence  ║${RESET}"
echo -e "${MAGENTA}╚════════════════════════════════════════════════════════╝${RESET}"
# Kill existing processes
echo -e "${CYAN}🧹 Cleaning up existing processes...${RESET}"
pkill -f "node.*server.js" 2>/dev/null || true
pkill -f "cloudflared" 2>/dev/null || true
pkill -f "ngrok" 2>/dev/null || true
# Start backend
echo -e "${GREEN}✅ Starting backend server (ports 3000 & 8080)...${RESET}"
cd ~/sovereign/backend
node server.js > ~/sovereign/logs/backend.log 2>&1 &
BACKEND_PID=$!
sleep 2
# Start Cloudflare Tunnel
echo -e "${GREEN}🌐 Starting Cloudflare Tunnel...${RESET}"
cloudflared tunnel --url http://localhost:3000 > ~/sovereign/logs/tunnel.log 2>&1 &
CF_PID=$!
sleep 3
# Extract tunnel URL
CF_URL=$(grep -oP 'https://[a-z-]+\.trycloudflare\.com' ~/sovereign/logs/tunnel.log | head -1)
# Start ngrok (if configured)
if command -v ngrok &> /dev/null; then
  echo -e "${GREEN}🔗 Starting ngrok tunnel...${RESET}"
  ngrok http 3000 --log=stdout > ~/sovereign/logs/ngrok.log 2>&1 &
  NGROK_PID=$!
  sleep 2
  NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | jq -r '.tunnels[0].public_url' 2>/dev/null || echo "pending")
else
  NGROK_URL="not installed"
fi
# Display status
echo -e "${MAGENTA}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║           🎉 SOVEREIGN AI PROTOCOL IS LIVE! 🎉            ║"
echo "╠════════════════════════════════════════════════════════════╣"
echo "║  Local REST API:    http://localhost:3000                 ║"
echo "║  Local WebSocket:   ws://localhost:8080                   ║"
echo "║  Cloudflare Tunnel: ${CF_URL}"
echo "║  ngrok Tunnel:      ${NGROK_URL}"
echo "╠════════════════════════════════════════════════════════════╣"
echo "║  Plan ID:           52f7b763                              ║"
echo "║  Author:            Cygel White (#MrGGTP)                 ║"
echo "║  Website:           www.aimetaverse.cloud                 ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${RESET}"
echo -e "${CYAN}📊 Process IDs:${RESET}"
echo -e "  Backend PID: ${BACKEND_PID}"
echo -e "  Cloudflare PID: ${CF_PID}"
[ ! -z "${NGROK_PID:-}" ] && echo -e "  ngrok PID: ${NGROK_PID}"
echo -e "\n${YELLOW}📋 To stop all services:${RESET}"
echo -e "  pkill -f 'node.*server.js'; pkill -f cloudflared; pkill -f ngrok"
echo -e "\n${CYAN}📝 Logs:${RESET}"
echo -e "  Backend:    tail -f ~/sovereign/logs/backend.log"
echo -e "  Cloudflare: tail -f ~/sovereign/logs/tunnel.log"
echo -e "  ngrok:      tail -f ~/sovereign/logs/ngrok.log"
echo -e "\n${GREEN}🌌 System ready! Press Ctrl+C to stop watching logs...${RESET}\n"
# Follow backend logs
tail -f ~/sovereign/logs/backend.log
