const test = require('node:test');
const assert = require('node:assert/strict');
const { matches, pick, review, nextCard } = require('../desktop/renderer/core.js');

test('correction tolerates case, spacing, smart apostrophes and final punctuation', () => {
  assert.ok(matches('  WOULD   HAVE BEEN. ', ['would have been']));
  assert.ok(matches('Hadn’t', ["hadn't"]));
  assert.ok(!matches('would be', ['would have been']));
  assert.ok(!matches('si', ['sí']));
});
test('a new random exercise does not immediately repeat the previous one', () => {
  const cards = [{ id: 'a' }, { id: 'b' }];
  assert.equal(pick(cards, 'a', () => 0).id, 'b');
  assert.equal(pick([{ id: 'a' }], 'a', () => 0).id, 'a');
});
test('successful recall expands intervals and failed recall returns soon', () => {
  const first = review(null, true, 0);
  const second = review(first, true, 0);
  const third = review(second, true, 0);
  assert.equal(first.interval, 1);
  assert.equal(second.interval, 3);
  assert.ok(third.interval > second.interval);
  const failed = review(third, false, 0);
  assert.equal(failed.repetitions, 0);
  assert.equal(failed.due, 60000);
  let state = failed;
  for (let i = 0; i < 20; i++) state = review(state, false, 0);
  assert.equal(state.ease, 1.3);
});
test('due reviews precede unseen cards and future reviews are not repeated early', () => {
  const cards = [{ id: 'a' }, { id: 'b' }, { id: 'c' }];
  assert.equal(nextCard(cards, { a: { due: 300 }, b: { due: 100 } }, null, 400).id, 'b');
  assert.equal(nextCard(cards, { a: { due: 300 }, b: { due: 100 } }, null, 0).id, 'c');
  assert.equal(nextCard(cards.slice(0, 2), { a: { due: 300 }, b: { due: 100 } }, null, 0), null);
});
