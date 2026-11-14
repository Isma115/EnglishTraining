const test = require('node:test');
const assert = require('node:assert/strict');
const { matches, parseProgress, review } = require('../desktop/renderer/core.js');
const fixture = require('./fixtures/practice-parity.json');

test('desktop follows the shared desktop/mobile answer and progress cases', () => {
  for (const item of fixture.answers) {
    assert.equal(matches(item.answer, item.accepted), item.correct, item.answer);
  }
  for (const item of fixture.progress) {
    if (item.error) assert.throws(() => parseProgress(item.text));
    else assert.deepEqual(parseProgress(item.text), item.expected);
  }
});

test('desktop follows the shared desktop/mobile review schedule', () => {
  let state;
  for (const { correct, now, ...expected } of fixture.reviews) {
    state = review(state, correct, now);
    assert.ok(Math.abs(state.ease - expected.ease) < 1e-10);
    const { ease, ...rest } = state;
    const { ease: expectedEase, ...expectedRest } = expected;
    assert.deepEqual(rest, expectedRest);
  }
});
