# Constellation-25 Deployment Runbook

## Purpose

This runbook describes the operational workflow for deploying, validating, and recovering Constellation-25 in supported environments. It is intended for engineers, operators, and release managers who are responsible for keeping the orchestration platform stable and secure.

## Scope

This document covers:
- local and edge deployment setup
- GitHub-triggered or CI/CD-driven deployment
- validation and health checks
- rollback procedures
- incident response and recovery

## Deployment Model

Constellation-25 is designed around a sovereign, local-first operating model with optional cloud deployment targets. Production deployment patterns generally include:

1. Local or edge execution for development and mobile-first workflows
2. CI/CD execution for automated build and release validation
3. Targeted deployment to GitHub, Vercel, Cloudflare, or cloud infrastructure
4. Runtime monitoring and rollback based on health and compliance gates

## Required Preconditions

Before deployment, confirm all of the following:

- repository is clean and branch is selected correctly
- `.env` or equivalent secrets file is populated with environment-specific values
- GitHub access token or deployment credentials are valid
- build environment matches target runtime requirements
- dependent services such as databases, caches, and observability stacks are reachable
- security policy checks are enabled for production-critical operations

## Environment Matrix

| Environment | Typical Use | Security Level | Notes |
|---|---|---:|---|
| Local | development, testing, mobile-first execution | Low-Medium | runs on local or edge devices |
| Staging | validation before production | Medium | must pass automated checks |
| Production | live deployment | High | requires approval gates and monitoring |

## Preflight Checklist

Run these checks before deployment:

```bash
# verify git state
git status

git fetch --all --prune

# lint and unit validation
make lint
make test

# build artifacts
make build
```

If the repository includes Docker-based deployment, also validate:

```bash
docker compose config
docker compose build
```

## Deployment Steps

### 1. Prepare the target branch

```bash
git checkout <release-branch>
git pull --ff-only origin <release-branch>
```

### 2. Validate configuration

- confirm environment variables are loaded correctly
- ensure GitHub and hosting credentials are valid
- verify secrets are not committed to source control

### 3. Run deployment pipeline

```bash
make deploy
```

If the platform is deployed via Docker or a platform-specific script, use the repository-defined entrypoint:

```bash
docker compose up -d
```

### 4. Post-deployment validation

Confirm the deployment is healthy:

```bash
make test
curl -f http://localhost:PORT/health || true
```

Check that:
- app processes are running
- required environment endpoints are reachable
- monitoring and logs are streaming
- deployment health checks pass

## Health Checks

Every deployment should validate the following:

- process uptime
- dependency health
- API response quality
- resource consumption
- environment-specific metrics
- alert thresholds

Recommended status endpoint:

```text
/health
/ready
/metrics
```

## Rollback Strategy

If deployment fails or the target becomes unstable:

1. Stop the new deployment or disable traffic routing.
2. Revert to the last known-good build or release tag.
3. Restore configuration values from the last stable environment state.
4. Re-run validation checks.
5. Keep the incident record in the operational log.

### Rollback commands

```bash
git revert <release-commit>
make rollback
```

Or container rollback:

```bash
docker compose down
docker compose up -d --scale service=0
docker compose up -d
```

## Incident Response

If a deployment is unhealthy, follow this sequence:

1. Pause rollout or traffic
2. Validate logs and metrics
3. Confirm whether the issue is configuration, dependency, or code-level
4. Apply the safest corrective action
5. Re-test before promoting the next change

Escalate to maintainers when:
- security controls fail
- data integrity is at risk
- critical service availability is reduced
- the rollback path is uncertain

## Operational Safeguards

- Require biometric or policy validation for protected actions
- Separate dev, staging, and production credentials
- Keep deployment logs and state records
- Restrict privileged automation to named operators
- Ensure rollback steps are tested before release windows

## Documentation and Change Control

Every production change should have:
- a tracked release commit
- a documented reason for the deployment
- testing and validation evidence
- rollback instructions
- issue or incident reference if applicable

## Maintenance Checklist

Before each release cycle:

- review dependency health and version drift
- validate secret rotation status
- confirm environment-level policies still match production requirements
- review alert thresholds and escalation routes
- check backup and recovery readiness

## Final Safety Rule

No production deployment should proceed without validated health checks, a rollback plan, and confirmation that security controls remain active.
