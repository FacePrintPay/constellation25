#!/usr/bin/env python3
"""
AGI Swarm API Bridge - Connects web frontend to task queue
"""

from datetime import datetime
import json
import os
from pathlib import Path
from typing import List

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

TASKS_ROOT = Path.home() / "tasks"
OUTPUTS_ROOT = Path.home() / "outputs"
LOGS_ROOT = Path.home() / "logs"

app = FastAPI(
    title="AGI Swarm API",
    version="1.0.0",
    description="API bridge for AGI agent orchestration"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # dev-only
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class TaskRequest(BaseModel):
    agent: str
    task_type: str
    description: str
    priority: str = "normal"

class TaskResponse(BaseModel):
    task_id: str
    agent: str
    status: str
    created_at: str

class SwarmStatus(BaseModel):
    orchestrator_running: bool
    agents_available: List[str]
    tasks_pending: int
    tasks_processing: int
    tasks_completed: int
    tasks_failed: int

@app.get("/")
async def root():
    return {"service": "AGI Swarm API", "version": "1.0.0", "status": "operational"}

@app.get("/health")
async def health():
    return {"ok": True, "ts": datetime.now().isoformat()}

@app.get("/swarm/status", response_model=SwarmStatus)
async def swarm_status():
    try:
        daemon_pid = LOGS_ROOT / "orchestrator" / "daemon.pid"
        orchestrator_running = False
        if daemon_pid.exists():
            try:
                pid = int(daemon_pid.read_text().strip())
                os.kill(pid, 0)
                orchestrator_running = True
            except Exception:
                orchestrator_running = False

        incoming = len(list((TASKS_ROOT / "incoming").glob("*.json"))) if (TASKS_ROOT / "incoming").exists() else 0
        processing = len(list((TASKS_ROOT / "processing").glob("*.json"))) if (TASKS_ROOT / "processing").exists() else 0
        completed = len(list((TASKS_ROOT / "completed").glob("*.json"))) if (TASKS_ROOT / "completed").exists() else 0
        failed = len(list((TASKS_ROOT / "failed").glob("*.json"))) if (TASKS_ROOT / "failed").exists() else 0

        return SwarmStatus(
            orchestrator_running=orchestrator_running,
            agents_available=["valuation", "market", "finance", "pr", "outreach", "income", "bundle", "web_build"],
            tasks_pending=incoming,
            tasks_processing=processing,
            tasks_completed=completed,
            tasks_failed=failed
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/swarm/task", response_model=TaskResponse)
async def create_task(request: TaskRequest):
    try:
        ts = int(datetime.now().timestamp())
        task_id = f"{request.agent}_{ts}"

        task_data = {
            "agent": request.agent,
            "type": request.task_type,
            "description": request.description,
            "priority": request.priority,
            "created_at": datetime.now().isoformat()
        }

        incoming_dir = TASKS_ROOT / "incoming"
        incoming_dir.mkdir(parents=True, exist_ok=True)

        task_file = incoming_dir / f"{task_id}.json"
        task_file.write_text(json.dumps(task_data, indent=2))

        return TaskResponse(
            task_id=task_id,
            agent=request.agent,
            status="queued",
            created_at=task_data["created_at"]
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
