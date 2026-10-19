#!/usr/bin/env python3
"""Generate unified routing map from build manifest"""
import json, sys, os

def generate_routing_map(manifest_path: str, output_path: str):
    with open(manifest_path) as f:
        manifest = json.load(f)
    
    routes = []
    for repo in manifest.get("repos", []):
        name = repo["name"]
        files = repo.get("files", {})
        grep = repo.get("grep_analysis", {})
        
        # Determine primary language
        if files.get("python", 0) > files.get("javascript", 0):
            lang = "python"
        elif files.get("javascript", 0) > 0:
            lang = "javascript"
        else:
            lang = "other"
        
        # Determine capabilities
        capabilities = []
        if grep.get("agent_refs", 0) > 0:
            capabilities.append("agent")
        if grep.get("security_refs", 0) > 0:
            capabilities.append("security")
        if grep.get("todos", 0) > 0:
            capabilities.append("todo-tracking")
        
        routes.append({
            "repo": name,
            "language": lang,
            "files": files,
            "capabilities": capabilities,
            "endpoint": f"/api/v1/repos/{name}"
        })
    
    with open(output_path, "w") as f:
        json.dump({"routes": routes, "version": "1.0"}, f, indent=2)
    
    print(f"✅ Generated {len(routes)} routes to {output_path}")

if __name__ == "__main__":
    manifest = sys.argv[1] if len(sys.argv) > 1 else "/workspace/Constellation25/build-manifest.json"
    output = sys.argv[2] if len(sys.argv) > 2 else "/workspace/Constellation25/.routing.map.json"
    generate_routing_map(manifest, output)
