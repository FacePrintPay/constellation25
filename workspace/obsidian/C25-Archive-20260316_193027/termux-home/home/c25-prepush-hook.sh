#!/data/data/com.termux/files/usr/bin/bash
# Auto-install CanisMajor as pre-push hook in every repo

find ~/github-repos -name ".git" -maxdepth 3 -type d | while read gitdir; do
    REPO=$(dirname "$gitdir")
    HOOK="$gitdir/hooks/pre-push"
    cat > "$HOOK" << 'HOOK'
#!/data/data/com.termux/files/usr/bin/bash
echo "🛡️ CanisMajor pre-push scan..."
ag=CanisMajor bash ~/github-repos/Constillation25/sovereign_gtp/agents/CanisMajor.sh "$(pwd)"
exit 0
HOOK
    chmod +x "$HOOK"
    echo "✅ CanisMajor hook → $REPO"
done
