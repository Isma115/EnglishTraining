const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const data = name => JSON.parse(fs.readFileSync(path.join(__dirname, '../data', `${name}.json`), 'utf8'));

test('all four bundled sets have their required counts and unique IDs', () => {
  for (const [name, count] of Object.entries({ grammar: 200, reading: 50, writing: 200, vocabulary: 20000 })) {
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
test('grammar has exactly one gap and a complete reference sentence', () => {
  const items = data('grammar').items;
  assert.equal(new Set(items.map(item => item.prompt)).size, 200);
  for (const item of items) {
    assert.match(item.level, /^(B2|C1)$/);
    assert.equal(item.prompt.split('____').length, 2);
    assert.ok(item.answers.length > 0);
    assert.equal(item.completed, item.prompt.replace('____', item.answers[0]));
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
