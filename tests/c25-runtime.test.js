'use strict';
const test = require('node:test');
const assert = require('node:assert/strict');
const { createConstellation, OUTPUTS } = require('../core/constellation');

test('C25 manifest includes All-As-One output contract', () => {
  const c = createConstellation({ title: 'Test build', prompt: 'Organize my sources', sourceCount: 2 });
  assert.equal(c.product, 'Constellation25');
  assert.equal(c.execution_mode, 'all_as_one');
  assert.equal(c.source_count, 2);
  assert.equal(c.outputs.length, OUTPUTS.length);
  assert.ok(c.outputs.some(x => x.name === 'interactive_build'));
  assert.equal(c.completion.state, 'awaiting_execution');
});
test('invalid source count is rejected', () => {
  assert.throws(() => createConstellation({ sourceCount: -1 }), /sourceCount/);
});
