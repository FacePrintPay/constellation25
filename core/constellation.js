'use strict';
const crypto = require('node:crypto');

const OUTPUTS = [
  'constellation_summary','source_map','evidence_index','knowledge_map',
  'insight_report','strategy','prototype','presentation','audio_overview',
  'interactive_build','dashboard_manifest','artifact_manifest','integrity_sha256'
];

function createConstellation({ title = 'My Constellation', prompt = '', sourceCount = 0 } = {}) {
  if (typeof title !== 'string' || !title.trim()) throw new TypeError('title is required');
  if (typeof prompt !== 'string') throw new TypeError('prompt must be a string');
  if (!Number.isInteger(sourceCount) || sourceCount < 0) throw new RangeError('sourceCount must be a non-negative integer');
  return {
    id: 'c25_' + crypto.randomUUID(),
    product: 'Constellation25',
    alias: 'C25',
    platform: 'SovereignGTP',
    execution_mode: 'all_as_one',
    title: title.trim(),
    prompt,
    source_count: sourceCount,
    outputs: OUTPUTS.map(name => ({ name, status: 'pending', artifact: null })),
    completion: { state: 'awaiting_execution', message: 'Your Constellation workspace is ready to build.', review_required: true },
    created_at: new Date().toISOString()
  };
}
module.exports = { OUTPUTS, createConstellation };
