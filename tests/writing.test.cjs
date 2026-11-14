const test = require('node:test');
const assert = require('node:assert/strict');
const { writingDiff } = require('../desktop/renderer/core.js');
const cases = require('./fixtures/writing-diff.json');

test('writing comparison highlights word and punctuation changes without losing either text', () => {
  for (const item of cases) {
    const changes = writingDiff(item.original, item.corrected);
    assert.equal(changes.filter(part => part.kind !== 'added').map(part => part.text).join(''), item.original);
    assert.equal(changes.filter(part => part.kind !== 'removed').map(part => part.text).join(''), item.corrected);
    assert.ok(changes.every(part => part.text.length > 0));
    if (item.expected) assert.deepEqual(changes, item.expected);
    if (item.original === item.corrected) assert.ok(changes.every(part => part.kind === 'equal'));
  }
});

test('writing comparison retains long paragraphs surrounding a correction', () => {
  const paragraph = 'A long paragraph about our holiday. '.repeat(2000);
  assert.deepEqual(writingDiff(paragraph + 'was ' + paragraph, paragraph + 'were ' + paragraph), [
    { kind: 'equal', text: paragraph }, { kind: 'removed', text: 'was' },
    { kind: 'added', text: 'were' }, { kind: 'equal', text: ' ' + paragraph },
  ]);
});
