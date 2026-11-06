import assert from 'node:assert/strict';
import { describe, test } from 'node:test';
import { citedHolding, REF_IN_PROSE, refFromUid, uidFromRef } from '../src/refs.js';
import { repoJson } from './helpers.js';

describe('uidFromRef', () => {
  test('spellings of one ref', () => {
    for (const r of ['SN 15.3', 'SN 15:3', 'sn15.3']) assert.equal(uidFromRef(r), 'sn15.3');
  });
  test('multi-word books and ranges', () => {
    assert.equal(uidFromRef('Tha Ap 1'), 'tha-ap1');
    assert.equal(uidFromRef('Bu Pj 1'), 'pli-tv-bu-vb-pj1');
    assert.equal(uidFromRef('Dhp 1-20'), 'dhp1-20');
  });
  test('aliases', () => {
    assert.equal(uidFromRef('Khp 1'), 'kp1');
    assert.equal(uidFromRef('It 5'), 'iti5');
    assert.equal(uidFromRef('Nm 1'), 'mnd1');
    assert.equal(uidFromRef('Nc 1'), 'cnd1');
  });
  test('not in the table', () => {
    assert.equal(uidFromRef('Mil 1'), null);
    assert.equal(uidFromRef('KN 1'), null);
  });
});

describe('refFromUid', () => {
  test('uid to display ref', () => {
    assert.equal(refFromUid('kp1'), 'Kp 1');
    assert.equal(refFromUid('pli-tv-bu-vb-pj1'), 'Bu Pj 1');
    assert.equal(refFromUid('dhp1-20'), 'Dhp 1-20');
    assert.equal(refFromUid('sn15.3'), 'SN 15.3');
  });
  test('snp is not sn', () => {
    assert.equal(refFromUid('snp1.8'), 'Snp 1.8');
  });
  test('no number: unchanged', () => {
    assert.equal(refFromUid('pli-tv-bu-pm'), 'pli-tv-bu-pm');
  });
});

describe('REF_IN_PROSE', () => {
  test('keeps case, so "an 8" and "it" stay words', () => {
    const text = 'Read an 8 page essay; AN 8 is apt. Tha Ap 1 and SN 15:3.';
    assert.deepEqual(text.match(REF_IN_PROSE), ['AN 8', 'Tha Ap 1', 'SN 15:3']);
  });
});

describe('citedHolding', () => {
  const cited = new Set(['dhp1-20', 'dhp21-32', 'an1.1-10', 'sn15.3', 'sn1-nalavagga']);
  test('itself', () => assert.equal(citedHolding('sn15.3', cited), 'sn15.3'));
  test('a range holding the number', () => {
    assert.equal(citedHolding('dhp1', cited), 'dhp1-20');
    assert.equal(citedHolding('dhp20', cited), 'dhp1-20');
    assert.equal(citedHolding('dhp21', cited), 'dhp21-32');
    assert.equal(citedHolding('an1.1', cited), 'an1.1-10');
    assert.equal(citedHolding('an1.5', cited), 'an1.1-10');
  });
  test('none', () => {
    assert.equal(citedHolding('dhp999', cited), null);
    assert.equal(citedHolding('sn1.5', cited), null); // a chapter uid isn't a range
    assert.equal(citedHolding('pli-tv-bu-pm', cited), null);
    assert.equal(citedHolding('dhp1-5', cited), null);
  });
});

test('every uid in the lookup file round-trips (BOOKS has not drifted)', () => {
  const { map } = repoJson('assets/data/sc-to-bjt.json') as { map: Record<string, string> };
  const bad = Object.keys(map).filter(
    (uid) => /\d$/.test(uid) && uid !== 'an2-balavagga2' && uidFromRef(refFromUid(uid)) !== uid,
  );
  assert.deepEqual(bad, []);
});
