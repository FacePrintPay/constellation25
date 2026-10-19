#!/usr/bin/env python3
"""
Agent Task Router - Direct Agent Invocation
Routes tasks to individual agent implementation scripts
"""

import json
import subprocess
import sys
from pathlib import Path

class AgentRouter:
    def __init__(self):
        self.base = Path.home() / "constellation25"
        self.agents_dir = self.base / "agents"
        
        # Agent → script mapping
        self.routes = {
            "earth": "earth_scaffolding.py",
            "moon": "moon_debug.py",
            "sun": "sun_optimize.py",
            "mercury": "mercury_testing.py",
            "venus": "venus_integration.py",
            "mars": "mars_security.py",
            "jupiter": "jupiter_docs.py",
            "saturn": "saturn_refactor.py",
            "uranus": "uranus_nlp.py",
            "neptune": "neptune_dedup.py",
            "pluto": "pluto_edge_cases.py",
            "cygnus": "cygnus_ml.py",
            "orion": "orion_ui.py",
            "andromeda": "andromeda_api.py",
            "pleiades": "pleiades_deps.py",
            "sirius": "sirius_deploy.py",
            "canismajor": "canismajor_debt.py",
            "hydra": "hydra_cicd.py",
            "vega": "vega_data.py",
            "polaris": "polaris_arch.py",
            "rigel": "rigel_realtime.py",
            "capella": "capella_research.py",
            "altair": "altair_scrape.py",
            "deneb": "deneb_ml_tuning.py",
            "fomalhaut": "fomalhaut_sovereign.py"
        }
    
    def invoke_agent(self, agent_name: str, task_file: str) -> int:
        """Invoke an agent with a task"""
        if agent_name not in self.routes:
            print(f"❌ Unknown agent: {agent_name}")
            return 1
        
        script = self.agents_dir / self.routes[agent_name]
        if not script.exists():
            # Fallback to generic execute_task.py
            script = self.agents_dir / "execute_task.py"
        
        try:
            result = subprocess.run(
                ["python3", str(script), task_file],
                check=False
            )
            return result.returncode
        except Exception as e:
            print(f"❌ Failed to invoke {agent_name}: {e}")
            return 1

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: agent_router.py <agent> <task.json>")
        sys.exit(1)
    
    agent = sys.argv[1]
    task_file = sys.argv[2]
    
    router = AgentRouter()
    exit_code = router.invoke_agent(agent, task_file)
    sys.exit(exit_code)
