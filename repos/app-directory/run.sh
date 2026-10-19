#!/data/data/com.termux/files/usr/bin/bash
echo "🌟 app-directory"
curl -s http://localhost:3000/api/proxy > /dev/null && echo "✅ PATHOS"
echo "[app-directory] $(date)" >> "/data/data/com.termux/files/home/sovereign_gtp/logs/app-directory.log"
