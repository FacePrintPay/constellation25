#!/data/data/com.termux/files/usr/bin/bash
# C25 SOVEREIGN FULL RUN — Cygel White / FacePrintPay
# Runs ALL scripts, logs clean vs failed

CLEAN="/data/data/com.termux/files/home/storage/external-1/external-1/C25_ALL_CLEAN.txt"
FAILED="/data/data/com.termux/files/home/storage/external-1/external-1/C25_ALL_FAILED.txt"

echo "C25 FULL RUN — $(date)" > $CLEAN
echo "C25 FULL FAILED — $(date)" > $FAILED

find ~ -name "*.sh" 2>/dev/null | grep -v node_modules | grep -v ".git" | while read SCRIPT; do
  if timeout 30 bash "$SCRIPT" >> /data/data/com.termux/files/home/storage/external-1/external-1/C25_RUN_OUTPUT.log 2>&1; then
    echo "✅ $SCRIPT" >> $CLEAN
  else
    echo "❌ $SCRIPT" >> $FAILED
  fi
done

echo ""
echo "═══════════════════════════════"
echo "CLEAN:  $(grep -c '✅' $CLEAN)"
echo "FAILED: $(grep -c '❌' $FAILED)"
echo "═══════════════════════════════"
echo "Logs saved to /data/data/com.termux/files/home/storage/external-1/external-1/"
