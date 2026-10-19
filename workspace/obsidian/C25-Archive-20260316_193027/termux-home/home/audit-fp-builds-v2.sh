#!/bin/bash
# FacePrintPay Build Audit v2 - Fixed & Working
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

OWNER="${GITHUB_USER:-FacePrintPay}"
OUTPUT_DIR="${HOME}/fp-build-audit-$(date +%Y%m%d-%H%M%S)"
REPORT_FILE="$OUTPUT_DIR/BUILD_REPORT.md"
JSON_REPORT="$OUTPUT_DIR/builds-complete.json"
FAILURES_FILE="$OUTPUT_DIR/failures.txt"

mkdir -p "$OUTPUT_DIR"

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  FacePrintPay Build Audit v2               ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

# Check gh CLI
if ! command -v gh &>/dev/null; then
  echo -e "${RED}❌ gh CLI not found. Install: pkg install gh${NC}"
  exit 1
fi

# === FETCH REPOS ===
echo -e "${CYAN}📚 Phase 1: Discovering repositories...${NC}"
gh repo list "$OWNER" --json name,url,isPrivate --limit 1000 > "$OUTPUT_DIR/repos.json" 2>/dev/null || {
  echo -e "${RED}❌ Failed to fetch repos. Run: gh auth login${NC}"
  exit 1
}
REPO_COUNT=$(jq 'length' "$OUTPUT_DIR/repos.json")
echo -e "${GREEN}✅ Found $REPO_COUNT repositories${NC}"

# === FETCH ALL BUILDS ===
echo -e "${CYAN}📋 Phase 2: Analyzing builds...${NC}"
echo "[]" > "$JSON_REPORT"
> "$FAILURES_FILE"

while IFS= read -r repo; do
  [ -z "$repo" ] && continue
  
  RUNS_FILE="$OUTPUT_DIR/runs-$repo.json"
  if ! gh run list --repo "$OWNER/$repo" --json status,name,conclusion,startedAt,headBranch,headSha --limit 100 > "$RUNS_FILE" 2>/dev/null; then
    echo "❌ Error fetching runs for $repo" >> "$FAILURES_FILE"
    continue
  fi
  
  if ! jq empty "$RUNS_FILE" 2>/dev/null; then
    echo "❌ Invalid JSON from $repo" >> "$FAILURES_FILE"
    continue
  fi
  
  RUNS=$(jq 'length' "$RUNS_FILE")
  [ "$RUNS" -eq 0 ] && continue
  
  echo -ne "${CYAN}  🔍 $repo ($RUNS builds)${NC}\r"
  
  # Process each run
  jq -c '.[]' "$RUNS_FILE" | while read -r run; do
    STATUS=$(echo "$run" | jq -r '.status // "unknown"')
    CONCLUSION=$(echo "$run" | jq -r '.conclusion // "unknown"')
    NAME=$(echo "$run" | jq -r '.name // "unnamed"')
    STARTED=$(echo "$run" | jq -r '.startedAt // "unknown"')
    BRANCH=$(echo "$run" | jq -r '.headBranch // "unknown"')
    SHA=$(echo "$run" | jq -r '.headSha // "unknown"' | cut -c1-7)
    
    BUILD_ENTRY="{\"repo\":\"$repo\",\"workflow\":\"$NAME\",\"status\":\"$STATUS\",\"conclusion\":\"$CONCLUSION\",\"branch\":\"$BRANCH\",\"sha\":\"$SHA\",\"started\":\"$STARTED\"}"
    
    jq --argjson entry "$BUILD_ENTRY" '. += [$entry]' "$JSON_REPORT" > "$JSON_REPORT.tmp" && mv "$JSON_REPORT.tmp" "$JSON_REPORT"
    
    if [ "$CONCLUSION" = "failure" ]; then
      echo "❌ [$repo] $NAME - FAILED on $BRANCH" >> "$FAILURES_FILE"
    fi
    if [ "$STATUS" = "queued" ]; then
      echo "⏳ [$repo] $NAME - QUEUED on $BRANCH" >> "$FAILURES_FILE"
    fi
  done
done < <(jq -r '.[].name' "$OUTPUT_DIR/repos.json")

echo ""

# Count from JSON
TOTAL_BUILDS=$(jq 'length' "$JSON_REPORT")
SUCCESS_BUILDS=$(jq '[.[] | select(.conclusion == "success")] | length' "$JSON_REPORT")
FAILED_BUILDS=$(jq '[.[] | select(.conclusion == "failure")] | length' "$JSON_REPORT")
QUEUED_BUILDS=$(jq '[.[] | select(.status == "queued")] | length' "$JSON_REPORT")

SUCCESS_RATE=0
[ "$TOTAL_BUILDS" -gt 0 ] && SUCCESS_RATE=$(( SUCCESS_BUILDS * 100 / TOTAL_BUILDS ))

echo -e "${GREEN}✅ Analyzed $TOTAL_BUILDS builds across $REPO_COUNT repos${NC}"

# === GENERATE REPORT ===
echo -e "${CYAN}📄 Phase 3: Generating report...${NC}"

cat > "$REPORT_FILE" << EOF
# 🔧 FacePrintPay Build Audit Report
**Generated:** $(date '+%Y-%m-%d %H:%M:%S')
**Scanned:** $TOTAL_BUILDS builds across $REPO_COUNT repositories

## 📊 Executive Summary
| Metric | Count | Percentage |
|--------|-------|-----------|
| **Total Builds** | $TOTAL_BUILDS | 100% |
| **✅ Successful** | $SUCCESS_BUILDS | ${SUCCESS_RATE}% |
| **❌ Failed** | $FAILED_BUILDS | $(( FAILED_BUILDS * 100 / (TOTAL_BUILDS + 1) ))% |
| **⏳ Queued** | $QUEUED_BUILDS | $(( QUEUED_BUILDS * 100 / (TOTAL_BUILDS + 1) ))% |

## 🚨 Critical Issues
\`\`\`
$(cat "$FAILURES_FILE" 2>/dev/null || echo "None")
\`\`\`

## 🔍 Debug Commands
\`\`\`bash
gh run view <RUN_ID> --repo $OWNER/<REPO> --log
gh run rerun <RUN_ID> --repo $OWNER/<REPO>
\`\`\`
EOF

echo -e "${GREEN}✅ Report saved: $REPORT_FILE${NC}"

# === CREATE HTML DASHBOARD ===
echo -e "${CYAN}🌐 Phase 4: Creating dashboard...${NC}"

cat > "$OUTPUT_DIR/index.html" << 'HTMLEOF'
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>FacePrintPay Build Dashboard</title>
<style>
body{font-family:monospace;background:#0d1117;color:#c9d1d9;padding:20px}
.card{background:#161b22;border:1px solid #30363d;border-radius:6px;padding:15px;margin:10px 0}
.success{color:#3fb950}.failed{color:#f85149}.warning{color:#d29922}
table{width:100%;border-collapse:collapse}
th,td{padding:10px;text-align:left;border-bottom:1px solid #30363d}
th{color:#58a6ff}
</style>
</head>
<body>
<h1>🔧 FacePrintPay Build Dashboard</h1>
<div id="stats"></div>
<div class="card"><h2>Failed Builds</h2><table id="failures"><thead><tr><th>Repo</th><th>Workflow</th><th>Status</th><th>Branch</th></tr></thead><tbody></tbody></table></div>
<script>
fetch('builds-complete.json').then(r=>r.json()).then(builds=>{
const stats={total:builds.length,success:builds.filter(b=>b.conclusion==='success').length,failed:builds.filter(b=>b.conclusion==='failure').length};
document.getElementById('stats').innerHTML='<div class="card"><h3>Summary</h3><p class="success">✅ Success: '+stats.success+'</p><p class="failed">❌ Failed: '+stats.failed+'</p><p>Total: '+stats.total+'</p></div>';
const tbody=document.getElementById('failures').querySelector('tbody');
builds.filter(b=>b.conclusion==='failure').forEach(b=>{
tbody.innerHTML+='<tr><td>'+b.repo+'</td><td>'+b.workflow+'</td><td class="failed">FAILED</td><td>'+b.branch+'</td></tr>';
});
});
</script>
</body>
</html>
HTMLEOF

echo -e "${GREEN}✅ Dashboard saved: $OUTPUT_DIR/index.html${NC}"

# === SUMMARY ===
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║          ✅ AUDIT COMPLETE                 ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}📁 Output:${NC} $OUTPUT_DIR"
echo -e "${CYAN}📊 Summary:${NC}"
echo -e "  • Repositories: ${GREEN}$REPO_COUNT${NC}"
echo -e "  • Total Builds: ${GREEN}$TOTAL_BUILDS${NC}"
echo -e "  • Successful: ${GREEN}$SUCCESS_BUILDS${NC}"
echo -e "  • Failed: ${RED}$FAILED_BUILDS${NC}"
echo -e "  • Success Rate: ${GREEN}${SUCCESS_RATE}%${NC}"
echo ""
echo -e "${CYAN}🚀 Next Steps:${NC}"
echo -e "  ${YELLOW}cat $REPORT_FILE${NC}"
echo -e "  ${YELLOW}open $OUTPUT_DIR/index.html${NC}"
echo ""
