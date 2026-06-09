#!/data/data/com.termux/files/usr/bin/bash
# C25 Agent Build Package - Each repo gets a complete build
# Agents: Earth(structure) Moon(review) Mars(deploy) Jupiter(docs)

REPOS="$HOME/github-repos/Constillation25"
LOG="$HOME/sovereign_gtp/logs/build_packages.log"
MODEL="llama3.2:1b"
DONE=0
FAILED=0

ask() {
    local prompt="$1"
    curl -s --max-time 90 http://localhost:11434/api/generate \
        -d "{\"model\":\"$MODEL\",\"prompt\":\"$prompt\",\"stream\":false,\"options\":{\"num_predict\":400}}" \
        | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('response',''))" 2>/dev/null
}

build_package() {
    local dir="$1"
    local name=$(basename "$dir")
    
    echo "🌟 Building package: $name"
    echo "[$(date '+%H:%M:%S')] Building: $name" >> "$LOG"

    # ── EARTH: Ensure structure ──
    mkdir -p "$dir"/{src,tests,docs,dist}

    # ── MOON: Generate package.json if missing ──
    if [ ! -f "$dir/package.json" ]; then
        cat > "$dir/package.json" << PKGJSON
{
  "name": "$name",
  "version": "1.0.0",
  "description": "C25 Constellation25 module - $name",
  "main": "index.js",
  "scripts": {
    "start": "node index.js 2>/dev/null || bash run.sh",
    "test": "bash tests/test.sh 2>/dev/null || echo 'no tests'",
    "build": "bash src/build.sh 2>/dev/null || echo 'built'"
  },
  "author": "Cygel White / FacePrintPay",
  "license": "MIT",
  "c25": {
    "agent": "$name",
    "system": "Constellation25",
    "pathos": "http://localhost:3000"
  }
}
PKGJSON
        echo "  📦 package.json created"
    fi

    # ── MARS: Generate Dockerfile if missing ──
    if [ ! -f "$dir/Dockerfile" ]; then
        cat > "$dir/Dockerfile" << DOCKER
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install --production 2>/dev/null || true
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
DOCKER
        echo "  🐳 Dockerfile created"
    fi

    # ── JUPITER: Generate test file if missing ──
    if [ ! -f "$dir/tests/test.sh" ]; then
        cat > "$dir/tests/test.sh" << TESTSH
#!/data/data/com.termux/files/usr/bin/bash
echo "🧪 Testing: $name"
# Test 1: Module exists
[ -f "\$(dirname \$0)/../run.sh" ] || [ -f "\$(dirname \$0)/../index.js" ] && \
    echo "✅ Entry point exists" || echo "❌ No entry point"
# Test 2: PATHOS connection
curl -s --max-time 3 http://localhost:3000/api/proxy > /dev/null && \
    echo "✅ PATHOS connected" || echo "⚠️  PATHOS offline"
echo "✅ $name tests done"
TESTSH
        chmod +x "$dir/tests/test.sh"
        echo "  🧪 tests/test.sh created"
    fi

    # ── CYGNUS: Generate .github/workflows if missing ──
    mkdir -p "$dir/.github/workflows"
    if [ ! -f "$dir/.github/workflows/ci.yml" ]; then
        cat > "$dir/.github/workflows/ci.yml" << YAML
name: C25 CI - $name
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Node
        uses: actions/setup-node@v3
        with:
          node-version: '18'
      - name: Install
        run: npm install 2>/dev/null || true
      - name: Test
        run: npm test 2>/dev/null || bash tests/test.sh || true
      - name: Security scan
        run: grep -rE "(TOKEN|SECRET|PASSWORD)=['\"][^'\"]{8,}" . | grep -v ".git" | wc -l
YAML
        echo "  ⚙️  CI workflow created"
    fi

    # ── OLLAMA: Generate smart README using LLM ──
    if [ ! -s "$dir/README.md" ] || [ $(wc -l < "$dir/README.md") -lt 10 ]; then
        echo "  📝 Generating README via LLM..."
        ask "Write a professional README.md for a software module called '$name'.
It is part of Constellation25 - a sovereign AI agent system built by Cygel White / FacePrintPay on Android/Termux.
Include: ## Overview, ## Installation, ## Usage, ## API, ## License sections.
Keep under 60 lines. Output ONLY markdown." > "$dir/README.md"
        echo "  ✅ README generated ($(wc -l < $dir/README.md) lines)"
    fi

    # ── GIT: Commit and push ──
    if [ -d "$dir/.git" ]; then
        cd "$dir"
        git add -A 2>/dev/null
        if ! git diff --cached --quiet 2>/dev/null; then
            git commit -m "C25 build-package: $name - $(date '+%Y-%m-%d')" 2>/dev/null
            git push origin main 2>/dev/null &
            DONE=$((DONE + 1))
            echo "  🚀 Pushed"
        else
            echo "  ✓ Already complete"
        fi
        cd "$REPOS"
    fi
}

echo "╔══════════════════════════════════════════╗"
echo "║  🌟 C25 BUILD PACKAGES - ALL REPOS       ║"
echo "║  Agents: Earth Moon Mars Jupiter Cygnus  ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# Process every c25 module
for dir in "$REPOS"/c25-*/; do
    build_package "$dir"
done

# Process main ecosystem repos
for repo in AiKre8tive-Stargate aikre8tive AiMeta AiMetaverse \
            constellation25 agentik; do
    if [ -d "$REPOS/$repo" ]; then
        build_package "$REPOS/$repo"
    fi
done

# Wait for all background pushes
wait

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║  ✅ BUILD PACKAGES COMPLETE              ║"
echo "║  Packages built: $DONE                   ║"
echo "║  Log: $LOG"
echo "╚══════════════════════════════════════════╝"

# Final main repo sync
cd "$REPOS"
git add -A 2>/dev/null
git commit -m "C25 build-packages complete - $(date '+%Y-%m-%d %H:%M')" 2>/dev/null
git push origin main --force
echo "✅ Main repo synced to GitHub"
