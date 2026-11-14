const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const core = require('../desktop/renderer/core.js');

// Exercise the renderer's actual controls without starting an Electron window.
class Element {
  constructor(tag, text) {
    this.tag = tag;
    this.textContent = text;
    this.children = [];
    this.attributes = {};
    this.listeners = {};
    this.classList = { add: name => { this.className = name; } };
  }
  append(...children) { this.children.push(...children); }
  replaceChildren(...children) { this.children = children; }
  setAttribute(name, value) { this.attributes[name] = value; }
  addEventListener(name, listener) { this.listeners[name] = listener; }
  focus() {}
  all() { return this.children.flatMap(child => [child, ...child.all()]); }
  querySelector(selector) {
    return this.all().find(node => selector.startsWith('[')
      ? node.attributes['aria-controls'] === 'translation-reference'
      : node.tag === selector);
  }
}

function translationApp() {
  const main = new Element('main');
  const context = vm.createContext({
    PracticeCore: { ...core, shuffle: items => core.shuffle(items, () => 0) },
    localStorage: { getItem: () => null },
    document: {
      createElement: tag => new Element(tag),
      querySelector: selector => selector === '#content' ? main : null,
      querySelectorAll: () => [],
    },
    window: { practice: { loadSets: () => new Promise(() => {}) } },
  });
  const items = JSON.parse(fs.readFileSync(path.join(__dirname, '../data/translation.json'), 'utf8')).items;
  vm.runInContext(fs.readFileSync(path.join(__dirname, '../desktop/renderer/app.js'), 'utf8'), context);
  context.testSets = { translation: { items } };
  vm.runInContext("sets = testSets; view = 'translation'; render();", context);
  const control = text => main.all().find(node => node.tag === 'button' && node.textContent === text);
  return {
    main, items, control,
    showWriting: () => vm.runInContext("writing ||= { topic: 'Practice writing' }; view = 'writing'; render();", context),
    showTranslation: () => vm.runInContext("view = 'translation'; render();", context),
    prompt: () => main.all().find(node => node.className === 'sentence').textContent,
    field: () => main.querySelector('textarea'),
    counter: () => main.all().find(node => node.tag === 'p').textContent,
    reference: () => main.all().find(node => node.id === 'translation-reference'),
    click: text => {
      const button = control(text);
      assert.ok(button && !button.disabled, text);
      button.listeners.click();
    },
    select: topic => {
      const select = main.querySelector('select');
      select.value = topic;
      select.listeners.change();
    },
    render: () => vm.runInContext('render()', context),
  };
}

test('mixed translation visits all 800 phrases once and retains the original ordered blocks', () => {
  const app = translationApp();
  assert.equal(app.prompt(), app.items[0].spanish);
  app.select('mixed');
  assert.equal(app.prompt(), app.items[1].spanish);
  assert.ok(app.control('Anterior').disabled);
  const visited = new Set();
  for (let i = 0; i < app.items.length; i++) {
    assert.match(app.counter(), new RegExp(`^Frase ${i + 1} de 800`));
    assert.ok(!visited.has(app.prompt()));
    visited.add(app.prompt());
    if (i < app.items.length - 1) app.click('Siguiente');
  }
  assert.deepEqual(visited, new Set(app.items.map(item => item.spanish)));
  assert.ok(app.control('Siguiente').disabled);
  app.click('Volver a mezclar');
  assert.match(app.counter(), /^Frase 1 de 800/);
  app.select(app.items[0].topic);
  assert.equal(app.prompt(), app.items[0].spanish);
  assert.match(app.counter(), /^Frase 1 de 32/);
  app.select('');
  assert.match(app.counter(), /^Frase 1 de 800/);
  assert.equal(app.control('Volver a mezclar'), undefined);
});

test('Writing displays the original and correction side by side and retains both when editing', () => {
  const app = translationApp();
  app.showWriting();
  const fields = app.main.all().filter(node => node.tag === 'textarea');
  fields[0].value = 'I has a dog.\nA <b>pet</b>.';
  fields[0].listeners.input();
  fields[1].value = 'I have a dog.\nA <b>pet</b>.';
  fields[1].listeners.input();
  app.click('Comparar');
  const panels = app.main.all().filter(node => node.className === 'writing-diff');
  assert.equal(panels.length, 2);
  assert.equal(panels[0].children.map(node => node.textContent).join(''), fields[0].value);
  assert.equal(panels[1].children.map(node => node.textContent).join(''), fields[1].value);
  assert.equal(panels[0].all().find(node => node.tag === 'del').textContent, 'has');
  assert.equal(panels[1].all().find(node => node.tag === 'ins').textContent, 'have');
  app.showTranslation();
  app.showWriting();
  assert.ok(app.control('Editar textos'));
  app.click('Editar textos');
  const restored = app.main.all().filter(node => node.tag === 'textarea');
  assert.deepEqual(restored.map(node => node.value), fields.map(node => node.value));
  restored[1].value = restored[0].value;
  restored[1].listeners.input();
  app.click('Comparar');
  assert.ok(app.main.all().some(node => node.textContent === 'Sin diferencias.'));
});

test('mixed translation retains drafts and order on reveal, backtracking and rerender', () => {
  const app = translationApp();
  app.select('mixed');
  const first = app.prompt();
  app.field().value = 'My mixed draft.';
  app.field().listeners.input();
  app.click('Mostrar traducción');
  assert.equal(app.reference().hidden, false);
  assert.equal(app.prompt(), first);
  app.click('Siguiente');
  assert.equal(app.reference().hidden, true);
  assert.notEqual(app.prompt(), first);
  app.click('Anterior');
  assert.equal(app.prompt(), first);
  assert.equal(app.field().value, 'My mixed draft.');
  app.render();
  assert.equal(app.prompt(), first);
  assert.equal(app.field().value, 'My mixed draft.');
  app.click('Mostrar traducción');
  app.click('Volver a mezclar');
  assert.equal(app.reference().hidden, true);
  assert.equal(app.field().value, 'My mixed draft.');
  app.select('');
  app.click('Siguiente');
  assert.equal(app.prompt(), first);
  assert.equal(app.field().value, 'My mixed draft.');
});
