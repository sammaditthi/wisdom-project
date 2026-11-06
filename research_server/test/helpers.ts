// Shared by the Worker tests. Importing this file makes any live fetch throw.

import { readFileSync } from 'node:fs';
import { GenerateResponse } from '../src/gemini.js';
import { buildResponse } from '../src/pipeline.js';

globalThis.fetch = (() => {
  throw new Error('live fetch in a unit test');
}) as typeof fetch;

// A JSON file by its path from the repo root (the tests run from dist/test/).
export const repoJson = (path: string): unknown =>
  JSON.parse(readFileSync(new URL(`../../../${path}`, import.meta.url), 'utf8'));

export interface Support {
  end: number;
  idx: number[];
}

// One grounding chunk per store uid; `end` counts UTF-8 bytes.
export function respOf(
  store: string[],
  supports: Support[] = [],
  parts = 1,
): GenerateResponse {
  return {
    candidates: [
      {
        content: { parts: Array.from({ length: parts }, () => ({ text: 'x' })) },
        groundingMetadata: {
          groundingChunks: store.map((uid) => ({
            retrievedContext: { title: uid, text: 'H\nbody' },
          })),
          groundingSupports: supports.map((s) => ({
            segment: { endIndex: s.end },
            groundingChunkIndices: s.idx,
          })),
        },
      },
    ],
  };
}

export function build(text: string, store: string[] = [], supports: Support[] = [], parts = 1) {
  return buildResponse(text, respOf(store, supports, parts), 'q', false, 220);
}

export const chipsOf = (s: string): string[] =>
  [...s.matchAll(/\[\[cite:([^\]\s]+)\]\]/g)].map((m) => m[1]!);

const BULLET = /^\s*[-*]\s+/;

// Copy of the app's paragraph rule (_parseBlocks), checked against the shared
// fixture in paragraphs.test.ts.
export function paragraphsOf(text: string): string[] {
  const out: string[] = [];
  let para: string[] = [];
  const flush = () => {
    if (para.length) out.push(para.join(' '));
    para = [];
  };
  for (const raw of text.split('\n')) {
    const line = raw.trim();
    if (BULLET.test(line)) {
      flush();
      out.push(line.replace(BULLET, ''));
    } else if (!line) flush();
    else para.push(line);
  }
  flush();
  return out;
}
