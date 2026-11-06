import assert from 'node:assert/strict';
import { describe, test } from 'node:test';
import { build, chipsOf, paragraphsOf, Support } from './helpers.js';

interface Case {
  name: string;
  input: string;
  store?: string[];
  supports?: Support[];
  parts?: number;
  expected: string;
  citations?: string[]; // checked when given
}

// Every chip is a citation, no citation twice, no chip twice in a paragraph.
function invariants(answer: string, citations: { uid: string }[]): void {
  const uids = citations.map((x) => x.uid);
  assert.equal(new Set(uids).size, uids.length, 'citation uid twice');
  for (const uid of chipsOf(answer)) assert.ok(uids.includes(uid), `chip ${uid} not in citations`);
  for (const p of paragraphsOf(answer)) {
    const chips = chipsOf(p);
    assert.equal(new Set(chips).size, chips.length, `paragraph repeats a chip: ${p}`);
  }
}

function run(cases: Case[]): void {
  for (const c of cases) {
    test(c.name, () => {
      const r = build(c.input, c.store, c.supports, c.parts);
      assert.equal(r.answer, c.expected);
      if (c.citations) assert.deepEqual(r.citations.map((x) => x.uid), c.citations);
      invariants(r.answer, r.citations);
    });
  }
}

describe('2. chips from the model references', () => {
  run([
    { name: '1 a ref inside a cited range is that range', input: 'Hatred never ceases by hatred (Dhp 5).', store: ['dhp1-20'], expected: 'Hatred never ceases by hatred [[cite:dhp1-20]].', citations: ['dhp1-20'] },
    { name: '2 a repeat in brackets goes, with the space before it', input: 'X (SN 15.3). Y (SN 15.3), Z (SN 15.3) end.', expected: 'X [[cite:sn15.3]]. Y, Z end.', citations: ['sn15.3'] },
    { name: '3 repeat inside one bracket', input: 'X (SN 15.3; SN 15.3).', expected: 'X [[cite:sn15.3]].' },
    { name: '4 the repeat separator goes, the rest stay', input: 'X (AN 1.1). Y (MN 1; AN 1.1; DN 2).', expected: 'X [[cite:an1.1]]. Y [[cite:mn1]]; [[cite:dn2]].' },
    { name: '5 sentence ref first, bracket repeat goes', input: 'As SN 15.3 says, X (SN 15.3).', expected: 'As [[cite:sn15.3]] says, X.' },
    { name: '6 a repeat in the sentence stays as words', input: 'X (SN 15.3). As SN 15.3 says, Y.', expected: 'X [[cite:sn15.3]]. As SN 15.3 says, Y.' },
    { name: '7 bold in brackets', input: 'X (**MN 138**). Y (**MN 138**).', expected: 'X [[cite:mn138]]. Y.' },
    { name: '8 a chip drops the marks, a repeat keeps them', input: '**MN 138** says X. Later **MN 138** again.', expected: '[[cite:mn138]] says X. Later **MN 138** again.' },
    { name: '9 triple marks', input: 'X ***SN 15.3*** and (***SN 15.3***).', expected: 'X [[cite:sn15.3]] and.' },
    { name: '10 italic round a bracket', input: 'text *(SN 15.3)* more.', expected: 'text *[[cite:sn15.3]]* more.' },
    { name: '11 a bracket with words in it stays', input: 'X (SN 15.3). Y (see SN 15.3).', expected: 'X [[cite:sn15.3]]. Y (see SN 15.3).' },
    { name: '12 a new paragraph gets its own chip', input: 'X (SN 15.3).\n\nY (SN 15.3).', expected: 'X [[cite:sn15.3]].\n\nY [[cite:sn15.3]].' },
    { name: '13 each bullet, and the line after one', input: '- one (SN 15.3)\n- two (SN 15.3)\nafter bullet (SN 15.3)', expected: '- one [[cite:sn15.3]]\n- two [[cite:sn15.3]]\nafter bullet [[cite:sn15.3]]' },
    { name: '14 soft-wrapped lines are one paragraph', input: 'line one (SN 15.3)\nline two (SN 15.3)', expected: 'line one [[cite:sn15.3]]\nline two' },
    { name: '15 Windows line ends', input: 'A (SN 15.3)\r\nB (SN 15.3)\r\n\r\nC (SN 15.3)', expected: 'A [[cite:sn15.3]]\r\nB\r\n\r\nC [[cite:sn15.3]]' },
    { name: '16 tab before a bracket', input: 'A (SN 15.3) B \t(SN 15.3).', expected: 'A [[cite:sn15.3]] B.' },
    { name: '17 multi-word books', input: 'Rule (Bu Pj 1). Verse (Tha Ap 1; Bu Pj 1).', expected: 'Rule [[cite:pli-tv-bu-vb-pj1]]. Verse [[cite:tha-ap1]].' },
    { name: '18 marks joining two refs', input: 'X (**SN 15.3**and**AN 1.1**).', expected: 'X [[cite:sn15.3]]and[[cite:an1.1]].' },
    { name: '19 a range the model wrote stays its own', input: 'X (Dhp 1-5).', store: ['dhp1-20'], expected: 'X [[cite:dhp1-5]].', citations: ['dhp1-20', 'dhp1-5'] },
    { name: '20 a chapter uid is not a range', input: 'X (SN 1.5).', store: ['sn1-nalavagga'], expected: 'X [[cite:sn1.5]].', citations: ['sn1-nalavagga', 'sn1.5'] },
    { name: '21 the chip names the range (accepted)', input: 'Dhp 5 says hatred never ceases; Dhp 6 adds more.', store: ['dhp1-20'], expected: '[[cite:dhp1-20]] says hatred never ceases; Dhp 6 adds more.', citations: ['dhp1-20'] },
    { name: '22 no range in the store: own uid', input: 'AN 1.1 says X (AN 1.1).', expected: '[[cite:an1.1]] says X.', citations: ['an1.1'] },
    { name: '23 not in the book table', input: 'X (Mil 5).', expected: 'X (Mil 5).', citations: [] },
    { name: '24 "an 8" is a word', input: 'Read an 8 page essay (SN 15.3).', expected: 'Read an 8 page essay [[cite:sn15.3]].' },
    { name: '25 Sinhala', input: 'වෛරයෙන් වෛරය නොසංසිඳේ (Dhp 5). නැවතත් (Dhp 5).', store: ['dhp1-20'], expected: 'වෛරයෙන් වෛරය නොසංසිඳේ [[cite:dhp1-20]]. නැවතත්.', citations: ['dhp1-20'] },
    { name: '26 plain answer', input: 'Plain answer.', expected: 'Plain answer.', citations: [] },
  ]);
});

const s1 = 'වෛරයෙන් වෛරය නොසංසිඳේ.';
const f4 = s1 + ' අවෛරයෙන් සංසිඳේ.';

const bytes = (s: string): number => Buffer.byteLength(s);

describe('3. chips from grounding supports (fallback)', () => {
  run([
    {
      name: 'F1 one chip per source per paragraph',
      input: 'First sentence here. Second sentence here.\n\nThird one.',
      store: ['sn15.3', 'an1.1-10'],
      supports: [{ end: 20, idx: [0] }, { end: 42, idx: [0, 1] }, { end: 54, idx: [0] }],
      expected: 'First sentence here.[[cite:sn15.3]] Second sentence here.[[cite:an1.1-10]]\n\nThird one.[[cite:sn15.3]]',
    },
    {
      name: 'F2 text with a chip injects nothing',
      input: 'X (SN 15.3). Y.',
      store: ['sn15.3', 'mn1'],
      supports: [{ end: 15, idx: [1] }],
      expected: 'X [[cite:sn15.3]]. Y.',
      citations: ['sn15.3', 'mn1'],
    },
    { name: 'F3 multi-part answers skip injection', input: 'One. Two.', store: ['sn15.3'], supports: [{ end: 4, idx: [0] }], parts: 2, expected: 'One. Two.' },
    {
      name: 'F4 Sinhala byte offsets',
      input: f4,
      store: ['dhp1-20', 'sn15.3'],
      supports: [{ end: bytes(s1), idx: [0] }, { end: bytes(f4), idx: [0, 1] }],
      expected: s1 + '[[cite:dhp1-20]] අවෛරයෙන් සංසිඳේ.[[cite:sn15.3]]',
    },
    { name: 'F5 no supports', input: 'Plain.', store: ['sn15.3'], expected: 'Plain.' },
  ]);
});

// Made-up answers; each expectation was worked out by hand from the rules.
const a1 = 'එවං මෙ සුතං.';
const a2 = ' නොසංසිඳේ.';
const a3 = ' අවෛරයෙන්.';
const a4 = 'අවසානය.';
const sinhala = a1 + a2 + a3 + '\n\n' + a4;

describe('4. whole answers', () => {
  run([
    {
      name: 'prose with brackets and a bullet list',
      input: 'Craving causes suffering (SN 56.11). The Buddha also taught restraint (AN 4.14; SN 56.11).\n\n- Ethics (Dhp 183)\n- Wisdom (Dhp 183)',
      expected: 'Craving causes suffering [[cite:sn56.11]]. The Buddha also taught restraint [[cite:an4.14]].\n\n- Ethics [[cite:dhp183]]\n- Wisdom [[cite:dhp183]]',
      citations: ['sn56.11', 'an4.14', 'dhp183'],
    },
    {
      name: 'bold brackets repeated across paragraphs',
      input: 'First (**MN 10**) and again (**MN 10**).\n\nSecond (**MN 10**).',
      expected: 'First [[cite:mn10]] and again.\n\nSecond [[cite:mn10]].',
      citations: ['mn10'],
    },
    {
      name: 'AN 1.1 with its range in the store: one chip, no Other sources',
      input: 'The first teaching, AN 1.1, concerns the mind (AN 1.1).',
      store: ['an1.1-10'],
      expected: 'The first teaching, [[cite:an1.1-10]], concerns the mind.',
      citations: ['an1.1-10'],
    },
    {
      name: 'Sinhala fallback with repeated supports',
      input: sinhala,
      store: ['dhp1-20', 'sn15.3'],
      supports: [
        { end: bytes(a1), idx: [0] },
        { end: bytes(a1 + a2), idx: [0] },
        { end: bytes(a1 + a2 + a3), idx: [0, 1] },
        { end: bytes(sinhala), idx: [0] },
      ],
      expected: a1 + '[[cite:dhp1-20]]' + a2 + a3 + '[[cite:sn15.3]]\n\n' + a4 + '[[cite:dhp1-20]]',
      citations: ['dhp1-20', 'sn15.3'],
    },
    {
      name: 'refs in the sentence mixed with repeats in brackets',
      input: 'As MN 10 says, mindfulness helps (MN 10; SN 47.1). Compare SN 47.1 and AN 1.1 (see AN 1.1).',
      expected: 'As [[cite:mn10]] says, mindfulness helps [[cite:sn47.1]]. Compare SN 47.1 and [[cite:an1.1]] (see AN 1.1).',
    },
    { name: 'no refs and no supports', input: 'Nothing is cited here.', expected: 'Nothing is cited here.', citations: [] },
  ]);
});
