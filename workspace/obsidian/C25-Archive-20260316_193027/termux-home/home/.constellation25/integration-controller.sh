#!/bin/bash
# Ensures all agents work independently AND as integrated system

while true; do
  # Check all agents healthy
  HEALTHY=$(jq -r '.agents | to_entries | map(select(.value.status == "healthy")) | length' ~/.constellation25/sync.db)
  
  if [ "$HEALTHY" -eq 17 ]; then
    # Sync shared resources
    rsync -a ~/.constellation25/ /sdcard/Obsidian/C25-Agents/constellation/
    
    # Update integration status
    jq '.integration_status = "operational" | .last_integration = now | strftime("%Y-%m-%dT%H:%M:%SZ")' \
      ~/.constellation25/sync.db > ~/.constellation25/sync.db.tmp
    mv ~/.constellation25/sync.db.tmp ~/.constellation25/sync.db
  else
    jq --arg count "$HEALTHY" '.integration_status = "degraded" | .healthy_agents = ($count | tonumber)' \
      ~/.constellation25/sync.db > ~/.constellation25/sync.db.tmp
    mv ~/.constellation25/sync.db.tmp ~/.constellation25/sync.db
  fi
  
  sleep 300
done
