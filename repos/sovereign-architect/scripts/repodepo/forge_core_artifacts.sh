#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

ROOT="$HOME/Kre8tiveKonceptz_RepoDepo"
ART="$ROOT/artifacts"
YES="$ART/01_yesquid_pathos/yesquid_all_in_one_persistent.sh"
STATE="$ART/02_state_management/build_state_manager.sh"
STATE_DIR="$ROOT/.state"
LOG_DIR="$ROOT/logs"
mkdir -p "$STATE_DIR" "$LOG_DIR"

# ----------------------------
# Artifact 1: YESQUID (real)
# ----------------------------
cat > "$YES" <<'YEOF'
#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

# YESQUID/PaTHos ALL-IN-ONE with PERSISTENT STATE (Termux-safe)
# RepoDepo integration: Kre8tiveKonceptz_RepoDepo

ROOT="${YESQUID_ROOT:-$HOME/Kre8tiveKonceptz_RepoDepo}"
STATE_DIR="$ROOT/.state"
LOG_DIR="$ROOT/logs"
OUT_DIR="$ROOT/data/yesquid_out"
CARVE_DIR="$OUT_DIR/carved"
INVENTORY="$OUT_DIR/inventory.tsv"
DEFAULT_SCAN_DIR="${YESQUID_SCAN_DIR:-$HOME/storage/shared}"

mkdir -p "$STATE_DIR" "$LOG_DIR" "$OUT_DIR" "$CARVE_DIR"

log(){ printf "[%s] %s\n" "$(date +'%F %T')" "$*" | tee -a "$LOG_DIR/yesquid.log" >/dev/null; }
die(){ log "ERROR: $*"; exit 1; }

need_bin(){
  command -v "$1" >/dev/null 2>&1 || die "Missing dependency: $1 (pkg install $1)"
}

# Lightweight deps only
need_bin find
need_bin sed
need_bin awk
need_bin sha256sum
need_bin wc
need_bin sort

hash_file(){ sha256sum "$1" | awk '{print $1}'; }

# Inventory: tsv fields:
# sha256  bytes  mtime_epoch  path
build_inventory(){
  local scan_dir="$1"
  log "Scanning: $scan_dir"
  : > "$INVENTORY"

  # busybox/stat differences: use toybox/stat if available, else fallback
  local stat_bin="stat"
  if command -v toybox >/dev/null 2>&1 && toybox stat --help >/dev/null 2>&1; then
    stat_bin="toybox stat"
  fi

  # Find files (avoid permission spam)
  while IFS= read -r -d '' f; do
    # size + mtime best-effort
    local size mtime
    size=$(ls -ln "$f" 2>/dev/null | awk '{print $5}' || echo "0")
    mtime=$(date -r "$f" +%s 2>/dev/null || echo "0")
    printf "%s\t%s\t%s\t%s\n" "$(hash_file "$f" 2>/dev/null || echo "ERR")" "$size" "$mtime" "$f" >> "$INVENTORY"
  done < <(find "$scan_dir" -type f -print0 2>/dev/null)

  log "Inventory complete: $(wc -l < "$INVENTORY") files"
}

# Carve: copy only interesting extensions (configurable)
carve_files(){
  local scan_dir="$1"
  local exts="${YESQUID_EXTS:-sh,py,js,ts,json,md,yml,yaml,txt,log,html}"
  IFS=',' read -r -a arr <<< "$exts"

  log "Carving extensions: $exts"
  rm -rf "$CARVE_DIR"
  mkdir -p "$CARVE_DIR"

  local count=0
  for ext in "${arr[@]}"; do
    while IFS= read -r -d '' f; do
      # mirror path safely
      local rel="${f#"$scan_dir"/}"
      local dest="$CARVE_DIR/$rel"
      mkdir -p "$(dirname "$dest")"
      cp -f "$f" "$dest" 2>/dev/null || true
      count=$((count+1))
    done < <(find "$scan_dir" -type f -iname "*.${ext}" -print0 2>/dev/null)
  done

  log "Carve complete: $count files copied into $CARVE_DIR"
}

# Persistent state snapshot
save_state(){
  local stamp
  stamp="$(date +'%Y%m%d_%H%M%S')"
  cp -f "$INVENTORY" "$STATE_DIR/inventory_$stamp.tsv"
  ln -sf "$STATE_DIR/inventory_$stamp.tsv" "$STATE_DIR/inventory_latest.tsv"
  log "State saved: $STATE_DIR/inventory_latest.tsv"
}

# Diff vs latest
diff_state(){
  local latest="$STATE_DIR/inventory_latest.tsv"
  if [ ! -f "$latest" ]; then
    log "No previous state found."
    return 0
  fi

  log "Diffing vs previous inventory..."
  # Compare by sha+path
  awk -F'\t' '{print $1"\t"$4}' "$latest" | sort > "$OUT_DIR/_prev.key"
  awk -F'\t' '{print $1"\t"$4}' "$INVENTORY" | sort > "$OUT_DIR/_curr.key"

  comm -13 "$OUT_DIR/_prev.key" "$OUT_DIR/_curr.key" > "$OUT_DIR/added.key" || true
  comm -23 "$OUT_DIR/_prev.key" "$OUT_DIR/_curr.key" > "$OUT_DIR/removed.key" || true

  log "Added:   $(wc -l < "$OUT_DIR/added.key")"
  log "Removed: $(wc -l < "$OUT_DIR/removed.key")"
  log "Outputs: $OUT_DIR/added.key  $OUT_DIR/removed.key"
}

usage(){
  cat <<USAGE
YESQUID/PaTHos - RepoDepo Runner

Usage:
  $0 run [scan_dir]        # scan + carve + diff + save
  $0 scan [scan_dir]       # inventory only
  $0 carve [scan_dir]      # carve only
  $0 diff                 # diff current inventory vs latest (requires scan/run)
  $0 state                # show latest state file
Env:
  YESQUID_SCAN_DIR=/path
  YESQUID_EXTS=sh,py,js,json,md,yml,txt,log,html
USAGE
}

cmd="${1:-help}"
scan_dir="${2:-$DEFAULT_SCAN_DIR}"

case "$cmd" in
  run)
    build_inventory "$scan_dir"
    carve_files "$scan_dir"
    diff_state
    save_state
    log "DONE ✅"
    ;;
  scan)
    build_inventory "$scan_dir"
    save_state
    ;;
  carve)
    carve_files "$scan_dir"
    ;;
  diff)
    # assumes inventory exists from scan/run
    [ -f "$INVENTORY" ] || die "Run scan or run first to generate inventory: $INVENTORY"
    diff_state
    ;;
  state)
    ls -la "$STATE_DIR" | sed -n '1,120p'
    ;;
  *)
    usage
    ;;
esac
YEOF

# ----------------------------
# Artifact 2: Build State Manager (real)
# ----------------------------
cat > "$STATE" <<'SEOF'
#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

# Persistent Build State Manager (RepoDepo)
ROOT="${REPO_ROOT:-$HOME/Kre8tiveKonceptz_RepoDepo}"
STATE_DIR="$ROOT/.state"
LOG_DIR="$ROOT/logs"
mkdir -p "$STATE_DIR" "$LOG_DIR"

log(){ printf "[%s] %s\n" "$(date +'%F %T')" "$*" | tee -a "$LOG_DIR/state_manager.log" >/dev/null; }
die(){ log "ERROR: $*"; exit 1; }

need(){
  command -v "$1" >/dev/null 2>&1 || die "Missing: $1 (pkg install $1)"
}

need sha256sum
need find
need awk
need sort
need wc

# Hash a directory deterministically (file contents + relative paths)
dir_hash(){
  local dir="$1"
  [ -d "$dir" ] || die "Not a directory: $dir"
  (cd "$dir" && find . -type f -print0 2>/dev/null | sort -z | xargs -0 sha256sum 2>/dev/null) \
    | sha256sum | awk '{print $1}'
}

write_kv(){
  local key="$1" val="$2"
  printf "%s=%s\n" "$key" "$val"
}

snapshot(){
  local target="${1:-$ROOT/artifacts}"
  local out="$STATE_DIR/build_state.env"
  local h
  h="$(dir_hash "$target")"
  {
    write_kv "TARGET" "$target"
    write_kv "HASH" "$h"
    write_kv "STAMP" "$(date -Iseconds)"
  } > "$out"
  log "Snapshot saved: $out"
  log "HASH=$h"
}

status(){
  local target="${1:-$ROOT/artifacts}"
  local state="$STATE_DIR/build_state.env"
  if [ ! -f "$state" ]; then
    log "No state found. Run: $0 snapshot"
    exit 0
  fi

  # shellcheck disable=SC1090
  source "$state" || true

  local current
  current="$(dir_hash "$target")"

  log "Target: $target"
  log "Saved:  ${HASH:-<none>}"
  log "Now:    $current"

  if [ "${HASH:-}" = "$current" ]; then
    echo "UNCHANGED"
    exit 0
  else
    echo "CHANGED"
    exit 2
  fi
}

should_build(){
  local target="${1:-$ROOT/artifacts}"
  if status "$target" >/dev/null 2>&1; then
    log "No rebuild needed ✅"
    return 1
  else
    log "Rebuild needed ⚠️"
    return 0
  fi
}

usage(){
  cat <<USAGE
Build State Manager - RepoDepo

Usage:
  $0 snapshot [dir]     # save hash snapshot of dir (default: artifacts)
  $0 status [dir]       # compare current hash vs saved
  $0 should-build [dir] # returns 0 if rebuild needed, 1 otherwise
Files:
  $STATE_DIR/build_state.env
USAGE
}

case "${1:-help}" in
  snapshot) snapshot "${2:-$ROOT/artifacts}" ;;
  status) status "${2:-$ROOT/artifacts}" ;;
  should-build) should_build "${2:-$ROOT/artifacts}" ;;
  *) usage ;;
esac
SEOF

chmod +x "$YES" "$STATE"

echo "[✓] Forged real artifacts:"
echo " - $YES"
echo " - $STATE"
echo ""
echo "[✓] Heads:"
sed -n '1,18p' "$YES"
echo "-----"
sed -n '1,18p' "$STATE"
