#!/data/data/com.termux/files/usr/bin/bash
# Sovereign Obsidian Cloud Sync — Using YOUR rclone config
VAULT_PATH="$HOME/Obsidian/WideOpen"
LOG_FILE="$VAULT_PATH/.sync_log_$(date +%Y%m%d_%H%M%S).txt"
GCS_REMOTE="cygel.co@gmail.com:"
mkdir -p "$VAULT_PATH"
BUCKETS=(
  "705009278546-us-central1-blueprint-config"
  "ai_metaverse_app_structure"
  "aimetaverse-d40f4.appspot.com"
  "cloud-oi-platform-07049032-e034-425d-a12e-dd970b770561"
  "media-aimetaverse-d40f4-2d7d"
  "staging.aimetaverse-d40f4.appspot.com"
  "us.artifacts.aimetaverse-d40f4.appspot.com"
)
echo "🚀 Starting WideOpen Obsidian Sync via rclone" | tee "$LOG_FILE"
echo "Using remote: $GCS_REMOTE" | tee -a "$LOG_FILE"
for BUCKET in "${BUCKETS[@]}"; do
  echo "📥 Syncing: $BUCKET" | tee -a "$LOG_FILE"
  rclone sync "$GCS_REMOTE$BUCKET" "$VAULT_PATH/Cloud/$BUCKET" \
    --checksum \
    --verbose \
    --log-file "$LOG_FILE" \
    --exclude "*.tmp" \
    --exclude "*/node_modules/**" \
    --transfers=4 \
    --checkers=8
done
echo "✅ DONE. All cloud files now in Obsidian vault." | tee -a "$LOG_FILE"
