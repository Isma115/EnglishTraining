const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { matches } = require('../desktop/renderer/core.js');
const data = name => JSON.parse(fs.readFileSync(path.join(__dirname, '../data', `${name}.json`), 'utf8'));

test('all bundled sets have their required counts and unique IDs', () => {
  for (const [name, count] of Object.entries({ grammar: 200, reading: 50, writing: 200, vocabulary: 20000, translation: 800 })) {
    const set = data(name);
    assert.equal(set.schemaVersion, 1);
    assert.equal(set.items.length, count);
    assert.equal(new Set(set.items.map(item => item.id)).size, count);
    assert.equal(
      fs.readFileSync(path.join(__dirname, '../data', `${name}.json`), 'utf8'),
      fs.readFileSync(path.join(__dirname, '../mobile/assets/data', `${name}.json`), 'utf8'),
      'Electron and Flutter must bundle exactly the same set',
    );
  }
});

test('translation has 800 distinct Spanish prompts and English references in 25 blocks', () => {
  const set = data('translation');
  assert.deepEqual(set.levelRange, ['B2']);
  assert.equal(new Set(set.items.map(item => item.spanish)).size, 800);
  const topics = new Map();
  set.items.forEach((item, index) => {
    assert.equal(item.id, `t${String(index + 1).padStart(3, '0')}`);
    assert.equal(item.level, 'B2');
    for (const key of ['topic', 'spanish', 'english']) {
      assert.equal(typeof item[key], 'string');
      assert.ok(item[key].trim());
      assert.ok(!item[key].includes('\uFFFD'));
    }
    assert.notEqual(item.spanish, item.english);
    topics.set(item.topic, (topics.get(item.topic) || 0) + 1);
  });
  assert.equal(topics.size, 25);
  assert.ok([...topics.values()].every(count => count === 32));
});
test('B2 grammar shows only a base verb and time reference beside each gap', () => {
  const set = data('grammar');
  assert.deepEqual(set.levelRange, ['B2']);
  const items = set.items;
  assert.equal(new Set(items.map(item => item.prompt)).size, 200);
  for (const item of items) {
    assert.equal(item.level, 'B2');
    assert.ok(item.context.trim(), item.id);
    assert.ok(item.context.split(/\s+/).length <= 6, item.id);
    assert.ok(item.verb.trim(), item.id);
    assert.ok(item.prompt.endsWith(` (${item.verb}; ${item.context})`));
    assert.ok(!Object.hasOwn(item, 'choices'));
    assert.ok(!item.prompt.includes(' / '));
    assert.ok(!item.prompt.includes('\n'));
    assert.equal(item.prompt.split('____').length, 2);
    assert.ok(item.answers.length > 0);
    assert.ok(item.answers.every(answer => answer.trim()));
    assert.equal(new Set(item.answers).size, item.answers.length);
    assert.equal(item.completed, item.prompt.replace('____', item.answers[0]));
  }
});
test('the unnecessary booking exercise establishes the action and fixes the modal', () => {
  const item = data('grammar').items.find(item => item.id === 'g069');
  assert.match(item.prompt, /Mia booked a table, but the restaurant was empty/);
  assert.match(item.prompt, /She need not ____ one/);
  assert.ok(matches('have booked', item.answers));
  assert.ok(!matches('booked', item.answers), 'need not booked is not grammatical');
});
test('past modal exercises fix the modal rather than asking learners to guess it', () => {
  const items = data('grammar').items;
  const deduction = items.find(item => item.id === 'g071');
  assert.match(deduction.prompt, /cannot ____/);
  assert.ok(matches('have committed', deduction.answers));
  assert.ok(!matches('committed', deduction.answers));
  const criticism = items.find(item => item.id === 'g076');
  assert.match(criticism.prompt, /should ____/);
  assert.ok(matches('have driven', criticism.answers));
  assert.ok(matches('have been driving', criticism.answers));
  assert.ok(!matches('driven', criticism.answers));
});
test('equivalent valid forms are accepted without showing answer options', () => {
  const items = data('grammar').items;
  for (const [id, forms] of [
    ['g016', ['arrives', 'has arrived']],
    ['g026', ['have been working', 'have worked']],
    ['g136', ['taking', 'having taken']],
    ['g146', ['meeting', 'having met']],
    ['g181', ['to travel', 'travelling', 'traveling']],
  ]) {
    const item = items.find(item => item.id === id);
    forms.forEach(form => assert.ok(matches(form, item.answers), `${id}: ${form}`));
    assert.ok(!Object.hasOwn(item, 'choices'));
    assert.ok(!item.prompt.includes(' / '));
  }
});
test('every reading has original text and reference answers for manual checking', () => {
  const items = data('reading').items;
  assert.equal(new Set(items.map(item => item.text)).size, 50);
  for (const item of items) {
    assert.match(item.level, /^(B2|C1)$/);
    assert.ok(item.text.split(/\s+/).length >= 130);
    assert.equal(item.questions.length, 3);
    item.questions.forEach(question => {
      assert.ok(question.question.endsWith('?'));
      assert.ok(question.answer.length > 20);
    });
  }
});
test('writing topics are distinct B2–C1 prompts', () => {
  const items = data('writing').items;
  assert.equal(new Set(items.map(item => item.topic)).size, 200);
  items.forEach(item => assert.match(item.level, /^(B2|C1)$/));
});
test('vocabulary contains 20,000 distinct headwords and both difficulty bands', () => {
  const set = data('vocabulary');
  assert.equal(new Set(set.items.map(item => item.english)).size, 20000);
  assert.deepEqual([...new Set(set.items.map(item => item.difficulty))].sort(), ['Frecuente', 'Menos frecuente']);
  for (const item of set.items) {
    assert.ok(item.english.trim());
    assert.ok(item.spanish.length);
    assert.equal(new Set(item.spanish).size, item.spanish.length);
    assert.ok(item.spanish.every(word => typeof word === 'string' && word.trim()));
  }
  for (const source of set.sources) {
    if (source.licenseFile) assert.ok(fs.existsSync(path.join(__dirname, '..', source.licenseFile)));
    if (source.sourceFile) assert.ok(fs.existsSync(path.join(__dirname, '..', source.sourceFile)));
  }
});
