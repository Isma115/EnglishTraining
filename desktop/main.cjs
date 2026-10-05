const { app, BrowserWindow, ipcMain, dialog, Menu, screen } = require('electron');
const fs = require('node:fs/promises');
const path = require('node:path');

let window;
const sets = ['grammar', 'reading', 'writing', 'vocabulary'];

function createWindow() {
  const { x, y, width, height } = screen.getPrimaryDisplay().workArea;
  window = new BrowserWindow({
    x, y, width, height, minWidth: 520, minHeight: 520,
    fullscreen: false,
    title: 'Aquí tú me hablas español',
    backgroundColor: '#171b19',
    webPreferences: {
      preload: path.join(__dirname, 'preload.cjs'),
      contextIsolation: true, nodeIntegration: false, sandbox: true,
    },
  });
  Menu.setApplicationMenu(null);
  window.loadFile(path.join(__dirname, 'renderer/index.html'));
  window.webContents.setWindowOpenHandler(() => ({ action: 'deny' }));
  window.webContents.on('will-navigate', event => event.preventDefault());
}

ipcMain.handle('load-sets', async () => {
  const entries = await Promise.all(sets.map(async name => {
    const text = await fs.readFile(path.join(__dirname, '../data', `${name}.json`), 'utf8');
    return [name, JSON.parse(text)];
  }));
  return Object.fromEntries(entries);
});

ipcMain.handle('save-writing', async (event, text) => {
  if (typeof text !== 'string' || !text.trim()) throw new Error('Escribe un writing antes de guardar.');
  const { canceled, filePath } = await dialog.showSaveDialog(BrowserWindow.fromWebContents(event.sender), {
    defaultPath: 'writing.txt', filters: [{ name: 'Texto', extensions: ['txt'] }],
  });
  if (canceled || !filePath) return false;
  await fs.writeFile(filePath.toLowerCase().endsWith('.txt') ? filePath : `${filePath}.txt`, text, 'utf8');
  return true;
});

app.whenReady().then(() => {
  createWindow();
  app.on('activate', () => { if (BrowserWindow.getAllWindows().length === 0) createWindow(); });
});
app.on('window-all-closed', () => { if (process.platform !== 'darwin') app.quit(); });
