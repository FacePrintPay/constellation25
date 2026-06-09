from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import json, os, subprocess

app = FastAPI(title="Constellation25 Unified Gateway")

class NLPPrompt(BaseModel):
    prompt: str
    repo_filter: str | None = None

@app.get("/health")
def health():
    return {"status": "ok", "service": "constellation25-gateway"}

@app.post("/nlp2code")
def nlp2code(request: NLPPrompt):
    """Route natural language to code execution across all repos"""
    # Parse intent
    intent = request.prompt.lower()
    
    # Route to appropriate repo/tool
    if "agent" in intent:
        return execute_agent_command(request.prompt, request.repo_filter)
    elif "build" in intent or "compile" in intent:
        return trigger_build(request.repo_filter)
    elif "test" in intent:
        return run_tests(request.repo_filter)
    else:
        # Fallback: search across all repos
        return search_repos(request.prompt)

def execute_agent_command(prompt: str, repo_filter: str | None):
    # TODO: Implement agent routing logic
    return {"status": "routed", "intent": "agent", "prompt": prompt}

def trigger_build(repo_filter: str | None):
    # TODO: Implement build trigger
    return {"status": "build_started", "repo": repo_filter or "all"}

def run_tests(repo_filter: str | None):
    # TODO: Implement test runner
    return {"status": "tests_running", "repo": repo_filter or "all"}

def search_repos(query: str):
    # Search across unified manifest
    manifest_path = os.getenv("MANIFEST_PATH", "/workspace/Constellation25/build-manifest.json")
    with open(manifest_path) as f:
        manifest = json.load(f)
    
    results = []
    for repo in manifest.get("repos", []):
        if query.lower() in repo.get("name", "").lower() or \
           query.lower() in repo.get("description", "").lower():
            results.append(repo)
    
    return {"results": results, "query": query}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
