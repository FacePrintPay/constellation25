#!/bin/bash
# Sync agent activity to Obsidian vault
VAULT="/sdcard/Obsidian/C25-Agents"
mkdir -p "$VAULT"
rsync -a ~/agent_logs/ "$VAULT/logs/"
rsync -a ~/tasks/ "$VAULT/tasks/"
rsync -a ~/.constellation25/ "$VAULT/constellation/"
