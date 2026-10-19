#!/data/data/com.termux/files/usr/bin/bash
echo "🌟 aimetaverse-demo"
curl -s http://localhost:3000/api/proxy > /dev/null && echo "✅ PATHOS"
echo "[aimetaverse-demo] $(date)" >> "/data/data/com.termux/files/home/sovereign_gtp/logs/aimetaverse-demo.log"
