#!/bin/bash
# Deployment Script - Deploy to production

REPO_ROOT="$HOME/Kre8tiveKonceptz_RepoDepo"
BUILD_DIR="$REPO_ROOT/build/deployable"

echo "🚀 Deploying Kre8tive Konceptz RepoDepo..."

# Source configuration
source "$REPO_ROOT/configs/master.conf"

# Upload to Google Cloud
if command -v gsutil &> /dev/null; then
    echo "☁️  Uploading to Google Cloud..."
    gsutil -m cp -r "$BUILD_DIR"/* "gs://$GCP_BUCKET/deployments/"
    echo "✅ Cloud deployment complete!"
else
    echo "⚠️  gsutil not available - skipping cloud upload"
fi

# Sync with YESQUID system
echo "🔄 Syncing with YESQUID/PaTHos..."
if [ -d "$YESQUID_HOME" ]; then
    cp -r "$REPO_ROOT/scripts"/*.sh "$YESQUID_HOME/"
    echo "✅ YESQUID sync complete!"
fi

echo "✅ Deployment complete!"
