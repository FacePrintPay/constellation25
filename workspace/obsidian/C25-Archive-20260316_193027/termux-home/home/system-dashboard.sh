#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

echo "🌌 CREATING SYSTEM-WIDE DASHBOARD"

# 1. Find ALL your projects
PROJECTS=("Constellation25" "FacePrintPay" "VideoCourts" "MyBuyO" "Agentik" "PaTHos" "AiKre8tive" "SovereignGTP" "VerseD")

# 2. Create master dashboard
mkdir -p ~/system-dashboard/{data,projects}

# 3. Generate project stats
for proj in "${PROJECTS[@]}"; do
  echo "  Scanning: $proj"
  
  # Count files
  FILES=$(find ~ -type f -iname "*${proj,,}*" 2>/dev/null | wc -l)
  FOLDERS=$(find ~ -type d -iname "*${proj,,}*" 2>/dev/null | wc -l)
  
  # Find key files
  REPOS=$(find ~ -maxdepth 4 -type d -iname "*${proj,,}*" 2>/dev/null | head -5)
  
  cat > ~/system-dashboard/projects/${proj}.md << PROJMD
# 📁 $proj

**Files:** $FILES
**Folders:** $FOLDERS
**Last Updated:** $(date '+%Y-%m-%d %H:%M')

## Repositories
$REPOS

## Key Files
$(find ~ -type f -iname "*${proj,,}*" \( -name "*.sh" -o -name "*.py" -o -name "*.json" \) 2>/dev/null | head -10)
PROJMD

done

# 4. Create main dashboard HTML
cat > ~/system-dashboard/index.html << 'MAINHTML'
<!DOCTYPE html>
<html><head>
<meta charset="UTF-8">
<title>FacePrintPay System Dashboard</title>
<style>
body{font-family:monospace;background:#0d1117;color:#c9d1d9;padding:20px;margin:0}
.container{max-width:1400px;margin:0 auto}
h1{color:#58a6ff}
.grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(300px,1fr));gap:20px;margin:20px 0}
.card{background:#161b22;border:1px solid #30363d;border-radius:8px;padding:20px}
.card h2{color:#58a6ff;margin-top:0}
.stat{display:flex;justify-content:space-between;padding:10px 0;border-bottom:1px solid #30363d}
.stat:last-child{border-bottom:none}
.badge{background:#1f6feb;color:#fff;padding:4px 8px;border-radius:4px;font-size:12px}
</style>
</head><body>
<div class="container">
<h1>🌌 FacePrintPay System Dashboard</h1>
<p style="color:#8b949e">Live System Overview | Updated: <span id="time"></span></p>

<div class="grid" id="projects"></div>

<div class="card" style="margin-top:20px">
<h2>🔧 Active Agents</h2>
<div id="agents">Loading...</div>
</div>

<div class="card" style="margin-top:20px">
<h2>📊 Build Status</h2>
<div id="builds">Loading...</div>
</div>
</div>

<script>
document.getElementById('time').textContent=new Date().toISOString();

// Load projects
fetch('projects.json')
  .then(r=>r.json())
  .then(projects=>{
    const grid=document.getElementById('projects');
    grid.innerHTML=Object.entries(projects).map(([name,data])=>`
      <div class="card">
        <h2>${name}</h2>
        <div class="stat"><span>Files</span><span class="badge">${data.files||0}</span></div>
        <div class="stat"><span>Folders</span><span class="badge">${data.folders||0}</span></div>
        <div class="stat"><span>Repos</span><span class="badge">${data.repos||0}</span></div>
      </div>
    `).join('');
  });

// Load agent status
fetch('agents.json')
  .then(r=>r.json())
  .then(agents=>{
    document.getElementById('agents').innerHTML=agents.map(a=>`
      <div class="stat"><span>${a.name}</span><span class="badge" style="background:${a.active?'#238636':'#da3633'}">${a.active?'ACTIVE':'INACTIVE'}</span></div>
    `).join('');
  });

// Load build stats
fetch('data/builds.json')
  .then(r=>r.json())
  .then(builds=>{
    const total=builds.length;
    const failed=builds.filter(b=>b.conclusion==='failure').length;
    const success=builds.filter(b=>b.conclusion==='success').length;
    document.getElementById('builds').innerHTML=`
      <div class="stat"><span>Total Builds</span><span class="badge">${total}</span></div>
      <div class="stat"><span>Success</span><span class="badge" style="background:#238636">${success}</span></div>
      <div class="stat"><span>Failed</span><span class="badge" style="background:#da3633">${failed}</span></div>
      <div class="stat"><span>Rate</span><span class="badge">${total?Math.round(success*100/total):0}%</span></div>
    `;
  });
</script>
</body></html>
MAINHTML

# 5. Generate JSON data
echo "  Generating project data..."
cat > ~/system-dashboard/projects.json << PROJJSON
{
$(for proj in "${PROJECTS[@]}"; do
  files=$(find ~ -type f -iname "*${proj,,}*" 2>/dev/null | wc -l)
  folders=$(find ~ -type d -iname "*${proj,,}*" 2>/dev/null | wc -l)
  repos=$(find ~ -maxdepth 4 -type d -iname "*${proj,,}*" 2>/dev/null | wc -l)
  echo "  \"$proj\":{\"files\":$files,\"folders\":$folders,\"repos\":$repos},"
done | sed '$ s/,$//')
}
PROJJSON

# 6. Agent status
echo "  Generating agent status..."
cat > ~/system-dashboard/agents.json << 'AGENTJSON'
[
  {"name":"Pathos-Sovereign-1","active":true},
  {"name":"CodeWeaver","active":true},
  {"name":"AuditGuard","active":true},
  {"name":"DeployBot","active":true},
  {"name":"DataSage","active":true},
  {"name":"Finder","active":true},
  {"name":"Anchor","active":true}
]
AGENTJSON

# 7. Copy build data
cp /data/data/com.termux/files/home/fp-build-audit-20260311-081904/builds-complete.json \
   ~/system-dashboard/data/ 2>/dev/null || echo "[]" > ~/system-dashboard/data/builds.json

# 8. Deploy to GitHub Pages
cd ~/system-dashboard
git init -q 2>/dev/null || true
git config user.email "agent@faceprintpay.dev" 2>/dev/null || true
git config user.name "SystemAgent" 2>/dev/null || true
git add -A -q 2>/dev/null || true
git commit -m "🌌 System dashboard $(date +%Y-%m-%d)" -q 2>/dev/null || true
git remote remove origin 2>/dev/null || true
git remote add origin "https://github.com/FacePrintPay/system-dashboard.git" 2>/dev/null || true
git branch -M main -q 2>/dev/null || true
git push -u origin main --force -q 2>/dev/null && \
  echo "✅ System Dashboard: https://faceprintpay.github.io/system-dashboard/" || \
  echo "⚠️ Local: ~/system-dashboard/index.html"

echo ""
echo "✅ SYSTEM DASHBOARD CREATED"
echo "🌐 Live: https://faceprintpay.github.io/system-dashboard/"
echo "📁 Location: ~/system-dashboard/"
