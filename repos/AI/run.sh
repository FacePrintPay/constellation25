#!/data/data/com.termux/files/usr/bin/bash
echo "🌟 AI"
curl -s http://localhost:3000/api/proxy > /dev/null && echo "✅ PATHOS"
echo "[AI] $(date)" >> "/data/data/com.termux/files/home/sovereign_gtp/logs/AI.log"
