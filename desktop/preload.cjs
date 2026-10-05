const { contextBridge, ipcRenderer } = require('electron');
contextBridge.exposeInMainWorld('practice', {
  loadSets: () => ipcRenderer.invoke('load-sets'),
  saveWriting: text => ipcRenderer.invoke('save-writing', text),
});
