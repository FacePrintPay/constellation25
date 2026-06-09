#!/usr/bin/env python3
"""
AGI KRE8TIVE - Key Rotation API (Clean, Termux-safe)
"""

from datetime import datetime
import secrets
import os
from typing import Optional

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

app = FastAPI(
    title="AGI KRE8TIVE Key Rotation API",
    version="1.0.0",
    description="Secure key rotation service for RepoDepo"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # dev-only
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class KeyRotationRequest(BaseModel):
    service_name: str
    key_type: str = "api_key"

class KeyRotationResponse(BaseModel):
    service_name: str
    new_key: str
    rotated_at: str
    expires_in_days: int = 90
    old_key_valid_until: Optional[str] = None

@app.get("/")
async def root():
    return {
        "service": "AGI KRE8TIVE Key Rotation API",
        "version": "1.0.0",
        "status": "operational",
        "endpoints": {
            "health": "/health",
            "metrics": "/metrics",
            "rotate_key": "/rotate-key (POST)"
        }
    }

@app.get("/health")
async def health():
    return {"ok": True, "ts": datetime.now().isoformat()}

@app.get("/metrics")
async def metrics():
    return {
        "service": "AGI KRE8TIVE Key Rotation",
        "timestamp": datetime.now().isoformat(),
        "pid": os.getpid(),
        "allowed": 0,
        "blocked": 0,
        "requests_per_second": 0.0,
    }

@app.post("/rotate-key", response_model=KeyRotationResponse)
async def rotate_key(request: KeyRotationRequest):
    try:
        new_key = f"ak_{secrets.token_urlsafe(32)}"
        rotated_at = datetime.now()
        return KeyRotationResponse(
            service_name=request.service_name,
            new_key=new_key,
            rotated_at=rotated_at.isoformat(),
            expires_in_days=90,
            old_key_valid_until=rotated_at.isoformat()
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Key rotation failed: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("output:app", host="0.0.0.0", port=8000, log_level="info")
