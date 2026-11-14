const test = require('node:test');
const assert = require('node:assert/strict');
const vm = require('node:vm');
const path = require('node:path');
const fs = require('node:fs/promises');
const os = require('node:os');

async function harness() {
  const handlers = new Map();
  const startup = [];
  let selection = { canceled: true }, preferences, windowOptions;
  class BrowserWindow {
    constructor(options) {
      startup.push('window');
      windowOptions = options;
      preferences = options.webPreferences;
      this.webContents = { setWindowOpenHandler() {}, on() {} };
    }
    loadFile() {}
    static fromWebContents() { return null; }
  }
  const electron = {
    app: {
      disableHardwareAcceleration: () => startup.push('software-rendering'),
      whenReady: () => { startup.push('ready'); return Promise.resolve(); },
      on() {}, quit() {},
    },
    BrowserWindow,
    screen: { getPrimaryDisplay: () => ({ workArea: { x: 24, y: 40, width: 1440, height: 860 } }) },
    Menu: { setApplicationMenu() {} },
    ipcMain: { handle: (name, callback) => handlers.set(name, callback) },
    dialog: { showSaveDialog: async () => selection },
  };
  const filename = path.join(__dirname, '../desktop/main.cjs');
  vm.runInNewContext(await fs.readFile(filename, 'utf8'), {
    require: name => name === 'electron' ? electron : require(name),
    __dirname: path.dirname(filename), process,
  }, { filename });
  await new Promise(resolve => setImmediate(resolve));
  return { handlers, select: value => selection = value, preferences, windowOptions, startup };
}

test('software rendering is configured before Electron is ready and creates a window', async () => {
  const { startup } = await harness();
  assert.deepEqual(startup, ['software-rendering', 'ready', 'window']);
});

test('Electron loads all bundled sets with an isolated renderer', async () => {
  const app = await harness();
  const sets = await app.handlers.get('load-sets')();
  assert.equal(sets.grammar.items.length, 200);
  assert.equal(sets.reading.items.length, 50);
  assert.equal(sets.writing.items.length, 200);
  assert.equal(sets.vocabulary.items.length, 20000);
  assert.equal(sets.translation.items.length, 800);
  assert.equal(app.preferences.contextIsolation, true);
  assert.equal(app.preferences.nodeIntegration, false);
  assert.equal(app.preferences.sandbox, true);
});

test('Writing export preserves the exact draft as UTF-8 and adds .txt only when needed', async () => {
  const app = await harness();
  const directory = await fs.mkdtemp(path.join(os.tmpdir(), 'writing-test-'));
  try {
    const draft = '  Un ejemplo: español, café.\nSecond paragraph.\n';
    for (const name of ['draft', 'draft.TXT']) {
      const filePath = path.join(directory, name);
      app.select({ canceled: false, filePath });
      assert.equal(await app.handlers.get('save-writing')({ sender: {} }, draft), true);
      const savedPath = name.endsWith('.TXT') ? filePath : `${filePath}.txt`;
      assert.equal(await fs.readFile(savedPath, 'utf8'), draft);
    }
  } finally { await fs.rm(directory, { recursive: true, force: true }); }
});

test('Writing cancellation and empty input do not create exports', async () => {
  const app = await harness();
  assert.equal(await app.handlers.get('save-writing')({ sender: {} }, 'A draft'), false);
  await assert.rejects(app.handlers.get('save-writing')({ sender: {} }, '   '), /Escribe un writing/);
});

test('Main window fills the display work area without fullscreen', async () => {
  const { windowOptions } = await harness();
  for (const [key, value] of Object.entries({ x: 24, y: 40, width: 1440, height: 860, fullscreen: false })) {
    assert.equal(windowOptions[key], value);
  }
});
