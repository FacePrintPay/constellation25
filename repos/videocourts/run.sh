#!/data/data/com.termux/files/usr/bin/bash
echo "🌟 VideoCourts"
curl -s http://localhost:3000/api/proxy > /dev/null && echo "✅ PATHOS"
echo "[VideoCourts] $(date)" >> "/data/data/com.termux/files/home/sovereign_gtp/logs/VideoCourts.log"
