#!/bin/bash

echo "=============================="
echo " C25 FILE SYSTEM EXPLORER"
echo "=============================="

echo ""
echo ">> HOME DIRECTORY (~)"
echo "------------------------------"
ls -la ~/

echo ""
echo ">> ALL DIRECTORIES IN HOME"
echo "------------------------------"
find ~ -maxdepth 3 -type d 2>/dev/null | grep -v node_modules | grep -v ".npm" | grep -v ".cache" | sort

echo ""
echo ">> ALL SERVER/APP FILES"
echo "------------------------------"
find ~ -maxdepth 5 \( \
  -name "server.js" \
  -o -name "index.js" \
  -o -name "index.html" \
  -o -name "package.json" \
  -o -name "app.js" \
  -o -name "main.js" \
\) 2>/dev/null | grep -v node_modules

echo ""
echo ">> INTERNAL STORAGE ROOT"
echo "------------------------------"
ls -la /sdcard/ 2>/dev/null || echo "No sdcard access"

echo ""
echo ">> INTERNAL STORAGE FOLDERS"
echo "------------------------------"
find /sdcard -maxdepth 2 -type d 2>/dev/null | sort

echo ""
echo ">> C25 RELATED FOLDERS ANYWHERE"
echo "------------------------------"
find / -maxdepth 6 -type d -iname "*c25*" -o \
  -type d -iname "*constellation*" -o \
  -type d -iname "*kre8*" -o \
  -type d -iname "*pathos*" \
  2>/dev/null | grep -v proc | grep -v sys

echo ""
echo ">> GIT REPOS FOUND"
echo "------------------------------"
find ~ /sdcard -maxdepth 5 -name ".git" -type d 2>/dev/null | sed 's/\/.git//' | sort

echo ""
echo "=============================="
echo " SCAN COMPLETE"
echo "=============================="
