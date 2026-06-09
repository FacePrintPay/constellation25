#!/data/data/com.termux/files/usr/bin/bash
set -e

API_PORT=8000
SWARM_PORT=8001
WEB_PORT=8765

kill_port(){ pkill -f "$1" 2>/dev/null || true; }

kill_port "uvicorn.*8000"
kill_port "uvicorn.*8001"
kill_port "http.server 8765"

nohup python -m uvicorn keys_api:app --host 127.0.0.1 --port 8000 > ../../logs/keys.log 2>&1 &
nohup python -m uvicorn swarm_api:app --host 127.0.0.1 --port 8001 > ../../logs/swarm.log 2>&1 &
nohup python -m http.server 8765 --directory ../src/web > ../../logs/web.log 2>&1 &

echo "Running:"
echo "  Web   http://127.0.0.1:8765/index.html"
echo "  Keys  http://127.0.0.1:8000/health"
echo "  Swarm http://127.0.0.1:8001/swarm/status"
