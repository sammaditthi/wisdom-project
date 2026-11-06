import assert from 'node:assert/strict';
import { test } from 'node:test';
import { build } from './helpers.js';

// The Worker has a 10 ms CPU budget; 100 ms is far above normal and below the old blow-ups.
function underBudget(text: string): void {
  const t0 = performance.now();
  build(text);
  const ms = performance.now() - t0;
  assert.ok(ms < 100, `took ${ms.toFixed(1)} ms`);
}

test('refs joined by marks, no closing bracket', () => {
  const refs = Array.from({ length: 14 }, (_, i) => `SN ${i + 1}`);
  underBudget('(' + refs.join('***') + '***');
});

test('a long run of spaces before a ref', () => {
  underBudget('A' + ' '.repeat(20000) + 'B (SN 15.3)');
});
