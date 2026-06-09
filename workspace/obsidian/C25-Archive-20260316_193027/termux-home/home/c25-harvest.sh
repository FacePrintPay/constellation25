#!/data/data/com.termux/files/usr/bin/bash

echo "🌟 C25 Storage Harvest"
echo "Linking all storage to C25..."

STORAGE="$HOME/storage/shared"
C25="$HOME/C25-MASTER"

# Create C25 storage sandbox
mkdir -p "$C25/sandbox/downloads"
mkdir -p "$C25/sandbox/documents"  
mkdir -p "$C25/sandbox/storage"

# Symlink entire internal storage into C25 sandbox
ln -sf "$HOME/storage/shared" "$C25/sandbox/storage/internal"
ln -sf "$HOME/storage/downloads" "$C25/sandbox/storage/downloads"

echo "✅ Internal storage linked to C25 sandbox"
echo ""
echo "Access via Ranger: c25m → sandbox/storage/"
echo "Or directly: ls ~/C25-MASTER/sandbox/storage/internal/"

# Tar snapshot of current device files
echo ""
echo "📦 Creating snapshot..."
tar -czf "$C25/sandbox/device_snapshot_$(date +%Y%m%d).tar.gz" \
    "$HOME/storage/shared" \
    "$HOME/github-repos" \
    "$HOME/C25-MASTER" \
    --exclude="*.tar.gz" \
    --exclude="node_modules" \
    2>/dev/null

echo "✅ Snapshot saved to C25/sandbox/"
