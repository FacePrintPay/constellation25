#!/data/data/com.termux/files/usr/bin/bash

# Install token guard as git pre-push hook in all repos
find ~/github-repos -name ".git" -type d | while read gitdir; do
    REPO=$(dirname "$gitdir")
    HOOK="$gitdir/hooks/pre-push"
    
    cat > "$HOOK" << 'HOOK'
#!/data/data/com.termux/files/usr/bin/bash
bash ~/c25-token-guard.sh "$(pwd)"
if [ $? -ne 0 ]; then
    echo "❌ Token guard failed - push blocked"
    exit 1
fi
exit 0
HOOK
    
    chmod +x "$HOOK"
    echo "✅ Hook installed: $REPO"
done
