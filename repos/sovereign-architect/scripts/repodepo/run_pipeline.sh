#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

ROOT="$HOME/Kre8tiveKonceptz_RepoDepo"
STATE="$ROOT/artifacts/02_state_management/build_state_manager.sh"
TARGET="$ROOT/artifacts"

echo "[i] Checking state…"
if "$STATE" should-build "$TARGET"; then
  echo "[⚙] Changes detected → running pipeline"

  echo "[1/3] Harvest + integrate…"
  if [[ -x "$HOME/repodepo_harvest_and_integrate_v3.sh" ]]; then
    bash "$HOME/repodepo_harvest_and_integrate_v3.sh"
  else
    echo "[!] Missing: ~/repodepo_harvest_and_integrate_v3.sh"
    exit 1
  fi

  echo "[2/3] Build…"
  if [[ -x "$ROOT/scripts/build_package.sh" ]]; then
    bash "$ROOT/scripts/build_package.sh"
  else
    echo "[i] build_package.sh not present yet — skipping build"
  fi

  echo "[3/3] Snapshot…"
  "$STATE" snapshot "$TARGET"

  echo "[✅] Pipeline complete + snapshot updated"
else
  echo "[✅] UNCHANGED → skipping pipeline"
fi
