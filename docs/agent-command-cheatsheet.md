# Constellation-25 Agent Command Cheat Sheet

This cheat sheet provides a simple terminal pattern for each of the 25 agents in the Constellation-25 ecosystem.

## Core CLI Pattern

```bash
constellation25 agent <agent-name> --status
constellation25 agent <agent-name> --run --task "<task-description>"
constellation25 agent <agent-name> --logs
constellation25 agent <agent-name> --health
```

## Agent Commands

### Earth
```bash
constellation25 agent earth --status
constellation25 agent earth --orchestrate --task "coordinate full workflow"
```

### Moon
```bash
constellation25 agent moon --state
constellation25 agent moon --checkpoint --save
```

### Sun
```bash
constellation25 agent sun --profile
constellation25 agent sun --optimize --target runtime
```

### Mercury
```bash
constellation25 agent mercury --health
constellation25 agent mercury --metrics --watch
```

### Venus
```bash
constellation25 agent venus --campaign --list
constellation25 agent venus --publish --channel social
```

### Mars
```bash
constellation25 agent mars --deploy --environment staging
constellation25 agent mars --rollback --environment production
```

### Jupiter
```bash
constellation25 agent jupiter --aggregate --source all
constellation25 agent jupiter --report --format json
```

### Saturn
```bash
constellation25 agent saturn --scan --target repo
constellation25 agent saturn --audit --compliance
```

### Uranus
```bash
constellation25 agent uranus --api --routes
constellation25 agent uranus --gateway --health
```

### Neptune
```bash
constellation25 agent neptune --db --status
constellation25 agent neptune --migrate --dry-run
```

### Pluto
```bash
constellation25 agent pluto --migration --plan
constellation25 agent pluto --compatibility --check
```

### Ceres
```bash
constellation25 agent ceres --deps --audit
constellation25 agent ceres --upgrade --check
```

### Vesta
```bash
constellation25 agent vesta --build
constellation25 agent vesta --artifact --package
```

### Pallas
```bash
constellation25 agent pallas --pipeline --status
constellation25 agent pallas --trigger --workflow release
```

### Juno
```bash
constellation25 agent juno --container --list
constellation25 agent juno --image --build
```

### Eris
```bash
constellation25 agent eris --infra --status
constellation25 agent eris --cloud --deploy
```

### Makemake
```bash
constellation25 agent makemake --alert --list
constellation25 agent makemake --escalate --incident critical
```

### Haumea
```bash
constellation25 agent haumea --incident --summary
constellation25 agent haumea --recover --target service
```

### Sedna
```bash
constellation25 agent sedna --backup --run
constellation25 agent sedna --restore --latest
```

### Quaoar
```bash
constellation25 agent quaoar --scale --status
constellation25 agent quaoar --autoscale --plan
```

### Orcus
```bash
constellation25 agent orcus --network --status
constellation25 agent orcus --firewall --audit
```

### Varuna
```bash
constellation25 agent varuna --logs --tail
constellation25 agent varuna --events --last 24h
```

### Ixion
```bash
constellation25 agent ixion --secret --list
constellation25 agent ixion --rotate --key production
```

### Chaos
```bash
constellation25 agent chaos --fault --inject
constellation25 agent chaos --resilience --test
```

### Nyx
```bash
constellation25 agent nyx --model --status
constellation25 agent nyx --inference --run "predictive analysis"
```

## Common Multi-Agent Run Pattern

```bash
constellation25 run --agent earth --task "coordinate release workflow"
constellation25 run --agent mars --task "deploy release to staging"
constellation25 run --agent saturn --task "security scan"
constellation25 run --agent varuna --task "collect logs after deploy"
```

## Quick Operational Sequence

```bash
constellation25 agent earth --status
constellation25 agent mercury --health
constellation25 agent saturn --scan --target repo
constellation25 agent mars --deploy --environment staging
constellation25 agent varuna --logs --tail
constellation25 agent makemake --alert --list
```

## Notes

- Replace placeholder values like `<release-branch>`, `<task-description>`, and `<environment>` with real values for your deployment.
- In production environments, route privileged commands through secure automation and approval workflows.
- Always verify health and rollback paths before promoting a release.
