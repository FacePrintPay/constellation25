# C25 Runtime Foundation

This change adds a minimal, testable HTTP runtime foundation to Constellation25.

## Endpoints
- `GET /health` — process health.
- `GET /ready` — currently configured local capabilities.
- `GET /api/c25/outputs` — the All-As-One output category contract.
- `POST /api/c25/constellations` — creates a validated constellation manifest from JSON `{ "title": "My Constellation", "prompt": "...", "sourceCount": 0 }`.

## Run locally
```bash
cp .env.example .env
npm install
npm run build
npm test
npm start
```

## Important scope boundary
This foundation creates a manifest and exposes an API; it does not yet execute model inference, ingest source files, generate real prototype/presentation/audio artifacts, authenticate users, persist builds, or deploy the service. Those integrations must be added and tested before describing C25 as a production-ready end-user platform.
