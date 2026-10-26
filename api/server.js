'use strict';
const express = require('express');
const { createConstellation, OUTPUTS } = require('../core/constellation');

function createApp() {
  const app = express();
  app.disable('x-powered-by');
  app.use(express.json({ limit: '1mb' }));

  app.get('/health', (_req, res) => res.json({ ok: true, service: 'c25-runtime', timestamp: new Date().toISOString() }));
  app.get('/ready', (_req, res) => res.json({ ready: true, capabilities: ['health', 'constellation-manifest'] }));
  app.get('/api/c25/outputs', (_req, res) => res.json({ product: 'Constellation25', mode: 'all_as_one', outputs: OUTPUTS }));
  app.post('/api/c25/constellations', (req, res) => {
    try {
      const { title, prompt, sourceCount } = req.body || {};
      if (prompt !== undefined && typeof prompt !== 'string') return res.status(400).json({ error: 'prompt must be a string' });
      const result = createConstellation({ title, prompt, sourceCount: sourceCount === undefined ? 0 : sourceCount });
      return res.status(201).json(result);
    } catch (error) {
      return res.status(400).json({ error: error.message });
    }
  });
  app.use((err, _req, res, _next) => {
    if (err && err.type === 'entity.too.large') return res.status(413).json({ error: 'request body too large' });
    if (err instanceof SyntaxError) return res.status(400).json({ error: 'invalid JSON' });
    return res.status(500).json({ error: 'internal server error' });
  });
  return app;
}
module.exports = { createApp };
