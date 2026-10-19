#!/bin/bash
# C25 AUTO-BOOT — Cygel White / FacePrintPay
cd ~/pathos && node server.js &
echo "✅ Pathos started (PID: $!)"
echo $! > ~/pathos.pid
