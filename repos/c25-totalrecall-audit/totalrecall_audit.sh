#!/usr/bin/env bash
set -euo pipefail
# ============================================
# TotalRecall Overlap Auditor (local forensic)
# ============================================
# What it does:
# - Takes your ChatGPT export JSON (or any conversations.json)
# - Extracts text, normalizes it
# - Creates shingles (N-word sequences)
# - Scans a directory of "platform texts" for overlaps
# - Produces evidence outputs: report.md + hits.csv + hashes
#
# What it does NOT do:
# - It does not prove intent or "theft"
# - It only finds textual overlap and similarity signals
# ---------- Config defaults ----------
SHINGLE_N="${SHINGLE_N:-8}"          # 8-word shingles (tune: 6-12)
MIN_HITS_PER_FILE="${MIN_HITS_PER_FILE:-3}"
MAX_HITS_PER_FILE="${MAX_HITS_PER_FILE:-50}"
OUTDIR="${OUTDIR:-TotalRecall_Audit_$(date +%Y%m%d_%H%M%S)}"
# ---------- Args ----------
if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <chat_export.json> <platform_text_dir>"
  echo ""
  echo "Example:"
  echo "  $0 ~/Downloads/conversations.json ~/Downloads/platform_texts"
  echo ""
  echo "Env overrides:"
  echo "  SHINGLE_N=10 MIN_HITS_PER_FILE=5 OUTDIR=MyAuditRun $0 ..."
  exit 1
fi
CHAT_JSON="$1"
PLATFORM_DIR="$2"
if [[ ! -f "$CHAT_JSON" ]]; then
  echo "❌ Chat export JSON not found: $CHAT_JSON"
  exit 1
fi
if [[ ! -d "$PLATFORM_DIR" ]]; then
  echo "❌ Platform text directory not found: $PLATFORM_DIR"
  exit 1
fi
mkdir -p "$OUTDIR"/{extracted,platform_index,results,hashes}
echo "✅ OUTDIR: $OUTDIR"
echo "✅ SHINGLE_N: $SHINGLE_N"
echo "✅ Chat JSON: $CHAT_JSON"
echo "✅ Platform dir: $PLATFORM_DIR"
echo ""
# ---------- Helper: normalize text ----------
# lowercases, collapses whitespace, strips most punctuation (keeps letters/numbers/spaces)
normalize_py='
import re, sys
txt = sys.stdin.read()
txt = txt.lower()
txt = re.sub(r"[^a-z0-9\s]+", " ", txt)
txt = re.sub(r"\s+", " ", txt).strip()
print(txt)
'
# ---------- 1) Extract chat text ----------
echo "🧾 Extracting chat text…"
# Handles typical OpenAI exports where messages live in mapping.*.message.content.parts[]
# If your JSON structure differs, tell me and I'll adapt the jq.
jq -r '
  .. | objects
  | select(has("message"))
  | .message
  | select(.content? and .content.parts?)
  | .content.parts[]
  | strings
' "$CHAT_JSON" \
| python3 -c "$normalize_py" \
> "$OUTDIR/extracted/chat_all.txt"
CHAT_WORDS=$(wc -w < "$OUTDIR/extracted/chat_all.txt" | tr -d ' ')
echo "✅ Extracted chat_all.txt (${CHAT_WORDS} words)"
# ---------- 2) Shingle the chat ----------
echo "🧠 Building shingles (word sequences)…"
python3 - <<PY > "$OUTDIR/extracted/chat_shingles.txt"
import sys
n = int("${SHINGLE_N}")
words = open("${OUTDIR}/extracted/chat_all.txt","r",encoding="utf-8",errors="ignore").read().split()
seen=set()
out=[]
for i in range(0, max(0, len(words)-n+1)):
    sh=" ".join(words[i:i+n])
    if sh not in seen:
        seen.add(sh)
        out.append(sh)
open("${OUTDIR}/extracted/chat_shingles.txt","w",encoding="utf-8").write("\n".join(out))
print(f"shingles={len(out)}", file=sys.stderr)
PY
SHINGLES_COUNT=$(wc -l < "$OUTDIR/extracted/chat_shingles.txt" | tr -d ' ')
echo "✅ Shingles: $SHINGLES_COUNT"
# ---------- 3) Index platform texts (normalize) ----------
echo "📚 Indexing platform texts…"
# Collect common text-like files. Add extensions if you want.
# This avoids binary junk.
find "$PLATFORM_DIR" -type f \
  \( -iname "*.txt" -o -iname "*.md" -o -iname "*.html" -o -iname "*.json" -o -iname "*.log" -o -iname "*.csv" -o -iname "*.yml" -o -iname "*.yaml" \) \
  -print0 \
| while IFS= read -r -d '' f; do
    rel="${f#$PLATFORM_DIR/}"
    out="$OUTDIR/platform_index/${rel//\//__}.norm.txt"
    mkdir -p "$(dirname "$out")" 2>/dev/null || true
    cat "$f" | python3 -c "$normalize_py" > "$out"
  done
PLAT_COUNT=$(find "$OUTDIR/platform_index" -type f | wc -l | tr -d ' ')
echo "✅ Indexed files: $PLAT_COUNT"
# ---------- 4) Overlap scan ----------
echo "🔎 Scanning for overlaps… (this can take a bit if your set is huge)"
HITS_CSV="$OUTDIR/results/hits.csv"
echo "file,hit_count,example_hits" > "$HITS_CSV"
REPORT_MD="$OUTDIR/results/report.md"
cat > "$REPORT_MD" <<MD
# TotalRecall Overlap Audit Report
Run: $(date -Is)
Chat JSON: \`$CHAT_JSON\`
Platform Dir: \`$PLATFORM_DIR\`
Params:
- SHINGLE_N: $SHINGLE_N
- MIN_HITS_PER_FILE: $MIN_HITS_PER_FILE
- MAX_HITS_PER_FILE: $MAX_HITS_PER_FILE
**Important:** This report measures **textual overlap** only. It does **not** prove intent or misuse.
MD
# We'll search shingles via rg fixed-string (-F).
# To make this feasible, we sample shingles if extremely large.
SAMPLE_SHINGLES="$OUTDIR/extracted/chat_shingles_sample.txt"
if [[ "$SHINGLES_COUNT" -gt 20000 ]]; then
  echo "⚠️ Large shingle set ($SHINGLES_COUNT). Sampling 20000 to keep runtime sane."
  shuf -n 20000 "$OUTDIR/extracted/chat_shingles.txt" > "$SAMPLE_SHINGLES"
else
  cp "$OUTDIR/extracted/chat_shingles.txt" "$SAMPLE_SHINGLES"
fi
TOTAL_MATCH_FILES=0
for pf in "$OUTDIR"/platform_index/*.norm.txt; do
  # count hits by scanning for each shingle in the file
  # We do it efficiently by letting rg take a pattern file.
  # rg --fixed-strings --file <patternfile> <targetfile>
  hits=$(rg -F --file "$SAMPLE_SHINGLES" "$pf" 2>/dev/null | wc -l | tr -d ' ')
  if [[ "$hits" -ge "$MIN_HITS_PER_FILE" ]]; then
    TOTAL_MATCH_FILES=$((TOTAL_MATCH_FILES+1))
    # capture up to MAX_HITS_PER_FILE example lines for audit
    examples=$(rg -F --file "$SAMPLE_SHINGLES" "$pf" 2>/dev/null | head -n "$MAX_HITS_PER_FILE" | tr '\n' ' ' | sed 's/"/""/g')
    base=$(basename "$pf")
    echo "\"$base\",$hits,\"$examples\"" >> "$HITS_CSV"
  fi
done
echo "" >> "$REPORT_MD"
echo "## Summary" >> "$REPORT_MD"
echo "- Extracted chat words: $CHAT_WORDS" >> "$REPORT_MD"
echo "- Shingles (unique): $SHINGLES_COUNT" >> "$REPORT_MD"
echo "- Platform files indexed: $PLAT_COUNT" >> "$REPORT_MD"
echo "- Files meeting threshold: $TOTAL_MATCH_FILES" >> "$REPORT_MD"
echo "" >> "$REPORT_MD"
echo "## Results" >> "$REPORT_MD"
echo "See: \`hits.csv\` for per-file overlap counts and sample matches." >> "$REPORT_MD"
# ---------- 5) Hash everything ----------
echo "🔐 Hashing outputs for integrity…"
(
  cd "$OUTDIR"
  find . -type f -print0 | sort -z | xargs -0 sha256sum > "hashes/SHA256SUMS.txt"
)
echo "✅ Done."
echo "📄 Report: $OUTDIR/results/report.md"
echo "📊 CSV:    $OUTDIR/results/hits.csv"
echo "🔐 Hashes: $OUTDIR/hashes/SHA256SUMS.txt"
