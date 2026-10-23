# Constellation-25

Sovereign AI orchestration platform for autonomous software generation, deployment, monitoring, and secure operations.

## Quickstart

### Prerequisites

- Git
- Docker (recommended for local orchestration)
- Node.js or Python runtime depending on your implementation branch
- Access to GitHub and deployment endpoints
- Secure environment variables in a `.env` file

### Clone

```bash
git clone https://github.com/FacePrintPay/constellation25.git
cd constellation25
```

### Configure environment

```bash
cp .env.example .env
# fill in required secrets, GitHub tokens, and deployment settings
```

### Install dependencies

```bash
# Node-based projects
npm install

# Python-based projects
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

### Run locally

```bash
# Common orchestration entrypoint
make run

# or, if using app entry files directly
node server.js
# or
python app.py
```

### Validate setup

```bash
make test
make lint
```

## Core Concepts

Constellation-25 is built around a coordinated set of 25 specialized agents. The orchestrator routes tasks to the appropriate agent based on domain, state, and security constraints.

## Architecture

See [`docs/architecture.md`](docs/architecture.md) for the full architecture overview and agent map.

## Key Features

- Local-first and edge-friendly execution
- Biometric and policy-based security
- GitHub and deployment automation
- Multi-agent orchestration
- CI/CD and build orchestration
- Observability and alerting

## Repository Layout

```text
constellation25/
├── agents/
├── api/
├── cli/
├── core/
├── integrations/
├── docs/
├── monitoring/
├── security/
├── scripts/
├── tests/
├── README.md
├── LICENSE
├── .env.example
├── Dockerfile
├── docker-compose.yml
└── Makefile
```

## Production Notes

- Treat security gates as mandatory for production operations.
- Keep agent responsibilities isolated and explicit.
- Persist task and deployment state for traceability.
- Validate all external integrations before release.

## License

See `LICENSE` for project licensing details.
