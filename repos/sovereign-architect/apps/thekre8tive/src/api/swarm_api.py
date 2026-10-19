from datetime import datetime
import json, os
from pathlib import Path
from fastapi import FastAPI
from pydantic import BaseModel

TASKS = Path.home() / "tasks"
TASKS.mkdir(exist_ok=True)
(TASKS/"incoming").mkdir(exist_ok=True)

app = FastAPI(title="AGI Swarm API")

class TaskReq(BaseModel):
    agent: str
    task_type: str
    description: str

@app.get("/health")
def health():
    return {"ok": True}

@app.get("/swarm/status")
def status():
    def c(d): return len(list(d.glob("*.json"))) if d.exists() else 0
    return {
        "incoming": c(TASKS/"incoming"),
        "processing": c(TASKS/"processing"),
        "completed": c(TASKS/"completed"),
        "failed": c(TASKS/"failed"),
    }

@app.post("/swarm/task")
def task(t: TaskReq):
    tid = f"{t.agent}_{int(datetime.utcnow().timestamp())}"
    f = TASKS/"incoming"/f"{tid}.json"
    f.write_text(json.dumps({
        "agent": t.agent,
        "type": t.task_type,
        "description": t.description,
        "created_at": datetime.utcnow().isoformat()
    }, indent=2))
    return {"task_id": tid, "status": "queued"}
