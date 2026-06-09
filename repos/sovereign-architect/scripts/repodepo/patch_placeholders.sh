#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

ROOT="$HOME/Kre8tiveKonceptz_RepoDepo"
Y="$ROOT/artifacts/01_yesquid_pathos/yesquid_all_in_one_persistent.sh"
S="$ROOT/artifacts/02_state_management/build_state_manager.sh"

echo "[*] Checking placeholders..."
grep -n "PASTE THE FULL YESQUID SCRIPT HERE" "$Y" >/dev/null && echo " - YESQUID is placeholder ✅"
grep -n "PASTE THE BUILD STATE MANAGER HERE" "$S" >/dev/null && echo " - State manager is placeholder ✅"

echo ""
echo "Paste the REAL YESQUID script now. End with a single line: __END__"
tmpy="$(mktemp)"
while IFS= read -r line; do
  [ "$line" = "__END__" ] && break
  printf "%s\n" "$line" >> "$tmpy"
done

echo ""
echo "Paste the REAL build_state_manager script now. End with a single line: __END__"
tmps="$(mktemp)"
while IFS= read -r line; do
  [ "$line" = "__END__" ] && break
  printf "%s\n" "$line" >> "$tmps"
done

cp "$tmpy" "$Y"
cp "$tmps" "$S"
chmod +x "$Y" "$S"

echo ""
echo "[✓] Patched both files and set executable bits."
echo "[✓] YESQUID head:"
sed -n '1,12p' "$Y"
echo "-----"
echo "[✓] State manager head:"
sed -n '1,12p' "$S"
