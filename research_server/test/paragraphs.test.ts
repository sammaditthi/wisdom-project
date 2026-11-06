import assert from 'node:assert/strict';
import { test } from 'node:test';
import { build, chipsOf, paragraphsOf, repoJson } from './helpers.js';

// Shared with the app's widget test: the Worker, the app and paragraphsOf
// must split alike.
const cases = repoJson('test/fixtures/research_answer_paragraphs.json') as {
  name: string;
  text: string;
  paragraphs: string[];
}[];

for (const c of cases) {
  test(`paragraphs: ${c.name}`, () => {
    // The Worker: one chip per paragraph.
    const chips = chipsOf(build(c.text).answer).filter((u) => u === 'sn15.3');
    assert.equal(chips.length, c.paragraphs.length);
    // The helper's copy, which the chips invariants split with.
    assert.deepEqual(paragraphsOf(c.text), c.paragraphs);
  });
}
