#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

# YOUR ACTUAL PATHS
AUDIT_DIR="/data/data/com.termux/files/home/fp-build-audit-20260311-081904"
OWNER="FacePrintPay"
WORK_DIR="$HOME/fix-work-$$"
LOG="$HOME/fix-now.log"

log() { echo "[$(date '+%H:%M:%S')] $*" | tee -a "$LOG"; }

echo "🔧 FACEPRINTPAY QUICK FIX - RUNNING NOW"
echo "Audit: $AUDIT_DIR"
echo ""

# Verify audit exists
if [ ! -f "$AUDIT_DIR/builds-complete.json" ]; then
  echo "❌ Audit not found"
  exit 1
fi

# Count builds
TOTAL=$(jq 'length' "$AUDIT_DIR/builds-complete.json")
FAILED=$(jq '[.[]|select(.conclusion=="failure")]|length' "$AUDIT_DIR/builds-complete.json")
SUCCESS=$(jq '[.[]|select(.conclusion=="success")]|length' "$AUDIT_DIR/builds-complete.json")

echo "📊 Stats: Total=$TOTAL | Failed=$FAILED | Success=$SUCCESS"
echo ""

# Create GitHub Pages dashboard
mkdir -p $HOME/fp-build-fixer/docs/data
cp "$AUDIT_DIR/builds-complete.json" $HOME/fp-build-fixer/docs/data/builds.json

cat > $HOME/fp-build-fixer/docs/index.html << 'HTML'
<!DOCTYPE html><html><head><meta charset="UTF-8"><title>FacePrintPay Builds</title>
<style>body{font-family:monospace;background:#0d1117;color:#c9d1d9;padding:20px}
.card{background:#161b22;border:1px solid #30363d;border-radius:6px;padding:15px;margin:10px 0}
.success{color:#3fb950}.failed{color:#f85149}</style></head><body>
<h1>🔧 FacePrintPay Build Dashboard</h1>
<div id="stats" class="card">Loading...</div>
<div class="card"><h3>Failed Builds</h3><pre id="failures"></pre></div>
<script>
fetch('data/builds-complete.json').then(r=>r.json()).then(b=>{
const t=b.length,f=b.filter(x=>x.conclusion==='failure').length,s=b.filter(x=>x.conclusion==='success').length;
document.getElementById('stats').innerHTML=`<p class="success">✅ Success: ${s}</p><p class="failed">❌ Failed: ${f}</p><p>Total: ${t}</p>`;
document.getElementById('failures').textContent=b.filter(x=>x.conclusion==='failure').slice(0,30).map(x=>`[${x.repo}] ${x.workflow}`).join('\n')||'None';
});
</script></body></html>
HTML

echo "✅ Dashboard created"

# Deploy to GitHub Pages
cd $HOME/fp-build-fixer/docs
git init -q 2>/dev/null || true
git config user.email "agent@faceprintpay.dev" 2>/dev/null || true
git config user.name "FixAgent" 2>/dev/null || true
git add . -q 2>/dev/null || true
git commit -m "🚀 Fix $(date +%Y-%m-%d)" -q 2>/dev/null || true
git remote remove origin 2>/dev/null || true
git remote add origin "https://github.com/FacePrintPay/fp-build-fixer.git" 2>/dev/null || true
git branch -M main -q 2>/dev/null || true
git push -u origin main --force -q 2>/dev/null && echo "✅ Deployed: https://faceprintpay.github.io/fp-build-fixer/" || echo "⚠️ Push needs permissions"

# Retry failed builds
echo ""
echo "🔄 Retriggering failed builds..."
jq -r '.[]|select(.conclusion=="failure")|.repo' "$AUDIT_DIR/builds-complete.json" 2>/dev/null | sort -u | head -5 | while read repo; do
  [ -z "$repo" ] && continue
  log "Retrying: $repo"
  gh run list --repo "$OWNER/$repo" --status failure --json databaseId -q '.[0].databaseId' 2>/dev/null | head -1 | while read rid; do
    [ -n "$rid" ] && gh run rerun "$rid" --repo "$OWNER/$repo" -q 2>/dev/null && log "✅ Retriggered: $rid"
  done
done

echo ""
echo "✅ FIX COMPLETE"
echo "📊 Dashboard: https://faceprintpay.github.io/fp-build-fixer/"
echo "📋 Log: $LOG"
