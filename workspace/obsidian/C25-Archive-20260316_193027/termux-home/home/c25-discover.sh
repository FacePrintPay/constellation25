#!/data/data/com.termux/files/usr/bin/bash
echo "=== C25 DISCOVERY SCAN ==="
echo "Date: $(date)"
echo ""

echo "--- Candidate Directories ---"
for d in constellation-25 C25-MASTER constellation25 c25 github-repos; do
  [ -d ~/$d ] && echo "FOUND: ~/$d" || echo "miss:  ~/$d"
done

echo ""
echo "--- Git Remotes Found ---"
find ~ -maxdepth 4 -name ".git" 2>/dev/null | while read g; do
  dir=$(dirname "$g")
  remote=$(git -C "$dir" remote get-url origin 2>/dev/null || echo "no remote")
  echo "$dir → $remote"
done

echo ""
echo "--- Key Files ---"
find ~ -maxdepth 5 -name "server.js" -o -name "mcp*.js" -o -name "pathos*.py" -o -name "ollama*" 2>/dev/null | grep -v node_modules

echo ""
echo "--- Ports In Use ---"
for p in 3000 3001 3005 5000; do
  lsof -i :$p 2>/dev/null | grep LISTEN && echo "port $p: ACTIVE" || echo "port $p: free"
done

echo ""
echo "=== DONE - paste output above ==="
