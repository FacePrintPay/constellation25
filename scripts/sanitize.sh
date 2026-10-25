#!/usr/bin/env bash
set -euo pipefail

echo "[sanitize] removing temporary and generated artifacts"
find . \( \
  -type d -name .git -prune -o \
  -type d -name node_modules -prune -o \
  -type d -name dist -prune -o \
  -type d -name build -prune -o \
  -type d -name .next -prune -o \
  -type d -name .vercel -prune -o \
  -type f \( -name '*.log' -o -name '*.tmp' -o -name '.DS_Store' -o -name '*.bak' \) -delete \
\)

echo "[sanitize] complete"
