#!/data/data/com.termux/files/usr/bin/bash
echo "🌟 1111"
curl -s http://localhost:3000/api/proxy > /dev/null && echo "✅ PATHOS"
echo "[1111] $(date)" >> "/data/data/com.termux/files/home/sovereign_gtp/logs/1111.log"
