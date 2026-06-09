# Sovereign Architect

AI-powered planning system for complex, multi-agent workflows.

## Architecture
- **Planner**: Breaks down high-level goals into hierarchical step plans
- **Enqueuer**: Converts plan steps into executable tasks
- **Agents**: Specialized workers (valuation, ROI, outreach, compliance)

## Usage
```bash
./agents/agent_architect.sh "Your complex goal here"
Current Plans
See plans/ directory for all generated plans.

## Execution System

### Setup
1. Get an Anthropic API key from https://console.anthropic.com
2. Create `.env` file: `cp .env.example .env`
3. Add your API key to `.env`
4. Load it: `export $(cat .env | xargs)`

### Execute a Plan
```bash
# List available plans
./agents/execute_plan.sh

# Execute a specific plan
./agents/execute_plan.sh 31cca67c

# Compile final deck
python3 agents/compile_deck.py 31cca67c
```

### What Happens
- Worker orchestrator loads the plan
- Each step gets executed by Claude Sonnet 4
- Outputs saved to `storage/outputs/`
- Final deck compiled to `storage/artifacts/`
- Plan status updated in real-time

### Status Tracking
```bash
# View plan status
jq '.status, (.steps[] | {step_id, title, status})' ~/sovereign-architect/plans/plan_*.json

# View latest output
ls -lt ~/sovereign-architect/storage/outputs/
```
