#!/data/data/com.termux/files/usr/bin/bash
echo "🌟 ALL-FILES"
curl -s http://localhost:3000/api/proxy > /dev/null && echo "✅ PATHOS"
echo "[ALL-FILES] $(date)" >> "/data/data/com.termux/files/home/sovereign_gtp/logs/ALL-FILES.log"
