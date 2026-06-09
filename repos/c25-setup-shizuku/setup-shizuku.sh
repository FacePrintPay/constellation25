#!/data/data/com.termux/files/usr/bin/bash
# setup-shizuku.sh - Start Shizuku in Termux after initial setup
# Author: Cygel White (@thacyg)
# Requirements: android-tools (adb) installed in Termux
set -e
echo "[*] Setting up Shizuku for X-plore..."
# Install adb if not present
if ! command -v adb &> /dev/null; then
  echo "[*] Installing android-tools (adb)..."
  pkg install -y android-tools
fi
# Shizuku package name
PKG="moe.shizuku.privileged.api"
# Check if Shizuku is installed
if ! pm list packages | grep -q "$PKG"; then
  echo "[!] Shizuku is not installed. Please install it from:"
  echo "    https://shizuku.rikka.app"
  exit 1
fi
# Default Shizuku ADB port
PORT=5555
# Connect via ADB (localhost works if Shizuku ADB is running)
echo "[*] Connecting to Shizuku ADB server..."
adb connect localhost:$PORT 2>/dev/null || true
# Check if Shizuku process is running
if adb shell "pm dump $PKG 2>/dev/null" | grep -q 'state=started'; then
  echo "[+] Shizuku is already running."
else
  echo "[*] Starting Shizuku service..."
  adb shell "am start-foreground-service -n $PKG/.starter.StarterService" 2>/dev/null || {
    echo "[!] Failed to start Shizuku."
    echo "    → Open Shizuku app manually and tap 'Start via ADB'."
    echo "    → Ensure Wireless Debugging is ON and paired."
    exit 1
  }
  sleep 2
  echo "[+] Shizuku started successfully."
fi
echo "[*] Done. X-plore should now access /Android/data via Shizuku."
